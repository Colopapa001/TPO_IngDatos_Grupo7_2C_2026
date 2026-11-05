USE DB_Gestion_Polideportivo_G7;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE SOCIOS
------------------------------------------------------

-- ====================================================
-- Description: SP-01 Registrar nuevo socio en el club.
-- ====================================================
CREATE PROCEDURE sp_RegistrarNuevoSocio
    @nombre NVARCHAR(80),
	@apellido NVARCHAR(80),
	@dni VARCHAR(10),
	@fecha_nac DATE,
	@telefono VARCHAR(30),
	@email VARCHAR(254),
	@direccion NVARCHAR(200)
	
AS
BEGIN
    SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el DNI del socio no este registrado.
		IF EXISTS(
			SELECT 1 
			FROM SOCIO
			WHERE dni=@dni)
        BEGIN
            RAISERROR('El DNI ingresado ya se encuentra registrado.', 16, 1);
        END


		INSERT INTO SOCIO (dni, nombre, apellido, fecha_nacimiento, telefono, email, direccion, fecha_alta, estado)
		VALUES
		(@dni, @nombre, @apellido, @fecha_nac, @telefono, @email, @direccion, CAST(GETDATE() AS DATE), 'ACTIVO')


        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;
		PRINT 'Se registró el nuevo socio de manera correcta.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

-- ===================================================
-- Description: SP-02 Dar de baja un socio en el club.
-- ===================================================
CREATE PROCEDURE sp_BajaSocio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el socio exista en la base de datos.
        IF NOT EXISTS (
            SELECT 1 
            FROM SOCIO 
            WHERE id_socio = @id_socio
        )
        BEGIN
            RAISERROR('El socio indicado no se encuentra registrado.', 16, 1);
        END

        -- Realizar la baja lógica actualizando el estado del socio
        UPDATE SOCIO 
        SET estado = 'BAJA'
        WHERE id_socio = @id_socio;

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;
        PRINT 'Socio dado de baja exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO


-- ===============================================================
-- Description: SP-03 Modificar de forma parcial 
-- los datos de un socio existente (no permite modificar el DNI).
-- ===============================================================
CREATE PROCEDURE sp_ModificarSocio
    @id_socio INT,
    @nombre VARCHAR(20) = NULL,
    @apellido VARCHAR(20) = NULL,
    @fecha_nac DATE = NULL,
    @telefono INT = NULL,
    @email VARCHAR(50) = NULL,
    @direccion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el socio a modificar exista en la base de datos.
        IF NOT EXISTS (
            SELECT 1 
            FROM SOCIO 
            WHERE id_socio = @id_socio
        )
        BEGIN
            RAISERROR('El socio que intenta modificar no se encuentra registrado.', 16, 1);
        END

        -- Actualizar solo los campos provistos (si el parámetro es NULL, mantiene el valor actual)
        UPDATE SOCIO 
        SET nombre = ISNULL(@nombre, nombre),
            apellido = ISNULL(@apellido, apellido),
            fecha_nacimiento = ISNULL(@fecha_nac, fecha_nacimiento),
            telefono = ISNULL(@telefono, telefono),
            email = ISNULL(@email, email),
            direccion = ISNULL(@direccion, direccion)
        WHERE id_socio = @id_socio;

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;
        PRINT 'Datos del socio actualizados exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO


----------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE COMISIONES
-- (INSCRPCIONES, BAJAS Y ASISTENCIAS)
----------------------------------------------------------

