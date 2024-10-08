	-- 0. Realizar un analisis exploratorio de datos

select count(*) from cultivo.recogida

select * from cultivo.recogida
order by cantidad desc;


select * from cultivo.recogida
order by fecha asc;

select * from cultivo.factura
order by total asc

delete from cultivo.precio
where valor > 100

-- Queries simples

-- 1.  Obtener el total recolectado por cada cultivo en el 2023
select 
c.nombre,
sum(r.cantidad)
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
where year(r.fecha)=2023
group by c.nombre

-- 2. Listar clientes y el número de despachos que han tenido durante el 2023, ordenados por la cantidad de despachos

select 
c.nombre,
count(d.id) as conteo
from cultivo.despacho as d
	join cultivo.cliente as c
		on d.id_cliente = c.id
where year(d.fecha) = 2023
group by c.nombre
order by conteo desc

-- 3. Calcular el precio promedio de cada cultivo a lo largo del tiempo:

select 
c.nombre,
avg(p.valor) as promedio
from cultivo.m_cultivo as c
	join cultivo.precio as p
		on p.id_cultivo = c.id
group by c.nombre
order by promedio desc

-- 4. Identificar los lotes con menor rendimiento en el 2023 y ordenar por cantidad recolectada:
select 
l.nombre,
sum(r.cantidad) as "total_recogido"
from cultivo.lote as l
	join cultivo.recogida as r
		on r.id_lote = l.id
where year(r.fecha) = 2023
group by l.nombre
order by total_recogido asc

-- Queries con Having:

-- 5. Encontrar cultivos cuyo promedio de precios haya sido superior a un valor específico en el último año:
select 
c.nombre,
avg(p.valor) as promedio
from cultivo.m_cultivo as c
	join cultivo.precio as p
		on p.id_cultivo = c.id
where year(p.fecha) = 2023
group by c.nombre
having avg(p.valor) > 1

-- 6. Listar las fincas que han tenido más de 10 lotes cultivados:
select 
f.nombre,
count(l.id)
from cultivo.finca as f
	join cultivo.lote as l
		on l.id_finca = f.id
group by f.nombre
having count(l.id)>10

-- 7. Identificar los usuarios que han recogido más de 1000 unidades en total:
select
u.nombre,
sum(r.cantidad)
from cultivo.usuario as u
	join cultivo.recogida as r
		on r.id_usuario = u.id
group by u.nombre
having sum(r.cantidad)>1000

-- 8. Determinar los meses en los cuales el valor total de despachos superó 1500 unidades:
select 
year(d.fecha), 
month(d.fecha),
sum(r.cantidad)
from cultivo.despacho as d
	join cultivo.recogida as r
		on r.id_despacho = d.id
group by year(d.fecha), month(d.fecha)
having sum(r.cantidad)>80000000

-- 9. Calcular los lotes que tuvieron un ingreso proyectado mayor a 100 millones en el 2023. El ingreso proyectado se calcula como el precio multiplicado por la cantidad de producto recogido.
select 
l.nombre,
sum(r.cantidad * p.valor) as ingreso_proyectado
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.precio as p
		on p.id_cultivo = c.id
where year(r.fecha) = 2023
group by l.nombre
having sum(r.cantidad * p.valor) > 100000000
-- SubQueries:

-- 10. Listar todas las fincas que han bajaron su producción en más de 20% entre el 2022 y el 2023
with total_2022 as (
	select
	f.nombre,
	sum(r.cantidad) as total_recogido
	from cultivo.finca as f
		join cultivo.lote as l
			on l.id_finca = f.id
		join cultivo.recogida as r
			on r.id_lote = l.id
	where year(r.fecha) = 2022
	group by f.nombre
),
total_2023 as (
	select
	f.nombre,
	sum(r.cantidad) as total_recogido
	from cultivo.finca as f
		join cultivo.lote as l
			on l.id_finca = f.id
		join cultivo.recogida as r
			on r.id_lote = l.id
	where year(r.fecha) = 2023
	group by f.nombre
)
select
t2.nombre,
(t3.total_recogido - t2.total_recogido) * 100 / t2.total_recogido as cambio_porcentual
from total_2022 as t2
	join total_2023 as t3
		on t2.nombre = t3.nombre
