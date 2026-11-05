USE DB_Gestion_Polideportivo_G7;
GO

-- Comparar esperado y obtenido de manera manual. NULL indica ausencia de resultado, no que el resultado sea cero
-- Se supone como realizada la carga inicial y que el ID 2147483647 no existe
-- Usar la carga ampliada actual, sobre tablas inicialmente vacias.
-- La carga actual fija la fecha_fin de las membresias 1 a 4 en 2026-11-30.
-- Estas pruebas solo consultan datos: no disparan ni verifican los triggers.
-- fn_SocioHabilitado acepta VIGENTE y VENCIDA; el cursor de vencimientos no cambia esos resultados.

-- 1. Pruebas de fn_CuposDisponibles

-- Cupos: hay tres inscripciones activas y el maximo es 20
SELECT 'Cupos: comision con inscriptos' AS caso,
       17 AS esperado, dbo.fn_CuposDisponibles(1) AS obtenido;

-- La comision 2 tiene dos inscripciones activas
SELECT 'Cupos: segunda comision con inscriptos' AS caso,
       18 AS esperado, dbo.fn_CuposDisponibles(2) AS obtenido;

-- Yoga no tiene inscripciones y su cupo maximo es 15
SELECT 'Cupos: sin inscripciones activas' AS caso,
       15 AS esperado, dbo.fn_CuposDisponibles(4) AS obtenido;

SELECT 'Cupos: parametro nulo' AS caso,
       NULL AS esperado, dbo.fn_CuposDisponibles(NULL) AS obtenido;

SELECT 'Cupos: identificador inexistente' AS caso,
       NULL AS esperado, dbo.fn_CuposDisponibles(2147483647) AS obtenido;

-- 2. Pruebas de fn_SocioHabilitado

-- Habilitacion: socio activo y contrato vigente en octubre
SELECT 'Habilitacion: cumple las condiciones' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(1, '20261027') AS obtenido;

SELECT 'Habilitacion: segundo socio vigente' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(2, '20261027') AS obtenido;

-- Fuera del periodo contratado, tanto para estado VIGENTE como VENCIDA
SELECT 'Habilitacion: contrato finalizado en la fecha consultada' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2, '20261201') AS obtenido;

-- Caso limite: el ultimo dia del contrato todavia esta incluido
SELECT 'Habilitacion: fecha final incluida' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(1, '20261130') AS obtenido;

SELECT 'Habilitacion: identificador inexistente' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2147483647, '20261027') AS obtenido;

-- 3. Pruebas de fn_DiasRestantesMembresia

-- El esperado varia con el dia de ejecucion; el contrato termina el 30 de noviembre.
-- Despues de esa fecha, ambos valores deben ser negativos.
SELECT 'Dias: membresia existente' AS caso,
       DATEDIFF(DAY, CONVERT(DATE, GETDATE()), CONVERT(DATE, '20261130')) AS esperado,
       dbo.fn_DiasRestantesMembresia(1) AS obtenido;

SELECT 'Dias: parametro nulo' AS caso,
       NULL AS esperado, dbo.fn_DiasRestantesMembresia(NULL) AS obtenido;

SELECT 'Dias: identificador inexistente' AS caso,
       NULL AS esperado, dbo.fn_DiasRestantesMembresia(2147483647) AS obtenido;

-- 4. Pruebas de fn_InstalacionTieneClases
-- No requieren configurar LANGUAGE ni DATEFIRST en la conexion.
-- El 2 de noviembre de 2026 es lunes: cancha 1, clase de 18:00 a 19:30.

SELECT 'Clases: horario superpuesto' AS caso,
       1 AS esperado, dbo.fn_InstalacionTieneClases(1, '20261102', '18:30', '19:00') AS obtenido;

-- Los horarios contiguos no se superponen.
SELECT 'Clases: termina al comenzar la clase' AS caso,
       0 AS esperado, dbo.fn_InstalacionTieneClases(1, '20261102', '17:00', '18:00') AS obtenido;

SELECT 'Clases: comienza al terminar la clase' AS caso,
       0 AS esperado, dbo.fn_InstalacionTieneClases(1, '20261102', '19:30', '20:00') AS obtenido;

SELECT 'Clases: otro dia de la semana' AS caso,
       0 AS esperado, dbo.fn_InstalacionTieneClases(1, '20261103', '18:30', '19:00') AS obtenido;

-- La comision 3 usa MIERCOLES sin tilde en el esquema.
SELECT 'Clases: miercoles en gimnasio' AS caso,
       1 AS esperado, dbo.fn_InstalacionTieneClases(3, '20261104', '10:15', '10:45') AS obtenido;

SELECT 'Clases: instalacion inexistente' AS caso,
       0 AS esperado, dbo.fn_InstalacionTieneClases(2147483647, '20261102', '18:30', '19:00') AS obtenido;
