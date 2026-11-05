Create Database DB_Gestion_Polideportivo_G7
GO
USE DB_Gestion_Polideportivo_G7
GO
-- =========================================
-- 1. SOCIOS
-- =========================================

CREATE TABLE SOCIO (
    id_socio INT IDENTITY(1,1) NOT NULL,
    dni VARCHAR(10) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    apellido NVARCHAR(80) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    email VARCHAR(254) NOT NULL,
    direccion NVARCHAR(200) NOT NULL,
    fecha_alta DATE NOT NULL
        CONSTRAINT DF_SOCIO_FECHA_ALTA
        DEFAULT (CONVERT(DATE, GETDATE())),
    estado VARCHAR(15) NOT NULL
        CONSTRAINT DF_SOCIO_ESTADO DEFAULT ('ACTIVO'),

    CONSTRAINT PK_SOCIO PRIMARY KEY (id_socio),
    CONSTRAINT UQ_SOCIO_DNI UNIQUE (dni),
    CONSTRAINT CK_SOCIO_DNI
        CHECK (LEN(LTRIM(RTRIM(dni))) > 0),
    CONSTRAINT CK_SOCIO_EMAIL
        CHECK (email LIKE '_%@_%._%'),
    CONSTRAINT CK_SOCIO_ESTADO
        CHECK (estado IN ('ACTIVO', 'SUSPENDIDO', 'BAJA'))
);

-- =========================================
-- 2. PLANES DE MEMBRESIA
-- =========================================

CREATE TABLE PLAN_MEMBRESIA (
    id_plan INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    descripcion NVARCHAR(250) NULL,
    precio_actual DECIMAL(12,2) NOT NULL,
    duracion_meses SMALLINT NOT NULL,
    estado VARCHAR(10) NOT NULL
        CONSTRAINT DF_PLAN_ESTADO DEFAULT ('ACTIVO'),

    CONSTRAINT PK_PLAN_MEMBRESIA PRIMARY KEY (id_plan),
    CONSTRAINT UQ_PLAN_NOMBRE UNIQUE (nombre),
    CONSTRAINT CK_PLAN_PRECIO CHECK (precio_actual > 0),
    CONSTRAINT CK_PLAN_DURACION CHECK (duracion_meses > 0),
    CONSTRAINT CK_PLAN_ESTADO
        CHECK (estado IN ('ACTIVO', 'INACTIVO'))
);

-- =========================================
-- 3. MEMBRESIAS
-- =========================================

CREATE TABLE MEMBRESIA (
    id_membresia INT IDENTITY(1,1) NOT NULL,
    id_socio INT NOT NULL,
    id_plan INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    precio_contratado DECIMAL(12,2) NOT NULL,
    estado VARCHAR(15) NOT NULL,

    CONSTRAINT PK_MEMBRESIA PRIMARY KEY (id_membresia),

    CONSTRAINT FK_MEMBRESIA_SOCIO
        FOREIGN KEY (id_socio)
        REFERENCES SOCIO(id_socio),

    CONSTRAINT FK_MEMBRESIA_PLAN
        FOREIGN KEY (id_plan)
        REFERENCES PLAN_MEMBRESIA(id_plan),

    CONSTRAINT CK_MEMBRESIA_FECHAS
        CHECK (fecha_fin >= fecha_inicio),

    CONSTRAINT CK_MEMBRESIA_PRECIO
        CHECK (precio_contratado > 0),

    CONSTRAINT CK_MEMBRESIA_ESTADO
        CHECK (estado IN (
            'VIGENTE', 'VENCIDA',
            'SUSPENDIDA', 'CANCELADA'
        ))
);

-- =========================================
-- 4. ACTIVIDADES
-- =========================================

