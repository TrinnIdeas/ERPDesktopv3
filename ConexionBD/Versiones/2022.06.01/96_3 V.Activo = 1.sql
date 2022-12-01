

ALTER Proc [dbo].[p_venta_afecta_inventario]
@pVentaId int,
@pSucursalId int
as

	DECLARE @movimientoid int,
			@consecutivo int,
			@movimientoDetalleId int,
			@folioVenta varchar(20)

	select @movimientoid = isnull(max(MovimientoId),0) + 1
	from doc_inv_movimiento

	select @consecutivo = isnull(max(Consecutivo),0) + 1
	from doc_inv_movimiento 
	where SucursalId = @pSucursalId and
	TipoMovimientoId = 8 --Venta en Caja

	select @folioVenta = isnull(Serie,'') + cast(@pVentaId as varchar)
	from [dbo].[cat_configuracion_ticket_venta]
	where sucursalId = @pSucursalId

	if(@folioVenta is null)
	begin
		select @folioVenta = cast(@pVentaId as varchar)
	end

	begin tran


	insert into doc_inv_movimiento(
		MovimientoId,		SucursalId,		FolioMovimiento,		TipoMovimientoId,		FechaMovimiento,
		HoraMovimiento,		Comentarios,	ImporteTotal,			Activo,					CreadoPor,
		CreadoEl,			Autorizado,		FechaAutoriza,			SucursalDestinoId,		AutorizadoPor,
		FechaCancelacion,	ProductoCompraId,Consecutivo,			SucursalOrigenId,		VentaId
	)
	select @movimientoid,	v.SucursalId,	@consecutivo,			8,						GETDATE(),
	getdate(),				@folioVenta,	v.TotalVenta,			1,						v.UsuarioCreacionId,
	getdate(),				1,				GETDATE(),				null,					UsuarioCreacionId,
	null,					null,			@consecutivo,			null,					v.VentaId
	from doc_ventas V
	where VentaId = @pVentaId AND
	V.Activo = 1

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	

	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	--Detalle de movs sin productos base
	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,	Consecutivo,	Cantidad,
		PrecioUnitario,			Importe,		Disponible,	CreadoPor,		CreadoEl
	)
	select @movimientoDetalleId + ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC), @movimientoid, 
	vd.ProductoId,ROW_NUMBER() OVER(ORDER BY vd.ProductoId ASC),
	Cantidad = sum(vd.Cantidad),			VD.PrecioUnitario,			VD.Total,	
	--Si tiene productos base, insertar cantidad 0 ya que no se debe de inventariar, solo dejar registro		
	Disponible =  sum(vd.Cantidad),
	v.UsuarioCreacionId,GETDATE()
	from doc_ventas V
	inner join doc_ventas_detalle vd on v.VentaId = @pVentaId AND V.Activo = 1 AND vd.VentaId = V.VentaId  
	--left join cat_productos_base pb on pb.ProductoId = vd.ProductoId
	
	
	group by vd.ProductoId,VD.PrecioUnitario,VD.Total,v.UsuarioCreacionId

	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	



	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
	

	
















