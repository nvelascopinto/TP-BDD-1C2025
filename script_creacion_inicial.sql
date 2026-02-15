USE [GD1C2025]
GO

CREATE SCHEMA [CNEJ]
GO

/****************************** CREACION DE TABLAS *****************************************/

------------------ TABLAS MAESTRAS (SIN DEPENDENCIAS) --------------------------

CREATE TABLE CNEJ.Provincia (
    pro_nombre NVARCHAR(255),
    pro_numero BIGINT,
    PRIMARY KEY(pro_numero)
);

CREATE TABLE CNEJ.Localidad (
    loc_nombre NVARCHAR(255),
    loc_numero BIGINT,
    PRIMARY KEY(loc_numero)
);

CREATE TABLE CNEJ.Material (
    mat_numero BIGINT,
    mat_tipo NVARCHAR(255),
    mat_nombre NVARCHAR(255),
    mat_descripcion NVARCHAR(255),
    mat_precio DECIMAL(18, 2),
    PRIMARY KEY(mat_numero)
);

CREATE TABLE CNEJ.Modelo (
    mod_numero BIGINT,
    mod_tipo NVARCHAR(255),
    mod_descripcion NVARCHAR(255),
    mod_precio DECIMAL(18, 2),
    PRIMARY KEY(mod_numero)
);

CREATE TABLE CNEJ.Medida (
    med_numero BIGINT,
    med_alto decimal(18, 2),
    med_ancho decimal(18, 2),
    med_profundidad decimal(18, 2),
    med_precio decimal(18, 2),
    PRIMARY KEY (med_numero)     
);

CREATE TABLE CNEJ.Contacto (
    con_numero BIGINT,
    con_mail NVARCHAR(255),
    con_telefono NVARCHAR(255),
    PRIMARY KEY(con_numero)
);

---------------- TABLAS QUE SOLO REFERENCIAN MAESTRAS -------------------

CREATE TABLE CNEJ.Sillon (
    sil_numero BIGINT,
    sil_material BIGINT,
    sil_modelo BIGINT,
    sil_medida BIGINT,
    PRIMARY KEY (sil_numero),
    FOREIGN KEY (sil_material) REFERENCES CNEJ.Material(mat_numero),
    FOREIGN KEY (sil_modelo) REFERENCES CNEJ.Modelo(mod_numero),
    FOREIGN KEY (sil_medida) REFERENCES CNEJ.Medida(med_numero)
);

