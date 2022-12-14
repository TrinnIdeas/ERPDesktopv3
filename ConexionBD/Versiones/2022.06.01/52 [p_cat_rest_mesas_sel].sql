-- [p_cat_rest_mesas_sel] 1
ALTER PROC [dbo].[p_cat_rest_mesas_sel]
@pSucursalId INT
AS

	SELECT DISTINCT POM.MesaId
	INTO #TMP_MESAS
	FROM doc_pedidos_orden PO	
	INNER JOIN doc_pedidos_orden_mesa POM ON POM.PedidoOrdenId = PO.PedidoId
	WHERE PO.SucursalId = @pSucursalId AND
	PO.Activo = 1 AND
	PO.VentaId IS NULL

	SELECT M.MesaId,
		SucursalId,
		Nombre,
		Descripcion,
		Activo,
		CreadoEl,
		CreadoPor,
		ModificadoEl,
		ModificadoPor,
		Ocupada = CAST(CASE WHEN TM.MesaId IS NULL THEN 0 ELSE 1 END AS BIT)
	FROM cat_rest_mesas M
	LEFT JOIN #TMP_MESAS TM ON TM.MesaId = M.MesaId
	WHERE SucursalId = @pSucursalId AND
	Activo = 1