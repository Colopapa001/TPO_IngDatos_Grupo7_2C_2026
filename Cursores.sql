USE DB_Gestion_Polideportivo_G7;
GO
SET NOCOUNT ON;

/* ============================================================
   CURSOR 1: Actualizar membresias vencidas una por una
   Procesa membresias marcadas VIGENTE cuya fecha_fin ya paso.
   ============================================================ */
PRINT 'CURSOR 1 - Membresias vencidas';

DECLARE @idMemVencer INT,
        @idSocioVencer INT,
        @fechaFinVencer DATE;

DECLARE curVencerMembresias CURSOR LOCAL FAST_FORWARD FOR
    SELECT id_membresia, id_socio, fecha_fin
    FROM dbo.MEMBRESIA
    WHERE estado = 'VIGENTE'
      AND fecha_fin < CONVERT(DATE, GETDATE());

OPEN curVencerMembresias;
FETCH NEXT FROM curVencerMembresias
    INTO @idMemVencer, @idSocioVencer, @fechaFinVencer;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.MEMBRESIA
    SET estado = 'VENCIDA'
    WHERE id_membresia = @idMemVencer;

    PRINT CONCAT('Membresia ', @idMemVencer,
                 ' del socio ', @idSocioVencer,
                 ' actualizada a VENCIDA. Fecha fin: ',
                 CONVERT(VARCHAR(10), @fechaFinVencer, 120));

    FETCH NEXT FROM curVencerMembresias
        INTO @idMemVencer, @idSocioVencer, @fechaFinVencer;
END;

CLOSE curVencerMembresias;
DEALLOCATE curVencerMembresias;

/* ============================================================
   CURSOR 2: Revisar ocupacion de las comisiones
   Cuenta inscripciones activas y calcula lugares disponibles.
   ============================================================ */
PRINT 'CURSOR 2 - Ocupacion de comisiones';

DECLARE @idComisionOcup INT,
        @nombreActividadOcup NVARCHAR(100),
        @cupoOcup INT,
        @inscriptosOcup INT,
        @disponiblesOcup INT;

DECLARE curOcupacionComisiones CURSOR LOCAL FAST_FORWARD FOR
    SELECT c.id_comision, a.nombre, c.cupo_maximo
    FROM dbo.COMISION AS c
    INNER JOIN dbo.ACTIVIDAD AS a
        ON a.id_actividad = c.id_actividad
    WHERE c.estado = 'ACTIVA';

OPEN curOcupacionComisiones;
FETCH NEXT FROM curOcupacionComisiones
    INTO @idComisionOcup, @nombreActividadOcup, @cupoOcup;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @inscriptosOcup = COUNT(*)
    FROM dbo.INSCRIPCION
    WHERE id_comision = @idComisionOcup
      AND estado = 'ACTIVA';

    SET @disponiblesOcup = @cupoOcup - @inscriptosOcup;

    IF @disponiblesOcup < 0
        PRINT CONCAT('ALERTA: comision ', @idComisionOcup, ' - ',
                     @nombreActividadOcup, ' supera su cupo. Inscriptos: ',
                     @inscriptosOcup, '; cupo: ', @cupoOcup);
    ELSE
        PRINT CONCAT('Comision ', @idComisionOcup, ' - ',
                     @nombreActividadOcup, ': inscriptos ', @inscriptosOcup,
                     ', lugares disponibles ', @disponiblesOcup, '.');

    FETCH NEXT FROM curOcupacionComisiones
        INTO @idComisionOcup, @nombreActividadOcup, @cupoOcup;
END;

CLOSE curOcupacionComisiones;
DEALLOCATE curOcupacionComisiones;

/* ============================================================
   CURSOR 3: Revisar pagos pendientes o rechazados
   Emite una accion sugerida para cada registro encontrado.
   ============================================================ */
PRINT 'CURSOR 3 - Seguimiento de pagos';

