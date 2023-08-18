

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_rpt_corte_caja_general 6,'20230817'
ALTER PROC [dbo].[p_rpt_corte_caja_general]
@pSucursalId INT,
@pFecha DateTime
AS

	DECLARE @montoVentasTelefono MONEY,
		@efectivo MONEY,
		@tdebito MONEY,
		@tcredito MONEY,
		@otros MONEY,
		@retiros MONEy

	SELECT @efectivo = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(1) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @tdebito = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(3) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @tcredito = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId IN(2) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112)  AND
	V.SucursalId = @pSucursalId

	SELECT @otros = ISNULL(SUM(VFP.Cantidad),0)
	FROM doc_ventas_formas_pago VFP
	INNER JOIN doc_ventas V ON V.VentaId = VFP.VentaId AND VFP.FormaPagoId NOT IN(1,2,3) AND
							V.Activo = 1 AND
							V.FechaCancelacion IS NULL
	WHERE CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112) AND
	V.SucursalId = @pSucursalId

	

	SELECT @montoVentasTelefono = SUM(V.TotalVenta)
	FROM doc_pedidos_orden PO
	INNER JOIN doc_ventas V ON V.VentaId = PO.VentaId
	WHERE PO.Activo = 1 AND
	CONVERT(VARCHAR,V.Fecha,112) = CONVERT(VARCHAR,@pFecha,112) AND
	PO.SucursalId = @pSucursalId AND
	PO.TipoPedidoId = 2--Pedido Telefono

	SELECT CC.CorteCajaId,
		
		MontoRetiro = SUM(R.MontoRetiro)
	INTO #TMP_RETIROS
	FROM doc_retiros R
	INNER JOIN doc_corte_caja CC ON CC.CajaId = R.CajaId AND
							convert(varchar,CC.FechaCorte,112) = convert(varchar,@pFecha,112) 		AND
							CAST(R.FechaRetiro AS DATE) BETWEEN convert(varchar,@pFecha,112)  AND convert(varchar,@pFecha,112) 
							
	GROUP BY CC.CorteCajaId

	SELECT 
		CC.CorteCajaId,
		TotalGlobal = SUM(CC.Total),
		Gastos = MAX(CCE.Gastos),
		Retiro = ISNULL(MAX(R.MontoRetiro),0),
		FondoInicial  = ISNULL(MAX(FI.Total),0)

	INTO #TMP_TOTAL_GLOBAL
	FROM doc_corte_caja_fp CC
	INNER JOIN doc_corte_caja C ON C.CorteCajaId = CC.CorteCajaId 
	INNER JOIN cat_cajas CAJA ON CAJA.Clave = C.CajaId AND
						CAJA.Sucursal = @pSucursalId AND
						CAST(C.FechaCorte AS DATE) = CAST(@pFecha AS DATE)
	INNER JOIN doc_corte_caja_egresos CCE ON CCE.CorteCajaId = CC.CorteCajaId
	INNER JOIN doc_declaracion_fondo_inicial FI ON FI.CorteCajaId = CC.CorteCajaId
	LEFT JOIN #TMP_RETIROS R ON R.CorteCajaId = C.CorteCajaId
	GROUP BY CC.CorteCajaId

	SELECT * FROM #TMP_TOTAL_GLOBAL

	SELECT	
			CC.CorteCajaId,
			Caja = C.Descripcion,
			CC.TotalCorte,
			CC.FechaCorte,
			HoraCorte = CONVERT(varchar,CC.FechaCorte,108),
			U.NombreUsuario,
			Efectivo = ISNULL(MAX(CFP.Total),0),
			OtrasFP = ISNULL(SUM(CFP2.Total),0),
			FondoInicial = ISNULL(FI.Total,0),
			Gastos = ISNULL(G.Gastos,0),
			Retiros = ISNULL(
								MAX(R.MontoRetiro)
								,0),
			TotalGlobal =MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos),
			Ingresado = ISNULL(SUM(CCD.Total),0),
			Faltante = CASE WHEN MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) < 0 
								then  MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) 
							    ELSE 0
						END,
			Excedente = CASE WHEN MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) > 0 
								then  MAX(TG.TotalGlobal)  + MAX(tg.FondoInicial) - MAX(TG.Gastos) - MAX(TG.Retiro)- ISNULL(SUM(CCD.Total),0) 
							    ELSE 0
						END,
			VentasTelefono = ISNULL(@montoVentasTelefono,0),
			FPEfectivo = @efectivo,
			FPTCredito = @tcredito,
			FPTDebito = @tdebito,
			FPOtros = @otros
	FROM cat_sucursales SUC
	INNER JOIN cat_cajas C on C.Sucursal = SUC.Clave
	INNER JOIN doc_corte_caja CC ON CC.CajaId = C.Clave AND
							CONVERT(VARCHAR,CC.FechaCorte,112) = CONVERT(VARCHAR,@pFecha,112)
	INNER JOIN cat_usuarios U ON U.IdUsuario = CC.CreadoPor
	INNER JOIN doc_corte_caja_fp CFP ON CFP.CorteCajaId = CC.CorteCajaId AND
										CFP.FormaPagoId = 1--EFECTIVO 
	INNER JOIN doc_declaracion_fondo_inicial FI ON FI.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_denominaciones CCD ON CCD.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_egresos G ON G.CorteCajaId = CC.CorteCajaId
	LEFT JOIN doc_corte_caja_fp CFP2 ON CFP2.CorteCajaId = CC.CorteCajaId AND
										CFP2.FormaPagoId <> 1--OTRAS
	LEFT JOIN #TMP_RETIROS R ON R.CorteCajaId = CC.CorteCajaId
	LEFT JOIN #TMP_TOTAL_GLOBAL TG ON TG.TotalGlobal = TG.TotalGlobal
	WHERE SUC.Clave = @pSucursalId
	GROUP BY CC.CorteCajaId, 
			C.Descripcion,
			CC.TotalCorte,
			U.NombreUsuario,
			FI.Total,
			G.Gastos,
			CC.FechaCorte

