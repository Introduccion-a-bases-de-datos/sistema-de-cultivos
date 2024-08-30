CREATE SCHEMA cultivo;

-- cultivo.cliente definition

-- Drop table

-- DROP TABLE cultivo.cliente;

CREATE TABLE cultivo.cliente (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nombre nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT cliente_pkey PRIMARY KEY (id)
);


-- cultivo.factura definition

-- Drop table

-- DROP TABLE cultivo.factura;

CREATE TABLE cultivo.factura (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	fecha datetime2 NOT NULL,
	total float DEFAULT 0 NOT NULL,
	CONSTRAINT factura_pkey PRIMARY KEY (id)
);


-- cultivo.finca definition

-- Drop table

-- DROP TABLE cultivo.finca;

CREATE TABLE cultivo.finca (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nombre nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT finca_pkey PRIMARY KEY (id)
);


-- cultivo.m_cultivo definition

-- Drop table

-- DROP TABLE cultivo.m_cultivo;

CREATE TABLE cultivo.m_cultivo (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nombre nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT m_cultivo_pkey PRIMARY KEY (id)
);


-- cultivo.usuario definition

-- Drop table

-- DROP TABLE cultivo.usuario;

CREATE TABLE cultivo.usuario (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nombre nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	correo nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT usuario_correo_key UNIQUE (correo),
	CONSTRAINT usuario_pkey PRIMARY KEY (id)
);


-- cultivo.despacho definition

-- Drop table

-- DROP TABLE cultivo.despacho;

CREATE TABLE cultivo.despacho (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	fecha datetime2 NOT NULL,
	id_cliente nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	id_factura nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT despacho_pkey PRIMARY KEY (id),
	CONSTRAINT despacho_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES cultivo.cliente(id) ON UPDATE CASCADE,
	CONSTRAINT despacho_id_factura_fkey FOREIGN KEY (id_factura) REFERENCES cultivo.factura(id) ON DELETE SET NULL ON UPDATE CASCADE
);


-- cultivo.lote definition

-- Drop table

-- DROP TABLE cultivo.lote;

CREATE TABLE cultivo.lote (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	nombre nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	id_finca nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	id_cultivo nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	CONSTRAINT lote_pkey PRIMARY KEY (id),
	CONSTRAINT lote_id_cultivo_fkey FOREIGN KEY (id_cultivo) REFERENCES cultivo.m_cultivo(id) ON UPDATE CASCADE,
	CONSTRAINT lote_id_finca_fkey FOREIGN KEY (id_finca) REFERENCES cultivo.finca(id) ON UPDATE CASCADE
);


-- cultivo.precio definition

-- Drop table

-- DROP TABLE cultivo.precio;

CREATE TABLE cultivo.precio (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	id_cultivo nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	valor float NOT NULL,
	fecha datetime2 NOT NULL,
	CONSTRAINT precio_pkey PRIMARY KEY (id),
	CONSTRAINT precio_id_cultivo_fkey FOREIGN KEY (id_cultivo) REFERENCES cultivo.m_cultivo(id) ON UPDATE CASCADE
);


-- cultivo.recogida definition

-- Drop table

-- DROP TABLE cultivo.recogida;

CREATE TABLE cultivo.recogida (
	id nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	fecha datetime2 NOT NULL,
	id_lote nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	cantidad float NOT NULL,
	id_usuario nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	id_despacho nvarchar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT recogida_pkey PRIMARY KEY (id),
	CONSTRAINT recogida_id_despacho_fkey FOREIGN KEY (id_despacho) REFERENCES cultivo.despacho(id) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT recogida_id_lote_fkey FOREIGN KEY (id_lote) REFERENCES cultivo.lote(id) ON UPDATE CASCADE,
	CONSTRAINT recogida_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES cultivo.usuario(id) ON UPDATE CASCADE
);
