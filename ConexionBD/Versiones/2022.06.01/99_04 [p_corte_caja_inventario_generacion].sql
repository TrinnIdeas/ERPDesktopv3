
-- p_corte_caja_inventario_generacion 10,'20221209','20221209'
alter PROC p_corte_caja_inventario_generacion
@pSucursalId INT,    
@pFechaIni DATETIME,    
@pFechaFin DATETIME    
as    
begin     
 DECLARE @TotalRetiros MONEY,    
  @MasaUsadaEnTortilla DECIMAL(14,3),    
  @MasaTotal DECIMAL(14,3),    
  @MetodoCalculo VARCHAR(50)='',    
  @fechaRegistroSobrantes DATETIME    
    
  SELECT @fechaRegistroSobrantes = DATEADD(MINUTE,-1,max(CerradoEl))    
  FROM doc_productos_sobrantes_registro    
  where CONVERT(VARCHAR,CreadoEl,112) = CONVERT(VARCHAR,@pFechaFin,112)    
    
	SELECT @MetodoCalculo = CAST(ISNULL(Valor,'')   AS VARCHAR)
	FROM sis_preferencias_sucursales PS  
	INNER JOIN sis_preferencias P ON P.ID = PS.PreferenciaId AND  
		  P.Preferencia = 'CCaja-TortilleriaMetodoCalculo'  
	WHERE SucursalId = @pSucursalId      
    
 CREATE TABLE #TMP_RESULTADO    
 (    
  Fila int identity(1,1),    
  TipoMovimiento VARCHAR(450),    
  Concepto VARCHAR(450),    
  Abono BIT,    
  Cantidad decimal(14,3),    
  PrecioUnitario MONEY,    
  Monto MONEY,    
  TotalAnalisisCorteCaja MONEY NULL,    
  TotalDescuentos MONEY NULL,    
  TotalEntregadoSucursal  MONEY NULL,    
  Diferencia MONEY NULL
 )    
    
 CREATE TABLE #TMP_MOVS_INVENTARIO_EXCLUIR(    
  MovimientoId INT,    
  MovimientoDetalleId INT    
 )    
 
 create table #PreciosProductoHistorico (ProductoId int, UltimoPrecio decimal(16,6), FechaRegistro date)

 insert into #PreciosProductoHistorico (ProductoId, UltimoPrecio, FechaRegistro)
 select distinct ProductoId, PrecioNuevo, FechaRegistro
 from 
	 (select ProductoId, PrecioNuevo, FechaRegistro= cast(FechaRegistro as date),  
					ROW_NUMBER() OVER(partition by ProductoId order by ProductoId asc, cast(FechaRegistro as date) desc) AS Row#
		 from [cat_productos_cambio_precio] 
		 where cast(FechaRegistro as date)<=@pFechaIni) as t1 
 where Row#= 1
 
 INSERT INTO #TMP_MOVS_INVENTARIO_EXCLUIR(MovimientoId,MovimientoDetalleId)    
 SELECT IMD.MovimientoId,IMD.MovimientoDetalleId    
 FROM doc_productos_sobrantes_regitro_inventario PSR    
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoDetalleId = PSR.MovimientoDetalleId    
 INNER JOIN doc_inv_movimiento IM ON IM.MovimientoId = IMD.MovimientoId    
 WHERE IM.SucursalId = @pSucursalId AND    
 convert(varchar,IM.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
 GROUP BY IMD.MovimientoId,IMD.MovimientoDetalleId    
    
 SELECT p.ProductoId,    
  Precio = ISNULL(MAX(VD.PrecioUnitario),MAX(isnull(t10.UltimoPrecio,PP.Precio)))    
 INTO #TMP_PRECIOS    
 FROM cat_productos P    
 left JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND    
          pp.IdPrecio = 1    
 left JOIN doc_ventas_detalle VD ON VD.ProductoId = P.ProductoId AND    
        CONVERT(VARCHAR,VD.FechaCreacion,112)  BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND  CONVERT(VARCHAR,@pFechaFin,112)  
 left join #PreciosProductoHistorico t10 on t10.ProductoId= p.ProductoId
 GROUP BY P.ProductoId     
    

 --PRECIO MASA FRIA    
 INSERT INTO #TMP_PRECIOS    
 SELECT P1.ProductoId,    
  PRecio = PRE.Precio    
 FROM cat_productos P1    
 INNER JOIN cat_productos P2 ON P2.Descripcion = 'TORTILLA'    
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P2.ProductoId    
 WHERE P1.Descripcion LIKE '%MASA%FRIA%'    
     
    
 SELECT @TotalRetiros = sum(R.MontoRetiro)    
 FROM doc_retiros R    
 WHERE R.SucursalId = @pSucursalId AND    
 CONVERT(VARCHAR,R.FechaRetiro,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
    
 /***********************************************ENTRADAS********************************************/    
 IF(@MetodoCalculo = '' OR @MetodoCalculo = 'MODE-TIRADAS')
 BEGIN     
	  INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
	  SELECT '1.1-ENTRADAS MASA Y TORTILLA','MASA',1,SUM(DATOS.MasaKg),PRE.Precio,SUM(DATOS.MasaKg) * PRE.Precio    
	  FROM doc_corte_caja_datos_entrada DATOS    
	  INNER JOIN cat_productos P ON P.Descripcion = 'MASA'    
	  INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId    
	  WHERE DATOS.SucursalId = @pSucursalId AND    
	  CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
	  GROUP BY PRE.Precio    
    
	  INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
	  SELECT '1.1-ENTRADAS MASA Y TORTILLA','TORTILLA',1,SUM(DATOS.TiradaTortillaKg),PRE.Precio,SUM(DATOS.TiradaTortillaKg) * PRE.Precio    
	  FROM doc_corte_caja_datos_entrada DATOS    
	  INNER JOIN cat_productos P ON P.Descripcion = 'TORTILLA'    
	  INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId    
	  WHERE DATOS.SucursalId = @pSucursalId AND    
	  CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
	  GROUP BY PRE.Precio  
 END

 IF(@MetodoCalculo = 'MODE-MAIZ')
   BEGIN	 
  
	  INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)  
	  SELECT '1.1-ENTRADAS MASA Y TORTILLA','TORTILLA',1,MR.TortillaTotalRendimiento,P.Precio,P.Precio * MR.TortillaTotalRendimiento
	  FROM [dbo].[doc_maiz_maseca_rendimiento] MR
	  INNER JOIN #TMP_PRECIOS P ON P.ProductoId = 1 
	  WHERE MR.SucursalId = @pSucursalId AND
	  CONVERT(VARCHAR,MR.Fecha,112) = CONVERT(VARCHAR,DATEADD(Day,-1,@pFechaIni),112)
  END
    
   
    
 SELECT @MasaTotal = SUM(Cantidad)    
 FROM #TMP_RESULTADO    
 WHERE TipoMovimiento = '1.1-ENTRADAS MASA Y TORTILLA'    
    
 --MASA FRIA    
     
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '1.1-ENTRADAS MASA Y TORTILLA',p.Descripcion +' '+ (CAST(SUM(MD.Cantidad) AS VARCHAR)),1,(SUM(md.Cantidad)/40*33),pp.Precio,(SUM(MD.Cantidad)/40*33) * pp.Precio    
 FROM doc_inv_movimiento_detalle MD    
 INNER JOIN cat_productos P ON P.ProductoId = MD.ProductoId    
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = 1 --TORTILLA   
 INNER JOIN doc_inv_movimiento M ON M.MovimientoId = MD.MovimientoId AND    
      P.Descripcion like '%MASA%FRIA%'    
 WHERE CONVERT(VARCHAR,M.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,DATEADD(dd,-1,@pFechaIni),112) AND CONVERT(VARCHAR,DATEADD(DD,-1,@pFechaFin),112) AND    
 MD.Cantidad  > 0    
 GROUP BY p.Descripcion,pp.Precio    

	/*****ENTRADAS DE PAGOS DE PEDIDOS DE DÍAS ANTERIORES*****/
    INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)  
	SELECT '1.1-1-PAGOS PEDIDOS DE DÍAS ANTERIORES' ,CLI.Nombre,1,SUM(VD.Cantidad),MAX(VD.PrecioUnitario),SUM(VD.Cantidad)* MAX(VD.PrecioUnitario)
	FROM doc_ventas V
	INNER JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId 								
	INNER JOIN doc_pedidos_orden PO ON V.SucursalId = @pSucursalId AND
								CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFechaFin,112) AND
								PO.VentaId = V.VentaId AND	
								CONVERT(VARCHAR,PO.CreadoEl,112) < CONVERT(VARCHAR,V.Fecha,112)
	INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId 
	GROUP BY CLI.Nombre
    
 --TORTILLA ENTRADA POR TRASPASO    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '1.2-ENTRADA POR TRASPASO',p.clave +'-'+ P.Descripcion ,1,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)    
 FROM doc_inv_movimiento IM    
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId    
 INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.ProdVtaBascula = 1 AND P.ProductoId = 1 --SOLO TORTILLA    
 INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND    
            TMI.TipoMovimientoInventarioId in (3,5)    
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = P.ProductoId 
 WHERE IM.SucursalId = @pSucursalId AND    
 CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND     
 IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR)    
 group by PP.Precio,P.Descripcion,p.clave    
    
     
    
 --VENTA MASA Y TORTILLA    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '1.1-VENTA MASA Y TORTILLA',    
 --  P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO CONTADO)' ELSE '-(VENTA MOSTRADOR)' END,    
 --  1,    
 --  SUM(VD.Cantidad),    
 --  PRE.Precio,    
 --  SUM(VD.Cantidad) * PRE.Precio    
 --FROM doc_ventas_detalle VD    
 --INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId    
 --INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1 AND    
 --       P.ProductoId = 1 --TORTILLA    
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId            
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId    
 --WHERE V.SucursalId = @pSucursalId AND    
 --V.Activo = 1 AND    
 --CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --PO.VentaId IS NULL AND    
 --VD.PrecioUnitario > 0    
 --GROUP BY P.CLAVE,P.Descripcion,PRE.Precio,v.ClienteId    
 --order by p.CLAVE    
    
    
 ----PEDIDO MAYOREO    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '1.1-VENTA MASA Y TORTILLA',    
 --  P.CLAVE + '-'+P.Descripcion  + '-(VENTA MAYOREO)',    
 --  1,    
 --  SUM(VD.Cantidad),    
 --  PRE.Precio,    
 --  SUM(VD.Cantidad) * PRE.Precio    
 --FROM doc_ventas_detalle VD    
 --INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId and vd.ProductoId = 1    
 --INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId     
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId      
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId    
 --WHERE V.SucursalId = @pSucursalId AND    
 --V.Activo = 1 AND    
 --CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --PO.VentaId IS NOT NULL    
 --GROUP BY P.CLAVE,P.Descripcion,PRE.Precio    
 --order by p.CLAVE    
    
    
 --PEDIDO MAYOREO POR PAGAR    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '1.1-VENTA MASA Y TORTILLA',p.CLave + '-' +p.Descripcion + '-(VENTA MAYOREO POR PAGAR)',1,    
 --SUM(POD.Cantidad),    
 --PRE.Precio,    
 --SUM(POD.Cantidad) * PRE.Precio    
 --FROM doc_pedidos_orden PO    
 --INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId   AND    
 --         PO.Activo = 1 AND    
 --         PO.SucursalId = @pSucursalId and    
 --         pod.ProductoId = 1    
 --INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId    
 --INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = POD.ProductoId        
 --WHERE CONVERT(VARCHAR,PO.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
 --GROUP BY p.Descripcion,PRE.Precio,p.CLave     
    
 --SELECT @MasaUsadaEnTortilla = SUM(Cantidad) * 1.21    
 --FROM #TMP_RESULTADO    
 --WHERE TipoMovimiento = '1.1-VENTA MASA Y TORTILLA'    
    
     
    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '1.1-VENTA MASA Y TORTILLA',P.Descripcion,1,(ISNULL(@MasaTotal,0) - ISNULL(@MasaUsadaEnTortilla,0)),PP.Precio,PP.Precio * (ISNULL(@MasaTotal,0) - ISNULL(@MasaUsadaEnTortilla,0))    
 --FROM cat_productos P    
 --INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND    
 --      PP.IdPrecio = 1    
 --WHERE P.ProductoId = 2    
    
     
    
     
    
 --VENTAS REGISTRADAS    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '1.3-VENTAS POR PRODUCTO',    
   P.CLAVE + '-'+P.Descripcion,    
   1,    
   SUM(VD.Cantidad),    
   pre.Precio,    
   SUM(VD.Cantidad) * PRE.Precio    
 FROM doc_ventas_detalle VD    
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId    
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 0    
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId    
 --LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId    
 WHERE V.SucursalId = @pSucursalId AND    
 V.Activo = 1 AND    
 CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)   
 -- and PO.VentaId IS NULL    
 GROUP BY P.CLAVE,P.Descripcion,PRE.Precio,p.orden    
 order by p.Orden    
    
     
 /********************FALTANTES DE PRODUCTOS MOSTRADOR*************************/    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '1.4-FALTANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,1, 
 PSR.CantidadInventario - PSR.CantidadSobrante, pre.Precio, (PSR.CantidadInventario - PSR.CantidadSobrante) * pre.Precio  
 FROM doc_productos_sobrantes_registro PSR    
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND    
       P.ProdVtaBascula = 0     
 left join #TMP_PRECIOS PRE on pre.ProductoId= p.ProductoId
 WHERE PSR.SucursalId = @pSucursalId AND    
 CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 ISNULL(PSR.CantidadSobrante,0) < ISNULL(PSR.CantidadInventario,0)    
 ORDER BY P.ORDEN    
  
 /**********************************GRAMOS A FAVOR EN CONTRA***************************************/  
