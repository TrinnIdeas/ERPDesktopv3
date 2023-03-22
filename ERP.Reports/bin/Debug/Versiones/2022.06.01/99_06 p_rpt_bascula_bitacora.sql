IF EXISTS (
	SELECT 1
	FROM SYSOBJECTS
	WHERE NAME = 'p_rpt_bascula_bitacora'
)
DROP PROC p_rpt_bascula_bitacora
GO

/******IMPORTANTE!!!!!
TODAS LAS MODIFICACIONES A ESTE SP REPLICARLAS EN EL SP p_corte_caja_inventario_generacion, en la sección de PESO INTELIGENTE

************/

-- p_rpt_bascula_bitacora '20221229','20221229',10,0
CREATE proc [dbo].[p_rpt_bascula_bitacora]
@pFechaIni DateTime,
@pFechaFin DateTime,
@pSucursalId int,
@pUsuarioId INT=0
as
BEGIN


	CREATE TABLE #TMP_RESULT(
		Id INT,
		BasculaId INT,
		Sucursal VARCHAR(250),
		Cantidad DECIMAL(14,2),
		Fecha DATETIME,
		TipoMovimiento VARCHAR(250),
		ClaveProducto VARCHAR(100),
		Producto VARCHAR(500)
	)

	/********************INDEFINIDOS*******************/    
	 SELECT     
	  ID= IDENTITY(INT,1,1),    
	  ProductoId = NULL,    
	  Clave = NULL,    
	  DescripcionCorta = 'INDEFINIDO',    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = 0   ,
	  BB.BasculaId,
		BitacoraId = BB.Id
	 INTO #TMP_DATOS    
	 FROM doc_basculas_bitacora BB    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
	 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 BB.ProductoId IS NULL AND    
	 TBB.TipoBasculaBitacoraId = 4   AND
	 BB.VentaId IS NULL
	 ORDER BY BB.Fecha     


	 /********************TORTILLA/MASA VENTA*****************r**/    
 
	  INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)    ,
	  BB.BasculaId,
	  BB.Id
     
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NULL 
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
	 BB.VentaId IS NOT NULL 
 
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre     , BB.BasculaId  , BB.Id
	 ORDER BY BB.Fecha    


	  /********************TORTILLA/MASA VENTA PEDIDO PAGADOS*****************r**/    
 
	   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL('VENTA MAYOREO PAGADO','INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)   ,
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NOT NULL 
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
	 BB.VentaId IS NOT NULL 
 
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre   , BB.BasculaId    , BB.Id
	 ORDER BY BB.Fecha    
    
    
    
	 /********************TORTILLA/MASA PRECIO EMPLEADO*****************r**/    
	 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),    
	  BB.Fecha,    
	  Hora = DATEPART(HH,BB.Fecha),    
	  Minuto = DATEPART(MM, BB.Fecha),    
	  Segundo = DATEPART(SECOND,BB.Fecha)    ,
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
   
	 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 14 --PRECIO EMPLEADO    
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre  , BB.BasculaId , BB.Id    
	 ORDER BY BB.Fecha    
    
    
    
	 /********************TORTILLA/MASA POR PAGAR*****************r**/    
	 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo,BasculaId,BitacoraId)    
	 SELECT     
      
	  ProductoId = P.ProductoId,    
	  Clave = ISNULL(P.Clave,''),    
	  DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),    
	  BB.Cantidad,    
	  TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,    
	  Tipo = ISNULL('PEDIDO MAYOREO POR PAGAR','INDEFINIDO'),    
	  VD.CreadoEl,    
	  Hora = DATEPART(HH,VD.CreadoEl),    
	  Minuto = DATEPART(MM, VD.CreadoEl),    
	  Segundo = DATEPART(SECOND,VD.CreadoEl)  ,  
     BB.BasculaId,
	  BB.Id
	 FROM doc_basculas_bitacora BB    
	 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
	 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
	 INNER JOIN doc_pedidos_orden_detalle VD ON VD.ProductoId = BB.ProductoId AND    
			 CONVERT(VARCHAR,VD.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
			 VD.Cantidad = BB.Cantidad     
	 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
	 --BB.SucursalId = @pSucursalId AND    
	 P.productoid IN (1,2) AND    
	 BB.TipoBasculaBitacoraId  = 15 --PRECIO EMPLEADO    
	 group by P.Clave,P.ProductoId,p.DescripcionCorta,VD.CreadoEl,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre  , BB.BasculaId  , BB.Id
	 ORDER BY VD.CreadoEl 
	 

	   --FILTRO DUPLICADOS
     
		 SELECT     
		  ID = MAX(ID),    
		  ProductoId,    
		  --Cantidad = MAX(Cantidad),    
		  TipoBasculaBitacoraId,    
		  --Fecha = MAX(Fecha),    
		  Tipo,    
		  Hora,    
		  Minuto,    
		  Segundo    
		 INTO #TMP_FILTRO_MOVS    
		 FROM #TMP_DATOS    
		 WHERE ISNULL(ProductoId,0) = 0    
		 GROUP BY ProductoId,Hora, Minuto,Segundo,TipoBasculaBitacoraId,Tipo    
     
    
    
		 INSERT INTO #TMP_FILTRO_MOVS    
		 SELECT     
		  ID = MAX(ID),    
		  ProductoId,      
		  TipoBasculaBitacoraId,      
		  Tipo,    
		  Hora,    
		  Minuto,    
		  0    
     
		 FROM #TMP_DATOS    
		 WHERE ISNULL(ProductoId,0) > 0    
		 GROUP BY ProductoId,Hora, Minuto,TipoBasculaBitacoraId,Tipo,ID    
	 


	 SELECT R.Id,
		R.BasculaId,
		Bascula = B.Alias,
		Sucursal = S.NombreSucursal,
		Cantidad = R.Cantidad,
		Fecha = R.Fecha,
		TipoMovimiento = UPPER(R.Tipo),
		ClaveProducto = P.Clave,
		Producto = P.Descripcion,
		r.BitacoraId
	 FROM #TMP_DATOS R
	 INNER JOIN #TMP_FILTRO_MOVS F ON F.ID = R.ID
	 INNER JOIN cat_basculas B ON B.BasculaId = R.BasculaId
	 INNER JOIN cat_sucursales S ON S.Clave = @pSucursalId
	 LEFT JOIN cat_productos P ON P.ProductoId = R.ProductoId
	

END

