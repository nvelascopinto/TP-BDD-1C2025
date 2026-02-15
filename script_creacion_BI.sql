/*  DROP TABLAS EXISTENTES (para recrear desde cero)  */
IF OBJECT_ID('CNEJ.BI_Hecho_PedFac','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_PedFac;
IF OBJECT_ID('CNEJ.BI_Hecho_VentaModelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_VentaModelo;
IF OBJECT_ID('CNEJ.BI_Hecho_Envio','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Envio;
IF OBJECT_ID('CNEJ.BI_Hecho_Facturacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Facturacion;
IF OBJECT_ID('CNEJ.BI_Hecho_Compra','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Compra;
IF OBJECT_ID('CNEJ.BI_Hecho_Pedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Pedido;

IF OBJECT_ID('CNEJ.BI_Dim_RangoEtario','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_RangoEtario;
IF OBJECT_ID('CNEJ.BI_Dim_Turno','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Turno;
IF OBJECT_ID('CNEJ.BI_Dim_EstadoPedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_EstadoPedido;
IF OBJECT_ID('CNEJ.BI_Dim_Modelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Modelo;
IF OBJECT_ID('CNEJ.BI_Dim_Material','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Material;
IF OBJECT_ID('CNEJ.BI_Dim_Sucursal','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Sucursal;
IF OBJECT_ID('CNEJ.BI_Dim_Cliente','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Cliente;
IF OBJECT_ID('CNEJ.BI_Dim_Ubicacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Ubicacion;
IF OBJECT_ID('CNEJ.BI_Dim_Tiempo','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Tiempo;
GO

IF OBJECT_ID('CNEJ.BI_Vista_LocalidadesCostoEnvio','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_LocalidadesCostoEnvio;
IF OBJECT_ID('CNEJ.BI_Vista_CumplimientoEnvios','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_CumplimientoEnvios;
IF OBJECT_ID('CNEJ.BI_Vista_ComprasTipoMaterial','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_ComprasTipoMaterial;
IF OBJECT_ID('CNEJ.BI_Vista_PromedioCompras','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_PromedioCompras;
IF OBJECT_ID('CNEJ.BI_Vista_TiempoFabricacion','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_TiempoFabricacion;
IF OBJECT_ID('CNEJ.BI_Vista_ConversionPedidos','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_ConversionPedidos;
IF OBJECT_ID('CNEJ.BI_Vista_VolumenPedidos','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_VolumenPedidos;
IF OBJECT_ID('CNEJ.BI_Vista_RendimientoModelos','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_RendimientoModelos;
IF OBJECT_ID('CNEJ.BI_Vista_FacturaPromedioMensual','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_FacturaPromedioMensual;
IF OBJECT_ID('CNEJ.BI_Vista_Ganancias','V') IS NOT NULL DROP VIEW CNEJ.BI_Vista_Ganancias;
GO

USE GD1C2025;
GO

/************************************ CREACION DE DIMENSIONES ************************************/

CREATE TABLE CNEJ.BI_Dim_Tiempo (
    TiempoKey    INT IDENTITY(1,1) PRIMARY KEY,
    Anio         INT NOT NULL,
    Cuatrimestre INT NOT NULL,
    Mes          INT NOT NULL
);

CREATE TABLE CNEJ.BI_Dim_Ubicacion (
    UbicacionKey INT IDENTITY(1,1) PRIMARY KEY,
    Provincia    NVARCHAR(255) NOT NULL,
    Localidad    NVARCHAR(255) NOT NULL
);

CREATE TABLE CNEJ.BI_Dim_Cliente (
    ClienteKey       INT IDENTITY(1,1) PRIMARY KEY,
    ClienteDni       BIGINT NOT NULL,
    FechaNacimiento  DATE NULL
);

CREATE TABLE CNEJ.BI_Dim_Sucursal (
    SucursalKey      INT IDENTITY(1,1) PRIMARY KEY,
    SucursalNumero   BIGINT NOT NULL,
    Direccion        NVARCHAR(255) NULL
);

CREATE TABLE CNEJ.BI_Dim_Material (
    MaterialKey      INT IDENTITY(1,1) PRIMARY KEY,
    MaterialNumero   BIGINT NOT NULL,
    Tipo             NVARCHAR(255) NOT NULL,
    Nombre           NVARCHAR(255) NOT NULL,
    Descripcion      NVARCHAR(255) NULL,
    Precio           DECIMAL(18,2) NULL
);

CREATE TABLE CNEJ.BI_Dim_Modelo (
    ModeloKey        INT IDENTITY(1,1) PRIMARY KEY,
    ModeloNumero     BIGINT NOT NULL,
    Tipo             NVARCHAR(255) NULL,
    Descripcion      NVARCHAR(255) NULL,
    Precio           DECIMAL(18,2) NULL
);

CREATE TABLE CNEJ.BI_Dim_EstadoPedido (
    EstadoKey        INT IDENTITY(1,1) PRIMARY KEY,
    Estado           NVARCHAR(255) NOT NULL
);

CREATE TABLE CNEJ.BI_Dim_Turno (
    TurnoKey         INT IDENTITY(1,1) PRIMARY KEY,
    Nombre           NVARCHAR(50) NOT NULL,
    HoraInicio       TIME NOT NULL,
    HoraFin          TIME NOT NULL
);

CREATE TABLE CNEJ.BI_Dim_RangoEtario (
    RangoKey         INT IDENTITY(1,1) PRIMARY KEY,
    Rango            NVARCHAR(20) NOT NULL,
	RangoMin         TINYINT NOT NULL,
	RangoMax         TINYINT NOT NULL
);
GO

/************************************ POBLACION DE DIMENSIONES ************************************/

DECLARE @minDate DATE, @maxDate DATE;
SELECT @minDate = MIN(CONVERT(date,ped_fecha)) FROM CNEJ.Pedido;
SELECT @maxDate = MAX(CONVERT(date,fac_fecha)) FROM CNEJ.Factura;
IF @minDate IS NULL SELECT @minDate = MIN(CONVERT(date,com_fecha)) FROM CNEJ.Compra;
IF @maxDate IS NULL SELECT @maxDate = MAX(CONVERT(date,env_fecha_real)) FROM CNEJ.Envio;

;WITH Calendario AS (
    SELECT @minDate AS Fecha
    UNION ALL
    SELECT DATEADD(DAY,1,Fecha)
      FROM Calendario
     WHERE Fecha < @maxDate
), DistinctMeses AS (
    SELECT DISTINCT
        YEAR(Fecha)                             AS Anio,
        ((MONTH(Fecha)-1)/4)+1                  AS Cuatrimestre,
        MONTH(Fecha)                            AS Mes
      FROM Calendario
)
INSERT INTO CNEJ.BI_Dim_Tiempo(Anio,Cuatrimestre,Mes)
SELECT Anio,Cuatrimestre,Mes
  FROM DistinctMeses
OPTION(MAXRECURSION 0);

INSERT INTO CNEJ.BI_Dim_Ubicacion(Provincia,Localidad)
SELECT DISTINCT p.pro_nombre,l.loc_nombre
  FROM CNEJ.Provincia p
 CROSS JOIN CNEJ.Localidad l
 WHERE EXISTS(
        SELECT 1
          FROM CNEJ.Sucursal s
         WHERE s.suc_provincia = p.pro_numero
           AND s.suc_localidad = l.loc_numero
       )
    OR EXISTS(
        SELECT 1
          FROM CNEJ.Cliente c
         WHERE c.cli_provincia = p.pro_numero
           AND c.cli_localidad = l.loc_numero
       );

INSERT INTO CNEJ.BI_Dim_Cliente(ClienteDni,FechaNacimiento)
SELECT DISTINCT cli_dni,CONVERT(date,cli_fecha_nac)
  FROM CNEJ.Cliente;

INSERT INTO CNEJ.BI_Dim_Sucursal(SucursalNumero,Direccion)
SELECT DISTINCT suc_numero,suc_direccion
  FROM CNEJ.Sucursal;

INSERT INTO CNEJ.BI_Dim_Material(MaterialNumero,Tipo,Nombre,Descripcion,Precio)
SELECT DISTINCT mat_numero,mat_tipo,mat_nombre,mat_descripcion,mat_precio
  FROM CNEJ.Material;

INSERT INTO CNEJ.BI_Dim_Modelo(ModeloNumero,Tipo,Descripcion,Precio)
SELECT DISTINCT mod_numero,mod_tipo,mod_descripcion,mod_precio
  FROM CNEJ.Modelo;

INSERT INTO CNEJ.BI_Dim_EstadoPedido(Estado)
SELECT DISTINCT ped_estado
  FROM CNEJ.Pedido;

INSERT INTO CNEJ.BI_Dim_Turno(Nombre,HoraInicio,HoraFin)
VALUES ('08:00-14:00','08:00','14:00'),
       ('14:00-20:00','14:00','20:00');

INSERT INTO CNEJ.BI_Dim_RangoEtario(Rango, RangoMin, RangoMax)
VALUES ('<25', 0, 24),('25-35', 25, 34),('35-50', 35, 49),('>50', 50, 100);
GO

/************************************ CREACION DE TABLAS DE HECHOS ************************************/

CREATE TABLE CNEJ.BI_Hecho_Pedido (
    TiempoKey     INT      NOT NULL,
    SucursalKey   INT      NOT NULL,
    ClienteKey    INT      NOT NULL,
    EstadoKey     INT      NOT NULL,
    TurnoKey      INT      NOT NULL,
    RangoKey      INT      NOT NULL,
    UbicacionKey  INT      NOT NULL,
    TotalPedidos  BIGINT   NOT NULL,
    TotalMontos   DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Pedido PRIMARY KEY (
      TiempoKey,SucursalKey,ClienteKey,
      EstadoKey,TurnoKey,RangoKey,UbicacionKey
    ),
    FOREIGN KEY (TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (SucursalKey)  REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY (ClienteKey)   REFERENCES CNEJ.BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY (EstadoKey)    REFERENCES CNEJ.BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY (TurnoKey)     REFERENCES CNEJ.BI_Dim_Turno(TurnoKey),
    FOREIGN KEY (RangoKey)     REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey),
    FOREIGN KEY (UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey)
);

CREATE TABLE CNEJ.BI_Hecho_Compra (
    TiempoKey     INT      NOT NULL,
    SucursalKey   INT      NOT NULL,
    MaterialKey   INT      NOT NULL,
    TotalCompra   DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Compra PRIMARY KEY (
      TiempoKey,SucursalKey,MaterialKey
    ),
    FOREIGN KEY (TiempoKey)   REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (SucursalKey) REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY (MaterialKey) REFERENCES CNEJ.BI_Dim_Material(MaterialKey)
);

CREATE TABLE CNEJ.BI_Hecho_Facturacion (
    TiempoKey     INT      NOT NULL,
    SucursalKey   INT      NOT NULL,
    ClienteKey    INT      NOT NULL,
    EstadoKey     INT      NOT NULL,
    TurnoKey      INT      NOT NULL,
    RangoKey      INT      NOT NULL,
    UbicacionKey  INT      NOT NULL,
    TotalFacturas BIGINT   NOT NULL,
    TotalMontos   DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Facturacion PRIMARY KEY (
      TiempoKey,SucursalKey,ClienteKey,
      EstadoKey,TurnoKey,RangoKey,UbicacionKey
    ),
    FOREIGN KEY (TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (SucursalKey)  REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY (ClienteKey)   REFERENCES CNEJ.BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY (EstadoKey)    REFERENCES CNEJ.BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY (TurnoKey)     REFERENCES CNEJ.BI_Dim_Turno(TurnoKey),
    FOREIGN KEY (RangoKey)     REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey),
    FOREIGN KEY (UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey)
);

CREATE TABLE CNEJ.BI_Hecho_VentaModelo (
    TiempoKey       INT      NOT NULL,
    UbicacionKey    INT      NOT NULL,
    RangoKey        INT      NOT NULL,
    ModeloKey       INT      NOT NULL,
    CantidadVendida BIGINT   NOT NULL,
    CONSTRAINT PK_Hecho_VentaModelo PRIMARY KEY (
      TiempoKey,UbicacionKey,RangoKey,ModeloKey
    ),
    FOREIGN KEY (TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY (RangoKey)     REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey),
    FOREIGN KEY (ModeloKey)    REFERENCES CNEJ.BI_Dim_Modelo(ModeloKey)
);

CREATE TABLE CNEJ.BI_Hecho_PedFac (
    TiempoKey     INT      NOT NULL,
    SucursalKey   INT      NOT NULL,
    DiasPromedio DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Hecho_PedFac PRIMARY KEY (
      TiempoKey,SucursalKey
    ),
    FOREIGN KEY (TiempoKey)  REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (SucursalKey)REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey)
);

CREATE TABLE CNEJ.BI_Hecho_Envio (
    TiempoKey     INT      NOT NULL,
    SucursalKey   INT      NOT NULL,
    UbicacionKey  INT      NOT NULL,
    TotalEnvios   BIGINT   NOT NULL,
    Cumplidos     BIGINT   NOT NULL,
    TotalCosto    DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Envio PRIMARY KEY (
      TiempoKey,SucursalKey,UbicacionKey
    ),
    FOREIGN KEY (TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY (SucursalKey)  REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY (UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey)
);
GO

/************************************ POBLACION DE TABLAS DE HECHOS ************************************/

INSERT INTO CNEJ.BI_Hecho_Pedido
  (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey,TotalPedidos,TotalMontos)
SELECT
  dt.TiempoKey,
  ds.SucursalKey,
  dc.ClienteKey,
  de.EstadoKey,
  dtur.TurnoKey,
  dr.RangoKey,
  dub.UbicacionKey,
  COUNT(*)           AS TotalPedidos,
  SUM(p.ped_total)   AS TotalMontos
FROM CNEJ.Pedido p
JOIN CNEJ.BI_Dim_Tiempo      dt   ON dt.Anio=YEAR(p.ped_fecha)
   AND dt.Cuatrimestre=((MONTH(p.ped_fecha)-1)/4)+1
   AND dt.Mes=MONTH(p.ped_fecha)
JOIN CNEJ.BI_Dim_Sucursal    ds   ON ds.SucursalNumero=p.ped_sucursal
JOIN CNEJ.BI_Dim_Cliente     dc   ON dc.ClienteDni=p.ped_cliente
JOIN CNEJ.BI_Dim_EstadoPedido de  ON de.Estado=p.ped_estado
JOIN CNEJ.BI_Dim_Turno       dtur ON CONVERT(time,p.ped_fecha) >= dtur.HoraInicio
   AND CONVERT(time,p.ped_fecha) < dtur.HoraFin
JOIN CNEJ.BI_Dim_RangoEtario dr   ON DATEDIFF(YEAR, dc.FechaNacimiento, GETDATE()) BETWEEN dr.RangoMin AND dr.RangoMax
JOIN CNEJ.Sucursal            s    ON s.suc_numero=p.ped_sucursal
JOIN CNEJ.Provincia          pr    ON pr.pro_numero=s.suc_provincia
JOIN CNEJ.Localidad          lo    ON lo.loc_numero=s.suc_localidad
JOIN CNEJ.BI_Dim_Ubicacion   dub  ON dub.Provincia=pr.pro_nombre
   AND dub.Localidad=lo.loc_nombre
GROUP BY
  dt.TiempoKey,ds.SucursalKey,dc.ClienteKey,
  de.EstadoKey,dtur.TurnoKey,dr.RangoKey,dub.UbicacionKey;

INSERT INTO CNEJ.BI_Hecho_Compra
  (TiempoKey,SucursalKey,MaterialKey,TotalCompra)
SELECT
  dt.TiempoKey,
  ds.SucursalKey,
  dm.MaterialKey,
  SUM(dc.det_com_subtotal)
FROM CNEJ.Compra c
JOIN CNEJ.Detalle_Compra      dc ON dc.com_numero=c.com_numero
JOIN CNEJ.BI_Dim_Tiempo      dt   ON dt.Anio=YEAR(c.com_fecha)
   AND dt.Cuatrimestre=((MONTH(c.com_fecha)-1)/4)+1
   AND dt.Mes=MONTH(c.com_fecha)
JOIN CNEJ.BI_Dim_Sucursal    ds   ON ds.SucursalNumero=c.com_sucursal
JOIN CNEJ.BI_Dim_Material    dm   ON dm.MaterialNumero=dc.mat_numero
GROUP BY dt.TiempoKey,ds.SucursalKey,dm.MaterialKey;

INSERT INTO CNEJ.BI_Hecho_Facturacion
  (TiempoKey, SucursalKey, ClienteKey, EstadoKey, TurnoKey, RangoKey, UbicacionKey, TotalFacturas, TotalMontos)
SELECT
    dt.TiempoKey,
    ds.SucursalKey,
    dc.ClienteKey,
    de.EstadoKey,
    tur.TurnoKey,
    re.RangoKey,
    ub.UbicacionKey,
    COUNT(*)                     AS TotalFacturas,
    SUM(f.fac_total)     AS TotalMontos
FROM CNEJ.Factura AS f
JOIN CNEJ.Detalle_Factura          AS df  ON f.fac_numero       = df.det_fac_fac_num
JOIN CNEJ.Detalle_Pedido dp ON dp.det_ped_numero = df.det_fac_det_pedido
JOIN CNEJ.Pedido           AS p  ON p.ped_numero       = dp.ped_numero
JOIN CNEJ.Sucursal         AS s  ON s.suc_numero       = f.fac_sucursal
JOIN CNEJ.Cliente          AS cli ON cli.cli_dni        = f.fac_cliente
JOIN CNEJ.Provincia        AS pr ON pr.pro_numero      = s.suc_provincia
JOIN CNEJ.Localidad        AS lo ON lo.loc_numero      = s.suc_localidad
JOIN CNEJ.BI_Dim_Tiempo       AS dt 
  ON dt.Anio         = YEAR(f.fac_fecha)
 AND dt.Mes          = MONTH(f.fac_fecha)
 AND dt.Cuatrimestre = ((MONTH(f.fac_fecha)-1)/4)+1
JOIN CNEJ.BI_Dim_Sucursal     AS ds ON ds.SucursalNumero = s.suc_numero
JOIN CNEJ.BI_Dim_Cliente      AS dc ON dc.ClienteDni     = cli.cli_dni
JOIN CNEJ.BI_Dim_EstadoPedido AS de ON de.Estado         = p.ped_estado
JOIN CNEJ.BI_Dim_Turno        AS tur
  ON CONVERT(time, f.fac_fecha) >= tur.HoraInicio
 AND CONVERT(time, f.fac_fecha) <  tur.HoraFin
JOIN CNEJ.BI_Dim_RangoEtario re 
  ON DATEDIFF(YEAR, cli.cli_fecha_nac, GETDATE()) BETWEEN re.RangoMin AND re.RangoMax
JOIN CNEJ.BI_Dim_Ubicacion    AS ub 
  ON ub.Provincia = pr.pro_nombre
 AND ub.Localidad = lo.loc_nombre
GROUP BY
    dt.TiempoKey, ds.SucursalKey, dc.ClienteKey, de.EstadoKey,
    tur.TurnoKey, re.RangoKey, ub.UbicacionKey;
GO

INSERT INTO CNEJ.BI_Hecho_VentaModelo
  (TiempoKey, UbicacionKey, RangoKey, ModeloKey, CantidadVendida)
SELECT
    dt.TiempoKey,
    ub.UbicacionKey,
    re.RangoKey,
    dm.ModeloKey,
    SUM(dp.det_ped_cantidad) AS CantidadVendida
FROM CNEJ.Detalle_Pedido   AS dp
JOIN CNEJ.Pedido           AS p  ON p.ped_numero   = dp.ped_numero
JOIN CNEJ.Sucursal         AS s  ON s.suc_numero   = p.ped_sucursal
JOIN CNEJ.Cliente          AS cli ON cli.cli_dni    = p.ped_cliente
JOIN CNEJ.Provincia        AS pr ON pr.pro_numero  = s.suc_provincia
JOIN CNEJ.Localidad        AS lo ON lo.loc_numero  = s.suc_localidad
JOIN CNEJ.Sillon           AS sl ON sl.sil_numero  = dp.sil_numero
JOIN CNEJ.BI_Dim_Modelo    AS dm ON dm.ModeloNumero= sl.sil_modelo
JOIN CNEJ.BI_Dim_Tiempo      AS dt 
  ON dt.Anio         = YEAR(p.ped_fecha)
 AND dt.Mes          = MONTH(p.ped_fecha)
 AND dt.Cuatrimestre = ((MONTH(p.ped_fecha)-1)/4)+1
JOIN CNEJ.BI_Dim_RangoEtario re 
  ON DATEDIFF(YEAR, cli.cli_fecha_nac, GETDATE()) BETWEEN re.RangoMin AND re.RangoMax
JOIN CNEJ.BI_Dim_Ubicacion   AS ub 
  ON ub.Provincia = pr.pro_nombre
 AND ub.Localidad = lo.loc_nombre
GROUP BY
    dt.TiempoKey, ub.UbicacionKey, re.RangoKey, dm.ModeloKey;
GO

INSERT INTO CNEJ.BI_Hecho_PedFac
  (TiempoKey,SucursalKey,DiasPromedio)
SELECT
  dt.TiempoKey,
  ds.SucursalKey,
  AVG(DATEDIFF(DAY,p.ped_fecha,f.fac_fecha))
FROM CNEJ.Detalle_Pedido dp
JOIN CNEJ.Pedido              p  ON p.ped_numero=dp.ped_numero
JOIN CNEJ.Detalle_Factura     df ON df.det_fac_det_pedido=dp.det_ped_numero
JOIN CNEJ.Factura             f  ON f.fac_numero=df.det_fac_fac_num
JOIN CNEJ.BI_Dim_Tiempo      dt   ON dt.Anio=YEAR(p.ped_fecha)
   AND dt.Cuatrimestre=((MONTH(p.ped_fecha)-1)/4)+1
   AND dt.Mes=MONTH(p.ped_fecha)
JOIN CNEJ.BI_Dim_Sucursal    ds   ON ds.SucursalNumero=p.ped_sucursal
GROUP BY dt.TiempoKey,ds.SucursalKey;

INSERT INTO CNEJ.BI_Hecho_Envio
  (TiempoKey, SucursalKey, UbicacionKey, TotalEnvios, Cumplidos, TotalCosto)
SELECT
    dt.TiempoKey,
    ds.SucursalKey,
    ub.UbicacionKey,
    COUNT(*)                                         AS TotalEnvios,
    SUM(CASE WHEN e.env_fecha_real <= e.env_fecha_programada THEN 1 ELSE 0 END)
                                                      AS Cumplidos,
    SUM(e.env_importe_traslado + e.env_importe_subida) AS TotalCosto
FROM CNEJ.Envio AS e
JOIN CNEJ.Factura  AS f  ON f.fac_numero    = e.env_factura
JOIN CNEJ.Detalle_Factura AS df ON df.det_fac_fac_num   = f.fac_numero
JOIN CNEJ.Detalle_Pedido AS dp ON dp.det_ped_numero = df.det_fac_det_pedido
JOIN CNEJ.Pedido   AS p  ON p.ped_numero    = dp.ped_numero
JOIN CNEJ.Sucursal AS s  ON s.suc_numero    = f.fac_sucursal
JOIN CNEJ.Cliente  AS cli ON cli.cli_dni     = f.fac_cliente
JOIN CNEJ.Provincia AS pr ON pr.pro_numero   = s.suc_provincia
JOIN CNEJ.Localidad AS lo ON lo.loc_numero   = s.suc_localidad
JOIN CNEJ.BI_Dim_Tiempo     AS dt 
  ON dt.Anio         = YEAR(e.env_fecha_programada)
 AND dt.Mes          = MONTH(e.env_fecha_programada)
 AND dt.Cuatrimestre = ((MONTH(e.env_fecha_programada)-1)/4)+1
JOIN CNEJ.BI_Dim_Sucursal   AS ds  ON ds.SucursalNumero = s.suc_numero
JOIN CNEJ.BI_Dim_Cliente    AS dc  ON dc.ClienteDni     = cli.cli_dni
JOIN CNEJ.BI_Dim_Ubicacion  AS ub  
  ON ub.Provincia = pr.pro_nombre
 AND ub.Localidad = lo.loc_nombre
GROUP BY
    dt.TiempoKey, ds.SucursalKey, ub.UbicacionKey;
GO

/************************************ VISTAS ************************************/

CREATE OR ALTER VIEW CNEJ.BI_Vista_Ganancias AS
SELECT
  dt.Anio,
  dt.Mes,
  f.SucursalKey,
  ISNULL(SUM(f.TotalMontos), 0)       AS TotalIngresos,
  ISNULL(SUM(c.TotalCompra), 0)       AS TotalEgresos,
  ISNULL(SUM(f.TotalMontos), 0) - ISNULL(SUM(c.TotalCompra), 0) AS Ganancia
FROM CNEJ.BI_Hecho_Facturacion f
LEFT JOIN CNEJ.BI_Hecho_Compra c
  ON c.TiempoKey=f.TiempoKey
 AND c.SucursalKey=f.SucursalKey
JOIN CNEJ.BI_Dim_Tiempo dt
  ON f.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Mes,f.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_FacturaPromedioMensual AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  f.SucursalKey,
  SUM(f.TotalMontos)/4.0 AS PromedioMensualPorCuatrimestre
FROM CNEJ.BI_Hecho_Facturacion f
JOIN CNEJ.BI_Dim_Tiempo dt
  ON f.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Cuatrimestre,f.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_RendimientoModelos AS
WITH RankedVentas AS (
  SELECT
    vm.TiempoKey,
    vm.UbicacionKey,
    vm.RangoKey,
    vm.ModeloKey,
    vm.CantidadVendida,
    ROW_NUMBER() OVER (
      PARTITION BY vm.TiempoKey,vm.UbicacionKey,vm.RangoKey
      ORDER BY vm.CantidadVendida DESC
    ) AS rn
  FROM CNEJ.BI_Hecho_VentaModelo vm
)
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  rv.UbicacionKey,
  rv.RangoKey,
  rv.ModeloKey,
  rv.CantidadVendida
FROM RankedVentas rv
JOIN CNEJ.BI_Dim_Tiempo dt
  ON rv.TiempoKey=dt.TiempoKey
WHERE rv.rn<=3;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_VolumenPedidos AS
SELECT
  dt.Anio,
  dt.Mes,
  p.SucursalKey,
  p.TurnoKey,
  COUNT(*) AS CantidadPedidos
FROM CNEJ.BI_Hecho_Pedido p
JOIN CNEJ.BI_Dim_Tiempo dt
  ON p.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Mes,p.SucursalKey,p.TurnoKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_ConversionPedidos AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  p.SucursalKey,
  p.EstadoKey,
  COUNT(*)*100.0/SUM(COUNT(*)) OVER (
    PARTITION BY dt.Anio,dt.Cuatrimestre,p.SucursalKey
  ) AS PorcentajePorEstado
FROM CNEJ.BI_Hecho_Pedido p
JOIN CNEJ.BI_Dim_Tiempo dt
  ON p.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Cuatrimestre,p.SucursalKey,p.EstadoKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_TiempoFabricacion AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  pf.SucursalKey,
  AVG(pf.DiasPromedio) AS DiasPromedio
FROM CNEJ.BI_Hecho_PedFac pf
JOIN CNEJ.BI_Dim_Tiempo dt
  ON pf.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Cuatrimestre,pf.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_PromedioCompras AS
SELECT
  dt.Anio,
  dt.Mes,
  c.SucursalKey,
  AVG(c.TotalCompra) AS PromedioCompra
FROM CNEJ.BI_Hecho_Compra c
JOIN CNEJ.BI_Dim_Tiempo dt
  ON c.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Mes,c.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_ComprasTipoMaterial AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  c.SucursalKey,
  m.Tipo AS TipoMaterial,
  SUM(c.TotalCompra) AS TotalGastado
FROM CNEJ.BI_Hecho_Compra c
JOIN CNEJ.BI_Dim_Tiempo dt
  ON c.TiempoKey=dt.TiempoKey
JOIN CNEJ.BI_Dim_Material m
  ON c.MaterialKey=m.MaterialKey
GROUP BY dt.Anio,dt.Cuatrimestre,c.SucursalKey,m.Tipo;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_CumplimientoEnvios AS
SELECT
  dt.Anio,
  dt.Mes,
  AVG(e.Cumplidos * 100.0 / e.TotalEnvios) AS PorcentajeCumplidos
FROM CNEJ.BI_Hecho_Envio e
JOIN CNEJ.BI_Dim_Tiempo dt
  ON e.TiempoKey=dt.TiempoKey
GROUP BY dt.Anio,dt.Mes;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_LocalidadesCostoEnvio AS
WITH Costos AS (
  SELECT
    e.UbicacionKey,
    SUM(e.TotalCosto) AS TotalEnvio,
    ROW_NUMBER() OVER (ORDER BY SUM(e.TotalCosto) DESC) AS rn
  FROM CNEJ.BI_Hecho_Envio e
  GROUP BY e.UbicacionKey
)
SELECT
  u.Provincia,
  u.Localidad,
  c.TotalEnvio
FROM Costos c
JOIN CNEJ.BI_Dim_Ubicacion u
  ON c.UbicacionKey=u.UbicacionKey
WHERE c.rn<=3;
GO

SELECT * FROM CNEJ.BI_Dim_Tiempo;
SELECT * FROM CNEJ.BI_Dim_Ubicacion;
SELECT * FROM CNEJ.BI_Dim_Cliente;
SELECT * FROM CNEJ.BI_Dim_Sucursal;
SELECT * FROM CNEJ.BI_Dim_Material;
SELECT * FROM CNEJ.BI_Dim_Modelo;
SELECT * FROM CNEJ.BI_Dim_EstadoPedido;
SELECT * FROM CNEJ.BI_Dim_Turno;
SELECT * FROM CNEJ.BI_Dim_RangoEtario;

SELECT * FROM CNEJ.BI_Hecho_Pedido;
SELECT * FROM CNEJ.BI_Hecho_Compra;
SELECT * FROM CNEJ.BI_Hecho_Facturacion;
SELECT * FROM CNEJ.BI_Hecho_VentaModelo;
SELECT * FROM CNEJ.BI_Hecho_PedFac;
SELECT * FROM CNEJ.BI_Hecho_Envio;

SELECT * FROM CNEJ.BI_Vista_Ganancias;
SELECT * FROM CNEJ.BI_Vista_FacturaPromedioMensual;
SELECT * FROM CNEJ.BI_Vista_RendimientoModelos;
SELECT * FROM CNEJ.BI_Vista_VolumenPedidos;
SELECT * FROM CNEJ.BI_Vista_ConversionPedidos;
SELECT * FROM CNEJ.BI_Vista_TiempoFabricacion;
SELECT * FROM CNEJ.BI_Vista_PromedioCompras;
SELECT * FROM CNEJ.BI_Vista_ComprasTipoMaterial;
SELECT * FROM CNEJ.BI_Vista_CumplimientoEnvios;
SELECT * FROM CNEJ.BI_Vista_LocalidadesCostoEnvio;
