USE DB_Gestion_Polideportivo_G7;
GO

-- =============================================
-- VISTA 1: SOCIOS CON MEMBRESÍAS VIGENTES
-- =============================================

CREATE VIEW VW_SOCIOS_MEMBRESIAS_VIGENTES
AS
SELECT
    s.id_socio,
    s.nombre,
    s.apellido,
    p.nombre AS nombre_plan,
    m.fecha_inicio,
    m.fecha_fin,
    m.estado
FROM SOCIO s
INNER JOIN MEMBRESIA m
    ON s.id_socio = m.id_socio
INNER JOIN PLAN_MEMBRESIA p
    ON m.id_plan = p.id_plan
WHERE m.estado = 'VIGENTE';
GO

-- =============================================
-- VISTA 2: INSCRIPTOS POR ACTIVIDAD
-- =============================================

CREATE VIEW VW_INSCRIPTOS_ACTIVIDADES
AS
SELECT
    a.nombre AS actividad,
    s.id_socio,
    s.nombre,
    s.apellido,
    i.fecha_inscripcion,
    i.estado
FROM INSCRIPCION i
INNER JOIN SOCIO s
    ON i.id_socio = s.id_socio
INNER JOIN COMISION c
    ON i.id_comision = c.id_comision
INNER JOIN ACTIVIDAD a
    ON c.id_actividad = a.id_actividad;
GO

-- =============================================
-- VISTA 3: RESERVAS DE INSTALACIONES
-- =============================================

CREATE VIEW VW_RESERVAS_INSTALACIONES
AS
SELECT
    r.id_reserva,
    s.nombre,
    s.apellido,
    i.nombre AS instalacion,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.estado
FROM RESERVA r
INNER JOIN SOCIO s
    ON r.id_socio = s.id_socio
INNER JOIN INSTALACION i
    ON r.id_instalacion = i.id_instalacion;
GO

-- =============================================
-- VISTA 4: PAGOS APROBADOS
-- =============================================

CREATE VIEW VW_PAGOS_APROBADOS
AS
SELECT
    p.id_pago,
    s.nombre,
    s.apellido,
    p.importe,
    p.fecha_pago,
    p.concepto,
    p.medio_pago
FROM PAGO p
INNER JOIN SOCIO s
    ON p.id_socio = s.id_socio
WHERE p.estado = 'APROBADO';
GO

-- =============================================
-- VISTA 5: MANTENIMIENTOS ACTIVOS
-- =============================================

CREATE VIEW VW_MANTENIMIENTOS_ACTIVOS
AS
SELECT
    i.nombre AS instalacion,
    p.nombre + ' ' + p.apellido AS responsable,
    m.tipo,
    m.fecha_inicio,
    m.fecha_fin_estimada,
    m.estado
FROM MANTENIMIENTO m
INNER JOIN INSTALACION i
    ON m.id_instalacion = i.id_instalacion
INNER JOIN PERSONAL p
    ON m.id_responsable = p.id_personal
WHERE m.estado = 'EN_PROCESO';
GO