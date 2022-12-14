if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_fp_previo'
)
drop proc p_rpt_corte_caja_fp_previo
go
-- p_rpt_corte_caja_fp 1
create proc [dbo].[p_rpt_corte_caja_fp_previo]
@pCorteCajaId int
as

	select fp.FormaPagoId,
		FormaPago =fp.Descripcion,
		Monto = sum(cc.Total)
	from doc_corte_caja_fp_previo cc
	inner join cat_formas_pago  fp on fp.FormaPagoId = cc.FormaPagoId
	where CorteCajaId = @pCorteCajaId
	group by fp.FormaPagoId,
		fp.Descripcion