-- =============================================================================================
-- Description: SP-04 Registrar socio en una comisión, verifica que la membresía sea válida, 
-- que la comisión exista y tenga cupos. Si el usuario ya tenía una inscrpción previa la activa, 
-- si no existía se crea.
-- =============================================================================================
CREATE PROCEDURE sp_RegistrarInscripcionComision
    @socio INT,
    @comision INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar socio y membresía vigente usando la función fn_SocioHabilitado
        IF dbo.fn_SocioHabilitado(@socio, GETDATE()) = 0
        BEGIN
            RAISERROR('El socio no existe, no se encuentra activo o no posee una membresía vigente.', 16, 1);
        END

		--  Validar existencia, estado y cupos usando la función fn_CuposDisponibles
        DECLARE @cupos_disponibles INT;
        SET @cupos_disponibles = dbo.fn_CuposDisponibles(@comision);

        -- Si la función retorna NULL, la comisión no existe.
        IF @cupos_disponibles IS NULL
        BEGIN
            RAISERROR('La comisión seleccionada no existe.', 16, 1);
        END

        -- Si retorna 0 o menos, no está activa o no hay cupo.
        IF @cupos_disponibles <= 0
        BEGIN
            RAISERROR('La comisión no está activa o no hay cupos disponibles.', 16, 1);
        END

        -- Controlar que el socio no esté inscripto previamente en esa misma comisión (RN05)
        IF EXISTS (
            SELECT 1 
            FROM INSCRIPCION 
            WHERE id_socio = @socio 
              AND id_comision = @comision 
              AND estado = 'ACTIVA'
        )
        BEGIN
            RAISERROR('El socio ya se encuentra inscripto en esta comisión.', 16, 1);
        END

        -- Verificar si existe una inscripción previa pero inactiva (para reactivarla).
        IF EXISTS (
            SELECT 1 
            FROM INSCRIPCION 
            WHERE id_socio = @socio 
              AND id_comision = @comision 
              AND estado = 'BAJA'
        )
        BEGIN
            -- Modificamos el estado a ACTIVO
            UPDATE INSCRIPCION 
            SET estado = 'ACTIVA',
                fecha_inscripcion = CAST(GETDATE() AS DATE),
                fecha_baja = NULL
            WHERE id_socio = @socio 
              AND id_comision = @comision;

            PRINT 'Inscripción reactivada exitosamente.';
        END
        ELSE
        BEGIN
            -- Si no existía ningún registro previo, insertamos uno nuevo
            INSERT INTO INSCRIPCION (id_socio, id_comision, fecha_inscripcion, estado)
            VALUES (@socio, @comision, CAST(GETDATE() AS DATE), 'ACTIVA');

            PRINT 'Inscripción realizada exitosamente.';
        END

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

-- =============================================
-- Description:	SP-05 Dar de baja socio en una comisión, 
--              verifica que el socio tenga una inscrpción activa
--              en la comisión y cambia el estado de la misma a BAJA.
-- =============================================
CREATE PROCEDURE sp_BajaInscripcionComision
    @socio INT,
    @comision INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el socio existe.
        IF NOT EXISTS(
			SELECT 1 
			FROM SOCIO WHERE id_socio=@socio)
        BEGIN
            RAISERROR('El socio no existe.', 16, 1);
        END

		--  Validar existencia de la comisión.
        IF NOT EXISTS(
			SELECT 1 
			FROM COMISION WHERE id_comision=@comision)        
        BEGIN
            RAISERROR('La comisión seleccionada no existe.', 16, 1);
        END

        -- Controlar que el socio esté inscripto en la comisión de forma activa.
        IF NOT EXISTS (
            SELECT 1 
            FROM INSCRIPCION 
            WHERE id_socio = @socio 
              AND id_comision = @comision 
              AND estado = 'ACTIVA'
        )
		BEGIN
            RAISERROR('El socio no posee una inscripción activa en esta comisión para dar de baja.', 16, 1);
        END
        
        -- Registrar la baja en la base de datos.
        UPDATE INSCRIPCION 
		SET estado = 'BAJA', 
			fecha_baja = CAST(GETDATE() AS DATE)
		WHERE id_socio = @socio 
              AND id_comision = @comision 
			  AND estado = 'ACTIVA';

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;
        PRINT 'Baja realizada exitosamente.';

    END TRY
	BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END
GO

