

-- p_cat_subfamilias_sel 1
ALTER PROC [dbo].[p_cat_subfamilias_sel]
@pSoloParaVenta BIT=0
AS

	SELECT F.Clave,
			F.Descripcion
	FROM cat_subfamilias F
	INNER JOIN cat_productos P ON F.Clave = P.ClaveSubFamilia
	WHERE @pSoloParaVenta = 0 OR (@pSoloParaVenta = 1 AND P.ProdParaVenta = 1) AND
	F.Descripcion <> 'CARGOS'
	GROUP BY F.Clave,
			F.Descripcion
	ORDER BY F.Descripcion