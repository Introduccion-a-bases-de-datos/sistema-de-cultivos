-- 0. Realizar un analisis exploratorio de datos

select * from cultivo_extendido.m_cultivo mc

select 
f.nombre as finca,
l.nombre as lote,
c.nombre as cultivo
from finca f
	join lote l 
		on l.id_finca = f.id
	join m_cultivo c
		on l.id_cultivo = c.id 
order by finca asc, lote asc
	

select 
c.nombre as cultivo,
p.fecha,
p.valor 
from m_cultivo c
	join precio p
		on p.id_cultivo = c.id
order by cultivo, fecha

select count(*) from despacho d

select count(*) from recogida r


select distinct
c.nombre as cliente,
count(f.id)
from factura f
	join despacho d
		on d.id_factura = f.id
	join cliente c
		on d.id_cliente = c.id
group by c.nombre


select 
u.nombre,
count(r.id),
sum(r.cantidad)
from usuario u
	join recogida r
		on r.id_usuario = u.id
group by u.nombre

-- lista de comandos en SQL

-- select
-- from
-- join
-- where
-- group by -> sum, avg, count, max, min
-- having
-- order by 
-- limit

-- 1. Encontrar cultivos cuyo promedio de precios haya sido superior a un dolar en el 2023:
select
c.nombre,
avg(p.valor)
from m_cultivo c
	join precio p
		on p.id_cultivo = c.id
where 
extract(year from p.fecha) = 2023
group by c.nombre
having avg(p.valor) > 1


-- 2. Listar las fincas que han tenido más de 10 lotes cultivados:
select
f.nombre,
count(l.id)
from finca f
	join lote l
		on l.id_finca = f.id
group by f.nombre
having count(l.id)>10

-- 3. Identificar los usuarios que han recogido más de 1000 unidades en total:
select
u.nombre,
sum(r.cantidad)
from usuario u
	join recogida r
		on r.id_usuario = u.id
group by u.nombre 
having sum(r.cantidad)>1000

-- 4. Determinar los meses en los cuales la cantidad despachada superó 8000000 de unidades:
select 
extract(year from d.fecha) as año, 
extract(month from d.fecha) as mes,
sum(r.cantidad) as total
from despacho d
	join recogida r
		on r.id_despacho = d.id
group by extract(year from d.fecha), 
extract(month from d.fecha)
having sum(r.cantidad) > 8000000

-- 5. Calcular los lotes que tuvieron un ingreso proyectado mayor a 100 millones en el 2023. 
-- El ingreso proyectado se calcula como el precio multiplicado por la cantidad de producto recogido.
select 
f.nombre, 
l.nombre,
sum(r.cantidad  * p.valor)
from lote l
	join finca f
		on l.id_finca = f.id
	join recogida r
		on r.id_lote = l.id
	join m_cultivo c
		on l.id_cultivo  = c.id
	join precio p
		on p.id_cultivo = c.id
where extract(year from r.fecha) = 2023
group by f.nombre, l.nombre
having sum(r.cantidad  * p.valor) > 100000000

-- 6. Listar todas las fincas que han bajado su producción en más de 20% entre el 2022 y el 2023


-- opcion 1: query en el CTE
with produccion_2022 as (
	select
	f.nombre as finca,
	sum(r.cantidad) as total
	from finca f
		join lote l
			on l.id_finca  = f.id
		join recogida r 
			on r.id_lote = l.id
	where extract(year from r.fecha) = 2022
	group by f.nombre
),
produccion_2023 as (
	select
	f.nombre as finca,
	sum(r.cantidad) as total
	from finca f
		join lote l
			on l.id_finca  = f.id
		join recogida r 
			on r.id_lote = l.id
	where extract(year from r.fecha) = 2023
	group by f.nombre
)
select 
p22.finca,
(p23.total - p22.total) * 100 / p22.total as cambio_porcentual
from produccion_2022 as p22
	join produccion_2023 as p23
		on p22.finca = p23.finca
where (p23.total - p22.total) * 100 / p22.total < -20


-- metodo 2: usando vistas y CTE
create view produccion_anual as
select
f.nombre as finca,
extract(year from r.fecha) as año,
sum(r.cantidad) as total
from finca f
	join lote l
		on l.id_finca  = f.id
	join recogida r 
		on r.id_lote = l.id
group by f.nombre, extract(year from r.fecha)
order by finca, año


with produccion_2022 as (
	select * from produccion_anual pa 
	where año = 2022
),
produccion_2023 as (
	select * from produccion_anual pa 
	where año = 2023
)
select 
p22.finca,
(p23.total - p22.total) * 100 / p22.total as cambio_porcentual
from produccion_2022 as p22
	join produccion_2023 as p23
		on p22.finca = p23.finca
where (p23.total - p22.total) * 100 / p22.total < -20




-- 7. Obtener el promedio de recolecciones por lote y listar aquellos lotes que superan el 
-- promedio general del cultivo de ese lote
-- Primero, necesitas calcular el promedio general de las recolecciones. 
-- Usa un join entre las tablas lote y recogida para obtener esta información. Una vez tengas 
-- el promedio general, procede a calcular el promedio de recolecciones por cada lote individualmente, 
--usando las mismas tablas. 
-- Finalmente, compara el promedio de cada lote con el promedio general y selecciona 
-- los lotes cuyo promedio supera el general. Este proceso puede ser facilitado utilizando
-- subconsultas o una CTE para mantener el promedio general 
-- accesible durante la comparación

create view promedio_general_cultivo as
select
c.nombre as cultivo,
avg(r.cantidad)
from m_cultivo as c
	join lote l
		on l.id_cultivo  = c.id
	join recogida r 
		on r.id_lote = l.id
