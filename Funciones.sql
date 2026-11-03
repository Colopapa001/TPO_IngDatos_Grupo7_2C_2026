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

-- 3. Devolver saldo de un contrato
CREATE FUNCTION dbo.fn_SaldoMembresia
(
    @id_membresia INT
)
RETURNS DECIMAL(19,2)
AS
BEGIN
    DECLARE @precio_contratado DECIMAL(12,2);
    DECLARE @id_socio_titular INT;
    DECLARE @total_pagado DECIMAL(19,2);

    SELECT @precio_contratado = precio_contratado,
           @id_socio_titular = id_socio
    FROM dbo.MEMBRESIA
    WHERE id_membresia = @id_membresia;

    IF @precio_contratado IS NULL
        RETURN NULL;

    SELECT @total_pagado = SUM(pago.importe)
    FROM dbo.PAGO_MEMBRESIA AS aplicacion
    INNER JOIN dbo.PAGO AS pago ON pago.id_pago = aplicacion.id_pago
    WHERE aplicacion.id_membresia = @id_membresia
      AND pago.id_socio = @id_socio_titular
      AND pago.estado = 'APROBADO';

    -- Si la suma devuelve NULL, entonces no se cubrio ningun importe
    IF @total_pagado IS NULL
        SET @total_pagado = 0;

    -- Usar el precio contratado, conservar sobrepagos como saldo negativo
    RETURN @precio_contratado - @total_pagado;
END;
GO
