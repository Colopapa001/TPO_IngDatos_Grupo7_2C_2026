USE DB_Gestion_Polideportivo_G7;
GO

-- Comparar esperado y obtenido de manera manual. NULL indica ausencia de resultado, no que el resultado sea cero
-- Se supone como realizada la carga inicial y que el ID 2147483647 no existe

-- 1. Pruebas de fn_CuposDisponibles

-- Cupos: queda una inscripcion activa y el maximo es 20
SELECT 'Cupos: comision con inscriptos' AS caso,
       19 AS esperado, dbo.fn_CuposDisponibles(1) AS obtenido;

-- La unica inscripcion de la comision 2 esta de baja
SELECT 'Cupos: sin inscripciones activas' AS caso,
       20 AS esperado, dbo.fn_CuposDisponibles(2) AS obtenido;

SELECT 'Cupos: parametro nulo' AS caso,
       NULL AS esperado, dbo.fn_CuposDisponibles(NULL) AS obtenido;

SELECT 'Cupos: identificador inexistente' AS caso,
       NULL AS esperado, dbo.fn_CuposDisponibles(2147483647) AS obtenido;

-- 2. Pruebas de fn_SocioHabilitado

-- Habilitacion: socio activo y contrato vigente en octubre
SELECT 'Habilitacion: cumple las condiciones' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(1, '20261027') AS obtenido;

SELECT 'Habilitacion: membresia vencida' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2, '20261027') AS obtenido;

-- Caso limite: el ultimo dia del contrato todavia esta incluido
SELECT 'Habilitacion: fecha final incluida' AS caso,
       1 AS esperado, dbo.fn_SocioHabilitado(1, '20261031') AS obtenido;

SELECT 'Habilitacion: identificador inexistente' AS caso,
       0 AS esperado, dbo.fn_SocioHabilitado(2147483647, '20261027') AS obtenido;

-- 3. Pruebas de fn_SaldoMembresia
-- Ejecutar esta seccion solo si se creo dbo.fn_SaldoMembresia
-- Puede omitirse desde aqui hasta el final del archivo

-- Comprueba que una membresia totalmente pagada devuelva saldo cero
SELECT 'Saldo: contrato cubierto' AS caso,
       0.00 AS esperado, dbo.fn_SaldoMembresia(1) AS obtenido;

-- Un pago rechazado no disminuye el saldo
SELECT 'Saldo: pago rechazado' AS caso,
       45000.00 AS esperado, dbo.fn_SaldoMembresia(3) AS obtenido;

SELECT 'Saldo: parametro nulo' AS caso,
       NULL AS esperado, dbo.fn_SaldoMembresia(NULL) AS obtenido;

SELECT 'Saldo: identificador inexistente' AS caso,
       NULL AS esperado, dbo.fn_SaldoMembresia(2147483647) AS obtenido;