CREATE TABLE CNEJ.Cliente (
    cli_dni BIGINT,
    cli_provincia BIGINT,
    cli_localidad BIGINT,
    cli_contacto BIGINT,
    cli_nombre NVARCHAR(255),
    cli_apellido NVARCHAR(255),
    cli_fecha_nac DATETIME2(6),
    cli_direccion NVARCHAR(255),
    PRIMARY KEY(cli_dni),
    FOREIGN KEY(cli_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY(cli_localidad) REFERENCES CNEJ.Localidad(loc_numero),
    FOREIGN KEY(cli_contacto) REFERENCES CNEJ.Contacto(con_numero)
);

CREATE TABLE CNEJ.Sucursal (
    suc_numero BIGINT,
    suc_provincia BIGINT,
    suc_localidad BIGINT,
    suc_contacto BIGINT,
    suc_direccion NVARCHAR(255),
    PRIMARY KEY(suc_numero),
    FOREIGN KEY(suc_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY(suc_localidad) REFERENCES CNEJ.Localidad(loc_numero),
    FOREIGN KEY(suc_contacto) REFERENCES CNEJ.Contacto(con_numero)
);

--------------------------------------------------------------------------

CREATE TABLE CNEJ.Pedido (
    ped_numero DECIMAL(18, 0),
    ped_sucursal BIGINT,
    ped_cliente BIGINT,
    ped_fecha DATETIME2(6),
    ped_estado NVARCHAR(255),
    ped_total DECIMAL(18, 2),
    PRIMARY KEY(ped_numero),
    FOREIGN KEY(ped_sucursal) REFERENCES CNEJ.Sucursal(suc_numero),
    FOREIGN KEY(ped_cliente) REFERENCES CNEJ.Cliente(cli_dni)
);

CREATE TABLE CNEJ.Detalle_Pedido (
    det_ped_numero BIGINT,
    sil_numero BIGINT,
    ped_numero DECIMAL(18,0),
    det_ped_cantidad BIGINT,
    det_ped_precio DECIMAL(18,2),
    det_ped_subtotal DECIMAL(18,2),
    PRIMARY KEY(det_ped_numero),
    FOREIGN KEY (sil_numero) REFERENCES CNEJ.Sillon(sil_numero),
    FOREIGN KEY (ped_numero) REFERENCES CNEJ.Pedido(ped_numero)
);

CREATE TABLE CNEJ.Factura (
    fac_numero BIGINT,
    fac_sucursal BIGINT,
    fac_cliente BIGINT,
    fac_fecha DATETIME2(6),
    fac_total DECIMAL(18, 2),
    PRIMARY KEY (fac_numero),
    FOREIGN KEY (fac_sucursal) REFERENCES CNEJ.Sucursal(suc_numero),
    FOREIGN KEY (fac_cliente) REFERENCES CNEJ.Cliente(cli_dni)
);

CREATE TABLE CNEJ.Detalle_Factura (
    det_fac_numero BIGINT,
    det_fac_det_pedido BIGINT,
    det_fac_precio DECIMAL(18, 2),
    det_fac_cantidad DECIMAL(18, 0),
    det_fac_subtotal DECIMAL(18, 2),
    det_fac_fac_num BIGINT,
    PRIMARY KEY(det_fac_numero),
    FOREIGN KEY (det_fac_det_pedido) REFERENCES CNEJ.Detalle_Pedido(det_ped_numero),
    FOREIGN KEY (det_fac_fac_num) REFERENCES CNEJ.Factura(fac_numero)
);

CREATE TABLE CNEJ.Cancelacion (
    ped_canc_numero BIGINT,
    can_pedido DECIMAL(18, 0),
    can_fecha DATETIME2(6),
    can_motivo NVARCHAR(255),
    PRIMARY KEY(ped_canc_numero),
    FOREIGN KEY(can_pedido) REFERENCES CNEJ.Pedido(ped_numero)
);

CREATE TABLE CNEJ.Envio (
    env_numero DECIMAL(18, 0),
    env_factura BIGINT,
    env_fecha_programada DATETIME2(6),
    env_fecha_real DATETIME2(6),
    env_importe_traslado DECIMAL(18, 2),
    env_importe_subida DECIMAL(18, 2),
    env_total DECIMAL(18, 2),
    PRIMARY KEY(env_numero),
    FOREIGN KEY (env_factura) REFERENCES CNEJ.Factura(fac_numero)
);

CREATE TABLE CNEJ.Proveedor (
    pro_cuit NVARCHAR(255),
    pro_contacto BIGINT,
    pro_provincia BIGINT,
    pro_localidad BIGINT,
    pro_razon_social NVARCHAR(255),
    pro_direccion NVARCHAR(255),
    PRIMARY KEY(pro_cuit),
    FOREIGN KEY (pro_contacto) REFERENCES CNEJ.Contacto(con_numero),
    FOREIGN KEY (pro_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY (pro_localidad) REFERENCES CNEJ.Localidad(loc_numero)
);

CREATE TABLE CNEJ.Compra (
    com_numero DECIMAL(18, 0),
    com_proveedor NVARCHAR(255),
    com_fecha DATETIME2(6),
    com_sucursal BIGINT,
    com_total DECIMAL(18, 2),
    PRIMARY KEY(com_numero),
    FOREIGN KEY(com_proveedor) REFERENCES CNEJ.Proveedor(pro_cuit),
    FOREIGN KEY(com_sucursal) REFERENCES CNEJ.Sucursal(suc_numero)
);

CREATE TABLE CNEJ.Detalle_Compra (
    det_com_numero BIGINT,
    mat_numero BIGINT,
    com_numero DECIMAL(18, 0),
    det_com_precio DECIMAL(18, 2),
    det_com_cantidad DECIMAL(18, 0),
    det_com_subtotal DECIMAL(18, 2),
    PRIMARY KEY (det_com_numero),
    FOREIGN KEY (mat_numero) REFERENCES CNEJ.Material(mat_numero),
    FOREIGN KEY (com_numero) REFERENCES CNEJ.Compra(com_numero)
);

CREATE TABLE CNEJ.Madera (
    mad_numero BIGINT,
    mad_material BIGINT,
    mad_color NVARCHAR(255),
    mad_dureza NVARCHAR(255),
    PRIMARY KEY (mad_numero),
    FOREIGN KEY (mad_material) REFERENCES CNEJ.Material(mat_numero)
);

CREATE TABLE CNEJ.Tela (
    tel_numero BIGINT,
    tel_material BIGINT,
    tel_color NVARCHAR(255),
    tel_textura NVARCHAR(255),
    PRIMARY KEY (tel_numero),
    FOREIGN KEY (tel_material) REFERENCES CNEJ.Material(mat_numero)
);

CREATE TABLE CNEJ.Relleno (
    rel_numero BIGINT,
    rel_material BIGINT,
    rel_densidad DECIMAL(38, 2),
    PRIMARY KEY(rel_numero),
    FOREIGN KEY (rel_material) REFERENCES CNEJ.Material(mat_numero)
);

/****************************** MIGRACION DE DATOS *****************************************/

USE [GD1C2025];
GO

EXEC sp_MSforeachtable 
    @command1 = '
        IF ''?'' LIKE ''%CNEJ.%''  
            ALTER TABLE ? NOCHECK CONSTRAINT ALL
    ';
GO

CREATE PROCEDURE sp_Migrar_Dimensiones AS
BEGIN
SET NOCOUNT ON;

;WITH CTE_Contactos AS (
    SELECT DISTINCT
        Cliente_Telefono   AS telefono,
        Cliente_Mail       AS mail
    FROM gd_esquema.Maestra
    WHERE Cliente_Telefono IS NOT NULL

    UNION

    SELECT DISTINCT
        Sucursal_telefono  AS telefono,
        Sucursal_mail      AS mail
    FROM gd_esquema.Maestra
    WHERE Sucursal_telefono IS NOT NULL

    UNION

    SELECT DISTINCT
        Proveedor_Telefono AS telefono,
        Proveedor_Mail     AS mail
    FROM gd_esquema.Maestra
    WHERE Proveedor_Telefono IS NOT NULL
)
INSERT INTO CNEJ.Contacto (con_numero, con_telefono, con_mail)
SELECT
    ROW_NUMBER() OVER (ORDER BY telefono, mail) AS con_numero,
    telefono,
    mail
FROM CTE_Contactos;

;WITH DistinctProvincia AS (
    SELECT DISTINCT Sucursal_Provincia AS nombre
    FROM gd_esquema.Maestra
    WHERE Sucursal_Provincia IS NOT NULL

    UNION

    SELECT DISTINCT Cliente_Provincia
    FROM gd_esquema.Maestra
    WHERE Cliente_Provincia IS NOT NULL

    UNION

    SELECT DISTINCT Proveedor_Provincia
    FROM gd_esquema.Maestra
    WHERE Proveedor_Provincia IS NOT NULL
)
INSERT INTO CNEJ.Provincia (pro_numero, pro_nombre)
SELECT
    ROW_NUMBER() OVER (ORDER BY nombre) AS pro_numero,
    nombre AS pro_nombre
FROM DistinctProvincia;

;WITH DistinctLocalidad AS (
    SELECT DISTINCT Sucursal_Localidad AS nombre
    FROM gd_esquema.Maestra
    WHERE Sucursal_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT Cliente_Localidad
    FROM gd_esquema.Maestra
    WHERE Cliente_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT Proveedor_Localidad
    FROM gd_esquema.Maestra
    WHERE Proveedor_Localidad IS NOT NULL
)
INSERT INTO CNEJ.Localidad (loc_numero, loc_nombre)
SELECT
    ROW_NUMBER() OVER (ORDER BY nombre) AS loc_numero,
    nombre AS loc_nombre
FROM DistinctLocalidad;

;WITH DistinctMaterial AS (
    SELECT DISTINCT
        Material_Tipo,
        Material_Nombre,
        Material_Descripcion,
        Material_Precio
    FROM gd_esquema.Maestra
    WHERE Material_Tipo IS NOT NULL
)
INSERT INTO CNEJ.Material (mat_numero, mat_tipo, mat_nombre, mat_descripcion, mat_precio)
SELECT
    ROW_NUMBER() OVER (ORDER BY Material_Tipo, Material_Nombre) AS mat_numero,
    Material_Tipo,
    Material_Nombre,
    Material_Descripcion,
    Material_Precio
FROM DistinctMaterial;

INSERT INTO CNEJ.Modelo (mod_numero, mod_tipo, mod_descripcion, mod_precio)
SELECT DISTINCT
    CAST(Sillon_Modelo_Codigo AS BIGINT)       AS mod_numero,
    Sillon_Modelo                             AS mod_tipo,
    Sillon_Modelo_Descripcion                 AS mod_descripcion,
    Sillon_Modelo_Precio                      AS mod_precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL;

;WITH DistinctMedida AS (
    SELECT DISTINCT
        Sillon_Medida_Alto        AS med_alto,
        Sillon_Medida_Ancho       AS med_ancho,
        Sillon_Medida_Profundidad AS med_profundidad,
        Sillon_Medida_Precio      AS med_precio
    FROM gd_esquema.Maestra
    WHERE Sillon_Medida_Alto IS NOT NULL
)
INSERT INTO CNEJ.Medida (med_numero, med_alto, med_ancho, med_profundidad, med_precio)
SELECT
    ROW_NUMBER() OVER (ORDER BY med_alto, med_ancho, med_profundidad) AS med_numero,
    med_alto,
    med_ancho,
    med_profundidad,
    med_precio
FROM DistinctMedida;

END;
GO

CREATE PROCEDURE sp_Migrar_EntidadesPrimarias AS
BEGIN
SET NOCOUNT ON;
;WITH CTE_Sucursal AS (
    SELECT DISTINCT
        CAST(Sucursal_NroSucursal AS BIGINT) AS suc_numero,
        Sucursal_Provincia                  AS suc_provincia,
        Sucursal_Localidad                  AS suc_localidad,
        Sucursal_Direccion                  AS suc_direccion,
        Sucursal_telefono                   AS suc_telefono,
        Sucursal_mail                       AS suc_mail
    FROM gd_esquema.Maestra
    WHERE Sucursal_NroSucursal IS NOT NULL
)
INSERT INTO CNEJ.Sucursal
    (suc_numero, suc_provincia, suc_localidad, suc_contacto, suc_direccion)
SELECT
    S.suc_numero,
    P.pro_numero,
    L.loc_numero,
    C.con_numero,
    S.suc_direccion
FROM CTE_Sucursal AS S
    LEFT JOIN CNEJ.Provincia AS P
        ON P.pro_nombre = S.suc_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = S.suc_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = S.suc_telefono
       AND C.con_mail     = S.suc_mail;

;WITH CTE_Cliente AS (
    SELECT DISTINCT
        CAST(Cliente_Dni           AS BIGINT) AS cli_dni,
        Cliente_Provincia                    AS cli_provincia,
        Cliente_Localidad                    AS cli_localidad,
        Cliente_Direccion                    AS cli_direccion,
        Cliente_Telefono                     AS cli_telefono,
        Cliente_Mail                         AS cli_mail,
        Cliente_Nombre                       AS cli_nombre,
        Cliente_Apellido                     AS cli_apellido,
        Cliente_FechaNacimiento              AS cli_fecha_nac
    FROM gd_esquema.Maestra
    WHERE Cliente_Dni IS NOT NULL
)
INSERT INTO CNEJ.Cliente
    (cli_dni, cli_provincia, cli_localidad, cli_contacto,
     cli_nombre, cli_apellido, cli_fecha_nac, cli_direccion)
SELECT
    Cc.cli_dni,
    P.pro_numero,
    L.loc_numero,
    C.con_numero,
    Cc.cli_nombre,
    Cc.cli_apellido,
    Cc.cli_fecha_nac,
    Cc.cli_direccion
FROM CTE_Cliente AS Cc
    LEFT JOIN CNEJ.Provincia AS P
        ON P.pro_nombre = Cc.cli_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = Cc.cli_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = Cc.cli_telefono
       AND C.con_mail     = Cc.cli_mail;

;WITH CTE_SillonDistinct AS (
    SELECT
        CAST(Sillon_Codigo AS BIGINT)         AS sil_numero,
        Material_Tipo,
        Material_Nombre,
        Material_Descripcion,
        Material_Precio,
        Sillon_Modelo_Codigo                  AS sil_modelo,
        Sillon_Medida_Alto,
        Sillon_Medida_Ancho,
        Sillon_Medida_Profundidad,
        Sillon_Medida_Precio
    FROM (
        SELECT 
            Sillon_Codigo,
            Material_Tipo,
            Material_Nombre,
            Material_Descripcion,
            Material_Precio,
            Sillon_Modelo_Codigo,
            Sillon_Medida_Alto,
            Sillon_Medida_Ancho,
            Sillon_Medida_Profundidad,
            Sillon_Medida_Precio,
            ROW_NUMBER() OVER (
                PARTITION BY Sillon_Codigo
                ORDER BY Sillon_Codigo
            ) AS rn
        FROM gd_esquema.Maestra
        WHERE Sillon_Codigo IS NOT NULL
    ) AS sub
    WHERE rn = 1
)
INSERT INTO CNEJ.Sillon (sil_numero, sil_material, sil_modelo, sil_medida)
SELECT
    D.sil_numero,
    M1.mat_numero,
    CAST(D.sil_modelo AS BIGINT),
    M2.med_numero
FROM CTE_SillonDistinct AS D
    INNER JOIN CNEJ.Material AS M1
        ON M1.mat_tipo        = D.Material_Tipo
       AND M1.mat_nombre      = D.Material_Nombre
       AND M1.mat_descripcion = D.Material_Descripcion
       AND M1.mat_precio      = D.Material_Precio
    INNER JOIN CNEJ.Medida AS M2
        ON M2.med_alto        = D.Sillon_Medida_Alto
       AND M2.med_ancho       = D.Sillon_Medida_Ancho
       AND M2.med_profundidad = D.Sillon_Medida_Profundidad
       AND M2.med_precio      = D.Sillon_Medida_Precio;
END;
GO

CREATE PROCEDURE sp_Migrar_Pedidos AS
BEGIN
SET NOCOUNT ON;

INSERT INTO CNEJ.Pedido
    (ped_numero, ped_sucursal, ped_cliente, ped_fecha, ped_estado, ped_total)
SELECT DISTINCT
    CAST(Pedido_Numero AS DECIMAL(18,0))    AS ped_numero,
    CAST(Sucursal_NroSucursal AS BIGINT)     AS ped_sucursal,
    CAST(Cliente_Dni AS BIGINT)              AS ped_cliente,
    Pedido_Fecha                            AS ped_fecha,
    Pedido_Estado                           AS ped_estado,
    CAST(Pedido_Total AS DECIMAL(18,2))     AS ped_total
FROM gd_esquema.Maestra
WHERE Pedido_Numero IS NOT NULL;

;WITH CTE_DetallePedidoGen AS (
    SELECT DISTINCT
        CAST(Pedido_Numero           AS DECIMAL(18,0))  AS ped_numero,
        CAST(Sillon_Codigo           AS BIGINT)         AS sil_numero,
        CAST(Detalle_Pedido_Cantidad AS BIGINT)         AS det_pedi_cant,
        CAST(Detalle_Pedido_Precio   AS DECIMAL(18,2))  AS det_pedi_precio,
        CAST(Detalle_Pedido_SubTotal AS DECIMAL(18,2))  AS det_pedi_subt,
        ROW_NUMBER() OVER (
            ORDER BY 
                CAST(Pedido_Numero AS DECIMAL(18,0)),
                CAST(Sillon_Codigo AS BIGINT),
                CAST(Detalle_Pedido_Cantidad AS BIGINT),
                CAST(Detalle_Pedido_Precio AS DECIMAL(18,2)),
                CAST(Detalle_Pedido_SubTotal AS DECIMAL(18,2))
        ) AS det_ped_numero
    FROM gd_esquema.Maestra
    WHERE Detalle_Pedido_Cantidad IS NOT NULL
      AND Sillon_Codigo IS NOT NULL
)
INSERT INTO CNEJ.Detalle_Pedido
    (det_ped_numero, sil_numero, ped_numero, det_ped_cantidad, det_ped_precio, det_ped_subtotal)
SELECT
    D.det_ped_numero,
    D.sil_numero,
    D.ped_numero,
    D.det_pedi_cant,
    D.det_pedi_precio,
    D.det_pedi_subt
FROM CTE_DetallePedidoGen AS D;
END;
GO

CREATE PROCEDURE sp_Migrar_Facturacion AS
BEGIN
SET NOCOUNT ON;

INSERT INTO CNEJ.Factura
    (fac_numero, fac_sucursal, fac_cliente, fac_fecha, fac_total)
SELECT DISTINCT
    CAST(Factura_Numero AS BIGINT)           AS fac_numero,
    CAST(Sucursal_NroSucursal AS BIGINT)     AS fac_sucursal,
    CAST(Cliente_Dni AS BIGINT)              AS fac_cliente,
    Factura_Fecha                            AS fac_fecha,
    CAST(Factura_Total AS DECIMAL(18,2))     AS fac_total
FROM gd_esquema.Maestra
WHERE Factura_Numero IS NOT NULL;

;WITH CTE_FirstDetallePedido AS (
    SELECT 
        ped_numero,
        MIN(det_ped_numero) AS first_det_ped_numero
    FROM CNEJ.Detalle_Pedido
    GROUP BY ped_numero
)
INSERT INTO CNEJ.Detalle_Factura
    (det_fac_numero, det_fac_det_pedido, det_fac_precio, det_fac_cantidad, det_fac_subtotal, det_fac_fac_num)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY 
            CAST(M.Factura_Numero AS BIGINT),
            CAST(M.Pedido_Numero  AS DECIMAL(18,0))
    ) AS det_fac_numero,
    F.first_det_ped_numero AS det_fac_det_pedido,
    CAST(M.Detalle_Factura_Precio    AS DECIMAL(18,2))  AS det_fac_precio,
    CAST(M.Detalle_Factura_Cantidad  AS DECIMAL(18,0))  AS det_fac_cantidad,
    CAST(M.Detalle_Factura_SubTotal  AS DECIMAL(18,2))  AS det_fac_subtotal,
    CAST(M.Factura_Numero AS BIGINT) AS det_fac_fac_num
FROM gd_esquema.Maestra AS M
    INNER JOIN CTE_FirstDetallePedido AS F
        ON F.ped_numero = CAST(M.Pedido_Numero AS DECIMAL(18,0))
WHERE M.Detalle_Factura_Precio IS NOT NULL;
END;
GO

CREATE PROCEDURE sp_Migrar_Logistica AS
BEGIN
SET NOCOUNT ON;

INSERT INTO CNEJ.Cancelacion
    (ped_canc_numero, can_pedido, can_fecha, can_motivo)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Pedido_Numero, Pedido_Cancelacion_Fecha
    ) AS ped_canc_numero,
    CAST(Pedido_Numero             AS DECIMAL(18,0)) AS can_pedido,
    Pedido_Cancelacion_Fecha                         AS can_fecha,
    Pedido_Cancelacion_Motivo                        AS can_motivo
FROM gd_esquema.Maestra
WHERE Pedido_Cancelacion_Fecha IS NOT NULL;

INSERT INTO CNEJ.Envio
    (env_numero, env_factura, env_fecha_programada, env_fecha_real,
     env_importe_traslado, env_importe_subida, env_total)
SELECT DISTINCT
    CAST(Envio_Numero AS DECIMAL(18,0))                 AS env_numero,
    CAST(Factura_Numero       AS BIGINT)                 AS env_factura,
    Envio_Fecha_Programada    AS env_fecha_programada,
    Envio_Fecha               AS env_fecha_real,
    CAST(Envio_ImporteTraslado AS DECIMAL(18,2))         AS env_importe_traslado,
    CAST(Envio_ImporteSubida   AS DECIMAL(18,2))         AS env_importe_subida,
    CAST(Envio_Total           AS DECIMAL(18,2))         AS env_total
FROM gd_esquema.Maestra
WHERE Envio_Numero IS NOT NULL;
END;
GO

CREATE PROCEDURE sp_Migrar_ProveedoresCompras AS
BEGIN
SET NOCOUNT ON;

;WITH CTE_Proveedor AS (
    SELECT DISTINCT
        Proveedor_Cuit         AS pro_cuit,
        Proveedor_Provincia    AS pro_provincia,
        Proveedor_Localidad    AS pro_localidad,
        Proveedor_RazonSocial  AS pro_razon_social,
        Proveedor_Direccion    AS pro_direccion,
        Proveedor_Telefono     AS prov_telefono,
        Proveedor_Mail         AS prov_mail
    FROM gd_esquema.Maestra
    WHERE Proveedor_Cuit IS NOT NULL
)
INSERT INTO CNEJ.Proveedor
    (pro_cuit, pro_contacto, pro_provincia, pro_localidad, pro_razon_social, pro_direccion)
SELECT
    Pv.pro_cuit,
    C.con_numero,
    Pr.pro_numero,
    L.loc_numero,
    Pv.pro_razon_social,
    Pv.pro_direccion
FROM CTE_Proveedor AS Pv
    LEFT JOIN CNEJ.Provincia AS Pr
        ON Pr.pro_nombre = Pv.pro_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = Pv.pro_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = Pv.prov_telefono
       AND C.con_mail     = Pv.prov_mail;

INSERT INTO CNEJ.Compra
    (com_numero, com_proveedor, com_fecha, com_sucursal, com_total)
SELECT DISTINCT
    CAST(Compra_Numero AS DECIMAL(18,0))   AS com_numero,
    Proveedor_Cuit                         AS com_proveedor,
    Compra_Fecha                           AS com_fecha,
    CAST(Sucursal_NroSucursal AS BIGINT)    AS com_sucursal,
    CAST(Compra_Total AS DECIMAL(18,2))    AS com_total
FROM gd_esquema.Maestra
WHERE Compra_Numero IS NOT NULL;

INSERT INTO CNEJ.Detalle_Compra
    (det_com_numero, mat_numero, com_numero, det_com_precio, det_com_cantidad, det_com_subtotal)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Compra_Numero, Material_Tipo, Material_Nombre
    ) AS det_com_numero,
    M.mat_numero                                AS mat_numero,
    CAST(Compra_Numero                AS DECIMAL(18,0))  AS com_numero,
    CAST(Detalle_Compra_Precio        AS DECIMAL(18,2))  AS det_com_precio,
    CAST(Detalle_Compra_Cantidad      AS DECIMAL(18,0))  AS det_com_cantidad,
    CAST(Detalle_Compra_SubTotal      AS DECIMAL(18,2))  AS det_com_subtotal
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE Detalle_Compra_Precio IS NOT NULL;
END;
GO

