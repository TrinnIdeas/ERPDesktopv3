IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'CorteCajaSubReporteVentasProd'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'CorteCajaSubReporteVentasProd','Si la preferencia est� activa, se mostrar� un subreporte en el corte de caja con un listado de productos y ventas. Como valor se ingresar�n los ProductoId de los productos que se quieran mostrar agrupados, los ids no incluidos se mostrar�n como otros Ejem. Valor[1,2]',1,0,GETDATE()
END