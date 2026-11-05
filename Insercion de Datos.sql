/*
 DATOS DE PRUEBA AMPLIADOS - POLIDEPORTIVO
 SQL Server
 Ejecutar sobre las 18 tablas recién creadas y vacías.
*/

use DB_Gestion_Polideportivo_G7

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 1. SOCIOS (Perfiles y estados variados para probar validaciones)
INSERT INTO dbo.SOCIO
    (dni, nombre, apellido, fecha_nacimiento, telefono, email,
     direccion, fecha_alta, estado)
VALUES
    ('30111222', N'Juan', N'Pérez', '1998-03-12', '1144556601', 'juan@mail.com', N'Caballito', '2026-03-01', 'ACTIVO'),
    ('32222333', N'María', N'Gómez', '2001-07-24', '1144556602', 'maria@mail.com', N'Flores', '2026-04-01', 'ACTIVO'),
    ('33444555', N'Lucas', N'Fernández', '1995-11-05', '1144556603', 'lucas@mail.com', N'Almagro', '2026-05-01', 'ACTIVO'),
    ('35666777', N'Carla', N'Sánchez', '1992-02-15', '1144556604', 'carla@mail.com', N'Belgrano', '2026-06-01', 'ACTIVO'),
    ('36777888', N'Lucía', N'Jackson', '2000-05-14', '1144556610', 'lucia.jackson@mail.com', N'Villa Luro', '2026-07-01', 'ACTIVO'),
    ('37888999', N'Bruno', N'Guerrero', '1988-09-22', '1144556611', 'bruno.guerrero@mail.com', N'Banfield', '2026-08-01', 'SUSPENDIDO'),
    ('38999000', N'Elena', N'Scarpello', '1996-12-03', '1144556612', 'elena.scarpello@mail.com', N'Haedo', '2026-09-01', 'BAJA');

-- 2. PLANES
INSERT INTO dbo.PLAN_MEMBRESIA
    (nombre, descripcion, precio_actual, duracion_meses, estado)
VALUES
    (N'Plan Integral', N'Acceso general al polideportivo', 45000, 1, 'ACTIVO'),
    (N'Plan Natación', N'Acceso a clases de natación', 32000, 1, 'ACTIVO'),
    (N'Plan Premium', N'Acceso total libre', 70000, 1, 'ACTIVO');

-- 3. MEMBRESÍAS
INSERT INTO dbo.MEMBRESIA
    (id_socio, id_plan, fecha_inicio, fecha_fin, precio_contratado, estado)
VALUES
    (1, 1, '2026-10-01', '2026-11-30', 45000, 'VIGENTE'),
    (2, 2, '2026-10-01', '2026-11-30', 32000, 'VIGENTE'),
    (3, 1, '2026-10-01', '2026-11-30', 45000, 'VIGENTE'),
    (4, 3, '2026-10-01', '2026-11-30', 70000, 'VIGENTE');

-- 4. ACTIVIDADES
INSERT INTO dbo.ACTIVIDAD (nombre, descripcion, estado)
VALUES
    (N'Fútbol', N'Entrenamiento de fútbol', 'ACTIVA'),
    (N'Natación', N'Clases de natación', 'ACTIVA'),
    (N'Musculación', N'Entrenamiento de fuerza', 'ACTIVA'),
    (N'Yoga', N'Clases de relajación y estiramiento', 'ACTIVA');

-- 5. PERSONAL
INSERT INTO dbo.PERSONAL (dni, nombre, apellido, telefono, email, estado)
VALUES
    ('25111222', N'Ana', N'Pérez', '1144667701', 'ana@polideportivo.com', 'ACTIVO'),
    ('26333444', N'Diego', N'Fernández', '1144667702', 'diego@polideportivo.com', 'ACTIVO'),
    ('27444555', N'Laura', N'Gómez', '1144667703', 'laura@polideportivo.com', 'ACTIVO'),
    ('28555666', N'Sergio', N'López', '1144667704', 'sergio@polideportivo.com', 'ACTIVO'),
    ('29666777', N'Manuel José Joaquín', N'del Corazón de Jesús Belgrano', '1144667705', 'manueljj@polideportivo.com', 'ACTIVO');

-- 6. ENTRENADORES (subtipo de PERSONAL)
INSERT INTO dbo.ENTRENADOR(id_personal, especialidad)
VALUES
    (1, N'Fútbol'),
    (2, N'Natación'),
    (3, N'Musculación'),
    (4, N'Yoga'),
    (5, N'Functional');

-- 7. INSTALACIONES
INSERT INTO dbo.INSTALACION
    (nombre, tipo_instalacion, ubicacion, capacidad, estado)