-- ==================================================================================
-- Description: SP-06 Registra la asistencia de un socio a una comisión específica, 
-- validando su inscripción activa y previene duplicados para la misma fecha (RN06).
-- ==================================================================================
CREATE PROCEDURE sp_RegistrarAsistenciaActividad
    @id_socio INT,
    @id_comision INT,
    @estado_asistencia VARCHAR(20) = 'PRESENTE'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Declarar variables para almacenar el id_inscripcion y control de duplicados
        DECLARE @id_inscripcion INT;
        DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);

        -- Validar que el socio esté inscripto y activo en la comisión (RN06)
        SELECT @id_inscripcion = id_inscripcion
        FROM INSCRIPCION
        WHERE id_socio = @id_socio 
          AND id_comision = @id_comision 
          AND estado = 'ACTIVA';

        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('El socio no se encuentra inscripto o no posee una inscripción activa en esta comisión.', 16, 1);
        END

        -- Controlar que no exista un registro de asistencia duplicado para la misma fecha y comisión/inscripción (RN06)
        IF EXISTS (
            SELECT 1 
            FROM ASISTENCIA 
            WHERE id_inscripcion = @id_inscripcion 
              AND fecha = @fecha_hoy
        )
        BEGIN
            RAISERROR('Ya existe un registro de asistencia para este socio en la comisión en el día de la fecha.', 16, 1);
        END

        -- Registrar la fecha, hora e id de inscripción correspondientes en la tabla ASISTENCIA
        INSERT INTO ASISTENCIA (id_inscripcion, fecha, estado)
        VALUES (@id_inscripcion, GETDATE(), @estado_asistencia);

        -- Confirmar la transacción si todo salió bien
        COMMIT TRANSACTION;
        PRINT 'Asistencia registrada exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la integridad de la BD
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores al igual que en tus SPs anteriores
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'sp_RegistrarAsistenciaActividad') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO


-------------------------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE RESERVAS DE INSTALACIONES
-------------------------------------------------------------------------

-- ===============================================================================
-- Description:	SP-07 Se crea una reserva de una instalación para una fecha determinada,
-- verifica que el espacio esté disponible, que la cantidad de invitados sea menor
-- a la capacidad, y que el socio tenga una membresía válida.
-- ===============================================================================
CREATE PROCEDURE sp_CrearReservaInstalacion 
	-- Add the parameters for the stored procedure here
	@instalacion INT, 
	@socio INT,
	@fecha DATE,
	@ctd_invitados INT,
	@inicio TIME,
	@fin TIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
	
		-- Validar que la instalación exista.
        IF NOT EXISTS (SELECT 1 FROM dbo.INSTALACION WHERE id_instalacion = @instalacion)
        BEGIN
            RAISERROR('La instalación especificada no existe en el sistema.', 16, 1);
        END

        -- Validar coherencia en los horarios.
        IF @inicio > @fin
        BEGIN
            RAISERROR('La hora de inicio del mantenimiento no puede ser posterior a la hora de finalización.', 16, 1);
        END


        -- Validar socio y membresía vigente usando la función fn_SocioHabilitado
        IF dbo.fn_SocioHabilitado(@socio, GETDATE()) = 0
        BEGIN
            RAISERROR('El socio no existe, no se encuentra activo o no posee una membresía vigente.', 16, 1);
        END

		--  Validar si el espacio está disponible en la fecha y horario indicado usando la función fn_InstalacionTieneClases
        IF dbo.fn_InstalacionTieneClases(@instalacion, @fecha, @inicio, @fin) = 1

        BEGIN
            RAISERROR('La instalación tiene una clase en el horario indicado.', 16, 1);
        END

		-- Validar que la instalación no tenga tareas de mantenimiento pendientes o en proceso en esa fecha (RN08)
        IF EXISTS (
            SELECT 1 
            FROM MANTENIMIENTO AS m
            WHERE m.id_instalacion = @instalacion
              AND m.estado IN ('PENDIENTE', 'EN_PROCESO')
              AND @fecha BETWEEN m.fecha_inicio AND COALESCE(m.fecha_fin_real, m.fecha_fin_estimada, @fecha)
        )
        BEGIN
            RAISERROR('No se puede reservar la instalación porque se encuentra en mantenimiento o tiene tareas programadas para esa fecha.', 16, 1);
        END

        -- Verificar si la Instalación tiene reservas previas en ese horario. (RN07)
        IF EXISTS (
            SELECT 1 
            FROM RESERVA as r
            WHERE r.id_instalacion = @instalacion 
              AND r.fecha = @fecha
			  AND @inicio < r.hora_fin 
			  AND @fin > r.hora_inicio
			  AND r.estado = 'CONFIRMADA'
        )
        BEGIN
            RAISERROR('La instalación ya tiene una reserva en el horario indicado.', 16, 1);
        END

		IF @ctd_invitados>(SELECT i.capacidad from INSTALACION i 
		WHERE i.id_instalacion = @instalacion)
		BEGIN
            RAISERROR('Los invitados superan la capacidad máxima de la instalación.', 16, 1);
        END

        INSERT INTO RESERVA(id_socio, id_instalacion, fecha, hora_inicio, hora_fin, fecha_creacion, estado)
        VALUES (@socio, @instalacion, @fecha, @inicio, @fin, GETDATE(), 'CONFIRMADA');

        PRINT 'Reserva realizada exitosamente.';

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

