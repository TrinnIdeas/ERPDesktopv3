-- p_cat_rest_platillo_adicionales_sel 1
ALTER PROC [dbo].[p_cat_rest_platillo_adicionales_sel]
@pProductoId INT
AS

	SELECT DISTINCT pa.*
	FROM cat_productos P
	INNER JOIN cat_rest_platillo_adicionales_sfam PAF ON PAF.SubfamiliaId = P.ClaveSubFamilia
	INNER JOIN cat_rest_platillo_adicionales PA ON PA.Id = PAF.PlatilloAdicionalId
	WHERE p.ProductoId = @pProductoId

	UNION 
	
	SELECT PA.*
	FROM cat_rest_platillo_adicionales PA 
	WHERE PA.MostrarSiempre = 1