where (t3.total_recogido - t2.total_recogido) * 100 / t2.total_recogido < -20


-- 11. Obtener el promedio de recolecciones por lote y listar aquellos lotes que superan el 
-- promedio general del cultivo de ese lote
-- Primero, necesitas calcular el promedio general de las recolecciones. 
-- Usa un join entre las tablas lote y recogida para obtener esta información. Una vez tengas 
-- el promedio general, procede a calcular el promedio de recolecciones por cada lote individualmente, 
--usando las mismas tablas. 
-- Finalmente, compara el promedio de cada lote con el promedio general y selecciona 
-- los lotes cuyo promedio supera el general. Este proceso puede ser facilitado utilizando
-- subconsultas o una CTE para mantener el promedio general 
-- accesible durante la comparación

-- método 1: con common table expressions
with promedio_general as (
select 
c.nombre as cultivo,
avg(r.cantidad) as prom_general
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
group by c.nombre
),
promedio_por_lote as (
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
group by c.nombre, f.nombre, l.nombre
)
select * from promedio_por_lote as pl
	join promedio_general as pg
		on pl.cultivo = pg.cultivo
where pl.prom_por_lote > pg.prom_general

-- método 2: queries anidados
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
prom_general.prom_general,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
	join (
	select 
		c.nombre as cultivo,
		avg(r.cantidad) as prom_general
		from cultivo.recogida as r
			join cultivo.lote as l
				on r.id_lote = l.id
			join cultivo.m_cultivo as c
				on l.id_cultivo = c.id
		group by c.nombre
	) as prom_general
		on prom_general.cultivo = c.nombre
group by c.nombre, f.nombre, l.nombre, prom_general.prom_general
having avg(r.cantidad)>prom_general.prom_general

-- subquery en el having
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
group by c.nombre, f.nombre, l.nombre
having avg(r.cantidad) > (
		select 
		avg(r.cantidad) as prom_general
		from cultivo.recogida as r
)


-- 12. Calcular el incremento en facturación por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en facturación por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar las facturas por mes y sumar el total de facturación
-- de cada mes. Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- facturación lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

with despachos_22 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2022
group by year(d.fecha), month(d.fecha)
),
despachos_23 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2023
group by year(d.fecha), month(d.fecha)
)
select
d22.mes,
d22.cantidad_despachos as despachos_2022,
d23.cantidad_despachos as despachos_2023,
coalesce(d23.cantidad_despachos,0) - d22.cantidad_despachos as diferencia
from despachos_22 as d22
	left join despachos_23 as d23
		on d22.mes = d23.mes

-- 12. Calcular el incremento en cantidad de despachos por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en cantidad de despachos por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar la cantidad de despachos por mes y año.
-- Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- cantidad de despacho lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

-- metodo 1: con CTE (common table expressions)
with despachos_22 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2022
group by year(d.fecha), month(d.fecha)
),
despachos_23 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2023
group by year(d.fecha), month(d.fecha)
)
select
d22.mes,
d22.cantidad_despachos as despachos_2022,
d23.cantidad_despachos as despachos_2023,
coalesce(d23.cantidad_despachos,0) - d22.cantidad_despachos as diferencia
from despachos_22 as d22
	left join despachos_23 as d23
		on d22.mes = d23.mes


-- metodo 2: creacion de una vista

create view cultivo.despachos_por_mes as
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
group by year(d.fecha), month(d.fecha);


with despachos_2022 as (
select * from cultivo.despachos_por_mes
where año = 2022
),
despachos_2023 as (
select * from cultivo.despachos_por_mes
where año = 2023
)
select 
*
from despachos_2022 as d22
	left join despachos_2023 as d23
		on d22.mes = d23.mes


-- 13. Calcular el aumento porcentual anual en el total de recogidas por cultivo entre dos años consecutivos, 
-- comparando específicamente las cantidades recolectadas en 2022 y 2023.


create view cultivo.total_recogido_por_cultivo_año as 
select 
c.nombre as cultivo,
year(r.fecha) as año,
sum(r.cantidad) as total_recogido
from cultivo.recogida as r
	join  cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
group by c.nombre, year(r.fecha);


