IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PROD-EquivalenciaMasaTortilla'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PROD-EquivalenciaMasaTortilla','Si la preferencia est� activa, como valor se ingresar� los kilos de masa que se necesitan para producir un kilo de tortilla',1,0,GETDATE()
END
GO
IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'CCaja-TortilleriaMetodoCalculo'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'CCaja-TortilleriaMetodoCalculo','Si la preferencia est� activa, como valor se ingresar� la clave del m�todo que se usar� para el calculo del corte de caja [MODE-MAIZ]=El calculo del corte de realizar� en base a los kilos de maiz usado en producci�n. [MODE-TIRADAS]=El calculo del corte se realizar� en base a las los kilos de masa que se hayan producido para masa de venta y masa para tortillas',1,0,GETDATE()
END
GO