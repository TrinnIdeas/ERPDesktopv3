IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PROD-EquivalenciaMaizMasa'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PROD-EquivalenciaMaizMasa','Si la preferencia est� activa, como valor se ingresar� los kilos de masa para tortilla que se producen con 1Kg de Maiz',1,0,GETDATE()
END