with total_2022 as (
select * from cultivo.total_recogido_por_cultivo_año
where año = 2022
),
total_2023 as (
select * from cultivo.total_recogido_por_cultivo_año
where año = 2023
)
select 
t22.cultivo,
(t23.total_recogido - t22.total_recogido)*100/cast(t22.total_recogido as float) as cambio_porcentual
from total_2022 as t22
	join total_2023 as t23
		on t22.cultivo = t23.cultivo

-- 14. Comparar la eficiencia de las fincas en términos de ingreso por hectárea. 

-- El ingreso se calcula como la cantidad recogida multiplicado por el precio del cultivo en el mes que se dio la recogida.
-- El tamaño de la finca se puede calcular asumiendo que cada lote mide 4 hectáreas.
-- Para realizar un análisis detallado de la eficiencia de las fincas en términos de ingreso por hectárea, comienza creando una vista que 
-- determine el tamaño total de cada finca sumando el número de lotes y multiplicando por 4, ya que cada lote tiene 4 hectáreas. 
-- Posteriormente, desarrolla una vista para capturar los precios mensuales de cada cultivo, asegurando que los ingresos se calculen 
-- utilizando el precio correspondiente al mes de cada recogida. Utiliza esta vista de precios en una tercera vista que calcula el ingreso 
-- por lote, multiplicando la cantidad recolectada en cada recogida por el precio del cultivo en el mes correspondiente. Realiza un join entre la 
-- vista del tamaño de las fincas y la vista de ingresos por lote para combinar el tamaño de cada finca con los ingresos obtenidos de sus lotes, 
-- sumando los ingresos de todos los lotes que pertenecen a cada finca. Finalmente, calcula el indicador de ingreso por hectárea dividiendo el total de 
-- ingresos de cada finca por su tamaño total en hectáreas.


	-- 0. Realizar un analisis exploratorio de datos

select count(*) from cultivo.recogida

select * from cultivo.recogida
order by cantidad desc;


select * from cultivo.recogida
order by fecha asc;

select * from cultivo.factura
order by total asc

delete from cultivo.precio
where valor > 100

-- Queries simples

-- 1.  Obtener el total recolectado por cada cultivo en el 2023
select 
c.nombre,
sum(r.cantidad)
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
where year(r.fecha)=2023
group by c.nombre

-- 2. Listar clientes y el número de despachos que han tenido durante el 2023, ordenados por la cantidad de despachos

select 
c.nombre,
count(d.id) as conteo
from cultivo.despacho as d
	join cultivo.cliente as c
		on d.id_cliente = c.id
where year(d.fecha) = 2023
group by c.nombre
order by conteo desc

-- 3. Calcular el precio promedio de cada cultivo a lo largo del tiempo:

select 
c.nombre,
avg(p.valor) as promedio
from cultivo.m_cultivo as c
	join cultivo.precio as p
		on p.id_cultivo = c.id
group by c.nombre
order by promedio desc

-- 4. Identificar los lotes con menor rendimiento en el 2023 y ordenar por cantidad recolectada:
select 
l.nombre,
sum(r.cantidad) as "total_recogido"
from cultivo.lote as l
	join cultivo.recogida as r
		on r.id_lote = l.id
where year(r.fecha) = 2023
group by l.nombre
order by total_recogido asc

-- Queries con Having:

-- 5. Encontrar cultivos cuyo promedio de precios haya sido superior a un valor específico en el último año:
select 
c.nombre,
avg(p.valor) as promedio
from cultivo.m_cultivo as c
	join cultivo.precio as p
		on p.id_cultivo = c.id
where year(p.fecha) = 2023
group by c.nombre
having avg(p.valor) > 1

-- 6. Listar las fincas que han tenido más de 10 lotes cultivados:
select 
f.nombre,
count(l.id)
from cultivo.finca as f
	join cultivo.lote as l
		on l.id_finca = f.id
group by f.nombre
having count(l.id)>10

-- 7. Identificar los usuarios que han recogido más de 1000 unidades en total:
select
u.nombre,
sum(r.cantidad)
from cultivo.usuario as u
	join cultivo.recogida as r
		on r.id_usuario = u.id
group by u.nombre
having sum(r.cantidad)>1000

