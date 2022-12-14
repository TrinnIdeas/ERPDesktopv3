
-- p_rpt_productos_vendidos 1,0,0,'20220101','20220501'
ALTER proc [dbo].[p_rpt_productos_vendidos]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as


	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad),
		Total = SUM(vd.Total)
	into #tmpResult
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.UsuarioCreacionId) and
	c.Sucursal = @pSucursalId and
	convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	v.FechaCancelacion is null
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	--order by SUM(vd.Cantidad) desc

	insert into #tmpResult
	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad),
		Total = sum(Total)
	from doc_apartados v
	inner join doc_apartados_productos vd on vd.ApartadoId = v.ApartadoId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.CreadoPor) and
	c.Sucursal = @pSucursalId and
	v.activo = 1 and
	v.saldo = 0 and
	convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) 
	
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	order by SUM(vd.Cantidad) desc


	select Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto ,
		Cantidad = sum(Cantidad),
		Total = sum(Total)
	from #tmpResult
	group by 
	Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto
	order by sum(Cantidad) desc


	
