if  exists(
	select 1
	from sysobjects
	where name = 'p_sis_versiones_detalle_ins'
)
drop proc p_sis_versiones_detalle_ins
go


create proc [dbo].[p_sis_versiones_detalle_ins]
@pVersion varchar(20) ,
@pScriptName varchar(250)
as

	declare @VersionId int,
		 @VersionDetalleId int

	select @VersionId = VersionId
	from sis_versiones
	where Nombre = @pVersion

	select @VersionDetalleId = isnull(max(VersionDetalleId),0) + 1
	from sis_versiones_detalle

	if not exists(
		select 1
		from sis_versiones_detalle
		where ScriptName = @pScriptName and
		VersionId = @VersionId
	)
	begin

		insert into sis_versiones_detalle(VersionDetalleId,VersionId,ScriptName,Completado)
		select @VersionDetalleId,@VersionId,@pScriptName,0

	end









	