-- 8. Determinar los meses en los cuales el valor total de despachos superó 1500 unidades:
select 
year(d.fecha), 
month(d.fecha),
sum(r.cantidad)
from cultivo.despacho as d
	join cultivo.recogida as r
		on r.id_despacho = d.id
group by year(d.fecha), month(d.fecha)
having sum(r.cantidad)>80000000

-- 9. Calcular los lotes que tuvieron un ingreso proyectado mayor a 100 millones en el 2023. El ingreso proyectado se calcula como el precio multiplicado por la cantidad de producto recogido.
select 
l.nombre,
sum(r.cantidad * p.valor) as ingreso_proyectado
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.precio as p
		on p.id_cultivo = c.id
where year(r.fecha) = 2023
group by l.nombre
having sum(r.cantidad * p.valor) > 100000000
-- SubQueries:

-- 10. Listar todas las fincas que han bajaron su producción en más de 20% entre el 2022 y el 2023
with total_2022 as (
	select
	f.nombre,
	sum(r.cantidad) as total_recogido
	from cultivo.finca as f
		join cultivo.lote as l
			on l.id_finca = f.id
		join cultivo.recogida as r
			on r.id_lote = l.id
	where year(r.fecha) = 2022
	group by f.nombre
),
total_2023 as (
	select
	f.nombre,
	sum(r.cantidad) as total_recogido
	from cultivo.finca as f
		join cultivo.lote as l
			on l.id_finca = f.id
		join cultivo.recogida as r
			on r.id_lote = l.id
	where year(r.fecha) = 2023
	group by f.nombre
)
select
t2.nombre,
(t3.total_recogido - t2.total_recogido) * 100 / t2.total_recogido as cambio_porcentual
from total_2022 as t2
	join total_2023 as t3
		on t2.nombre = t3.nombre
where (t3.total_recogido - t2.total_recogido) * 100 / t2.total_recogido < -20


-- 11. Obtener el promedio de recolecciones por lote y listar aquellos lotes que superan el 
-- promedio general del cultivo de ese lote
-- Primero, necesitas calcular el promedio general de las recolecciones. 
-- Usa un join entre las tablas lote y recogida para obtener esta información. Una vez tengas 
-- el promedio general, procede a calcular el promedio de recolecciones por cada lote individualmente, 
--usando las mismas tablas. 
-- Finalmente, compara el promedio de cada lote con el promedio general y selecciona 
-- los lotes cuyo promedio supera el general. Este proceso puede ser facilitado utilizando
-- subconsultas o una CTE para mantener el promedio general 
-- accesible durante la comparación

-- método 1: con common table expressions
with promedio_general as (
select 
c.nombre as cultivo,
avg(r.cantidad) as prom_general
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
group by c.nombre
),
promedio_por_lote as (
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
group by c.nombre, f.nombre, l.nombre
)
select * from promedio_por_lote as pl
	join promedio_general as pg
		on pl.cultivo = pg.cultivo
where pl.prom_por_lote > pg.prom_general

-- método 2: queries anidados
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
prom_general.prom_general,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
	join (
	select 
		c.nombre as cultivo,
		avg(r.cantidad) as prom_general
		from cultivo.recogida as r
			join cultivo.lote as l
				on r.id_lote = l.id
			join cultivo.m_cultivo as c
				on l.id_cultivo = c.id
		group by c.nombre
	) as prom_general
		on prom_general.cultivo = c.nombre
group by c.nombre, f.nombre, l.nombre, prom_general.prom_general
having avg(r.cantidad)>prom_general.prom_general

-- subquery en el having
select 
c.nombre as cultivo, 
f.nombre as finca, 
l.nombre as lote,
avg(r.cantidad) as prom_por_lote
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
	join cultivo.finca as f
		on l.id_finca = f.id
group by c.nombre, f.nombre, l.nombre
having avg(r.cantidad) > (
		select 
		avg(r.cantidad) as prom_general
		from cultivo.recogida as r
)


-- 12. Calcular el incremento en facturación por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en facturación por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar las facturas por mes y sumar el total de facturación
-- de cada mes. Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- facturación lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

with despachos_22 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2022
group by year(d.fecha), month(d.fecha)
),
despachos_23 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2023
group by year(d.fecha), month(d.fecha)
)
select
d22.mes,
d22.cantidad_despachos as despachos_2022,
d23.cantidad_despachos as despachos_2023,
coalesce(d23.cantidad_despachos,0) - d22.cantidad_despachos as diferencia
from despachos_22 as d22
	left join despachos_23 as d23
		on d22.mes = d23.mes