create table #GramosFavorEnContra (ProductoId int, PrecioProducto decimal(16,6), ClaveTipoGramos smallint, PrecioPorGramo decimal(16,6), GramosPesados decimal(16,6), 
									Total decimal(16,6), GramosVendidos_EnBase_Al_Total decimal(16,6), ResultadoGramos decimal(16,6), ImporteGramos decimal(16,6))   

insert into #GramosFavorEnContra(ProductoId, PrecioProducto, PrecioPorGramo, GramosPesados, Total, GramosVendidos_EnBase_Al_Total)   
select ProductoId,   PrecioProducto= PrecioUnitario,  
PrecioPorgramo= (PrecioUnitario/1000),   GramosPesados=(Cantidad*1000),  Total,   GramosVendidos_EnBase_Al_Total= (Total/(PrecioUnitario/1000))  
from    
	doc_ventas t1 
inner join   
	doc_ventas_detalle t2 on t2.VentaId= t1.VentaId  
where  
	isnull(t1.clienteid,0)=0 and   t1.SucursalId=@pSucursalId and   
	cast(t1.FechaCreacion as date)  between  cast(@pFechaIni as date) and cast(@pFechaFin as date) and 
	PrecioUnitario>0   
	--and  
	--cast(FechaCreacion as date)  ='20221123' and   ProductoId in (1,2) and   Total>0 
