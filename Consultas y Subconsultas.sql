/* Socios que nunca pagaron con tarjeta de crédito

- Que información desea obtener:
El listado de socios que nunca registraron un pago aprobado utilizando el medio de pago 'TARJETA_CREDITO'
los presenta ordenados alfabéticamente por apellido y nombre

- Que funcion cumple la subconsulta:
La subconsulta relacionada mediante "NOT EXISTS" busca en la tabla PAGO si existe al menos un pago linkeado al socio actual
(usando "id_socio") que tenga como medio de pago "TARJETA_CREDITO" y estado "APROBADO"

- Por qué resulta adecuada para resolver la problemática:
Permite detectar aquellos clientes que nunca utilizaron el medio de pago para incentivarlos mediante promociones, por el lado
técnico "NOT EXISTS" actua como un operador de cortocircuito eficiente ya que al encontrar la primera coincidencia no procesa
datos adicionales de forma innecesaria.
*/
SELECT soc.id_socio, soc.dni, soc.nombre, soc.apellido, soc.email
FROM SOCIO AS soc
WHERE NOT EXISTS (
    SELECT 1 FROM PAGO AS pago
    WHERE pago.id_socio = soc.id_socio
      AND pago.medio_pago = 'TARJETA_CREDITO'
      AND pago.estado = 'APROBADO'
)
ORDER BY soc.apellido, soc.nombre;

/* Entrenadores sin comisiones activas

- Que información desea obtener:
Los entrenadores que no tienen ninguna comisión asignada en estado "ACTIVA"

- Que funcion cumple la subconsulta:
Evalúa mediante "NOT EXISTS" en la tabla "COMISIÓN" la ausencia de registros activos vinculados al ID del personal evaluado  en
la consulta principal

- Por qué resulta adecuada para resolver la problemática:
Desde el punto de vista del negocio es fundamental para detectar personal ocioso disponible para asignarle comisiones,
desde el punto de vista técnico, "NOT EXISTS" permite buscar coincidencias de forma simple.
*/
SELECT pers.id_personal, pers.nombre, pers.apellido, ent.especialidad
FROM PERSONAL pers
JOIN ENTRENADOR ent ON ent.id_personal = pers.id_personal
WHERE NOT EXISTS (
    SELECT 1 FROM COMISION com
    WHERE com.id_personal = pers.id_personal
      AND com.estado = 'ACTIVA'
)
ORDER BY pers.apellido, pers.nombre;

/* Socios que pagan más que el promedio

- Que información desea obtener:
Los socios que realizaron pagos individuales (aprobados) cuyo importe supera el valor promedio general de todos los pagos realizados, 
ordenados de mayor a menor.

- Que funcion cumple la subconsulta:
Calcula el valor promedio global de todos los pagos aprobados registrados en el sistema para usarlo en la comparación del WHERE y
seleccionar los socios.

- Por qué resulta adecuada para resolver la problemática:
Desde el punto de vista del negocio permite identificar los socios que aportan más que el promedio, para poder priorizarlos.
Desde lo técnico, la subconsulta es necesaria ya que en SQL no se puede usar funciones de agregación como "AVG" dentro de WHERE sin
resolverlas previamente.
*/
SELECT soc.id_socio, soc.nombre + ' ' + soc.apellido AS socio,
  SUM(pago.importe) AS total_aportado 
FROM SOCIO soc
JOIN PAGO pago ON pago.id_socio = soc.id_socio
WHERE pago.estado = 'APROBADO'
  AND pago.importe > (SELECT AVG(importe) FROM PAGO WHERE estado = 'APROBADO')
GROUP BY soc.id_socio, soc.nombre, soc.apellido
ORDER BY total_aportado DESC;

/* Actividades no realizadas por socios para recomendar
- Que información desea obtener:
Actividades no realizadas (ni ahora ni en el pasado) por socios que realizan más de una actividad.

- Que funcion cumple la subconsulta:
Consta de dos subconsultas:
  1: Cuenta la cantidad de actividades distintas con inscripción "ACTIVA" que posee el socio analizado, filtrando
  a quienes tienen 2 o más.
  2: Verifica con "NOT EXIST" que no existan inscripciones pasadas de ese socio en alguna comision perteneciente
  a la actividad evaluada.

- Por qué resulta adecuada para resolver la problemática:
Para el negocio resuelve una necesidad comercial clave: Premir o incentivar a los socios más comprometidos ofrenciendo actividades
nuevas que no probaron. Desde lo técnico, hacer CROSS JOIN con ambas subconsultas permite cruzar el universo de socios con las
actividades y filtrar a los clientes con 2 o más actividades y la ausencia de inscripciones previas a otras actividades.
*/
SELECT soc.id_socio, soc.nombre + ' ' + soc.apellido AS socio, acti.nombre AS actividad_recomendada
FROM SOCIO soc 
CROSS JOIN ACTIVIDAD acti
WHERE
    -- El socio practica 2 o más actividades distintas (activas)
    (SELECT COUNT(DISTINCT com.id_actividad)
     FROM INSCRIPCION ins
     JOIN COMISION com ON com.id_comision = ins.id_comision
     WHERE ins.id_socio = soc.id_socio
       AND ins.estado = 'ACTIVA') >= 2
    -- Y nunca se inscribió a esa actividad (ni activa ni baja)
    AND NOT EXISTS (
        SELECT 1 FROM INSCRIPCION ins2
        JOIN COMISION com2 ON com2.id_comision = ins2.id_comision
        WHERE ins2.id_socio = soc.id_socio
          AND com2.id_actividad = acti.id_actividad
    )
    AND acti.estado = 'ACTIVA'