-- 12. Calcular el incremento en cantidad de despachos por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en cantidad de despachos por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar la cantidad de despachos por mes y año.
-- Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- cantidad de despacho lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

-- metodo 1: con CTE (common table expressions)
with despachos_22 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2022
group by year(d.fecha), month(d.fecha)
),
despachos_23 as (
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
where year(d.fecha) = 2023
group by year(d.fecha), month(d.fecha)
)
select
d22.mes,
d22.cantidad_despachos as despachos_2022,
d23.cantidad_despachos as despachos_2023,
coalesce(d23.cantidad_despachos,0) - d22.cantidad_despachos as diferencia
from despachos_22 as d22
	left join despachos_23 as d23
		on d22.mes = d23.mes


-- metodo 2: creacion de una vista

create view cultivo.despachos_por_mes as
select 
year(d.fecha) as año,
month(d.fecha) as mes,
count(d.id) as cantidad_despachos
from cultivo.despacho as d
group by year(d.fecha), month(d.fecha);


with despachos_2022 as (
select * from cultivo.despachos_por_mes
where año = 2022
),
despachos_2023 as (
select * from cultivo.despachos_por_mes
where año = 2023
)
select 
*
from despachos_2022 as d22
	left join despachos_2023 as d23
		on d22.mes = d23.mes


-- 13. Calcular el aumento porcentual anual en el total de recogidas por cultivo entre dos años consecutivos, 
-- comparando específicamente las cantidades recolectadas en 2022 y 2023.


create view cultivo.total_recogido_por_cultivo_año as 
select 
c.nombre as cultivo,
year(r.fecha) as año,
sum(r.cantidad) as total_recogido
from cultivo.recogida as r
	join  cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
group by c.nombre, year(r.fecha);


with total_2022 as (
select * from cultivo.total_recogido_por_cultivo_año
where año = 2022
),
total_2023 as (
select * from cultivo.total_recogido_por_cultivo_año
where año = 2023
)
select 
t22.cultivo,
(t23.total_recogido - t22.total_recogido)*100/cast(t22.total_recogido as float) as cambio_porcentual
from total_2022 as t22
	join total_2023 as t23
		on t22.cultivo = t23.cultivo

-- 14. Comparar la eficiencia de las fincas en términos de ingreso por hectárea. 

-- El ingreso se calcula como la cantidad recogida multiplicado por el precio del cultivo en el mes que se dio la recogida.
-- El tamaño de la finca se puede calcular asumiendo que cada lote mide 4 hectáreas.
-- Para realizar un análisis detallado de la eficiencia de las fincas en términos de ingreso por hectárea, comienza 
-- creando una vista que 
-- determine el tamaño total de cada finca sumando el número de lotes y multiplicando por 4, ya que cada lote tiene 4 hectáreas. 
-- Posteriormente, desarrolla una vista para capturar los precios mensuales de cada cultivo, asegurando que los ingresos se 
-- calculen 
-- utilizando el precio correspondiente al mes de cada recogida. Utiliza esta vista de precios en una tercera vista que 
-- calcula el ingreso 
-- por lote, multiplicando la cantidad recolectada en cada recogida por el precio del cultivo en el mes correspondiente. 
-- Realiza un join entre la 
-- vista del tamaño de las fincas y la vista de ingresos por lote para combinar el tamaño de cada finca con los ingresos 
-- obtenidos de sus lotes, 
-- sumando los ingresos de todos los lotes que pertenecen a cada finca. Finalmente, calcula el indicador de ingreso por 
-- hectárea dividiendo el total de 
-- ingresos de cada finca por su tamaño total en hectáreas.

-- vista para calcular el tamaño de la finca
create view cultivo.tamaño_fincas as 
select 
f.nombre as finca,
count(l.id) as cantidad_lotes,
count(l.id) * 4 as tamaño
from cultivo.finca as f
	join cultivo.lote as l
		on l.id_finca = f.id
group by f.nombre;


select * from cultivo.tamaño_fincas