CREATE TABLE ACTIVIDAD (
    id_actividad INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(250) NULL,
    estado VARCHAR(10) NOT NULL
        CONSTRAINT DF_ACTIVIDAD_ESTADO DEFAULT ('ACTIVA'),

    CONSTRAINT PK_ACTIVIDAD PRIMARY KEY (id_actividad),
    CONSTRAINT UQ_ACTIVIDAD_NOMBRE UNIQUE (nombre),
    CONSTRAINT CK_ACTIVIDAD_ESTADO
        CHECK (estado IN ('ACTIVA', 'INACTIVA'))
);

-- =========================================
-- 5. PERSONAL
-- =========================================

CREATE TABLE PERSONAL (
    id_personal INT IDENTITY(1,1) NOT NULL,
    dni VARCHAR(20) NOT NULL,
    nombre NVARCHAR(80) NOT NULL,
    apellido NVARCHAR(80) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    email VARCHAR(254) NOT NULL,
    estado VARCHAR(10) NOT NULL
        CONSTRAINT DF_PERSONAL_ESTADO DEFAULT ('ACTIVO'),

    CONSTRAINT PK_PERSONAL PRIMARY KEY (id_personal),
    CONSTRAINT UQ_PERSONAL_DNI UNIQUE (dni),
    CONSTRAINT CK_PERSONAL_EMAIL
        CHECK (email LIKE '_%@_%._%'),
    CONSTRAINT CK_PERSONAL_ESTADO
        CHECK (estado IN ('ACTIVO', 'BAJA'))
);

-- =========================================
-- 6. ENTRENADORES
-- El identificador también es FK a PERSONAL.
-- =========================================

CREATE TABLE ENTRENADOR (
    id_personal INT NOT NULL,
    especialidad NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_ENTRENADOR PRIMARY KEY (id_personal),

    CONSTRAINT FK_ENTRENADOR_PERSONAL
        FOREIGN KEY (id_personal)
        REFERENCES PERSONAL(id_personal)
);

-- =========================================
-- 7. INSTALACIONES
-- =========================================

CREATE TABLE INSTALACION (
    id_instalacion INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    tipo_instalacion VARCHAR(20) NOT NULL,
    ubicacion NVARCHAR(150) NULL,
    capacidad INT NOT NULL,
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_INSTALACION_ESTADO
        DEFAULT ('OPERATIVA'),

    CONSTRAINT PK_INSTALACION PRIMARY KEY (id_instalacion),

    CONSTRAINT CK_INSTALACION_TIPO
        CHECK (tipo_instalacion IN (
            'CANCHA', 'PISCINA',
            'GIMNASIO', 'SALON', 'OTRA'
        )),

    CONSTRAINT CK_INSTALACION_CAPACIDAD
        CHECK (capacidad > 0),

    CONSTRAINT CK_INSTALACION_ESTADO
        CHECK (estado IN (
            'OPERATIVA',
            'EN_MANTENIMIENTO',
            'FUERA_SERVICIO'
        ))
);

-- =========================================
-- 8. COMISIONES / HORARIOS
-- =========================================

CREATE TABLE COMISION (
    id_comision INT IDENTITY(1,1) NOT NULL,
    id_actividad INT NOT NULL,
    id_personal INT NOT NULL,
    id_instalacion INT NOT NULL,
    dia_semana VARCHAR(10) NOT NULL,
    hora_inicio TIME(0) NOT NULL,
    hora_fin TIME(0) NOT NULL,
    cupo_maximo INT NOT NULL,
    estado VARCHAR(10) NOT NULL
        CONSTRAINT DF_COMISION_ESTADO DEFAULT ('ACTIVA'),

    CONSTRAINT PK_COMISION PRIMARY KEY (id_comision),

    CONSTRAINT FK_COMISION_ACTIVIDAD
        FOREIGN KEY (id_actividad)
        REFERENCES ACTIVIDAD(id_actividad),

    CONSTRAINT FK_COMISION_ENTRENADOR
        FOREIGN KEY (id_personal)
        REFERENCES ENTRENADOR(id_personal),

    CONSTRAINT FK_COMISION_INSTALACION
        FOREIGN KEY (id_instalacion)
        REFERENCES INSTALACION(id_instalacion),

    CONSTRAINT CK_COMISION_DIA
        CHECK (dia_semana IN (
            'LUNES', 'MARTES', 'MIERCOLES',
            'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'
        )),

    CONSTRAINT CK_COMISION_HORARIO
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT CK_COMISION_CUPO
        CHECK (cupo_maximo > 0),

    CONSTRAINT CK_COMISION_ESTADO
        CHECK (estado IN ('ACTIVA', 'INACTIVA', 'CANCELADA'))
);