DECLARE @idPagoSeg INT,
        @nombreSocioPago NVARCHAR(161),
        @importePago DECIMAL(12,2),
        @conceptoPago NVARCHAR(150),
        @estadoPagoSeg VARCHAR(15);

DECLARE curSeguimientoPagos CURSOR LOCAL FAST_FORWARD FOR
    SELECT p.id_pago,
           CONCAT(s.nombre, N' ', s.apellido),
           p.importe,
           p.concepto,
           p.estado
    FROM dbo.PAGO AS p
    INNER JOIN dbo.SOCIO AS s
        ON s.id_socio = p.id_socio
    WHERE p.estado IN ('PENDIENTE', 'RECHAZADO')
    ORDER BY p.fecha_pago, p.id_pago;

OPEN curSeguimientoPagos;
FETCH NEXT FROM curSeguimientoPagos
    INTO @idPagoSeg, @nombreSocioPago, @importePago,
         @conceptoPago, @estadoPagoSeg;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @estadoPagoSeg = 'RECHAZADO'
        PRINT CONCAT('Pago ', @idPagoSeg, ' de ', @nombreSocioPago,
                     ': importe $', @importePago,
                     ', concepto ', @conceptoPago,
                     '. Accion: revisar rechazo y solicitar otro medio de pago.');
    ELSE
        PRINT CONCAT('Pago ', @idPagoSeg, ' de ', @nombreSocioPago,
                     ': importe $', @importePago,
                     ', concepto ', @conceptoPago,
                     '. Accion: verificar si se acredito.');

    FETCH NEXT FROM curSeguimientoPagos
        INTO @idPagoSeg, @nombreSocioPago, @importePago,
             @conceptoPago, @estadoPagoSeg;
END;

CLOSE curSeguimientoPagos;
DEALLOCATE curSeguimientoPagos;

/* ============================================================
   CURSOR 4: Recorrer reservas pendientes o confirmadas
   Presenta el detalle operativo de cada reserva no cancelada.
   ============================================================ */
PRINT 'CURSOR 4 - Reservas registradas';

DECLARE @idReservaCur INT,
        @socioReserva NVARCHAR(161),
        @instalacionReserva NVARCHAR(100),
        @fechaReserva DATE,
        @horaInicioReserva TIME(0),
        @horaFinReserva TIME(0),
        @estadoReserva VARCHAR(15);

DECLARE curReservas CURSOR LOCAL FAST_FORWARD FOR
    SELECT r.id_reserva,
           CONCAT(s.nombre, N' ', s.apellido),
           i.nombre,
           r.fecha,
           r.hora_inicio,
           r.hora_fin,
           r.estado
    FROM dbo.RESERVA AS r
    INNER JOIN dbo.SOCIO AS s
        ON s.id_socio = r.id_socio
    INNER JOIN dbo.INSTALACION AS i
        ON i.id_instalacion = r.id_instalacion
    WHERE r.estado IN ('PENDIENTE', 'CONFIRMADA')
    ORDER BY r.fecha, r.hora_inicio;

OPEN curReservas;
FETCH NEXT FROM curReservas
    INTO @idReservaCur, @socioReserva, @instalacionReserva,
         @fechaReserva, @horaInicioReserva, @horaFinReserva, @estadoReserva;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('Reserva ', @idReservaCur, ': ', @socioReserva,
                 ', instalacion ', @instalacionReserva,
                 ', fecha ', CONVERT(VARCHAR(10), @fechaReserva, 120),
                 ', horario ', CONVERT(VARCHAR(5), @horaInicioReserva),
                 '-', CONVERT(VARCHAR(5), @horaFinReserva),
                 ', estado ', @estadoReserva, '.');

    FETCH NEXT FROM curReservas
        INTO @idReservaCur, @socioReserva, @instalacionReserva,
             @fechaReserva, @horaInicioReserva, @horaFinReserva, @estadoReserva;
END;

CLOSE curReservas;
DEALLOCATE curReservas;