group by c.nombre

create view promedio_lote as
select 
f.nombre as finca,
l.nombre as lote,
avg(r.cantidad)
from lote l
	join recogida r
		on r.id_lote = l.id
	join finca f 
		on l.id_finca = f.id
group by f.nombre, l.nombre



select * from promedio_general_cultivo

select * from promedio_lote

with cultivo_finca_lote as (
	select
	c.nombre as cultivo,
	f.nombre  as finca,
	l.nombre as lote
	from lote l
		join m_cultivo c
			on l.id_cultivo = c.id
		join finca f 
			on l.id_finca = f.id
	)
select
cfl.cultivo,
cfl.finca,
cfl.lote,
pgc.avg as prom_general,
pl.avg as prom_lote,
pgc.avg - pl.avg as diferencia
from cultivo_finca_lote as cfl
	join promedio_general_cultivo as pgc
		on cfl.cultivo = pgc.cultivo
	join promedio_lote as pl
		on cfl.finca = pl.finca and cfl.lote = pl.lote
where pgc.avg - pl.avg < 0

-- 8. Calcular el incremento en facturación por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en facturación por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar las facturas por mes y sumar el total de facturación
-- de cada mes. Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- facturación lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

-- crear vista de facturacion_mensual
create view facturacion_mensual as
select
extract(year from f.fecha) as año,
extract (month from f.fecha) as mes,
sum(f.total)
from factura f
group by extract(year from f.fecha), extract(month from f.fecha)

select * from facturacion_mensual

with facturacion_22 as (
	select * from facturacion_mensual
	where año = 2022
),
facturacion_23 as (
	select * from facturacion_mensual
	where año = 2023
)
select 
f22.mes,
f22.sum,
coalesce(f23.sum,0),
f22.sum - coalesce(f23.sum,0) as diferencia
from facturacion_22 as f22
	left join facturacion_23 as f23
		on f22.mes = f23.mes



-- 9. Calcular el incremento en cantidad de despachos por cada mes entre el 2022 y el 2023.
-- Para calcular el incremento en cantidad de despachos por cada mes entre los años 2022 y 2023 
-- utilizando Common Table Expressions (CTEs), primero debes estructurar dos CTEs separadas, 
-- una para cada año. Cada CTE deberá agrupar la cantidad de despachos por mes y año.
-- Luego, una vez que tienes estas dos tablas temporales de resultados para 2022 y 
-- 2023, debes hacer un join usando el mes como llave. Esto te permitirá tener los totales de 
-- cantidad de despacho lado a lado para cada mes de ambos años en una única consulta. 
-- El siguiente paso es calcular la diferencia entre los dos totales para cada mes, 
-- lo que te dará el incremento o decremento en la facturación mes a mes.

create view despachos_por_mes as
select
extract (year from d.fecha) as año,
extract (month from d.fecha) as mes,
count(d.id) as cantidad_despachos
from despacho d
group by extract(year from d.fecha), extract(month from d.fecha)
order by año, mes


with despachos_22 as (
	select * from despachos_por_mes
	where año = 2022
),
despachos_23 as (
	select * from despachos_por_mes
	where año = 2023
)
select 
d22.mes,
d22.cantidad_despachos as despachos_22,
coalesce(d23.cantidad_despachos,0) as despachos_23,
coalesce(d23.cantidad_despachos,0) - d22.cantidad_despachos as diferencia
from despachos_22 as d22
	left join despachos_23 as d23
		on d22.mes = d23.mes
	
		
-- 10. Calcular el aumento porcentual anual en el total de recogidas por cultivo entre dos años consecutivos, 
-- comparando específicamente las cantidades recolectadas en 2022 y 2023.

		
-- 
with total_cultivo_22 as (
	select 
	c.nombre,
	sum(r.cantidad) as total
	from recogida r
		join lote l 
			on r.id_lote = l.id
		join finca f 
			on l.id_finca = f.id
		join m_cultivo c
			on l.id_cultivo = c.id
	where extract(year from r.fecha) = 2022
	group by c.nombre
),
total_cultivo_23 as (
	select 
	c.nombre,
	sum(r.cantidad) as total
	from recogida r
		join lote l 
			on r.id_lote = l.id
		join finca f 
			on l.id_finca = f.id
		join m_cultivo c
			on l.id_cultivo = c.id
	where extract(year from r.fecha) = 2023
	group by c.nombre
)
select 
c22.nombre,
(c23.total - c22.total) * 100 / c22.total as diferencia
from total_cultivo_22 as c22
	join total_cultivo_23 as c23
		on c22.nombre = c23.nombre

-- usando vistas
create view total_cultivado_año as
select 
c.nombre,
extract(year from r.fecha) as año,
sum(r.cantidad) as total
from recogida r
	join lote l 
		on r.id_lote = l.id
	join finca f 
		on l.id_finca = f.id
	join m_cultivo c
		on l.id_cultivo = c.id
group by extract(year from r.fecha), c.nombre


with total_22 as (
	select * from total_cultivado_año
	where año = 2022
),
total_23 as (
	select * from total_cultivado_año
	where año = 2023
)
select
t22.nombre,
(t23.total - t22.total) * 100 / t22.total as diferencia
from total_22 t22
	join total_23 t23
		on t22.nombre = t23.nombre


-- 11. calcular las 3 recogidas mas grandes de cada lote
		
		
-- 12. Porcentaje de la contribución de cada recogida al total anual por cultivo
		
-- 13. Calcular el porcentaje de contribución de cada finca a la producción total por año
		
-- 14. Obtener el puesto de cada usuario según la cantidad total de recogida que ha realizado
		
-- 15. Obtener la cantidad de recogida de cada lote y su posición relativa dentro de la finca