-- =========================================
-- 9. INSCRIPCIONES
-- Conserva el historial de bajas.
-- =========================================

CREATE TABLE INSCRIPCION (
    id_inscripcion INT IDENTITY(1,1) NOT NULL,
    id_socio INT NOT NULL,
    id_comision INT NOT NULL,
    fecha_inscripcion DATE NOT NULL
        CONSTRAINT DF_INSCRIPCION_FECHA
        DEFAULT (CONVERT(DATE, GETDATE())),
    fecha_baja DATE NULL,
    estado VARCHAR(10) NOT NULL
        CONSTRAINT DF_INSCRIPCION_ESTADO DEFAULT ('ACTIVA'),

    CONSTRAINT PK_INSCRIPCION PRIMARY KEY (id_inscripcion),

    CONSTRAINT FK_INSCRIPCION_SOCIO
        FOREIGN KEY (id_socio)
        REFERENCES SOCIO(id_socio),

    CONSTRAINT FK_INSCRIPCION_COMISION
        FOREIGN KEY (id_comision)
        REFERENCES COMISION(id_comision),

    CONSTRAINT CK_INSCRIPCION_ESTADO
        CHECK (
            (estado = 'ACTIVA' AND fecha_baja IS NULL)
            OR
            (estado = 'BAJA' AND fecha_baja IS NOT NULL)
        ),

    CONSTRAINT CK_INSCRIPCION_FECHAS
        CHECK (
            fecha_baja IS NULL
            OR fecha_baja >= fecha_inscripcion
        )
);

-- Impide duplicar inscripciones activas,
-- pero permite conservar inscripciones anteriores dadas de baja.

CREATE UNIQUE INDEX UX_INSCRIPCION_ACTIVA
ON INSCRIPCION (id_socio, id_comision)
WHERE estado = 'ACTIVA';

-- =========================================
-- 10. ASISTENCIAS
-- Una inscripción puede tener una asistencia
-- por fecha de clase.
-- =========================================

CREATE TABLE ASISTENCIA (
    id_inscripcion INT NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR(15) NOT NULL,

    CONSTRAINT PK_ASISTENCIA
        PRIMARY KEY (id_inscripcion, fecha),

    CONSTRAINT FK_ASISTENCIA_INSCRIPCION
        FOREIGN KEY (id_inscripcion)
        REFERENCES INSCRIPCION(id_inscripcion),

    CONSTRAINT CK_ASISTENCIA_ESTADO
        CHECK (estado IN (
            'PRESENTE', 'AUSENTE', 'JUSTIFICADA'
        ))
);

-- =========================================
-- 11. RESERVAS
-- =========================================

CREATE TABLE RESERVA (
    id_reserva INT IDENTITY(1,1) NOT NULL,
    id_socio INT NOT NULL,
    id_instalacion INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME(0) NOT NULL,
    hora_fin TIME(0) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_RESERVA_CREACION DEFAULT (SYSDATETIME()),
    estado VARCHAR(15) NOT NULL
        CONSTRAINT DF_RESERVA_ESTADO DEFAULT ('PENDIENTE'),

    CONSTRAINT PK_RESERVA PRIMARY KEY (id_reserva),

    CONSTRAINT FK_RESERVA_SOCIO
        FOREIGN KEY (id_socio)
        REFERENCES SOCIO(id_socio),

    CONSTRAINT FK_RESERVA_INSTALACION
        FOREIGN KEY (id_instalacion)
        REFERENCES INSTALACION(id_instalacion),

    CONSTRAINT CK_RESERVA_HORARIO
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT CK_RESERVA_ESTADO
        CHECK (estado IN (
            'PENDIENTE', 'CONFIRMADA',
            'CANCELADA', 'FINALIZADA'
        ))
);