VALUES
    (N'Cancha de fútbol', 'CANCHA', N'Sector exterior', 22, 'OPERATIVA'),
    (N'Piscina principal', 'PISCINA', N'Edificio central', 30, 'OPERATIVA'),
    (N'Gimnasio', 'GIMNASIO', N'Planta baja', 25, 'OPERATIVA'),
    (N'Salón multiuso', 'SALON', N'Primer piso', 20, 'OPERATIVA');

-- 8. COMISIONES / HORARIOS
INSERT INTO dbo.COMISION
    (id_actividad, id_personal, id_instalacion, dia_semana,
     hora_inicio, hora_fin, cupo_maximo, estado)
VALUES
    (1, 1, 1, 'LUNES', '18:00', '19:30', 20, 'ACTIVA'),
    (2, 2, 2, 'MARTES', '18:00', '19:00', 20, 'ACTIVA'),
    (3, 3, 3, 'MIERCOLES', '10:00', '11:00', 20, 'ACTIVA'),
    (4, 4, 4, 'JUEVES', '09:00', '10:00', 15, 'ACTIVA'),
    (1, 1, 1, 'MARTES', '18:00', '19:30', 5, 'ACTIVA'),
    (4, 4, 4, 'SABADO', '10:00', '11:00', 15, 'ACTIVA');

-- 9. INSCRIPCIONES (Socio 1 inscripto en 2 actividades para probar recomendación)
INSERT INTO dbo.INSCRIPCION
    (id_socio, id_comision, fecha_inscripcion, fecha_baja, estado)
VALUES
    (1, 1, '2026-10-01', NULL, 'ACTIVA'), -- Socio 1 en Fútbol
    (1, 2, '2026-10-01', NULL, 'ACTIVA'), -- Socio 1 en Natación (Tiene 2 activas)
    (2, 3, '2026-10-01', NULL, 'ACTIVA'), -- Socio 2 en Musculación
    (3, 1, '2026-10-01', NULL, 'ACTIVA'), -- Socio 3 en Fútbol
    (4, 1, '2026-10-01', NULL, 'ACTIVA'), -- Socio 4 en Fútbol
    (4, 2, '2026-10-01', NULL, 'ACTIVA'), -- Socio 4 en Natación (Tiene 2 activas)
    (1, 5, '2026-10-01', NULL, 'ACTIVA'), -- Socio 1 en Fútbol (comisión con poco cupo)
    (2, 5, '2026-10-01', NULL, 'ACTIVA'),
    (3, 5, '2026-10-01', NULL, 'ACTIVA'),
    (4, 5, '2026-10-01', NULL, 'ACTIVA'), -- Comisión 5 queda con 4 de 5 lugares
    (1, 6, '2026-10-01', '2026-10-15', 'BAJA'); -- Historial para probar reactivación

-- 10. ASISTENCIAS
INSERT INTO dbo.ASISTENCIA (id_inscripcion, fecha, estado)
VALUES
    (1, '2026-10-19', 'PRESENTE'),
    (2, '2026-10-20', 'PRESENTE'),
    (3, '2026-10-21', 'PRESENTE'),
    (1, '2026-10-26', 'AUSENTE'),
    (2, '2026-10-27', 'JUSTIFICADA'),
    (7, '2026-10-27', 'PRESENTE'),
    (8, '2026-10-28', 'AUSENTE'),
    (9, '2026-10-28', 'JUSTIFICADA'),
    (10, '2026-10-29', 'PRESENTE');

-- 11. RESERVAS
INSERT INTO dbo.RESERVA
    (id_socio, id_instalacion, fecha, hora_inicio, hora_fin, estado)
VALUES
    (1, 1, '2026-10-23', '16:00', '17:00', 'CONFIRMADA'),
    (2, 2, '2026-10-24', '14:00', '15:00', 'CONFIRMADA'),
    (3, 3, '2026-10-25', '10:00', '11:00', 'CONFIRMADA'),
    (1, 2, '2026-10-26', '12:00', '13:00', 'CONFIRMADA'),
    (1, 1, '2026-11-12', '16:00', '17:00', 'PENDIENTE'),
    (2, 2, '2026-10-27', '14:00', '15:00', 'CANCELADA'),
    (3, 3, '2026-10-28', '10:00', '11:00', 'FINALIZADA');

-- 12. PAGOS (Incluye pagos altos para superar el promedio, y socio 3 sin pagar con tarjeta)
INSERT INTO dbo.PAGO
    (id_socio, importe, fecha_pago, concepto, medio_pago, estado)
VALUES
    (1, 45000, '2026-10-01', N'Membresía integral', 'TRANSFERENCIA', 'APROBADO'),
    (2, 32000, '2026-10-01', N'Membresía natación', 'EFECTIVO', 'APROBADO'),
    (3, 95000, '2026-10-01', N'Pago anual VIP', 'TRANSFERENCIA', 'APROBADO'), -- Pago alto superior al promedio
    (4, 70000, '2026-10-01', N'Plan Premium', 'TARJETA_CREDITO', 'APROBADO'); -- Socio 4 pagó con tarjeta