/* ============================================================
   CURSOR 5: Controlar mantenimientos abiertos y vencidos
   Compara la fecha estimada de finalizacion con la fecha actual.
   ============================================================ */
PRINT 'CURSOR 5 - Seguimiento de mantenimiento';

DECLARE @idMantenimientoCur INT,
        @nombreInstalacionMant NVARCHAR(100),
        @fechaEstimadaMant DATE,
        @estadoMantCur VARCHAR(15),
        @descripcionMant NVARCHAR(300);

DECLARE curMantenimientos CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.id_mantenimiento, i.nombre, m.fecha_fin_estimada,
           m.estado, m.descripcion
    FROM dbo.MANTENIMIENTO AS m
    INNER JOIN dbo.INSTALACION AS i
        ON i.id_instalacion = m.id_instalacion
    WHERE m.estado IN ('PENDIENTE', 'EN_PROCESO')
    ORDER BY m.fecha_inicio;

OPEN curMantenimientos;
FETCH NEXT FROM curMantenimientos
    INTO @idMantenimientoCur, @nombreInstalacionMant,
         @fechaEstimadaMant, @estadoMantCur, @descripcionMant;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @fechaEstimadaMant IS NOT NULL
       AND @fechaEstimadaMant < CONVERT(DATE, GETDATE())
        PRINT CONCAT('ALERTA: mantenimiento ', @idMantenimientoCur,
                     ' de ', @nombreInstalacionMant,
                     ' esta atrasado. Descripcion: ', @descripcionMant);
    ELSE
        PRINT CONCAT('Mantenimiento ', @idMantenimientoCur,
                     ' de ', @nombreInstalacionMant,
                     ', estado ', @estadoMantCur,
                     ', fecha estimada ',
                     COALESCE(CONVERT(VARCHAR(10), @fechaEstimadaMant, 120), 'sin definir'), '.');

    FETCH NEXT FROM curMantenimientos
        INTO @idMantenimientoCur, @nombreInstalacionMant,
             @fechaEstimadaMant, @estadoMantCur, @descripcionMant;
END;

CLOSE curMantenimientos;
DEALLOCATE curMantenimientos;

/* ============================================================
   CURSOR 6: Generar resumen de asistencia por comision
   Para cada comision cuenta presentes, ausentes y justificadas.
   ============================================================ */
PRINT 'CURSOR 6 - Resumen de asistencias';

DECLARE @idComisionAsis INT,
        @actividadAsis NVARCHAR(100),
        @presentesAsis INT,
        @ausentesAsis INT,
        @justificadasAsis INT;

DECLARE curResumenAsistencia CURSOR LOCAL FAST_FORWARD FOR
    SELECT c.id_comision, a.nombre
    FROM dbo.COMISION AS c
    INNER JOIN dbo.ACTIVIDAD AS a
        ON a.id_actividad = c.id_actividad
    ORDER BY c.id_comision;

OPEN curResumenAsistencia;
FETCH NEXT FROM curResumenAsistencia
    INTO @idComisionAsis, @actividadAsis;

WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT
        @presentesAsis = COALESCE(SUM(CASE WHEN a.estado = 'PRESENTE' THEN 1 ELSE 0 END), 0),
        @ausentesAsis = COALESCE(SUM(CASE WHEN a.estado = 'AUSENTE' THEN 1 ELSE 0 END), 0),
        @justificadasAsis = COALESCE(SUM(CASE WHEN a.estado = 'JUSTIFICADA' THEN 1 ELSE 0 END), 0)
    FROM dbo.INSCRIPCION AS ins
    LEFT JOIN dbo.ASISTENCIA AS a
        ON a.id_inscripcion = ins.id_inscripcion
    WHERE ins.id_comision = @idComisionAsis;

    PRINT CONCAT('Comision ', @idComisionAsis, ' - ', @actividadAsis,
                 ': presentes ', @presentesAsis,
                 ', ausentes ', @ausentesAsis,
                 ', justificadas ', @justificadasAsis, '.');

    FETCH NEXT FROM curResumenAsistencia
        INTO @idComisionAsis, @actividadAsis;
