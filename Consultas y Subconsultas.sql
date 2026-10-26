/* Socios que nunca pagaron con tarjeta de crédito
Esta consulta/subconsulta es util ya que permite al negocio detectar que socios nunca pagaron (con éxito) por este medio
Y así, incentivarlos con promociones por ejemplo.
*/
SELECT id_socio, dni, nombre, apellido, email
FROM SOCIO as socio
WHERE NOT EXISTS (
    SELECT 1
    FROM PAGO as pago
    WHERE pago.id_socio = socio.id_socio
      AND pago.medio_pago = 'TARJETA_CREDITO'
      AND pago.estado = 'APROBADO'
);

/* Entrenadores sin comisiones activas
Esta consulta/subconsulta es útil ya que permite que el negocio detecte que entrenadores requieren ser asignados a una comisión
U otras medidas que puedan llegar a necesitar
*/
SELECT pers.id_personal, pers.nombre, pers.apellido, esp.especialidad
FROM PERSONAL pers
JOIN ENTRENADOR ent ON ent.id_personal = pers.id_personal
WHERE NOT EXISTS (
    SELECT 1 FROM COMISION com
    WHERE com.id_personal = pers.id_personal
      AND com.estado = 'ACTIVA'
);

/* Socios que pagaron más que el promedio
Esta consulta/subconsulta es útil ya que permite al negocio detectar que clientes son los que más aportan
para poder tenerlos como prioridad */
SELECT id_socio, importe
FROM PAGO
WHERE estado = 'APROBADO'
  AND importe > (SELECT AVG(importe) FROM PAGO WHERE estado = 'APROBADO');