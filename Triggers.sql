USE DB_Gestion_Polideportivo_G7;
GO

/* ============================================================
   TRIGGER 1: validar comisiones y horarios
   - El cupo no puede superar la capacidad de la instalacion.
   - Una comision activa requiere una instalacion operativa.
   - No se superponen horarios activos del entrenador ni del lugar.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_COMISION_VALIDAR
ON dbo.COMISION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.INSTALACION ins
            ON ins.id_instalacion = i.id_instalacion
        WHERE i.cupo_maximo > ins.capacidad
    )
    BEGIN
        ;THROW 51001, 'El cupo maximo de la comision supera la capacidad de la instalacion.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.INSTALACION ins
            ON ins.id_instalacion = i.id_instalacion
        WHERE i.estado = 'ACTIVA'
          AND ins.estado <> 'OPERATIVA'
    )
    BEGIN
        ;THROW 51002, 'No se puede activar una comision en una instalacion que no esta operativa.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.COMISION c
            ON c.id_comision <> i.id_comision
           AND c.dia_semana = i.dia_semana
           AND c.id_personal = i.id_personal
           AND c.estado = 'ACTIVA'
           AND i.estado = 'ACTIVA'
           AND i.hora_inicio < c.hora_fin
           AND i.hora_fin > c.hora_inicio
    )
    BEGIN
        ;THROW 51003, 'El entrenador ya tiene otra comision activa en ese dia y horario.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.COMISION c
            ON c.id_comision <> i.id_comision
           AND c.dia_semana = i.dia_semana
           AND c.id_instalacion = i.id_instalacion
           AND c.estado = 'ACTIVA'
           AND i.estado = 'ACTIVA'
           AND i.hora_inicio < c.hora_fin
           AND i.hora_fin > c.hora_inicio
    )
    BEGIN
        ;THROW 51004, 
            'La instalacion ya tiene otra comision activa en ese dia y horario.', 1;
    END;
END;
GO

/* ============================================================
   TRIGGER 2: validar inscripciones activas
   - Socio activo.
   - Comision activa.
   - Membresia vigente en la fecha actual.
   - No superar el cupo de la comision.
   Nota: el indice UX_INSCRIPCION_ACTIVA ya controla duplicados.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_INSCRIPCION_VALIDAR
ON dbo.INSCRIPCION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SOCIO s
            ON s.id_socio = i.id_socio
        INNER JOIN dbo.COMISION c
            ON c.id_comision = i.id_comision
        WHERE i.estado = 'ACTIVA'
          AND (s.estado <> 'ACTIVO' OR c.estado <> 'ACTIVA')
    )
    BEGIN
        ;THROW 51011, 'Solo se puede activar una inscripcion para un socio y una comision activos.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.estado = 'ACTIVA'
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.MEMBRESIA m
              WHERE m.id_socio = i.id_socio
                AND m.estado = 'VIGENTE'
                AND m.fecha_inicio <= CONVERT(DATE, GETDATE())
                AND m.fecha_fin >= CONVERT(DATE, GETDATE())
          )
    )
    BEGIN
        ;THROW 51012, 'El socio debe tener una membresia vigente para inscribirse.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM (SELECT DISTINCT id_comision
              FROM inserted
              WHERE estado = 'ACTIVA') x
        INNER JOIN dbo.COMISION c
            ON c.id_comision = x.id_comision
        CROSS APPLY (
            SELECT COUNT_BIG(*) AS cantidad_inscriptos
            FROM dbo.INSCRIPCION insc
            WHERE insc.id_comision = c.id_comision
              AND insc.estado = 'ACTIVA'
        ) total
        WHERE total.cantidad_inscriptos > c.cupo_maximo
    )
    BEGIN
        ;THROW 51013, 'No hay cupos disponibles en una o mas comisiones.', 1;
    END;
END;
GO

/* ============================================================
   TRIGGER 3: validar reservas
   - Socio habilitado y membresia valida en la fecha reservada.
   - Instalacion operativa y sin mantenimiento que cubra esa fecha.
   - Sin solapamientos de reservas por instalacion ni por socio.
   Solo las reservas PENDIENTE y CONFIRMADA bloquean horarios.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_RESERVA_VALIDAR
ON dbo.RESERVA
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SOCIO s ON s.id_socio = i.id_socio
        WHERE i.estado IN ('PENDIENTE', 'CONFIRMADA')
          AND s.estado <> 'ACTIVO'
    )
    BEGIN
        ;THROW 51021, 'El socio debe estar activo para realizar una reserva.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.estado IN ('PENDIENTE', 'CONFIRMADA')
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.MEMBRESIA m
              WHERE m.id_socio = i.id_socio
                AND m.fecha_inicio <= i.fecha
                AND m.fecha_fin >= i.fecha
                AND m.estado IN ('VIGENTE', 'VENCIDA')
          )
    )
    BEGIN
        ;THROW 51022, 'El socio no tiene una membresia valida para la fecha de la reserva.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.INSTALACION ins
            ON ins.id_instalacion = i.id_instalacion
        WHERE i.estado IN ('PENDIENTE', 'CONFIRMADA')
          AND ins.estado <> 'OPERATIVA'
    )
    BEGIN
        ;THROW 51023, 'No se puede reservar una instalacion que no esta operativa.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.MANTENIMIENTO m
            ON m.id_instalacion = i.id_instalacion
           AND m.estado IN ('PENDIENTE', 'EN_PROCESO')
           AND m.fecha_inicio <= i.fecha
           AND COALESCE(m.fecha_fin_estimada, CONVERT(DATE, '99991231')) >= i.fecha
        WHERE i.estado IN ('PENDIENTE', 'CONFIRMADA')
    )
    BEGIN
        ;THROW 51024, 'La instalacion tiene mantenimiento previsto o en curso para esa fecha.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.RESERVA r
            ON r.id_reserva <> i.id_reserva
           AND r.id_instalacion = i.id_instalacion
           AND r.fecha = i.fecha
           AND r.estado IN ('PENDIENTE', 'CONFIRMADA')
           AND i.estado IN ('PENDIENTE', 'CONFIRMADA')
           AND i.hora_inicio < r.hora_fin
           AND i.hora_fin > r.hora_inicio
    )
    BEGIN
        ;THROW 51025, 'La instalacion ya tiene una reserva en ese dia y horario.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.RESERVA r
            ON r.id_reserva <> i.id_reserva
           AND r.id_socio = i.id_socio
           AND r.fecha = i.fecha
           AND r.estado IN ('PENDIENTE', 'CONFIRMADA')
           AND i.estado IN ('PENDIENTE', 'CONFIRMADA')
           AND i.hora_inicio < r.hora_fin
           AND i.hora_fin > r.hora_inicio
    )
    BEGIN
        ;THROW 51026, 'El socio ya tiene una reserva en ese dia y horario.', 1;
    END;
END;
GO

/* ============================================================
   TRIGGER 4: sincronizar estado de la instalacion con mantenimiento
   - Si existe mantenimiento EN_PROCESO, marca EN_MANTENIMIENTO.
   - Si ya no existe mantenimiento EN_PROCESO, la devuelve a OPERATIVA.
   - No modifica instalaciones marcadas FUERA_SERVICIO manualmente.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_MANTENIMIENTO_ACTUALIZAR_INSTALACION
ON dbo.MANTENIMIENTO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH InstalacionesAfectadas AS (
        SELECT id_instalacion FROM inserted
        UNION
        SELECT id_instalacion FROM deleted
    )
    UPDATE ins
       SET estado = CASE
           WHEN EXISTS (
               SELECT 1
               FROM dbo.MANTENIMIENTO m
               WHERE m.id_instalacion = ins.id_instalacion
                 AND m.estado = 'EN_PROCESO'
           ) THEN 'EN_MANTENIMIENTO'
           ELSE 'OPERATIVA'
       END
    FROM dbo.INSTALACION ins
    INNER JOIN InstalacionesAfectadas a
        ON a.id_instalacion = ins.id_instalacion
    WHERE ins.estado <> 'FUERA_SERVICIO'
      AND (
           (ins.estado = 'EN_MANTENIMIENTO' AND NOT EXISTS (
               SELECT 1
               FROM dbo.MANTENIMIENTO m
               WHERE m.id_instalacion = ins.id_instalacion
                 AND m.estado = 'EN_PROCESO'
           ))
           OR
           (ins.estado <> 'EN_MANTENIMIENTO' AND EXISTS (
               SELECT 1
               FROM dbo.MANTENIMIENTO m
               WHERE m.id_instalacion = ins.id_instalacion
                 AND m.estado = 'EN_PROCESO'
           ))
      );
END;
GO

/* ============================================================
   TRIGGER 5: validar correspondencia entre pago y membresia
   - El pago y la membresia vinculada deben pertenecer al mismo socio.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_PAGO_MEMBRESIA_VALIDAR_SOCIO
ON dbo.PAGO_MEMBRESIA
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted pm
        INNER JOIN dbo.PAGO p
            ON p.id_pago = pm.id_pago
        INNER JOIN dbo.MEMBRESIA m
            ON m.id_membresia = pm.id_membresia
        WHERE p.id_socio <> m.id_socio
    )
    BEGIN
        ;THROW 51031, 'El pago y la membresia asociada deben pertenecer al mismo socio.', 1;
    END;
END;
GO

/* ============================================================
   TRIGGER 6: impedir programar mantenimiento sobre reservas activas
   - Evita iniciar/programar mantenimiento en fechas con reservas
     pendientes o confirmadas para la misma instalacion.
   - Primero se deben cancelar o reprogramar esas reservas.
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.TR_MANTENIMIENTO_VALIDAR_RESERVAS
ON dbo.MANTENIMIENTO
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted m
        INNER JOIN dbo.RESERVA r
            ON r.id_instalacion = m.id_instalacion
           AND r.fecha >= m.fecha_inicio
           AND r.fecha <= COALESCE(m.fecha_fin_estimada, CONVERT(DATE, '99991231'))
           AND r.estado IN ('PENDIENTE', 'CONFIRMADA')
        WHERE m.estado IN ('PENDIENTE', 'EN_PROCESO')
    )
    BEGIN
        ;THROW 51041, 'No se puede programar mantenimiento mientras existan reservas pendientes o confirmadas en ese periodo. Reprograme o cancele las reservas primero.', 1;
    END;
END;
GO