-- =====================================================
-- Description:	SP-08 Actualiza el estado de una reserva
-- de instalación APROBADA a CANCELADA.
-- =====================================================
CREATE PROCEDURE sp_CancelarReservaInstalacion 
	-- Add the parameters for the stored procedure here
	@id_reserva INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY

        -- Verificar si la reserva existe.
        IF NOT EXISTS (
            SELECT 1 
            FROM RESERVA as r
            WHERE r.id_reserva = @id_reserva
			  AND r.estado IN ('CONFIRMADA','PENDIENTE')
        )
		BEGIN
            RAISERROR('No existe una reserva confirmada o pendiente con el ID ingresado.', 16, 1);
        END

        UPDATE RESERVA SET estado = 'CANCELADA'
        WHERE id_reserva = @id_reserva

        PRINT 'Reserva cancelada exitosamente.';

        -- Confirmar la transacción si no hay errores.
        COMMIT TRANSACTION;

    END TRY
	BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la BD.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error de vuelta conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

-----------------------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE TAREAS DE MANTENIMIENTO
-----------------------------------------------------------------------

-- ===============================================================
-- Description: SP-09 Permite programar una tarea de mantenimiento
-- para una instalación determinada, validando fechas y delegando  
-- el control de reservas activas al trigger correspondiente.
-- ===============================================================
CREATE PROCEDURE sp_ProgramarMantenimientoInstalacion
    @instalacion INT,
	@responsable INT,
	@tipo VARCHAR(20),
    @fecha_inicio DATE,
    @fecha_fin_estimada DATE = NULL,
    @descripcion NVARCHAR(255),
    @estado VARCHAR(20) = 'PENDIENTE'
AS
BEGIN
    SET NOCOUNT ON;

    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que la instalación exista.
        IF NOT EXISTS (SELECT 1 FROM dbo.INSTALACION WHERE id_instalacion = @instalacion)
        BEGIN
            RAISERROR('La instalación especificada no existe en el sistema.', 16, 1);
        END

        -- Validar coherencia en las fechas ingresadas.
        IF @fecha_fin_estimada IS NOT NULL AND @fecha_inicio > @fecha_fin_estimada
        BEGIN
            RAISERROR('La fecha de inicio del mantenimiento no puede ser posterior a la fecha fin estimada.', 16, 1);
        END

        -- Validar que el estado ingresado sea válido.
        IF UPPER(@estado) NOT IN ('PENDIENTE', 'EN_PROCESO')
        BEGIN
            RAISERROR('El estado del mantenimiento debe ser PENDIENTE o EN_PROCESO.', 16, 1);
        END

		-- Validar que el tipo ingresado sea válido.
        IF @tipo NOT IN ('OTRO', 'CORRECTIVO', 'PREVENTIVO')
        BEGIN
            RAISERROR('El tipo del mantenimiento debe ser OTRO, CORRECTIVO o PREVENTIVO', 16, 1);
        END


        -- Insertar el registro de mantenimiento. 
        -- Nota: El trigger TR_MANTENIMIENTO_VALIDAR_RESERVAS se disparará automáticamente 
        -- para verificar si hay reservas pendientes o confirmadas en ese rango de fechas.
        INSERT INTO dbo.MANTENIMIENTO (id_instalacion, id_responsable, tipo, fecha_inicio, fecha_fin_estimada, descripcion, estado)
        VALUES (@instalacion, @responsable, UPPER(@tipo), @fecha_inicio, @fecha_fin_estimada, @descripcion, @estado);

        PRINT 'Tarea de mantenimiento programada exitosamente.';

        -- Confirmar la transacción si todo salió bien
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, se deshacen los cambios para mantener la consistencia
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores (incluye el error lanzado por el trigger si existieran reservas)
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + ': ' + @ErrorMsg;

        -- Propagar el error conservando severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO


