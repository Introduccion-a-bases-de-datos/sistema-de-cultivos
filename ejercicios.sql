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

-- 7. Identificar los usuarios que han recogido más de 1000 unidades en total:

-- 8. Determinar los meses en los cuales el valor total de despachos superó 1500 unidades:


-- SubQueries:

-- 9. Listar los clientes que han hecho pedidos en cada uno de los últimos tres meses:

-- 10. Obtener el promedio de recolecciones por lote y listar aquellos lotes que superan el promedio general

-- 11. Determinar el cultivo más rentable basado en el precio promedio multiplicado por la cantidad recolectada

-- 12. Comparar el total facturado en despachos por cada cliente en los últimos 12 meses versus el año anterior

