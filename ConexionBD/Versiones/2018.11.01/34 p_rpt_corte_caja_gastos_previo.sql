if exists (	
	select 1
	from sysobjects
	where name = 'p_rpt_corte_caja_gastos_previo'
)
drop proc p_rpt_corte_caja_gastos_previo
go

-- p_rpt_corte_caja_gastos 1
create proc [dbo].[p_rpt_corte_caja_gastos_previo]
@pCorteCajaId int
as

	select FolioGasto = g.GastoId,
			Fecha = g.CreadoEl,
		   g.Monto,
		   CentroCosto = cc.Descripcion,
		   Concepto = con.Descripcion
	from doc_gastos g
	inner join doc_corte_caja_previo c on c.CorteCajaId = @pCorteCajaId
	inner join cat_centro_costos cc on cc.Clave = g.CentroCostoId
	inner join cat_gastos con on con.Clave = g.GastoConceptoId
	where g.CreadoEl
	 between c.FechaApertura and c.FechaCorte and
	g.Activo = 1 and
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	





