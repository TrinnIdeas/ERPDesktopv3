-- p_corte_caja_inventario_generacion 10,'20220811','20220811'
ALTER PROC [dbo].[p_corte_caja_inventario_generacion]
@pSucursalId INT,
@pFechaIni DATETIME,
@pFechaFin DATETIME
as

	DECLARE @TotalRetiros MONEY,
		@MasaUsadaEnTortilla DECIMAL(14,3),
		@MasaTotal DECIMAL(14,3)

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

	INSERT INTO #TMP_MOVS_INVENTARIO_EXCLUIR(MovimientoId,MovimientoDetalleId)
	SELECT IMD.MovimientoId,IMD.MovimientoDetalleId
	FROM doc_productos_sobrantes_regitro_inventario PSR
	INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoDetalleId = PSR.MovimientoDetalleId
	INNER JOIN doc_inv_movimiento IM ON IM.MovimientoId = IMD.MovimientoId
	WHERE IM.SucursalId = @pSucursalId AND
	convert(varchar,IM.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY IMD.MovimientoId,IMD.MovimientoDetalleId

	SELECT p.ProductoId,
		Precio = ISNULL(MAX(VD.PrecioUnitario),MAX(PP.Precio))
	INTO #TMP_PRECIOS
	FROM cat_productos P
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
										pp.IdPrecio = 1
	INNER JOIN doc_ventas_detalle VD ON VD.ProductoId = P.ProductoId AND
								CONVERT(VARCHAR,VD.FechaCreacion,112)  BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND  CONVERT(VARCHAR,@pFechaFin,112)
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
	--ENTRADAS DE MASA 
	--INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	--SELECT '1-ENTRADAS MASA Y TORTILLA',P.Descripcion,1,SUM(IMD.Cantidad),0,0
	--FROM doc_inv_movimiento IM
	--INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId AND
	--							IM.Activo = 1
	--INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.Descripcion = 'MASA'	
	--INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND 
	--												TMI.EsEntrada = 1 
	
	--WHERE IM.SucursalId = @pSucursalId AND
	--CONVERT(VARCHAR,IM.FechaMovimiento,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND 
	--IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR)
	--GROUP BY P.Descripcion
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1-ENTRADAS MASA Y TORTILLA','MASA',1,SUM(DATOS.MasaKg),PRE.Precio,SUM(DATOS.MasaKg) * PRE.Precio
	FROM doc_corte_caja_datos_entrada DATOS
	INNER JOIN cat_productos P ON P.Descripcion = 'MASA'
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId
	WHERE DATOS.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY PRE.Precio

	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1-ENTRADAS MASA Y TORTILLA','TORTILLA',1,SUM(DATOS.TiradaTortillaKg),PRE.Precio,SUM(DATOS.TiradaTortillaKg) * PRE.Precio
	FROM doc_corte_caja_datos_entrada DATOS
	INNER JOIN cat_productos P ON P.Descripcion = 'TORTILLA'
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = P.ProductoId
	WHERE DATOS.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,DATOS.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY PRE.Precio


	SELECT @MasaTotal = SUM(Cantidad)
	FROM #TMP_RESULTADO
	WHERE TipoMovimiento = '1-ENTRADAS MASA Y TORTILLA'

	--MASA FRIA
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1-ENTRADAS MASA Y TORTILLA',p.Descripcion +' '+ (CAST(SUM(psr.CantidadSobrante) AS VARCHAR)),1,(SUM(psr.CantidadSobrante)/40*33),pp.Precio,(SUM(psr.CantidadSobrante)/40*33) * pp.Precio
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.Descripcion like '%MASA FRIA%'
	INNER JOIN cat_productos PM ON PM.Descripcion = 'TORTILLA'
	INNER JOIN #TMP_PRECIOS PP ON PP.ProductoId = P.ProductoId
	WHERE CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY p.Descripcion,pp.Precio

	

	--VENTA MASA Y TORTILLA
	--INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	--SELECT '1.1-VENTA MASA Y TORTILLA',
	--		P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO CONTADO)' ELSE '-(VENTA MOSTRADOR)' END,
	--		1,
	--		SUM(VD.Cantidad),
	--		PRE.Precio,
	--		SUM(VD.Cantidad) * PRE.Precio
	--FROM doc_ventas_detalle VD
	--INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	--INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1 AND
	--							P.ProductoId = 1 --TORTILLA
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
	--		P.CLAVE + '-'+P.Descripcion  + '-(VENTA MAYOREO)',
	--		1,
	--		SUM(VD.Cantidad),
	--		PRE.Precio,
	--		SUM(VD.Cantidad) * PRE.Precio
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
	--INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId 	 AND
	--									PO.Activo = 1 AND
	--									PO.SucursalId = @pSucursalId and
	--									pod.ProductoId = 1
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
	--						PP.IdPrecio = 1
	--WHERE P.ProductoId = 2

	--TORTILLA ENTRADA POR TRASPASO
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1.2-ENTRADA POR TRASPASO',p.clave +'-'+ P.Descripcion ,1,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)
	FROM doc_inv_movimiento IM
	INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId
	INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.ProdVtaBascula = 1 AND P.ProductoId = 1 --SOLO TORTILLA
	INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND
												TMI.TipoMovimientoInventarioId in (3,5)
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId and pp.IdPrecio = 1
	WHERE IM.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,IM.CreadoEl,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND 
	IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR)
	group by PP.Precio,P.Descripcion,p.clave

	

	--VENTAS REGISTRADAS
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1.3-ENTRADAS POR PRODUCTO',
			P.CLAVE + '-'+P.Descripcion,
			1,
			SUM(VD.Cantidad),
			pre.Precio,
			SUM(VD.Cantidad) * PRE.Precio
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 0
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId
	LEFT JOIN doc_pedidos_orden PO ON PO.VentaId = V.VentaId
	WHERE V.SucursalId = @pSucursalId AND
	V.Activo = 1 AND
	CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	PO.VentaId IS NULL
	GROUP BY P.CLAVE,P.Descripcion,PRE.Precio
	order by p.Descripcion

	
	/********************FALTANTES DE PRODUCTOS MOSTRADOR*************************/
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '1.4-FALTANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,1,PSR.CantidadInventario - PSR.CantidadSobrante,PP.Precio, (PSR.CantidadInventario - PSR.CantidadSobrante) * pp.Precio
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND
							P.ProdVtaBascula = 0
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
					PP.IdPrecio = 1
	WHERE PSR.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	ISNULL(PSR.CantidadSobrante,0) < ISNULL(PSR.CantidadInventario,0)

	--GRAMOS EN CONTRA
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)	
	SELECT 	
		'1.5-GRAMOS EN CONTRA',
		P.Clave +'-'+ P.Descripcion,
		1,
		SUM(1-(Total % 1) ),
		PRE.Precio,
		PRE.Precio * SUM(1-(Total % 1))
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
	INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId
	WHERE Total % 1 BETWEEN .875 AND .999 AND
	PrecioUnitario > 0 AND
	@pSucursalId IN (S.Clave,0 )  AND
	CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY P.Clave,P.Descripcion,PRE.Precio
	
	
	

	/**********************DESCUENTOS***********************************************/
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2-SOBRANTES/DESPERDICIO',p.Descripcion,0,sum(PSR.CantidadSobrante),pp.Precio,PSR.CantidadSobrante* pp.Precio
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND p.ProdVtaBascula = 1 AND PSR.SucursalId = @pSucursalId AND
										P.Descripcion NOT LIKE '%MASA%FRIA%'
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = p.ProductoId and pp.IdPrecio = 1
	WHERE CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY p.Descripcion,pp.Precio,PSR.CantidadSobrante

	--CORTESIA
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2-CORTESIA/CONSUMO EMPLEADO',P.Descripcion + ' Folio:'+v.Folio,0,VD.Cantidad,PP.Precio,VD.Cantidad * PP.Precio
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND
											ISNULL(VD.Total,0) = 0
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND P.ProdVtaBascula = 1
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
										PP.IdPrecio = 1
	WHERE CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN  CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	V.SucursalId = @pSucursalId and
	v.Activo = 1
	order by P.Descripcion

	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2.1-GASTOS',G.Obervaciones,0,1,g.Monto,g.Monto
	FROM doc_gastos G
	WHERE CONVERT(VARCHAR,G.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	G.SucursalId = @pSucursalId and
	G.Activo = 1


	--PEDIDO MAYOREO	

	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2.2-PEDIDOS MAYOREO',
			P.CLAVE + '-'+P.Descripcion + CASE WHEN ISNULL(MIN(v.ClienteId),0) > 0 THEN '-(PEDIDO MAYOREO CONTADO '+CLI.Nombre+')'  ELSE '-(VENTA MOSTRADOR)' END,
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
								P.ProductoId = 1 --TORTILLA
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
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2.3-PEDIDOS MAYOREO POR PAGAR',p.Descripcion,0,SUM(POD.Cantidad),
	PRE.Precio,
	SUM(POD.Cantidad) * PRE.Precio
	FROM doc_pedidos_orden PO
	INNER JOIN doc_pedidos_orden_detalle POD ON POD.PedidoId = PO.PedidoId 	 AND
										PO.Activo = 1 AND
										PO.SucursalId = @pSucursalId 
	INNER JOIN cat_productos P ON P.ProductoId = POD.ProductoId
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = POD.ProductoId 			
	WHERE CONVERT(VARCHAR,PO.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY p.Descripcion,PRE.Precio


	--TRASPASOS
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2.4-TRASPASO/SALIDA',P.Descripcion,0,SUM(IMD.Cantidad),PP.Precio,PP.Precio * SUM(IMD.Cantidad)
	FROM doc_inv_movimiento IM
	INNER JOIN doc_inv_movimiento_detalle IMD ON IMD.MovimientoId = IM.MovimientoId
	INNER JOIN cat_productos P ON P.ProductoId = IMD.ProductoId AND P.ProdVtaBascula = 1 AND P.Descripcion NOT LIKE '%MASA%FRIA%' AND
												P.ProductoId IN( 1,2)
	INNER JOIN cat_tipos_movimiento_inventario TMI ON TMI.TipoMovimientoInventarioId = IM.TipoMovimientoId AND
												TMI.TipoMovimientoInventarioId in (4,6)
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
										PP.IdPrecio = 1
	WHERE IM.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,IM.CreadoEl,112) BETWEEN   CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)AND 
	IMD.MovimientoDetalleId NOT IN (SELECT MovimientoDetalleId FROM #TMP_MOVS_INVENTARIO_EXCLUIR)
	group by PP.Precio,P.Descripcion


	

	/********************SOBRANTES DE PRODUCTOS MOSTRADOR*************************/
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT '2.6-SOBRANTES PRODUCTO MOSTRADOR',P.Clave +'-'+ P.Descripcion,0,ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0),
			PP.Precio, 
			(ISNULL(PSR.CantidadSobrante,0) - ISNULL(PSR.CantidadInventario,0)) * pp.Precio
	FROM doc_productos_sobrantes_registro PSR
	INNER JOIN cat_productos P ON P.ProductoId = PSR.ProductoId AND
							P.ProdVtaBascula = 0
	INNER JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
					PP.IdPrecio = 1
	WHERE PSR.SucursalId = @pSucursalId AND
	CONVERT(VARCHAR,PSR.CreadoEl,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	ISNULL(PSR.CantidadSobrante,0) > ISNULL(PSR.CantidadInventario,0)


	/************************GRAMOS A FAVOR***********************************/
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT 	'2.7-GRAMOS A FAVOR',
		P.Clave +'-'+ P.Descripcion,
		0,
		SUM(Cantidad - Total/VD.PRECIOUNITARIO),
		PRE.Precio,
		SUM(VD.PrecioUnitario * (Cantidad - Total/VD.PRECIOUNITARIO))
		
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND v.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId AND p.ProdVtaBascula = 1
	INNER JOIN cat_sucursales S ON S.Clave = V.SucursalId
	INNER JOIN #TMP_PRECIOS PRE ON PRE.ProductoId = VD.ProductoId
	WHERE (VD.PRECIOUNITARIO * Cantidad) <> Total AND
	PrecioUnitario > 0 AND
	@pSucursalId IN (S.Clave,0 )  AND
	CONVERT(VARCHAR,V.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112)
	GROUP BY P.Clave ,P.Descripcion,PRE.Precio

	update #TMP_RESULTADO
	set Monto = Monto * -1
	where Abono = 0

	
	UPDATE #TMP_RESULTADO
	SET TotalEntregadoSucursal = ISNULL(@TotalRetiros,0),
		TotalAnalisisCorteCaja = ISNULL((SELECT SUM(Monto) FROM #TMP_RESULTADO WHERE Abono = 1),0),
		TotalDescuentos = ISNULL((SELECT SUM(Monto)*-1 FROM #TMP_RESULTADO WHERE Abono = 0),0)

	UPDATE #TMP_RESULTADO
	SET Diferencia = TotalEntregadoSucursal - TotalAnalisisCorteCaja + TotalDescuentos

	
	/***********************************RESULTADOS******************************/
	INSERT INTO #TMP_RESULTADO(TipoMovimiento,Concepto,Abono,Cantidad,PrecioUnitario,Monto)
	SELECT TOP 1 '3-BALANCE FINAL','Total Análisis Corte Caja',0,1,TotalAnalisisCorteCaja,TotalAnalisisCorteCaja
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
		Segundo = 0
	INTO #TMP_DATOS
	FROM doc_basculas_bitacora BB
	INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId		
	WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	BB.ProductoId IS NULL AND
	TBB.TipoBasculaBitacoraId = 4
	ORDER BY BB.Fecha 


	
	


	/********************TORTILLA/MASA VENTA*****************r**/
	--INSERT INTO  #TMP_DATOS(ProductoId,Clave,DescripcionCorta,Cantidad,TipoBasculaBitacoraId,Tipo,Fecha,Hora,Minuto,Segundo)
	--SELECT 
		
	--	ProductoId = P.ProductoId,
	--	Clave = ISNULL(P.Clave,''),
	--	DescripcionCorta = ISNULL(p.DescripcionCorta,'INDEFINIDO'),
	--	BB.Cantidad,
	--	TipoBasculaBitacoraId= CASE WHEN BB.TipoBasculaBitacoraId IS NULL THEN 0 ELSE BB.TipoBasculaBitacoraId  END ,
	--	Tipo = ISNULL(TBB.Nombre,'INDEFINIDO'),
	--	VD.FechaCreacion,
	--	Hora = DATEPART(HH,VD.FechaCreacion),
	--	Minuto = DATEPART(MM, VD.FechaCreacion),
	--	Segundo = DATEPART(SECOND,VD.FechaCreacion)
	
	--FROM doc_basculas_bitacora BB
	--INNER JOIN cat_productos P ON P.ProductoId = BB.ProductoId
	--INNER join cat_tipos_bascula_bitacora TBB ON TBB.TipoBasculaBitacoraId = BB.TipoBasculaBitacoraId
	--INNER JOIN doc_ventas_detalle VD ON VD.ProductoId = BB.ProductoId AND
	--								CONVERT(VARCHAR,VD.FechaCreacion,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	--								VD.Cantidad = BB.Cantidad 
	--WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	----BB.SucursalId = @pSucursalId AND
	--P.productoid IN (1,2) AND
	--BB.TipoBasculaBitacoraId  = 1 --VENTA MOSTRADOR
	--group by P.Clave,P.ProductoId,p.DescripcionCorta,VD.FechaCreacion,BB.Cantidad,BB.TipoBasculaBitacoraId,TBB.Nombre
	--ORDER BY VD.FechaCreacion

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
	
	WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
	--BB.SucursalId = @pSucursalId AND
	P.productoid IN (1,2) AND
	BB.TipoBasculaBitacoraId  = 1 --VENTA MOSTRADOR
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
	
	WHERE CONVERT(VARCHAR,Fecha,112) BETWEEN CONVERT(VARCHAR,@pFechaIni,112) AND CONVERT(VARCHAR,@pFechaFin,112) AND
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
	LEFT  JOIN cat_productos_precios PP ON PP.IdProducto = P.ProductoId AND
									PP.IdPrecio = 1
	
	GROUP BY TMP.ProductoId,P.Clave,p.DescripcionCorta,TMP.TipoBasculaBitacoraId,TMP.Tipo 



	/******************************PESO INTELIGENTE****************************************/
		


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