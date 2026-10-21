/*
 DATOS DE PRUEBA SIMPLIFICADOS - POLIDEPORTIVO
 SQL Server
 Ejecutar sobre las 18 tablas recién creadas y vacías.
 Este ejemplo usa los ID que se generan al insertar desde tablas vacías.
*/

use DB_Gestion_Polideportivo_G7

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 1. SOCIOS
INSERT INTO dbo.SOCIO
    (dni, nombre, apellido, fecha_nacimiento, telefono, email,
     direccion, fecha_alta, estado)
VALUES
    ('30111222', N'Juan', N'Pérez', '1998-03-12', '1144556601', 'juan@mail.com', N'Caballito', '2026-03-01', 'ACTIVO'),
    ('32222333', N'María', N'Gómez', '2001-07-24', '1144556602', 'maria@mail.com', N'Flores', '2026-04-01', 'ACTIVO'),
    ('33444555', N'Lucas', N'Fernández', '1995-11-05', '1144556603', 'lucas@mail.com', N'Almagro', '2026-05-01', 'SUSPENDIDO');

-- 2. PLANES
INSERT INTO dbo.PLAN_MEMBRESIA
    (nombre, descripcion, precio_actual, duracion_meses, estado)
VALUES
    (N'Plan Integral', N'Acceso general al polideportivo', 45000, 1, 'ACTIVO'),
    (N'Plan Natación', N'Acceso a clases de natación', 32000, 1, 'ACTIVO');

-- 3. MEMBRESÍAS
INSERT INTO dbo.MEMBRESIA
    (id_socio, id_plan, fecha_inicio, fecha_fin, precio_contratado, estado)
VALUES
    (1, 1, '2026-10-01', '2026-10-31', 45000, 'VIGENTE'),
    (2, 2, '2026-08-01', '2026-08-31', 32000, 'VENCIDA'),
    (3, 1, '2026-10-01', '2026-10-31', 45000, 'SUSPENDIDA');

-- 4. ACTIVIDADES
INSERT INTO dbo.ACTIVIDAD (nombre, descripcion, estado)
VALUES
    (N'Fútbol', N'Entrenamiento de fútbol', 'ACTIVA'),
    (N'Natación', N'Clases de natación', 'ACTIVA'),
    (N'Musculación', N'Entrenamiento de fuerza', 'ACTIVA');

-- 5. PERSONAL
INSERT INTO dbo.PERSONAL (dni, nombre, apellido, telefono, email, estado)
VALUES
    ('25111222', N'Ana', N'Martínez', '1144667701', 'ana@polideportivo.com', 'ACTIVO'),
    ('26333444', N'Diego', N'Fernández', '1144667702', 'diego@polideportivo.com', 'ACTIVO'),
    ('27444555', N'Laura', N'Gómez', '1144667703', 'laura@polideportivo.com', 'ACTIVO'),
    ('28555666', N'Sergio', N'López', '1144667704', 'sergio@polideportivo.com', 'ACTIVO');

-- 6. ENTRENADORES (subtipo de PERSONAL)
INSERT INTO dbo.ENTRENADOR(id_personal, especialidad)
VALUES
    (1, N'Fútbol'),
    (2, N'Natación'),
    (3, N'Musculación');

-- 7. INSTALACIONES
INSERT INTO dbo.INSTALACION
    (nombre, tipo_instalacion, ubicacion, capacidad, estado)
VALUES
    (N'Cancha de fútbol', 'CANCHA', N'Sector exterior', 22, 'OPERATIVA'),
    (N'Piscina principal', 'PISCINA', N'Edificio central', 30, 'OPERATIVA'),
    (N'Gimnasio', 'GIMNASIO', N'Planta baja', 25, 'OPERATIVA'),
    (N'Salón multiuso', 'SALON', N'Primer piso', 20, 'EN_MANTENIMIENTO');

-- 8. COMISIONES / HORARIOS
INSERT INTO dbo.COMISION
    (id_actividad, id_personal, id_instalacion, dia_semana,
     hora_inicio, hora_fin, cupo_maximo, estado)
VALUES
    (1, 1, 1, 'LUNES', '18:00', '19:30', 20, 'ACTIVA'),
    (2, 2, 2, 'MARTES', '18:00', '19:00', 20, 'ACTIVA'),
    (3, 3, 3, 'MIERCOLES', '10:00', '11:00', 20, 'ACTIVA');

-- 9. INSCRIPCIONES
INSERT INTO dbo.INSCRIPCION
    (id_socio, id_comision, fecha_inscripcion, fecha_baja, estado)
VALUES
    (1, 1, '2026-10-01', NULL, 'ACTIVA'),
    (2, 2, '2026-08-01', '2026-08-31', 'BAJA'),
    (3, 3, '2026-10-01', NULL, 'ACTIVA');

-- 10. ASISTENCIAS
INSERT INTO dbo.ASISTENCIA (id_inscripcion, fecha, estado)
VALUES
    (1, '2026-10-19', 'PRESENTE'),
    (2, '2026-10-20', 'AUSENTE'),
    (3, '2026-10-21', 'PRESENTE');

