if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_retiros_previo'
)
drop proc p_rpt_corte_caja_retiros_previo
go


-- p_rpt_corte_caja_retiros 1
create Proc [dbo].[p_rpt_corte_caja_retiros_previo]
@pCorteCajaId int
as

	select Folio=ret.RetiroId,
		Monto=ret.MontoRetiro,
		Fecha=ret.FechaRetiro
	from doc_corte_caja_previo cc	
	inner join doc_retiros ret on ret.CajaId = cc.CajaId and
								ret.FechaRetiro
								between cc.FechaApertura
								 and cc.FechaCorte and
								 ret.CreadoPor = cc.CreadoPor
	
	where cc.CorteCajaId = @pCorteCajaId






