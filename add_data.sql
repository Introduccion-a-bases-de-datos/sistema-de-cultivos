-- insert de maestro de cultivos
insert into cultivo.m_cultivo
select * from cultivo.tmp_m_cultivos;

-- insert precios
insert into cultivo.precio
select * from cultivo.tmp_precios;

-- insert fincas
insert into cultivo.finca
select * from cultivo.tmp_fincas;

-- insert lote
insert into cultivo.lote
select * from cultivo.tmp_lotes;

-- insert cliente
insert into cultivo.cliente
select * from cultivo.tmp_clientes;

-- insert factura
insert into cultivo.factura
select * from cultivo.tmp_facturas;

-- insert usuario
insert into cultivo.usuario
select * from cultivo.tmp_usuarios;

-- insert despacho
insert into cultivo.despacho
select * from cultivo.tmp_despachos;

-- insert recogida
insert into cultivo.recogida
select * from cultivo.tmp_recogidas;