-- 11. RESERVAS
INSERT INTO dbo.RESERVA
    (id_socio, id_instalacion, fecha, hora_inicio, hora_fin, estado)
VALUES
    (1, 1, '2026-10-23', '16:00', '17:00', 'CONFIRMADA'),
    (2, 2, '2026-10-24', '14:00', '15:00', 'PENDIENTE'),
    (3, 3, '2026-10-25', '10:00', '11:00', 'CANCELADA');

-- 12. PAGOS
INSERT INTO dbo.PAGO
    (id_socio, importe, fecha_pago, concepto, medio_pago, estado)
VALUES
    (1, 45000, '2026-10-01', N'Membresía integral', 'TRANSFERENCIA', 'APROBADO'),
    (2, 32000, '2026-08-01', N'Membresía natación', 'EFECTIVO', 'APROBADO'),
    (3, 45000, '2026-10-01', N'Membresía integral', 'TARJETA_CREDITO', 'RECHAZADO');

-- 13. RELACIÓN ENTRE PAGOS Y MEMBRESÍAS
INSERT INTO dbo.PAGO_MEMBRESIA (id_pago, id_membresia)
VALUES (1, 1), (2, 2), (3, 3);

-- 14. MANTENIMIENTOS
INSERT INTO dbo.MANTENIMIENTO
    (id_instalacion, id_responsable, tipo, descripcion,
     fecha_inicio, fecha_fin_estimada, fecha_fin_real, estado)
VALUES
    (1, 4, 'PREVENTIVO', N'Revisión de iluminación de la cancha',
     '2026-09-01', '2026-09-03', '2026-09-03', 'FINALIZADO'),
    (4, 4, 'CORRECTIVO', N'Reparación del salón multiuso',
     '2026-10-20', '2026-10-25', NULL, 'EN_PROCESO');

-- 15. ACCESOS
INSERT INTO dbo.ACCESO
    (id_socio, fecha_hora_ingreso, fecha_hora_egreso)
VALUES
    (1, '2026-10-21T10:00:00', '2026-10-21T11:30:00'),
    (2, '2026-10-20T14:00:00', '2026-10-20T15:00:00'),
    (3, '2026-10-21T09:00:00', NULL);

-- 16. USUARIOS DEL SISTEMA
INSERT INTO dbo.USUARIO_SISTEMA
    (id_personal, nombre_usuario, password_hash, estado)
VALUES
    (1, 'ana.martinez', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'demo-ana'), 2), 'ACTIVO'),
    (4, 'sergio.lopez', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', 'demo-sergio'), 2), 'ACTIVO');

-- 17. ROLES
INSERT INTO dbo.ROL (nombre, descripcion)
VALUES
    ('ADMINISTRADOR', N'Administración del sistema'),
    ('PROFESOR', N'Gestión de clases y asistencias'),
    ('MANTENIMIENTO', N'Gestión del mantenimiento');

-- 18. ASIGNACIÓN DE ROLES
INSERT INTO dbo.USUARIO_ROL (id_usuario, id_rol)
VALUES
    (1, 2),
    (2, 3);

COMMIT TRANSACTION;

-- Verificación sencilla: cantidad de registros por tabla.
SELECT 'SOCIO' AS tabla, COUNT(*) AS cantidad FROM dbo.SOCIO
UNION ALL SELECT 'PLAN_MEMBRESIA', COUNT(*) FROM dbo.PLAN_MEMBRESIA
UNION ALL SELECT 'MEMBRESIA', COUNT(*) FROM dbo.MEMBRESIA
UNION ALL SELECT 'ACTIVIDAD', COUNT(*) FROM dbo.ACTIVIDAD
UNION ALL SELECT 'PERSONAL', COUNT(*) FROM dbo.PERSONAL
UNION ALL SELECT 'ENTRENADOR', COUNT(*) FROM dbo.ENTRENADOR
UNION ALL SELECT 'INSTALACION', COUNT(*) FROM dbo.INSTALACION
UNION ALL SELECT 'COMISION', COUNT(*) FROM dbo.COMISION
UNION ALL SELECT 'INSCRIPCION', COUNT(*) FROM dbo.INSCRIPCION
UNION ALL SELECT 'ASISTENCIA', COUNT(*) FROM dbo.ASISTENCIA
UNION ALL SELECT 'RESERVA', COUNT(*) FROM dbo.RESERVA
UNION ALL SELECT 'PAGO', COUNT(*) FROM dbo.PAGO
UNION ALL SELECT 'PAGO_MEMBRESIA', COUNT(*) FROM dbo.PAGO_MEMBRESIA
UNION ALL SELECT 'MANTENIMIENTO', COUNT(*) FROM dbo.MANTENIMIENTO
UNION ALL SELECT 'ACCESO', COUNT(*) FROM dbo.ACCESO
UNION ALL SELECT 'USUARIO_SISTEMA', COUNT(*) FROM dbo.USUARIO_SISTEMA
UNION ALL SELECT 'ROL', COUNT(*) FROM dbo.ROL
UNION ALL SELECT 'USUARIO_ROL', COUNT(*) FROM dbo.USUARIO_ROL;
