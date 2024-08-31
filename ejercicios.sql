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

-- 3. Calcular el precio promedio de cada cultivo a lo largo del tiempo:

-- 4. Identificar los lotes con menor rendimiento en el 2023 y ordenar por cantidad recolectada:


-- Queries con Having:

-- 5. Encontrar cultivos cuyo promedio de precios haya sido superior a un valor específico en el último año:

-- 6. Listar las fincas que han tenido más de 10 lotes cultivados:

-- 7. Identificar los usuarios que han recogido más de 1000 unidades en total:

-- 8. Determinar los meses en los cuales el valor total de despachos superó 1500 unidades:


-- SubQueries:

-- 9. Listar los clientes que han hecho pedidos en cada uno de los últimos tres meses:

