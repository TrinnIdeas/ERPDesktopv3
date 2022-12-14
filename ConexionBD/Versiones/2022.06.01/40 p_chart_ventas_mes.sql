IF  EXISTS (
	SELECT 1
	FROM SYSOBJECTS
	WHERE NAME = 'p_chart_ventas_mes'
)
DROP PROC p_chart_ventas_mes
GO

-- p_chart_ventas_mes 0
CREATE PROC p_chart_ventas_mes
@pSucursalId INT
AS


	DECLARE @Fecha DATETIME = GETDATE()

	CREATE TABLE #TMP_ANIOMES
	(
		Anio INT,
		Mes INT,
		ID INT,
		NombreMes VARCHAR(50)
	)

	INSERT INTO #TMP_ANIOMES(Anio,Mes,ID,NombreMes)
	SELECT YEAR(GETDATE()),MONTH(GETDATE()),1, DATENAME(MONTH,GETDATE())
	UNION
	SELECT YEAR(DATEADD(MONTH,-1,GETDATE())),MONTH(DATEADD(MONTH,-1,GETDATE())),2,DATENAME(MONTH,DATEADD(MONTH,-1,GETDATE()))
	UNION
	SELECT YEAR(DATEADD(MONTH,-2,GETDATE())),MONTH(DATEADD(MONTH,-2,GETDATE())),3,DATENAME(MONTH,DATEADD(MONTH,-2,GETDATE()))

	SELECT Producto = CASE WHEN P.ProductoId IN (1,2) THEN P.Descripcion ELSE 'OTROS' END,
			TMP.ID,
			TMP.Anio,
			TMP.Mes,
			VD.Total,
			TMP.NombreMes
	INTO #TMP_RESULT
	FROM doc_ventas_detalle VD
	INNER JOIN doc_ventas V ON V.VentaId = VD.VentaId AND V.Activo = 1
	INNER JOIN cat_productos P ON P.ProductoId = VD.ProductoId
	INNER JOIN #TMP_ANIOMES TMP ON TMP.Anio = YEAR(V.Fecha) AND
									TMP.Mes = MONTH(V.Fecha)
	WHERE @pSucursalId IN(0,V.SucursalId)

	

	SELECT Producto,
		   Mes3 = SUM(CASE WHEN TMP.ID = 1 THEN Total ELSE 0 END),
		   Mes2 = SUM(CASE WHEN TMP.ID = 2 THEN Total ELSE 0 END),
		   Mes1 = SUM(CASE WHEN TMP.ID = 3 THEN Total ELSE 0 END),
		   ID = CAST(ROW_NUMBER() OVER(ORDER BY Producto ASC)  AS INT)
	FROM #TMP_Result TMP
	GROUP BY Producto
	