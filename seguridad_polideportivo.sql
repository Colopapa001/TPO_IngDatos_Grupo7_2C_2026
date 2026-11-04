/*
    SEGURIDAD - DB_Gestion_Polideportivo_G7
    SQL Server

    IMPORTANTE:
    - Ejecutar con una cuenta con permisos para crear LOGINS en el servidor
      y usuarios/roles/permisos en la base de datos (por ejemplo, sysadmin).
    - Las contrasenas incluidas son SOLO para pruebas academicas locales.
      Reemplazarlas por contrasenas propias antes de usar fuera del entorno de prueba.
    - Se utiliza autenticacion SQL. El servidor debe tener habilitado el modo mixto.
    - El script es idempotente en la creacion de logins, usuarios y roles:
      si ya existen, no los vuelve a crear. Los GRANT pueden volver a ejecutarse.
*/

/* ============================================================
   1. CREACION DE LOGINS A NIVEL SERVIDOR
   ============================================================ */
USE master;
GO

IF DB_ID(N'DB_Gestion_Polideportivo_G7') IS NULL
BEGIN
    ;THROW 50001, 'No existe la base DB_Gestion_Polideportivo_G7.', 1;
END;
GO

IF SUSER_ID(N'login_poli_admin') IS NULL
    CREATE LOGIN [login_poli_admin]
    WITH PASSWORD = N'G7!Azul_Cancha#91Q', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

IF SUSER_ID(N'login_poli_recepcion') IS NULL
    CREATE LOGIN [login_poli_recepcion]
    WITH PASSWORD = N'G7!Faro_Entrada#58Q', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

IF SUSER_ID(N'login_poli_profesor') IS NULL
    CREATE LOGIN [login_poli_profesor]
    WITH PASSWORD = N'G7!Clase_Comision#64Q', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

IF SUSER_ID(N'login_poli_mantenimiento') IS NULL
    CREATE LOGIN [login_poli_mantenimiento]
    WITH PASSWORD = N'G7!Taller_Piscina#73Q', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

IF SUSER_ID(N'login_poli_gerencia') IS NULL
    CREATE LOGIN [login_poli_gerencia]
    WITH PASSWORD = N'G7!Panel_Informe#82Q', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

/* ============================================================
   2. USUARIOS Y ROLES A NIVEL BASE DE DATOS
   ============================================================ */
USE DB_Gestion_Polideportivo_G7;
GO

-- Roles operativos. Cada rol recibe solamente los permisos necesarios.
IF DATABASE_PRINCIPAL_ID(N'rol_recepcion') IS NULL
    CREATE ROLE [rol_recepcion] AUTHORIZATION [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'rol_profesor') IS NULL
    CREATE ROLE [rol_profesor] AUTHORIZATION [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'rol_mantenimiento') IS NULL
    CREATE ROLE [rol_mantenimiento] AUTHORIZATION [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'rol_gerencia') IS NULL
    CREATE ROLE [rol_gerencia] AUTHORIZATION [dbo];
GO

-- Usuarios de base de datos vinculados a los logins del servidor.
IF DATABASE_PRINCIPAL_ID(N'usr_poli_admin') IS NULL
    CREATE USER [usr_poli_admin] FOR LOGIN [login_poli_admin] WITH DEFAULT_SCHEMA = [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'usr_poli_recepcion') IS NULL
    CREATE USER [usr_poli_recepcion] FOR LOGIN [login_poli_recepcion] WITH DEFAULT_SCHEMA = [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'usr_poli_profesor') IS NULL
    CREATE USER [usr_poli_profesor] FOR LOGIN [login_poli_profesor] WITH DEFAULT_SCHEMA = [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'usr_poli_mantenimiento') IS NULL
    CREATE USER [usr_poli_mantenimiento] FOR LOGIN [login_poli_mantenimiento] WITH DEFAULT_SCHEMA = [dbo];
GO
IF DATABASE_PRINCIPAL_ID(N'usr_poli_gerencia') IS NULL
    CREATE USER [usr_poli_gerencia] FOR LOGIN [login_poli_gerencia] WITH DEFAULT_SCHEMA = [dbo];
GO

-- Administrador de esta base: puede administrar objetos y permisos de la DB.
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = N'db_owner' AND u.name = N'usr_poli_admin'
)
    ALTER ROLE [db_owner] ADD MEMBER [usr_poli_admin];
GO

-- Asociacion de usuarios operativos a sus roles.
IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = N'rol_recepcion' AND u.name = N'usr_poli_recepcion'
)
    ALTER ROLE [rol_recepcion] ADD MEMBER [usr_poli_recepcion];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = N'rol_profesor' AND u.name = N'usr_poli_profesor'
)
    ALTER ROLE [rol_profesor] ADD MEMBER [usr_poli_profesor];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = N'rol_mantenimiento' AND u.name = N'usr_poli_mantenimiento'
)
    ALTER ROLE [rol_mantenimiento] ADD MEMBER [usr_poli_mantenimiento];
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = N'rol_gerencia' AND u.name = N'usr_poli_gerencia'
)
    ALTER ROLE [rol_gerencia] ADD MEMBER [usr_poli_gerencia];
GO

/* ============================================================
   3. PERMISOS: RECEPCION
   Gestiona socios, membresias, reservas, pagos y accesos.
   No puede borrar registros ni administrar la estructura.
   ============================================================ */
