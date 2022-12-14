if exists (
	select 1
	from sysobjects
	where name = 'p_rpt_corte_productos_existencias_previo'
)
drop proc p_rpt_corte_productos_existencias_previo
go
-- p_rpt_corte_productos_existencias 1,1
create proc [dbo].[p_rpt_corte_productos_existencias_previo]
@pCorteCajaId int,
@pSoloConExistencia bit
as

	declare @sucursalid int

	select @sucursalid = c.Sucursal
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	where CorteCajaId = @pCorteCajaId

	select p.Clave,
			Descripcion = substring(p.Descripcion,1,30),
			pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	where pe.SucursalId = @sucursalid and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)
	ORDER BY P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