ORDER BY socio, actividad_recomendada;

/* Instalaciones más demandadas en reservas de socios
- Objetivo y necesidad del negocio:
Permite identificar las instalaciones más pedidas para reservas particulares por parte de los socios, ayudando al negocio a
planificar el mantenimiento preventivo de los espacios más exigidos y gestionar la disponibilidad de turnos de reserva.

- Elementos técnicos aplicados:
Combina INSTALACION, RESERVA y SOCIO mediante JOIN, filtra reservas vigentes y socios activos con WHERE, agrupa por instalación
con GROUP BY, aplica las funciones de agregación COUNT y DISTINCT, filtra con HAVING y ordena por nivel de demanda con ORDER BY.

*/
SELECT inst.id_instalacion, inst.nombre AS instalacion, inst.tipo_instalacion, inst.ubicacion, inst.capacidad,
    COUNT(res.id_reserva) AS total_reservas, 
    COUNT(DISTINCT res.id_socio) AS socios_distintos
FROM INSTALACION inst
JOIN RESERVA res ON res.id_instalacion = inst.id_instalacion
JOIN SOCIO soc ON soc.id_socio = res.id_socio
WHERE res.estado <> 'CANCELADA' AND soc.estado = 'ACTIVO'
GROUP BY inst.id_instalacion, inst.nombre, inst.tipo_instalacion, inst.ubicacion, inst.capacidad
HAVING COUNT(res.id_reserva) >= 1
ORDER BY total_reservas DESC, instalacion ASC;

/*Actividades con más demanda
- Objetivo y necesidad del negocio:
Permite identificar las actividades más demandadas, además de medir la popularidad de cada una, brinda datos clave para toma
de decisiones

- Elementos técnicos aplicados:
Se utillizan JOINS entre las tabls ACTIVIDAD, COMISION e INSCRIPCIÓN, obteniendo los registros activos, agrupando por actividad
con GROUP BY, usando funciones de agregación simultaneas (COUNT, DISTINCT) para obtener datos relevantes de cada actividad 
y ordenamiento descendiente por volumen de inscriptos. (ORDER BY)

*/
SELECT
    acti.id_actividad, acti.nombre AS actividad,
    COUNT(DISTINCT com.id_comision) AS cantidad_comisiones,
    COUNT(ins.id_inscripcion) AS inscriptos_totales,
    COUNT(DISTINCT ins.id_socio) AS socios_unicos
FROM ACTIVIDAD acti
JOIN COMISION com ON com.id_actividad = acti.id_actividad
JOIN INSCRIPCION ins ON ins.id_comision  = com.id_comision
WHERE acti.estado = 'ACTIVA' AND com.estado = 'ACTIVA' AND ins.estado = 'ACTIVA'
GROUP BY acti.id_actividad, acti.nombre
HAVING COUNT(ins.id_inscripcion) >= 1
ORDER BY inscriptos_totales DESC, actividad ASC;


/*Horarios con menos inscriptos activos
- Objetivo y necesidad de negocio: 
Permite al negocio detectar los horarios con la menor cantidad de inscriptos activos.
Esta información es sumamente útil para tomar decisiones estratégicas como promociones o cancelaciones de turnos no rentables.

- Elementos técnicos aplicados:
Usa LEFT JOIN entre COMISION e INSCRIPCIÓN, esto permite no filtrar las comisiones sin socios inscriptos, que son las más
críticas en este requerimiento de negocio.

*/
SELECT com.dia_semana, com.hora_inicio,
    COUNT(ins.id_inscripcion) AS inscriptos_activos,
    SUM(com.cupo_maximo) AS cupo_total,
    SUM(com.cupo_maximo) - COUNT(ins.id_inscripcion) AS lugares_disponibles
FROM COMISION com
LEFT JOIN INSCRIPCION ins 
  ON ins.id_comision = com.id_comision AND ins.estado = 'ACTIVA'
WHERE com.estado = 'ACTIVA'
GROUP BY com.dia_semana, com.hora_inicio
ORDER BY inscriptos_activos ASC, com.dia_semana, com.hora_inicio;