GRANT SELECT, INSERT, UPDATE ON dbo.SOCIO TO [rol_recepcion];
GRANT SELECT ON dbo.PLAN_MEMBRESIA TO [rol_recepcion];
GRANT SELECT, INSERT, UPDATE ON dbo.MEMBRESIA TO [rol_recepcion];
GRANT SELECT ON dbo.ACTIVIDAD TO [rol_recepcion];
GRANT SELECT ON dbo.INSTALACION TO [rol_recepcion];
GRANT SELECT ON dbo.COMISION TO [rol_recepcion];
GRANT SELECT ON dbo.ENTRENADOR TO [rol_recepcion];
GRANT SELECT (id_personal, nombre, apellido) ON dbo.PERSONAL TO [rol_recepcion];
GRANT SELECT, INSERT ON dbo.PAGO TO [rol_recepcion];
GRANT SELECT, INSERT ON dbo.PAGO_MEMBRESIA TO [rol_recepcion];
GRANT SELECT, INSERT, UPDATE ON dbo.RESERVA TO [rol_recepcion];
GRANT SELECT, INSERT ON dbo.ACCESO TO [rol_recepcion];
GO

/* ============================================================
   4. PERMISOS: PROFESOR
   Consulta sus referencias operativas y registra asistencias.
   Solo puede ver datos basicos de los socios.
   ============================================================ */
GRANT SELECT ON dbo.ACTIVIDAD TO [rol_profesor];
GRANT SELECT ON dbo.COMISION TO [rol_profesor];
GRANT SELECT ON dbo.INSCRIPCION TO [rol_profesor];
GRANT SELECT (id_socio, nombre, apellido, estado) ON dbo.SOCIO TO [rol_profesor];
GRANT SELECT, INSERT, UPDATE ON dbo.ASISTENCIA TO [rol_profesor];
GO

/* ============================================================
   5. PERMISOS: MANTENIMIENTO
   Consulta instalaciones y personal; registra y actualiza
   ordenes de mantenimiento. El estado de la instalacion se
   actualiza mediante el trigger correspondiente.
   ============================================================ */
GRANT SELECT ON dbo.INSTALACION TO [rol_mantenimiento];
GRANT SELECT (id_personal, nombre, apellido) ON dbo.PERSONAL TO [rol_mantenimiento];
GRANT SELECT, INSERT, UPDATE ON dbo.MANTENIMIENTO TO [rol_mantenimiento];
GO

/* ============================================================
   6. PERMISOS: GERENCIA
   Consulta informacion para reportes y toma de decisiones.
   No modifica los datos operativos. Se limitan algunos datos
   personales y no se otorga acceso a credenciales.
   ============================================================ */
GRANT SELECT (id_socio, nombre, apellido, fecha_alta, estado) ON dbo.SOCIO TO [rol_gerencia];
GRANT SELECT ON dbo.PLAN_MEMBRESIA TO [rol_gerencia];
GRANT SELECT ON dbo.MEMBRESIA TO [rol_gerencia];
GRANT SELECT ON dbo.ACTIVIDAD TO [rol_gerencia];
GRANT SELECT (id_personal, nombre, apellido, estado) ON dbo.PERSONAL TO [rol_gerencia];
GRANT SELECT ON dbo.ENTRENADOR TO [rol_gerencia];
GRANT SELECT ON dbo.INSTALACION TO [rol_gerencia];
GRANT SELECT ON dbo.COMISION TO [rol_gerencia];
GRANT SELECT ON dbo.INSCRIPCION TO [rol_gerencia];
GRANT SELECT ON dbo.ASISTENCIA TO [rol_gerencia];
GRANT SELECT ON dbo.RESERVA TO [rol_gerencia];
GRANT SELECT (id_pago, id_socio, importe, fecha_pago, concepto, estado) ON dbo.PAGO TO [rol_gerencia];
GRANT SELECT ON dbo.PAGO_MEMBRESIA TO [rol_gerencia];
GRANT SELECT ON dbo.MANTENIMIENTO TO [rol_gerencia];
GRANT SELECT ON dbo.ACCESO TO [rol_gerencia];
GO

/*
   No se otorgan permisos sobre USUARIO_SISTEMA, ROL ni USUARIO_ROL
   a los roles operativos. En particular, no pueden consultar password_hash.
   Tampoco se otorgan permisos DELETE a los roles operativos.
*/

/* ============================================================
   7. CONSULTA DE VERIFICACION DE USUARIOS Y ROLES
   ============================================================ */
SELECT
    dp.name AS usuario_base_datos,
    sp.name AS login_servidor,
    rp.name AS rol_base_datos
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp
    ON dp.sid = sp.sid
LEFT JOIN sys.database_role_members drm
    ON dp.principal_id = drm.member_principal_id
LEFT JOIN sys.database_principals rp
    ON drm.role_principal_id = rp.principal_id
WHERE dp.name IN (
    'usr_poli_admin',
    'usr_poli_recepcion',
    'usr_poli_profesor',
    'usr_poli_mantenimiento',
    'usr_poli_gerencia'
)
ORDER BY dp.name;
GO

PRINT 'Seguridad configurada. Revisar la consulta de usuarios y roles.';
GO