update #GramosFavorEnContra set ResultadoGramos= ((GramosPesados)-(Total/(PrecioPorgramo)))  

update #GramosFavorEnContra set ClaveTipoGramos= 1 /*A favor*/, ImporteGramos= PrecioPorGramo*ResultadoGramos 
where ResultadoGramos>0  

update #GramosFavorEnContra set ClaveTipoGramos= 2 /*En contra*/, ImporteGramos= PrecioPorGramo*ResultadoGramos where ResultadoGramos<0  

delete #GramosFavorEnContra where ISNULL(ResultadoGramos, 0)= 0  
  
 /***************************************************************************************************************/  
    
     
 --GRAMOS EN CONTRA    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT  TipoMovimiento= '1.5-GRAMOS EN CONTRA',     
		Concepto= max(t2.Clave) +'-'+ max(t2.Descripcion),     
		Abono= 1, 
		Cantidad= ((sum(ResultadoGramos))/1000.00000)*-1,
		PrecioUnitario= PrecioProducto, 
		Monto= sum(ImporteGramos)*-1  
from #GramosFavorEnContra t1 inner join 
	cat_productos t2 on t2.ProductoId= t1.ProductoId   
where t1.ClaveTipoGramos= 2  
group  by ClaveTipoGramos, t1.ProductoId, PrecioProducto  order by t1.ProductoId  
     
     
     
    
    
    
 /**********************DESCUENTOS***********************************************/    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2-SOBRANTES/DESPERDICIO/CONSUMO EMPLEADOS Y CORTESÍA',p.Descripcion,0,sum(PSR.CantidadSobrante),pp.Precio,PSR.CantidadSobrante* pp.Precio    
 FROM doc_productos_sobrantes_registro PSR    
 INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.ProdVtaBascula = 1 AND PSR.SucursalId = @pSucursalId AND    
          P.Descripcion NOT LIKE '%MASA%FRIA%'    
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 WHERE CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
 GROUP BY p.Descripcion,pp.Precio,PSR.CantidadSobrante    
    
 --CORTESIA    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2-SOBRANTES/DESPERDICIO/CONSUMO EMPLEADOS Y CORTESÍA','(CONSUMO EMPLEADO)'+P.Descripcion + ' Folio:'+v.Folio,0,VD.Cantidad,PP.Precio,VD.Cantidad * PP.Precio    
 FROM doc_ventas_detalle VD    
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND    
           ISNULL(VD.Total,0) = 0    
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1    
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 WHERE CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN  CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 V.SucursalId = @pSucursalId and    
 v.Activo = 1    
 order by P.Descripcion    

 /*****ENTRADAS DE PAGOS DE PEDIDOS DE DÍAS ANTERIORES*****/
    INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)  
	SELECT '2.1-PAGOS PEDIDOS DE DÍAS ANTERIORES' ,CLI.Nombre,0,SUM(VD.Cantidad),MAX(VD.PrecioUnitario),SUM(VD.Cantidad)* MAX(VD.PrecioUnitario)
	FROM doc_ventas V
	INNER JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId 								
	INNER JOIN doc_pedidos_orden PO ON V.SucursalId = @pSucursalId AND
								CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFechaFin,112) AND
								PO.VentaId = V.VentaId AND	
								CONVERT(VARCHAR,PO.CreadoEl,112) < CONVERT(VARCHAR,V.Fecha,112)
	INNER JOIN doc_ventas_detalle VD ON VD.VentaId = V.VentaId 
	GROUP BY CLI.Nombre
    
 /********************SOBRANTES DE PRODUCTOS MOSTRADOR*************************/    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '2.1-SOBRANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,0,ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0),    
 --  PP.Precio,     
 --  (ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0)) * pp.Precio    
 --FROM doc_productos_sobrantes_registro PSR    
 --INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND    
 --      P.ProdVtaBascula = 0    
 --INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 --WHERE PSR.SucursalId = @pSucursalId AND    
 --CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --ISNULL(PSR.CantidadSobrante,0) > ISNULL(PSR.CantidadInventario,0)    
 --ORDER BY  P.Orden    
    
    
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '2.1.1-GASTOS',G.Obervaciones,0,1,g.Monto,g.Monto    
 --FROM doc_gastos G    
 --WHERE CONVERT(VARCHAR,G.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --G.SucursalId = @pSucursalId and    
 --G.Activo = 1    
    
    
 --PEDIDO MAYOREO     
    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2.2-PEDIDOS MAYOREO PAGADO',    
   P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO PAGADO '+CLI.Nombre+')'  ELSE '-(VENTA MOSTRADOR)' END,    
   0,    
   SUM(VD.Cantidad),    
   vd.PrecioUnitario,    
   CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0     
     THEN (SUM(VD.Cantidad) * MAX(pre.Precio)) - (SUM(VD.Cantidad) * vd.PrecioUnitario)    
     ELSE (SUM(VD.Cantidad) * vd.PrecioUnitario)    
   END    
 FROM doc_ventas_detalle VD    
 INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId    
 INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1 AND    
        P.ProductoId IN( 1,2) --TORTILLA    
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId     
 LEFT JOIN cat_clientes CLI ON CLI.ClienteId = V.ClienteId    
 LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId    
 WHERE V.SucursalId = @pSucursalId AND    
 V.Activo = 1 AND    
 CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 PO.VentaId IS NULL AND    
 VD.PrecioUnitario > 0 AND    
 v.ClienteId IS NOT NULL    
 GROUP BY P.CLAVE,P.Descripcion,vd.PrecioUnitario,v.ClienteId,CLI.Nombre    
 order by p.CLAVE    
    
    
 --PEDIDO MAYOREO POR PAGAR    
 /*INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2.3-PEDIDOS MAYOREO POR PAGAR',p.Descripcion,0,SUM(POD.Cantidad),    
 PRE.Precio,    
 SUM(POD.Cantidad) * PRE.Precio    
 FROM doc_pedidos_orden PO    
 INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId   AND    
          PO.Activo = 1 AND    
          PO.SucursalId = @pSucursalId     
 INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId    
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = POD.ProductoId        
 WHERE CONVERT(VARCHAR,PO.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)    
 GROUP BY p.Descripcion,PRE.Precio    
  */
  
