if exists (
	select 1
	from sysobjects
	where name = 'p_rpt_VentaTicket'
)
drop proc p_rpt_VentaTicket
go
-- [p_rpt_VentaTicket] 11
create PROC [dbo].[p_rpt_VentaTicket]
@pVentaId INT
AS


	declare @Giro varchar(20) ,
		@Observaciones varchar(500)	

	select @Giro = Giro
	from cat_configuracion

	select @Observaciones = case when @Giro = 'AUTOLAV'
								then 'Nombre:'+cli.Nombre + ', ' +
									'Modelo:'+isnull(a.Modelo,'') + ' ' +
									isnull(a.Color,'') + ' ' +
									isnull(a.placas,'') + ', '+
									'Obs:'+isnull(a.Observaciones,'')
								else ''
							End
	from doc_ventas v
	inner join cat_clientes cli on cli.clienteId = v.ClienteId
	inner join cat_clientes_automovil a on a.ClienteId = cli.clienteId
	where VentaId = @pVentaId

	SELECT suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')) ,
			FOLIO = cast(v.Folio as bigint),
			vd.VentaDetalleId,
			FECHA = CONVERT(VARCHAR,v.FechaCreacion,103),
			HORA = CONVERT(VARCHAR,v.FechaCreacion,108),
			Producto = prod.DescripcionCorta + ' ' +isnull(prod.talla,''),
			Cantidad = vd.Cantidad,
			ImportePartida = vd.Total,
			TotalVenta = v.TotalVenta,
			TotalDescuentoVenta = v.TotalDescuento,
			SubTotalVenta = v.TotalVenta - v.Impuestos,
			ImpuestosVenta = v.Impuestos,
			TotalRecibido = SUM(vfp.Cantidad) + isnull(v.cambio,0),
			suc.Telefono1,
			RFC = emp.RFC,
			vd.PrecioUnitario,
			v.Cambio,
			conf.TextoCabecera1,
			conf.TextoCabecera2,
			conf.TextoPie,
			Serie = isnull(conf.Serie,''),
			Atendio = rhe.Nombre,
			MotivoCancelacion =case when isnull(v.MotivoCancelacion,'') = '' then ''
									else 'Motivo Cancelaci�n:' + isnull(v.MotivoCancelacion,'')
								End,
			TasaIVA = isnull(max(vd.TasaIVA),0),
			Observaciones = @Observaciones
	FROM dbo.doc_ventas v
	INNER JOIN dbo.doc_ventas_detalle vd ON vd.VentaId = v.VentaId
	INNER JOIN dbo.cat_productos prod ON prod.ProductoId = vd.ProductoId
	INNER JOIN dbo.cat_sucursales suc ON suc.Clave = v.SucursalId
	INNER JOIN dbo.doc_ventas_formas_pago vfp ON vfp.VentaId = v.VentaId
	inner join cat_empresas emp on emp.Clave = 1
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rhE on rhE.NumEmpleado = usu.IdEmpleado
	LEFT JOIN cat_configuracion_ticket_venta conf on conf.SucursalId = v.SucursalId
	
	WHERE v.VentaId = @pVentaId
	GROUP BY v.VentaId,suc.Calle,suc.NoExt ,suc.NoInt,suc.Colonia,suc.Ciudad,suc.Estado,suc.Pais,v.FechaCreacion,
	prod.DescripcionCorta,vd.Cantidad,vd.Total,v.TotalVenta,v.TotalDescuento,v.Impuestos,v.Impuestos,vd.VentaDetalleId,
	suc.NombreSucursal,suc.Telefono1,emp.RFC,vd.PrecioUnitario,v.Cambio,prod.talla,
	conf.TextoCabecera1,conf.TextoCabecera2,conf.TextoPie,conf.Serie,rhe.Nombre,v.MotivoCancelacion,v.Folio










