/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp]    Script Date: 06/07/2022 06:50:32 p. m. ******/
-- p_rpt_corte_caja_fp 46
ALTER proc [dbo].[p_rpt_corte_caja_fp]
@pCorteCajaId int
as


		SELECT VFP.FormaPagoId,
			FormaPago = fp.Descripcion,
			Monto = SUM(V.TotalVenta)
		FROM doc_corte_caja_ventas CCV
		INNER JOIN  doc_ventas V ON V.VentaId = CCV.VentaId 
		INNER JOIN doc_ventas_formas_pago VFP ON VFP.VentaId = V.VentaId
		inner join cat_formas_pago  fp on fp.FormaPagoId = VFP.FormaPagoId
		WHERE CCV.CorteId = @pCorteCajaId AND
		V.FechaCancelacion IS NULL AND
		ISNULL(V.Activo,0)=1
		GROUP BY VFP.FormaPagoId,
			 fp.Descripcion