create table #Pedido_mayoreo_por_pagar(ProductoId int, ClaveProducto varchar(50), Descripcion varchar(100), PrecioUnitario decimal (16,6), Cantidad decimal (16,6), 
										TipoBasculaBitacoraId int, TipoDetalle varchar(100), Total decimal (16,6))

insert into #Pedido_mayoreo_por_pagar(ProductoId, ClaveProducto, Descripcion, PrecioUnitario,  Cantidad, TipoBasculaBitacoraId, TipoDetalle, Total)
 select 
 ProductoId= t2.ProductoId,
 Clave= max(t4.clave),
 DescripcionCorta= Concat(max(t4.Descripcion),' (', max(t3.Nombre), ')' ),
 PrecioUnitario= max(pre.Precio),
 Cantidad=  sum(t2.Cantidad),
 TipoBasculaBitacoraId= 15,  --Venta Mayoreo por Pagar,
 Tipo = '2.3-PEDIDOS MAYOREO POR PAGAR',  
 Total=SUM(t2.Cantidad) * max(PRE.Precio)    
 from doc_pedidos_orden t1 
 inner join doc_pedidos_orden_detalle t2 on t2.PedidoId= t1.PedidoId
 inner join cat_clientes t3 on t3.ClienteId= t1.ClienteId
 inner join cat_productos t4 on t4.ProductoId= t2.ProductoId
 INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = t4.ProductoId        
 where t1.SucursalId= @pSucursalId  and 
 cast(t1.CreadoEl as date)  between  cast(@pFechaIni as date) and cast(@pFechaFin as date)
 and t2.ProductoId IN (1,2) /*Masa y tortilla*/ and 
 isnull(Parallevar, 0)= 0 AND t1.VentaId IS NULL
 group by t1.ClienteId, t2.ProductoId
 order by t2.ProductoId
 
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)   
 select TipoDetalle, Descripcion, Abono= 0, Cantidad, PrecioUnitario, Total
 from #Pedido_mayoreo_por_pagar
    
 --TRASPASOS    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT '2.4-TRASPASO/SALIDA',P.Descripcion,0,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)    
 FROM doc_inv_movimiento IM    
 INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId    
 INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.Descripcion NOT LIKE '%MASA%FRIA%' AND    
            P.ProductoId IN( 1,2)    
 INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND    
            TMI.TipoMovimientoInventarioId in (4,6)    
 INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 WHERE IM.SucursalId = @pSucursalId AND    
 CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND
 IM.FechaMovimiento < @fechaRegistroSobrantes
 group by PP.Precio,P.Descripcion    
    
 --TRASPASOS  MOSTRADOR
 --INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 --SELECT '2.4-TRASPASO/SALIDA',P.Descripcion,0,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)    
 --FROM doc_inv_movimiento IM    
 --INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId    
 --INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.Descripcion NOT LIKE '%MASA%FRIA%' AND    
 --           P.ProductoId NOT IN( 1,2)    
 --INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND    
 --           TMI.TipoMovimientoInventarioId in (4,6)    
 --INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 --WHERE IM.SucursalId = @pSucursalId AND    
 --CONVERT(VARCHAR,IM.CreadoEl,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND     
 --IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR) AND    
 --IM.FechaMovimiento < @fechaRegistroSobrantes    
 --group by PP.Precio,P.Descripcion    
    
    
     
    
     
 /************************GRAMOS A FAVOR***********************************/    
  INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
  SELECT  TipoMovimiento= '2.7-GRAMOS A FAVOR',     Concepto= max(t2.Clave) +'-'+ max(t2.Descripcion),     Abono= 0, 
  Cantidad= (sum(ResultadoGramos))/1000,PrecioUnitario= PrecioProducto, Monto= sum(ImporteGramos)   
  from #GramosFavorEnContra t1 inner join cat_productos t2 on t2.ProductoId= t1.ProductoId   
  where t1.ClaveTipoGramos= 1  group  by ClaveTipoGramos, t1.ProductoId, PrecioProducto  order by t1.ProductoId   
    
 update #TMP_RESULTADO    
 set Monto = Monto * -1    
 where Abono = 0    
    
     
 UPDATE #TMP_RESULTADO    
 SET TotalEntregadoSucursal = ISNULL(@TotalRetiros,0),    
  TotalAnalisisCorteCaja = ISNULL((SELECT SUM(Monto) FROM #TMP_RESULTADO WHERE Abono = 1),0)- ISNULL((SELECT SUM(Monto)*-1 FROM #TMP_RESULTADO WHERE Abono = 0),0)  ,    
  TotalDescuentos = ISNULL((SELECT SUM(Monto)*-1 FROM #TMP_RESULTADO WHERE Abono = 0),0)    
    
 UPDATE #TMP_RESULTADO    
 SET Diferencia = (TotalAnalisisCorteCaja  - TotalEntregadoSucursal ) *-1
    
     
 /***********************************RESULTADOS******************************/    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)    
 SELECT TOP 1 '3-BALANCE FINAL','Total An?lisis Corte Caja',0,1,TotalAnalisisCorteCaja,TotalAnalisisCorteCaja    
 FROM #TMP_RESULTADO    
 union    
 SELECT TOP 1 '3-BALANCE FINAL','Total Descuentos',0,1,TotalDescuentos,TotalDescuentos    
 FROM #TMP_RESULTADO    
 union    
 SELECT TOP 1 '3-BALANCE FINAL','Total Entregado En Sucursal',0,1,TotalEntregadoSucursal,TotalEntregadoSucursal    
 FROM #TMP_RESULTADO    
 union    
 SELECT TOP 1 '3-BALANCE FINAL','Diferencia',0,1,Diferencia,Diferencia    
 FROM #TMP_RESULTADO    
    
    
 /******************PESO INTELIGENTE****************************/    
    
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
  PrecioSeccion = CAST(0 AS FLOAT)
 INTO #TMP_DATOS    
 FROM doc_basculas_bitacora BB    
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId      
 WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 BB.ProductoId IS NULL AND    
 TBB.TipoBasculaBitacoraId = 4   AND
 BB.VentaId IS NULL
 ORDER BY BB.Fecha     
    
    
     
     
    
    
 /********************TORTILLA/MASA VENTA*****************r**/    
 
   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)    
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
  Segundo = DATEPART(SECOND,BB.Fecha)    
     
 FROM doc_basculas_bitacora BB    
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NULL 
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --BB.SucursalId = @pSucursalId AND    
 P.productoid IN (1,2) AND    
 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
 BB.VentaId IS NOT NULL 
 
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre    
 ORDER BY BB.Fecha    


  /********************TORTILLA/MASA VENTA PEDIDO PAGADOS*****************r**/    
 
   INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)    
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
  Segundo = DATEPART(SECOND,BB.Fecha)   
     
 FROM doc_basculas_bitacora BB    
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
 INNER JOIN doc_ventas V ON V.VentaId = BB.VentaId AND V.ClienteId IS NOT NULL 
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --BB.SucursalId = @pSucursalId AND    
 P.productoid IN (1,2) AND    
 BB.TipoBasculaBitacoraId  = 1 AND--VENTA MOSTRADOR    
 BB.VentaId IS NOT NULL 
 
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre    
 ORDER BY BB.Fecha    
    
    
    
 /********************TORTILLA/MASA PRECIO EMPLEADO*****************r**/    
 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)    
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
  Segundo = DATEPART(SECOND,BB.Fecha)    
     
 FROM doc_basculas_bitacora BB    
 INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId    
 INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId    
   
 WHERE CONVERT(VARCHAR,BB.Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND    
 --BB.SucursalId = @pSucursalId AND    
 P.productoid IN (1,2) AND    
 BB.TipoBasculaBitacoraId  = 14 --PRECIO EMPLEADO    
 group by P.Clave,P.ProductoId,p.DescripcionCorta,BB.Fecha,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre    
 ORDER BY BB.Fecha    
    
    
    
 /********************TORTILLA/MASA POR PAGAR*****************r**/    
 INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)    
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
  Segundo = DATEPART(SECOND,VD.CreadoEl)    
     
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
 group by P.Clave,P.ProductoId,p.DescripcionCorta,VD.CreadoEl,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre    
 ORDER BY VD.CreadoEl    
     
    
     
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
    
    
 /******************************PESO INTELIGENTE****************************************/    
 INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)     
 SELECT     
  '4 PESO INTELIGENTE (RESUMEN)',      
  Producto = ISNULL(P.Clave,'') +'-'+ ISNULL(p.DescripcionCorta,'') + ' (' + TMP.Tipo + ')',    
  0,    
  Cantidad = ISNULL(CASE WHEN TMP.TipoBasculaBitacoraId IN (12,14) THEN SUM(TMPD.Cantidad) * -1 ELSE SUM(TMPD.Cantidad) END,0),    
  ISNULL(MAX(pp.Precio),0),    
  Total = ISNULL(CASE WHEN TMP.TipoBasculaBitacoraId IN (12,14) THEN SUM(TMPD.Cantidad) * MAX(pp.Precio) *-1 ELSE SUM(TMPD.Cantidad) * MAX(pp.Precio) END,0)     
 FROM #TMP_FILTRO_MOVS TMP    
 INNER JOIN #TMP_DATOS TMPD ON TMPD.ID = TMP.ID    
 LEFT JOIN cat_productos P ON P.ProductoId = TMP.ProductoId    
 left JOIN #TMP_PRECIOS PP ON PP.ProductoId = p.ProductoId 
 GROUP BY TMP.ProductoId,P.Clave,p.DescripcionCorta,TMP.TipoBasculaBitacoraId,TMP.Tipo     
    
    
    
      
      
    
    
 SELECT Fila ,    
  TipoMovimiento,    
  Concepto,    
  Abono,    
  Cantidad,    
  PrecioUnitario,    
  Monto,    
  TotalAnalisisCorteCaja = ISNULL(TotalAnalisisCorteCaja,0),    
  TotalDescuentos = ISNULL(TotalDescuentos,0),    
  TotalEntregadoSucursal = ISNULL(TotalEntregadoSucursal,0),    
  Diferencia = ISNULL(Diferencia,0)    
 FROM #TMP_RESULTADO    
 order by Fila  
end  

go 
