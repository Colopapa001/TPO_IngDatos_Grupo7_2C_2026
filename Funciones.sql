USE DB_Gestion_Polideportivo_G7;
GO

-- 1. Cupos de una comision
CREATE FUNCTION dbo.fn_CuposDisponibles
(
    @id_comision INT
)
RETURNS INT
AS
BEGIN
    DECLARE @cupo_maximo INT;
    DECLARE @estado_comision VARCHAR(10);
    DECLARE @inscriptos_activos INT;

    -- Guardar en variables los datos de la comision solicitada
    SELECT @cupo_maximo = cupo_maximo,
           @estado_comision = estado
    FROM dbo.COMISION
    WHERE id_comision = @id_comision;

    -- Si no hubo fila, la variable sigue nula
    IF @cupo_maximo IS NULL
        RETURN NULL;

    IF @estado_comision <> 'ACTIVA'
        RETURN 0;

    -- Una baja no ocupa plaza, pero un socio suspendido con inscripcion activa si
    SELECT @inscriptos_activos = COUNT(*)
    FROM dbo.INSCRIPCION
    WHERE id_comision = @id_comision
      AND estado = 'ACTIVA';

    -- Un negativo detecta que los datos ya superan el cupo
    RETURN @cupo_maximo - @inscriptos_activos;
END;
GO

-- 2. Socio activo con contrato valido en la fecha, como TR_RESERVA_VALIDAR
CREATE FUNCTION dbo.fn_SocioHabilitado
(
    @id_socio INT,
    @fecha_referencia DATE
)
RETURNS BIT
AS
BEGIN
    IF @id_socio IS NULL OR @fecha_referencia IS NULL
        RETURN 0;

    -- Consulta si hay al menos una combinacion que cumpla todo
    IF EXISTS
    (
        SELECT 1
        FROM dbo.SOCIO AS socio
        INNER JOIN dbo.MEMBRESIA AS membresia
            ON membresia.id_socio = socio.id_socio
        WHERE socio.id_socio = @id_socio
          AND socio.estado = 'ACTIVO'
          AND socio.fecha_alta <= @fecha_referencia
          AND membresia.estado IN ('VIGENTE', 'VENCIDA')
          AND @fecha_referencia BETWEEN membresia.fecha_inicio AND membresia.fecha_fin
    )
        RETURN 1;

    RETURN 0;
END;
GO


-- 3 dias restantes que le quedan a una membresia
CREATE FUNCTION dbo.fn_DiasRestantesMembresia
(
    @id_membresia INT
)
RETURNS INT
AS
BEGIN
    DECLARE @fecha_fin DATE;

    SELECT @fecha_fin = fecha_fin
    FROM dbo.MEMBRESIA
    WHERE id_membresia = @id_membresia;

    -- Si la membresía no existe
    IF @fecha_fin IS NULL
        RETURN NULL;

    -- Calcular días restantes hasta el vencimiento
    RETURN DATEDIFF(
        DAY,
        CONVERT(DATE, GETDATE()),
        @fecha_fin
    );
END;
GO

/*
4- Verifica si hay una clase activa en una cierta fecha y hora para una instalación.
Devuelve 0 si la instalación no tiene clases, 1 si hay una clase. 
*/
CREATE FUNCTION dbo.fn_InstalacionTieneClases (
    @id_instalacion INT,
    @fecha_consulta DATE,
    @hora_inicio_consulta TIME(0),
    @hora_fin_consulta TIME(0)
)
RETURNS INT
AS
BEGIN
    -- Variables para almacenar el día de la semana correspondiente a la fecha
    DECLARE @dia_semana VARCHAR(20);
    DECLARE @tiene_clase INT = 0; 

    -- Determinar el día de la semana de la fecha consultada.
    SET @dia_semana = UPPER(DATENAME(WEEKDAY, @fecha_consulta));

    -- Verificar si existe alguna comisión activa en esa instalación, 
    -- en el mismo día de la semana, que se superponga con el horario consultado.
    IF EXISTS (
        SELECT 1
        FROM dbo.COMISION AS c
        WHERE c.id_instalacion = @id_instalacion
          AND c.estado = 'ACTIVA'
          AND c.dia_semana = @dia_semana
          AND c.hora_inicio < @hora_fin_consulta
          AND c.hora_fin > @hora_inicio_consulta
    )
    BEGIN
        SET @tiene_clase = 1; -- Sí, tiene clases en ese horario
    END

    RETURN @tiene_clase;
END;
GO