-- vista para calcular cuanto se recogió en cada lote en cada mes
create view cultivo.recogidas_mes_lote as
select 
year(r.fecha) as año,
month(r.fecha) as mes,
f.nombre as finca,
l.nombre as lote,
sum(r.cantidad) as total_recogido
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.finca as f
		on l.id_finca = f.id
group by 
year(r.fecha), 
month(r.fecha),
f.nombre,
l.nombre;

select * from cultivo.recogidas_mes_lote;


-- vista para calcular el precio por cada cultivo en cada mes
create view cultivo.precio_cultivo_mes as 
select 
year(p.fecha) as año,
month(p.fecha) as mes,
c.nombre as cultivo,
avg(p.valor) as precio
from cultivo.m_cultivo as c
	join cultivo.precio as p
		on p.id_cultivo = c.id
group by year(p.fecha), month(p.fecha), c.nombre;

select * from cultivo.precio_cultivo_mes;


-- ingreso por lote por mes
create view cultivo.ingreso_lote_mes as 
with recogidas_mes as (
select 
rml.año,
rml.mes,
rml.lote,
rml.finca,
rml.total_recogido,
l.id_cultivo as id_cultivo
from cultivo.recogidas_mes_lote as rml
	join cultivo.finca as f
		on rml.finca = f.nombre
	join cultivo.lote as l
		on rml.lote = l.nombre and l.id_finca = f.id
),
precios_mes as (
select
pcm.año,
pcm.mes,
pcm.precio,
c.id
from cultivo.precio_cultivo_mes as pcm
	join cultivo.m_cultivo as c
		on pcm.cultivo = c.nombre
)
select
rm.año,
rm.mes,
rm.finca,
rm.lote,
rm.total_recogido * pm.precio as ingreso
from recogidas_mes as rm
	join precios_mes as pm
		on rm.año = pm.año and rm.mes = pm.mes and rm.id_cultivo = pm.id;


-- calcular total de ingreso por finca
with ingreso_total as (
select 
ilm.finca,
sum(ilm.ingreso) as ingreso_total
from cultivo.ingreso_lote_mes as ilm
group by ilm.finca
)
select 
it.finca,
it.ingreso_total / tm.tamaño as ingreso_por_hectarea
from ingreso_total it
	join cultivo.tamaño_fincas as tm
	 on it.finca = tm.finca



--  calcular la cantidad acumulada de palma recogida por mes en un lote especifico
  select
  l.nombre,
  year(r.fecha) as año,
  month(r.fecha) as mes,
  sum(r.cantidad) as total,
  sum(sum(r.cantidad)) over (partition by l.nombre order by year(r.fecha), month(r.fecha)) as total_acumulado
from cultivo.lote as l
  join cultivo.recogida as r
    on r.id_lote = l.id
  join cultivo.finca as f
    on l.id_finca = f.id
where l.nombre = 'Lote10' and f.nombre = 'La Ilusión'
group by year(r.fecha), month(r.fecha), l.nombre
order by año, mes;


-- calcular las 3 recogidas mas grandes de cada lote
with ranking as (
select
l.id,
f.nombre as finca,
l.nombre as lote,
r.fecha as fecha,
r.cantidad,
row_number() over (partition by l.id order by r.cantidad desc) as rango
from cultivo.lote as l
	join cultivo.recogida as r
		on r.id_lote = l.id
	join cultivo.finca as f
		on l.id_finca = f.id
) select
r.finca,
r.lote,
r.cantidad,
r.fecha,
r.rango
from ranking as r where rango <= 3
order by r.finca, r.lote


select
f.nombre as finca,
l.nombre as lote,
r.fecha as fecha,
r.cantidad,
avg(r.cantidad) over (partition by l.id) as promedio_lote
from cultivo.lote as l
	join cultivo.recogida as r
		on r.id_lote = l.id
	join cultivo.finca as f
		on l.id_finca = f.id


-- Porcentaje de la contribución de cada recogida al total anual por cultivo
select 
c.nombre as cultivo,
r.fecha,
r.cantidad,
sum(r.cantidad) over (partition by year(r.fecha), c.id) as total_anual
from cultivo.recogida as r
	join cultivo.lote as l
		on r.id_lote = l.id
	join cultivo.m_cultivo as c
		on l.id_cultivo = c.id