END;

CLOSE curResumenAsistencia;
DEALLOCATE curResumenAsistencia;

/* ============================================================
   CURSOR 7: Detectar accesos que siguen abiertos
   Lista socios con ingreso registrado y sin egreso.
   ============================================================ */
PRINT 'CURSOR 7 - Accesos sin egreso';

DECLARE @idAccesoCur INT,
        @nombreSocioAcceso NVARCHAR(161),
        @ingresoAcceso DATETIME2(0);

DECLARE curAccesosAbiertos CURSOR LOCAL FAST_FORWARD FOR
    SELECT ac.id_acceso,
           CONCAT(s.nombre, N' ', s.apellido),
           ac.fecha_hora_ingreso
    FROM dbo.ACCESO AS ac
    INNER JOIN dbo.SOCIO AS s
        ON s.id_socio = ac.id_socio
    WHERE ac.fecha_hora_egreso IS NULL
    ORDER BY ac.fecha_hora_ingreso;

OPEN curAccesosAbiertos;
FETCH NEXT FROM curAccesosAbiertos
    INTO @idAccesoCur, @nombreSocioAcceso, @ingresoAcceso;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('Acceso ', @idAccesoCur, ': ', @nombreSocioAcceso,
                 ' ingreso ', CONVERT(VARCHAR(19), @ingresoAcceso, 120),
                 ' sin egreso registrado. Verificar estado.');

    FETCH NEXT FROM curAccesosAbiertos
        INTO @idAccesoCur, @nombreSocioAcceso, @ingresoAcceso;
END;

CLOSE curAccesosAbiertos;
DEALLOCATE curAccesosAbiertos;

/* ============================================================
   CURSOR 8: Avisos de membresias que vencen en los proximos 7 dias
   Procesa cada membresia vigente y genera un mensaje individual.
   ============================================================ */
PRINT 'CURSOR 8 - Avisos de vencimiento de membresias';

DECLARE @idMemAviso INT,
        @idSocioAviso INT,
        @nombreSocioAviso NVARCHAR(161),
        @fechaFinAviso DATE,
        @diasRestantes INT;

DECLARE curAvisoVencimientos CURSOR LOCAL FAST_FORWARD FOR
    SELECT m.id_membresia, m.id_socio,
           CONCAT(s.nombre, N' ', s.apellido), m.fecha_fin
    FROM dbo.MEMBRESIA AS m
    INNER JOIN dbo.SOCIO AS s
        ON s.id_socio = m.id_socio
    WHERE m.estado = 'VIGENTE'
      AND m.fecha_fin >= CONVERT(DATE, GETDATE())
      AND m.fecha_fin <= DATEADD(DAY, 7, CONVERT(DATE, GETDATE()))
    ORDER BY m.fecha_fin;

OPEN curAvisoVencimientos;
FETCH NEXT FROM curAvisoVencimientos
    INTO @idMemAviso, @idSocioAviso, @nombreSocioAviso, @fechaFinAviso;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @diasRestantes = DATEDIFF(DAY, CONVERT(DATE, GETDATE()), @fechaFinAviso);

    PRINT CONCAT('Aviso para ', @nombreSocioAviso,
                 ' (socio ', @idSocioAviso, '): membresia ', @idMemAviso,
                 ' vence el ', CONVERT(VARCHAR(10), @fechaFinAviso, 120),
                 '. Dias restantes: ', @diasRestantes, '.');

    FETCH NEXT FROM curAvisoVencimientos
        INTO @idMemAviso, @idSocioAviso, @nombreSocioAviso, @fechaFinAviso;
END;

CLOSE curAvisoVencimientos;
DEALLOCATE curAvisoVencimientos;

PRINT 'Fin de los 8 ejemplos de cursores.';
GO
 