-----------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE PAGOS
-----------------------------------------------------

-- =========================================================================
-- Descripción: SP-10 Registra el pago de una membresía, la vincula mediante 
-- PAGO_MEMBRESIA, crea o renueva el período de membresía y activa al socio.
-- =========================================================================
CREATE PROCEDURE dbo.sp_RegistrarPagoYRenovacionMembresia
    @id_socio INT,
    @importe DECIMAL(10,2),
    @medio_pago VARCHAR(50),
    @id_plan_membresia INT,
    @concepto VARCHAR(150) = 'Pago de Membresía'
AS
BEGIN
    SET NOCOUNT ON;

    -- Iniciamos la transacción para garantizar la atomicidad (Todo o Nada)
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el socio exista
        IF NOT EXISTS (SELECT 1 FROM dbo.SOCIO WHERE id_socio = @id_socio)
        BEGIN
            RAISERROR('El socio especificado no existe en el sistema.', 16, 1);
        END

        -- Validar que el importe sea mayor a cero
        IF @importe <= 0
        BEGIN
            RAISERROR('El importe del pago debe ser mayor a cero.', 16, 1);
        END

        -- Obtener la duración en meses y el precio actual del plan de membresía
        DECLARE @duracion_meses INT;
        DECLARE @precio_plan DECIMAL(10,2);

        SELECT 
            @duracion_meses = duracion_meses,
            @precio_plan = precio_actual
        FROM dbo.PLAN_MEMBRESIA 
        WHERE id_plan = @id_plan_membresia 
          AND estado = 'ACTIVO';

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('El plan de membresía seleccionado no existe o no se encuentra activo.', 16, 1);
        END

        -- Validar que el importe abonado cubra el valor del plan
        IF @importe < @precio_plan
        BEGIN
            RAISERROR('El importe abonado es insuficiente para cubrir el valor del plan seleccionado.', 16, 1);
        END

		-- Verificar que el medio de pago ingresado sea válido
		IF @medio_pago NOT IN ('EFECTIVO', 'TRANSFERENCIA', 'OTRO', 'MERCADO_PAGO',
		'TARJETA_CREDITO', 'TARJETA_DEBITO')
		BEGIN
            RAISERROR('El medio de pago debe estar dentro de las opciones válidas: EFECTIVO, TRANSFERENCIA, MERCADO_PAGO,
		TARJETA_CREDITO, TARJETA_DEBITO, OTRO', 16, 1);
        END

        -- Registrar el pago en la tabla PAGO
        INSERT INTO dbo.PAGO (id_socio, importe, fecha_pago, concepto, medio_pago, estado)
        VALUES (@id_socio, @importe, GETDATE(), @concepto, UPPER(@medio_pago), 'APROBADO');

        -- Capturar el ID del pago generado
        DECLARE @nuevo_id_pago INT = SCOPE_IDENTITY();

        -- Lógica de cálculo de fechas e ID de la Membresía previa (FILTRADO POR PLAN)
        DECLARE @id_membresia_existente INT;
        DECLARE @fecha_inicio_antigua DATE;
        DECLARE @fecha_fin_antigua DATE;
        DECLARE @fecha_inicio_nueva DATE;
        DECLARE @fecha_fin_nueva DATE;

        -- Buscamos la última membresía del socio que coincida específicamente con ESTE plan
        SELECT TOP 1 
            @id_membresia_existente = id_membresia,
            @fecha_inicio_antigua = fecha_inicio,
            @fecha_fin_antigua = fecha_fin
        FROM dbo.MEMBRESIA
        WHERE id_socio = @id_socio
          AND id_plan = @id_plan_membresia
        ORDER BY fecha_fin DESC;

        -- Determinar si la membresía de ese plan sigue vigente o ya venció
        IF @fecha_fin_antigua IS NOT NULL AND @fecha_fin_antigua >= CAST(GETDATE() AS DATE)
        BEGIN
            -- Extensión: Arranca donde terminaba la anterior de este mismo plan
            SET @fecha_inicio_nueva = @fecha_inicio_antigua; 
            SET @fecha_fin_nueva = DATEADD(MONTH, @duracion_meses, @fecha_fin_antigua);
        END
        ELSE
        BEGIN
            -- Renovación por vencimiento o primera vez en este plan: arranca hoy
            SET @fecha_inicio_nueva = CAST(GETDATE() AS DATE);
            SET @fecha_fin_nueva = DATEADD(MONTH, @duracion_meses, GETDATE());
        END

        -- UPDATE si ya tiene un registro de membresía de este plan, INSERT si es nuevo para este plan
        DECLARE @id_membresia_final INT;

        IF @id_membresia_existente IS NOT NULL
        BEGIN
            -- Actualizamos el registro existente de este plan
            UPDATE dbo.MEMBRESIA
            SET fecha_inicio = @fecha_inicio_nueva,
                fecha_fin = @fecha_fin_nueva,
                precio_contratado = @importe,
                estado = 'VIGENTE'
            WHERE id_membresia = @id_membresia_existente;

            SET @id_membresia_final = @id_membresia_existente;
        END
        ELSE
        BEGIN
            -- Si no tenía ningún registro previo para este plan, insertamos uno nuevo
            INSERT INTO dbo.MEMBRESIA (id_socio, id_plan, fecha_inicio, fecha_fin, precio_contratado, estado)
            VALUES (@id_socio, @id_plan_membresia, @fecha_inicio_nueva, @fecha_fin_nueva, @importe, 'VIGENTE');
            SET @id_membresia_final = SCOPE_IDENTITY();
        END
        
        -- Vincular el pago con la membresía en la tabla intermedia PAGO_MEMBRESIA
        INSERT INTO dbo.PAGO_MEMBRESIA (id_pago, id_membresia)
        VALUES (@nuevo_id_pago, @id_membresia_final);

        -- Actualizar el estado del socio a 'ACTIVO'
        UPDATE dbo.SOCIO
        SET estado = 'ACTIVO'
        WHERE id_socio = @id_socio;

        -- Confirmar la transacción si todo fue exitoso
        COMMIT TRANSACTION;
        PRINT 'Pago registrado y membresía actualizada/renovada con éxito.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, se deshacen los cambios para mantener la consistencia
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + ': ' + @ErrorMsg;

        -- Propagar el error conservando severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

------------------------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DEL PERSONAL Y SUS USUARIOS
------------------------------------------------------------------------

-- ==================================================================
-- Description: SP-11 Registra un nuevo empleado en la tabla PERSONAL
-- y, simultáneamente, crea su cuenta de acceso en USUARIO_SISTEMA 
-- con su rol inicial correspondiente de forma transaccional.
-- ==================================================================
CREATE PROCEDURE sp_RegistrarPersonalConUsuario
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @dni VARCHAR(20),
	@telefono VARCHAR(20),
    @email VARCHAR(100),
    @password_hash VARCHAR(255),
    @id_rol INT,
	@nombre_usuario VARCHAR(50) = 'nombre.apellido'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que no exista otro empleado registrado con el mismo DNI
        IF EXISTS (SELECT 1 FROM dbo.PERSONAL WHERE dni = @dni)
        BEGIN
            RAISERROR('Ya existe un empleado registrado con el DNI ingresado.', 16, 1);
        END

        -- Validar que no exista otro empleado con el mismo correo electrónico
        IF EXISTS (SELECT 1 FROM dbo.PERSONAL WHERE email = @email)
        BEGIN
            RAISERROR('Ya existe un empleado registrado con el correo electrónico ingresado.', 16, 1);
        END

		IF @nombre_usuario = 'nombre.apellido'
		BEGIN
			-- Declaración de variables para armar el usuario
			DECLARE @primer_nombre VARCHAR(50);
			DECLARE @apellido_limpio VARCHAR(50);

			-- Reemplazar tildes, diéresis y la letra 'ñ' por sus caracteres correspondientes
            SET @nombre = TRANSLATE(@nombre, 'áéíóúÁÉÍÓÚñÑäëïöüÄËÏÖÜ', 'aeiouAEIOUnNaeiouAEIOU');
            SET @apellido = TRANSLATE(@apellido, 'áéíóúÁÉÍÓÚñÑäëïöüÄËÏÖÜ', 'aeiouAEIOUnNaeiouAEIOU');

			-- Limpiar espacios excedentes en los extremos
			SET @nombre = LTRIM(RTRIM(@nombre));
			SET @apellido = LTRIM(RTRIM(@apellido));

			-- Obtener solo el primer nombre (si hay espacios, corta antes del primer espacio)
			IF CHARINDEX(' ', @nombre) > 0
				SET @primer_nombre = SUBSTRING(@nombre, 1, CHARINDEX(' ', @nombre) - 1);
			ELSE
				SET @primer_nombre = @nombre;

			-- Tomar el apellido (elimina espacios si los hubiera)
			SET @apellido_limpio = REPLACE(@apellido, ' ', '');

			-- Concatenar y pasar todo a minúsculas (ej: juan.perez)
			SET @nombre_usuario = LOWER(@primer_nombre + '.' + @apellido_limpio);

			-- Validar que el nombre de usuario de sistema no esté ocupado
			IF EXISTS (SELECT 1 FROM dbo.USUARIO_SISTEMA WHERE nombre_usuario = @nombre_usuario)
			BEGIN
				SET @nombre_usuario = LOWER(@apellido_limpio + '.' + @primer_nombre)
				--Vuelve a validar el nombre de usuario actualizado a apellido.nombre
				IF EXISTS (SELECT 1 FROM dbo.USUARIO_SISTEMA WHERE nombre_usuario = @nombre_usuario)
				BEGIN
					RAISERROR('El nombre de usuario generado automáticamente ya existe en el sistema. Pasar el valor como parametro.', 16, 1);
				END
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM dbo.USUARIO_SISTEMA WHERE nombre_usuario = @nombre_usuario)
			BEGIN
				RAISERROR('El nombre de usuario ingresado ya existe en el sistema.', 16, 1);
			END
		END

        -- Validar que el rol especificado exista en el sistema
        IF NOT EXISTS (SELECT 1 FROM dbo.ROL WHERE id_rol = @id_rol)
        BEGIN
            RAISERROR('El rol especificado no existe en el sistema.', 16, 1);
        END

        -- Insertar el registro del nuevo personal
        INSERT INTO dbo.PERSONAL (nombre, apellido, dni, telefono, email, estado)
        VALUES (@nombre, @apellido, @dni, @telefono, @email, 'ACTIVO');

        -- Obtener el ID del personal recién insertado
        DECLARE @id_personal INT = SCOPE_IDENTITY();

        -- Crear el usuario de sistema vinculado al personal
        INSERT INTO dbo.USUARIO_SISTEMA (id_personal, nombre_usuario, password_hash, estado)
        VALUES (@id_personal, @nombre_usuario, @password_hash, 'ACTIVO');

        -- Obtener el ID del usuario de sistema recién creado
        DECLARE @id_usuario INT = SCOPE_IDENTITY();

        -- Asignar el rol correspondiente en la tabla intermedia USUARIO_ROL
        INSERT INTO dbo.USUARIO_ROL (id_usuario, id_rol, fecha_asignacion)
        VALUES (@id_usuario, @id_rol, GETDATE());

        -- Confirmar la transacción si todo salió bien
        COMMIT TRANSACTION;
        PRINT 'Personal y usuario de sistema registrados exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, se deshacen los cambios para mantener la consistencia
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + '] en la línea ' 
        + CAST(@ErrorLine AS VARCHAR(10)) + ': ' + @ErrorMsg;

        -- Propagar el error conservando severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

