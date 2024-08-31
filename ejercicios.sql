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


-- 11. Obtener el promedio de recolecciones por lote y listar aquellos lotes que superan el promedio general
-- Primero, necesitas calcular el promedio general de las recolecciones. Usa un join entre las tablas lote y recogida para obtener esta información. Una vez tengas 
-- el promedio general, procede a calcular el promedio de recolecciones por cada lote individualmente, usando las mismas tablas. 
-- Finalmente, compara el promedio de cada lote con el promedio general y selecciona 
-- los lotes cuyo promedio supera el general. Este proceso puede ser facilitado utilizando subconsultas o una CTE para mantener el promedio general 
-- accesible durante la comparación

-- 12. Determinar el cultivo más rentable basado en el precio promedio multiplicado por la cantidad recolectada

-- 13. Comparar el total facturado en despachos por cada cliente en los últimos 12 meses versus el año anterior