-- 13. RELACIÓN ENTRE PAGOS Y MEMBRESÍAS
INSERT INTO dbo.PAGO_MEMBRESIA (id_pago, id_membresia)
VALUES (1, 1), (2, 2), (3, 3), (4, 4);

-- 14. MANTENIMIENTOS
INSERT INTO dbo.MANTENIMIENTO
    (id_instalacion, id_responsable, tipo, descripcion,
     fecha_inicio, fecha_fin_estimada, fecha_fin_real, estado)
VALUES
    (1, 4, 'PREVENTIVO', N'Revisión de iluminación de la cancha',
     '2026-09-01', '2026-09-03', '2026-09-03', 'FINALIZADO'),
    (2, 5, 'CORRECTIVO', N'Reparación del sistema de filtrado de pileta',
     '2026-11-16', '2026-11-20', NULL, 'PENDIENTE'),
    (3, 4, 'PREVENTIVO', N'Revisión de máquinas y equipamiento del gimnasio',
     '2026-11-06', '2026-11-10', NULL, 'EN_PROCESO'),
    (4, 5, 'OTRO', N'Reacondicionamiento del salón multiuso',
     '2026-10-10', '2026-10-12', NULL, 'CANCELADO'),
    (2, 5, 'PREVENTIVO', N'Limpieza técnica de la piscina',
     '2026-10-01', '2026-10-02', '2026-10-02', 'FINALIZADO');

-- 15. ACCESOS
INSERT INTO dbo.ACCESO
    (id_socio, fecha_hora_ingreso, fecha_hora_egreso)
VALUES
    (1, '2026-10-21T10:00:00', '2026-10-21T11:30:00'),
    (2, '2026-10-20T14:00:00', '2026-10-20T15:00:00');

-- =========================================
-- 16. USUARIOS DEL SISTEMA
-- =========================================

INSERT INTO dbo.USUARIO_SISTEMA
    (id_personal, nombre_usuario, password_hash, estado)

SELECT
    P.id_personal,
    V.nombre_usuario,
    CONVERT(VARCHAR(64),
        HASHBYTES('SHA2_256', V.password_demo), 2),
    'ACTIVO'
FROM (VALUES
    ('25111222', 'ana.perez', 'Demo-Ana-2026!'),
    ('26333444', 'diego.fernandez', 'Demo-Diego-2026!'),
    ('27444555', 'laura.gomez', 'Demo-Laura-2026!'),
    ('28555666', 'sergio.lopez', 'Demo-Sergio-2026!'),
    ('29666777', 'manuel.belgrano', 'Demo-Manuel-2026!')
) AS V(dni, nombre_usuario, password_demo)

INNER JOIN dbo.PERSONAL P
    ON P.dni = V.dni

WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.USUARIO_SISTEMA U
    WHERE U.id_personal = P.id_personal
       OR U.nombre_usuario = V.nombre_usuario
);


-- =========================================
-- 17. ROLES
-- =========================================

INSERT INTO dbo.ROL (nombre, descripcion)
SELECT V.nombre, V.descripcion
FROM (VALUES
    ('ADMINISTRADOR', N'Administracion general'),
    ('RECEPCION', N'Gestion de socios, membresias y pagos'),
    ('PROFESOR', N'Gestion de actividades y asistencias'),
    ('MANTENIMIENTO', N'Gestion de instalaciones'),
    ('GERENCIA', N'Consultas y reportes')
) AS V(nombre, descripcion)

WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ROL R
    WHERE R.nombre = V.nombre
);


-- =========================================
-- 18. ASIGNACION DE ROLES
-- =========================================

INSERT INTO dbo.USUARIO_ROL
    (id_usuario, id_rol)

SELECT
    U.id_usuario,
    R.id_rol

FROM (VALUES
    ('ana.perez', 'PROFESOR'),
    ('diego.fernandez', 'RECEPCION'),
    ('laura.gomez', 'GERENCIA'),
    ('sergio.lopez', 'MANTENIMIENTO'),
    ('manuel.belgrano', 'ADMINISTRADOR')
) AS V(nombre_usuario, nombre_rol)

INNER JOIN dbo.USUARIO_SISTEMA U
    ON U.nombre_usuario = V.nombre_usuario

INNER JOIN dbo.ROL R
    ON R.nombre = V.nombre_rol

WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.USUARIO_ROL UR
    WHERE UR.id_usuario = U.id_usuario
      AND UR.id_rol = R.id_rol
);


COMMIT TRANSACTION;