-- ========================================================================
-- Description: SP-12 Permite asignar o cambiar roles a un 
-- usuario del sistema de forma segura, validando la existencia previa, 
-- evitando duplicados en USUARIO_ROL y registrando la fecha de asignación.
-- ========================================================================
CREATE PROCEDURE sp_AsignarRolUsuario
    @id_usuario INT,
    @id_rol INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el usuario del sistema exista
        IF NOT EXISTS (SELECT 1 FROM dbo.USUARIO_SISTEMA WHERE id_usuario = @id_usuario)
        BEGIN
            RAISERROR('El usuario del sistema especificado no existe.', 16, 1);
        END

        -- Validar que el rol exista en el sistema
        IF NOT EXISTS (SELECT 1 FROM dbo.ROL WHERE id_rol = @id_rol)
        BEGIN
            RAISERROR('El rol especificado no existe en el sistema.', 16, 1);
        END

        -- Verificar que el usuario no tenga ya asignado ese rol para evitar duplicados en USUARIO_ROL
        IF EXISTS (
            SELECT 1 
            FROM dbo.USUARIO_ROL 
            WHERE id_usuario = @id_usuario 
              AND id_rol = @id_rol
        )
        BEGIN
            RAISERROR('El usuario ya tiene asignado este rol.', 16, 1);
        END

        -- Insertar la asignación registrando la fecha correspondiente
        INSERT INTO dbo.USUARIO_ROL (id_usuario, id_rol, fecha_asignacion)
        VALUES (@id_usuario, @id_rol, CAST(GETDATE() AS DATE));

        -- Confirmar la transacción si todo salió bien
        COMMIT TRANSACTION;
        PRINT 'Rol asignado exitosamente al usuario.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, la deshacemos para proteger la integridad de la BD
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores
        DECLARE @ErrorNum INT = ERROR_NUMBER();
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        -- Armamos un mensaje completo para el diagnóstico
        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'sp_AsignarRolUsuario') + 
                            '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + 
                            ': ' + @ErrorMsg;

        -- Propagamos el error conservando su severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO

--------------------------------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PARA EL MANEJO DE INGRESOS Y EGRESOS AL CLUB
--------------------------------------------------------------------------

-- ===============================================
-- Description: SP-13 Permite registrar el ingreso
-- y egreso de socios al club.
-- ===============================================

CREATE PROCEDURE sp_RegistrarFichadasSocios
    @id_socio INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Manejo de transacciones para garantizar la atomicidad y consistencia
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Validar que el socio exista.
        IF NOT EXISTS (SELECT 1 FROM dbo.SOCIO WHERE id_socio = @id_socio)
        BEGIN
            RAISERROR('El usuario del sistema especificado no existe.', 16, 1);
        END

        -- Validar si el socio ficho ingreso, si sí, pasa a fichar salida.
        IF EXISTS (SELECT 1 FROM dbo.ACCESO WHERE id_socio = @id_socio 
        AND CAST(fecha_hora_ingreso AS DATE) = CAST(GETDATE() AS DATE)
        AND fecha_hora_egreso IS NULL)
        BEGIN
            UPDATE  dbo.ACCESO  SET fecha_hora_egreso= GETDATE()
            WHERE id_socio=@id_socio 
            AND CAST(fecha_hora_ingreso AS DATE) = CAST(GETDATE() AS DATE)
            AND fecha_hora_egreso IS NULL;
            
        END
        ELSE
        BEGIN
            -- Insertar la asignación registrando la fecha correspondiente
            INSERT INTO dbo.ACCESO (id_socio, fecha_hora_ingreso)
            VALUES (@id_socio, GETDATE());
        END

        -- Confirmar la transacción si todo salió bien
        COMMIT TRANSACTION;
        PRINT 'Ingreso/egreso registrado exitosamente.';

    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, se deshacen los cambios para mantener la consistencia
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Captura avanzada de errores
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSev INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProc SYSNAME = ERROR_PROCEDURE();

        DECLARE @MensajeFinal NVARCHAR(4000);
        SET @MensajeFinal = 'Error en SP [' + ISNULL(@ErrorProc, 'SQL_Query') + '] en la línea ' + CAST(@ErrorLine AS VARCHAR(10)) + ': ' + @ErrorMsg;

        -- Propagar el error conservando severidad y estado original
        RAISERROR(@MensajeFinal, @ErrorSev, @ErrorState);
    END CATCH
END;
GO