-- =========================================
-- 12. PAGOS
-- =========================================

CREATE TABLE PAGO (
    id_pago INT IDENTITY(1,1) NOT NULL,
    id_socio INT NOT NULL,
    importe DECIMAL(12,2) NOT NULL,
    fecha_pago DATETIME2(0) NOT NULL
        CONSTRAINT DF_PAGO_FECHA DEFAULT (SYSDATETIME()),
    concepto NVARCHAR(150) NOT NULL,
    medio_pago VARCHAR(25) NOT NULL,
    estado VARCHAR(15) NOT NULL
        CONSTRAINT DF_PAGO_ESTADO DEFAULT ('PENDIENTE'),

    CONSTRAINT PK_PAGO PRIMARY KEY (id_pago),

    CONSTRAINT FK_PAGO_SOCIO
        FOREIGN KEY (id_socio)
        REFERENCES SOCIO(id_socio),

    CONSTRAINT CK_PAGO_IMPORTE
        CHECK (importe > 0),

    CONSTRAINT CK_PAGO_MEDIO
        CHECK (medio_pago IN (
            'EFECTIVO', 'TRANSFERENCIA',
            'TARJETA_DEBITO', 'TARJETA_CREDITO',
            'MERCADO_PAGO', 'OTRO'
        )),

    CONSTRAINT CK_PAGO_ESTADO
        CHECK (estado IN (
            'PENDIENTE', 'APROBADO',
            'RECHAZADO', 'ANULADO'
        ))
);

-- =========================================
-- 13. PAGOS APLICADOS A MEMBRESIAS
-- Es una relación opcional entre PAGO y MEMBRESIA.
-- Los demás pagos no requieren este registro.
-- =========================================

CREATE TABLE PAGO_MEMBRESIA (
    id_pago INT NOT NULL,
    id_membresia INT NOT NULL,

    CONSTRAINT PK_PAGO_MEMBRESIA PRIMARY KEY (id_pago),

    CONSTRAINT FK_PAGO_MEMBRESIA_PAGO
        FOREIGN KEY (id_pago)
        REFERENCES PAGO(id_pago),

    CONSTRAINT FK_PAGO_MEMBRESIA_MEMBRESIA
        FOREIGN KEY (id_membresia)
        REFERENCES MEMBRESIA(id_membresia)
);

-- =========================================
-- 14. MANTENIMIENTOS
-- =========================================

CREATE TABLE MANTENIMIENTO (
    id_mantenimiento INT IDENTITY(1,1) NOT NULL,
    id_instalacion INT NOT NULL,
    id_responsable INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    descripcion NVARCHAR(300) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin_estimada DATE NULL,
    fecha_fin_real DATE NULL,
    estado VARCHAR(15) NOT NULL
        CONSTRAINT DF_MANTENIMIENTO_ESTADO
        DEFAULT ('PENDIENTE'),

    CONSTRAINT PK_MANTENIMIENTO
        PRIMARY KEY (id_mantenimiento),

    CONSTRAINT FK_MANTENIMIENTO_INSTALACION
        FOREIGN KEY (id_instalacion)
        REFERENCES INSTALACION(id_instalacion),

    CONSTRAINT FK_MANTENIMIENTO_PERSONAL
        FOREIGN KEY (id_responsable)
        REFERENCES PERSONAL(id_personal),

    CONSTRAINT CK_MANTENIMIENTO_TIPO
        CHECK (tipo IN (
            'PREVENTIVO', 'CORRECTIVO', 'OTRO'
        )),

    CONSTRAINT CK_MANTENIMIENTO_FECHAS
        CHECK (
            (fecha_fin_estimada IS NULL
                OR fecha_fin_estimada >= fecha_inicio)
            AND
            (fecha_fin_real IS NULL
                OR fecha_fin_real >= fecha_inicio)
        ),

    CONSTRAINT CK_MANTENIMIENTO_ESTADO
        CHECK (estado IN (
            'PENDIENTE', 'EN_PROCESO',
            'FINALIZADO', 'CANCELADO'
        )),

    CONSTRAINT CK_MANTENIMIENTO_FINALIZADO
        CHECK (
            estado <> 'FINALIZADO'
            OR fecha_fin_real IS NOT NULL
        )
);

