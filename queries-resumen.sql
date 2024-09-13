-- CRUD

-- Query de lectura (R): Lectura básica de columnas específicas
select
nombre,
id
from cultivo.cliente;

-- Query de creación (C): Inserción múltiple de registros en una tabla
insert into
cultivo.cliente (id, nombre)
values
('prueba insert2', 'Daniel'),
('prueba insert3', 'Daniel'),
('prueba insert4', 'Daniel');

-- Inserción de un solo registro en otra tabla
insert into cultivo.factura (id, fecha, total)
values
('id prueba', '2023-01-20', 150);

-- Query de actualización (U): Actualización de un campo en función de una condición
update cultivo.cliente
set nombre = 'prueba 1'
where id = 'prueba insert';

-- Query de eliminación (D): Eliminación de registros según condición
delete from cultivo.cliente
where id = 'prueba insert4';

-- JOIN simple: Unión de tablas por llave foránea (foreign key)
select
f.nombre,
l.nombre,
c.nombre,
p.valor,
p.fecha
from cultivo.finca as f
    join cultivo.lote as l on l.id_finca = f.id
    join cultivo.m_cultivo as c on l.id_cultivo = c.id
    join cultivo.precio as p on p.id_cultivo = c.id;

-- Funciones de agregación: Promedio y agrupación por un campo
select 
c.nombre,
avg(p.valor)
from cultivo.m_cultivo as c
    join cultivo.precio as p on p.id_cultivo = c.id
where c.nombre = 'algodón'
group by c.nombre;

-- Filtrado por año: Uso de la función year() en el filtro de fecha
select 
c.nombre,
avg(p.valor)
from cultivo.m_cultivo as c
    join cultivo.precio as p on p.id_cultivo = c.id
where year(p.fecha) = 2022
group by c.nombre;

-- Filtrado por valor: Filtrado de registros según una condición numérica
select 
c.nombre,
avg(p.valor)
from cultivo.m_cultivo as c
    join cultivo.precio as p on p.id_cultivo = c.id
where p.valor > 1
group by c.nombre;

-- Filtro con IN: Filtrado de registros usando una lista de valores
select 
u.nombre,
r.fecha,
r.cantidad
from cultivo.recogida as r
    join cultivo.usuario as u on r.id_usuario = u.id
where u.nombre in ('Gabriela Herrera', 'Valentina Herrera');

-- Uso de LIKE: Búsqueda con patrón utilizando el operador like
select nombre from cultivo.usuario as u
where u.nombre like '%Herrera%';

-- Subconsulta en WHERE: Filtrado de registros usando una subconsulta
select 
u.nombre,
r.fecha,
r.cantidad
from cultivo.recogida as r
    join cultivo.usuario as u on r.id_usuario = u.id
where u.nombre in (
    select nombre from cultivo.usuario as u
    where u.nombre like '%Herrera%'
);

-- Subconsulta en FROM: Subconsulta para filtrar y renombrar temporalmente resultados
select 
familia_herrera.nombre,
r.fecha,
r.cantidad
from cultivo.recogida as r
    join (
        select * from cultivo.usuario as u
        where u.nombre like '%Herrera%'
    ) as familia_herrera
    on familia_herrera.id = r.id_usuario;

-- Common Table Expression (CTE): Uso de una CTE para simplificar la query
with familia_herrera as (
    select * from cultivo.usuario as u
    where u.nombre like '%Herrera%'
)
select
fh.nombre,
r.cantidad,
r.fecha
from familia_herrera as fh
    join cultivo.recogida as r on r.id_usuario = fh.id;

-- HAVING: Filtrado de resultados agregados
select
c.nombre,
sum(f.total) as total_facturado
from cultivo.despacho as d
    join cultivo.cliente as c on d.id_cliente = c.id
    join cultivo.factura as f on d.id_factura = f.id
group by c.nombre
having sum(f.total) > 100000000000;

-- Creación de vistas: Definición de una vista para consultas repetidas
create view cultivo.facturacion_total_cliente as
select
c.nombre,
sum(f.total) as total_facturado
from cultivo.despacho as d
    join cultivo.cliente as c on d.id_cliente = c.id
    join cultivo.factura as f on d.id_factura = f.id
group by c.nombre;

-- Consulta a una vista: Búsqueda en una vista previamente creada
select * from cultivo.facturacion_total_cliente
where total_facturado > 100000000000;

-- CTE y particiones: Uso de CTE combinado con agregación y función analítica
with comparativo_recogida_vs_promedio_lote as (
    select 
    f.nombre as finca,
    l.nombre as lote,
    u.nombre as usuario,
    r.id,
    r.fecha,
    r.cantidad,
    avg(r.cantidad) over (partition by l.nombre) as promedio_lote,
    r.cantidad - avg(r.cantidad) over (partition by l.nombre) as diferencia
    from cultivo.recogida as r
        join cultivo.lote as l on r.id_lote = l.id
        join cultivo.finca as f on l.id_finca = f.id
        join cultivo.usuario as u on r.id_usuario = u.id
    where f.nombre = 'La Esperanza'
)
select 
c.usuario,
count(c.id)
from comparativo_recogida_vs_promedio_lote as c
where c.diferencia > 0
group by c.usuario
having count(c.id) > 1100
order by count(c.id) desc;
