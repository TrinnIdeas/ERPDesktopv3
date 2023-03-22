IF NOT EXISTS(
	SELECT 1
	FROM sis_preferencias
	WHERE Preferencia = 'PVProductoDefault'
)
BEGIN
	INSERT INTO sis_preferencias(
		Preferencia,Descripcion,ParaEmpresa,ParaUsuario,CreadoEl
	)
	SELECT 'PVProductoDefault','Si la preferencia est� activa, en cada nueva venta se seleccionar� el producto por default de manera autom�tica. Como valor ingresar la clave del producto [VALOR=CLAVE_PRODUCTO]. ',1,0,GETDATE()
END