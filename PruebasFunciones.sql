USE DB_Gestion_Polideportivo_G7;
GO

-- Comparar esperado y obtenido de manera manual. NULL indica ausencia de resultado, no que el resultado sea cero
-- Se supone como realizada la carga inicial y que el ID 2147483647 no existe
-- Usar la carga ampliada actual, sobre tablas inicialmente vacias.
-- Ejecutar antes de Cursores.sql: el cursor de vencimientos modifica los estados segun la fecha actual.

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

-- Fuera del periodo contratado, aunque el estado almacenado siga siendo VIGENTE
SELECT 'Habilitacion: contrato finalizado en la fecha consultada' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2, '20261101') AS obtenido;

-- Caso limite: el ultimo dia del contrato todavia esta incluido
SELECT 'Habilitacion: fecha final incluida' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(1, '20261031') AS obtenido;

SELECT 'Habilitacion: identificador inexistente' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2147483647, '20261027') AS obtenido;