-- =========================================
-- 15. ACCESOS
-- =========================================

CREATE TABLE ACCESO (
    id_acceso INT IDENTITY(1,1) NOT NULL,
    id_socio INT NOT NULL,
    fecha_hora_ingreso DATETIME2(0) NOT NULL
        CONSTRAINT DF_ACCESO_INGRESO DEFAULT (SYSDATETIME()),
    fecha_hora_egreso DATETIME2(0) NULL,

    CONSTRAINT PK_ACCESO PRIMARY KEY (id_acceso),

    CONSTRAINT FK_ACCESO_SOCIO
        FOREIGN KEY (id_socio)
        REFERENCES SOCIO(id_socio),

    CONSTRAINT CK_ACCESO_HORAS
        CHECK (
            fecha_hora_egreso IS NULL
            OR fecha_hora_egreso >= fecha_hora_ingreso
        )
);

-- =========================================
-- 16. USUARIOS DEL SISTEMA
-- Se almacena el hash de la contraseña, nunca
-- la contraseña en texto plano.
-- =========================================

CREATE TABLE USUARIO_SISTEMA (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    id_personal INT NOT NULL,
    nombre_usuario VARCHAR(60) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_USUARIO_CREACION DEFAULT (SYSDATETIME()),
    estado VARCHAR(12) NOT NULL
        CONSTRAINT DF_USUARIO_ESTADO DEFAULT ('ACTIVO'),

    CONSTRAINT PK_USUARIO_SISTEMA PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_USUARIO_NOMBRE UNIQUE (nombre_usuario),
    CONSTRAINT UQ_USUARIO_PERSONAL UNIQUE (id_personal),

    CONSTRAINT FK_USUARIO_PERSONAL
        FOREIGN KEY (id_personal)
        REFERENCES PERSONAL(id_personal),

    CONSTRAINT CK_USUARIO_ESTADO
        CHECK (estado IN ('ACTIVO', 'BLOQUEADO'))
);

-- =========================================
-- 17. ROLES
-- =========================================

CREATE TABLE ROL (
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(40) NOT NULL,
    descripcion NVARCHAR(150) NULL,

    CONSTRAINT PK_ROL PRIMARY KEY (id_rol),
    CONSTRAINT UQ_ROL_NOMBRE UNIQUE (nombre)
);

-- =========================================
-- 18. ASIGNACION DE ROLES
-- =========================================

CREATE TABLE USUARIO_ROL (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_USUARIO_ROL_FECHA
        DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_USUARIO_ROL
        PRIMARY KEY (id_usuario, id_rol),

    CONSTRAINT FK_USUARIO_ROL_USUARIO
        FOREIGN KEY (id_usuario)
        REFERENCES USUARIO_SISTEMA(id_usuario),

    CONSTRAINT FK_USUARIO_ROL_ROL
        FOREIGN KEY (id_rol)
        REFERENCES ROL(id_rol)
);

-- =========================================
-- 19. HISTORIAL DE ASISTENCIAS A COMISIONES
-- =========================================

CREATE TABLE HISTORIAL_INSCRIPCION (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    id_socio INT NOT NULL,
    id_comision INT NOT NULL,
    fecha_inscripcion DATE,
    fecha_baja DATE,
    estado VARCHAR(20),
    accion_realizada VARCHAR(10), -- 'INSERT' o 'UPDATE'
    fecha_modificacion DATETIME DEFAULT GETDATE(),
    usuario_bd SYSNAME DEFAULT SYSTEM_USER
);