CREATE PROCEDURE sp_Migrar_SubtiposMaterial AS
BEGIN
SET NOCOUNT ON;

INSERT INTO CNEJ.Madera (mad_numero, mad_material, mad_color, mad_dureza)
SELECT DISTINCT
    M.mat_numero               AS mad_numero,
    M.mat_numero               AS mad_material,
    G.Madera_Color             AS mad_color,
    G.Madera_Dureza            AS mad_dureza
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Madera_Color IS NOT NULL;

INSERT INTO CNEJ.Tela (tel_numero, tel_material, tel_color, tel_textura)
SELECT DISTINCT
    M.mat_numero               AS tel_numero,
    M.mat_numero               AS tel_material,
    G.Tela_Color               AS tel_color,
    G.Tela_Textura             AS tel_textura
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Tela_Color IS NOT NULL;

INSERT INTO CNEJ.Relleno (rel_numero, rel_material, rel_densidad)
SELECT DISTINCT
    M.mat_numero                                   AS rel_numero,
    M.mat_numero                                   AS rel_material,
    CAST(G.Relleno_Densidad AS DECIMAL(38,2))      AS rel_densidad
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Relleno_Densidad IS NOT NULL;
END;
GO

EXEC sp_Migrar_Dimensiones;
EXEC sp_Migrar_EntidadesPrimarias;
EXEC sp_Migrar_Pedidos;
EXEC sp_Migrar_Facturacion;
EXEC sp_Migrar_Logistica;
EXEC sp_Migrar_ProveedoresCompras;
EXEC sp_Migrar_SubtiposMaterial;

EXEC sp_MSforeachtable 
    @command1 = '
        IF ''?'' LIKE ''%CNEJ.%''  
            ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL
    ';
GO
