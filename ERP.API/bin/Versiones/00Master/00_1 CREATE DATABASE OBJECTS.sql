USE ERPProd_data
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetDateTimeServer]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetDateTimeServer]()
RETURNS DateTime
AS
BEGIN
	
	return getdate()

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetComandaAdicionales]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetComandaAdicionales]
(
	@pPedidoDetalleId int
)
RETURNS varchar(500)
AS
BEGIN
	
	DECLARE @Result varchar(500),
			@ingredientes varchar(500)='',
			@adicionales varchar(500)='',
			@notas varchar(500) = ''

	select @ingredientes= @ingredientes + ' '+
						case when i.Con = 1 then 'C/'
							 when i.Sin = 1 then 'S/'
						end+
						isnull(p.DescripcionCorta,'')
	from doc_pedidos_orden_ingre i	
	inner join cat_productos p on p.ProductoId = i.ProductoId
	where PedidoDetalleId = @pPedidoDetalleId

	select @adicionales = @adicionales +
						' /'+
						isnull(a.Descripcion,'')
	from doc_pedidos_orden_adicional pa
	inner join cat_rest_platillo_adicionales a on a.Id = pa.AdicionalId
	where pa.PedidoDetalleId = @pPedidoDetalleId


	select @notas = Notas
	from doc_pedidos_orden_detalle
	where PedidoDetalleId = @pPedidoDetalleId

	set @Result = isnull(@ingredientes,'') + ' '+
					isnull(@adicionales,'') +' '+ isnull(@notas,'')


	

	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetComandaMesas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetComandaMesas]
(
	@pPedidoId int
)
RETURNS varchar(500)
AS
BEGIN
	
	DECLARE @Result varchar(500)=''


	select @Result = @Result +  m.Nombre + ','
	from doc_pedidos_orden_mesa pm
	inner join cat_rest_mesas m on m.MesaId = pm.MesaId
	where PedidoOrdenId = @pPedidoId


	

	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  FUNCTION [dbo].[fnSplitString] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata varchar(max))
 
--declare @tabla  table(splitdata int)
--declare @string varchar(50) = '1580',
--	   @delimiter char(1) = ','

BEGIN 
    DECLARE @start INT, @end bigINT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 
    BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        Select Cast((SUBSTRING(@string, @start, @end - @start)) as varchar(max)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)	   
    END 
    RETURN 
END 


GO
/****** Object:  Table [dbo].[cat_abreviaturas_SAT]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_abreviaturas_SAT](
	[Clave] [int] NOT NULL,
	[AbreviaturaSAT] [varchar](50) NOT NULL,
	[CodigoSAT] [varchar](20) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_abreviaturas_SAT] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_almacenes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_almacenes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Ubicacion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_anaqueles]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_anaqueles](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_andenes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_andenes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_antecedentes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_antecedentes](
	[AntecedenteId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
 CONSTRAINT [PK_cat_antecedentes] PRIMARY KEY CLUSTERED 
(
	[AntecedenteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cajas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cajas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Ubicacion] [varchar](50) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
 CONSTRAINT [PK_cat_cajas] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_cajas_impresora]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_cajas_impresora](
	[CajaImpresoraId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[ImpresoraId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_cajas_impresora] PRIMARY KEY CLUSTERED 
(
	[CajaImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_centro_costos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_centro_costos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clases_sat]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clases_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clasificacion_impuestos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clasificacion_impuestos](
	[Clave] [int] NOT NULL,
	[NombreSAT] [varchar](150) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_clasificacion_impuestos] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes](
	[ClienteId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[RFC] [varchar](15) NULL,
	[Calle] [varchar](100) NULL,
	[NumeroExt] [varchar](10) NULL,
	[NumeroInt] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[CodigoPostal] [varchar](5) NULL,
	[EstadoId] [int] NULL,
	[MunicipioId] [int] NULL,
	[PaisId] [smallint] NULL,
	[Telefono] [varchar](15) NULL,
	[Telefono2] [varchar](15) NULL,
	[TipoClienteId] [tinyint] NULL,
	[DiasCredito] [smallint] NULL,
	[LimiteCredito] [money] NULL,
	[AntecedenteId] [int] NULL,
	[CreditoDisponible] [money] NULL,
	[SaldoGlobal] [money] NULL,
	[Activo] [bit] NULL,
	[ClienteEspecial] [bit] NULL,
	[ClienteGral] [bit] NULL,
	[PrecioId] [tinyint] NULL,
	[GiroId] [int] NULL,
 CONSTRAINT [PK_cat_clientes] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_automovil]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_automovil](
	[ClienteAutoId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[Modelo] [varchar](150) NOT NULL,
	[Color] [varchar](50) NOT NULL,
	[Placas] [varchar](20) NULL,
	[Observaciones] [varchar](300) NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_automovil] PRIMARY KEY CLUSTERED 
(
	[ClienteAutoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_direcciones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_direcciones](
	[ClienteDireccionId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[TipoDireccionId] [tinyint] NOT NULL,
	[Calle] [varchar](50) NULL,
	[NumeroInterior] [varchar](10) NULL,
	[NumeroExterior] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[Ciudad] [varchar](100) NULL,
	[EstadoId] [int] NULL,
	[PaisId] [int] NULL,
	[CodigoPostal] [varchar](5) NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_clientes_direcciones] PRIMARY KEY CLUSTERED 
(
	[ClienteDireccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_openpay]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_openpay](
	[ClienteId] [int] NOT NULL,
	[OpenPayId] [varchar](35) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_openpay_1] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_clientes_web]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_clientes_web](
	[ClienteId] [int] NOT NULL,
	[Email] [varchar](150) NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_clientes_web] PRIMARY KEY CLUSTERED 
(
	[ClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_conceptos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_conceptos](
	[ConceptoId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_conceptos] PRIMARY KEY CLUSTERED 
(
	[ConceptoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion](
	[ConfiguradorId] [int] NOT NULL,
	[UnaFormaPago] [bit] NULL,
	[MasUnaFormaPago] [bit] NULL,
	[CosteoUEPS] [bit] NULL,
	[CosteoPEPS] [bit] NULL,
	[CosteoPromedio] [bit] NULL,
	[AfectarInventarioLinea] [bit] NULL,
	[AfectarInventarioManual] [bit] NULL,
	[AfectarInventarioCorte] [bit] NULL,
	[EnlazarPuntoVentaInventario] [bit] NULL,
	[CajeroIncluirDetalleVenta] [bit] NULL,
	[CajeroReqClaveSupervisor] [bit] NULL,
	[SuperIncluirDetalleVenta] [bit] NULL,
	[SuperIncluirVentaTel] [bit] NULL,
	[SuperIncluirDetGastos] [bit] NULL,
	[SuperEmail1] [varchar](100) NULL,
	[SuperEmail2] [varchar](100) NULL,
	[SuperEmail3] [varchar](100) NULL,
	[SuperEmail4] [varchar](100) NULL,
	[RetiroMontoEfec] [money] NULL,
	[RetiroLectura] [bit] NULL,
	[RetiroEscritura] [bit] NULL,
	[NombreImpresora] [varchar](200) NULL,
	[HardwareCaracterCajon] [varchar](50) NULL,
	[EmpleadoPorcDescuento] [decimal](5, 2) NULL,
	[EmpleadoGlobal] [bit] NULL,
	[EmpleadoIndividual] [bit] NULL,
	[MontoImpresionTicket] [money] NULL,
	[ApartadoAnticipo1] [money] NULL,
	[ApartadoAnticipoHasta1] [money] NULL,
	[ApartadoAnticipo2] [money] NULL,
	[ApatadoAnticipoEnAdelante2] [money] NULL,
	[PorcentajeUtilidadProd] [decimal](5, 2) NULL,
	[DesgloceMontoTicket] [bit] NULL,
	[RetiroReqClaveSup] [bit] NULL,
	[CajDeclaracionFondoCorte] [bit] NULL,
	[SupDeclaracionFondoCorte] [bit] NULL,
	[vistaPreviaImpresion] [bit] NULL,
	[CajeroCorteDetGasto] [bit] NULL,
	[SupCorteDetGasto] [bit] NULL,
	[CajeroCorteCancelaciones] [bit] NULL,
	[SupCorteCancelaciones] [bit] NULL,
	[DevDiasVale] [tinyint] NULL,
	[DevDiasGarantia] [tinyint] NULL,
	[DevHorasGarantia] [tinyint] NULL,
	[ApartadoDiasLiq] [tinyint] NULL,
	[ApartadoDiasProrroga] [tinyint] NULL,
	[ReqClaveSupReimpresionTicketPV] [bit] NULL,
	[ReqClaveSupCancelaTicketPV] [bit] NULL,
	[ReqClaveSupGastosPV] [bit] NULL,
	[ReqClaveSupDevolucionPV] [bit] NULL,
	[ReqClaveSupApartadoPV] [bit] NULL,
	[ReqClaveSupExistenciaPV] [bit] NULL,
	[SerieTicketVenta] [char](3) NULL,
	[SerieTicketApartado] [char](3) NULL,
	[CorteCajaIncluirExistencia] [bit] NULL,
	[ImprimirTicketMediaCarta] [bit] NULL,
	[Giro] [varchar](10) NULL,
	[SolicitarComanda] [bit] NULL,
	[TieneRec] [bit] NULL,
	[PorcRec] [decimal](5, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_restaurante]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_restaurante](
	[Id] [int] NOT NULL,
	[SolicitarFolioComanda] [bit] NOT NULL,
 CONSTRAINT [PK_cat_configuracion_restaurante] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_ticket_apartado]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_ticket_apartado](
	[ConfiguracionTicketVentaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TextoCabecera1] [varchar](250) NOT NULL,
	[TextoCabecera2] [varchar](250) NOT NULL,
	[TextoPie] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Serie] [varchar](5) NULL,
 CONSTRAINT [PK_cat_configuracion_ticket_apartado] PRIMARY KEY CLUSTERED 
(
	[ConfiguracionTicketVentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_configuracion_ticket_venta]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_configuracion_ticket_venta](
	[ConfiguracionTicketVentaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[TextoCabecera1] [varchar](250) NOT NULL,
	[TextoCabecera2] [varchar](250) NOT NULL,
	[TextoPie] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Serie] [varchar](5) NULL,
 CONSTRAINT [PK_cat_configuracion_ticket_venta] PRIMARY KEY CLUSTERED 
(
	[ConfiguracionTicketVentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_denominaciones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_denominaciones](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Valor] [money] NULL,
	[Orden] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_divisiones_sat]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_divisiones_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](2) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[codigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_empresas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_empresas](
	[Clave] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[NombreComercial] [varchar](100) NULL,
	[RegimenFiscal] [varchar](100) NULL,
	[RFC] [varchar](20) NULL,
	[Calle] [varchar](100) NULL,
	[Colonia] [varchar](100) NULL,
	[NoExt] [varchar](20) NULL,
	[NoInt] [varchar](20) NULL,
	[CP] [varchar](20) NULL,
	[Ciudad] [varchar](50) NULL,
	[Estado] [varchar](50) NULL,
	[Pais] [varchar](50) NULL,
	[Telefono1] [varchar](40) NULL,
	[Telefono2] [varchar](40) NULL,
	[Email] [varchar](60) NULL,
	[FechaAlta] [date] NULL,
	[Estatus] [bit] NULL,
	[Logo] [image] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estados]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estados](
	[EstadoId] [int] NOT NULL,
	[PaisId] [smallint] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
 CONSTRAINT [PK_cat_estados] PRIMARY KEY CLUSTERED 
(
	[EstadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_estatus_pedido]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_estatus_pedido](
	[EstatusPedidoId] [smallint] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_pedido_estatus] PRIMARY KEY CLUSTERED 
(
	[EstatusPedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_familias]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_familias](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[ProductoPortadaId] [int] NULL,
	[Orden] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_formas_pago]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_formas_pago](
	[FormaPagoId] [int] NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
	[Abreviatura] [varchar](10) NOT NULL,
	[Orden] [smallint] NOT NULL,
	[RequiereDigVerificador] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[Signo] [varchar](1) NOT NULL,
	[NumeroHacienda] [smallint] NOT NULL,
 CONSTRAINT [PK_cat_formas_pago] PRIMARY KEY CLUSTERED 
(
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_gastos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_gastos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[ClaveCentroCosto] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[Monto] [money] NULL,
	[Observaciones] [varchar](300) NULL,
	[ConceptoId] [int] NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[CajaId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_giros]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_giros](
	[GiroId] [smallint] NOT NULL,
	[Descripcion] [varchar](200) NOT NULL,
 CONSTRAINT [PK_cat_giros] PRIMARY KEY CLUSTERED 
(
	[GiroId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_giros_neg]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_giros_neg](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_grupos_sat]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_grupos_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impresoras]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impresoras](
	[ImpresoraId] [smallint] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[NombreRed] [varchar](250) NOT NULL,
	[NombreImpresora] [varchar](150) NOT NULL,
	[Activa] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_impresoras] PRIMARY KEY CLUSTERED 
(
	[ImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impresoras_comandas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impresoras_comandas](
	[ImpresoraId] [smallint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_impresoras_comandas] PRIMARY KEY CLUSTERED 
(
	[ImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_impuestos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_impuestos](
	[Clave] [int] NOT NULL,
	[CodigoSAT] [varchar](15) NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[IdAbreviatura] [int] NOT NULL,
	[OrdenImpresion] [tinyint] NOT NULL,
	[IdClasificacionImpuesto] [int] NOT NULL,
	[IdTipoFactor] [int] NOT NULL,
	[Porcentaje] [decimal](5, 2) NULL,
	[CuotaFija] [money] NULL,
	[DecimalesPorcCuota] [tinyint] NULL,
	[DesglosarImpPrecioVta] [bit] NULL,
	[AgregarImpPrecioVta] [bit] NULL,
 CONSTRAINT [PK_cat_impuestos] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_lineas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_lineas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_lotes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_lotes](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_marcas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_marcas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_monedas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_monedas](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Abreviacion] [varchar](20) NULL,
	[TipoCambio] [decimal](18, 0) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[IdMonedaAbreviatura] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_monedas_abreviaturas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_monedas_abreviaturas](
	[IdMonedaAbreviatura] [int] NOT NULL,
	[NombreMonedaSAT] [varchar](200) NOT NULL,
	[ClaveSAT] [varchar](20) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_monedas_abreviaturas] PRIMARY KEY CLUSTERED 
(
	[IdMonedaAbreviatura] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_municipios]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_municipios](
	[MunicipioId] [int] NOT NULL,
	[EstadoId] [int] NOT NULL,
	[Nombre] [varchar](100) NULL,
 CONSTRAINT [PK_cat_municipios] PRIMARY KEY CLUSTERED 
(
	[MunicipioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_paises]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_paises](
	[PaisId] [smallint] NOT NULL,
	[Nombre] [varchar](50) NULL,
 CONSTRAINT [PK_cat_paises] PRIMARY KEY CLUSTERED 
(
	[PaisId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_paqueterias]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_paqueterias](
	[PaqueteriaId] [int] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_paqueterias] PRIMARY KEY CLUSTERED 
(
	[PaqueteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_precios]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_precios](
	[IdPrecio] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NULL,
 CONSTRAINT [PK_cat_precios] PRIMARY KEY CLUSTERED 
(
	[IdPrecio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos](
	[ProductoId] [int] NOT NULL,
	[Clave] [varchar](30) NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[DescripcionCorta] [varchar](30) NULL,
	[FechaAlta] [date] NULL,
	[ClaveMarca] [int] NULL,
	[ClaveFamilia] [int] NULL,
	[ClaveSubFamilia] [int] NULL,
	[ClaveLinea] [int] NULL,
	[ClaveUnidadMedida] [int] NULL,
	[ClaveInventariadoPor] [int] NULL,
	[ClaveVendidaPor] [int] NULL,
	[Estatus] [bit] NULL,
	[ProductoTerminado] [bit] NULL,
	[Inventariable] [bit] NULL,
	[MateriaPrima] [bit] NULL,
	[ProdParaVenta] [bit] NULL,
	[ProdVtaBascula] [bit] NULL,
	[Seriado] [bit] NULL,
	[NumeroDecimales] [tinyint] NULL,
	[PorcDescuentoEmpleado] [numeric](19, 2) NULL,
	[ContenidoCaja] [int] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[Foto] [image] NULL,
	[ClaveAlmacen] [int] NULL,
	[ClaveAnden] [int] NULL,
	[ClaveLote] [int] NULL,
	[FechaCaducidad] [datetime] NULL,
	[MinimoInventario] [decimal](14, 2) NULL,
	[MaximoInventario] [decimal](14, 2) NULL,
	[PorcUtilidad] [decimal](5, 2) NULL,
	[Talla] [varchar](5) NULL,
	[ParaSexo] [varchar](1) NULL,
	[Color] [varchar](10) NULL,
	[Color2] [varchar](10) NULL,
	[SobrePedido] [bit] NULL,
	[Especificaciones] [varchar](500) NULL,
	[Liquidacion] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_agrupados]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_agrupados](
	[ProductoAgrupadoId] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[DescripcionCorta] [varchar](30) NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Especificaciones] [varchar](500) NULL,
	[ProductoId] [int] NOT NULL,
	[Rating] [tinyint] NULL,
	[Liquidacion] [bit] NULL,
 CONSTRAINT [PK_cat_productos_agrupados] PRIMARY KEY CLUSTERED 
(
	[ProductoAgrupadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_agrupados_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_agrupados_detalle](
	[ProductoAgrupadoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_productos_agrupados_detalle] PRIMARY KEY CLUSTERED 
(
	[ProductoAgrupadoId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_base]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_base](
	[ProductoMateriaPrimaId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ProductoBaseId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_productos_base] PRIMARY KEY CLUSTERED 
(
	[ProductoMateriaPrimaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_cambio_precio]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_cambio_precio](
	[Id] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[PrecioId] [tinyint] NOT NULL,
	[PrecioAnterior] [money] NOT NULL,
	[PrecioNuevo] [money] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioRegistroId] [int] NULL,
 CONSTRAINT [PK_cat_productos_cambio_precio] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_config_sucursal]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_config_sucursal](
	[ProductoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[CalculaPrecioPorcUtilidad] [bit] NOT NULL,
	[CalculaPrecioIncUtilidad] [bit] NOT NULL,
	[CalculaPrecioManual] [bit] NOT NULL,
	[PorcUtilidadValor] [decimal](6, 2) NOT NULL,
	[IncUtilidadValor] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
 CONSTRAINT [PK_cat_productos_config_sucursal] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_existencias]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_existencias](
	[ProductoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ExistenciaTeorica] [decimal](14, 2) NOT NULL,
	[CostoUltimaCompra] [money] NOT NULL,
	[CostoPromedio] [money] NOT NULL,
	[ValCostoUltimaCompra] [money] NOT NULL,
	[ValCostoPromedio] [money] NOT NULL,
	[ModificadoEl] [datetime] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Apartado] [decimal](14, 2) NULL,
	[Disponible] [decimal](14, 2) NULL,
 CONSTRAINT [PK_cat_productos_existencias] PRIMARY KEY CLUSTERED 
(
	[ProductoId] ASC,
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_imagenes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_imagenes](
	[ProductoImageId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[FileName] [varchar](250) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[FileByte] [image] NULL,
	[Principal] [bit] NULL,
	[Miniatura] [bit] NULL,
 CONSTRAINT [PK_cat_productos_imagenes] PRIMARY KEY CLUSTERED 
(
	[ProductoImageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_impuestos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_impuestos](
	[ProductoImpuestoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[ImpuestoId] [int] NOT NULL,
 CONSTRAINT [PK_cat_productos_impuestos] PRIMARY KEY CLUSTERED 
(
	[ProductoImpuestoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_productos_precios]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_productos_precios](
	[IdProductoPrecio] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdPrecio] [tinyint] NOT NULL,
	[PorcDescuento] [decimal](14, 2) NOT NULL,
	[MontoDescuento] [money] NOT NULL,
	[Precio] [money] NOT NULL,
 CONSTRAINT [PK_cat_productos_precios] PRIMARY KEY CLUSTERED 
(
	[IdProductoPrecio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_proveedores]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_proveedores](
	[ProveedorId] [int] NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[RFC] [varchar](15) NULL,
	[Calle] [varchar](100) NULL,
	[NumeroExt] [varchar](10) NULL,
	[NumeroInt] [varchar](10) NULL,
	[Colonia] [varchar](50) NULL,
	[CodigoPostal] [varchar](5) NULL,
	[EstadoId] [int] NULL,
	[MunicipioId] [int] NULL,
	[PaisId] [smallint] NULL,
	[Telefono] [varchar](15) NULL,
	[Telefono2] [varchar](15) NULL,
	[TipoProveedorId] [tinyint] NULL,
	[DiasCredito] [smallint] NULL,
	[LimiteCredito] [money] NULL,
	[CreditoDisponible] [money] NULL,
	[SaldoGlobal] [money] NULL,
	[Activo] [bit] NULL,
	[ClienteEspecial] [bit] NULL,
	[ClienteGral] [bit] NULL,
	[PrecioId] [tinyint] NULL,
	[GiroId] [int] NULL,
 CONSTRAINT [PK_cat_proveedores] PRIMARY KEY CLUSTERED 
(
	[ProveedorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_comandas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_comandas](
	[ComandaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Folio] [int] NOT NULL,
	[Disponible] [bit] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_rest_comandas] PRIMARY KEY CLUSTERED 
(
	[ComandaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_mesas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_mesas](
	[MesaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Nombre] [varchar](20) NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_cat_rest_mesas] PRIMARY KEY CLUSTERED 
(
	[MesaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_platillo_adicionales]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_platillo_adicionales](
	[Id] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[MostrarSiempre] [bit] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_cat_rest_platillo_adicionales] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rest_platillo_adicionales_sfam]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rest_platillo_adicionales_sfam](
	[PlatilloAdicionalId] [int] NOT NULL,
	[SubfamiliaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_rest_platillo_adicionales_sfam] PRIMARY KEY CLUSTERED 
(
	[PlatilloAdicionalId] ASC,
	[SubfamiliaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_rubros]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_rubros](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sitios_entrega_pedido]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sitios_entrega_pedido](
	[SitioEntregaPedidoId] [smallint] NOT NULL,
	[Descripcion] [varchar](200) NOT NULL,
	[CiudadId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_sitios_entrega_pedido] PRIMARY KEY CLUSTERED 
(
	[SitioEntregaPedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_subclases_sat]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_subclases_sat](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](150) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[CodigoSAT] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_subfamilias]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_subfamilias](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[Familia] [int] NOT NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_sucursales]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_sucursales](
	[Clave] [int] NOT NULL,
	[Empresa] [int] NULL,
	[Calle] [varchar](50) NULL,
	[Colonia] [varchar](50) NULL,
	[NoExt] [nchar](20) NULL,
	[NoInt] [nchar](20) NULL,
	[Ciudad] [varchar](60) NULL,
	[Estado] [varchar](60) NULL,
	[Pais] [varchar](60) NULL,
	[Telefono1] [varchar](40) NULL,
	[Telefono2] [varchar](40) NULL,
	[Email] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[NombreSucursal] [varchar](60) NULL,
	[CP] [varchar](5) NULL,
	[ServidorMailSMTP] [varchar](50) NULL,
	[ServidorMailFrom] [varchar](70) NULL,
	[ServidorMailPort] [smallint] NULL,
	[ServidorMailPassword] [varchar](50) NULL,
 CONSTRAINT [PK_cat_sucursales] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipo_factor_SAT]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipo_factor_SAT](
	[Clave] [int] NOT NULL,
	[NombreFactorSAT] [varchar](150) NOT NULL,
	[Activo] [bit] NULL,
 CONSTRAINT [PK_cat_tipo_factor_SAT] PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_cliente]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_cliente](
	[TipoClienteId] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NOT NULL,
 CONSTRAINT [PK_cat_tipos_cliente] PRIMARY KEY CLUSTERED 
(
	[TipoClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_devolucion]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_devolucion](
	[TipoDevolucionId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
 CONSTRAINT [PK_cat_tipos_devolucion] PRIMARY KEY CLUSTERED 
(
	[TipoDevolucionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_direcciones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_direcciones](
	[TipoDireccionId] [tinyint] NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_cat_tipos_direcciones] PRIMARY KEY CLUSTERED 
(
	[TipoDireccionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_documento]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_documento](
	[TipoDocumentoId] [tinyint] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[Abreviatura] [varchar](3) NOT NULL,
	[FolioInicial] [int] NOT NULL,
	[RequiereClaveSuper] [bit] NOT NULL,
	[IntegrarCorteCaja] [bit] NOT NULL,
 CONSTRAINT [PK_cat_tipos_documento] PRIMARY KEY CLUSTERED 
(
	[TipoDocumentoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_movimiento_inventario]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_movimiento_inventario](
	[TipoMovimientoInventarioId] [int] NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[Activo] [bit] NOT NULL,
	[EsEntrada] [bit] NULL,
	[TipoMovimientoCancelacionId] [int] NULL,
 CONSTRAINT [PK_cat_tipo_movimiento_inventario] PRIMARY KEY CLUSTERED 
(
	[TipoMovimientoInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_proveedor]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_proveedor](
	[TipoProveedorId] [tinyint] NOT NULL,
	[Descripcion] [varchar](100) NULL,
 CONSTRAINT [PK_cat_tipos_proveedor] PRIMARY KEY CLUSTERED 
(
	[TipoProveedorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_tipos_vale]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_tipos_vale](
	[TipoValeId] [int] NOT NULL,
	[Descripcion] [varchar](55) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_tipos_vale] PRIMARY KEY CLUSTERED 
(
	[TipoValeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_unidades_medida_SAT]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_unidades_medida_SAT](
	[IdUnidadMedidaSAT] [int] NOT NULL,
	[ClaveSAT] [varchar](20) NOT NULL,
	[NombreSAT] [varchar](100) NOT NULL,
	[DescripcionSAT] [varchar](500) NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_cat_unidades_medida_SAT] PRIMARY KEY CLUSTERED 
(
	[IdUnidadMedidaSAT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_unidadesmed]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_unidadesmed](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NOT NULL,
	[DescripcionCorta] [varchar](20) NULL,
	[Decimales] [int] NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[IdCodigoSAT] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_usuarios]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_usuarios](
	[IdUsuario] [int] NOT NULL,
	[IdEmpleado] [int] NOT NULL,
	[NombreUsuario] [varchar](50) NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Activo] [bit] NULL,
	[EsSupervisor] [bit] NULL,
	[PasswordSupervisor] [varchar](20) NULL,
	[IdSucursal] [int] NULL,
	[EsSupervisorCajero] [bit] NULL,
	[PasswordSupervisorCajero] [varchar](20) NULL,
	[Email] [varchar](100) NULL,
 CONSTRAINT [PK_cat_usuarios] PRIMARY KEY CLUSTERED 
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[cat_web_configuracion]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cat_web_configuracion](
	[SucursalId] [int] NOT NULL,
	[Dominio] [varchar](100) NOT NULL,
	[ServidorFTP] [varchar](50) NOT NULL,
	[UsuarioFTP] [varchar](50) NOT NULL,
	[PasswordFTP] [varchar](20) NOT NULL,
	[FolderProductos] [varchar](150) NOT NULL,
	[DiasEntregaAdicSPedido] [tinyint] NULL,
	[DiasEntregaPedido] [tinyint] NULL,
 CONSTRAINT [PK_cat_web_configuracion] PRIMARY KEY CLUSTERED 
(
	[SucursalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados](
	[ApartadoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[TotalApartado] [money] NOT NULL,
	[Saldo] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[FechaLimite] [datetime] NULL,
	[FechaProrroga] [datetime] NULL,
	[VentaId] [bigint] NULL,
	[CajaId] [int] NULL,
 CONSTRAINT [PK_doc_apartados] PRIMARY KEY CLUSTERED 
(
	[ApartadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_formas_pago]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_formas_pago](
	[ApartadoPagoId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Cantidad] [money] NOT NULL,
	[DigitoVerificador] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_apartados_formas_pago] PRIMARY KEY CLUSTERED 
(
	[ApartadoPagoId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_pagos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_pagos](
	[ApartadoPagoId] [int] NOT NULL,
	[ApartadoId] [int] NOT NULL,
	[Importe] [money] NOT NULL,
	[FechaPago] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Anticipo] [bit] NOT NULL,
	[CajaId] [int] NULL,
 CONSTRAINT [PK_doc_apartados_pagos] PRIMARY KEY CLUSTERED 
(
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_apartados_productos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_apartados_productos](
	[ApartadoProductoId] [int] NOT NULL,
	[ApartadoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](7, 2) NOT NULL,
	[Precio] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[SubTotal] [money] NULL,
	[Impuestos] [money] NULL,
	[Descuentos] [money] NULL,
	[POrcentajeDescuento] [decimal](5, 2) NULL,
 CONSTRAINT [PK_cat_apartados_productos] PRIMARY KEY CLUSTERED 
(
	[ApartadoProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja](
	[CorteCajaId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[VentaIniId] [bigint] NULL,
	[VentaFinId] [bigint] NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCorte] [datetime] NOT NULL,
	[TotalCorte] [money] NOT NULL,
	[TotalIngresos] [money] NOT NULL,
	[TotalEgresos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_apartados_pagos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_apartados_pagos](
	[CorteCajaId] [int] NOT NULL,
	[ApartadoPagoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_apartados_pagos] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_apartados_pagos_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_apartados_pagos_previo](
	[CorteCajaId] [int] NOT NULL,
	[ApartadoPagoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_apartados_pagos_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[ApartadoPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_denominaciones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_denominaciones](
	[CorteCajaId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Valor] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_denominaciones] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[DenominacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_denominaciones_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_denominaciones_previo](
	[CorteCajaId] [int] NOT NULL,
	[DenominacionId] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[Valor] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_denominaciones_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[DenominacionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_egresos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_egresos](
	[CorteCajaId] [int] NOT NULL,
	[Gastos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_egresos] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_egresos_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_egresos_previo](
	[CorteCajaId] [int] NOT NULL,
	[Gastos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_egresos_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_apartado]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_apartado](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_apartado] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_apartado_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_apartado_previo](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_apartado_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_fp_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_fp_previo](
	[CorteCajaId] [int] NOT NULL,
	[FormaPagoId] [int] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_fp_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC,
	[FormaPagoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_previo](
	[CorteCajaId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[VentaIniId] [bigint] NULL,
	[VentaFinId] [bigint] NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCorte] [datetime] NOT NULL,
	[TotalCorte] [money] NOT NULL,
	[TotalIngresos] [money] NOT NULL,
	[TotalEgresos] [money] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_previo] PRIMARY KEY CLUSTERED 
(
	[CorteCajaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_ventas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_ventas](
	[CorteId] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_ventas] PRIMARY KEY CLUSTERED 
(
	[CorteId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_corte_caja_ventas_previo]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_corte_caja_ventas_previo](
	[CorteId] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_corte_caja_ventas_previo] PRIMARY KEY CLUSTERED 
(
	[CorteId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_devoluciones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_devoluciones](
	[DevolucionId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[TipoDevolucionId] [int] NULL,
	[FechaVencimiento] [datetime] NULL,
 CONSTRAINT [PK_doc_devoluciones_1] PRIMARY KEY CLUSTERED 
(
	[DevolucionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_devoluciones_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_devoluciones_detalle](
	[DevolucionDetId] [int] NOT NULL,
	[DevolucionId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_devoluciones_detalle] PRIMARY KEY CLUSTERED 
(
	[DevolucionDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_entrada_directa_adicional]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_entrada_directa_adicional](
	[MovimientoDetalleId] [int] NOT NULL,
	[PrecioCompra] [money] NOT NULL,
 CONSTRAINT [PK_doc_entrada_directa_adicional] PRIMARY KEY CLUSTERED 
(
	[MovimientoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_gastos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_gastos](
	[GastoId] [int] NOT NULL,
	[CentroCostoId] [int] NOT NULL,
	[GastoConceptoId] [int] NOT NULL,
	[Obervaciones] [varchar](300) NOT NULL,
	[Monto] [money] NOT NULL,
	[CajaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
 CONSTRAINT [PK_doc_gastos] PRIMARY KEY CLUSTERED 
(
	[GastoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_carga_inicial]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_carga_inicial](
	[CargaInventarioId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](15, 2) NOT NULL,
	[CostoPromedio] [money] NOT NULL,
	[UltimoCosto] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_inv_carga_inicial] PRIMARY KEY CLUSTERED 
(
	[CargaInventarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_movimiento]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_movimiento](
	[MovimientoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[FolioMovimiento] [varchar](10) NOT NULL,
	[TipoMovimientoId] [int] NOT NULL,
	[FechaMovimiento] [datetime] NOT NULL,
	[HoraMovimiento] [time](7) NOT NULL,
	[Comentarios] [varchar](250) NOT NULL,
	[ImporteTotal] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Autorizado] [bit] NULL,
	[FechaAutoriza] [datetime] NULL,
	[SucursalDestinoId] [int] NULL,
	[AutorizadoPor] [int] NULL,
	[FechaCancelacion] [datetime] NULL,
	[ProductoCompraId] [int] NULL,
	[Consecutivo] [int] NULL,
	[SucursalOrigenId] [int] NULL,
	[VentaId] [bigint] NULL,
	[MovimientoRefId] [int] NULL,
	[Cancelado] [bit] NULL,
 CONSTRAINT [PK_doc_inv_movimiento] PRIMARY KEY CLUSTERED 
(
	[MovimientoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_inv_movimiento_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_inv_movimiento_detalle](
	[MovimientoDetalleId] [int] NOT NULL,
	[MovimientoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Consecutivo] [smallint] NOT NULL,
	[Cantidad] [decimal](14, 3) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[Importe] [money] NOT NULL,
	[Disponible] [decimal](14, 3) NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CostoUltimaCompra] [money] NULL,
	[CostoPromedio] [money] NULL,
	[ValCostoUltimaCompra] [money] NULL,
	[ValCostoPromedio] [money] NULL,
	[ValorMovimiento] [money] NULL,
 CONSTRAINT [PK_doc_inv_movimiento_detalle] PRIMARY KEY CLUSTERED 
(
	[MovimientoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos](
	[PedidoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[PedidoConfiguracionId] [int] NULL,
	[ClienteId] [int] NOT NULL,
	[CiudadId] [int] NOT NULL,
	[LugarEntrega] [varchar](300) NULL,
	[FechaEntrega] [date] NOT NULL,
	[HoraEntrega] [timestamp] NOT NULL,
	[EstatusId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos] PRIMARY KEY CLUSTERED 
(
	[PedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_clientes]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_clientes](
	[PedidoClienteId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ClienteId] [int] NOT NULL,
	[EstatusId] [smallint] NOT NULL,
	[FechaEntregaProgramada] [datetime] NOT NULL,
	[HoraEntrega] [time](7) NULL,
	[FechaEntregaReal] [datetime] NULL,
	[SitioEntregaId] [smallint] NULL,
	[ClienteDireccionId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
	[PedidoConfiguracionId] [int] NULL,
	[CostoEnvio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_clientes] PRIMARY KEY CLUSTERED 
(
	[PedidoClienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_clientes_det]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_clientes_det](
	[PedidoClienteDetId] [int] NOT NULL,
	[PedidoClienteId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](8, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Precio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_clientes_det] PRIMARY KEY CLUSTERED 
(
	[PedidoClienteDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_configuracion]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_configuracion](
	[PedidoConfiguracionId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Descripcion] [varchar](50) NOT NULL,
	[Inicio] [date] NOT NULL,
	[Cierre] [date] NOT NULL,
	[FechaLlegada] [date] NULL,
	[FechaInicioEntrega] [date] NULL,
	[FechaFinEntrega] [date] NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[ModificadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
 CONSTRAINT [PK_doc_pedidos_configuracion] PRIMARY KEY CLUSTERED 
(
	[PedidoConfiguracionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_configuracion_det]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_configuracion_det](
	[PedidoConfiguracionDetId] [int] NOT NULL,
	[PedidoConfiguracionId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Precio] [money] NULL,
 CONSTRAINT [PK_doc_pedidos_configuracion_det_1] PRIMARY KEY CLUSTERED 
(
	[PedidoConfiguracionDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden](
	[PedidoId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[ComandaId] [int] NULL,
	[PorcDescuento] [decimal](5, 2) NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[ClienteId] [int] NULL,
	[MotivoCancelacion] [varchar](150) NULL,
	[Activo] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[Personas] [tinyint] NOT NULL,
	[FechaApertura] [datetime] NOT NULL,
	[FechaCierre] [datetime] NOT NULL,
	[VentaId] [bigint] NULL,
	[Cancelada] [bit] NULL,
	[FechaCancelacion] [datetime] NULL,
	[CanceladoPor] [int] NULL,
 CONSTRAINT [PK_cat_rest_comandas_orden] PRIMARY KEY CLUSTERED 
(
	[PedidoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_adicional]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_adicional](
	[PedidoDetalleId] [int] NOT NULL,
	[AdicionalId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_adicional] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC,
	[AdicionalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_detalle](
	[PedidoDetalleId] [int] NOT NULL,
	[PedidoId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 3) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcDescuento] [decimal](5, 2) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Notas] [varchar](200) NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[TasaIVA] [decimal](5, 2) NOT NULL,
	[Impreso] [bit] NULL,
	[ComandaId] [int] NULL,
	[Parallevar] [bit] NULL,
	[Cancelado] [bit] NULL,
 CONSTRAINT [PK_doc_pedidos_orden_detalle] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_ingre]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_ingre](
	[PedidoDetalleId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Con] [bit] NOT NULL,
	[Sin] [bit] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_ingre] PRIMARY KEY CLUSTERED 
(
	[PedidoDetalleId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_mesa]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_mesa](
	[PedidoOrdenId] [int] NOT NULL,
	[MesaId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_mesa] PRIMARY KEY CLUSTERED 
(
	[PedidoOrdenId] ASC,
	[MesaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_pedidos_orden_mesero]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_pedidos_orden_mesero](
	[PedidoOrdenId] [int] NOT NULL,
	[EmpleadoId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_pedidos_orden_mesero] PRIMARY KEY CLUSTERED 
(
	[PedidoOrdenId] ASC,
	[EmpleadoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_compra]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_compra](
	[ProductoCompraId] [int] NOT NULL,
	[ProveedorId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[NumeroRemision] [varchar](50) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[Activo] [bit] NOT NULL,
	[FechaCancelacion] [datetime] NULL,
	[CanceladoPor] [int] NULL,
	[FechaRemision] [datetime] NULL,
	[PrecioAfectado] [bit] NULL,
	[PrecioConImpuestos] [bit] NULL,
	[SucursalId] [int] NULL,
 CONSTRAINT [PK_doc_productos_compra] PRIMARY KEY CLUSTERED 
(
	[ProductoCompraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_compra_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_compra_detalle](
	[ProductoCompraDetId] [int] NOT NULL,
	[ProductoCompraId] [int] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcImpuestos] [decimal](5, 2) NOT NULL,
	[Impuestos] [money] NOT NULL,
	[PorcDescuentos] [decimal](5, 2) NOT NULL,
	[Descuentos] [money] NOT NULL,
	[Subtotal] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[PrecioNeto] [money] NULL,
	[PrecioCompra] [money] NULL,
 CONSTRAINT [PK_doc_productos_compra_detalle] PRIMARY KEY CLUSTERED 
(
	[ProductoCompraDetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_productos_importacion_bitacora]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_productos_importacion_bitacora](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UUID] [uniqueidentifier] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[TipoMovimientoInventarioId] [int] NOT NULL,
	[Cantidad] [decimal](14, 2) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
 CONSTRAINT [PK_doc_productos_importacion_bitacora] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones](
	[PromocionId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[PorcentajeDescuento] [decimal](5, 2) NOT NULL,
	[FechaInicioVigencia] [datetime] NOT NULL,
	[FechaFinVigencia] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[EmpresaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Activo] [bit] NOT NULL,
	[NombrePromocion] [varchar](100) NULL,
	[Lunes] [bit] NULL,
	[Martes] [bit] NULL,
	[Miercoles] [bit] NULL,
	[Jueves] [bit] NULL,
	[Viernes] [bit] NULL,
	[Sabado] [bit] NULL,
	[Domingo] [bit] NULL,
	[Permanente] [bit] NULL,
 CONSTRAINT [PK_doc_promociones] PRIMARY KEY CLUSTERED 
(
	[PromocionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_detalle](
	[PromocionDetalleId] [int] NOT NULL,
	[PromocionId] [int] NOT NULL,
	[LineaId] [int] NULL,
	[FamiliaId] [int] NULL,
	[Subfamilia] [int] NULL,
	[ProductoId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_promociones_detalle] PRIMARY KEY CLUSTERED 
(
	[PromocionDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_promociones_excepcion]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_promociones_excepcion](
	[PromocionExcepcionId] [int] NOT NULL,
	[PromocionId] [int] NOT NULL,
	[LineaId] [int] NULL,
	[FamiliaId] [int] NULL,
	[Subfamilia] [int] NULL,
	[ProductoId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_promociones_excepcion] PRIMARY KEY CLUSTERED 
(
	[PromocionExcepcionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_reimpresion_ticket]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_reimpresion_ticket](
	[ReimpresionTicketId] [int] NOT NULL,
	[FechaReimpresion] [datetime] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
 CONSTRAINT [PK_doc_reimpresion_ticket] PRIMARY KEY CLUSTERED 
(
	[ReimpresionTicketId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_retiros]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_retiros](
	[RetiroId] [int] NOT NULL,
	[FechaRetiro] [datetime] NOT NULL,
	[MontoRetiro] [money] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[SucursalId] [int] NOT NULL,
	[Observaciones] [varchar](300) NOT NULL,
 CONSTRAINT [PK_doc_retiros] PRIMARY KEY CLUSTERED 
(
	[RetiroId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_sesiones_punto_venta]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_sesiones_punto_venta](
	[SesionId] [int] NOT NULL,
	[UsuarioId] [int] NOT NULL,
	[CajaId] [int] NOT NULL,
	[FechaInicio] [datetime] NOT NULL,
	[FechaUltimaConexion] [datetime] NULL,
	[CorteAplicado] [bit] NULL,
	[FechaCorte] [datetime] NULL,
	[Finalizada] [bit] NULL,
	[CorteCajaId] [int] NULL,
 CONSTRAINT [PK_doc_sesiones_punto_venta] PRIMARY KEY CLUSTERED 
(
	[SesionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas](
	[VentaId] [bigint] NOT NULL,
	[Folio] [varchar](20) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[ClienteId] [int] NULL,
	[DescuentoVentaSiNo] [bit] NULL,
	[PorcDescuentoVenta] [decimal](5, 2) NULL,
	[MontoDescuentoVenta] [money] NULL,
	[DescuentoEnPartidas] [money] NULL,
	[TotalDescuento] [money] NULL,
	[Impuestos] [money] NOT NULL,
	[SubTotal] [money] NOT NULL,
	[TotalVenta] [money] NOT NULL,
	[TotalRecibido] [money] NOT NULL,
	[Cambio] [money] NOT NULL,
	[Activo] [bit] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[UsuarioCancelacionId] [int] NULL,
	[FechaCancelacion] [datetime] NULL,
	[SucursalId] [int] NULL,
	[CajaId] [int] NULL,
	[Serie] [varchar](5) NULL,
	[MotivoCancelacion] [varchar](150) NULL,
	[Rec] [bit] NULL,
 CONSTRAINT [PK_doc_ventas] PRIMARY KEY CLUSTERED 
(
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_detalle](
	[VentaDetalleId] [bigint] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](14, 3) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[PorcDescuneto] [decimal](5, 2) NOT NULL,
	[Descuento] [money] NOT NULL,
	[Impuestos] [money] NOT NULL,
	[Total] [money] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[TasaIVA] [decimal](5, 2) NULL,
 CONSTRAINT [PK_doc_ventas_detalle] PRIMARY KEY CLUSTERED 
(
	[VentaDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_formas_pago]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_formas_pago](
	[FormaPagoId] [int] NOT NULL,
	[VentaId] [bigint] NOT NULL,
	[Cantidad] [money] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[UsuarioCreacionId] [int] NOT NULL,
	[digitoVerificador] [varchar](20) NULL,
 CONSTRAINT [PK_doc_ventas_formas_pago] PRIMARY KEY CLUSTERED 
(
	[FormaPagoId] ASC,
	[VentaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_formas_pago_vale]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_formas_pago_vale](
	[Id] [int] NOT NULL,
	[VentaId] [int] NOT NULL,
	[TipoValeId] [int] NOT NULL,
	[Monto] [money] NOT NULL,
	[DevolucionId] [int] NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_ventas_formas_pago_vale] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_ventas_temp]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_ventas_temp](
	[VentaId] [int] NOT NULL,
	[VentaTempId] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_doc_ventas_temp] PRIMARY KEY CLUSTERED 
(
	[VentaId] ASC,
	[VentaTempId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_web_carrito]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_web_carrito](
	[uUID] [varchar](50) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Total] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[EnvioCalle] [varchar](250) NOT NULL,
	[EnvioColonia] [varchar](100) NOT NULL,
	[EnvioCiudad] [varchar](70) NOT NULL,
	[EnvioEstadoId] [int] NOT NULL,
	[EnvioCP] [varchar](5) NOT NULL,
	[EnvioPersonaRecibe] [varchar](250) NOT NULL,
	[EnvioTelefonoContacto] [varchar](20) NOT NULL,
	[ClienteId] [int] NULL,
	[Impuestos] [money] NULL,
	[Subtotal] [money] NULL,
	[Pagado] [bit] NULL,
	[FechaPago] [datetime] NULL,
	[VentaId] [bigint] NULL,
	[MontoPaypal] [varchar](20) NULL,
	[TransactionRef] [varchar](30) NULL,
	[FechaEstimadaEntrega] [datetime] NULL,
	[EntregadoEl] [datetime] NULL,
	[FormaPagoId] [tinyint] NULL,
 CONSTRAINT [PK_doc_web_carrito] PRIMARY KEY CLUSTERED 
(
	[uUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[doc_web_carrito_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[doc_web_carrito_detalle](
	[IdDetalle] [int] NOT NULL,
	[uUID] [varchar](50) NOT NULL,
	[ProductoId] [int] NOT NULL,
	[Cantidad] [decimal](10, 2) NOT NULL,
	[Descripcion] [varchar](250) NOT NULL,
	[PrecioUnitario] [money] NOT NULL,
	[Importe] [money] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Impuestos] [money] NULL,
	[Subtotal] [money] NULL,
	[Id] [int] NULL,
 CONSTRAINT [PK_doc_web_carrito_detalle] PRIMARY KEY CLUSTERED 
(
	[IdDetalle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_departamentos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_departamentos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_empleado_puestos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_empleado_puestos](
	[EmpleadoId] [int] NOT NULL,
	[PuestoId] [int] NOT NULL,
	[CreadoPor] [int] NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
 CONSTRAINT [PK_rh_empleado_puestos] PRIMARY KEY CLUSTERED 
(
	[EmpleadoId] ASC,
	[PuestoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_empleados]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_empleados](
	[NumEmpleado] [int] NOT NULL,
	[Nombre] [varchar](150) NOT NULL,
	[SueldoNeto] [money] NOT NULL,
	[SueldoDiario] [money] NULL,
	[SueldoHra] [money] NULL,
	[FormaPago] [int] NULL,
	[TipoContrato] [int] NULL,
	[Puesto] [int] NULL,
	[Departamento] [int] NULL,
	[FechaIngreso] [date] NULL,
	[FechaInicioLab] [date] NULL,
	[Estatus] [int] NULL,
	[Foto] [image] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[NumEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_estatus_empleados]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_estatus_empleados](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_formaspagonom]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_formaspagonom](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[NumDias] [int] NULL,
	[HrasDia] [int] NULL,
	[Estatus] [int] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_puestos]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_puestos](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
	[PermitirEliminar] [bit] NULL,
	[Mostrar] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[rh_tipos_contrato]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rh_tipos_contrato](
	[Clave] [int] NOT NULL,
	[Descripcion] [varchar](60) NULL,
	[Estatus] [bit] NULL,
	[Empresa] [int] NULL,
	[Sucursal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Clave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_bitacora_errores]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_bitacora_errores](
	[IdError] [int] NOT NULL,
	[Sistema] [varchar](50) NOT NULL,
	[Clase] [varchar](250) NULL,
	[Metodo] [varchar](250) NULL,
	[Error] [varchar](500) NOT NULL,
	[CreadoEl] [datetime] NULL,
 CONSTRAINT [PK_sis_bitacora_errores] PRIMARY KEY CLUSTERED 
(
	[IdError] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_versiones]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_versiones](
	[VersionId] [smallint] NOT NULL,
	[Nombre] [varchar](20) NOT NULL,
	[CreadoEl] [datetime] NOT NULL,
	[Completado] [bit] NOT NULL,
	[Intentos] [tinyint] NOT NULL,
 CONSTRAINT [PK_sis_versiones] PRIMARY KEY CLUSTERED 
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sis_versiones_detalle]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sis_versiones_detalle](
	[VersionDetalleId] [int] NOT NULL,
	[VersionId] [smallint] NOT NULL,
	[ScriptName] [varchar](250) NOT NULL,
	[Completado] [bit] NOT NULL,
 CONSTRAINT [PK_sis_versiones_detalle] PRIMARY KEY CLUSTERED 
(
	[VersionDetalleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos0]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos0](
	[IMAGEN] [image] NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos1]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos1](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos2]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos2](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos3]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos3](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos4]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos4](
	[IMAGEN] [nvarchar](255) NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tmpProductos5]    Script Date: 8/24/2019 6:10:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpProductos5](
	[IMAGEN] [image] NULL,
	[LINEA] [nvarchar](255) NULL,
	[PRODUCTO] [nvarchar](255) NULL,
	[CODIGO] [nvarchar](255) NULL,
	[DESCRIPCION CORTA] [nvarchar](255) NULL,
	[DESCRIPCION LARGA] [nvarchar](255) NULL,
	[PRECIO] [money] NULL,
	[EXISTENCIAS] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
INSERT [dbo].[cat_abreviaturas_SAT] ([Clave], [AbreviaturaSAT], [CodigoSAT], [Activo]) VALUES (1, N'IVA', N'', 1)
INSERT [dbo].[cat_cajas] ([Clave], [Descripcion], [Ubicacion], [Estatus], [Empresa], [Sucursal]) VALUES (1, N'Caja 1', N'SALIDA', 1, 1, 1)

INSERT [dbo].[cat_clasificacion_impuestos] ([Clave], [NombreSAT], [Activo]) VALUES (1, N'IVA', 1)
INSERT [dbo].[cat_configuracion] ([ConfiguradorId], [UnaFormaPago], [MasUnaFormaPago], [CosteoUEPS], [CosteoPEPS], [CosteoPromedio], [AfectarInventarioLinea], [AfectarInventarioManual], [AfectarInventarioCorte], [EnlazarPuntoVentaInventario], [CajeroIncluirDetalleVenta], [CajeroReqClaveSupervisor], [SuperIncluirDetalleVenta], [SuperIncluirVentaTel], [SuperIncluirDetGastos], [SuperEmail1], [SuperEmail2], [SuperEmail3], [SuperEmail4], [RetiroMontoEfec], [RetiroLectura], [RetiroEscritura], [NombreImpresora], [HardwareCaracterCajon], [EmpleadoPorcDescuento], [EmpleadoGlobal], [EmpleadoIndividual], [MontoImpresionTicket], [ApartadoAnticipo1], [ApartadoAnticipoHasta1], [ApartadoAnticipo2], [ApatadoAnticipoEnAdelante2], [PorcentajeUtilidadProd], [DesgloceMontoTicket], [RetiroReqClaveSup], [CajDeclaracionFondoCorte], [SupDeclaracionFondoCorte], [vistaPreviaImpresion], [CajeroCorteDetGasto], [SupCorteDetGasto], [CajeroCorteCancelaciones], [SupCorteCancelaciones], [DevDiasVale], [DevDiasGarantia], [DevHorasGarantia], [ApartadoDiasLiq], [ApartadoDiasProrroga], [ReqClaveSupReimpresionTicketPV], [ReqClaveSupCancelaTicketPV], [ReqClaveSupGastosPV], [ReqClaveSupDevolucionPV], [ReqClaveSupApartadoPV], [ReqClaveSupExistenciaPV], [SerieTicketVenta], [SerieTicketApartado], [CorteCajaIncluirExistencia], [ImprimirTicketMediaCarta], [Giro], [SolicitarComanda], [TieneRec], [PorcRec]) VALUES (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, N'', N'', N'', N'', 0.0000, 0, 0, N'Microsoft Print to PDF', N'', CAST(0.00 AS Decimal(5, 2)), 0, 0, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, CAST(0.00 AS Decimal(5, 2)), 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, 0, 0, N'REST', 0, 1, CAST(15.00 AS Decimal(5, 2)))
INSERT [dbo].[cat_configuracion_restaurante] ([Id], [SolicitarFolioComanda]) VALUES (1, 0)
INSERT [dbo].[cat_configuracion_ticket_venta] ([ConfiguracionTicketVentaId], [SucursalId], [TextoCabecera1], [TextoCabecera2], [TextoPie], [CreadoEl], [CreadoPor], [Serie]) VALUES (1, 1, N'', N'', N'', CAST(N'2019-05-29T15:45:18.820' AS DateTime), 1, N'NV')
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (1, N'1,000.00', 1000.0000, 1, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (2, N'500.00', 500.0000, 2, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (3, N'200.00', 200.0000, 3, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (4, N'100.00', 100.0000, 4, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (5, N'50.00', 50.0000, 5, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (6, N'20.00', 20.0000, 6, 1, NULL, NULL)
INSERT [dbo].[cat_denominaciones] ([Clave], [Descripcion], [Valor], [Orden], [Estatus], [Empresa], [Sucursal]) VALUES (7, N'10', 10.0000, 7, 1, NULL, NULL)
INSERT [dbo].[cat_empresas] ([Clave], [Nombre], [NombreComercial], [RegimenFiscal], [RFC], [Calle], [Colonia], [NoExt], [NoInt], [CP], [Ciudad], [Estado], [Pais], [Telefono1], [Telefono2], [Email], [FechaAlta], [Estatus], [Logo]) VALUES (1, N'SAMBORCITO E MARGOT', N'NOMBRE EMPRESA', N'', N'', N'', N'', N'', N'', N'0', N'', N'', N'', N'(   )   -', N'(   )   -', N'', CAST(N'2019-05-29' AS Date), 1, NULL)
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (1, 1, N'?AGUASCALIENTES')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (2, 1, N'BAJA CALIFORNIA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (3, 1, N'BAJA CALIFORNIA SUR')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (4, 1, N'CAMPECHE')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (5, 1, N'CHIAPAS')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (6, 1, N'CHIHUAHUA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (7, 1, N'CIUDAD DE M?XICO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (8, 1, N'COAHUILA DE ZARAGOZA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (9, 1, N'COLIMA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (10, 1, N'DURANGO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (11, 1, N'ESTADO DE M?XICO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (12, 1, N'GUANAJUATO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (13, 1, N'GUERRERO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (14, 1, N'HIDALGO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (15, 1, N'JALISCO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (16, 1, N'MICHOAC?N DE OCAMPO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (17, 1, N'MORELOS')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (18, 1, N'NAYARIT')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (19, 1, N'NUEVO LE?N')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (20, 1, N'OAXACA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (21, 1, N'PUEBLA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (22, 1, N'QUER?TARO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (23, 1, N'QUINTANA ROO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (24, 1, N'SAN LUIS POTOS?')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (25, 1, N'SIN LOCALIDAD')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (26, 1, N'SINALOA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (27, 1, N'SONORA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (28, 1, N'TABASCO')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (29, 1, N'TAMAULIPAS')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (30, 1, N'TLAXCALA')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (31, 1, N'VERACRUZ DE IGNACIO DE LA LLAVE')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (32, 1, N'YUCAT?N')
INSERT [dbo].[cat_estados] ([EstadoId], [PaisId], [Nombre]) VALUES (33, 1, N'ZACATECAS')
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (1, N'Registrado por Cliente', CAST(N'2019-05-29T16:03:04.527' AS DateTime))
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (2, N'Solicitado a Proveedor', CAST(N'2019-05-29T16:03:04.527' AS DateTime))
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (3, N'En Transito', CAST(N'2019-05-29T16:03:04.530' AS DateTime))
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (4, N'Recibido', CAST(N'2019-05-29T16:03:04.530' AS DateTime))
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (5, N'Entregado a Cliente', CAST(N'2019-05-29T16:03:04.530' AS DateTime))
INSERT [dbo].[cat_estatus_pedido] ([EstatusPedidoId], [Descripcion], [CreadoEl]) VALUES (6, N'Cancelado', CAST(N'2019-05-29T16:03:04.530' AS DateTime))

INSERT [dbo].[cat_formas_pago] ([FormaPagoId], [Descripcion], [Abreviatura], [Orden], [RequiereDigVerificador], [Activo], [Signo], [NumeroHacienda]) VALUES (1, N'EFECTIVO', N'EFE', 1, 0, 1, N'+', 2)
INSERT [dbo].[cat_formas_pago] ([FormaPagoId], [Descripcion], [Abreviatura], [Orden], [RequiereDigVerificador], [Activo], [Signo], [NumeroHacienda]) VALUES (2, N'TARJETA DE CRÉDITO', N'TDC', 2, 1, 1, N'-', 2)
INSERT [dbo].[cat_formas_pago] ([FormaPagoId], [Descripcion], [Abreviatura], [Orden], [RequiereDigVerificador], [Activo], [Signo], [NumeroHacienda]) VALUES (3, N'TARJETA DE DEBITO', N'TDD', 3, 1, 1, N'-', 0)
INSERT [dbo].[cat_formas_pago] ([FormaPagoId], [Descripcion], [Abreviatura], [Orden], [RequiereDigVerificador], [Activo], [Signo], [NumeroHacienda]) VALUES (4, N'CH', N'CHE', 4, 1, 1, N'+', 4)
INSERT [dbo].[cat_formas_pago] ([FormaPagoId], [Descripcion], [Abreviatura], [Orden], [RequiereDigVerificador], [Activo], [Signo], [NumeroHacienda]) VALUES (5, N'VALES', N'VAL', 5, 0, 1, N'+', 0)
INSERT [dbo].[cat_impuestos] ([Clave], [CodigoSAT], [Descripcion], [IdAbreviatura], [OrdenImpresion], [IdClasificacionImpuesto], [IdTipoFactor], [Porcentaje], [CuotaFija], [DecimalesPorcCuota], [DesglosarImpPrecioVta], [AgregarImpPrecioVta]) VALUES (1, N'', N'IVA', 1, 1, 1, 1, CAST(16.00 AS Decimal(5, 2)), 0.0000, 0, 0, 0)
INSERT [dbo].[cat_marcas] ([Clave], [Descripcion], [Estatus], [Empresa], [Sucursal]) VALUES (1, N'SIN MARCA', 1, 1, 1)

INSERT [dbo].[cat_paises] ([PaisId], [Nombre]) VALUES (1, N'M?XICO')
INSERT [dbo].[cat_precios] ([IdPrecio], [Descripcion]) VALUES (1, N'Publico General')
INSERT [dbo].[cat_precios] ([IdPrecio], [Descripcion]) VALUES (2, N'Medio Mayoreo')
INSERT [dbo].[cat_precios] ([IdPrecio], [Descripcion]) VALUES (3, N'Mayoreo')
INSERT [dbo].[cat_precios] ([IdPrecio], [Descripcion]) VALUES (4, N'Franquicias')
INSERT [dbo].[cat_precios] ([IdPrecio], [Descripcion]) VALUES (5, N'Distribuidores')

INSERT [dbo].[cat_sucursales] ([Clave], [Empresa], [Calle], [Colonia], [NoExt], [NoInt], [Ciudad], [Estado], [Pais], [Telefono1], [Telefono2], [Email], [Estatus], [NombreSucursal], [CP], [ServidorMailSMTP], [ServidorMailFrom], [ServidorMailPort], [ServidorMailPassword]) VALUES (1, 1, N'CALLE NEGOCIO', N'COL. NEGOCIO', N'1000                ', N'# INT               ', N'TAMPICO', N'TAMAULIPAS', N'MÉXICO', N'(833)123-5555', N'(   )   -', NULL, 1, N'SAMBORCITO DE MARGOT', N'89000', N'', N'', 0, N'')
INSERT [dbo].[cat_tipo_factor_SAT] ([Clave], [NombreFactorSAT], [Activo]) VALUES (1, N'IVA', 1)
INSERT [dbo].[cat_tipos_cliente] ([TipoClienteId], [Descripcion]) VALUES (1, N'Crédito')
INSERT [dbo].[cat_tipos_cliente] ([TipoClienteId], [Descripcion]) VALUES (2, N'Contado')
INSERT [dbo].[cat_tipos_devolucion] ([TipoDevolucionId], [Descripcion]) VALUES (1, N'Por garantía')
INSERT [dbo].[cat_tipos_devolucion] ([TipoDevolucionId], [Descripcion]) VALUES (2, N'Express')
INSERT [dbo].[cat_tipos_direcciones] ([TipoDireccionId], [Nombre], [CreadoEl]) VALUES (1, N'Direcci?n de env?o para compras', CAST(N'2019-05-29T16:02:31.050' AS DateTime))
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (1, N'Carga Inicial', 1, 1, 9)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (2, N'Compra de Productos', 1, 1, 10)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (3, N'Entrada por Traspaso', 1, 1, 11)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (4, N'Salida por Traspaso', 1, 0, 12)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (5, N'Ajuste Por Entrada', 1, 1, 13)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (6, N'Ajuste Por Salida', 1, 0, 14)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (7, N'Entrada Directa', 1, 1, 15)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (8, N'Venta Caja', 1, 0, 16)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (9, N'Cancela Carga Inicial', 1, 0, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (10, N'Cancela Compra de Productos', 1, 0, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (11, N'Cancela Entrada por Traspaso', 1, 0, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (12, N'Cancela Salida por Traspaso', 1, 1, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (13, N'Cancela Ajuste Por Entrada', 1, 0, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (14, N'Cancela Ajuste Por Salida', 1, 1, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (15, N'Cancela Entrada Directa', 1, 0, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (16, N'Cancela Venta Caja', 1, 1, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (17, N'Apartado', 1, 0, 18)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (18, N'Cancelación Apartado', 1, 1, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (19, N'Cancela Devolución', 1, 1, NULL)
INSERT [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId], [Descripcion], [Activo], [EsEntrada], [TipoMovimientoCancelacionId]) VALUES (20, N'Devolución', 1, 1, 19)
INSERT [dbo].[cat_tipos_proveedor] ([TipoProveedorId], [Descripcion]) VALUES (1, N'Crédito')
INSERT [dbo].[cat_tipos_proveedor] ([TipoProveedorId], [Descripcion]) VALUES (2, N'Contado')
INSERT [dbo].[cat_tipos_vale] ([TipoValeId], [Descripcion], [Activo]) VALUES (1, N'Vales Devolución', 1)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (1, N'PIEZA', N'PIEZA', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (2, N'Kilo', N'Kilo', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (3, N'Litro', N'Litro', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (4, N'Gramos', N'Gramos', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (5, N'Mililitros', N'Mililitros', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (6, N'Metros', N'Metros', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (7, N'Centimetros', N'Centimetros', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (8, N'Servicio', N'Servicio', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (9, N'PLATILLO', N'PLATILLO', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (10, N'PZA', N'PZA', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (11, N'PLATILLOS', N'PLATILLOS', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (12, N'ORDEN', N'ORDEN', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (13, N'VASO', N'VASO', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_unidadesmed] ([Clave], [Descripcion], [DescripcionCorta], [Decimales], [Estatus], [Empresa], [Sucursal], [IdCodigoSAT]) VALUES (14, N'JARRA', N'JARRA', 0, 1, 1, 1, NULL)
INSERT [dbo].[cat_usuarios] ([IdUsuario], [IdEmpleado], [NombreUsuario], [Password], [CreadoEl], [Activo], [EsSupervisor], [PasswordSupervisor], [IdSucursal], [EsSupervisorCajero], [PasswordSupervisorCajero], [Email]) VALUES (1, 1, N'ADMIN', N'admin', CAST(N'2019-05-29T15:43:47.653' AS DateTime), 1, 1, N'admin', 1, NULL, NULL, NULL)
INSERT [dbo].[cat_usuarios] ([IdUsuario], [IdEmpleado], [NombreUsuario], [Password], [CreadoEl], [Activo], [EsSupervisor], [PasswordSupervisor], [IdSucursal], [EsSupervisorCajero], [PasswordSupervisorCajero], [Email]) VALUES (2, 2, N'cajero1', N'cajero1', CAST(N'2019-05-29T15:45:11.010' AS DateTime), 1, 0, NULL, 1, NULL, NULL, N'')
INSERT [dbo].[cat_web_configuracion] ([SucursalId], [Dominio], [ServidorFTP], [UsuarioFTP], [PasswordFTP], [FolderProductos], [DiasEntregaAdicSPedido], [DiasEntregaPedido]) VALUES (1, N'https://www.masymaszapatos.com', N'ftp://ftp.site4now.net/', N'maszapatos', N'zapatos2018', N'Content/Productos/', 7, 6)
INSERT [dbo].[rh_empleado_puestos] ([EmpleadoId], [PuestoId], [CreadoPor], [CreadoEl]) VALUES (2, 3, 1, CAST(N'2019-07-20T17:36:52.483' AS DateTime))
INSERT [dbo].[rh_empleado_puestos] ([EmpleadoId], [PuestoId], [CreadoPor], [CreadoEl]) VALUES (2, 4, 1, CAST(N'2019-07-14T03:23:50.910' AS DateTime))
INSERT [dbo].[rh_empleados] ([NumEmpleado], [Nombre], [SueldoNeto], [SueldoDiario], [SueldoHra], [FormaPago], [TipoContrato], [Puesto], [Departamento], [FechaIngreso], [FechaInicioLab], [Estatus], [Foto], [Empresa], [Sucursal]) VALUES (1, N'ADMIN', 0.0000, 0.0000, 0.0000, NULL, NULL, 1, NULL, CAST(N'2019-05-29' AS Date), CAST(N'2019-05-29' AS Date), 1, NULL, 1, 1)
INSERT [dbo].[rh_empleados] ([NumEmpleado], [Nombre], [SueldoNeto], [SueldoDiario], [SueldoHra], [FormaPago], [TipoContrato], [Puesto], [Departamento], [FechaIngreso], [FechaInicioLab], [Estatus], [Foto], [Empresa], [Sucursal]) VALUES (2, N'cajero 1', 0.0000, 0.0000, 0.0000, NULL, NULL, NULL, NULL, CAST(N'2019-05-29' AS Date), CAST(N'2019-05-29' AS Date), 1, NULL, 1, 1)
INSERT [dbo].[rh_puestos] ([Clave], [Descripcion], [Estatus], [Empresa], [Sucursal], [PermitirEliminar], [Mostrar]) VALUES (1, N'Gerente', 1, 1, 1, NULL, NULL)
INSERT [dbo].[rh_puestos] ([Clave], [Descripcion], [Estatus], [Empresa], [Sucursal], [PermitirEliminar], [Mostrar]) VALUES (2, N'Vendedor', 1, 1, 1, NULL, NULL)
INSERT [dbo].[rh_puestos] ([Clave], [Descripcion], [Estatus], [Empresa], [Sucursal], [PermitirEliminar], [Mostrar]) VALUES (3, N'Cajero', 1, 1, 1, NULL, NULL)
INSERT [dbo].[rh_puestos] ([Clave], [Descripcion], [Estatus], [Empresa], [Sucursal], [PermitirEliminar], [Mostrar]) VALUES (4, N'Mesero', 1, 1, 1, 0, 1)
/****** Object:  Index [IX_cat_cajas_impresora]    Script Date: 8/24/2019 6:10:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cat_cajas_impresora] ON [dbo].[cat_cajas_impresora]
(
	[CajaId] ASC,
	[ImpresoraId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cat_productos_base]    Script Date: 8/24/2019 6:10:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cat_productos_base] ON [dbo].[cat_productos_base]
(
	[ProductoId] ASC,
	[ProductoBaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cat_productos_precios]    Script Date: 8/24/2019 6:10:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_cat_productos_precios] ON [dbo].[cat_productos_precios]
(
	[IdPrecio] ASC,
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_doc_inv_carga_inicial]    Script Date: 8/24/2019 6:10:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_doc_inv_carga_inicial] ON [dbo].[doc_inv_carga_inicial]
(
	[SucursalId] ASC,
	[ProductoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_doc_web_carrito]    Script Date: 8/24/2019 6:10:51 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_doc_web_carrito] ON [dbo].[doc_web_carrito]
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_almacenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_anaqueles]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_andenes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas]  WITH CHECK ADD  CONSTRAINT [FK__cat_cajas__Empre__160F4887] FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas] CHECK CONSTRAINT [FK__cat_cajas__Empre__160F4887]
GO
ALTER TABLE [dbo].[cat_cajas]  WITH CHECK ADD  CONSTRAINT [FK__cat_cajas__Sucur__17036CC0] FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas] CHECK CONSTRAINT [FK__cat_cajas__Sucur__17036CC0]
GO
ALTER TABLE [dbo].[cat_cajas_impresora]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_impresora_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_cajas_impresora] CHECK CONSTRAINT [FK_cat_cajas_impresora_cat_cajas]
GO
ALTER TABLE [dbo].[cat_cajas_impresora]  WITH CHECK ADD  CONSTRAINT [FK_cat_cajas_impresora_cat_impresoras] FOREIGN KEY([ImpresoraId])
REFERENCES [dbo].[cat_impresoras] ([ImpresoraId])
GO
ALTER TABLE [dbo].[cat_cajas_impresora] CHECK CONSTRAINT [FK_cat_cajas_impresora_cat_impresoras]
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_centro_costos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_antecedentes] FOREIGN KEY([AntecedenteId])
REFERENCES [dbo].[cat_antecedentes] ([AntecedenteId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_antecedentes]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_estados]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_giros] FOREIGN KEY([GiroId])
REFERENCES [dbo].[cat_giros_neg] ([Clave])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_giros]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_municipios] FOREIGN KEY([MunicipioId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_municipios]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_paises]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_precios] FOREIGN KEY([PrecioId])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_precios]
GO
ALTER TABLE [dbo].[cat_clientes]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_cat_tipos_cliente] FOREIGN KEY([TipoClienteId])
REFERENCES [dbo].[cat_tipos_cliente] ([TipoClienteId])
GO
ALTER TABLE [dbo].[cat_clientes] CHECK CONSTRAINT [FK_cat_clientes_cat_tipos_cliente]
GO
ALTER TABLE [dbo].[cat_clientes_automovil]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_automovil_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_automovil] CHECK CONSTRAINT [FK_cat_clientes_automovil_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_direcciones_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_cat_clientes_direcciones_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_direcciones_cat_tipos_direcciones] FOREIGN KEY([TipoDireccionId])
REFERENCES [dbo].[cat_tipos_direcciones] ([TipoDireccionId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_cat_clientes_direcciones_cat_tipos_direcciones]
GO
ALTER TABLE [dbo].[cat_clientes_direcciones]  WITH CHECK ADD  CONSTRAINT [FK_clientes_direcciones_Estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_clientes_direcciones] CHECK CONSTRAINT [FK_clientes_direcciones_Estados]
GO
ALTER TABLE [dbo].[cat_clientes_openpay]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_openpay_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_openpay] CHECK CONSTRAINT [FK_cat_clientes_openpay_cat_clientes]
GO
ALTER TABLE [dbo].[cat_clientes_web]  WITH CHECK ADD  CONSTRAINT [FK_cat_clientes_web_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[cat_clientes_web] CHECK CONSTRAINT [FK_cat_clientes_web_cat_clientes]
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_apartado]  WITH CHECK ADD  CONSTRAINT [FK_cat_configuracion_ticket_apartado_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_apartado] CHECK CONSTRAINT [FK_cat_configuracion_ticket_apartado_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_venta]  WITH CHECK ADD  CONSTRAINT [FK_cat_configuracion_ticket_venta_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_configuracion_ticket_venta] CHECK CONSTRAINT [FK_cat_configuracion_ticket_venta_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_denominaciones]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_divisiones_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_estados]  WITH CHECK ADD  CONSTRAINT [FK_cat_estados_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_estados] CHECK CONSTRAINT [FK_cat_estados_cat_paises]
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_familias]  WITH CHECK ADD  CONSTRAINT [FK_familias_productos] FOREIGN KEY([ProductoPortadaId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_familias] CHECK CONSTRAINT [FK_familias_productos]
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ClaveCentroCosto])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ClaveCentroCosto])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([ConceptoId])
REFERENCES [dbo].[cat_conceptos] ([ConceptoId])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD  CONSTRAINT [FK__cat_gasto__Cread__58671BC9] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_gastos] CHECK CONSTRAINT [FK__cat_gasto__Cread__58671BC9]
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_gastos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_giros_neg]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_grupos_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_impresoras]  WITH CHECK ADD  CONSTRAINT [FK_cat_impresoras_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_impresoras] CHECK CONSTRAINT [FK_cat_impresoras_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_impresoras_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_impresoras_comandas_cat_impresoras] FOREIGN KEY([ImpresoraId])
REFERENCES [dbo].[cat_impresoras] ([ImpresoraId])
GO
ALTER TABLE [dbo].[cat_impresoras_comandas] CHECK CONSTRAINT [FK_cat_impresoras_comandas_cat_impresoras]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_abreviaturas_SAT] FOREIGN KEY([IdAbreviatura])
REFERENCES [dbo].[cat_abreviaturas_SAT] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_abreviaturas_SAT]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_clasificacion_impuestos] FOREIGN KEY([IdClasificacionImpuesto])
REFERENCES [dbo].[cat_clasificacion_impuestos] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_clasificacion_impuestos]
GO
ALTER TABLE [dbo].[cat_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_impuestos_cat_tipo_factor_SAT] FOREIGN KEY([IdTipoFactor])
REFERENCES [dbo].[cat_tipo_factor_SAT] ([Clave])
GO
ALTER TABLE [dbo].[cat_impuestos] CHECK CONSTRAINT [FK_cat_impuestos_cat_tipo_factor_SAT]
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_lineas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_lotes]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_marcas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_monedas]  WITH CHECK ADD  CONSTRAINT [FK_monedas_abreviaturas] FOREIGN KEY([IdMonedaAbreviatura])
REFERENCES [dbo].[cat_monedas_abreviaturas] ([IdMonedaAbreviatura])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[cat_monedas] CHECK CONSTRAINT [FK_monedas_abreviaturas]
GO
ALTER TABLE [dbo].[cat_municipios]  WITH CHECK ADD  CONSTRAINT [FK_cat_municipios_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_municipios] CHECK CONSTRAINT [FK_cat_municipios_cat_estados]
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAlmacen])
REFERENCES [dbo].[cat_almacenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAnden])
REFERENCES [dbo].[cat_andenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLote])
REFERENCES [dbo].[cat_lotes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveMarca])
REFERENCES [dbo].[cat_marcas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveFamilia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveSubFamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLinea])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveUnidadMedida])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveInventariadoPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveVendidaPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAlmacen])
REFERENCES [dbo].[cat_almacenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveAnden])
REFERENCES [dbo].[cat_andenes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLote])
REFERENCES [dbo].[cat_lotes] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveMarca])
REFERENCES [dbo].[cat_marcas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveFamilia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveSubFamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveLinea])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveUnidadMedida])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveInventariadoPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([ClaveVendidaPor])
REFERENCES [dbo].[cat_unidadesmed] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_agrupados]  WITH CHECK ADD  CONSTRAINT [FK_productos_agrupados_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados] CHECK CONSTRAINT [FK_productos_agrupados_productos]
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle] CHECK CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos_agrupados] FOREIGN KEY([ProductoAgrupadoId])
REFERENCES [dbo].[cat_productos_agrupados] ([ProductoAgrupadoId])
GO
ALTER TABLE [dbo].[cat_productos_agrupados_detalle] CHECK CONSTRAINT [FK_cat_productos_agrupados_detalle_cat_productos_agrupados]
GO
ALTER TABLE [dbo].[cat_productos_base]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_base] CHECK CONSTRAINT [FK_cat_productos_base_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_base]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_base_cat_productos1] FOREIGN KEY([ProductoBaseId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_base] CHECK CONSTRAINT [FK_cat_productos_base_cat_productos1]
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_cambio_precio_cat_precios] FOREIGN KEY([UsuarioRegistroId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio] CHECK CONSTRAINT [FK_cat_productos_cambio_precio_cat_precios]
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_cambio_precio_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_cambio_precio] CHECK CONSTRAINT [FK_cat_productos_cambio_precio_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_productos_config_sucursal] CHECK CONSTRAINT [FK_cat_productos_config_sucursal_cat_usuarios1]
GO
ALTER TABLE [dbo].[cat_productos_existencias]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_existencias_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_existencias] CHECK CONSTRAINT [FK_cat_productos_existencias_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_existencias]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_existencias_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_existencias] CHECK CONSTRAINT [FK_cat_productos_existencias_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_productos_imagenes]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_imagenes_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_imagenes] CHECK CONSTRAINT [FK_cat_productos_imagenes_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_impuestos_cat_impuestos] FOREIGN KEY([ImpuestoId])
REFERENCES [dbo].[cat_impuestos] ([Clave])
GO
ALTER TABLE [dbo].[cat_productos_impuestos] CHECK CONSTRAINT [FK_cat_productos_impuestos_cat_impuestos]
GO
ALTER TABLE [dbo].[cat_productos_impuestos]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_impuestos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_impuestos] CHECK CONSTRAINT [FK_cat_productos_impuestos_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_precios_cat_productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[cat_productos_precios] CHECK CONSTRAINT [FK_cat_productos_precios_cat_productos]
GO
ALTER TABLE [dbo].[cat_productos_precios]  WITH CHECK ADD  CONSTRAINT [FK_cat_productos_precios_cat_productos_precios] FOREIGN KEY([IdPrecio])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_productos_precios] CHECK CONSTRAINT [FK_cat_productos_precios_cat_productos_precios]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_estados] FOREIGN KEY([EstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_estados]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_giros] FOREIGN KEY([GiroId])
REFERENCES [dbo].[cat_giros_neg] ([Clave])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_giros]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_municipios] FOREIGN KEY([MunicipioId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_municipios]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_paises] FOREIGN KEY([PaisId])
REFERENCES [dbo].[cat_paises] ([PaisId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_paises]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_precios] FOREIGN KEY([PrecioId])
REFERENCES [dbo].[cat_precios] ([IdPrecio])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_precios]
GO
ALTER TABLE [dbo].[cat_proveedores]  WITH CHECK ADD  CONSTRAINT [FK_cat_proveedores_cat_tipos_proveedor] FOREIGN KEY([TipoProveedorId])
REFERENCES [dbo].[cat_tipos_proveedor] ([TipoProveedorId])
GO
ALTER TABLE [dbo].[cat_proveedores] CHECK CONSTRAINT [FK_cat_proveedores_cat_tipos_proveedor]
GO
ALTER TABLE [dbo].[cat_rest_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_comandas] CHECK CONSTRAINT [FK_cat_rest_comandas_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_rest_comandas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_comandas] CHECK CONSTRAINT [FK_cat_rest_comandas_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_mesas]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_mesas_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_mesas] CHECK CONSTRAINT [FK_cat_rest_mesas_cat_usuarios1]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_cat_usuarios]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_rest_platillo_adicionales] FOREIGN KEY([PlatilloAdicionalId])
REFERENCES [dbo].[cat_rest_platillo_adicionales] ([Id])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_rest_platillo_adicionales]
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_subfamilias] FOREIGN KEY([SubfamiliaId])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[cat_rest_platillo_adicionales_sfam] CHECK CONSTRAINT [FK_cat_rest_platillo_adicionales_sfam_cat_subfamilias]
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_rubros]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_sitios_entrega_pedido]  WITH CHECK ADD  CONSTRAINT [FK_cat_sitios_entrega_pedido_cat_municipios] FOREIGN KEY([CiudadId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[cat_sitios_entrega_pedido] CHECK CONSTRAINT [FK_cat_sitios_entrega_pedido_cat_municipios]
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subclases_sat]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Familia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Familia])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_subfamilias]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_tipos_movimiento_inventario]  WITH CHECK ADD FOREIGN KEY([TipoMovimientoCancelacionId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[cat_tipos_movimiento_inventario]  WITH CHECK ADD FOREIGN KEY([TipoMovimientoCancelacionId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_unidadesmed]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_cat_sucursales] FOREIGN KEY([IdSucursal])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_usuarios] CHECK CONSTRAINT [FK_cat_usuarios_cat_sucursales]
GO
ALTER TABLE [dbo].[cat_usuarios]  WITH CHECK ADD  CONSTRAINT [FK_cat_usuarios_rh_empleados] FOREIGN KEY([IdEmpleado])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[cat_usuarios] CHECK CONSTRAINT [FK_cat_usuarios_rh_empleados]
GO
ALTER TABLE [dbo].[cat_web_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_cat_web_configuracion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[cat_web_configuracion] CHECK CONSTRAINT [FK_cat_web_configuracion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_apartados_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_apartados_ventas]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_clientes]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_apartados]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados] CHECK CONSTRAINT [FK_doc_apartados_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_formas_pago_cat_formas_pago] FOREIGN KEY([FormaPagoId])
REFERENCES [dbo].[cat_formas_pago] ([FormaPagoId])
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago] CHECK CONSTRAINT [FK_doc_apartados_formas_pago_cat_formas_pago]
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_formas_pago_doc_apartados_pagos] FOREIGN KEY([ApartadoPagoId])
REFERENCES [dbo].[doc_apartados_pagos] ([ApartadoPagoId])
GO
ALTER TABLE [dbo].[doc_apartados_formas_pago] CHECK CONSTRAINT [FK_doc_apartados_formas_pago_doc_apartados_pagos]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_caja] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_caja]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_pagos_doc_apartados] FOREIGN KEY([ApartadoId])
REFERENCES [dbo].[doc_apartados] ([ApartadoId])
GO
ALTER TABLE [dbo].[doc_apartados_pagos] CHECK CONSTRAINT [FK_doc_apartados_pagos_doc_apartados]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_productos]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_apartados_productos]  WITH CHECK ADD  CONSTRAINT [FK_doc_apartados_productos_doc_apartados] FOREIGN KEY([ApartadoId])
REFERENCES [dbo].[doc_apartados] ([ApartadoId])
GO
ALTER TABLE [dbo].[doc_apartados_productos] CHECK CONSTRAINT [FK_doc_apartados_productos_doc_apartados]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_cat_cajas]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_doc_ventas] FOREIGN KEY([VentaIniId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_doc_ventas]
GO
ALTER TABLE [dbo].[doc_corte_caja]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_doc_ventas1] FOREIGN KEY([VentaFinId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_corte_caja] CHECK CONSTRAINT [FK_doc_corte_caja_doc_ventas1]
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_apartados_pagos] FOREIGN KEY([ApartadoPagoId])
REFERENCES [dbo].[doc_apartados_pagos] ([ApartadoPagoId])
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos] CHECK CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_apartados_pagos]
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_apartados_pagos] CHECK CONSTRAINT [FK_doc_corte_caja_apartados_pagos_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_denominaciones_cat_denominaciones] FOREIGN KEY([DenominacionId])
REFERENCES [dbo].[cat_denominaciones] ([Clave])
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones] CHECK CONSTRAINT [FK_doc_corte_caja_denominaciones_cat_denominaciones]
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_denominaciones_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_denominaciones] CHECK CONSTRAINT [FK_doc_corte_caja_denominaciones_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_egresos]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_egresos_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_egresos] CHECK CONSTRAINT [FK_doc_corte_caja_egresos_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_fp]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_fp_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_fp] CHECK CONSTRAINT [FK_doc_corte_caja_fp_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_corte_caja_fp_apartado]  WITH CHECK ADD  CONSTRAINT [FK_doc_corte_caja_fp_apartado_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_corte_caja_fp_apartado] CHECK CONSTRAINT [FK_doc_corte_caja_fp_apartado_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD FOREIGN KEY([TipoDevolucionId])
REFERENCES [dbo].[cat_tipos_devolucion] ([TipoDevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD FOREIGN KEY([TipoDevolucionId])
REFERENCES [dbo].[cat_tipos_devolucion] ([TipoDevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_usuarios1] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_devoluciones] CHECK CONSTRAINT [FK_doc_devoluciones_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_devoluciones]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_doc_ventas1] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones] CHECK CONSTRAINT [FK_doc_devoluciones_doc_ventas1]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_productos] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_cat_productos]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_devoluciones_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_devoluciones_detalle] CHECK CONSTRAINT [FK_doc_devoluciones_doc_ventas]
GO
ALTER TABLE [dbo].[doc_entrada_directa_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_entrada_directa_adicional_doc_inv_movimiento_detalle] FOREIGN KEY([MovimientoDetalleId])
REFERENCES [dbo].[doc_inv_movimiento_detalle] ([MovimientoDetalleId])
GO
ALTER TABLE [dbo].[doc_entrada_directa_adicional] CHECK CONSTRAINT [FK_doc_entrada_directa_adicional_doc_inv_movimiento_detalle]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_cajas]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_centro_costos] FOREIGN KEY([CentroCostoId])
REFERENCES [dbo].[cat_centro_costos] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_centro_costos]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_gastos] FOREIGN KEY([GastoConceptoId])
REFERENCES [dbo].[cat_gastos] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_gastos]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_gastos]  WITH CHECK ADD  CONSTRAINT [FK_doc_gastos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_gastos] CHECK CONSTRAINT [FK_doc_gastos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_productos]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_carga_inicial_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_carga_inicial] CHECK CONSTRAINT [FK_doc_inv_carga_inicial_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([AutorizadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([AutorizadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalOrigenId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalDestinoId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalOrigenId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalDestinoId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cancelacion] FOREIGN KEY([MovimientoRefId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cancelacion]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cat_sucursales] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_inv_movimiento]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_movimiento_inventario] FOREIGN KEY([TipoMovimientoId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento] CHECK CONSTRAINT [FK_doc_inv_movimiento_cat_tipos_movimiento_inventario]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_inv_movimiento_detalle_doc_inv_movimiento] FOREIGN KEY([MovimientoId])
REFERENCES [dbo].[doc_inv_movimiento] ([MovimientoId])
GO
ALTER TABLE [dbo].[doc_inv_movimiento_detalle] CHECK CONSTRAINT [FK_doc_inv_movimiento_detalle_doc_inv_movimiento]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_municipios] FOREIGN KEY([CiudadId])
REFERENCES [dbo].[cat_municipios] ([MunicipioId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_municipios]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos] CHECK CONSTRAINT [FK_doc_pedidos_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes_direcciones] FOREIGN KEY([ClienteDireccionId])
REFERENCES [dbo].[cat_clientes_direcciones] ([ClienteDireccionId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_clientes_direcciones]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_estatus_pedido] FOREIGN KEY([EstatusId])
REFERENCES [dbo].[cat_estatus_pedido] ([EstatusPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_estatus_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_sitios_entrega_pedido] FOREIGN KEY([SitioEntregaId])
REFERENCES [dbo].[cat_sitios_entrega_pedido] ([SitioEntregaPedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_sitios_entrega_pedido]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes] CHECK CONSTRAINT [FK_doc_pedidos_clientes_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_det_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det] CHECK CONSTRAINT [FK_doc_pedidos_clientes_det_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_clientes_det_doc_pedidos_clientes] FOREIGN KEY([PedidoClienteDetId])
REFERENCES [dbo].[doc_pedidos_clientes] ([PedidoClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_clientes_det] CHECK CONSTRAINT [FK_doc_pedidos_clientes_det_doc_pedidos_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_configuracion_det_doc_pedidos_configuracion] FOREIGN KEY([PedidoConfiguracionId])
REFERENCES [dbo].[doc_pedidos_configuracion] ([PedidoConfiguracionId])
GO
ALTER TABLE [dbo].[doc_pedidos_configuracion_det] CHECK CONSTRAINT [FK_doc_pedidos_configuracion_det_doc_pedidos_configuracion]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_orden_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_cat_rest_comandas_orden_cat_clientes]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_cat_rest_comandas_orden_cat_rest_comandas] FOREIGN KEY([ComandaId])
REFERENCES [dbo].[cat_rest_comandas] ([ComandaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_cat_rest_comandas_orden_cat_rest_comandas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_doc_pedidos_orden_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_pedidos_orden]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_Ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden] CHECK CONSTRAINT [FK_Pedidos_Ventas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_rest_platillo_adicionales] FOREIGN KEY([AdicionalId])
REFERENCES [dbo].[cat_rest_platillo_adicionales] ([Id])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_rest_platillo_adicionales]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_adicional_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_adicional] CHECK CONSTRAINT [FK_doc_pedidos_orden_adicional_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_rest_comandas] FOREIGN KEY([ComandaId])
REFERENCES [dbo].[cat_rest_comandas] ([ComandaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_cat_rest_comandas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_detalle_doc_pedidos_orden] FOREIGN KEY([PedidoId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_detalle] CHECK CONSTRAINT [FK_doc_pedidos_orden_detalle_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_productos_base] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_productos_base]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_ingre_doc_pedidos_orden_detalle] FOREIGN KEY([PedidoDetalleId])
REFERENCES [dbo].[doc_pedidos_orden_detalle] ([PedidoDetalleId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_ingre] CHECK CONSTRAINT [FK_doc_pedidos_orden_ingre_doc_pedidos_orden_detalle]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesa_cat_rest_mesas] FOREIGN KEY([MesaId])
REFERENCES [dbo].[cat_rest_mesas] ([MesaId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesa_cat_rest_mesas]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesa_doc_pedidos_orden] FOREIGN KEY([PedidoOrdenId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesa] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesa_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesero_doc_pedidos_orden] FOREIGN KEY([PedidoOrdenId])
REFERENCES [dbo].[doc_pedidos_orden] ([PedidoId])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesero_doc_pedidos_orden]
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero]  WITH CHECK ADD  CONSTRAINT [FK_doc_pedidos_orden_mesero_rh_empleados] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[doc_pedidos_orden_mesero] CHECK CONSTRAINT [FK_doc_pedidos_orden_mesero_rh_empleados]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_proveedores] FOREIGN KEY([ProveedorId])
REFERENCES [dbo].[cat_proveedores] ([ProveedorId])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_proveedores]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios1] FOREIGN KEY([ModificadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_cat_usuarios2] FOREIGN KEY([CanceladoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_doc_productos_compra_cat_usuarios2]
GO
ALTER TABLE [dbo].[doc_productos_compra]  WITH CHECK ADD  CONSTRAINT [FK_Productos_Compra_Suursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_productos_compra] CHECK CONSTRAINT [FK_Productos_Compra_Suursales]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_compra_detalle_doc_productos_compra] FOREIGN KEY([ProductoCompraId])
REFERENCES [dbo].[doc_productos_compra] ([ProductoCompraId])
GO
ALTER TABLE [dbo].[doc_productos_compra_detalle] CHECK CONSTRAINT [FK_doc_productos_compra_detalle_doc_productos_compra]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_productos]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_tipos_movimiento_inventario] FOREIGN KEY([TipoMovimientoInventarioId])
REFERENCES [dbo].[cat_tipos_movimiento_inventario] ([TipoMovimientoInventarioId])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_tipos_movimiento_inventario]
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora]  WITH CHECK ADD  CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_productos_importacion_bitacora] CHECK CONSTRAINT [FK_doc_productos_importacion_bitacora_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_empresas] FOREIGN KEY([EmpresaId])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_empresas]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_promociones]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_promociones] CHECK CONSTRAINT [FK_doc_promociones_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_familias] FOREIGN KEY([FamiliaId])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_familias]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_lineas] FOREIGN KEY([LineaId])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_lineas]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_cat_subfamilias] FOREIGN KEY([Subfamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_cat_subfamilias]
GO
ALTER TABLE [dbo].[doc_promociones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_detalle_doc_promociones] FOREIGN KEY([PromocionId])
REFERENCES [dbo].[doc_promociones] ([PromocionId])
GO
ALTER TABLE [dbo].[doc_promociones_detalle] CHECK CONSTRAINT [FK_doc_promociones_detalle_doc_promociones]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_familias] FOREIGN KEY([FamiliaId])
REFERENCES [dbo].[cat_familias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_familias]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_lineas] FOREIGN KEY([LineaId])
REFERENCES [dbo].[cat_lineas] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_lineas]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_productos]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_cat_subfamilias] FOREIGN KEY([Subfamilia])
REFERENCES [dbo].[cat_subfamilias] ([Clave])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_cat_subfamilias]
GO
ALTER TABLE [dbo].[doc_promociones_excepcion]  WITH CHECK ADD  CONSTRAINT [FK_doc_promociones_excepcion_doc_promociones] FOREIGN KEY([PromocionId])
REFERENCES [dbo].[doc_promociones] ([PromocionId])
GO
ALTER TABLE [dbo].[doc_promociones_excepcion] CHECK CONSTRAINT [FK_doc_promociones_excepcion_doc_promociones]
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket]  WITH CHECK ADD  CONSTRAINT [FK_doc_reimpresion_ticket_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket] CHECK CONSTRAINT [FK_doc_reimpresion_ticket_cat_cajas]
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket]  WITH CHECK ADD  CONSTRAINT [FK_doc_reimpresion_ticket_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_reimpresion_ticket] CHECK CONSTRAINT [FK_doc_reimpresion_ticket_doc_ventas]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_cajas]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_sucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_sucursales]
GO
ALTER TABLE [dbo].[doc_retiros]  WITH CHECK ADD  CONSTRAINT [FK_doc_retiros_cat_usuarios] FOREIGN KEY([CreadoPor])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_retiros] CHECK CONSTRAINT [FK_doc_retiros_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_cat_cajas] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_cat_cajas]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_cat_usuarios] FOREIGN KEY([UsuarioId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta]  WITH CHECK ADD  CONSTRAINT [FK_doc_sesiones_punto_venta_doc_corte_caja] FOREIGN KEY([CorteCajaId])
REFERENCES [dbo].[doc_corte_caja] ([CorteCajaId])
GO
ALTER TABLE [dbo].[doc_sesiones_punto_venta] CHECK CONSTRAINT [FK_doc_sesiones_punto_venta_doc_corte_caja]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_clientes] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_clientes]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_cat_usuarios1] FOREIGN KEY([UsuarioCancelacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_doc_ventas_cat_usuarios1]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_VentasCaja] FOREIGN KEY([CajaId])
REFERENCES [dbo].[cat_cajas] ([Clave])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_VentasCaja]
GO
ALTER TABLE [dbo].[doc_ventas]  WITH CHECK ADD  CONSTRAINT [FK_VentasSucursales] FOREIGN KEY([SucursalId])
REFERENCES [dbo].[cat_sucursales] ([Clave])
GO
ALTER TABLE [dbo].[doc_ventas] CHECK CONSTRAINT [FK_VentasSucursales]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_detalle_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_ventas_detalle] CHECK CONSTRAINT [FK_doc_ventas_detalle_doc_ventas]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_cat_formas_pago] FOREIGN KEY([FormaPagoId])
REFERENCES [dbo].[cat_formas_pago] ([FormaPagoId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_cat_formas_pago]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_cat_usuarios] FOREIGN KEY([UsuarioCreacionId])
REFERENCES [dbo].[cat_usuarios] ([IdUsuario])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_cat_usuarios]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_doc_ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_doc_ventas]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_vale_cat_tipos_vale] FOREIGN KEY([TipoValeId])
REFERENCES [dbo].[cat_tipos_vale] ([TipoValeId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_vale_cat_tipos_vale]
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale]  WITH CHECK ADD  CONSTRAINT [FK_doc_ventas_formas_pago_vale_doc_devoluciones] FOREIGN KEY([DevolucionId])
REFERENCES [dbo].[doc_devoluciones] ([DevolucionId])
GO
ALTER TABLE [dbo].[doc_ventas_formas_pago_vale] CHECK CONSTRAINT [FK_doc_ventas_formas_pago_vale_doc_devoluciones]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_Cliente] FOREIGN KEY([ClienteId])
REFERENCES [dbo].[cat_clientes] ([ClienteId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_Carrito_Cliente]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_Ventas] FOREIGN KEY([VentaId])
REFERENCES [dbo].[doc_ventas] ([VentaId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_Carrito_Ventas]
GO
ALTER TABLE [dbo].[doc_web_carrito]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_cat_estados] FOREIGN KEY([EnvioEstadoId])
REFERENCES [dbo].[cat_estados] ([EstadoId])
GO
ALTER TABLE [dbo].[doc_web_carrito] CHECK CONSTRAINT [FK_doc_web_carrito_cat_estados]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_Carrito_CarritoDetalle] FOREIGN KEY([Id])
REFERENCES [dbo].[doc_web_carrito] ([id])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_Carrito_CarritoDetalle]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_detalle_cat_productos] FOREIGN KEY([ProductoId])
REFERENCES [dbo].[cat_productos] ([ProductoId])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_doc_web_carrito_detalle_cat_productos]
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle]  WITH CHECK ADD  CONSTRAINT [FK_doc_web_carrito_detalle_doc_web_carrito] FOREIGN KEY([uUID])
REFERENCES [dbo].[doc_web_carrito] ([uUID])
GO
ALTER TABLE [dbo].[doc_web_carrito_detalle] CHECK CONSTRAINT [FK_doc_web_carrito_detalle_doc_web_carrito]
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_departamentos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleado_puestos]  WITH CHECK ADD  CONSTRAINT [FK_rh_empleado_puestos_rh_empleados] FOREIGN KEY([EmpleadoId])
REFERENCES [dbo].[rh_empleados] ([NumEmpleado])
GO
ALTER TABLE [dbo].[rh_empleado_puestos] CHECK CONSTRAINT [FK_rh_empleado_puestos_rh_empleados]
GO
ALTER TABLE [dbo].[rh_empleado_puestos]  WITH CHECK ADD  CONSTRAINT [FK_rh_empleado_puestos_rh_puestos] FOREIGN KEY([PuestoId])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleado_puestos] CHECK CONSTRAINT [FK_rh_empleado_puestos_rh_puestos]
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Departamento])
REFERENCES [dbo].[rh_departamentos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Departamento])
REFERENCES [dbo].[rh_departamentos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([FormaPago])
REFERENCES [dbo].[rh_formaspagonom] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([FormaPago])
REFERENCES [dbo].[rh_formaspagonom] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Puesto])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Puesto])
REFERENCES [dbo].[rh_puestos] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([TipoContrato])
REFERENCES [dbo].[rh_tipos_contrato] ([Clave])
GO
ALTER TABLE [dbo].[rh_empleados]  WITH CHECK ADD FOREIGN KEY([TipoContrato])
REFERENCES [dbo].[rh_tipos_contrato] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_estatus_empleados]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_formaspagonom]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_puestos]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Empresa])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[rh_tipos_contrato]  WITH CHECK ADD FOREIGN KEY([Sucursal])
REFERENCES [dbo].[cat_empresas] ([Clave])
GO
ALTER TABLE [dbo].[sis_versiones_detalle]  WITH CHECK ADD  CONSTRAINT [FK_sis_versiones_detalle_sis_versiones] FOREIGN KEY([VersionId])
REFERENCES [dbo].[sis_versiones] ([VersionId])
GO
ALTER TABLE [dbo].[sis_versiones_detalle] CHECK CONSTRAINT [FK_sis_versiones_detalle_sis_versiones]
GO
/****** Object:  StoredProcedure [dbo].[doc_corte_caja_denominaciones_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Proc [dbo].[doc_corte_caja_denominaciones_ins]
@pCorteCajaId int,
@pDenominacionId int,
@pCantidad int,
@pValor money,
@pTotal money,
@pCreadoPor int
as

	insert into [dbo].[doc_corte_caja_denominaciones](
		CorteCajaId,
		DenominacionId,
		Cantidad,
		Valor,
		Total,
		CreadoPor,
		CreadoEl
	)
	values(
		@pCorteCajaId,
		@pDenominacionId,
		@pCantidad,
		@pValor,
		@pTotal,
		@pCreadoPor,
		getdate()
		
	)





GO
/****** Object:  StoredProcedure [dbo].[doc_inv_movimiento_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[doc_inv_movimiento_detalle_ins]
@pMovimientoDetalleId	int out,
@pMovimientoId	int,
@pProductoId	int,
@pConsecutivo	smallint,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pImporte	money,
@pDisponible	decimal(14,3),
@pCreadoPor	int
as


select @pMovimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
from [doc_inv_movimiento_detalle]

INSERT INTO [dbo].[doc_inv_movimiento_detalle]
           ([MovimientoDetalleId]
           ,[MovimientoId]
           ,[ProductoId]
           ,[Consecutivo]
           ,[Cantidad]
           ,[PrecioUnitario]
           ,[Importe]
           ,[Disponible]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@pMovimientoDetalleId,
           @pMovimientoId,
           @pProductoId, 
           @pConsecutivo, 
           @pCantidad, 
           @pPrecioUnitario, 
           @pImporte, 
           @pDisponible, 
           @pCreadoPor, 
           getdate() )






GO
/****** Object:  StoredProcedure [dbo].[p_Actualizar_CompraListaPrecios]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_Actualizar_CompraListaPrecios 5,0,1,''
CREATE proc [dbo].[p_Actualizar_CompraListaPrecios]
@pProductoCompraId int,
@pCompraDirectaId int,
@pUsuarioId int,
@pError varchar(200) out
as

	/**********VALIDACIONES********************/
	declare @activo bit,
			@productoId int,
			@precio money,
			@porcUtilidad decimal(5,2),
			@idAux int,
			@precioAnterior money,
			@cambioPrecioPorcUtilidad bit,
			@cambioPrecioIncUtilidad bit,
			@sucursalId int,
			@porcTotImpuestos decimal(6,2)

	if(@pProductoCompraId > 0)
	begin
		select @activo =Activo,
			@sucursalId = SucursalId
		from doc_productos_compra
		where ProductoCompraId = @pProductoCompraId
	end
	if(@pCompraDirectaId > 0)
	begin
		select @activo =Activo,
			@sucursalId = SucursalId
		from doc_inv_movimiento
		where MovimientoId = @pCompraDirectaId
	end

	if(
		@activo = 0
	)
	begin
		set @pError = 'No s epueden realizar cambios de precios sobre un movimiento cancelado'
		return	
	end

	Create Table #tmpProductos
	(
		ProductoId int,
		PRecioCompra money
	)

	if(isnull(@pProductoCompraId,0) > 0)
	begin
		insert into #tmpProductos
		select ProductoId,PrecioCompra
		from doc_productos_compra_detalle
		where ProductoCompraId = @pProductoCompraId
	end

	if(isnull(@pCompraDirectaId,0) > 0)
	begin
		insert into #tmpProductos
		select ProductoId,PrecioUnitario
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
		where m.MovimientoId = @pCompraDirectaId and
		m.Activo = 1 and
		m.Autorizado = 1 and
		m.TipoMovimientoId = 7--Entrada directa

	end	
	

	select @productoID = MIn(productoId)
	from #tmpProductos

	while @productoId is not null
	Begin

		select @cambioPrecioPorcUtilidad = CalculaPrecioPorcUtilidad,
			@cambioPrecioIncUtilidad = CalculaPrecioIncUtilidad 
		from cat_productos_config_sucursal
		where ProductoId = @productoId and
		SucursalId = @sucursalId

		

		select @precio = PrecioCompra
		from #tmpProductos

		

		if(
			@cambioPrecioIncUtilidad = 1
		)
		begin

			select @porcTotImpuestos = sum(isnull(i.Porcentaje,0))
			from cat_productos_impuestos pi
			inner join cat_impuestos i on i.Clave = pi.ImpuestoId
			where pi.ProductoId = @productoId

			select @precio = case when isnull(@porcTotImpuestos,0) = 0 then  @precio + isnull(p2.IncUtilidadValor,0) 
									else 
									
									(
										(@precio / (1 + (@porcTotImpuestos / 100))) + isnull(p2.IncUtilidadValor,0) 
									) * (1 + (@porcTotImpuestos / 100))
							end,
				
				@precioAnterior = isnull(pp.Precio,0)
			from #tmpProductos tmp
			inner join cat_productos p on p.ProductoId = tmp.ProductoId
			inner join cat_productos_config_sucursal p2 on p2.ProductoId = p.ProductoId and
													p2.SucursalId = @sucursalId		
			
			left join cat_productos_precios pp on pp.IdProducto = p.ProductoId and
										pp.IdPrecio = 1
			where tmp.productoid = @productoId
		end

		if(
			@cambioPrecioPorcUtilidad = 1
		)
		begin
			select @precio = @precio + (@precio * (isnull(p2.PorcUtilidadValor,0) / 100)),
				
				@precioAnterior = isnull(pp.Precio,0)
			from #tmpProductos tmp
			inner join cat_productos p on p.ProductoId = tmp.ProductoId
			inner join cat_productos_config_sucursal p2 on p2.ProductoId = p.ProductoId and
													p2.SucursalId = @sucursalId
			left join cat_productos_precios pp on pp.IdProducto = p.ProductoId and
										pp.IdPrecio = 1
			where tmp.productoid = @productoId
		end

		--select @cambioPrecioPorcUtilidad,@cambioPrecioIncUtilidad,@precio

		if(@precio  > @precioAnterior
		and
		(@cambioPrecioIncUtilidad = 1 or @cambioPrecioPorcUtilidad = 1)
		)
		begin

			if exists (
				select 1
				from cat_productos_precios
				where IdProducto = @productoId and
				IdPrecio = 1
			)
			begin		

				update cat_productos_precios
				set Precio = @precio
				where IdProducto = @productoId
				and IdPrecio = 1
			End
			Else
			Begin
				select  @idAux  =isnull(max(IdProductoPrecio),0) + 1
				from cat_productos_precios

				insert into cat_productos_precios(
					IdProductoPrecio,IdProducto,IdPrecio,PorcDescuento,MontoDescuento,Precio
				)
				select @idAux,@productoId,1,0,0, @precio

			End			
			
			exec [dbo].[p_ActualizarListaPrecios] @productoId,null,null,0,@precio
			
		End

		select @productoID = MIn(productoId)
		from #tmpProductos
		where productoId > @productoId

	End

	--IF(@cambioPrecioIncUtilidad = 1 oR @cambioPrecioPorcUtilidad = 1)
	--BEGIN
		update doc_productos_compra
		set PrecioAfectado = 1
		where  ProductoCompraId = @pProductoCompraId
	--END











GO
/****** Object:  StoredProcedure [dbo].[p_ActualizarListaPrecios]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_ActualizarListaPrecios 2,0,0,0,200
CREATE PROC [dbo].[p_ActualizarListaPrecios]
@pProductoId INT,
@pPrecioId INT,
@pDescuento MONEY,
@pMontoDescuento MONEY OUT,
@pPrecioFinal MONEY out
AS

	declare	 @precioVta MONEY,
			@precioSinImp MONEY,
			@porcImpuestos decimal(5,2),
			@subtotal MONEY,
			@impuestos MONEY,
			@idAux int

	SELECT @precioVta = Precio
	FROM dbo.cat_productos_precios pre	
	inner join cat_productos p on p.ProductoId = pre.idProducto
	WHERE IdPrecio = 1 and--PRECIO VTA 
	IdProducto = @pProductoId

	SELECT @porcImpuestos = ISNULL(SUM(ISNULL(i.Porcentaje,0)),0)
	FROM dbo.cat_productos_impuestos PI
	INNER JOIN dbo.cat_impuestos I ON I.Clave = PI.ImpuestoId
	WHERE ProductoId = @pProductoId



	IF(@porcImpuestos > 0)
	begin
		SET @impuestos = @precioVta - ( @precioVta / (1+ (@porcImpuestos/100)))
		SET @subtotal = @precioVta - @impuestos
		SET @precioSinImp = @subtotal
	END
    ELSE
    BEGIN
		SET @impuestos = 0 
		SET @subtotal = @precioVta
		SET @precioSinImp = @subtotal
    end
    
	

	/*************ASEGURARSE QUE EXISTAN TODOS LOS PRECIOS PARA EL PRODUCTO *****************/
	BEGIN TRAN

	DECLARE @IdProductoPrecio INT
    SELECT @IdProductoPrecio = ISNULL(MAX(IdProductoPrecio),0)
	FROM cat_productos_precios

	INSERT INTO dbo.cat_productos_precios
	(
	    IdProductoPrecio,
	    IdProducto,
	    IdPrecio,
	    PorcDescuento,
	    MontoDescuento,
	    Precio
	)
	SELECT ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @IdProductoPrecio,
	@pProductoId,
	p.IdPrecio,
	0,
	0,
	ISNULL(@precioVta,@pPrecioFinal)
	FROM dbo.cat_precios p
	where not EXISTS (
		SELECT 1
		FROM dbo.cat_productos_precios
		WHERE IdProducto = @pProductoId AND
        IdPrecio = p.IdPrecio
	)

	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END


	SELECT @idAux = ISNULL(MAX(id),0)
	FROM [cat_productos_cambio_precio]
	
    
	INSERT INTO [dbo].[cat_productos_cambio_precio](
		Id,				ProductoId,		PrecioId,		PrecioAnterior,			PrecioNuevo,
		FechaRegistro,	UsuarioRegistroId)
	SELECT ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @idAux,			IdProducto,		IdPrecio,		Precio,					
	(@precioSinImp -  (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								))
								*
								(1+(@porcImpuestos/100)),
								
	GETDATE(),
	NULL				
	FROM cat_productos_precios
	WHERE IdProducto = @pProductoId AND
	ISNULL(@pPrecioId,0) IN (0,IdPrecio) AND
    IdPrecio > 1	

	
	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END

	UPDATE dbo.cat_productos_precios
	SET Precio = (@precioSinImp -  (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								))
								*
								(1+(@porcImpuestos/100)),
		MontoDescuento = (
								@precioSinImp * (
											CASE WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
													ELSE PorcDescuento
											END
											/100
											)
								),
		PorcDescuento = CASE 
							WHEN ISNULL(@pPrecioId,0) > 0 THEN @pDescuento 
							ELSE PorcDescuento
						END
	WHERE IdProducto = @pProductoId AND
	ISNULL(@pPrecioId,0) IN (0,IdPrecio) AND
    IdPrecio > 1


	if @@error <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO fin
    END
    

	COMMIT TRAN

	fin:

	SELECT @pPrecioFinal = Precio,
			@pMontoDescuento = MontoDescuento
	FROM dbo.cat_productos_precios
	WHERE ISNULL(@pPrecioId,1) = IdPrecio AND
    @pProductoId = IdProducto

	






GO
/****** Object:  StoredProcedure [dbo].[p_BuscarProductos]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_BuscarProductos '1',1
CREATE PROC [dbo].[p_BuscarProductos]
@pText VARCHAR(100),
@pBuscarSoloPorClave bit
AS

SELECT PRO.Clave,
		Descripcion = pro.Descripcion +' '+ isnull(pro.Talla,''),
		Unidad = u.Descripcion ,
		Precio = isnull(precio.Precio,0),
		ID = pro.ProductoId,
		impuestos = CASE WHEN  SUM(imp2.Porcentaje)  > 0 
					THEN (SUM(imp2.Porcentaje) / 100) * ISNULL(precio.Precio,0)
					ELSE 0
				END,
		porcImpuestos = SUM(imp2.Porcentaje),
		Foto = (SELECT foto FROM cat_productos t1 WHERE t1.ProductoId = pro.ProductoId),
		pro.Estatus

FROM dbo.cat_productos pro
left JOIN dbo.cat_productos_precios precio ON 
						precio.IdProducto = pro.ProductoId AND
                        precio.IdPrecio = 1 --publico gral
LEFT JOIN dbo.cat_productos_impuestos imp ON imp.ProductoId = pro.ProductoId
LEFT JOIN dbo.cat_impuestos imp2 ON imp2.Clave = imp.ImpuestoId
left JOIN dbo.cat_unidadesmed u ON u.Clave = pro.ClaveUnidadMedida
WHERE (pro.Descripcion LIKE '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.DescripcionCorta LIKE '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.Clave like '%'+RTRIM(@pText)+'%' AND @pBuscarSoloPorClave = 0)
OR
(pro.Clave = RTRIM(@pText) AND @pBuscarSoloPorClave = 1)
GROUP BY PRO.Clave,
		pro.Descripcion,
		u.Descripcion,
		precio.Precio,
		pro.ProductoId,
		pro.Estatus,
		pro.Talla
ORDER BY pro.Descripcion












GO
/****** Object:  StoredProcedure [dbo].[p_caja_efectivo_disponible_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [p_caja_efectivo_disponible_sel] 1, '20180710'
CREATE Proc [dbo].[p_caja_efectivo_disponible_sel]
@pCajaId int,
@pFecha datetime
as

	declare @efectivoTotalCaja money,
		@retiros money,
		@fechaUltimoCorte datetime,
		@gastos money,
		@pagosApartados money

	/**********Obtener la fecha del ultimo corte************/

	select @fechaUltimoCorte = max(FechaCorte)
	from doc_corte_caja
	where CajaId = @pCajaId

	if(@fechaUltimoCorte is null)
	begin
		select @fechaUltimoCorte = '19000101'
	end

	select @pagosApartados = sum(ap.Importe)
	from doc_apartados_pagos ap
	inner join doc_apartados a on a.ApartadoId = ap.Apartadoid
	where a.CajaId =  @pCajaId and
	ap.FechaPago > @fechaUltimoCorte

	

	select @efectivoTotalCaja = isnull(sum(Cantidad),0)
	from doc_ventas v
	inner join doc_ventas_formas_pago dfp on dfp.VentaId = v.VentaId
	where fecha > @fechaUltimoCorte and
	CajaId = @pCajaId and
	FormaPagoId = 1 and
	v.Activo = 1

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where cajaId = @pCajaId and
	CreadoEl > @fechaUltimoCorte

	select @retiros = isnull(sum(MontoRetiro),0)
	from doc_retiros r
	where r.FechaRetiro > @fechaUltimoCorte
	and r.cajaId  = @pCajaId

	select Disponible = isnull(@efectivoTotalCaja,0) + isnull(@pagosApartados,0) - 
						isnull(@retiros,0) - isnull(@gastos,0)







GO
/****** Object:  StoredProcedure [dbo].[p_calcular_existencias]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_calcular_existencias 1,1,6
CREATE Proc [dbo].[p_calcular_existencias]
@pSucursalId int,
@pProductoId int,
@pMovimientoDetalleId int = 0
as


	declare @entradas float,
			@salidasInv float,
			@salidasVentas float,
			@salidasTot float,
			@existencia float,
			@costoUltimaCompra money,
			@costoPromedio money,
			@valuadoCostoUCompra money,
			@valuadoCostoPromedio money,
			@comprasAcumuladas money,
			@tipoMovimiento int,
			@ultimoValorCtoProm money,
			@actualValorMov money,
			@disopnible decimal(14,2),
			@apartado decimal(14,2)

	select @tipoMovimiento = m.TipoMovimientoId
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where md.MovimientoDetalleId = @pMovimientoDetalleId

	select @entradas = ISNULL(SUM(MD.Cantidad),0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId and
												md.ProductoId = @pProductoId	
	INNER JOIN cat_tipos_movimiento_inventario 	tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId and
											tm.EsEntrada=1												
	where m.Activo = 1 and
	m.Autorizado = 1 and
	m.SucursalId = @pSucursalId


	select @salidasInv = ISNULL(SUM(MD.Cantidad),0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId and
												md.ProductoId = @pProductoId	
	INNER JOIN cat_tipos_movimiento_inventario 	tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId and
											tm.EsEntrada=0												
	where m.Activo = 1 and
	m.Autorizado = 1 and
	m.SucursalId = @pSucursalId

	/*OBTENER TODAS LAS COMPRAS*/

	select @comprasAcumuladas = sum(isnull(md.Importe,0))
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where m.Activo = 1 and
	m.Autorizado = 1 and
	m.TipoMovimientoId in (2) and
	md.ProductoId = @pProductoId
	

	set @salidasTot = isnull(@salidasInv,0) 
	set @existencia = isnull(@entradas,0) - isnull(@salidasTot,0)

	--select TOP 1 @costoUltimaCompra =  ISNULL(PrecioUnitario,0)
	--from doc_productos_compra pc
	--inner join doc_productos_compra_detalle pcd on pcd.ProductoCompraId = pc.ProductoCompraId
	--WHERE PC.Activo = 1 AND
	--PC.SucursalId = @pSucursalId and
	--pcd.ProductoId = @pProductoId
	--ORDER BY PC.FechaRegistro DESC

	select top 1 @costoUltimaCompra = isnull(md.PrecioUnitario,0)
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where m.Activo = 1 and
	m.Autorizado = 1 and
	m.TipoMovimientoId in (2) and
	md.ProductoId = @pProductoId
	order by md.CreadoEl desc

	--if(isnull(@costoUltimaCompra,0) = 0)
	--begin 
	--	select TOP 1 @costoUltimaCompra = MD.CostoUltimaCompra
	--	from doc_inv_movimiento_detalle md
	--	inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
	--	where m.Activo = 1 and
	--	m.Autorizado = 1 and
	--	md.ProductoId = @pProductoId and
	--	m.SucursalId = @pSucursalId
	--	ORDER BY  MovimientoDetalleId DESC
	--end

	

	set @costoPromedio = case when  ISNULL(@existencia,0) = 0 then 0 else isnull(@comprasAcumuladas,0)/ISNULL(@existencia,0) end

	set @valuadoCostoPromedio = ISNULL(isnull(@costoPromedio,0) * isnull(@existencia,0),0)
	set @valuadoCostoUCompra = ISNULL(isnull(@costoUltimaCompra,0) * isnull(@existencia,0),0)


	/***********Calcular valor inventario******************/
	if(
		@tipoMovimiento in (2,7)
	)
	begin

		select top 1 @ultimoValorCtoProm = isnull(ValCostoPromedio,0)
		from doc_inv_movimiento m
		inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
		where md.MovimientoDetalleId <> @pMovimientoDetalleId
		order by  md.MovimientoDetalleId desc

		select @actualValorMov = isnull(PrecioUnitario,0) * isnull(Cantidad,0)
		from doc_inv_movimiento_detalle
		where MovimientoDetalleId = @pMovimientoDetalleId		

		SELECT @costoPromedio = case when ISNULL(@existencia,0) = 0 then 
										(isnull(@actualValorMov,0)+ isnull(@ultimoValorCtoProm,0)) 
										else
										(isnull(@actualValorMov,0)+ isnull(@ultimoValorCtoProm,0)) /  ISNULL(@existencia,0)
								End

	end
	Else
	Begin
		SELECT top 1 @costoPromedio = isnull(CostoPromedio,0)
		from doc_inv_movimiento_detalle md
		inner join doc_inv_movimiento m on m.MovimientoId = md.MovimientoId
		where ProductoId = @pProductoId  and
		m.Sucursalid = @pSucursalId and
		md.MovimientoDetalleId < @pMovimientoDetalleId
		order by md.MovimientoDetalleId desc

	End

	/**********************************APARTADOS***************************/
	SELECT @apartado = isnull(sum(ap.Cantidad),0)
	FROM doc_apartados a
	inner join doc_apartados_productos ap on ap.ApartadoId = a.ApartadoId
	where ap.ProductoId = @pProductoId
	and a.VentaId is null 
	and a.Activo = 1
	/***********************************************************************/

	update doc_inv_movimiento_detalle
		set Disponible = ISNULL(@existencia,0),
			CostoPromedio =ISNULL(@costoPromedio,0),
			CostoUltimaCompra = @costoUltimaCompra,
			ValCostoPromedio = abs(@valuadoCostoPromedio),
			ValCostoUltimaCompra = abs(@valuadoCostoUCompra),
			ValorMovimiento = ISNULL(Cantidad,0) * ISNULL(PrecioUnitario,0)
		where MovimientoDetalleId = @pMovimientoDetalleId 

	/********************************************************/

	IF NOT EXISTS(
		SELECT 1
		FROM cat_productos_existencias
		WHERE productoid = @pProductoId
		and SucursalId = @pSucursalId
	)
	BEGIN
		INSERT INTO cat_productos_existencias(
			ProductoId,				SucursalId,			ExistenciaTeorica,		CostoUltimaCompra,		CostoPromedio,
			ValCostoUltimaCompra,	ValCostoPromedio,	ModificadoEl,			CreadoEl,
			Apartado,				Disponible
		)
		VALUES(
			@pProductoId,			@pSucursalId,		isnull(@existencia,0),			isnull(@costoUltimaCompra,0),		isnull(@costoPromedio,0),
			ISNULL(@valuadoCostoUCompra,0),	ISNULL(@valuadoCostoPromedio,0),getdate(),					getdate(),
			isnull(@apartado,0),				isnull(@existencia,0) - isnull(@apartado,0)
		
		)
	END
	Else
	Begin
		update cat_productos_existencias
		SET ExistenciaTeorica = ISNULL(@existencia,0),
			CostoPromedio = CostoPromedio,
			CostoUltimaCompra = ISNULL(@costoUltimaCompra,0),
			ValCostoPromedio = ISNULL(@valuadoCostoPromedio,0),
			ValCostoUltimaCompra = ISNULL(@valuadoCostoUCompra,0),
			Apartado = isnull(@apartado,0),
			Disponible = isnull(@existencia,0) - isnull(@apartado,0)
		where ProductoId = @pProductoId and
		SucursalId = @pSucursalId
	End

	

		
	
	






GO
/****** Object:  StoredProcedure [dbo].[p_cat_clientes_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_clientes_ins_upd]
@pClienteId int out,
@pNombre varchar(500),
@pRFC varchar(15),
@pCalle varchar(100),
@pNumeroExt varchar(10),
@pNumeroInt varchar(10),
@pColonia varchar(50),
@pCodigoPostal varchar(5),
@pEstadoId int,
@pMunicipioId int,
@pPaisId int,
@pTelefono varchar(15),
@pTelefono2 varchar(15),
@pTipoClienteId int,
@pDiasCredito smallint,
@pLimiteCredito money,
@pAntecedenteId int,
@pCreditoDisponible money,
@pSaldoGlobal money,
@pActivo bit,
@pClienteEspecial bit,
@pClienteGral bit,
@pPrecioId tinyint,
@pGiroId int,
@pClienteAutoId int out,
@pModelo varchar(150),
@pColor varchar(50),
@pPlacas varchar(20),
@pObservaciones varchar(300)
as



	if isnull(@pClienteId,0) = 0
	begin


		select @pClienteId = isnull(max(ClienteId),0) + 1
		from cat_clientes


		insert into cat_clientes(
			ClienteId,	Nombre,		RFC,		Calle,		NumeroExt,		NumeroInt,
			Colonia,	CodigoPostal,EstadoId,	MunicipioId,PaisId,			Telefono,
			Telefono2,	TipoClienteId,DiasCredito,LimiteCredito,AntecedenteId,CreditoDisponible,
			SaldoGlobal,Activo,		ClienteEspecial,ClienteGral,PrecioId,	GiroId
		)
		select @pClienteId,@pNombre,@pRFC,@pCalle,@pNumeroExt,@pNumeroInt,
		@pColonia,	@pCodigoPostal,@pEstadoId,@pMunicipioId,@pPaisId,@pTelefono,
		@pTelefono2,@pTipoClienteId,@pDiasCredito,@pLimiteCredito,@pAntecedenteId,@pCreditoDisponible,
		@pSaldoGlobal,1,@pClienteEspecial,@pClienteGral,@pPrecioId,@pGiroId


	

	End
	Else
	Begin
		update cat_clientes
		set Nombre = @pNombre,		RFC=@pRFC,		Calle=@pCalle,		NumeroExt=@pNumeroExt,		
			NumeroInt=@pNumeroInt,	Colonia=@pColonia,	CodigoPostal=@pCodigoPostal,
			EstadoId=@pEstadoId,	
			MunicipioId=@pMunicipioId,
			PaisId=@pPaisId,			
			Telefono=@pTelefono,
			Telefono2=@pTelefono2,	
			TipoClienteId=@pTipoClienteId,
			DiasCredito=@pDiasCredito,
			LimiteCredito=@pLimiteCredito,
			AntecedenteId=@pAntecedenteId,
			CreditoDisponible=@pCreditoDisponible,
			SaldoGlobal=@pSaldoGlobal,
			Activo=@pActivo,		
			ClienteEspecial=@pClienteEspecial,
			ClienteGral=@pClienteGral,
			PrecioId=@pPrecioId,
			GiroId=@pGiroId
		Where ClienteId = @pClienteId
	End

	if isnull(@pClienteAutoId,0) = 0
	begin

		select @pClienteAutoId = isnull(max(ClienteAutoId),0) +1
		from cat_clientes_automovil

		insert into cat_clientes_automovil(
		ClienteAutoId,	ClienteId,	Modelo,	Color,
		Placas,				Observaciones,CreadoEl
		)
		select @pClienteAutoId,@pClienteId, @pModelo,@pColor,
		@pPlacas,@pObservaciones,GETDATE()
	end
	Else
	Begin
		Update cat_clientes_automovil
		set Modelo=@pModelo,	
		Color = @pColor,
		Placas = @pPlacas,				
		Observaciones = @pObservaciones
		where ClienteAutoId = @pClienteAutoId
	End


	


GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[p_cat_configuracion_ins_upd]
@pConfiguradorId	int,
@pUnaFormaPago	bit,
@pMasUnaFormaPago	bit,
@pCosteoUEPS	bit,
@pCosteoPEPS	bit,
@pCosteoPromedio	bit,
@pAfectarInventarioLinea	bit,
@pAfectarInventarioManual	bit,
@pAfectarInventarioCorte	bit,
@pEnlazarPuntoVentaInventario	bit,
@pCajeroIncluirDetalleVenta	bit,
@pCajeroReqClaveSupervisor	bit,
@pSuperIncluirDetalleVenta	bit,
@pSuperIncluirVentaTel	bit,
@pSuperIncluirDetGastos	bit,
@pSuperEmail1	varchar(100),
@pSuperEmail2	varchar(100),
@pSuperEmail3	varchar(100),
@pSuperEmail4	varchar(100),
@pRetiroMontoEfec	money,
@pRetiroLectura	bit,
@pRetiroEscritura	bit,
@pNombreImpresora	varchar(200),
@pHardwareCaracterCajon	varchar(50),
@pEmpleadoPorcDescuento	decimal(5,2),
@pEmpleadoGlobal	bit,
@pEmpleadoIndividual	bit,
@pMontoImpresionTicket	money,
@pApartadoAnticipo1	money,
@pApartadoAnticipoHasta1	money,
@pApartadoAnticipo2	money,
@pApatadoAnticipoEnAdelante2	money,
@pPorcentajeUtilidadProd	decimal(5,2),
@pDesgloceMontoTicket	bit,
@pRetiroReqClaveSup bit,
@pCajDeclaracionFondoCorte bit,
@pSupDeclaracionFondoCorte bit,
@pvistaPreviaImpresion bit,
@pCajeroCorteDetGasto bit,
@pSupCorteDetGasto bit,
@pCajeroCorteCancelaciones bit,
@pSupCorteCancelaciones bit,
@pDevDiasVale	tinyint,
@pDevDiasGarantia	tinyint,
@pDevHorasGarantia	tinyint,
@pApartadoDiasLiq tinyint,
@pApartadoDiasProrroga tinyint,
@pReqClaveSupReimpresionTicketPV	bit,
@pReqClaveSupCancelaTicketPV	bit,
@pReqClaveSupGastosPV	bit,
@pReqClaveSupDevolucionPV	bit,
@pReqClaveSupApartadoPV	bit,
@pReqClaveSupExistenciaPV	bit,
@pCorteCajaIncluirExistencia bit,
@pImprimirTicketMediaCarta bit,
@pSolicitarComanda bit
as

	update cat_configuracion
	set 
		UnaFormaPago = @pUnaFormaPago,
		MasUnaFormaPago=@pMasUnaFormaPago,
		CosteoUEPS=@pCosteoUEPS,
		CosteoPEPS=@pCosteoPEPS,
		CosteoPromedio=@pCosteoPromedio,
		AfectarInventarioLinea=@pAfectarInventarioLinea,
		AfectarInventarioManual=@pAfectarInventarioManual,
		AfectarInventarioCorte=@pAfectarInventarioCorte,
		EnlazarPuntoVentaInventario=@pEnlazarPuntoVentaInventario,
		CajeroIncluirDetalleVenta=@pCajeroIncluirDetalleVenta,
		CajeroReqClaveSupervisor=@pCajeroReqClaveSupervisor,
		SuperIncluirDetalleVenta=@pSuperIncluirDetalleVenta,
		SuperIncluirVentaTel=@pSuperIncluirVentaTel,
		SuperIncluirDetGastos=@pSuperIncluirDetGastos,
		SuperEmail1=@pSuperEmail1,
		SuperEmail2=@pSuperEmail2,
		SuperEmail3=@pSuperEmail3,
		SuperEmail4=@pSuperEmail4,
		RetiroMontoEfec=@pRetiroMontoEfec,
		RetiroLectura=@pRetiroLectura,
		RetiroEscritura=@pRetiroEscritura,
		NombreImpresora=@pNombreImpresora,
		HardwareCaracterCajon=@pHardwareCaracterCajon,
		EmpleadoPorcDescuento=@pEmpleadoPorcDescuento,
		EmpleadoGlobal=@pEmpleadoGlobal,
		EmpleadoIndividual=@pEmpleadoIndividual,
		MontoImpresionTicket=@pMontoImpresionTicket,
		ApartadoAnticipo1=@pApartadoAnticipo1,
		ApartadoAnticipoHasta1=@pApartadoAnticipoHasta1,
		ApartadoAnticipo2=@pApartadoAnticipo2,
		ApatadoAnticipoEnAdelante2=@pApatadoAnticipoEnAdelante2,
		PorcentajeUtilidadProd=@pPorcentajeUtilidadProd,
		DesgloceMontoTicket=@pDesgloceMontoTicket,
		RetiroReqClaveSup = @pRetiroReqClaveSup,
		CajDeclaracionFondoCorte = @pCajDeclaracionFondoCorte,
		SupDeclaracionFondoCorte = @pSupDeclaracionFondoCorte,
		vistaPreviaImpresion=@pvistaPreviaImpresion,
		CajeroCorteDetGasto = @pCajeroCorteDetGasto,
		SupCorteDetGasto = @pSupCorteDetGasto,
		CajeroCorteCancelaciones = @pCajeroCorteCancelaciones,
		SupCorteCancelaciones = @pSupCorteCancelaciones,
		DevDiasVale = @pDevDiasVale,
		DevDiasGarantia=@pDevDiasGarantia,
		DevHorasGarantia=@pDevHorasGarantia,
		ApartadoDiasLiq = @pApartadoDiasLiq,
		ApartadoDiasProrroga = @pApartadoDiasProrroga,
		ReqClaveSupReimpresionTicketPV	=@pReqClaveSupReimpresionTicketPV,
		ReqClaveSupCancelaTicketPV	=@pReqClaveSupCancelaTicketPV,
		ReqClaveSupGastosPV	=@pReqClaveSupGastosPV,
		ReqClaveSupDevolucionPV	=@pReqClaveSupDevolucionPV,
		ReqClaveSupApartadoPV	=@pReqClaveSupApartadoPV,
		ReqClaveSupExistenciaPV	=@pReqClaveSupExistenciaPV,
		CorteCajaIncluirExistencia = @pCorteCajaIncluirExistencia,
		ImprimirTicketMediaCarta = @pImprimirTicketMediaCarta,
		SolicitarComanda = @pSolicitarComanda
where ConfiguradorId = 1












GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_rest_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_configuracion_rest_ins_upd]
@pId int,
@pSolicitarFolioComanda bit
as

	if not exists(
		select 1
		from [cat_configuracion_restaurante]
	)
	begin
		set @pId = 1

		insert into [cat_configuracion_restaurante]
		select @pId,@pSolicitarFolioComanda
		
	end
	Else
	begin

		update [cat_configuracion_restaurante]
		set SolicitarFolioComanda = @pSolicitarFolioComanda
	end
GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ticket_apartado_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_cat_configuracion_ticket_apartado_ins_upd]
@pConfiguracionTicketVentaId	int OUT,
@pSucursalId	int,
@pTextoCabecera1	varchar(250),
@pTextoCabecera2	varchar(250),
@pTextoPie	varchar(250),
@pCreadoPor	int,
@pSerieTicket varchar(5)
as

	if(isnull(@pConfiguracionTicketVentaId,0) = 0)
	begin
		select @pConfiguracionTicketVentaId = isnull(max(ConfiguracionTicketVentaId),0) + 1
		from cat_configuracion_ticket_apartado


		insert into cat_configuracion_ticket_apartado(
		ConfiguracionTicketVentaId,		SucursalId,		TextoCabecera1,		TextoCabecera2,
		TextoPie,						CreadoEl,		CreadoPor,			Serie
		)
		values(
			@pConfiguracionTicketVentaId,		@pSucursalId,		@pTextoCabecera1,		@pTextoCabecera2,
			@pTextoPie,						getdate(),		@pCreadoPor,	@pSerieTicket
		)
	end
	Else
	begin

		update cat_configuracion_ticket_apartado
		set TextoCabecera1 = @pTextoCabecera1,
			TextoCabecera2 = @pTextoCabecera2,
			TextoPie = @pTextoPie,
			Serie = @pSerieTicket
		where ConfiguracionTicketVentaId = @pConfiguracionTicketVentaId
	End

	





GO
/****** Object:  StoredProcedure [dbo].[p_cat_configuracion_ticket_venta_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_cat_configuracion_ticket_venta_ins_upd]
@pConfiguracionTicketVentaId	int OUT,
@pSucursalId	int,
@pTextoCabecera1	varchar(250),
@pTextoCabecera2	varchar(250),
@pTextoPie	varchar(250),
@pCreadoPor	int,
@pSerieTicket varchar(5)
as

	if(isnull(@pConfiguracionTicketVentaId,0) = 0)
	begin
		select @pConfiguracionTicketVentaId = isnull(max(ConfiguracionTicketVentaId),0) + 1
		from cat_configuracion_ticket_venta


		insert into cat_configuracion_ticket_venta(
		ConfiguracionTicketVentaId,		SucursalId,		TextoCabecera1,		TextoCabecera2,
		TextoPie,						CreadoEl,		CreadoPor,			Serie
		)
		values(
			@pConfiguracionTicketVentaId,		@pSucursalId,		@pTextoCabecera1,		@pTextoCabecera2,
			@pTextoPie,						getdate(),		@pCreadoPor,	@pSerieTicket
		)
	end
	Else
	begin

		update cat_configuracion_ticket_venta
		set TextoCabecera1 = @pTextoCabecera1,
			TextoCabecera2 = @pTextoCabecera2,
			TextoPie = @pTextoPie,
			Serie  = @pSerieTicket
		where ConfiguracionTicketVentaId = @pConfiguracionTicketVentaId
	End

	

	





GO
/****** Object:  StoredProcedure [dbo].[p_cat_impuestos_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_impuestos_grd ''
	CREATE PROC [dbo].[p_cat_impuestos_grd]
@pBuscar VARCHAR(100)
AS

	SELECT imp.Clave,
			imp.CodigoSAT,
			imp.Descripcion,
			Abreviatura = abr.AbreviaturaSAT,
			imp.OrdenImpresion,
			Clasificacion = cla.NombreSAT,
			TipoFactor = fac.NombreFactorSAT,
			imp.Porcentaje,
			imp.CuotaFija,
			imp.DecimalesPorcCuota,
			imp.DesglosarImpPrecioVta,
			imp.AgregarImpPrecioVta 
	FROM dbo.cat_impuestos imp
	INNER JOIN dbo.cat_tipo_factor_SAT fac ON fac.Clave = imp.IdTipoFactor
	INNER JOIN dbo.cat_clasificacion_impuestos cla ON cla.Clave = imp.IdClasificacionImpuesto
	INNER JOIN dbo.cat_abreviaturas_SAT abr ON abr.Clave = imp.IdAbreviatura
	WHERE Descripcion LIKE '%'+RTRIM(@pBuscar)+'%' OR @pBuscar = ''





GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_agrupados_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_productos_agrupados_detalle_ins]
@pProductoAgrupadoId int,
@pProductoId int
as

	declare @especificaciones varchar(500)

	select @especificaciones = Especificaciones
	from cat_productos_agrupados
	where ProductoAgrupadoId = @pProductoAgrupadoId 

	insert into [dbo].[cat_productos_agrupados_detalle](
		ProductoAgrupadoId,ProductoId,CreadoEl
	)
	select @pProductoAgrupadoId,@pProductoId,getdate()

	--update cat_productos
	--set Especificaciones = @especificaciones
	--where ProductoId = @pProductoId


	update cat_productos 
	set Liquidacion = pa1.Liquidacion
	from cat_productos p
	inner join cat_productos_agrupados_detalle pa on pa.ProductoId = p.ProductoId
	inner join cat_productos_agrupados pa1 on pa1.ProductoAgrupadoId = pa.ProductoAgrupadoId
	where pa1.ProductoAgrupadoId = @pProductoAgrupadoId




GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_agrupados_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[p_cat_productos_agrupados_ins_upd]
@pProductoAgrupadoId	int out,	
@pProductoId	int,
@pEspecificaciones varchar(500),
@pLiquidacion bit
as

	declare @Descripcion	varchar(60),
			@DescripcionCorta	varchar(30)

	select @Descripcion =Descripcion ,
		@DescripcionCorta = DescripcionCorta,
		@pEspecificaciones = Especificaciones
	from cat_productos
	where ProductoId =@pProductoId 

	if isnull(@pProductoAgrupadoId,0) = 0
	begin

		select @pProductoAgrupadoId = isnull(max(ProductoAgrupadoId),0) + 1
		from cat_productos_agrupados
		
		insert into cat_productos_agrupados(
			ProductoAgrupadoId,Descripcion,DescripcionCorta,CreadoEl,Especificaciones,ProductoId,
			Liquidacion
		)
		values(
			@pProductoAgrupadoId,@Descripcion,@DescripcionCorta,getdate(),@pEspecificaciones,@pProductoId,
			@pLiquidacion
		)

		insert into cat_productos_agrupados_detalle(ProductoAgrupadoId,ProductoId,CreadoEl)
		values(@pProductoAgrupadoId,@pProductoId,getdate())
	end
	Else
	Begin
		
		update 	cat_productos_agrupados
		set Descripcion=@Descripcion,
			DescripcionCorta=@DescripcionCorta,
			Especificaciones=@pEspecificaciones,
			ProductoId = @pProductoId,
			Liquidacion = @pLiquidacion
		where ProductoAgrupadoId = @pProductoAgrupadoId


		--update cat_productos
		--set Especificaciones = CASE WHEN ISNULL(@pEspecificaciones,'') = '' THEN Especificaciones
		--						ELSE @pEspecificaciones
		--						end
		--from cat_productos p
		--inner join cat_productos_agrupados pa on pa.ProductoId = p.ProductoId
		--where pa.ProductoAgrupadoId = @pProductoAgrupadoId

	End

	update cat_productos 
	set Liquidacion = @pLiquidacion
	from cat_productos p
	inner join cat_productos_agrupados_detalle pa on pa.ProductoId = p.ProductoId
	where pa.ProductoAgrupadoId = @pProductoAgrupadoId

	


GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_config_sucursal_ins_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_cat_productos_config_sucursal_ins_upd]
@pProductoId	int,
@pSucursalId	int,
@pCalculaPrecioPorcUtilidad	bit,
@pCalculaPrecioIncUtilidad	bit,
@pCalculaPrecioManual	bit,
@pPorcUtilidadValor	decimal(6,2),
@pIncUtilidadValor	money,
@pCreadoPor	int
as

	if not exists (
		select 1
		from cat_productos_config_sucursal
		where productoid = @pProductoId and
		sucursalid = @pSucursalId
	)
	begin

		insert into [cat_productos_config_sucursal](
			ProductoId,			SucursalId,		CalculaPrecioPorcUtilidad,		CalculaPrecioIncUtilidad,
			CalculaPrecioManual,CreadoPor,		CreadoEl,						PorcUtilidadValor,
			IncUtilidadValor
		)
		values(
			@pProductoId,			@pSucursalId,		@pCalculaPrecioPorcUtilidad,		@pCalculaPrecioIncUtilidad,
			@pCalculaPrecioManual,	@pCreadoPor,		getdate(),				@pPorcUtilidadValor,
			@pIncUtilidadValor
		)
		
	end
	else
	begin
		update [cat_productos_config_sucursal]
		set CalculaPrecioPorcUtilidad = @pCalculaPrecioPorcUtilidad,		
			CalculaPrecioIncUtilidad = @pCalculaPrecioIncUtilidad,
			CalculaPrecioManual = @pCalculaPrecioManual,
			PorcUtilidadValor = @pPorcUtilidadValor,
			IncUtilidadValor = @pIncUtilidadValor
		where ProductoId = @pProductoId and
		SucursalId = @pSucursalId
		
	end







GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_productos_grd 1
create proc [dbo].[p_cat_productos_grd]
@pEmpresaId int
as

	select p.ProductoId,
			p.Clave,
			p.Descripcion,
			p.DescripcionCorta,
			p.FechaAlta,
			p.ClaveMarca,
			Marca =mar.Descripcion,
			p.ClaveFamilia,
			Familia = fam.Descripcion,
			p.ClaveSubFamilia,
			Subfamilia = sfam.Descripcion,
			p.ClaveLinea,
			Linea = li.Descripcion,
			p.ClaveUnidadMedida,
			Unidad = um.Descripcion,
			p.ClaveInventariadoPor,
			p.ClaveVendidaPor,
			p.Estatus,
			p.ProductoTerminado,
			p.Inventariable,
			p.MateriaPrima,
			p.ProdParaVenta,
			p.ProdVtaBascula,
			p.Seriado,
			p.NumeroDecimales,
			p.PorcDescuentoEmpleado,
			p.ContenidoCaja,
			p.Empresa,
			p.Sucursal,
			p.ClaveAlmacen,
			p.ClaveAnden,
			p.ClaveLote,
			p.FechaCaducidad,
			p.MinimoInventario,
			p.MaximoInventario,
			p.PorcUtilidad,
			p.Talla,
			p.ParaSexo,
			p.Color,
			p.Color2,
			p.SobrePedido,
			p.Especificaciones,
			p.Liquidacion ,
			Foto = FileByte
	from cat_productos p
	left join cat_productos_imagenes pi on pi.ProductoId = p.ProductoId and
									pi.Principal = 1
	inner join cat_familias fam on fam.Clave = p.ClaveFamilia
	inner join cat_subfamilias sfam on sfam.Clave = p.ClaveSubFamilia
	inner join cat_lineas li on li.Clave = p.ClaveLinea
	inner join cat_unidadesmed um on um.Clave = p.ClaveUnidadMedida
	left join cat_marcas mar on mar.Clave = p.ClaveMarca
GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[p_cat_productos_ins]
@pProductoId	int out,
@pClave	varchar(30),
@pDescripcion	varchar(60),
@pDescripcionCorta	varchar(30),
@pFechaAlta	date,
@pClaveMarca	int,
@pClaveFamilia	int,
@pClaveSubFamilia	int,
@pClaveLinea	int,
@pClaveUnidadMedida	int,
@pClaveInventariadoPor	int,
@pClaveVendidaPor	int,
@pEstatus	bit,
@pProductoTerminado	bit,
@pInventariable	bit,
@pMateriaPrima	bit,
@pProdParaVenta	bit,
@pProdVtaBascula	bit,
@pSeriado	bit,
@pNumeroDecimales	tinyint,
@pPorcDescuentoEmpleado	numeric(19,2),
@pContenidoCaja	int,
@pEmpresa	int,
@pSucursal	INT,
@pFoto	IMAGE,
@pClaveAlmacen INT,
@pClaveAnden INT,
@pClaveLote INT,
@pFechaCaducidad DATETIME,
@pMinimoInventario DECIMAL(14,2),
@pMaximoInventario DECIMAL(14,2),
@pPorcUtilidad decimal(5,2),
@pTalla varchar(5),
@pColor varchar(10),
@pColor2 varchar(10),
@pEspecificaciones varchar(500),
@pSobrePedido bit
as


SELECT @pProductoId = ISNULL(MAX(ProductoId),0) + 1
FROM dbo.cat_productos


INSERT INTO dbo.cat_productos
(
    ProductoId,
    Clave,
    Descripcion,
    DescripcionCorta,
    FechaAlta,
    ClaveMarca,
    ClaveFamilia,
    ClaveSubFamilia,
    ClaveLinea,
    ClaveUnidadMedida,
    ClaveInventariadoPor,
    ClaveVendidaPor,
    Estatus,
    ProductoTerminado,
    Inventariable,
    MateriaPrima,
    ProdParaVenta,
    ProdVtaBascula,
    Seriado,
    NumeroDecimales,
    PorcDescuentoEmpleado,
    ContenidoCaja,
    Empresa,
    Sucursal,
    Foto,
	ClaveAlmacen,
	ClaveAnden,
	ClaveLote,
	FechaCaducidad,
	MinimoInventario,
	MaximoInventario,
	PorcUtilidad,
	Talla,
	Color,
	Color2,
	Especificaciones,
	SobrePedido
)
VALUES
(	@pProductoId,
    @pClave,
    @pDescripcion,
    @pDescripcionCorta,
    @pFechaAlta,
    @pClaveMarca,
    @pClaveFamilia,
    @pClaveSubFamilia,
    @pClaveLinea,
    @pClaveUnidadMedida,
    @pClaveInventariadoPor,
    @pClaveVendidaPor,
    @pEstatus,
    @pProductoTerminado,
    @pInventariable,
    @pMateriaPrima,
    @pProdParaVenta,
    @pProdVtaBascula,
    @pSeriado,
    @pNumeroDecimales,
    @pPorcDescuentoEmpleado,
    @pContenidoCaja,
    @pEmpresa,
    @pSucursal,
    @pFoto,
	@pClaveAlmacen,
	@pClaveAnden,
	@pClaveLote,
	@pFechaCaducidad,
	@pMinimoInventario,
	@pMaximoInventario,
	@pPorcUtilidad,
	@pTalla,
	@pColor,
	@pColor2,
	@pEspecificaciones,
	@pSobrePedido
    )	


insert into cat_productos_existencias(
	ProductoId,	SucursalId,	ExistenciaTeorica,	CostoUltimaCompra,
	CostoPromedio,	ValCostoUltimaCompra,	ValCostoPromedio,
	ModificadoEl,	CreadoEl
)
select @pProductoId,@pSucursal,0,0,0,0,0,getdate(),getdate()
















GO
/****** Object:  StoredProcedure [dbo].[p_cat_productos_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_cat_productos_upd]
@pProductoId	int,
@pClave	varchar(30),
@pDescripcion	varchar(60),
@pDescripcionCorta	varchar(30),
@pFechaAlta	date,
@pClaveMarca	int,
@pClaveFamilia	int,
@pClaveSubFamilia	int,
@pClaveLinea	int,
@pClaveUnidadMedida	int,
@pClaveInventariadoPor	int,
@pClaveVendidaPor	int,
@pEstatus	bit,
@pProductoTerminado	bit,
@pInventariable	bit,
@pMateriaPrima	bit,
@pProdParaVenta	bit,
@pProdVtaBascula	bit,
@pSeriado	bit,
@pNumeroDecimales	tinyint,
@pPorcDescuentoEmpleado	numeric(19,2),
@pContenidoCaja	int,
@pEmpresa	int,
@pSucursal	INT,
@pFoto	IMAGE,
@pClaveAlmacen INT,
@pClaveAnden INT,
@pClaveLote INT,
@pFechaCaducidad datetime,
@pMinimoInventario DECIMAL(14,2),
@pMaximoInventario DECIMAL(14,2),
@pPorcUtilidad decimal(5,2),
@pTalla varchar(5),
@pColor varchar(10),
@pColor2 varchar(10),
@pEspecificaciones varchar(500),
@pSobrePedido bit
as

update dbo.cat_productos
set
    
    Clave = @pClave,
    Descripcion = @pDescripcion,
    DescripcionCorta = @pDescripcionCorta,
    --FechaAlta = @pFechaAlta,
    ClaveMarca = @pClaveMarca,
    ClaveFamilia = @pClaveFamilia,
    ClaveSubFamilia = @pClaveSubFamilia,
    ClaveLinea = @pClaveLinea,
    ClaveUnidadMedida = @pClaveUnidadMedida,
    ClaveInventariadoPor = @pClaveInventariadoPor,
    ClaveVendidaPor = @pClaveVendidaPor,
    Estatus = @pEstatus,
    ProductoTerminado = @pProductoTerminado,
    Inventariable = @pInventariable,
    MateriaPrima = @pMateriaPrima,
    ProdParaVenta = @pProdParaVenta,
    ProdVtaBascula = @pProdVtaBascula,
    Seriado = @pSeriado,
    NumeroDecimales = @pNumeroDecimales,
    PorcDescuentoEmpleado = @pPorcDescuentoEmpleado,
    ContenidoCaja = @pContenidoCaja,
    Empresa = @pEmpresa,
    Sucursal = @pSucursal,
    Foto = @pFoto,
	ClaveAlmacen = @pClaveAlmacen,
	ClaveAnden = @pClaveAnden,
	ClaveLote = @pClaveLote,
	FechaCaducidad = @pFechaCaducidad,
	MinimoInventario = @pMinimoInventario,
	MaximoInventario = @pMaximoInventario,
	PorcUtilidad = @pPorcUtilidad,
	TallA = @pTalla,
	Color = @pColor,
	Color2 = @pColor2,
	Especificaciones = @pEspecificaciones,
	SobrePedido = @pSobrePedido
	WHERE ProductoId = @pProductoId









GO
/****** Object:  StoredProcedure [dbo].[p_cat_rest_comandas_gen]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_cat_rest_comandas_gen]
@pSucursalId int,
@pFolioInicio int,
@pFolioFin int,
@pCreadoPor int
as

	declare @folio int,
			@comandaId int

	select @folio = @pFolioInicio

	while @folio <= @pFolioFin
	begin

		select @comandaId = isnull(max(ComandaId),0)+1
		from cat_rest_comandas

		insert into cat_rest_comandas(
		ComandaId,		SucursalId,		Folio,		Disponible,
		CreadoPor,		CreadoEl
		)
			select @comandaId,@pSucursalId,@folio,1,
			@pCreadoPor,getdate()

		select 	@folio = @folio + 1
	end

	
GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_cat_sucursales_grd ''
CREATE PROC [dbo].[p_cat_sucursales_grd]
@pText VARCHAR(100)

AS
	SELECT Clave,NombreSucursal,Empresa,Estatus ,
	Calle,
	Colonia,
	NoExt = rtrim(NoExt),
	NoInt  = rtrim(NoInt),
	Ciudad,
	Estado,
	Pais,
	Telefono1,
	Telefono2,
	cp,
	ServidorMailSMTP,
	ServidorMailFrom,
	ServidorMailPort,
	ServidorMailPassword
	FROM dbo.cat_sucursales
	WHERE NombreSucursal LIKE '%'+RTRIM(@pText)+'%'
	OR RTRIM(@pText) = ''
	OR CAST(Clave AS varchar) = @pText









GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_cat_sucursales_ins]
@pClave	int,
@pEmpresa	int,
@pCalle	varchar(50),
@pColonia	varchar(50),
@pNoExt	nchar(40),
@pNoInt	nchar(40),
@pCiudad	varchar(60),
@pEstado	varchar(60),
@pPais	varchar(60),
@pTelefono1	varchar(40),
@pTelefono2	varchar(40),
@pEmail	varchar(60),
@pEstatus	BIT,
@pNombreSucursal	varchar(60),
@pCp varchar(5),
@pServidorMailSMTP varchar(50),
@pServidorMailFrom varchar(70), 
@pServidorMailPort smallint,
@pServidorMailPassword varchar(50) 
as

INSERT INTO dbo.cat_sucursales
(
    Clave,
    Empresa,
    Calle,
    Colonia,
    NoExt,
    NoInt,
    Ciudad,
    Estado,
    Pais,
    Telefono1,
    Telefono2,
    Email,
    Estatus,
    NombreSucursal,
	cp,
	ServidorMailSMTP,
	ServidorMailFrom,
	ServidorMailPort,
	ServidorMailPassword
)
VALUES
(	@pClave,
    @pEmpresa,
    @pCalle,
    @pColonia,
    @pNoExt,
    @pNoInt,
    @pCiudad,
    @pEstado,
    @pPais,
    @pTelefono1,
    @pTelefono2,
    @pEmail,
    @pEstatus,
    @pNombreSucursal,
	@pcp,
	@pServidorMailSMTP,
	@pServidorMailFrom,
	@pServidorMailPort,
	@pServidorMailPassword
    )






GO
/****** Object:  StoredProcedure [dbo].[p_cat_sucursales_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_cat_sucursales_upd]
@pClave	int,
@pEmpresa	int,
@pCalle	varchar(50),
@pColonia	varchar(50),
@pNoExt	nchar(40),
@pNoInt	nchar(40),
@pCiudad	varchar(60),
@pEstado	varchar(60),
@pPais	varchar(60),
@pTelefono1	varchar(40),
@pTelefono2	varchar(40),
@pEmail	varchar(60),
@pEstatus	BIT,
@pNombreSucursal	varchar(60),
@pCp varchar(5),
@pServidorMailSMTP varchar(50),
@pServidorMailFrom varchar(70), 
@pServidorMailPort smallint,
@pServidorMailPassword varchar(50) 
as

update dbo.cat_sucursales
set
    Clave=@pClave,
    Empresa = @pEmpresa,
    Calle = @pCalle,
    Colonia = @pColonia,
    NoExt = @pNoExt,
    NoInt = @pNoInt,
    Ciudad = @pCiudad,
    Estado = @pEstado,
    Pais = @pPais,
    Telefono1 = @pTelefono1,
    Telefono2 = @pTelefono2,
    Email = @pEmail,
    Estatus = @pEstatus,
    NombreSucursal = @pNombreSucursal,
	cp = @pCp,
	ServidorMailSMTP = @pServidorMailSMTP,
	ServidorMailFrom = @pServidorMailFrom,
	ServidorMailPort = @pServidorMailPort,
	ServidorMailPassword=@pServidorMailPassword
	WHERE Clave = @pClave






GO
/****** Object:  StoredProcedure [dbo].[p_cliente_web_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_cliente_web_ins]
@pClienteId int out,
@pEmail varchar(150),
@pPassword varchar(20),
@pNombre varchar(500)
as
begin
	select @pClienteId = isnull(MAX(ClienteId),0) + 1
	from [cat_clientes]

	begin tran

	insert into [dbo].[cat_clientes](
		ClienteId,Nombre,Activo
	)
	select @pClienteId,@pNombre,1

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	insert into [dbo].[cat_clientes_web](
		ClienteId,Email,Password,CreadoEl
	)
	select @pClienteId,@pEmail,@pPassword,GETDATE()

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:
	end




GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_generacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_corte_caja_generacion 1,1,'20180516',0
CREATE Proc [dbo].[p_corte_caja_generacion]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pCorteCajaId int out,
@pPermitirCorteEnCero bit
as


	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@retiros money,
		@ventaIniId int,
		@ventaFinId int,
		@sucursalId int,
		@esSupervisorGral bit,
		@cajeroOrigId int,
		@totalApartados money


	select @esSupervisorGral = usu.EsSupervisor
	from cat_usuarios usu
	where usu.IdUsuario = @pUsuarioId	


	select @pFechaHoraCorte = case when max(Fecha) > getdate() then max(Fecha) else getdate() end
	from doc_ventas
	where activo = 1

	set @pFechaHoraCorte = isnull(@pFechaHoraCorte,getdate())


	select @fechaUltimoCorte = isnull(max(FechaCorte),'19000101')
	from doc_corte_caja
	where CajaId = @pCajaId

	select @sucursalId  =Sucursal
	from cat_cajas
	where Clave = @pCajaId


	if @fechaUltimoCorte = '19000101' 
	begin
		select @fechaUltimoCorte = min(Fecha)
		from doc_ventas
		where CajaId = @pCajaId
	end

	begin tran

	select @corteCajaId = isnull(max(CorteCajaId),0) + 1
	from doc_corte_caja

	select @pCorteCajaId = @corteCajaId


	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	UsuarioCreacionId = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		--(
		--	r.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		r.CajaId = @pCajaId and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		--(
		--	g.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where 
		--(
		--	dev.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
		
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 
		--and
		--(
		--	ap.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)	
	--
	if not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	v.UsuarioCreacionId = @pUsuarioId 
		--	or
		--	@esSupervisorGral = 1
		--)
		having isnull(max(ventaid),0) > 0
	)	
	AND @pPermitirCorteEnCero = 0
	begin
		RAISERROR (15600,-1,-1, 'No hay movimientos para generar el corte');  
		
		goto fin
	
	end

	/************LIMITAR LAS VENTAS QUE SE PUEDEN CONSIDERAR EN EL CORTE*****************/
	select *
	into #tmpVentas
	from doc_ventas
	where cajaId = @pCajaId and
	Fecha between 
	@fechaUltimoCorte and @pFechaHoraCorte --AND
	--(
	--	UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	--Quitar los tickets de apartados
	and ventaId not in (
		select VentaId
		from doc_apartados
		where isnull(ventaid,0) > 0
	)

	if(@esSupervisorGral = 1)
		select @cajeroOrigId = UsuarioCreacionId
		from #tmpVentas

	select @totalApartados = isnull(Sum(Cantidad),0)
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId

	insert into doc_corte_caja(
		CorteCajaId,	CajaId,		CreadoEl,		CreadoPor,
		VentaIniId,		VentaFinId,	FechaApertura,	FechaCorte,
		TotalCorte,		TotalIngresos,TotalEgresos)
	select @corteCajaId, @pCajaId, getdate(),		@pUsuarioId,
		min(VentaId),	max(ventaid),@fechaUltimoCorte,	@pFechaHoraCorte,
		isnull(sum(
			case when v.Activo = 1 then TotalVenta 
				else 0
			end
		),0)+ isnull(@totalApartados,0), 
		isnull(sum(case when v.Activo = 1 then TotalVenta 
				else 0
			end),0) + isnull(@totalApartados,0),			0
	from #tmpVentas v
	--where cajaId = @pCajaId and
	--Fecha between 
	--@fechaUltimoCorte and @pFechaHoraCorte AND
	--UsuarioCreacionId = @pUsuarioId
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	insert into doc_corte_caja_ventas(CorteId,VentaId,CreadoEl)
	select @corteCajaId, v.VentaId,GETDATE()
	from #tmpVentas v

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where activo = 1 and
	cajaid = @pCajaId and
	creadoEl between @fechaUltimoCorte and @pFechaHoraCorte 
	--and
	--(
	--	CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)

	select @retiros = sum(MontoRetiro)
	from doc_retiros r
	where r.SucursalId = @sucursalId AND
	--(
	--	r.CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--) and
	r.CajaId = @pCajaId and
	r.FechaRetiro  between @fechaUltimoCorte and @pFechaHoraCorte 


	update doc_corte_caja
	set TotalEgresos = isnull(@gastos,0) + isnull(@retiros,0)
	where CorteCajaId = @corteCajaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into doc_corte_caja_egresos(CorteCajaId,Gastos)
	select @corteCajaId,@gastos

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @ventaIniId=VentaIniId,
		@ventaFinId=VentaFinId
	from doc_corte_caja
	where cortecajaId = @corteCajaId
	
	insert into [dbo].[doc_corte_caja_fp](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,vfp.FormaPagoId,sum(Cantidad),getdate()
	from [dbo].[doc_ventas_formas_pago] vfp
	inner join #tmpVentas v on v.ventaId = vfp.ventaId
	where v.VentaId between @ventaIniId and @ventaFinId
	and v.Activo = 1
	--AND (
	--	V.UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	group by vfp.FormaPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [doc_corte_caja_fp_apartado](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,fp.FormaPagoId,isnull(Sum(Cantidad),0),GETDATE()
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	

	insert into [dbo].[doc_corte_caja_apartados_pagos](
		CorteCajaId,ApartadoPagoId,CreadoEl
	)
	select @corteCajaId,ap.ApartadoPagoId,GETDATE()
	from  doc_apartados_pagos ap 
	where ap.Cajaid = @pCajaId AND
	ap.FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by ap.ApartadoPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	/*****Cerrar la sesión del cajero****************/
	declare @pSesionId int

	

	
	update 	doc_sesiones_punto_venta
	set 	Finalizada = 1,
			FechaCorte = getdate(),
			CorteAplicado = 1,
			CorteCajaId = @corteCajaId
	where 	
		SesionId in(
		select  s.SesionId
			from doc_sesiones_punto_venta  s		
			inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId
			where s.CajaId = @pCajaId and
			isnull(s.Finalizada,0) = 0 
	)
		
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	commit tran


	fin:





GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_generacion_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_corte_caja_generacion_previo 1,2,'15/02/2019 12:20:47',0,1
CREATE Proc [dbo].[p_corte_caja_generacion_previo]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pCorteCajaId int out,
@pPermitirCorteEnCero bit
as


	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@retiros money,
		@ventaIniId int,
		@ventaFinId int,
		@sucursalId int,
		@esSupervisorGral bit,
		@cajeroOrigId int

	/***Limpiar tablas***/
	select CorteCajaId
	into #tmpCorteCaja_temp
	from [doc_corte_caja_previo]
	where CreadoPor = @pUsuarioId	


	delete [doc_corte_caja_apartados_pagos]
	from [doc_corte_caja_apartados_pagos] a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_denominaciones_previo
	from doc_corte_caja_denominaciones_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_egresos_previo
	from doc_corte_caja_egresos_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_fp_apartado_previo
	from doc_corte_caja_fp_apartado_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_fp_previo
	from doc_corte_caja_fp_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_previo
	from doc_corte_caja_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteCajaId

	delete doc_corte_caja_ventas_previo
	from doc_corte_caja_ventas_previo a
	inner join #tmpCorteCaja_temp tmp on tmp.CorteCajaId = a.CorteId
	/*******************************/
	


	select @esSupervisorGral = usu.EsSupervisor
	from cat_usuarios usu
	where usu.IdUsuario = @pUsuarioId	


	--select @pFechaHoraCorte =  max(FechaCorte)--case when max(FechaCorte) > dbo.fn_GetDateTimeServer() then max(FechaCorte) else dbo.fn_GetDateTimeServer() end
	--from doc_corte_caja_previo
	--where CajaId = @pCajaId

	

	set @pFechaHoraCorte = isnull(@pFechaHoraCorte,dbo.fn_GetDateTimeServer())


	

	
	if(@fechaUltimoCorte is null)
	begin
		select @fechaUltimoCorte = isnull(max(FechaCorte),dateadd(day,-1,getdate()))
		from doc_corte_caja
		where CajaId = @pCajaId 
	end

	

	select @sucursalId  =Sucursal
	from cat_cajas
	where Clave = @pCajaId

	


	if isnull(@fechaUltimoCorte,'19000101') = '19000101' 
	begin
		select @fechaUltimoCorte = min(Fecha)
		from doc_ventas
		where CajaId = @pCajaId
	end

	begin tran

	select @corteCajaId = isnull(max(CorteCajaId),0) + 1
	from doc_corte_caja_previo

	select @pCorteCajaId = @corteCajaId


	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	UsuarioCreacionId = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		--(
		--	r.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		r.CajaId = @pCajaId and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		--(
		--	g.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where 
		--(
		--	dev.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
		
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 
		--and
		--(
		--	ap.CreadoPor = @pUsuarioId or
		--	@esSupervisorGral = 1
		--)
	)	
	--
	if not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		--and (
		--	v.UsuarioCreacionId = @pUsuarioId 
		--	or
		--	@esSupervisorGral = 1
		--)
		having isnull(max(ventaid),0) > 0
	)	
	AND @pPermitirCorteEnCero = 0
	begin
		RAISERROR (15600,-1,-1, 'No hay movimientos para generar el corte');  
		
		goto fin
	
	end

	/************LIMITAR LAS VENTAS QUE SE PUEDEN CONSIDERAR EN EL CORTE*****************/
	select *
	into #tmpVentas
	from doc_ventas
	where cajaId = @pCajaId and
	UsuarioCreacionId = @pUsuarioId AND

	Fecha between 
	@fechaUltimoCorte and @pFechaHoraCorte --AND
	--(
	--	UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	--Quitar los tickets de apartados
	and ventaId not in (
		select VentaId
		from doc_apartados
		where isnull(ventaid,0) > 0
	)

	if(@esSupervisorGral = 1)
		select @cajeroOrigId = UsuarioCreacionId
		from #tmpVentas

	insert into doc_corte_caja_previo(
		CorteCajaId,	CajaId,		CreadoEl,		CreadoPor,
		VentaIniId,		VentaFinId,	FechaApertura,	FechaCorte,
		TotalCorte,		TotalIngresos,TotalEgresos)
	select @corteCajaId, @pCajaId, dbo.fn_GetDateTimeServer(),		@pUsuarioId,
		min(VentaId),	max(ventaid),isnull(@fechaUltimoCorte,dbo.fn_GetDateTimeServer()),	@pFechaHoraCorte,
		isnull(sum(
			case when v.Activo = 1 then TotalVenta 
				else 0
			end
		),0), isnull(sum(case when v.Activo = 1 then TotalVenta 
				else 0
			end),0),			0
	from #tmpVentas v
	--where cajaId = @pCajaId and
	--Fecha between 
	--@fechaUltimoCorte and @pFechaHoraCorte AND
	--UsuarioCreacionId = @pUsuarioId
	

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	insert into doc_corte_caja_ventas_previo(CorteId,VentaId,CreadoEl)
	select @corteCajaId, v.VentaId,dbo.fn_GetDateTimeServer()
	from #tmpVentas v

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @gastos = isnull(sum(Monto),0)
	from doc_gastos
	where activo = 1 and
	cajaid = @pCajaId and
	creadoEl between @fechaUltimoCorte and @pFechaHoraCorte 
	--and
	--(
	--	CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)

	select @retiros = sum(MontoRetiro)
	from doc_retiros r
	where r.SucursalId = @sucursalId AND
	--(
	--	r.CreadoPor = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--) and
	r.CajaId = @pCajaId and
	r.FechaRetiro  between @fechaUltimoCorte and @pFechaHoraCorte 


	update doc_corte_caja_previo
	set TotalEgresos = isnull(@gastos,0) + isnull(@retiros,0)
	where CorteCajaId = @corteCajaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into doc_corte_caja_egresos_previo(CorteCajaId,Gastos)
	select @corteCajaId,@gastos

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	select @ventaIniId=VentaIniId,
		@ventaFinId=VentaFinId
	from doc_corte_caja_previo
	where cortecajaId = @corteCajaId
	
	insert into [dbo].[doc_corte_caja_fp_previo](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,vfp.FormaPagoId,sum(Cantidad),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_ventas_formas_pago] vfp
	inner join #tmpVentas v on v.ventaId = vfp.ventaId
	where v.VentaId between @ventaIniId and @ventaFinId
	and v.Activo = 1
	--AND (
	--	V.UsuarioCreacionId = @pUsuarioId
	--	or
	--	@esSupervisorGral = 1
	--)
	group by vfp.FormaPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [doc_corte_caja_fp_apartado_previo](
		CorteCajaId,FormaPagoId,Total,CreadoEl
	)
	select @corteCajaId,fp.FormaPagoId,isnull(Sum(Cantidad),0),dbo.fn_GetDateTimeServer()
	from [dbo].[doc_apartados_formas_pago] fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.Cajaid = @pCajaId AND
	FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by fp.FormaPagoId



	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	insert into [dbo].[doc_corte_caja_apartados_pagos_previo](
		CorteCajaId,ApartadoPagoId,CreadoEl
	)
	select @corteCajaId,ap.ApartadoPagoId,dbo.fn_GetDateTimeServer()
	from  doc_apartados_pagos ap 
	where ap.Cajaid = @pCajaId AND
	ap.FechaPago between @fechaUltimoCorte and @pFechaHoraCorte 
	group by ap.ApartadoPagoId


	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	
	commit tran


	fin:







GO
/****** Object:  StoredProcedure [dbo].[p_corte_caja_validaMovs]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_corte_caja_validaMovs 1,1,'20180418'
CREATE Proc [dbo].[p_corte_caja_validaMovs]
@pCajaId int,
@pUsuarioId int,
@pFechaHoraCorte datetime,
@pHayMovimientos bit out
as

	set @pHayMovimientos = 0
	set dateformat dmy
	declare @fechaUltimoCorte datetime,
		@corteCajaId int,
		@gastos money,
		@ventaIniId int,
		@ventaFinId int,
		@error varchar(500) = '',
		@esSupervisorGral bit

		set @pFechaHoraCorte = getdate()

	select @fechaUltimoCorte = isnull(max(FechaCorte),'19000101')
	from doc_corte_caja
	where CajaId = @pCajaId	

	select @esSupervisorGral = EsSupervisor
	from cat_usuarios
	where IdUsuario = @pUsuarioId

	--validar CANCELACIONES
	if not exists(
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		FechaCancelacion between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		and (
			UsuarioCreacionId = @pUsuarioId OR
			@esSupervisorGral = 1
		)
	)
	--validar retiros
	and not exists(
		select 1
		from doc_retiros r
		where 
		(
			r.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral = 1
		)
		 and
		
			r.CajaId = @pCajaId 
			
		 and
		r.FechaRetiro between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar gastos
	and not exists(
		select 1
		from doc_gastos g
		where g.CajaId = @pCajaId and
		(
			g.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral = 1
		) and
		g.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
	)
	--validar devoluciones
	and not exists(
		select 1
		from doc_devoluciones dev
		where (
			dev.CreadoPor = @pUsuarioId
			OR
			@esSupervisorGral =1
		) and
		dev.CreadoEl between @fechaUltimoCorte and @pFechaHoraCorte
		
	)
	--Validar ventas
	and not exists (
		select 1
		from doc_ventas v
		where cajaId = @pCajaId and
		Fecha between 
		@fechaUltimoCorte and @pFechaHoraCorte
		and v.activo = 1 
		and (
			UsuarioCreacionId = @pUsuarioId
			OR
			@esSupervisorGral = 1
		)
		
	)
	--validar apartados
	and not exists (
		select 1
		from doc_apartados a
		inner join doc_apartados_pagos ap on ap.ApartadoId = a.ApartadoId
		where a.CajaId = @pCajaId  and
		ap.FechaPago between 
		@fechaUltimoCorte and @pFechaHoraCorte and
		a.Activo = 1 and
		(
			ap.CreadoPor = @pUsuarioId
			or 
			@esSupervisorGral = 1
		)
	)	
	
	begin
		set @error= 'No hay movimientos para generar el corte'		
		set @pHayMovimientos = 0
	
	end
	else
		set @pHayMovimientos = 1

	select @error










GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartado_venta_generacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- p_doc_apartado_venta_generacion 3,1,0
CREATE proc [dbo].[p_doc_apartado_venta_generacion]
@pApartadoId int,
@pCreadoPor int,
@pVentaId bigint out
as

	declare 
		@descuentoTotal money,
		@impuestos money,
		@subtotal money,
		@total money,
		@ventaDetalleId int

	select @pVentaId = isnull(max(VentaId),0) + 1
	from doc_ventas

	select @descuentoTotal = isnull(sum(Descuentos),0),
		@impuestos = isnull(sum(Impuestos),0),
		@subtotal = isnull(sum(Subtotal),0),
		@total = isnull(sum(Total),0)
	from doc_apartados_productos
	where ApartadoId = @pApartadoId

	
	
	begin tran

	insert into doc_ventas(
		VentaId,			Folio,				Fecha,				ClienteId,
		DescuentoVentaSiNo,	PorcDescuentoVenta,	MontoDescuentoVenta,DescuentoEnPartidas,
		TotalDescuento,		Impuestos,			SubTotal,			TotalVenta,
		TotalRecibido,		Cambio,				Activo,				UsuarioCreacionId,
		FechaCreacion,		UsuarioCancelacionId,FechaCancelacion,	SucursalId,
		CajaId
	)
	select @pVentaId,		@pVentaId,			GETDATE(),			ClienteId,
	case when isnull(@descuentoTotal,0) > 0 then 1 else 0 end,
	0,0,@descuentoTotal,
	@descuentoTotal,		@impuestos,			@subtotal,			@total,
		@total ,				0,					1,					@pCreadoPor,
		GETDATE(),			null,				null,				SucursalId,
		CajaId
	from doc_apartados a	
	where ApartadoId = @pApartadoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	select @ventaDetalleId= isnull(max(VentaDetalleId),0) + 1
	from doc_ventas_detalle

	insert into doc_ventas_detalle(
		VentaDetalleId,			VentaId,		ProductoId,		Cantidad,
		PrecioUnitario,			PorcDescuneto,	Descuento,		Impuestos,
		Total,					UsuarioCreacionId,FechaCreacion
	)
	select ROW_NUMBER() OVER(ORDER BY ApartadoProductoId ASC) + @ventaDetalleId ,		@pVentaId,		ProductoId,		Cantidad,
		Precio,					POrcentajeDescuento,Descuentos,	Impuestos,
		Total,					@pCreadoPor,GETDATE()				
	from doc_apartados_productos
	where ApartadoId = @pApartadoId


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	

	
	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	update doc_apartados
	set VentaId = @pVentaId
	where ApartadoId = @pApartadoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	insert into doc_ventas_formas_pago(
		FormaPagoId,	VentaId,	Cantidad,	FechaCreacion,
		UsuarioCreacionId,digitoVerificador
	)
	select isnull(FormaPagoId,1),@pVentaId,Importe = sum(fp.cantidad),getdate(),
	@pCreadoPor,max(digitoverificador)
	from doc_apartados_formas_pago fp
	inner join doc_apartados_pagos ap on ap.ApartadoPagoId = fp.ApartadoPagoId
	where ap.ApartadoId = @pApartadoId and
	fp.cantidad > 0
	group by fp.FormaPagoId


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran
	fin:
	






GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_consulta_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_apartados_consulta_grd 1,'D'
create proc [dbo].[p_doc_apartados_consulta_grd]
@pSucursalId int,
@pTexto varchar(200),
@pSoloConSaldo bit
as

	select a.ClienteId,
		c.Nombre,
		Saldo = sum(a.Saldo)
	from doc_apartados a
	inner join cat_clientes c on c.ClienteId = a.ClienteId
	where a.SucursalId = @pSucursalId 
	and
	(
		cast(a.ClienteId as varchar) = cast(@pTexto as varchar) OR
		c.Nombre like '%'+rtrim(@pTexto)+'%'
	)
	group by a.ClienteId,c.Nombre
	having (sum(a.Saldo) > 0 and @pSoloConSaldo = 1)
	OR
	@pSoloConSaldo = 0




GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE pROC [dbo].[p_doc_apartados_ins]
@pApartadoId	int out,
@pSucursalId	int,
@pClienteId	int,
@pTotalApartado	money,
@pSaldo	money,
@pCreadoPor	int,
@pCajaId int
as

	declare @fechaVencimiento datetime,
			@fechaProrroga datetime,
			@diasLiquidacion int,
			@diasProrroga int

	select @diasLiquidacion = ApartadoDiasLiq,
		@diasProrroga = ApartadoDiasProrroga
	from cat_configuracion

	set @fechaVencimiento = DATEADD(dd,@diasLiquidacion,getdate())
	set @fechaProrroga = DATEADD(dd,@diasProrroga,@fechaVencimiento)
	

	select @pApartadoId = isnull(max(ApartadoId),0)+1
	from doc_apartados

	

	insert into doc_apartados(
		ApartadoId,	SucursalId,	ClienteId,	TotalApartado,
		Saldo,		Activo,		CreadoEl,	CreadoPor,
		FechaLimite,FechaProrroga,VentaId,	CajaId
	)
	select @pApartadoId,	@pSucursalId,	@pClienteId,	@pTotalApartado,
		@pSaldo,		1,		getdate(),	@pCreadoPor,
		@fechaVencimiento,@fechaProrroga,null,@pCajaId

	

	







GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_mov_inv]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_apartados_mov_inv]
@pApartadoId int
as

	declare @MovimientoId int,
			@MovimientoDetalleId int,
			@consecutivo int

	select @MovimientoId = isnull(max(MovimientoId),0) + 1
	from doc_inv_movimiento

	select @consecutivo = isnull(max(Consecutivo),0)+1
	from doc_inv_movimiento
	where TipoMovimientoId = 17

	begin tran

	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,	FolioMovimiento,	TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,Comentarios,		ImporteTotal,
		Activo,			CreadoPor,		CreadoEl,		Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,	VentaId,
		MovimientoRefId,Cancelado
	)
	select @MovimientoId,SucursalId,@consecutivo,17,
	GETDATE(),			GETDATE(),	'',					TotalApartado,
	1,				CreadoPor,		GETDATE(),			1,
	GETDATE(),			NULL,			CreadoPor,		null,
	null,				@consecutivo,SucursalId,		null,
	null,				0
	from doc_apartados
	where ApartadoId = @pApartadoId

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	select @MovimientoDetalleId = isnull(max(MovimientoDetalleId),0)+1

	from doc_inv_movimiento_detalle
	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
		Cantidad,				PrecioUnitario,	Importe,		Disponible,
		CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
		ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
	)
	SELECT @MovimientoDetalleId + ROW_NUMBER() OVER(ORDER BY ProductoId ASC) ,@MovimientoId,	ProductoId,ROW_NUMBER() OVER(ORDER BY ProductoId ASC) ,
	Cantidad,					Precio,			Total,			Cantidad,
	CreadoPor,					GETDATE(),		null,			null,
	null,						null,			null
	FROM doc_apartados_productos
	WHERE ApartadoId = @pApartadoId

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran
	fin:


	








GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_pagos_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_apartados_pagos_ins]
@pApartadoPagoId	int out,
@pApartadoId	int,
@pImporte	money,
@pFechaPago	datetime,
@pCreadoPor	int,
@pAnticipo bit,
@pFormaPagoId int,
@pDigitoVerificador varchar(20),
@pCajaId int
as

	declare	 @pagos money,
			@total money

		begin tran		

		if(@pApartadoPagoId = 0)
		begin 		

			select @pApartadoPagoId=isnull(max(ApartadoPagoId),0)+1
			from doc_apartados_pagos 


			insert into doc_apartados_pagos(
				ApartadoPagoId,ApartadoId,Importe,FechaPago,CreadoPor,Anticipo,CajaId
			)
			values(
				@pApartadoPagoId,@pApartadoId,@pImporte,GETDATE(),@pCreadoPor,@pAnticipo,@pCajaId
			)

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
		end

		insert into doc_apartados_formas_pago(
			ApartadoPagoId,	FormaPagoId,	DigitoVerificador,CreadoEl,Cantidad
		)
		select @pApartadoPagoId,@pFormaPagoId,@pDigitoVerificador,GETDATE(),@pImporte

		if @@error <> 0
		begin
				rollback tran
				goto fin
		end

		update doc_apartados_pagos
		set Importe = (select sum(isnull(cantidad,0)) from doc_apartados_formas_pago st1 where st1.ApartadoPagoId = @pApartadoPagoId)
		where ApartadoPagoId = @pApartadoPagoId

		if @@error <> 0
		begin
				rollback tran
				goto fin
		end

		/**Actualizar saldo***/

		select @total = TotalApartado
		from doc_apartados
		where ApartadoId = @pApartadoId

		select @pagos = isnull(sum(Importe),0)
		from doc_apartados_pagos
		where ApartadoId = @pApartadoId

		update doc_apartados
		set Saldo = @total - @pagos
		where ApartadoId = @pApartadoId

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end


		commit tran
		fin:












GO
/****** Object:  StoredProcedure [dbo].[p_doc_apartados_productos_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_doc_apartados_productos_ins]
@pApartadoProductoId	int out,
@pApartadoId	int,
@pProductoId	int,
@pCantidad	decimal(7,2),
@pPrecio	money,
@pCreadoPor	int,
@pSubTotal money,
@pImpuestos money,
@pDescuentos money,
@pPorcDescuneto decimal(6,2),
@pTotal money
as

	select @pApartadoProductoId = isnull(max(ApartadoProductoId),0) + 1
	from doc_apartados_productos

	begin tran
	
	insert into doc_apartados_productos(
		ApartadoProductoId,	ApartadoId,	ProductoId,	Cantidad,
		Precio,				CreadoEl,	CreadoPor,	ModificadoEl,
		ModificadoPor,		Total,		Subtotal,	Impuestos,
		Descuentos,			POrcentajeDescuento
	)
	select @pApartadoProductoId,@pApartadoId,@pProductoId,@pCantidad,
	@pPrecio,				GETDATE(),	@pCreadoPor,null,
	null,					@pTotal,
	@pSubTotal,@pImpuestos,@pDescuentos,@pPorcDescuneto

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_apartados_productos
		set Descuentos = (cantidad * precio ) - Total
	where ApartadoProductoId = @pApartadoProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
	





GO
/****** Object:  StoredProcedure [dbo].[p_doc_corte_caja_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- [p_doc_corte_caja_grd] 2,2,'20180501','20180504'
CREATE Proc [dbo].[p_doc_corte_caja_grd]
@pSucursalId int,
@pUsuarioId int,
@pFechaDel DateTime,
@pFechaAl DateTime
as

	


	select CC.CajaId,
		CC.TotalCorte,
		CC.TotalEgresos,
		CC.TotalIngresos,
		CC.CreadoEl,
		cc.CorteCajaId,
		Sucursal = suc.NombreSucursal,
		Caja = c.Descripcion
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.clave = c.sucursal
	inner join cat_usuarios usu on usu.IdUsuario = @pUsuarioId
	where --c.Sucursal = @pSucursalId and
	(
		@pUsuarioId in (cc.CreadoPor,0) 
		OR
		usu.EsSupervisor = 1

	) and
	convert(varchar,cc.CreadoEl,112) between convert(varchar,@pFechaDel,112) and convert(varchar,@pFechaAl,112)
	ORDER BY CC.CorteCajaId DESC





GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[p_doc_devolucion_detalle_ins]
@pDevolucionDetId	int out,
@pDevolucionId	int,
@pVentaId	bigint,
@pProductoId	int,
@pCantidad	decimal(14,2),
@pTotal	money,
@pCreadoEl	datetime,
@pCreadoPor	int,
@pError varchar(250) out
as

	declare @pCantidadEnDevolucion decimal(5,2),
			@pCantidadTicket decimal(5,2),
			@error varchar(250)

	select @pCantidadEnDevolucion = isnull(sum(Cantidad),0)
	from doc_devoluciones_detalle  dd
	inner join doc_devoluciones d on d.DevolucionId = dd.DevolucionId
	where d.VentaId = @pVentaId and
	dd.ProductoId = @pProductoId

	select @pCantidadTicket = isnull(sum(vd.Cantidad),0)
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	where v.VentaId = @pVentaId and
	vd.ProductoId = @pProductoId

	set @pCantidadEnDevolucion= isnull(@pCantidadEnDevolucion,0) + @pCantidad

	if(@pCantidadEnDevolucion > @pCantidadTicket)
	begin
		set @pError='Ya no se puede devolver mas cantidad para el producto '+cast(@pProductoId as varchar) + ' Disponible:'+cast((@pCantidadTicket-(@pCantidadEnDevolucion - @pCantidadTicket)) as varchar)
		
		return
	end

	select @pDevolucionDetId = isnull(max(DevolucionDetId),0)+1
	from doc_devoluciones_detalle

	insert into doc_devoluciones_detalle(
		DevolucionDetId,		DevolucionId,		VentaId,		ProductoId,
		Cantidad,				Total,				CreadoEl,		CreadoPor
	)	
	values(
		@pDevolucionDetId,		@pDevolucionId,		@pVentaId,		@pProductoId,
		@pCantidad,				@pTotal,				getdate(),		@pCreadoPor
	)







GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_devolucion_ins]
@pDevolucionId int out,
@pVentaId bigint,
@pTotal money,
@pCreadoEl datetime,
@pCreadoPor int,
@pTipoDevolucionId int
as

	declare @fechaVencimiento datetime,
		@diasVencimientoVale int

	select @diasVencimientoVale = isnull(DevDiasVale,0)
	from cat_configuracion

	select @fechaVencimiento = DATEADD(dd,@diasVencimientoVale,getdate())

	


	select @pDevolucionId = isnull(max(DevolucionId),0) + 1
	from doc_devoluciones

	insert into doc_devoluciones(
		DevolucionId,VentaId,CreadoEl,CreadoPor,Total,TipoDevolucionId,
		FechaVencimiento
	)
	values(
		@pDevolucionId,@pVentaId,getdate(),@pCreadoPor,@pTotal,@pTipoDevolucionId,
		@fechaVencimiento
	)

	






GO
/****** Object:  StoredProcedure [dbo].[p_doc_devolucion_mov_inv_genera]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_doc_devolucion_mov_inv_genera 3,2
create proc [dbo].[p_doc_devolucion_mov_inv_genera]
@pDevolucionId int,
@pCreadoPor int
as

	declare @movimientoId int,
			@folioMov int,
			@sucursalId int

	select @movimientoId = max(MovimientoId)+1
	from doc_inv_movimiento

	select @sucursalId = v.SucursalId
	from doc_devoluciones dev
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where dev.DevolucionId = @pDevolucionId


	select @folioMov = isnull(max(Consecutivo),0) +1 
	from doc_inv_movimiento
	where SucursalId = @sucursalId
	and TipoMovimientoId = 20 --Devolución	
	
	BEGIN TRAN

	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,	FolioMovimiento,	TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,Comentarios,		ImporteTotal,
		Activo,			CreadoPor,	CreadoEl,			Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,FechaCancelacion,
		ProductoCompraId,Consecutivo,SucursalOrigenId,	VentaId,
		MovimientoRefId,Cancelado
	)
	select @movimientoId,@sucursalId,@folioMov,20,
	GETDATE(),GETDATE(),			'Devolución Folio:'+cast(@pDevolucionId as varchar),dev.Total,
	1,				@pCreadoPor,	GETDATE(),			1,
	GETDATE(),		NULL,				@pCreadoPor,	NULL,
	NULL,			@folioMov,		NULL,				NULL,
	NULL,				0
	from doc_devoluciones dev
	inner join doc_ventas v on v.VentaId = dev.VentaId
	WHERE dev.DevolucionId = @pDevolucionId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO FIN
	END


	DECLARE @movimientoDetalleId int

	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	INSERT INTO doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
		Cantidad,				PrecioUnitario,	Importe,		Disponible,
		CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
		ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
	)
	select row_number() over (order by DevolucionDetId) +@movimientoDetalleId,@movimientoId,d.ProductoId,row_number() over (order by DevolucionDetId),
	D.Cantidad,					d.Total/d.Cantidad,D.Total,D.Cantidad,
	@pCreadoPor,				GETDATE(),		null,			null,
	null,					null,				null
	from doc_devoluciones_detalle d
	where DevolucionId = @pDevolucionId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		GOTO FIN
	END

	COMMIT TRAN

	FIN:



GO
/****** Object:  StoredProcedure [dbo].[p_doc_devoluciones_grid]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_doc_devoluciones_grid 1,0
CREATE Proc [dbo].[p_doc_devoluciones_grid]
@pVentaId int,
@pDevolucionId int
as

	
	select 
		dev.DevolucionId,
		dev2.DevolucionDetId,
		v.VentaId,
		vd.ProductoId,
		PrecioUnitario= CASE WHEN isnull(vd.Descuento,0) > 0 THEN 
							 cast(vd.PrecioUnitario - (isnull(vd.Descuento,0)/isnull(VD.Cantidad,0)) as decimal(14,2))
							 ELSE cast(vd.PrecioUnitario  as decimal(14,2))
							end,
		Producto=prod.Descripcion,
		Cantidad = isnull(dev2.Cantidad,0),
		Total = isnull(dev2.Total,0),
		Seleccionar = cast(case when dev2.DevolucionDetId is null then 0 else 1 end as bit),
		CantidadTicket = sum(vd.Cantidad) ,
		FechaTicket = v.FechaCreacion
		
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_productos prod on prod.ProductoId = vd.ProductoId
	left join doc_devoluciones dev on
					--(
					--		(dev.DevolucionId = @pDevolucionId and
					--		@pDevolucionId > 0)
					--		Or 
					--		@pDevolucionId = 0
					--)
					--AND
					--(
					--	(
					--		dev.VentaId = @pVentaId 
					--		and @pVentaId > 0
					--	)
					--	OR @pVentaId = 0
					--) and
					dev.VentaId = v.VentaId and
					dev.DevolucionId = @pDevolucionId 
				
	left join doc_devoluciones_detalle dev2 on dev2.DevolucionId = dev.DevolucionId AND
												DEV2.ProductoId = VD.ProductoId
	where
	v.activo=1 and
	(
		(
			@pDevolucionId > 0 and dev.VentaId is not null
		)
		OR 
		(@pVentaId > 0 and v.VentaId = @pVentaId)
	)
	group by  v.VentaId,
		vd.ProductoId,
		vd.PrecioUnitario,
	prod.Descripcion,
	dev2.Cantidad,
	dev2.Total,
	dev.DevolucionId,
		dev2.DevolucionDetId,
		v.FechaCreacion,
		vd.Descuento,VD.Cantidad









GO
/****** Object:  StoredProcedure [dbo].[p_doc_gasto_del_valida]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_gasto_del_valida 1
Create Proc [dbo].[p_doc_gasto_del_valida]
@pGastoId int
as

	declare @error varchar(250)=''
	
	if exists (
		select  1
		from doc_gastos g
		inner join doc_corte_caja cc on cc.CorteCajaId = cc.CorteCajaId
		where GastoId = @pGastoId  and
		g.CreadoEl between FechaApertura and FechaCorte

	)
	begin

		set @error = 'No es posible editar/eliminar el gasto, ya se realizó un corte de caja'
		
	end

	select error = @error





GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_cancel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_inv_movimiento_cancel]
@pMovimientoId int,
@pModificadoPor int
as

	update [doc_inv_movimiento]
	set --Activo = 1,
		FechaCancelacion = getdate(),
		Cancelado=1
		--Autorizado = 1
	where MovimientoId = @pMovimientoId






GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_inv_movimiento_ins]
@pMovimientoId int out,
@pSucursalId int,
@pFolioMovimiento varchar(10),
@pTipoMovimientoId int,
@pFechaMovimiento datetime,
@pHoraMovimiento time(7),
@pComentarios varchar(250),
@pImporteTotal money,
@pCreadoPor int,
@pAutorizado	bit,
@pFechaAutoriza	datetime,
@pSucursalOrigenId	int,
@pSucursalDestinoId	int,
@pAutorizadoPor	int          
as

	declare @consecutivo int

	select @pMovimientoId = isnull(max(MovimientoId),0) + 1
	from [doc_inv_movimiento]

	select @consecutivo = isnull(max(consecutivo),0)  + 1
	from [doc_inv_movimiento]
	where [TipoMovimientoId] = @pTipoMovimientoId
	and [SucursalId] = @pSucursalId

	set @pFolioMovimiento = cast(@consecutivo as varchar(20))



	INSERT INTO [dbo].[doc_inv_movimiento]
           ([MovimientoId]
           ,[SucursalId]
           ,[FolioMovimiento]
           ,[TipoMovimientoId]
           ,[FechaMovimiento]
           ,[HoraMovimiento]
           ,[Comentarios]
           ,[ImporteTotal]
           ,[Activo]
           ,[CreadoPor]
           ,[CreadoEl],
		   Autorizado,
		FechaAutoriza,
		SucursalDestinoId,
		AutorizadoPor,
		Consecutivo,
		SucursalOrigenId)
     VALUES
           (@pMovimientoId, 
           @pSucursalId,
           @pFolioMovimiento, 
           @pTipoMovimientoId,
           @pFechaMovimiento,
           @pHoraMovimiento,
           @pComentarios, 
           @pImporteTotal, 
           1,
           @pCreadoPor,
           getdate(),
		   @pAutorizado,
			@pFechaAutoriza,
			@pSucursalDestinoId,
			@pAutorizadoPor,
			@consecutivo,
			@pSucursalOrigenId
		   )






GO
/****** Object:  StoredProcedure [dbo].[p_doc_inv_movimiento_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_inv_movimiento_upd]
@pMovimientoId int out,
@pSucursalId int,
@pFolioMovimiento varchar(10),
@pTipoMovimientoId int,
@pFechaMovimiento datetime,
@pHoraMovimiento time(7),
@pComentarios varchar(250),
@pImporteTotal money,
@pCreadoPor int,
@pAutorizado	bit,
@pFechaAutoriza	datetime,
@pSucursalOrigenId	int,
@pSucursalDestinoId	int,
@pAutorizadoPor	int          
as

update [doc_inv_movimiento]
set
           [SucursalId] = @pSucursalId                                            
           ,[Comentarios]=@pComentarios
           ,[ImporteTotal]=@pImporteTotal
           ,[Activo]=1		   		
		   ,SucursalDestinoId = @pSucursalDestinoId	
		   ,SucursalOrigenId = @pSucursalOrigenId
where MovimientoId = @pMovimientoId






GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_adicional_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_adicional_del]
@pPedidoDetalleId int
as


	delete [dbo].[doc_pedidos_orden_adicional]
	where PedidoDetalleId = @pPedidoDetalleId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_adicional_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_adicional_ins]
@pPedidoDetalleId int,
@pAdicionalId int,
@pCreadoPor int
as
		insert into doc_pedidos_orden_adicional(PedidoDetalleId,AdicionalId,CreadoEl,CreadoPor)
		select @pPedidoDetalleId,@pAdicionalId,getdate(),@pCreadoPor
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_buscar]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[p_doc_pedidos_orden_buscar]
@pMesasId varchar(500),
@pComandaId int
as


	select mesaId = splitdata
	into #tmpMesas
	from [dbo].[fnSplitString](@pMesasId,',')


	select PedidoId = isnull(max(p.PedidoId),0)
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_mesa pm on pm.PedidoOrdenId = p.PedidoId
	inner join #tmpMesas m on m.mesaId = pm.MesaId
	where p.VentaId is null and
	isnull(p.MotivoCancelacion,'') = ''

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_cancelacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_pedidos_orden_cancelacion]
@pPedidoId int,
@pMotivoCancelacion varchar(150),
@pCanceladoPor int
as

	update doc_pedidos_orden
	set Cancelada = 1,
		FechaCancelacion = getdate(),
		MotivoCancelacion = @pMotivoCancelacion,
		CanceladoPor = @pCanceladoPor,
		Activo = 0
	where PedidoId = @pPedidoId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_pedidos_orden_detalle_del]
@pPedidoDetalleId int
as

	--begin tran

	--delete [dbo].[doc_pedidos_orden_adicional]
	--where PedidoDetalleId = @pPedidoDetalleId

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin

	--end

	--delete [dbo].[doc_pedidos_orden_ingre]
	--where PedidoDetalleId = @pPedidoDetalleId

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin

	--end

	--delete [dbo].[doc_pedidos_orden_detalle]
	--where PedidoDetalleId = @pPedidoDetalleId

	update doc_pedidos_orden_detalle
	set Cantidad = 0,
		Cancelado = 1,		
		Descuento = 0,
		Impuestos = 0,
		Total = 0
	where PedidoDetalleId = @pPedidoDetalleId

	
	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin

	--end



	--commit tran
	fin:

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_detalle_insupd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_pedidos_orden_detalle_insupd]
@pPedidoDetalleId	int out,
@pPedidoId	int,
@pProductoId	int,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pPorcDescuento	decimal(5,2),
@pDescuento	money,
@pImpuestos	money,
@pNotas	varchar(200),
@pTotal	money,
@pCreadoPor	int,
@pTasaIVA	decimal(5,2),
@pParallevar bit,
@pComandaId int OUT
as

	declare @porcIVA decimal(5,2)

	select @porcIVA = (Porcentaje / 100)
	from cat_productos_impuestos pi
	inner join cat_impuestos i on i.Clave = pi.ImpuestoId 
	where pi.ProductoId = @pProductoId and
	pi.ImpuestoId = 1--IVA	

	select @pPrecioUnitario = Precio
	from  cat_productos_precios 
	where IdProducto = @pProductoId and
	IdPrecio = 1

	set @pTotal = @pPrecioUnitario * @pCantidad

	set @pImpuestos = case when @porcIVA > 0 then  @pTotal / (1 + @porcIVA) else 0 end

	if not exists (
		select 1
		from [doc_pedidos_orden_detalle]
		where PedidoDetalleId = @pPedidoDetalleId
	)
	begin


		--Comanda
		if(isnull(@pComandaId,0)=0)
		begin
			select @pComandaId = min(c.ComandaId)
			from cat_rest_comandas c
			inner join doc_pedidos_orden p on p.PedidoId = @pPedidoId
			left join doc_pedidos_orden_detalle pd on pd.ComandaId = c.ComandaId
			where Disponible = 1 and
			p.SucursalId = P.SucursalId  and
			pd.ComandaId is null


			if(isnull(@pComandaId,0) = 0)
			begin
				

				select @pComandaId = isnull(max(ComandaId),0) + 1
				from cat_rest_comandas 

				insert into cat_rest_comandas(
					ComandaId,SucursalId,Folio,Disponible,CreadoPor,CreadoEl
				)
				select @pComandaId,p.SucursalId,cast(@pComandaId as varchar),0,@pCreadoPor,getdate()
				from  doc_pedidos_orden p where p.PedidoId = @pPedidoId

				 
			end
		end

		update cat_rest_comandas
		set Disponible = 0
		where ComandaId = @pComandaId

		select @pPedidoDetalleId = isnull(max(PedidoDetalleId),0) + 1
		from [doc_pedidos_orden_detalle]

		insert into  [dbo].[doc_pedidos_orden_detalle](
			PedidoDetalleId,	PedidoId,	ProductoId,	Cantidad,	PrecioUnitario,	PorcDescuento,
			Descuento,			Impuestos,	Notas,		Total,		CreadoPor,		CreadoEl,
			TasaIVA,			Impreso,	Parallevar,	ComandaId
		)
		select @pPedidoDetalleId,	@pPedidoId,		@pProductoId,	@pCantidad,		@pPrecioUnitario,	@pPorcDescuento,
			@pDescuento,			@pImpuestos,	@pNotas,		@pTotal  ,		@pCreadoPor,		getdate(),
			@pTasaIVA,			0,			@pParallevar, @pComandaId
	end
	Else
	Begin
		update [doc_pedidos_orden_detalle]
		set ProductoId=@pProductoId,
			Cantidad = @pCantidad,
			PrecioUnitario = @pPrecioUnitario,
			PorcDescuento = @pPorcDescuento,
			Descuento = @pDescuento,
			Impuestos = @pImpuestos,
			Notas = @pNotas,
			Total = @pTotal,
			TasaIVA = @pTasaIVA
		WHERE PedidoDetalleId = PedidoDetalleId

	End

	update doc_pedidos_orden
	set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId),
		Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId)
	where PedidoId = @pPedidoId

	update doc_pedidos_orden
	set Subtotal = Total-isnull(Impuestos,0)
	where PedidoId = @pPedidoId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_ingre_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_ingre_del]
@pPedidoDetalleId int
as


	delete doc_pedidos_orden_ingre
	where PedidoDetalleId = @pPedidoDetalleId

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_ingre_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_ingre_ins]
@pPedidoDetalleId int,
@pProductoMateriaPrimaId int,
@pCon bit,
@pSin bit,
@pCreadoPor int
as

	insert into doc_pedidos_orden_ingre(PedidoDetalleId,ProductoId,CreadoEl,CreadoPor,Con, Sin)
	select @pPedidoDetalleId,@pProductoMateriaPrimaId,getdate(),@pCreadoPor,@pCon,@pSin
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_insupd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_insupd]
@pPedidoId	int OUT,
@pSucursalId	int,
@pComandaId	int,
@pPorcDescuento	decimal(5,2),
@pSubtotal	money,
@pDescuento	money,
@pImpuestos	money,
@pTotal	money,
@pClienteId	int,
@pMotivoCancelacion	varchar(150),
@pActivo	bit,
@pCreadoPor	int,
@pPersonas tinyint,
@pFechaApertura Datetime,
@pFechaCierre Datetime
as


	set @pClienteId = case when @pClienteId =0 then null else @pClienteId end

	if not exists (
		select 1
		from [doc_pedidos_orden]
		where PedidoId = @pPedidoId
	)
	begin

		select @pPedidoId = isnull(max(PedidoId),0) + 1
		from [doc_pedidos_orden]
		
		insert into [dbo].[doc_pedidos_orden](
			PedidoId,SucursalId,ComandaId,PorcDescuento,Subtotal,Descuento,Impuestos,Total,ClienteId,MotivoCancelacion,
			Activo,CreadoEl,CreadoPor,Personas,FechaApertura,FechaCierre
		)
		select @pPedidoId,@pSucursalId,@pComandaId,@pPorcDescuento,@pSubtotal,@pDescuento,@pImpuestos,@pTotal,@pClienteId,@pMotivoCancelacion,
			1,getdate(),@pCreadoPor,@pPersonas,@pFechaApertura,@pFechaCierre
	end
	Else
	Begin
		update [doc_pedidos_orden]
		set ComandaId = @pComandaId,
			PorcDescuento = @pPorcDescuento,
			Subtotal = @pSubtotal,
			Descuento = @pDescuento,
			Impuestos = @pImpuestos,
			Total = @pTotal,
			ClienteId = @pClienteId,
			MotivoCancelacion = @pMotivoCancelacion,
			Activo = @pActivo,
			FechaCierre = @pFechaCierre,
			Personas = @pPersonas
		where PedidoId = @pPedidoId
			
	End

	
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesa_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesa_del]
@pPedidoOrdenId int
as


	delete doc_pedidos_orden_mesa
	where PedidoOrdenId = @pPedidoOrdenId

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesa_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesa_ins]
@pPedidoOrdenId int,
@pMesaId int
as


	insert into doc_pedidos_orden_mesa(
		PedidoOrdenId,MesaId,CreadoEl
	)
	select @pPedidoOrdenId,@pMesaId,getdate()

GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesero_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesero_del]
@pPedidoOrdenId int
as

	delete [doc_pedidos_orden_mesero]
	where PedidoOrdenId = @pPedidoOrdenId
GO
/****** Object:  StoredProcedure [dbo].[p_doc_pedidos_orden_mesero_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_doc_pedidos_orden_mesero_ins]
@pPedidoOrdenId int,
@pEmpleadoId int
as

	insert into [dbo].[doc_pedidos_orden_mesero](
		PedidoOrdenId,EmpleadoId,CreadoEl
	)
	select @pPedidoOrdenId,@pEmpleadoId,getdate()
GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_cancelar]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_productos_compra_cancelar]
@pProductoCompraId int,
@pUsuarioId int
as

	begin tran

	update doc_productos_compra
	set FechaCancelacion = getdate(),
	CanceladoPor = @pUsuarioId,
	Activo = 0
	where  ProductoCompraId = @pProductoCompraId and
	FechaCancelacion is null

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update [doc_inv_movimiento]
	set Cancelado = 1,
	FechaCancelacion = GETDATE()
	from [doc_inv_movimiento]
	where  ProductoCompraId = @pProductoCompraId 

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran
	fin:








GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_doc_productos_compra_detalle_ins]
@pProductoCompraDetId	int,
@pProductoCompraId	int,
@pProductoId	int,
@pCantidad	decimal(14,2),
@pPrecioUnitario	money,
@pPorcImpuestos	decimal(5,2),
@pImpuestos	money,
@pPorcDescuentos	decimal(5,2),
@pDescuentos	money,
@pSubtotal	money,
@pTotal	money,
@pCreadoPor	int,
@pPrecioNeto money,
@pPrecioCompra money
AS

	SELECT @pProductoCompraDetId = ISNULL(MAX(ProductoCompraDetId),0)+ 1
	FROM doc_productos_compra_detalle

	insert INTO dbo.doc_productos_compra_detalle
	(
	    ProductoCompraDetId,
	    ProductoCompraId,
	    ProductoId,
	    Cantidad,
	    PrecioUnitario,
	    PorcImpuestos,
	    Impuestos,
	    PorcDescuentos,
	    Descuentos,
	    Subtotal,
	    Total,
	    CreadoEl,
	    CreadoPor,
		PrecioNeto,
		PrecioCompra
	)
	VALUES
	(   @pProductoCompraDetId,
	    @pProductoCompraId,
	    @pProductoId,
	    @pCantidad,
	    @pPrecioUnitario,
	    @pPorcImpuestos,
	    @pImpuestos,
	    @pPorcDescuentos,
	    @pDescuentos,
	    @pSubtotal,
	    @pTotal,
	    GETDATE(),
	    @pCreadoPor,     -- CreadoPor - int
		@pPrecioNeto,
		@pPrecioCompra
	    )





GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[p_doc_productos_compra_ins]
@pProductoCompraId	int out,
@pProveedorId	int,
@pSucursalId int,
@pFechaRegistro	datetime,
@pNumeroRemision	varchar(50),
@pFechaRemision datetime,
@pDescuento	money,
@pSubtotal	money,
@pImpuestos	money,
@pTotal	MONEY,
@pCreadoPor	int,
@pPrecioConImpuestos bit
AS

	SELECT @pProductoCompraId = ISNULL(MAX(ProductoCompraId),0)+1
	FROM doc_productos_compra

	INSERT INTO doc_productos_compra(ProductoCompraId,	ProveedorId,	FechaRegistro,	NumeroRemision,		
	Descuento,		Subtotal,	Impuestos,		Total,	CreadoPor,	CreadoEl,	ModificadoPor,
	ModificadoEl,	Activo,		FechaRemision,	PrecioConImpuestos,	SucursalId)		
	VALUES(
		@pProductoCompraId,		@pProveedorId,		getdate(),		@pNumeroRemision,		
	@pDescuento,		@pSubtotal,		@pImpuestos,		@pTotal,	@pCreadoPor,	GETDATE(),	null,
	null,			1,			@pFechaRemision,@pPrecioConImpuestos,@pSucursalId
	)





GO
/****** Object:  StoredProcedure [dbo].[p_doc_productos_compra_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_doc_productos_compra_upd]
@pProductoCompraId	int out,
@pProveedorId	int,
@pSucursalId int,
@pFechaRegistro	datetime,
@pNumeroRemision	varchar(50),
@pFechaRemision datetime,
@pDescuento	money,
@pSubtotal	money,
@pImpuestos	money,
@pTotal	MONEY,
@pCreadoPor	int
AS

	
	

	UPDATE doc_productos_compra
	SET 	
	ProveedorId = @pProveedorId,		
	NumeroRemision = @pNumeroRemision,		
	Descuento = @pDescuento,		
	Subtotal = @pSubtotal,	
	Impuestos = @pImpuestos,		
	Total = @pTotal,		
	ModificadoPor = @pCreadoPor,
	ModificadoEl = getdate(),		
	FechaRemision = @pFechaRemision,
	SucursalId = @pSucursalId
	WHERE ProductoCompraId = @pProductoCompraId





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_promociones_detalle]
@pPromocionDetalleId	int,
@pPromocionId	int,
@pLineaId	int,
@pFamiliaId	int,
@pSubfamilia	int,
@pProductoId	int
as


	select @pPromocionDetalleId = isnull(max(PromocionDetalleId),0) + 1
	from [doc_promociones_detalle]

	insert into [dbo].[doc_promociones_detalle](
		PromocionDetalleId,		PromocionId,		LineaId,		FamiliaId,	
		Subfamilia,				ProductoId,			CreadoEl
	)
	values(
		@pPromocionDetalleId,		@pPromocionId,		@pLineaId,		@pFamiliaId,	
		@pSubfamilia,				@pProductoId,		getdate()
	)





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_doc_promociones_detalle_del]
@pPromocionId int
as
	
		delete [doc_promociones_detalle]
		where promocionid = @pPromocionId





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_detalle_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_doc_promociones_detalle_grd]
@pPromocionId int
as

	select PromocionDetalleId,
			PromocionId,
			LineaId,
			Linea = isnull(l.Descripcion,'(Todas)'),
			FamiliaId,
			Familia =  isnull(F.Descripcion,'(Todas)'),
			SubfamiliaId = pd.Subfamilia,
			Subfamilia = isnull(sF.Descripcion,'(Todas)'),
			pd.ProductoId,
			Producto =isnull( pro.DescripcionCorta,'(Todas)'),
			CreadoEl
	from doc_promociones_detalle pd
	left join cat_lineas l on l.clave = pd.lineaId
	LEFT join cat_familias f on f.clave = pd.familiaiD
	LEFT JOIN CAT_SUBFAMILIAS sf on sf.clave = pd.Subfamilia
	left join cat_productos pro on pro.productoId = pd.ProductoId
	where promocionId = @pPromocionId





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_del]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_doc_promociones_excepcion_del]
@pPromocionId int
as
	
		delete [doc_promociones_excepcion]
		where promocionid = @pPromocionId




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Proc [dbo].[p_doc_promociones_excepcion_grd]
@pPromocionId int
as

	select PromocionExcepcionId,
			PromocionId,
			LineaId,
			Linea = isnull(l.Descripcion,'(Todas)'),
			FamiliaId,
			Familia =  isnull(F.Descripcion,'(Todas)'),
			SubfamiliaId = pd.Subfamilia,
			Subfamilia = isnull(sF.Descripcion,'(Todas)'),
			pd.ProductoId,
			Producto =isnull( pro.DescripcionCorta,'(Todas)'),
			CreadoEl
	from doc_promociones_excepcion pd
	left join cat_lineas l on l.clave = pd.lineaId
	LEFT join cat_familias f on f.clave = pd.familiaiD
	LEFT JOIN CAT_SUBFAMILIAS sf on sf.clave = pd.Subfamilia
	left join cat_productos pro on pro.productoId = pd.ProductoId
	where promocionId = @pPromocionId




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_excepcion_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_doc_promociones_excepcion_ins]
@pPromocionDetalleId	int,
@pPromocionId	int,
@pLineaId	int,
@pFamiliaId	int,
@pSubfamilia	int,
@pProductoId	int
as


	select @pPromocionDetalleId = isnull(max(PromocionExcepcionId),0) + 1
	from [doc_promociones_excepcion]

	insert into [dbo].[doc_promociones_excepcion](
		PromocionExcepcionId,		PromocionId,		LineaId,		FamiliaId,	
		Subfamilia,				ProductoId,			CreadoEl
	)
	values(
		@pPromocionDetalleId,		@pPromocionId,		@pLineaId,		@pFamiliaId,	
		@pSubfamilia,				@pProductoId,		getdate()
	)




GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_doc_promociones_ins]
@pPromocionId	int out,
@pPorcentajeDescuento	decimal(5,2),
@pFechaInicioVigencia	datetime,
@pFechaFinVigencia	datetime,
@pCreadoPor	int,
@pEmpresaId	int,
@pSucursalId	int,
@pNombrePromocion varchar(100),
@pLunes bit,
@pMartes bit,
@pMiercoles bit,
@pJueves bit,
@pViernes bit,
@pSabado bit,
@pDomingo bit,
@pPermanente bit
as

	select @pPromocionId = isnull(max(PromocionId),0) + 1
	from [doc_promociones]

	insert into [dbo].[doc_promociones](
		PromocionId,			FechaRegistro,		PorcentajeDescuento,		FechaInicioVigencia,
		FechaFinVigencia,		CreadoPor,			EmpresaId,					SucursalId,
		Activo,					NombrePromocion,	Lunes,
		Martes,					Miercoles,			Jueves,
		Viernes,				Sabado,				Domingo,					Permanente
	)
	values(
		@pPromocionId,			getdate(),			@pPorcentajeDescuento,		@pFechaInicioVigencia,
		@pFechaFinVigencia,		@pCreadoPor,		@pEmpresaId,				@pSucursalId,
		1,						@pNombrePromocion,	@pLunes,
		@pMartes,				@pMiercoles,		@pJueves,
		@pViernes,				@pSabado,			@pDomingo,					@pPermanente
	)





GO
/****** Object:  StoredProcedure [dbo].[p_doc_promociones_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[p_doc_promociones_upd]
@pPromocionId	int out,
@pPorcentajeDescuento	decimal(5,2),
@pFechaInicioVigencia	datetime,
@pFechaFinVigencia	datetime,
@pCreadoPor	int,
@pEmpresaId	int,
@pSucursalId	int,
@pNombrePromocion varchar(100),
@pLunes bit,
@pMartes bit,
@pMiercoles bit,
@pJueves bit,
@pViernes bit,
@pSabado bit,
@pDomingo bit,
@pActivo bit,
@pPermanente bit
as

	

	update [dbo].[doc_promociones]
	set 
		PorcentajeDescuento = @pPorcentajeDescuento,
		FechaInicioVigencia = @pFechaInicioVigencia,
		FechaFinVigencia = @pFechaFinVigencia,
		EmpresaId = @pEmpresaId,
		SucursalId = @pSucursalId,
		NombrePromocion = @pNombrePromocion,
		Lunes = @pLunes,
		Martes = @pMartes,
		Miercoles = @pMiercoles,
		Jueves = @pJueves,
		Viernes = @pViernes,
		Sabado = @pSabado,
		Domingo = @pDomingo,
		Activo = @pActivo,
		Permanente = @pPermanente
	where Promocionid = @pPromocionId







GO
/****** Object:  StoredProcedure [dbo].[p_doc_sesiones_punto_venta_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_doc_sesiones_punto_venta_ins]
@pSesionId	int out,
@pUsuarioId	int,
@pCajaId	int,
@pFechaInicio	datetime,
@pFechaUltimaConexion	datetime,
@pCorteAplicado	bit,
@pFechaCorte	datetime,
@pFinalizada	bit,
@pCorteCajaId	int
as

	if(isnull(@pSesionId,0) = 0)
	begin 

		select @pSesionId  =isnull(max(SesionId),0)+1
		from doc_sesiones_punto_venta



		insert into doc_sesiones_punto_venta(
			SesionId,UsuarioId,CajaId,FechaInicio,FechaUltimaConexion,
			CorteAplicado,FechaCorte,Finalizada,CorteCajaId
		)
		values(
			@pSesionId,@pUsuarioId,@pCajaId,getdate(),getdate(),
			@pCorteAplicado,@pFechaCorte,@pFinalizada,@pCorteCajaId
		)
	end
	else
	begin
		update doc_sesiones_punto_venta
		set FechaUltimaConexion = getdate()
		where sesionId = @pSesionId
	end
	



GO
/****** Object:  StoredProcedure [dbo].[p_doc_venta_fp_vale_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_venta_fp_vale_ins]
@pId	int,
@pVentaId	int,
@pTipoValeId	int,
@pMonto	money,
@pDevolucionId	int
as


	select @pId = isnull(max(id),0) + 1
	from doc_ventas_formas_pago_vale

	insert into doc_ventas_formas_pago_vale(
		Id,		VentaId,		TipoValeId,		Monto,		DevolucionId,
		CreadoEl
	)
	values(
		@pId,		@pVentaId,		@pTipoValeId,		@pMonto,		@pDevolucionId,
		getdate())





GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_cancelacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_doc_ventas_cancelacion 4,1,'PRUEBA WEB'
CREATE PROC [dbo].[p_doc_ventas_cancelacion]
@pVentaId INT,
@pUsuarioCancelaId INT,
@pMotivoCancelacion varchar(250)
AS


	if exists (
		select 1
		from doc_apartados
		where ventaId = @pVentaId and
		ventaId > 0
	)
	begin
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR TICKETS DE APARTADOS************');
		return
	end

	if exists (
		select 1
		from doc_corte_caja cc
		inner join  doc_ventas v on v.ventaId between cc.VentaIniId and cc.VentaFINId
		where v.VentaId = @pVentaId 
	)
	begin 
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR EL TICKET, YA EST� DENTRO DE UN CORTE************');
		return
	end

	if exists (
		select 1
		from  doc_ventas v 
		inner join doc_devoluciones dev on dev.VentaId = v.ventaid
		where v.VentaId = @pVentaId 
	)
	begin 
		RAISERROR (15600,-1,-1, '*************NO ES POSIBLE CANCELAR EL TICKET, TIENE UNA DEVOLUCI�N************');
		return
	end


	begin tran

	UPDATE dbo.doc_ventas
	SET Activo = 0,
		FechaCancelacion = GETDATE(),
		UsuarioCancelacionId = @pUsuarioCancelaId,
		MotivoCancelacion = @pMotivoCancelacion
	WHERE VentaId = @pVentaId

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update doc_inv_movimiento 
	set FechaCancelacion = GETDATE(),
		Cancelado = 1
	from doc_inv_movimiento m
	inner join doc_ventas v on v.VentaId = m.VentaId
	where isnull(m.Cancelado,0) = 0 and
	v.VentaId = @pVentaId

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update doc_web_carrito
	set Pagado = 0,
		FechaPago = null
	where VentaId = @pVentaId

	
	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	commit tran
	fin:












GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_rec]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [dbo].[p_doc_ventas_rec]
@pSucursalId int,
@pError varchar(250)=''
as

		declare @aplica_rec bit,
			@porc_rec decimal(5,2),
			@fechaInicioRec datetime,
			@ventaIni int,@ventaFin int,
			@totalMaxRec money,
			@folio_new varchar(5),
			@serie_new varchar(5)


	

	create table #tmpVentasRec
	(
		VentaId int,
		Total money
	)

	select @aplica_rec = TieneRec,
		@porc_rec = PorcRec
	from cat_configuracion 
	

	if(
		isnull(@aplica_rec,0) = 1 and
		isnull(@porc_rec,0) > 0
	)
	begin

		
		BEGIN TRY	

			BEGIN TRANSACTION


			--Sincornizar info con temp
			exec p_doc_ventas_rec_sinc @pSucursalId,@pError out

			select @fechaInicioRec = isnull(max(FechaCorte),'19000101')
			from doc_corte_caja cc
			inner join  cat_cajas c on c.Clave = cc.CajaId
			where c.Sucursal = @pSucursalId

			select v.VentaId,v.TotalVenta, rec = cast(0 as bit),v.Activo,v.FechaCancelacion
			into #tmpVentasTot
			from doc_ventas v
			where SucursalId = @pSucursalId and
			v.FechaCreacion >= @fechaInicioRec and
			isnull(v.Rec,0) = 0

			

			select @totalMaxRec = sum(TotalVenta) * (@porc_rec / 100)
			from #tmpVentasTot
			where activo = 1 and
			fechacancelacion is null


			select @ventaFin = max(VentaId)
			from #tmpVentasTot

			while @ventaFin is not null
			begin
				declare @total_i money,
					@totalVenta_i money

					
			
				if exists(
					select 1
					from doc_ventas v
					inner join doc_ventas_formas_pago vfp on vfp.VentaId = v.VentaId and
																vfp.FormaPagoId = 1 --EFECTIVO
					left join doc_ventas_formas_pago vfp2 on vfp2.VentaId = v.VentaId and
																vfp2.FormaPagoId <> 1
					where v.VentaId = @ventaFin and
					v.Activo = 1 and
					v.FechaCancelacion is null and
					isnull(v.Impuestos,0) > 0 and
					vfp2.VentaId is null
				)
				begin
					
					
					select @total_i = isnull(sum(tmp.Total),0) 
					from #tmpVentasRec tmp
				

					select @totalVenta_i = isnull(TotalVenta,0)
					from #tmpVentasTot tmp2 
					where tmp2.VentaId = @ventaFin

					if((@total_i + @totalVenta_i) < @totalMaxRec)
					begin

						insert into #tmpVentasRec
						select @ventaFin,@totalVenta_i
					end
				
				end


				select @ventaFin = max(VentaId)
				from #tmpVentasTot
				where VentaId < @ventaFin

				

			end

			
			--Desligar las ventas a recortar del inventario
			update doc_inv_movimiento
			set VentaId = null
			from doc_inv_movimiento m
			inner join #tmpVentasRec tmp on tmp.VentaId = m.VentaId

			--MArcar las ventas como rec
			update doc_ventas
			set rec=1
			where isnull(rec,0)= 0

			--BORRAR PEDIDOS
			delete doc_pedidos_orden_adicional
			from doc_pedidos_orden_adicional pa
			inner join doc_pedidos_orden_detalle pd on pd.PedidoDetalleId = pa.PedidoDetalleId
			inner join doc_pedidos_orden p on p.PedidoId = pd.PedidoId
			inner join #tmpVentasRec b on b.VentaId = p.VentaId

			delete doc_pedidos_orden_ingre
			from doc_pedidos_orden_ingre pi 
			inner join doc_pedidos_orden_detalle pd on pd.PedidoDetalleId = pi.PedidoDetalleId
			inner join doc_pedidos_orden p on p.PedidoId = pd.PedidoId
			inner join #tmpVentasRec b on b.VentaId = p.VentaId

			delete doc_pedidos_orden_mesa
			from doc_pedidos_orden_mesa pom 
			inner join doc_pedidos_orden p on p.PedidoId = pom.PedidoOrdenId
			inner join #tmpVentasRec b on b.VentaId = p.VentaId

			delete doc_pedidos_orden_mesero
			from doc_pedidos_orden_mesero pom 
			inner join doc_pedidos_orden p on p.PedidoId = pom.PedidoOrdenId
			inner join #tmpVentasRec b on b.VentaId = p.VentaId


			delete doc_pedidos_orden_detalle
			from doc_pedidos_orden_detalle a
			inner join doc_pedidos_orden p on p.PedidoId = a.PedidoId
			inner join #tmpVentasRec b on b.VentaId = p.VentaId

			delete doc_pedidos_orden
			from doc_pedidos_orden po
			inner join #tmpVentasRec b on b.VentaId = po.VentaId

			--BORRAR DOC_VEN
			delete [doc_ventas_temp]
			from [doc_ventas_temp] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			

			delete [doc_ventas_formas_pago_vale]
			from [doc_ventas_formas_pago_vale] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			
			

			delete [doc_ventas_formas_pago]
			from [doc_ventas_formas_pago]  a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			
			
			
			delete [doc_ventas_detalle]
			from [doc_ventas_detalle] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			delete [doc_ventas]
			from [doc_ventas] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			
			select
				@folio_new = isnull(max(Folio),0)
			from doc_ventas v
			where ventaId < (
				select min(VentaId)
				from #tmpVentasTot
			)

					

			select tmp1.VentaId,
			Folio = ROW_NUMBER() OVER(ORDER BY tmp1.VentaId ASC) + cast(@folio_new as int)
			into #tmpVentasFolios
			from #tmpVentasTot tmp1
			inner join doc_ventas v on v.VentaId = tmp1.VentaId
			

			
			update doc_ventas
			set Folio = f.Folio
			from doc_ventas v
			inner join #tmpVentasTot tmp1 on tmp1.VentaId = v.VentaId
			inner join #tmpVentasFolios f on f.VentaId = v.VentaId

		
		--select sum(TotalVenta) from #tmpVentasTot
		--	select @totalMaxRec
		--	SELECT * FROM DOC_VENTAS
		--	SELECT * FROM ERPTemp..DOC_VENTAS
			

			COMMIT TRAN

		END TRY  
		BEGIN CATCH  
			set @pError = ERROR_MESSAGE()
		
			 ROLLBACK TRAN
			
		END CATCH;  

	end
GO
/****** Object:  StoredProcedure [dbo].[p_doc_ventas_rec_sinc]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [dbo].[p_doc_ventas_rec_sinc]
@pSucursalId int,
@pError varchar(250)='' out
as

--	ERPJalisco.dbo.doc_apartados: FK_apartados_ventas
--ERPJalisco.dbo.doc_corte_caja: FK_doc_corte_caja_doc_ventas
--ERPJalisco.dbo.doc_corte_caja: FK_doc_corte_caja_doc_ventas1
--ERPJalisco.dbo.doc_devoluciones: FK_doc_devoluciones_doc_ventas1
--ERPJalisco.dbo.doc_devoluciones_detalle: FK_doc_devoluciones_cat_productos
--ERPJalisco.dbo.doc_devoluciones_detalle: FK_doc_devoluciones_doc_ventas
--ERPJalisco.dbo.doc_inv_movimiento: FK__doc_inv_m__Venta__7226EDCC
--ERPJalisco.dbo.doc_inv_movimiento: FK__doc_inv_m__Venta__731B1205
--ERPJalisco.dbo.doc_pedidos_orden: FK_Pedidos_Ventas
--ERPJalisco.dbo.doc_reimpresion_ticket: FK_doc_reimpresion_ticket_doc_ventas
--ERPJalisco.dbo.doc_ventas_detalle: FK_doc_ventas_detalle_doc_ventas
--ERPJalisco.dbo.doc_ventas_formas_pago: FK_doc_ventas_formas_pago_doc_ventas
--ERPJalisco.dbo.doc_web_carrito: FK_Carrito_Ventas

	declare @aplica_rec bit,
		@devolucionId int,
		@devolucionDetalleId int,
		@pedidoOrdenId int,
		@pedidoOrdenDetalleId int,
		@pventaId int,
		@ventaDetalleId int,
		@ventaFPValeId int

	select @aplica_rec = TieneRec
	from cat_configuracion 


	
	--BEGIN TRAN
	BEGIN TRY  
		
		if(@aplica_rec = 1)
		begin



			--Sincornizar productos
			insert into ERPTemp..cat_productos(
				ProductoId,		Clave,		Descripcion,	DescripcionCorta,		FechaAlta,		ClaveMarca,
				ClaveFamilia,	ClaveSubFamilia,ClaveLinea,	ClaveUnidadMedida,		ClaveInventariadoPor,ClaveVendidaPor,
				Estatus,		ProductoTerminado,Inventariable,MateriaPrima,		ProdParaVenta,	ProdVtaBascula,
				Seriado,		NumeroDecimales,PorcDescuentoEmpleado,ContenidoCaja,Empresa,		Sucursal,
				Foto,			ClaveAlmacen,ClaveAnden,	ClaveLote,				FechaCaducidad,	MinimoInventario,
				MaximoInventario,PorcUtilidad,Talla,		ParaSexo,				Color,			Color2,
				SobrePedido,	Especificaciones,			Liquidacion
			)
			select ProductoId,		Clave,		Descripcion,	DescripcionCorta,		FechaAlta,		ClaveMarca,
				ClaveFamilia,	ClaveSubFamilia,ClaveLinea,	ClaveUnidadMedida,		ClaveInventariadoPor,ClaveVendidaPor,
				Estatus,		ProductoTerminado,Inventariable,MateriaPrima,		ProdParaVenta,	ProdVtaBascula,
				Seriado,		NumeroDecimales,PorcDescuentoEmpleado,ContenidoCaja,Empresa,		Sucursal,
				Foto,			ClaveAlmacen,ClaveAnden,	ClaveLote,				FechaCaducidad,	MinimoInventario,
				MaximoInventario,PorcUtilidad,Talla,		ParaSexo,				Color,			Color2,
				SobrePedido,	Especificaciones,			Liquidacion
			from cat_productos a
			where not exists(
				select 1
				from ERPTemp..cat_productos b
				where b.ProductoId = a.ProductoId
			)
			

			select @pventaId = isnull(max(VentaId ),0)
			from ERPTemp..doc_ventas

			/***Crear relaci�n antes de sincronizar****/
			INSERT INTO doc_ventas_temp(
				VentaId,VentaTempId,CreadoEl
			)
			select v.VentaId, ROW_NUMBER() OVER(ORDER BY v.VentaId ASC) + @pventaId,GETDATE()
			from doc_ventas v
			where isnull(v.Rec,0) = 0
			order by v.VentaId asc

			

			--VENTAS
			insert into ERPTemp..doc_ventas(
				VentaId,		Folio,			Fecha,			ClienteId,		DescuentoVentaSiNo,			PorcDescuentoVenta,
				MontoDescuentoVenta,DescuentoEnPartidas,TotalDescuento,			Impuestos,					SubTotal,
				TotalVenta,TotalRecibido,		Cambio,			Activo,			UsuarioCreacionId,			FechaCreacion,
				UsuarioCancelacionId,FechaCancelacion,SucursalId,CajaId,		Serie,						MotivoCancelacion,
				Rec
			)
			select ROW_NUMBER() OVER(ORDER BY VentaId ASC) + @pventaId,Folio,			Fecha,			ClienteId,		DescuentoVentaSiNo,			PorcDescuentoVenta,
				MontoDescuentoVenta,DescuentoEnPartidas,TotalDescuento,			Impuestos,					SubTotal,
				TotalVenta,TotalRecibido,		Cambio,			Activo,			UsuarioCreacionId,			FechaCreacion,
				UsuarioCancelacionId,FechaCancelacion,SucursalId,CajaId,		Serie,						MotivoCancelacion,
				Rec
			from doc_ventas v
			where isnull(v.Rec,0) = 0

			--VENTAS DETALLE
			select @ventaDetalleId= isnull(max(VentaDetalleId ),0)
			from ERPTemp..doc_ventas_detalle

			insert into ERPTemp..doc_ventas_detalle(
				VentaDetalleId,		VentaId,		ProductoId,		Cantidad,		PrecioUnitario,
				PorcDescuneto,		Descuento,		Impuestos,		Total,			UsuarioCreacionId,
				FechaCreacion,		TasaIVA
			)
			select ROW_NUMBER() OVER(ORDER BY VentaDetalleId ASC)  + @ventaDetalleId,vtemp.VentaTempId,ProductoId,		Cantidad,		PrecioUnitario,
				PorcDescuneto,		Descuento,		Impuestos,		Total,			UsuarioCreacionId,
				FechaCreacion,		TasaIVA
			from doc_ventas_detalle vd 
			inner join doc_ventas_temp vtemp on vtemp.ventaId = vd.VentaId


			--VENTAS FORMAS DE PAGO
			INSERT INTO ERPTemp..[doc_ventas_formas_pago](
				FormaPagoId,VentaId,Cantidad,FechaCreacion,UsuarioCreacionId,digitoVerificador
			)
			SELECT FormaPagoId,vtemp.VentaTempId,Cantidad,FechaCreacion,UsuarioCreacionId,digitoVerificador
			FROM [doc_ventas_formas_pago] FP
			inner join doc_ventas_temp vtemp on vtemp.ventaId = FP.VentaId

			--VENTAS FORMAS PAGO VALE

			select @ventaFPValeId = isnull(max(Id),0)
			from ERPTemp..[doc_ventas_formas_pago_vale]

			INSERT INTO ERPTemp..[doc_ventas_formas_pago_vale](
				Id,VentaId,TipoValeId,Monto,DevolucionId,CreadoEl
			)
			select ROW_NUMBER() OVER(ORDER BY Id ASC) + @ventaFPValeId,VentaTempId,TipoValeId,Monto,DevolucionId,A.CreadoEl
			from [doc_ventas_formas_pago_vale] a
			inner join doc_ventas_temp vtemp on vtemp.ventaId = a.VentaId


			--DEVOLUCIONES
			select @devolucionId = isnull(max(devolucionId),0)
			from ERPTemp..doc_devoluciones


			insert into ERPTemp..doc_devoluciones(
				DevolucionId,	VentaId,			Total,	CreadoEl,
				CreadoPor,		TipoDevolucionId,	FechaVencimiento
			)
			select DevolucionId + @devolucionId,	dev.VentaId,			Total,	CreadoEl,
				CreadoPor,		TipoDevolucionId,	FechaVencimiento
			from doc_devoluciones dev
			inner join doc_ventas  v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by DevolucionId

			--Sincornizar Devoluciones Detalle
			select @devolucionDetalleId = isnull(max(DevolucionDetId),0)
			from ERPTemp..doc_devoluciones_Detalle


			insert into ERPTemp..doc_devoluciones_Detalle(DevolucionDetId,DevolucionId,VentaId,ProductoId,Cantidad,
			Total,CreadoEl,CreadoPor)
			select ROW_NUMBER() OVER(ORDER BY DevolucionDetId ASC) + @devolucionDetalleId,dev.DevolucionId + @devolucionId,dev.VentaId,
			dd.ProductoId,dd.Cantidad,dd.Total,GETDATE(),dd.CreadoPor
			from doc_devoluciones dev
			inner join doc_ventas  v on v.VentaId = dev.VentaId
			inner join doc_devoluciones_detalle dd on dd.DevolucionId = dev.DevolucionId
			where isnull(v.Rec,0) = 0
			order by DevolucionDetId asc

			--SINCRONIZAR 
			select @pedidoOrdenId = isnull(max(PedidoId),0)
			from ERPTemp..doc_pedidos_orden

			insert into  ERPTemp..doc_pedidos_orden(
				PedidoId,SucursalId,ComandaId,PorcDescuento,Subtotal,Descuento,Impuestos,Total,
				ClienteId,MotivoCancelacion,Activo,CreadoEl,CreadoPor,Personas,FechaApertura,FechaCierre,
				VentaId,Cancelada,FechaCancelacion,CanceladoPor
			)
			select dev.PedidoId + @pedidoOrdenId,dev.SucursalId,dev.ComandaId,dev.PorcDescuento,dev.Subtotal,dev.Descuento,
			dev.Impuestos,dev.Total,dev.ClienteId,dev.MotivoCancelacion,dev.Activo,dev.CreadoEl,
			dev.CreadoPor,dev.Personas,dev.FechaApertura,dev.FechaCierre,dev.VentaId,dev.Cancelada,
			dev.FechaCancelacion,dev.CanceladoPor
			from doc_pedidos_orden dev
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc

			select @pedidoOrdenDetalleId = isnull(max(PedidoDetalleId),0)
			from ERPTemp..doc_pedidos_orden_detalle


			insert into  ERPTemp..doc_pedidos_orden_detalle(
				PedidoDetalleId,PedidoId,ProductoId,Cantidad,PrecioUnitario,
				PorcDescuento,Descuento,Impuestos,Notas,Total,
				CreadoPor,CreadoEl,TasaIVA,Impreso,ComandaId,
				Parallevar,Cancelado
			)
			select ROW_NUMBER() OVER(ORDER BY PedidoDetalleId ASC) + @pedidoOrdenDetalleId,dev.PedidoId + @pedidoOrdenId,pod.ProductoId,pod.Cantidad,
				pod.PrecioUnitario,	pod.PorcDescuento,pod.Descuento,pod.Impuestos,pod.Notas,pod.Total,
				pod.CreadoPor,pod.CreadoEl,pod.TasaIVA,pod.Impreso,pod.ComandaId,
				Parallevar,Cancelado
			from doc_pedidos_orden dev
			inner join doc_ventas v on v.VentaId = dev.VentaId
			inner join doc_pedidos_orden_detalle pod on pod.PedidoId = dev.PedidoId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc

			insert into ERPTemp..[doc_pedidos_orden_mesa](
				PedidoOrdenId,MesaId,CreadoEl
			)
			select pm.PedidoOrdenId +  @pedidoOrdenId,pm.MesaId,pm.CreadoEl
			from [doc_pedidos_orden_mesa] pm
			inner join doc_pedidos_orden dev on dev.PedidoId = pm.PedidoOrdenId
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc


			insert into ERPTemp..[doc_pedidos_orden_mesero](
				PedidoOrdenId,EmpleadoId,CreadoEl
			)
			select pom.PedidoOrdenId + @pedidoOrdenId,pom.EmpleadoId,pom.CreadoEl
			from [doc_pedidos_orden_mesero] pom 
			inner join doc_pedidos_orden dev on dev.PedidoId = pom.PedidoOrdenId
			inner join doc_ventas v on v.VentaId = dev.VentaId
			where isnull(v.Rec,0) = 0
			order by dev.PedidoId asc


			

		end

		--ROLLBACK TRAN
	END TRY  
	BEGIN CATCH  
		--ROLLBACK TRAN
		set @pError = 'Ocurri� un error al sincronizar tablas'
	END CATCH;  
GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_doc_web_carrito_detalle_ins]
@pId int,
@pIdDetalle	int out,
@puUID	varchar(50),
@pProductoId	int,
@pCantidad	decimal(10,2),
@pDescripcion	varchar(250),
@pPrecioUnitario	money,
@pImporte	money
as

	begin Tran

	declare @impuestos money=0,
			@porcImpuestos decimal(5,2)=0,
			@precioUnitario money,
			@subtotal money=0


	select @porcImpuestos = isnull(sum(isnull(Porcentaje,0)),0)
	from cat_productos_impuestos p
	inner join cat_impuestos i on i.Clave = p.ImpuestoId
	where ProductoId = @pProductoId

	select @pPrecioUnitario = pp.Precio
	from cat_productos p
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId
	where p.ProductoId = @pProductoId and
	pp.IdPrecio = 1--venta

	set @pImporte = @pPrecioUnitario * @pCantidad


	if(@porcImpuestos > 0)
	begin
		set @impuestos = @pImporte / (1+(@porcImpuestos/100))
	end

	set @subtotal = @pImporte-@impuestos



	

	select @pIdDetalle = isnull(max(IdDetalle),0) + 1
	from doc_web_carrito_detalle

	insert into [dbo].[doc_web_carrito_detalle](
		IdDetalle,		uUID,			ProductoId,		Cantidad,
		Descripcion,	PrecioUnitario,	Importe,		CreadoEl,
		Impuestos,		Subtotal,Id
	)
	values(
		@pIdDetalle,	@puUID,			@pProductoId,	@pCantidad,
		@pDescripcion,	@pPrecioUnitario,@pImporte,		getdate(),
		@Impuestos,		@Subtotal,@pId
	)

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--Actualizar totales
	update doc_web_carrito
	set Total = (select sum(importe) from [doc_web_carrito_detalle] where uUID = @puUID),
		SubTotal = (select sum(Subtotal) from [doc_web_carrito_detalle] where uUID = @puUID),
		Impuestos = (select sum(Impuestos) from [doc_web_carrito_detalle] where uUID = @puUID)
	where uUID = @puUID


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	commit tran

	fin:

GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_doc_web_carrito_ins]
@puUID	varchar(50),
@pid	int out,
@pEmail	varchar(50),
@pTotal	money,
@pEnvioCalle	varchar(250),
@pEnvioColonia	varchar(100),
@pEnvioCiudad	varchar(70),
@pEnvioEstadoId	int,
@pEnvioCP	varchar(5),
@pEnvioPersonaRecibe	varchar(250),
@pEnvioTelefonoContacto	varchar(20),
@pClienteId int out,
@pFechaEstimadaEntrega DateTime

as

	
	
	select @pid = case when isnull(max(id),0)  <= 100 then 1000 
					else isnull(max(id),0)  +1
					end
	from doc_web_carrito

	

	begin tran

	insert into [dbo].[doc_web_carrito](
		Id,
		uUID,						Email,		Total,			CreadoEl,
		EnvioCalle,	EnvioColonia,	EnvioCiudad,EnvioEstadoId,	EnvioCP,
		EnvioPersonaRecibe,EnvioTelefonoContacto,
		FechaEstimadaEntrega
	)
	values(
		@pid,
		@puUID,						@pEmail,		@pTotal,			getdate(),
		@pEnvioCalle,		@pEnvioColonia,			@pEnvioCiudad,		@pEnvioEstadoId,	@pEnvioCP,
		@pEnvioPersonaRecibe,@pEnvioTelefonoContacto,
		@pFechaEstimadaEntrega
	)

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	/****Generar un cliente*****/

	select @pClienteId = isnull(ClienteId,0)
	from cat_clientes_web
	where lower(rtrim(email)) = lower(rtrim(@pEmail))

	if @pClienteId = 0
	Begin
		/****Generar un id de cliente*******/

		select @pClienteId = isnull(max(ClienteId),0)+ 1
		from cat_clientes

		insert into cat_clientes(ClienteId,Nombre,Activo,Telefono )	
		values(@pClienteId,@pEmail,1,@pEnvioTelefonoContacto)

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end

		insert into cat_clientes_web(ClienteId,Email,Password,CreadoEl)
		values(@pClienteId,@pEmail,'1234',getdate())

		if @@error <> 0
		begin
			rollback tran
			goto fin
		end

	End

	if @pClienteId > 0
	begin

		declare @ClienteDireccionId int

		select @ClienteDireccionId = isnull(ClienteDireccionId,0)
		from cat_clientes_direcciones 
		where ClienteId = @pClienteId and
		CodigoPostal = @pEnvioCP

		if(isnull(@ClienteDireccionId,0) = 0)
		begin
			select @ClienteDireccionId = isnull(max(ClienteDireccionId),0) +1

			from cat_clientes_direcciones
			--Generar Direcci�n
			insert into cat_clientes_direcciones(
				ClienteDireccionId,	ClienteId,	TipoDireccionId,	Calle,
				NumeroInterior,	NumeroExterior,	Colonia,			Ciudad,
				EstadoId,		PaisId,			CodigoPostal,		CreadoEl
			)
			select @ClienteDireccionId,@pClienteId,1,				@pEnvioCalle,
			'',					'',				@pEnvioColonia,		@pEnvioCiudad,
			@pEnvioEstadoId,	1,				@pEnvioCP,			getdate()
		end
		Else
		Begin

			update cat_clientes_direcciones
			set Calle = @pEnvioCalle,
				Colonia = @pEnvioColonia,
				Ciudad = @pEnvioCiudad,
				EstadoId = @pEnvioEstadoId,
				CodigoPostal = @pEnvioCP
			where ClienteDireccionId = @ClienteDireccionId
		End	


		
		if @@error <> 0
		begin
				rollback tran
				goto fin
		end
	end

	
	update [doc_web_carrito]
	set clienteId = @pClienteId
	where uUID = @puUID

	if @@error <> 0
	begin
			rollback tran
			goto fin
	end
	

	

	commit tran


	fin:


GO
/****** Object:  StoredProcedure [dbo].[p_doc_web_carrito_pagar]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_doc_web_carrito_pagar]
@pSucursalId int,
@pId int,
@pTransactionRef varchar(30),
@pMontoPagado varchar(20),
@pFormaPagoId tinyint
as

	declare @FechaEstimadaEntrega datetime
	declare @diasPedido tinyint=0
	declare @diasAdicPedido tinyint=0

	select @FechaEstimadaEntrega = GETDATE();

	select @diasAdicPedido = DiasEntregaAdicSPedido,
			@diasPedido = DiasEntregaPedido
	from cat_web_configuracion
	where SucursalId = @pSucursalId

	set @FechaEstimadaEntrega = DATEADD(day,@diasPedido,@FechaEstimadaEntrega)

	if exists (
		select 1
		from doc_web_carrito_detalle d
		inner join cat_productos prod on prod.ProductoId = d.ProductoId
		inner join cat_productos_existencias pe on pe.ProductoId = prod.ProductoId and
											pe.SucursalId = @pSucursalId and
											pe.ExistenciaTeorica <= 0 
		where d.Id = @pId 
	)
	begin
		set @FechaEstimadaEntrega = DATEADD(day,@diasAdicPedido,@FechaEstimadaEntrega)
	end

	update doc_web_carrito
	set Pagado = 1,
		FechaPago = GETDATE(),
		TransactionRef = @pTransactionRef,
		MontoPaypal = @pMontoPagado,
		FechaEstimadaEntrega = @FechaEstimadaEntrega,
		FormaPagoId = @pFormaPagoId
	where id = @pId
GO
/****** Object:  StoredProcedure [dbo].[p_dov_ventas_rec]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_dov_ventas_rec]
@pSucursalId int,
@pError varchar(250)=''
as

		declare @aplica_rec bit,
			@porc_rec decimal(5,2),
			@fechaInicioRec datetime,
			@ventaIni int,@ventaFin int,
			@totalMaxRec money,
			@folio_new varchar(5),
			@serie_new varchar(5)


	

	create table #tmpVentasRec
	(
		VentaId int,
		Total money
	)

	select @aplica_rec = TieneRec,
		@porc_rec = PorcRec
	from cat_configuracion 
	

	if(
		isnull(@aplica_rec,0) = 1 and
		isnull(@porc_rec,0) > 0
	)
	begin

		BEGIN TRY

			

			BEGIN TRANSACTION


			--Sincornizar info con temp
			exec p_doc_ventas_rec_sinc @pSucursalId,@pError out

			select @fechaInicioRec = max(FechaCorte)
			from doc_corte_caja cc
			inner join  cat_cajas c on c.Clave = cc.CajaId
			where c.Sucursal = @pSucursalId

			select v.VentaId,v.TotalVenta, rec = cast(0 as bit),v.Activo,v.FechaCancelacion
			into #tmpVentasTot
			from doc_ventas v
			where SucursalId = @pSucursalId and
			v.FechaCreacion >= @fechaInicioRec and
			isnull(v.Rec,0) = 0

			select @totalMaxRec = sum(TotalVenta) * (@porc_rec / 100)
			from #tmpVentasRec
			where activo = 1 and
			fechacancelacion is null


			select @ventaFin = max(VentaId)
			from #tmpVentasTot

			while @ventaFin is not null
			begin
				declare @total_i money,
					@totalVenta_i money
			
				if exists(
					select 1
					from doc_ventas v
					inner join doc_ventas_formas_pago vfp on vfp.VentaId = v.VentaId and
																vfp.FormaPagoId = 1 --EFECTIVO
					left join doc_ventas_formas_pago vfp2 on vfp2.VentaId = v.VentaId and
																vfp2.FormaPagoId <> 1
					where v.VentaId = @ventaFin and
					v.Activo = 1 and
					v.FechaCancelacion is null and
					isnull(v.Impuestos,0) > 0 and
					vfp2.VentaId is null
				)
				begin

					select @total_i = isnull(sum(tmp.Total),0) 
					from #tmpVentasRec tmp
				

					select @totalVenta_i = isnull(TotalVenta,0)
					from #tmpVentasTot tmp2 
					where tmp2.VentaId = @ventaFin

					if((@total_i + @totalVenta_i) < @totalMaxRec)
					begin

						insert into #tmpVentasRec
						select @ventaFin,@totalVenta_i
					end
				
				end


				select @ventaFin = max(VentaId)
				from #tmpVentasTot
				where VentaId < @ventaFin

			end

			--Desligar las ventas a recortar del inventario
			update doc_inv_movimiento
			set VentaId = null
			from doc_inv_movimiento m
			inner join #tmpVentasRec tmp on tmp.VentaId = m.VentaId

			--MArcar las ventas como rec
			update doc_ventas
			set rec=1
			where isnull(rec,0)= 0

			--BORRAR DOC_VEN
			delete [doc_ventas_temp]
			from [doc_ventas_temp] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin

			delete [doc_ventas_formas_pago_vale]
			from [doc_ventas_formas_pago_vale] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin

			delete [doc_ventas_formas_pago]
			from [doc_ventas_formas_pago]  a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId
			where a.VentaId = @ventaFin
			
			delete [doc_ventas_detalle]
			from [doc_ventas_detalle] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			delete [doc_ventas]
			from [doc_ventas] a
			inner join #tmpVentasRec b on b.VentaId = a.VentaId

			select @serie_new = Serie,
				@folio_new = Folio
			from doc_ventas
			where ventaId = (
				select min(VentaId)
				from #tmpVentasTot
			)

			select tmp1.VentaId,
			Folio = ROW_NUMBER() OVER(PARTITION BY tmp1.VentaId ORDER BY name ASC) + cast(@folio_new as int)
			into #tmpVentasFolios
			from #tmpVentasTot tmp1
			inner join doc_ventas v on v.VentaId = tmp1.VentaId

			update doc_ventas
			set Folio = f.Folio
			from doc_ventas v
			inner join #tmpVentasTot tmp1 on tmp1.VentaId = v.VentaId
			inner join #tmpVentasFolios f on f.VentaId = v.VentaId




			COMMIT

		END TRY  
		BEGIN CATCH  
			 ROLLBACK
			set @pError = 'Ocurrió un error al realizar rec tablas'
		END CATCH;  

	end
GO
/****** Object:  StoredProcedure [dbo].[p_GetDateTimeServer]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_GetDateTimeServer]
as
	select FechaServidor=getdate()





GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVenta]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_InsertarVenta]
@pVentaId	BIGINT out,
@pFolio	varchar(20),
@pFecha	datetime,
@pClienteId	int,
@pDescuentoVentaSiNo	bit,
@pPorcDescuentoVenta	decimal(5,2),
@pMontoDescuentoVenta	money,
@pDescuentoEnPartidas	money,
@pTotalDescuento	money,
@pImpuestos	money,
@pSubTotal	money,
@pTotalVenta	money,
@pTotalRecibido MONEY,
@pCambio MONEY,
@pActivo	bit,
@pUsuarioCreacionId	int,
@pFechaCreacion	datetime,
@pUsuarioCancelacionId	int,
@pFechaCancelacion	datetime,
@pSucursalId int,
@pCajaId int,
@pPedidoId int
AS


	declare @serie varchar(5) = ''

	select @serie = isnull(Serie,'')
	from [dbo].[cat_configuracion_ticket_venta]
	where sucursalId = @pSucursalId


	SELECT @pVentaId = ISNULL(MAX(VentaId),0) + 1
	FROM [doc_ventas]

	select @pFolio = isnull(max(CAST(Folio AS int)),0) + 1
	from doc_ventas 
	where Serie = @serie

	

		

		INSERT INTO [dbo].[doc_ventas](
			VentaId,
			Folio,
			Fecha,
			ClienteId,
			DescuentoVentaSiNo,
			PorcDescuentoVenta,
			MontoDescuentoVenta,
			DescuentoEnPartidas,
			TotalDescuento,
			Impuestos,
			SubTotal,
			TotalVenta,
			TotalRecibido,
			Cambio,
			Activo,
			UsuarioCreacionId,
			FechaCreacion,
			UsuarioCancelacionId,
			FechaCancelacion,
			SucursalId,
			CajaId,
			Serie
		)
		VALUES( @pVentaId,
			@pFolio,
			getdate(),
			@pClienteId,
			@pDescuentoVentaSiNo,
			@pPorcDescuentoVenta,
			@pMontoDescuentoVenta,
			@pDescuentoEnPartidas,
			@pTotalDescuento,
			@pImpuestos,
			@pSubTotal,
			@pTotalVenta,
			@pTotalRecibido,
			@pCambio,
			@pActivo,
			@pUsuarioCreacionId,
			getdate(),
			@pUsuarioCancelacionId,
			@pFechaCancelacion,
			@pSucursalId,
			@pCajaId,
			@serie
			)



			update doc_pedidos_orden
			set VentaId = @pVentaId,
				Activo = 0
			where PedidoId = @pPedidoId




GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVentaDetalle]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_InsertarVentaDetalle]
@pVentaDetalleId bigint,
@pVentaId bigint,
@pProductoId int,
@pCantidad money,
@pPrecioUnitario money,
@pPorcDescuneto decimal(5,2),
@pDescuento money,
@pImpuestos money,
@pTotal money,
@pUsuarioCreacionId int,
@pFechaCreacion datetime
AS

	declare @tasaIVA decimal(5,2),
			@subtotal money

	select @tasaIVA = sum(i.Porcentaje)
	from [dbo].[cat_productos_impuestos] p
	inner join cat_impuestos i on i.Clave = p.ImpuestoId
	where p.ProductoId = @pProductoId and
	i.Clave = 1

	if(isnull(@tasaIVA,0) > 0)
	begin 

		set @subtotal = @pTotal / (1+(@tasaIVA/100))
		set @pImpuestos = case when @pTotal <> @subtotal then  @pTotal - @subtotal else 0 end
		
	end



	SELECT @pVentaDetalleId = ISNULL(MAX(VentaDetalleId),0) + 1
	FROM doc_ventas_detalle

	begin tran

	INSERT INTO dbo.doc_ventas_detalle
	(
	    VentaDetalleId,
	    VentaId,
	    ProductoId,
	    Cantidad,
	    PrecioUnitario,
	    PorcDescuneto,
	    Descuento,
	    Impuestos,
	    Total,
	    UsuarioCreacionId,
	    FechaCreacion,
		TasaIVA
	)
	VALUES
	(	@pVentaDetalleId	,        -- VentaDetalleId - bigint
	    @pVentaId,        -- VentaId - bigint
	    @pProductoId,        -- ProductoId - int
	    @pCantidad,     -- Cantidad - decimal(14, 3)
	    @pPrecioUnitario,     -- PrecioUnitario - money
	    @pPorcDescuneto,     -- PorcDescuneto - decimal(5, 2)
	    @pDescuento,     -- Descuento - money
	    @pImpuestos,     -- Impuestos - money
	    @pTotal,     -- Total - money
	    @pUsuarioCreacionId,        -- UsuarioCreacionId - int
	    GETDATE(), -- FechaCreacion - datetime
		@tasaIVA
	    )


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_ventas_detalle
	set Descuento = (PrecioUnitario * Cantidad) - Total
	where VentaDetalleId = @pVentaDetalleId

	
	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_ventas
	set TotalDescuento =(select sum(Descuento) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_ventas
	set Impuestos =(select sum(s1.Impuestos) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_ventas
	set TotalVenta =(select sum(Total) from doc_ventas_detalle s1 where s1.VentaId = @pVentaId )
	where ventaId = @pVentaId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update doc_ventas
	set SubTotal =TotalVenta - isnull(Impuestos,0)
	where ventaId = @pVentaId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end



	commit tran
	fin:







GO
/****** Object:  StoredProcedure [dbo].[p_InsertarVentaFormaPago]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[p_InsertarVentaFormaPago]
@pFormaPagoId int,
@pVentaId bigint,
@pCantidad money,		
@pUsuarioCreacionId INT,
@pDigitoVerificador VARCHAR(20)
AS

	declare @cambio money

	select @cambio = isnull(cambio,0)
	from doc_ventas
	where  ventaid = @pVentaId

	if(@pformapagoid = 1)
		set @pCantidad = @pCantidad - @cambio

	INSERT INTO [dbo].[doc_ventas_formas_pago](
		FormaPagoId,
		VentaId,
		Cantidad,
		FechaCreacion,
		UsuarioCreacionId,
		digitoVerificador
	)
	VALUES(
	@pFormaPagoId,
		@pVentaId,
		@pCantidad,
		GETDATE(),
		@pUsuarioCreacionId,
		@pDigitoVerificador
	)







GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicia_cancel_inv]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_inv_carga_inicia_cancel_inv]
@pCargaInventarioId int
as


	begin tran

	update [dbo].[doc_inv_movimiento]
	set --Activo = 1,
		FechaCancelacion = getdate(),
		Cancelado = 1
	from [doc_inv_movimiento] mov
	inner join [doc_inv_movimiento_detalle] movD on movD.MovimientoId = mov.MovimientoId
	inner join [doc_inv_carga_inicial] ci on ci.ProductoId = movD.ProductoId and
											ci.SucursalId = mov.SucursalId 
	where ci.CargaInventarioId = @pCargaInventarioId and
	mov.TipoMovimientoId = 1 --CARGA INICIAL

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[doc_inv_carga_inicial]
	where CargaInventarioId = @pCargaInventarioId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
											







GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_cancel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_inv_carga_inicial_cancel]
@pCargaInventarioId int
as

	delete [dbo].[doc_inv_carga_inicial]
	where CargaInventarioId = @pCargaInventarioId





GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_inv_carga_inicial_grd 1,1,2,0
CREATE Proc [dbo].[p_inv_carga_inicial_grd]
@pSucursaldId int,
@pFamiliaId int,
@pSubFamiliaId int,
@pVerListadoGeneral bit
as

	select 
		ci.CargaInventarioId,
		p.Clave,
		p.ProductoId,
		p.Descripcion,
		CostoPromedio = isnull(ci.CostoPromedio,0),
		UltimoCosto = isnull(ci.UltimoCosto,0),
		InventarioFisico = isnull(ci.Cantidad,0),
		TieneCargaInicial = cast(case when max(md.ProductoId) > 0 then 1 else 0 end as bit) 
	from [dbo].cat_productos p
	left join doc_inv_carga_inicial ci on ci.ProductoId = p.ProductoId and @pSucursaldId = ci.SucursalId
	left join doc_inv_movimiento m on m.SucursalId = @pSucursaldId and
							m.TipoMovimientoId = 1 and
							m.Autorizado = 1 and
							m.Activo = 1 --Carga Inicial
	left join doc_inv_movimiento_detalle md on md.MovimientoId  = m.MovimientoId and
									md.ProductoId = ci.ProductoId
										
	where  (
		@pFamiliaId in( p.ClaveFamilia , 0)
		and @pSubFamiliaId in (p.ClaveSubFamilia ,0)
	)
	OR
	@pVerListadoGeneral = 1
	GROUP BY ci.CargaInventarioId,
		p.Clave,
		p.ProductoId,
		p.Descripcion,
		ci.CostoPromedio,
		ci.UltimoCosto,
		ci.Cantidad
	
	

	





GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_inv_carga_inicial_ins]
@pCargaInventarioId	int out,
@pSucursalId	int,
@pProductoId	int,
@pCantidad	decimal,
@pCostoPromedio	money,
@pUltimoCosto	money,
@pCreadoPor	int
as

	select @pCargaInventarioId = isnull(max(CargaInventarioId),0) + 1
	from doc_inv_carga_inicial

	insert into doc_inv_carga_inicial(
		CargaInventarioId,SucursalId,ProductoId,Cantidad,CostoPromedio,
		UltimoCosto	,CreadoEl,CreadoPor
	)
	values(
		@pCargaInventarioId,@pSucursalId,@pProductoId,@pCantidad,@pCostoPromedio,
		@pUltimoCosto	,getdate(),@pCreadoPor
	)





GO
/****** Object:  StoredProcedure [dbo].[p_inv_carga_inicial_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[p_inv_carga_inicial_upd]
@pCargaInventarioId	int ,
@pSucursalId	int,
@pProductoId	int,
@pCantidad	decimal,
@pCostoPromedio	money,
@pUltimoCosto	money,
@pCreadoPor	int
as

	update doc_inv_carga_inicial
	set Cantidad = @pCantidad,
		CostoPromedio = @pCostoPromedio,
		UltimoCosto = @pUltimoCosto
	where CargaInventarioId = @pCargaInventarioId

	





GO
/****** Object:  StoredProcedure [dbo].[p_inv_genera_mov_cancel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_inv_genera_mov_cancel]
@pMovimientoId int
as

	declare @movimientoCancelId int,
			@sucursalId int,
			@consecutivo int,
			@tipoMovId int,
			@tipoMovCancel int,
			@movimientoDetalleId int,
			@consecutivoCancel int

	if not exists (
		select 1
		from doc_inv_movimiento 
		where MovimientoRefId =@pMovimientoId 
	)
	and exists (
		select 1
		from doc_inv_movimiento
		where MovimientoId = @pMovimientoId and
		FechaCancelacion is not null
	)
	begin
		

	select @movimientoCancelId= isnull(max(MovimientoId),0) + 1
	from doc_inv_movimiento

	select @sucursalId = SucursalId,
		@tipoMovId = TipoMovimientoId
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId

	
	select @consecutivo = isnull(max(Consecutivo),0) + 1
	from doc_inv_movimiento
	where SucursalId = @sucursalId and
	TipoMovimientoId = @tipoMovId

	select @tipoMovCancel = TipoMovimientoCancelacionId
	from cat_tipos_movimiento_inventario
	where TipoMovimientoInventarioId = @tipoMovId

	select @consecutivoCancel = Consecutivo
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId

	begin tran
	
	
	insert into doc_inv_movimiento(
		MovimientoId,	SucursalId,		FolioMovimiento,		TipoMovimientoId,
		FechaMovimiento,HoraMovimiento,	Comentarios,			ImporteTotal,
		Activo,			CreadoPor,		CreadoEl,				Autorizado,
		FechaAutoriza,	SucursalDestinoId,AutorizadoPor,		FechaCancelacion,
		ProductoCompraId,Consecutivo,	SucursalOrigenId,		VentaId,
		MovimientoRefId
	)
	select @movimientoCancelId,SucursalId,@consecutivo,		@tipoMovCancel,
	GETDATE(),			GETDATE(),		'Cancela Folio:'+cast(@consecutivoCancel as varchar),ImporteTotal,
	1,					CreadoPor,		GETDATE(),				1,	
	GETDATE(),			SucursalDestinoId,AutorizadoPor,		FechaCancelacion,
	ProductoCompraId,	@consecutivo,	SucursalOrigenId,		VentaId,
	@pMovimientoId
	from doc_inv_movimiento
	where MovimientoId = @pMovimientoId
	AND FechaCancelacion IS NOT NULL

	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	select @movimientoDetalleId =isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,
		PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl,
		CostoUltimaCompra,CostoPromedio,ValCostoUltimaCompra,ValCostoPromedio
	)
	select @movimientoDetalleId + ROW_NUMBER() OVER( ORDER BY MovimientoDetalleId ASC) ,
	@movimientoCancelId,ProductoId,Consecutivo,Cantidad,
	PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl,
	null,null,null,null
	from doc_inv_movimiento_detalle
	where MovimientoId = @pMovimientoId


	if @@ERROR <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:

	End

	





GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_autoriza]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[p_inv_movimiento_autoriza]
@pMovimientoId int,
@pAutorizadoPor int
as

	update [dbo].[doc_inv_movimiento]
	set Autorizado = 1,
		AutorizadoPor = @pAutorizadoPor,
		FechaAutoriza = getdate()
	where  MovimientoId = @pMovimientoId

	if exists(
		select 1
		from doc_inv_movimiento m
		where m.MovimientoId = @pMovimientoId and
		m.TipoMovimientoId = 7 --Entrada drecta
	)
	begin
		 exec p_Actualizar_CompraListaPrecios 0,@pMovimientoId,@pAutorizadoPor,''
	end







GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_inv_movimiento_detalle_ins]
@pMovimientoDetalleId	int out,
@pMovimientoId	int,
@pProductoId	int,
@pConsecutivo	smallint,
@pCantidad	decimal(14,3),
@pPrecioUnitario	money,
@pImporte	money,
@pDisponible	decimal(14,3),
@pCreadoPor	int,
@pCostoUltimaCompra money,
@pCostoPromedio money
as

	declare @ValCostoUltimaCompra money,
		   @ValCostoPromedio money

select @pMovimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
from [doc_inv_movimiento_detalle]

select @pConsecutivo = isnull(max(Consecutivo),0)
from [doc_inv_movimiento_detalle]
where MovimientoId = @pMovimientoId

set @pImporte = @pCantidad * @pPrecioUnitario
set @ValCostoUltimaCompra = @pCantidad *@pCostoUltimaCompra
set @ValCostoPromedio = @pCantidad * @pCostoPromedio

INSERT INTO [dbo].[doc_inv_movimiento_detalle]
           ([MovimientoDetalleId]
           ,[MovimientoId]
           ,[ProductoId]
           ,[Consecutivo]
           ,[Cantidad]
           ,[PrecioUnitario]
           ,[Importe]
           ,[Disponible]
           ,[CreadoPor]
           ,[CreadoEl]
		   ,CostoUltimaCompra
			,CostoPromedio
			,ValCostoUltimaCompra
			,ValCostoPromedio)
     VALUES
           (@pMovimientoDetalleId,
           @pMovimientoId,
           @pProductoId, 
           @pConsecutivo, 
           @pCantidad, 
           @pPrecioUnitario, 
           @pImporte, 
           @pDisponible, 
           @pCreadoPor, 
           getdate() 
		   ,null
		   ,null
		   ,null
		   ,null)







GO
/****** Object:  StoredProcedure [dbo].[p_inv_movimiento_rpt]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_inv_movimiento_rpt 1
CREATE Proc [dbo].[p_inv_movimiento_rpt]
@pMovimientoId int
as

	declare @proveedor varchar(200)
	if @pMovimientoId = 2
	begin
		
		select @proveedor = prov.Nombre
		from doc_productos_compra pc
		inner join doc_inv_movimiento m on m.ProductoCompraId = pc.ProductoCompraId
		inner join cat_proveedores prov on  prov.ProveedorId = PC.ProveedorId
		where m.MovimientoId = @pMovimientoId 
	end

	select SucursalOrigen = suc.NombreSucursal,
		SucursalDestino = sucDes.NombreSucursal,
		TipoMovimiento = TM.Descripcion,
		Folio = m.FolioMovimiento,
		FechaMovimiento = m.FechaMovimiento,
		FechaAfectaInv = m.FechaAutoriza,
		ProductoClave = PROD.Clave,
		Producto = cast(prod.Descripcion as varchar(26)),
		CantidadMov = md.Cantidad,
		RegistradoPor = usu.NombreUsuario,
		AutorizadoPor = usu2.NombreUsuario	,
		Proveedor = 	@proveedor
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	inner join cat_productos prod on prod.ProductoId = md.ProductoId
	inner join cat_sucursales suc on suc.Clave = m.SucursalId
	inner join cat_tipos_movimiento_inventario tm on tm.TipoMovimientoInventarioId = m.TipoMovimientoId
	inner join cat_usuarios usu on usu.IdUsuario = m.CreadoPor
	inner join cat_usuarios usu2 on usu2.IdUsuario = M.AutorizadoPor
	left join cat_sucursales sucDes on sucDes.Clave = m.SucursalDestinoId
	where m.MovimientoId = @pMovimientoId






GO
/****** Object:  StoredProcedure [dbo].[p_inv_producto_kardex_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_inv_producto_kardex_grd 1,1
CREATE Proc [dbo].[p_inv_producto_kardex_grd]
@pSucursalId int,
@pProductoId int
as	

	select FechaMov = m.FechaMovimiento,
		SucursalMov=suc.NombreSucursal,
		SucursalOrigen = sucO.NombreSucursal,
		SucursalDestino = sucD.NombreSucursal,
		FolioMov = m.FolioMovimiento,
		Movimiento = tipoMov.Descripcion,
		prod.clave,
		prod.DescripcionCorta,
		CantidadEntrada = case when tipoMov.EsEntrada = 1 then md.Cantidad else 0 end,
		CantidadSalida = case when tipoMov.EsEntrada = 0 then md.Cantidad else 0 end,
		Existencia = md.Disponible,
		CostoUltimaCompra,
		CostoPromedio,
		ValCostoUltimaCompra,
		ValCostoPromedio,
		m.Comentarios,
		ValorMovimiento	 = case when m.TipoMovimientoId in (2,7) then ValorMovimiento else null end	
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId and
											md.ProductoId=@pProductoId
	inner join cat_tipos_movimiento_inventario tipoMov on tipoMov.TipoMovimientoInventarioId = m.TipoMovimientoId
	inner join cat_sucursales suc on suc.Clave = m.SucursalId
	inner join cat_productos prod on prod.ProductoId = md.ProductoId
	left join cat_sucursales sucO on sucO.Clave = m.SucursalOrigenId
	left join cat_sucursales sucD on sucD.Clave = m.SucursalDestinoId
	where m.SucursalId = @pSucursalId and
	m.Activo = 1 and
	m.Autorizado = 1
	order by m.FechaMovimiento ASC








GO
/****** Object:  StoredProcedure [dbo].[p_producto_imagen_principal_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_producto_imagen_principal_upd]
@pProductoImagenId int
as

	declare @pProductoId int

	select @pProductoId = ProductoId
	from cat_productos_imagenes
	where ProductoImageId = @pProductoImagenId

	update cat_productos_imagenes
	set Principal = 0
	where ProductoId = @pProductoId

	update cat_productos_imagenes
	set Principal = 1
	where ProductoImageId = @pProductoImagenId



GO
/****** Object:  StoredProcedure [dbo].[p_producto_promocion_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_producto_promocion_sel 1,1
CREATE proc [dbo].[p_producto_promocion_sel]
@pSucursalId int,
@pProductoId int
as

	declare @diaSemena int

	select @diaSemena =datepart(weekday, getdate())	

	select PD.PromocionId,
		ProductoId = @pProductoId,
		p.PorcentajeDescuento
	into #tmpExcepciones
	from doc_promociones p
	inner join cat_productos pro on pro.ProductoId = @pProductoId and
									(
										(p.FechaInicioVigencia <= GETDATE() and
										p.FechaFinVigencia >= GETDATE())
										or
										P.Permanente = 1
									)
	inner join doc_promociones_excepcion pd on pd.PromocionId = p.PromocionId 	
	where p.SucursalId = @pSucursalId and
	p.Activo = 1 and
	(
		(p.Lunes = 1 and @diaSemena = 2) OR
		(p.Martes = 1 and @diaSemena = 3) OR
		(p.Miercoles = 1 and @diaSemena = 4) OR
		(p.Jueves = 1 and @diaSemena = 5) OR
		(p.Viernes = 1 and @diaSemena = 6) OR
		(p.Sabado = 1 and @diaSemena = 7) OR
		(p.Domingo = 1 and @diaSemena = 1) 
	) 
	AND (
		PD.ProductoId = PRO.ProductoId
		or(
			PD.ProductoId IS NULL and
			PD.LineaId = PRO.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia = PRO.ClaveSubFamilia
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId  is null AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId is null AND
			PD.FamiliaId is null AND
			PD.Subfamilia is null
		)
	)
	
	


	select PD.PromocionId,
		ProductoId = @pProductoId,
		p.PorcentajeDescuento		
	from doc_promociones p
	inner join cat_productos pro on pro.ProductoId = @pProductoId and
									(
										(p.FechaInicioVigencia <= GETDATE() and
										p.FechaFinVigencia >= GETDATE())
										or
										P.Permanente = 1
									)
	inner join doc_promociones_detalle pd on pd.PromocionId = p.PromocionId 
	--left join doc_promociones_excepcion pe on pe.ProductoId = p.PromocionId									
	where p.SucursalId = @pSucursalId and
	p.Activo = 1 and
	(
		(p.Lunes = 1 and @diaSemena = 2) OR
		(p.Martes = 1 and @diaSemena = 3) OR
		(p.Miercoles = 1 and @diaSemena = 4) OR
		(p.Jueves = 1 and @diaSemena = 5) OR
		(p.Viernes = 1 and @diaSemena = 6) OR
		(p.Sabado = 1 and @diaSemena = 7) OR
		(p.Domingo = 1 and @diaSemena = 1) 
	) 
	AND (
		PD.ProductoId = PRO.ProductoId
		or(
			PD.ProductoId IS NULL and
			PD.LineaId = PRO.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia = PRO.ClaveSubFamilia
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId = PRO.ClaveFamilia AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId =pro.ClaveLinea AND
			PD.FamiliaId  is null AND
			PD.Subfamilia IS NULL
		)
		or(
			PD.ProductoId IS NULL and
			PD.LineaId is null AND
			PD.FamiliaId is null AND
			PD.Subfamilia is null
		)
	)
	AND NOT EXISTS(
		SELECT 1
		FROM #tmpExcepciones st1
		where st1.PromocionId = PD.PromocionId
	)
	
	





GO
/****** Object:  StoredProcedure [dbo].[p_producto_ultima_compra]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_producto_ultima_compra 13
CREATE Proc [dbo].[p_producto_ultima_compra]
@pProductoId int
as

	declare @ProductoCompraDetId int,
		@precioUnitario money,
		@impuestos money,
		@porcImpuestos money,
		@movimientoId int

	--select top 1  @ProductoCompraDetId = ProductoCompraDetId
	--from doc_productos_compra_detalle pcd
	--inner join doc_productos_compra pc on pc.ProductoCompraId = pcd.ProductoCompraId
	--where pcd.ProductoId = @pProductoId and
	--pc.activo = 1
	--order by FechaRegistro desc

	--select @porcImpuestos = isnull(sum(i.Porcentaje),0)
	--from cat_productos_impuestos pi
	--inner join cat_impuestos i on i.Clave = pi.ImpuestoId
	--where ProductoId = @pProductoId


	--select PrecioUnitario = isnull(PrecioUnitario,0),
	--	Impuestos = isnull(
	--						PrecioUnitario -
	--						(
	--						PrecioUnitario / 
	--						(1+ (@porcImpuestos / 100))
	--						)
	--					,0),
	--	PrecioNeto = PrecioUnitario - isnull(
	--						PrecioUnitario -
	--						(
	--						PrecioUnitario / 
	--						(1+ (@porcImpuestos / 100))
	--						)
	--					,0)
	--from doc_productos_compra_detalle
	--where ProductoCompraDetId = @ProductoCompraDetId


	select top 1 @movimientoId = md.MovimientoDetalleId
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where md.ProductoId = @pProductoId and
	m.Activo = 1 and
	m.Autorizado = 1
	order by md.CreadoEl desc

	select @porcImpuestos = isnull(sum(i.Porcentaje),0)
	from cat_productos_impuestos pi
	inner join cat_impuestos i on i.Clave = pi.ImpuestoId
	where ProductoId = @pProductoId


	select PrecioUnitario = isnull(PrecioUnitario,0),
		Impuestos = isnull(
							PrecioUnitario -
							(
							PrecioUnitario / 
							(1+ (@porcImpuestos / 100))
							)
						,0),
		PrecioNeto = PrecioUnitario - isnull(
							PrecioUnitario -
							(
							PrecioUnitario / 
							(1+ (@porcImpuestos / 100))
							)
						,0)
	from doc_inv_movimiento_detalle
	where MovimientoDetalleId = @movimientoId
	








GO
/****** Object:  StoredProcedure [dbo].[p_productos_agrupados_upd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_productos_agrupados_upd]
@pProductoId int
as
	
	select pd2.ProductoId
	into #tmpProdutosRelacionados
	from cat_productos_agrupados_detalle pd
	INNER JOIN cat_productos_agrupados pa on pa.ProductoAgrupadoId = pd.ProductoAgrupadoId
	inner join cat_productos_agrupados_detalle pd2 on pd2.ProductoAgrupadoId = PA.ProductoAgrupadoId AND
											pd2.ProductoId <> @pProductoId
	where pd.ProductoId = @pProductoId

	select *
	into #tmpProducto
	from cat_productos 
	where ProductoId = @pProductoId

	select *
	into #tmpProductosPrecios
	from cat_productos_precios
	where IdProducto=@pProductoId
	

	--Generales
	--Revisar si es un producto agrupado
	update cat_productos
	set Descripcion = t2.Descripcion,
		DescripcionCorta=t2.DescripcionCorta,		
		ClaveMarca = t2.ClaveMarca,
		ClaveFamilia= t2.Clavefamilia,
		ClaveSubFamilia=t2.ClaveSubfamilia,
		ClaveLinea=t2.ClaveLinea,
		ClaveUnidadMedida=t2.ClaveUnidadMedida,
		ProductoTerminado=t2.ProductoTerminado,
		Inventariable=t2.Inventariable,
		MateriaPrima=t2.MateriaPrima,
		ProdParaVenta=t2.ProdParaVenta,
		ProdVtaBascula=t2.ProdVtaBascula,
		Seriado= t2.Seriado,
		NumeroDecimales= t2.NumeroDecimales,
		PorcDescuentoEmpleado=t2.PorcDescuentoEmpleado,
		ContenidoCaja=t2.ContenidoCaja,
		Empresa=t2.Empresa,
		Sucursal=t2.Sucursal,		
		ClaveAlmacen = t2.ClaveAlmacen,
		ClaveAnden=t2.ClaveAnden,
		ClaveLote=t2.ClaveLote,
		FechaCaducidad=t2.FechaCaducidad,
		MinimoInventario= t2.MinimoINventario,
		MaximoInventario= t2.MaximoInventario,
		PorcUtilidad=t2.PorcUtilidad,
		--Talla=t2.Talla,
		ParaSexo= t2.ParaSexo,
		Color=t2.Color,
		Color2=t2.Color2,
		SobrePedido= t2.SobrePedido,
		Especificaciones=t2.Especificaciones
	from cat_productos t1
	inner join #tmpProdutosRelacionados pr on pr.ProductoId = t1.ProductoId
	inner join #tmpProducto t2 on t2.ProductoId = @pProductoId

	--Precios
	UPDATE cat_productos_precios
	set 		
		PorcDescuento=tmp.PorcDescuento,
		MontoDescuento=tmp.MontoDescuento,
		Precio=tmp.Precio
	from cat_productos_precios pp
	inner join #tmpProdutosRelacionados pr on pr.ProductoId = pp.IdProducto 
	inner join #tmpProductosPrecios tmp on tmp.IdProducto = @pProductoId AND
										tmp.IdPrecio = pp.IdPrecio 
											
	
GO
/****** Object:  StoredProcedure [dbo].[p_productos_clonar]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_clonar]
@pProductoId int,
@pProductoNuevoId int out
as

	declare @pIdProductoPrecio int,
		@pProductoImageId int

	select @pProductoNuevoId=isnull(max(ProductoId),0)+1
	from cat_productos

	begin tran

	insert into cat_productos(
		ProductoId,		Clave,		Descripcion,		DescripcionCorta,
		FechaAlta,		ClaveMarca,	ClaveFamilia,		ClaveSubFamilia,
		ClaveLinea,		ClaveUnidadMedida,ClaveInventariadoPor,ClaveVendidaPor,
		Estatus,		ProductoTerminado,Inventariable,MateriaPrima,
		ProdParaVenta,	ProdVtaBascula,Seriado,NumeroDecimales,
		PorcDescuentoEmpleado,	ContenidoCaja,	Empresa,	Sucursal,
		Foto,			ClaveAlmacen,	ClaveAnden,		ClaveLote,
		FechaCaducidad,	MinimoInventario,MaximoInventario,PorcUtilidad,
		Talla,			ParaSexo,	Color,				Color2,
		SobrePedido,		Especificaciones
	)
	select @pProductoNuevoId,@pProductoNuevoId,		Descripcion,		DescripcionCorta,
		FechaAlta,		ClaveMarca,	ClaveFamilia,		ClaveSubFamilia,
		ClaveLinea,		ClaveUnidadMedida,ClaveInventariadoPor,ClaveVendidaPor,
		Estatus,		ProductoTerminado,Inventariable,MateriaPrima,
		ProdParaVenta,	ProdVtaBascula,Seriado,NumeroDecimales,
		PorcDescuentoEmpleado,	ContenidoCaja,	Empresa,	Sucursal,
		Foto,			ClaveAlmacen,	ClaveAnden,		ClaveLote,
		FechaCaducidad,	MinimoInventario,MaximoInventario,PorcUtilidad,
		Talla,			ParaSexo,	Color,				Color2,
		SobrePedido,		Especificaciones
	from cat_productos
	where ProductoId = @pProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end
	
	--Insertar Precios
	select @pIdProductoPrecio = isnull(max(IdProductoPrecio),0) 
	from cat_productos_precios

	insert into cat_productos_precios(
		IdProductoPrecio,IdProducto,IdPrecio,PorcDescuento,
		MontoDescuento,Precio
	)
	select ROW_NUMBER() OVER(ORDER BY IdPrecio ASC) + @pIdProductoPrecio,@pProductoNuevoId,IdPrecio,PorcDescuento,
	MontoDescuento,Precio
	from cat_productos_precios
	where IdProducto = @pProductoId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--EXISTENCIAS
	insert into cat_productos_existencias(
			ProductoId,		SucursalId,		ExistenciaTeorica,		CostoUltimaCompra,
			CostoPromedio,	ValCostoUltimaCompra,ValCostoPromedio,	ModificadoEl,
			CreadoEl
		)
		select @pProductoNuevoId,clave,isnull(0,0),0,
		0,0,0,getdate(),
		getdate()
		from cat_sucursales
		where estatus =1 

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	--IMAGENES
	--select @pProductoImageId =isnull(max(ProductoImageId),0)
	--from cat_productos_imagenes
	


	--insert into cat_productos_imagenes(
	--	ProductoImageId,	ProductoId,		FileName,		CreadoEl,
	--	FileByte,			Principal,		Miniatura
	--)
	--select ROW_NUMBER() OVER(ORDER BY ProductoImageId ASC) + @pProductoImageId,				@pProductoNuevoId,	FileName,	GETDATE(),
	--FileByte,				Principal,		Miniatura
	--from cat_productos_imagenes
	--where ProductoId = @pProductoId


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	commit tran

	fin:
GO
/****** Object:  StoredProcedure [dbo].[p_productos_compra_inv]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Proc [dbo].[p_productos_compra_inv]
@pProductoCompraId int,
@pSucursalId int,
@pCreadoPor int
as


	declare @pMovimientoId int,
			@pMovimientoDetId int,
			@consecutivo int,
			@sucursalId int

	select @pMovimientoId = isnull(max(MovimientoId),0) + 1
	from [doc_inv_movimiento]

	select @sucursalId = @pSucursalId
	--from [doc_inv_movimiento]
	--where ProductoCompraId = @pProductoCompraId

	select @consecutivo = @pProductoCompraId-- isnull(max(Consecutivo ),0) + 1
	--from [doc_inv_movimiento]
	--where SucursalId = @sucursalId and
	--TipoMovimientoId = 2

	select @pMovimientoDetId = isnull(max(MovimientoDetalleId),0) + 1
	from [doc_inv_movimiento_detalle]

	begin tran

	insert into [dbo].[doc_inv_movimiento](
		MovimientoId,SucursalId,FolioMovimiento,TipoMovimientoId,FechaMovimiento,
		HoraMovimiento,Comentarios,ImporteTotal,Activo,CreadoPor,CreadoEl,
		Autorizado,FechaAutoriza,AutorizadoPor,ProductoCompraId,Consecutivo
	)
	select @pMovimientoId,SucursalId,@consecutivo,2,getdate(),
	cast(getdate() as time),'',Total,1,@pCreadoPor,getdate(),
	1,getdate(),@pCreadoPor,@pProductoCompraId,@consecutivo
	from [dbo].[doc_productos_compra]
	where ProductoCompraId = @pProductoCompraId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	insert into [dbo].[doc_inv_movimiento_detalle](
		MovimientoDetalleId,MovimientoId,ProductoId,Consecutivo,Cantidad,
		PrecioUnitario,Importe,Disponible,CreadoPor,CreadoEl
	)
	select @pMovimientoDetId + ROW_NUMBER() OVER(ORDER BY ProductoId ASC),@pMovimientoId,ProductoId,ROW_NUMBER() OVER(ORDER BY ProductoId ASC),Cantidad,
	PrecioUnitario,Total,Cantidad,@pCreadoPor,GETDATE()
	from [dbo].[doc_productos_compra_detalle]
	where ProductoCompraId = @pProductoCompraId

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:



	

	








GO
/****** Object:  StoredProcedure [dbo].[p_productos_existencia_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_productos_existencia_sel 1,0,0,0,0,1
CREATE Proc [dbo].[p_productos_existencia_sel]
@pSucursal int,
@pLineaId int,
@pFamiliaId int,
@pSubfamiliaId int,
@pProductoId int,
@pSoloConExistencias bit
as
	/**********Obtener existencias de todas las sucursales************/
	select PE.SucursalId,
	PE.ProductoId,
	P.ClaveLinea,
	ClaveFamilia=isnull(P.ClaveFamilia,0),
	ClaveSubFamilia=isnull(P.ClaveSubFamilia,0),
	PE.ExistenciaTeorica,
	Apartado = isnull(PE.Apartado,0),
	Disponible = isnull(PE.Disponible,0)
	INTO #tmpExistencias
	from cat_productos_existencias PE
	INNER JOIN cat_productos p on p.ProductoId = pe.ProductoId
	where @pLineaId in (0,isnull(p.ClaveLinea,0)) and
	@pFamiliaId in (0,isnull(p.ClaveFamilia,0)) and
	@pSubfamiliaId in (0,isnull(p.ClaveSubFamilia,0)) and
	@pProductoId in (0,isnull(p.ProductoId,0))

	select tmp.SucursalId,
		  tmp.ClaveLinea,
		  Linea = l.Descripcion,
		  tmp.ClaveFamilia,
		  Familia = f.Descripcion,
		  tmp.ClaveSubFamilia,
		  SubFamilia = sf.Descripcion,
		  tmp.ProductoId,
		  ClaveProducto = p.clave,
		  Producto = p.Descripcion,
		  ExistenciaSucursal = tmp.ExistenciaTeorica,
		  ExistenciaTotal = (select sum(s1.ExistenciaTeorica)  from #tmpExistencias s1 where s1.ProductoId = p.ProductoId),
		  p.Clave,
		  tmp.ExistenciaTeorica,
		  p.Descripcion,
		  SUC.NombreSucursal,
		  tmp.Apartado,
		  tmp.Disponible
	from #tmpExistencias tmp
	INNER JOIN cat_productos P ON P.ProductoId = tmp.ProductoId and p.Inventariable = 1
	inner join cat_sucursales suc on suc.Clave = tmp.SucursalId
	left JOIN cat_familias f on f.Clave = p.ClaveFamilia
	left join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	left join cat_lineas l on l.Clave = p.ClaveLinea
	where tmp.SucursalId = @pSucursal and
	(
		(
			tmp.ExistenciaTeorica <> 0
			and @pSoloConExistencias = 1
		)
		OR
		(
			@pSoloConExistencias = 0
		)
	)
	














GO
/****** Object:  StoredProcedure [dbo].[p_productos_imagenes_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_imagenes_sel]
@pProductoId int
as
	select ProductoImageId,
			ProductoId,
			FileName,
			Principal
	from cat_productos_imagenes
	where ProductoId = @pProductoId
GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_importacion 1,1,'BLING','JUEGO SENCILOO','ECO2J1-66','JUEGO BLING PLATEADO ROSA','JUEGO BLING PLATEADO ROSA',132,12,0
CREATE Proc [dbo].[p_productos_importacion]
@pEmpresa int,
@pSucursalId int,
@pLinea varchar(100),
@pFamilia varchar(100),
@pClaveProducto varchar(50),
@pDescripcionCorta varchar(30),
@pDescripcionLarga varchar(60),
@pPrecio money,
@pExistencias decimal(6,2),
@pInsertado bit out,
@pIVA int,
@pUnidad varchar(100),
@pMarca varchar(100),
@pSubfamilia varchar(100),
@pTalla varchar(5),
@pParaSexo varchar(1),
@pColor varchar(10),
@pColor2 varchar(10),
@pSobrePedido bit,
@pCreadoPor int,
@uuid uniqueidentifier,
@pMateriaPrima bit,
@pProdParaVenta bit
as
BEGIN

	declare @familiaId int,
			@lineaId int,
			@subfamiliaId int,
			@productoId int,
			@marcaId int,
			@unidadId int,
			 @movimiento int,
			@folio int,
			@movimientoDetalle int



	SET @pInsertado = 0

	select @lineaId = Clave
	from cat_lineas f
	where rtrim(f.Descripcion) = rtrim(@pLinea)

	select @familiaId = Clave
	from cat_familias f
	where rtrim(f.Descripcion) = rtrim(@pFamilia)

	select @subfamiliaid = Clave
	from cat_subfamilias f
	where rtrim(f.Descripcion) = rtrim(@pSubFamilia)

	SELECT @productoId = ProductoId
	from cat_productos
	where RTRIM(Clave) = RTRIM(@pClaveProducto)

	SELECT @marcaId = Clave
	from cat_marcas
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pMarca))

	SELECT @unidadId = Clave
	from cat_unidadesmed
	where upper(RTRIM(Descripcion)) = upper(RTRIM(@pUnidad))

	--BEGIN TRAN

	

	if(
		isnull(@lineaId,0) = 0
	)
	begin 
		select @lineaId = isnull(max(Clave),0) +1
		from cat_lineas

		insert into cat_lineas(Empresa,Sucursal,Clave,Descripcion,Estatus)
		select @pEmpresa,@pSucursalId, @lineaId,@pLinea,1
	end

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	GOTO FIN
	--END

	if(
		isnull(@familiaId,0) = 0
	)
	begin 
		select @familiaId = isnull(max(Clave),0) +1
		from cat_familias

		insert into cat_familias(Empresa,Sucursal,Clave,Descripcion,Estatus)
		select @pEmpresa,@pSucursalId,@familiaId,@pFamilia,1
	end

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	GOTO FIN
	--END

	if(
		isnull(@subfamiliaId,0) = 0
	)
	begin 
		select @subfamiliaId = isnull(max(Clave),0) +1
		from cat_subfamilias

		insert into cat_subfamilias(Clave,Descripcion,Familia,Estatus,
		Empresa,Sucursal)
		select @subfamiliaId,@pSubfamilia,@familiaiD,1,
		@pEmpresa,@pSucursalId
	end

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	GOTO FIN
	--END


	if(
		isnull(@marcaId,0) = 0
	)
	begin 
		select @marcaId = isnull(max(Clave),0) +1
		from cat_marcas

		insert into cat_marcas(Clave,Descripcion,Estatus,Empresa,Sucursal)
		select @marcaId,@pMarca,1,1,1
	end

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	GOTO FIN
	--END

	if(
		isnull(@unidadId,0) = 0
	)
	begin 
		select @unidadId = isnull(max(Clave),0) +1
		from cat_unidadesmed

		insert into cat_unidadesmed(
			Clave,		Descripcion,	DescripcionCorta,Decimales,
			Estatus,	Empresa,		Sucursal,		IdCodigoSAT
		)
		select @unidadId,@pUnidad,@pUnidad,0,
		1,@pEmpresa,1,null
	end

	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	GOTO FIN
	--END

	--Si el producto no existe
	if(ISNULL(@productoId,0) = 0 and isnull(@pClaveProducto,'') != '')
	begin

		SELECT @productoId = isnull(max(ProductoId),0)+1
		FROM cat_productos

		insert into cat_productos(
		Empresa,			Sucursal,
			ProductoId,		ClaveLinea,		ClaveFamilia,		Descripcion,
			DescripcionCorta,Estatus,		Clave,				NumeroDecimales,
			PorcDescuentoEmpleado,ContenidoCaja,ProductoTerminado,Inventariable,
			MateriaPrima,	ProdParaVenta,	ProdVtaBascula,		Seriado,
			FechaAlta	,	ClaveMarca,		ClaveSubfamilia,
			--
			Talla,			ParaSexo,		Color,				Color2,
			SobrePedido,	ClaveUnidadMedida,ClaveInventariadoPor
			)
		select 
			@pEmpresa,@pSucursalId,
			@productoId,@lineaId,@familiaId,@pDescripcionLarga,
			@pDescripcionCorta,1,@pClaveProducto,				0,
			0,				0,				1,					1,
			@pMateriaPrima,	@pProdParaVenta,				0,					0,
			GETDATE(),		@marcaId,		@subfamiliaId,
			@pTalla,		@pParaSexo,		@pColor,			@pColor2,
			@pSobrePedido,	@unidadId,		@unidadId
			
		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END

		declare @IdProductoPrecio int

		select @IdProductoPrecio = isnull(max(IdProductoPrecio),0) + 1
		from cat_productos_precios

		--
		insert into cat_productos_precios(
			IdProductoPrecio,IdProducto,IdPrecio,
			PorcDescuento,MontoDescuento,Precio)
		select @IdProductoPrecio + IdPrecio,@productoId,
		IdPrecio,0,0, case when IdPrecio = 1 then @pPrecio else 0 end
		from cat_precios

		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END

		insert into cat_productos_existencias(
			ProductoId,		SucursalId,		ExistenciaTeorica,		CostoUltimaCompra,
			CostoPromedio,	ValCostoUltimaCompra,ValCostoPromedio,	ModificadoEl,
			CreadoEl
		)
		select @productoId,clave,isnull(@pExistencias,0),0,
		0,0,0,getdate(),
		getdate()
		from cat_sucursales
		where estatus =1 
		
		
		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END

		/**********Insertar carga inicial***********/
		declare @cargainventarioId int

		if not exists(
			select 1
			from [doc_inv_carga_inicial]
			where productoId = @productoId and
			SucursalId = @pSucursalId
		)
		begin
				select @cargainventarioId = isnull(max(cargainventarioId),0)+1
				from [doc_inv_carga_inicial]

				insert into [doc_inv_carga_inicial](
					CargaInventarioId,	SucursalId,		ProductoId,		Cantidad,
					CostoPromedio,		UltimoCosto,		CreadoEl,	CreadoPor
				)
				select @cargainventarioId,@pSucursalId,	@productoId,	@pExistencias,
				0,					0,					getdate(),		@pCreadoPor

				--IF @@ERROR <> 0
				--BEGIN
				--	ROLLBACK TRAN
				--	GOTO FIN
				--END
		End

		/***Insertar movimiento de inventario*****/
		
		select @movimiento = isnull(max(MovimientoId),0) + 1
		from [dbo].[doc_inv_movimiento]

		select @folio = isnull(max(Consecutivo),0) + 1
		from [dbo].[doc_inv_movimiento]
		where TipoMovimientoId = 1 --CargaInicial


		insert into [dbo].[doc_inv_movimiento](
			MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
			FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
			Activo,			CreadoPor,		CreadoEl,			Autorizado,
			FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
			ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
			MovimientoRefId,Cancelado
		)
		select @movimiento,@pSucursalId,cast(@folio as varchar),	1,
		getdate(),			getdate(),		'Importaci�n Productos Excel',isnull(@pPrecio,0)*isnull(@pExistencias,0),
		1,					@pCreadoPor,	getdate(),			1,
		getdate(),			null,			@pCreadoPor,		null,
		null,				@folio,			null,				null,
		null,				null


		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END

		select @movimientoDetalle = isnull(max(MovimientoDetalleId),0) +1
		from [doc_inv_movimiento_detalle]

		insert into [dbo].[doc_inv_movimiento_detalle](
			MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
			Cantidad,				PrecioUnitario,	Importe,		Disponible,
			CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
			ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
		)
		select @movimientoDetalle,	@movimiento,	@productoId,	1,
			isnull(@pExistencias,0),isnull(@pPrecio,0),isnull(@pPrecio,0)*isnull(@pExistencias,0),isnull(@pExistencias,0),
			@pCreadoPor,			GETDATE(),		0,			0,
			0,						0,				0
			
				
		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END



		if @pIVA > 0
		begin
			declare @ProductoImpuestoId int

			select @ProductoImpuestoId = isnull(max(ProductoImpuestoId),0)+1
			from cat_productos_impuestos

			insert into cat_productos_impuestos(
				ProductoImpuestoId,ProductoId,ImpuestoId
			)
			select @ProductoImpuestoId,@productoId,1 --IVA

						
			--IF @@ERROR <> 0
			--BEGIN
			--	ROLLBACK TRAN
			--	GOTO FIN
			--END
			
		end

		
		--Guardar Bitacora
		insert into doc_productos_importacion_bitacora(
			UUID,		ProductoId,		TipoMovimientoInventarioId,		Cantidad,
			CreadoEl,	CreadoPor
		)
		select @uuid,	@productoId,	1,								@pExistencias,
		GETDATE(),		@pCreadoPor


		SET @pInsertado = 1

	end
	--si el producto no existe
	else
	begin

		--generar entrada directa
		/***Insertar movimiento de inventario*****/
		
		select @movimiento = isnull(max(MovimientoId),0) + 1
		from [dbo].[doc_inv_movimiento]

		select @folio = isnull(max(Consecutivo),0) + 1
		from [dbo].[doc_inv_movimiento]
		where TipoMovimientoId = 7 --Entrada Directa


		insert into [dbo].[doc_inv_movimiento](
			MovimientoId,	SucursalId,		FolioMovimiento,	TipoMovimientoId,
			FechaMovimiento,HoraMovimiento,	Comentarios,		ImporteTotal,
			Activo,			CreadoPor,		CreadoEl,			Autorizado,
			FechaAutoriza,	SucursalDestinoId,AutorizadoPor,	FechaCancelacion,
			ProductoCompraId,Consecutivo,	SucursalOrigenId,	VentaId,
			MovimientoRefId,Cancelado
		)
		select @movimiento,@pSucursalId,cast(@folio as varchar),	7,
		getdate(),			getdate(),		'Importaci�n Productos Excel',isnull(@pPrecio,0)*isnull(@pExistencias,0),
		1,					@pCreadoPor,	getdate(),			1,
		getdate(),			null,			@pCreadoPor,		null,
		null,				@folio,			null,				null,
		null,				null


		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END

		select @movimientoDetalle = isnull(max(MovimientoDetalleId),0) +1
		from [doc_inv_movimiento_detalle]

		insert into [dbo].[doc_inv_movimiento_detalle](
			MovimientoDetalleId,	MovimientoId,	ProductoId,		Consecutivo,
			Cantidad,				PrecioUnitario,	Importe,		Disponible,
			CreadoPor,				CreadoEl,		CostoUltimaCompra,CostoPromedio,
			ValCostoUltimaCompra,	ValCostoPromedio,ValorMovimiento
		)
		select @movimientoDetalle,	@movimiento,	@productoId,	1,
			isnull(@pExistencias,0),isnull(@pPrecio,0),isnull(@pPrecio,0)*isnull(@pExistencias,0),isnull(@pExistencias,0),
			@pCreadoPor,			GETDATE(),		0,			0,
			0,						0,				0
			
				
		--Guardar Bitacora
		insert into doc_productos_importacion_bitacora(
			UUID,		ProductoId,		TipoMovimientoInventarioId,		Cantidad,
			CreadoEl,	CreadoPor
		)
		select @uuid,	@productoId,	7,								@pExistencias,
		GETDATE(),		@pCreadoPor


		--IF @@ERROR <> 0
		--BEGIN
		--	ROLLBACK TRAN
		--	GOTO FIN
		--END
	end
	

	

	--COMMIT TRAN

	FIN:


END







GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion_bitacora_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_productos_importacion_bitacora_sel]
as

	select UUID,
		  Fecha = convert(varchar,CreadoEl,103),
		  Producto = sum(cantidad)
	from [dbo].[doc_productos_importacion_bitacora]
	group by UUID,convert(varchar,CreadoEl,103)
	order by convert(varchar,CreadoEl,103) desc
GO
/****** Object:  StoredProcedure [dbo].[p_productos_importacion_validar]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_importacion_validar 1,1,''
create proc [dbo].[p_productos_importacion_validar]
@pSucursald int,
@pProductoId int
as

	declare @respuesta as bit

	if exists (select 1
	from doc_inv_movimiento m
	inner join doc_inv_movimiento_detalle md on md.MovimientoId = m.MovimientoId
	where SucursalId = @pSucursald and
	md.ProductoId = @pProductoId and
	m.Activo = 1 and
	m.TipoMovimientoId in (1,7) and
	convert(varchar,m.FechaMovimiento,112) = convert(varchar,GETDATE(),112))
	begin
		set @respuesta = 1
	end
	Else
	Begin
		set @respuesta = 0
		
	End

	select Respuesta = @respuesta

	
GO
/****** Object:  StoredProcedure [dbo].[p_productos_precio_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_productos_precio_grd 1
CREATE PROC [dbo].[p_productos_precio_grd]
@pIdProducto int
as

	select pp.IdProductoPrecio,
		   p.IdPrecio,
		   p.Descripcion,
		   pp.PorcDescuento,
		   pp.MontoDescuento,
		   pp.Precio
	from [cat_precios] p
	left join cat_productos_precios pp on pp.IdProducto = @pIdProducto and
									pp.IdPrecio = p.IdPrecio





GO
/****** Object:  StoredProcedure [dbo].[p_punto_venta_validar_sesion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_punto_venta_validar_sesion 2,1,'',0
CREATE proc [dbo].[p_punto_venta_validar_sesion]
@pUsuarioId int,
@pCajaId int,
@pError varchar(250) out,
@pSesionId int out
as

		declare @usuarioActivo varchar(100)=''
		set @pError = ''
		set @pSesionId = 0

	
		select @usuarioActivo = ua.NombreUsuario
		from doc_sesiones_punto_venta  s
		inner join cat_usuarios u on u.IdUsuario = @pUsuarioId and u.Activo = 1 and
									isnull(u.EsSupervisor,0) =0
									
		inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId and
								ua.IdUsuario <> @pUsuarioId
		where s.CajaId = @pCajaId and
		s.Finalizada = 0
	

		if rtrim(@usuarioActivo) != ''
		begin
			set @pError = 'Existe una sesi�n activa por el usuario:' + @usuarioActivo
		end

		if exists(
			select 1
			from doc_ventas v
			inner join doc_corte_caja_ventas ccv on ccv.VentaId = v.VentaId 
			where v.CajaId = @pCajaId and
			UsuarioCreacionId <> @pUsuarioId
		)
		BEGIN
			set @pError = @pError + 'Existen un corte pendiente por otro usuario' 
		END

		if @pError = ''
		begin 
			select @pSesionId = s.SesionId
			from doc_sesiones_punto_venta  s		
			inner join cat_usuarios ua on ua.IdUsuario = s.UsuarioId
			where s.CajaId = @pCajaId and
			s.Finalizada = 0 and			
			ua.IdUsuario = @pUsuarioId
		end


	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_apartado_ticket]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_apartado_ticket 1,2
CREATE Proc [dbo].[p_rpt_apartado_ticket]
@pApartadoId int,
@pApartadoPagoId int
as

	select Folio = a.ApartadoId,
			FechaApartado = A.CreadoEl,
			PagoRealizado = p.Importe,
			FechaPago = p.FechaPago,
			TotalApartado,
			Saldo,
			Empresa = e.NombreComercial,
			Sucursal = s.NombreSucursal,
			a.FechaLimite,
			ExpedidoEn = RTRIM(s.Calle) + ' '+
						RTRIM(s.NoExt) + ' '+
						RTRIM(s.NoInt) + ' '+
						RTRIM(s.Colonia) + ' '+
						RTRIM(s.Ciudad) + ' '+
						RTRIM(s.Estado),
			a.ClienteId,
			Cliente = cli.Nombre,
			--------
			ClaveProducto = PROD.Clave,
			Producto = prod.Descripcion,
			Cantidad = pProd.Cantidad,
			Importe = pProd.Total,
			TextoCabecera1 = ISNULL(TextoCabecera1,''),
			TextoCabecera2 = ISNULL(TextoCabecera2,''),
			TextoPie = ISNULL(TextoPie,''),
			AnticipoAbono = case when p.Anticipo = 1 then 'APARTADO INICIAL' else 'ABONO APARTADO' end,
			Serie = isnull(confA.Serie,''),
			Atendio = rh.Nombre

	from doc_apartados a
	inner join cat_sucursales s on s.Clave = a.SucursalId
	inner join cat_clientes cli on cli.ClienteId = A.ClienteId
	inner join cat_empresas e on e.Clave = s.Empresa
	inner join doc_apartados_pagos p on p.ApartadoId = a.ApartadoId and
									p.ApartadoPagoId = @pApartadoPagoId
	inner join doc_apartados_productos pProd on pProd.ApartadoId = A.ApartadoId
	inner join cat_productos prod on prod.ProductoId = pProd.ProductoId
	inner join cat_usuarios usu on usu.IdUsuario = p.CreadoPor
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	LEFT JOIN cat_configuracion_ticket_apartado confA on confA.SucursalId = a.SucursalId
	where a.ApartadoId = @pApartadoId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_apartados]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_apartados 1,0,'20180601','20180801',1
CREATE proc [dbo].[p_rpt_apartados]
@pSucursalId int,
@pCliente int,
@pDel datetime,
@pAl datetime,
@pSoloVencido bit
as

	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Cliente = a.ClienteId,
		Nombre = c.Nombre,
		FechaApartado = a.CreadoEl,
		a.FechaLimite,
		Folio = a.ApartadoId,
		Clave = max(p.Clave),
		SaldoPorVencer30 = (
			select isnull(sum(s1.Saldo),0)
			from doc_apartados s1
			where s1.ApartadoId = a.ApartadoId and
			DATEDIFF ( day , getdate() , a.FechaLimite ) <= 30 and
			a.FechaLimite > getdate()
		),
		SaldoVencido30 = (
			select isnull(sum(s1.Saldo),0)
			from doc_apartados s1
			where s1.ApartadoId = a.ApartadoId and
			DATEDIFF ( day , getdate() , a.FechaLimite ) >= 30 and
			a.FechaLimite < getdate()
		),
		SaldoTotal = a.Saldo,
		Telefono = isnull(c.Telefono,c.Telefono2)
	from doc_apartados a
	inner join doc_apartados_productos ap on ap.Apartadoid = a.ApartadoId
	inner join cat_clientes c on c.Clienteid = a.ClienteId
	inner join cat_productos p on p.Productoid = ap.ProductoId
	inner join cat_sucursales suc on suc.Clave = a.SucursalId
	inner join cat_empresas emp on emp.clave = suc.Empresa
	
	where a.SucursalId = @pSucursalId and
	(
		(
			convert(varchar,a.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)  and 
			@pSoloVencido = 0
		)
		OR
		(a.FechaLimite < getdate() and @pSoloVencido = 1 )
	)
	and
	a.Activo = 1 and
	a.saldo > 0 and
	@pCliente in (0,a.ClienteId)
	group by  a.ClienteId,
		 c.Nombre,
		 a.CreadoEl,
		 a.ApartadoId,
		 a.FechaLimite,
		 a.Saldo,
		 emp.NombreComercial,suc.NombreSucursal,
		 c.Telefono,
		 c.Telefono2

	order by a.ClienteId,a.CreadoEl
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_clientes_apartados]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_clientes_apartados 1
create proc [dbo].[p_rpt_clientes_apartados]
@pSucursalId int
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		c.ClienteId,
		c.Nombre,
		Telefono = isnull(c.Telefono,c.Telefono2),
		FechaApartado = max(a.CreadoEl),
		FechaVencimiento = max(a.FechaLimite),
		Producto = max(p.Clave),
		Saldo = max(a.Saldo),
		a.Apartadoid
		
	from cat_clientes c
	inner join cat_sucursales suc on suc.Clave = @pSucursalId
	inner join cat_empresas emp on emp.clave = suc.Empresa
	left join doc_apartados a on a.ClienteId = c.ClienteId and
								a.Activo = 1 and
								a.Saldo > 0  and
								a.SucursalId = @pSucursalId
	left join doc_apartados_productos ap on ap.ApartadoId = a.ApartadoId 
	left join cat_productos p on p.ProductoId = ap.ProductoId
	group by c.ClienteId,c.Nombre,c.Telefono,c.Telefono2,a.ApartadoId,emp.NombreComercial,suc.NombreSucursal
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_Comanda]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_rpt_Comanda]
@pPedidoId int,
@pComandaId int,
@pMarcarImpresos bit
as

	select Fecha = GETDATE(),
		Folio = com.Folio,
		Cantidad = pd.Cantidad ,
		Descripcion = prod.Descripcion + dbo.fnGetComandaAdicionales(pd.PedidoDetalleId),
		pd.Parallevar,
		Mesas = dbo.fnGetComandaMesas(@pPedidoId),
		Para = case when isnull(pd.Parallevar,0) = 1 then 'PARA LLEVAR' 
				when isnull(pd.Parallevar,0) = 0 then 'PARA MESA' 
				end
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_detalle pd on pd.PedidoId = p.PedidoId
	inner join cat_rest_comandas com on com.ComandaId = pd.ComandaId
	inner join cat_productos prod on prod.ProductoId = pd.ProductoId
	where p.PedidoId = @pPedidoId and isnull(Impreso,0) = 0
	and isnull(pd.Cancelado,0) = 0 
	--and
	--@pComandaId in (pd.ComandaId ,0 )
	order by cast(pd.Parallevar as int) ASC,pd.CreadoEl

	if(@pMarcarImpresos = 1)
	begin

		update doc_pedidos_orden_detalle
		set Impreso = 1		
		where PedidoId = @pPedidoId and
		isnull(Impreso,0) = 0

	end


	--update doc_pedidos_orden
	--set Total = (select isnull(sum(Total),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId),
	--	Impuestos = (select isnull(sum(Impuestos),0) from doc_pedidos_orden_detalle where PedidoId = @pPedidoId)
	--where PedidoId = @pPedidoId

	--update doc_pedidos_orden
	--set Subtotal = Total-isnull(Impuestos,0)
	--where PedidoId = @pPedidoId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[p_rpt_corte_caja_apartados]
@pCorteCajaId int
as

	select Folio = a.ApartadoId,
		a.TotalApartado 
	from doc_apartados a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_det]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_apartados_det 7
CREATE PROC [dbo].[p_rpt_corte_caja_apartados_det]
@pCorteCajaId int
as

	--Anticipos
	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Anticipo',
			Total = isnull(sum(a.Importe),0)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 1
	having count(distinct a.ApartadoPagoId) > 0

	union

	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Abono',
			Total = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 0
	having count(distinct a.ApartadoPagoId) > 0




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_det_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_apartados_det 7
create PROC [dbo].[p_rpt_corte_caja_apartados_det_previo]
@pCorteCajaId int
as

	--Anticipos
	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Anticipo',
			Total = isnull(sum(a.Importe),0)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 1
	having count(distinct a.ApartadoPagoId) > 0

	union

	select Pagos = count(distinct a.ApartadoPagoId),
			TipoPago = 'Abono',
			Total = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor and
	a.anticipo = 0
	having count(distinct a.ApartadoPagoId) > 0




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_apartados_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_rpt_corte_caja_apartados_previo]
@pCorteCajaId int
as

	select Folio = a.ApartadoId,
		a.TotalApartado 
	from doc_apartados a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor



GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_cancelaciones]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_cancelaciones 8
CREATE Proc [dbo].[p_rpt_corte_caja_cancelaciones]
@pCorteCajaId int
as

	select Folio = v.VentaId,
		FechaCancelacion = v.FechaCancelacion,
		v.TotalVenta
	from doc_ventas v
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId and
							v.FechaCancelacion
							between cc.FechaApertura and cc.FechaCorte and
							cc.CreadoPor = v.UsuarioCreacionId
	where v.Activo = 0  and
	v.CajaId = cc.CajaId



	
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_cancelaciones_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_cancelaciones 8
create Proc [dbo].[p_rpt_corte_caja_cancelaciones_previo]
@pCorteCajaId int
as

	select Folio = v.VentaId,
		FechaCancelacion = v.FechaCancelacion,
		v.TotalVenta
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId and
							v.FechaCancelacion
							between cc.FechaApertura and cc.FechaCorte and
							cc.CreadoPor = v.UsuarioCreacionId
	where v.Activo = 0  and
	v.CajaId = cc.CajaId



	
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_denom]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_denom 1
Create proc [dbo].[p_rpt_corte_caja_denom]
@pCorteCajaId int
as

	select Denominacion=d.Descripcion,
		Cantidad = cd.Cantidad,
		Total = cd.Total
	from doc_corte_caja_denominaciones cd
	inner join doc_corte_caja cc on cc.CorteCajaId = cd.CorteCajaId
	INNER JOIN cat_denominaciones d on d.Clave = cd.DenominacionId
	where cc.CorteCajaId = @pCorteCajaId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_denom_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_denom 1
create proc [dbo].[p_rpt_corte_caja_denom_previo]
@pCorteCajaId int
as

	select Denominacion=d.Descripcion,
		Cantidad = cd.Cantidad,
		Total = cd.Total
	from doc_corte_caja_denominaciones_previo cd
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = cd.CorteCajaId
	INNER JOIN cat_denominaciones d on d.Clave = cd.DenominacionId
	where cc.CorteCajaId = @pCorteCajaId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_descuentos]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_descuentos 1
CREATE proc [dbo].[p_rpt_corte_caja_descuentos]
@pCorteCaja int
as

	select v.Folio,
			Descuento = v.DescuentoEnPartidas
	from doc_corte_caja cc
	inner join doc_ventas v on v.VentaId between cc.VentaIniId and cc.VentaFinId and
				v.Activo = 1 and
				isnull(v.DescuentoEnPartidas,0) > 0 AND
				v.UsuarioCreacionId = cc.CreadoPor
	where cc.CorteCajaId = @pCorteCaja
	order by v.Folio

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_descuentos_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_descuentos 1
create proc [dbo].[p_rpt_corte_caja_descuentos_previo]
@pCorteCaja int
as

	select v.Folio,
			Descuento = v.DescuentoEnPartidas
	from doc_corte_caja_previo cc
	inner join doc_ventas v on v.VentaId between cc.VentaIniId and cc.VentaFinId and
				v.Activo = 1 and
				isnull(v.DescuentoEnPartidas,0) > 0 AND
				v.UsuarioCreacionId = cc.CreadoPor
	where cc.CorteCajaId = @pCorteCaja
	order by v.Folio

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_detallado]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- [p_rpt_corte_caja_detallado] 1,1,'20180723','20180724'
CREATE Proc [dbo].[p_rpt_corte_caja_detallado]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money,
		@efectivoApartado money,
		@tarjetaApartado money

    --gastos
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	

	--retiros
	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Efectivo Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoApartado
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasApartado
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Efectivo Venta
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	---vales
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpValesVenta
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (5) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId




	select 
		Dia = convert(varchar,FechaApertura,112) ,
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		--Ventas
		EfectivoVenta = isnull(ev.Total1,0),
		TarjetaVenta = isnull(tv.Total1,0),		
		TotalVenta =isnull(ev.Total1,0)+isnull(tv.Total1,0) ,
		--Apartados
		EfectivoApartado = isnull(ea.Total1,0),
		TarjetaApartado = isnull(ta.Total1,0),		
		TotalApartado =isnull(ea.Total1,0)+isnull(ta.Total1,0) ,
		--
		Gastos = isnull(g.total1,0),
		Vales = isnull(vv.total1,0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalIngreso = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0),
		TotalGral = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0)-
						 isnull(g.total1,0),
		TotalCorte = isnull(ev.Total1,0) +
					 isnull(tv.Total1,0) +
					 isnull(ea.Total1,0) +
					 isnull(ta.Total1,0) +
					 isnull(vv.total1,0) -
					 isnull(g.total1,0) -
					(
						select isnull(sum(sv.TotalVenta),0)
						from doc_ventas sv
						where sv.CajaId = cc.CajaId and
						sv.FechaCancelacion is not null and
						sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
					) -
					isnull(r.total1,0) -
					(
						select isnull(sum(sdev.Total),0)
						from doc_devoluciones sdev
						inner join doc_ventas sv on sv.VentaId = sdev.VentaId
						where sv.CajaId = cc.CajaId and
						sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
					),
		Vendedor = u.NombreUsuario
	from doc_corte_caja cc
	--inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u 
				on u.IdUsuario = (
					select isnull(min(sv.UsuarioCreacionId),cc.CreadoPor)
					from doc_ventas sv
					where sv.VentaId between cc.VentaIniId and cc.VentaFinId
					)
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join doc_corte_caja_fp_apartado ccapartado on ccapartado.CorteCajaId  = cc.CorteCajaId
	left join #tmpEfectivoApartado ea on ea.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasApartado ta on ta.CorteCajaId = cc.CorteCajaId
	left join #tmpEfectivoVenta ev on ev.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasVenta tv on tv.CorteCajaId = cc.CorteCajaId
	left join #tmpValesVenta vv on vv.CorteCajaId = cc.CorteCajaId

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		ea.total1,
		ta.total1,
		ev.total1,
		tv.total1,
		vv.total1
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_detallado_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- [p_rpt_corte_caja_detallado] 1,1,'20180723','20180724'
create Proc [dbo].[p_rpt_corte_caja_detallado_previo]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money,
		@efectivoApartado money,
		@tarjetaApartado money

    --gastos
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	

	--retiros
	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Efectivo Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasApartado
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp_apartado] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Efectivo Venta
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpEfectivoVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid = 1 --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	--Tarjeta Apartado
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpTarjetasVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (2,3) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId

	---vales
	select cc.CorteCajaId,total1 = isnull(sum(g.Total),0)
	into #tmpValesVenta
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join [doc_corte_caja_fp] g on g.CorteCajaId = cc.CorteCajaId and
											g.FormaPagoid in (5) --Efec
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId




	select 
		Dia = convert(varchar,FechaApertura,112) ,
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		--Ventas
		EfectivoVenta = isnull(ev.Total1,0),
		TarjetaVenta = isnull(tv.Total1,0),		
		TotalVenta =isnull(ev.Total1,0)+isnull(tv.Total1,0) ,
		--Apartados
		EfectivoApartado = isnull(ea.Total1,0),
		TarjetaApartado = isnull(ta.Total1,0),		
		TotalApartado =isnull(ea.Total1,0)+isnull(ta.Total1,0) ,
		--
		Gastos = isnull(g.total1,0),
		Vales = isnull(vv.total1,0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalIngreso = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0),
		TotalGral = isnull(ev.Total1,0)+isnull(tv.Total1,0)+
						isnull(ea.Total1,0)+isnull(ta.Total1,0)-
						 isnull(g.total1,0),
		TotalCorte = isnull(ev.Total1,0) +
					 isnull(tv.Total1,0) +
					 isnull(ea.Total1,0) +
					 isnull(ta.Total1,0) +
					 isnull(vv.total1,0) -
					 isnull(g.total1,0) -
					(
						select isnull(sum(sv.TotalVenta),0)
						from doc_ventas sv
						where sv.CajaId = cc.CajaId and
						sv.FechaCancelacion is not null and
						sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
					) -
					isnull(r.total1,0) -
					(
						select isnull(sum(sdev.Total),0)
						from doc_devoluciones sdev
						inner join doc_ventas sv on sv.VentaId = sdev.VentaId
						where sv.CajaId = cc.CajaId and
						sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
					),
		Vendedor = u.NombreUsuario
	from doc_corte_caja_previo cc
	--inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u 
				on u.IdUsuario = (
					select isnull(min(sv.UsuarioCreacionId),cc.CreadoPor)
					from doc_ventas sv
					where sv.VentaId between cc.VentaIniId and cc.VentaFinId
					)
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join doc_corte_caja_fp_apartado_previo ccapartado on ccapartado.CorteCajaId  = cc.CorteCajaId
	left join #tmpEfectivoApartado ea on ea.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasApartado ta on ta.CorteCajaId = cc.CorteCajaId
	left join #tmpEfectivoVenta ev on ev.CorteCajaId = cc.CorteCajaId
	left join #tmpTarjetasVenta tv on tv.CorteCajaId = cc.CorteCajaId
	left join #tmpValesVenta vv on vv.CorteCajaId = cc.CorteCajaId

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		ea.total1,
		ta.total1,
		ev.total1,
		tv.total1,
		vv.total1
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_devoluciones]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[p_rpt_corte_caja_devoluciones]
@pCorteCajaId int
as
	select FolioDevolucion=	dev.DevolucionId,
			FolioVenta = v.Folio,
			MontoDevolucion = dev.Total
	from doc_corte_caja cc
	INNER JOIN doc_devoluciones DEV ON 
				DEV.CreadoEl 
				between cc.FechaApertura and cc.FechaCorte 
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where cc.CorteCajaId = @pCorteCajaId AND
	cc.CreadoPor = dev.CreadoPor





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_devoluciones_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rpt_corte_caja_devoluciones_previo]
@pCorteCajaId int
as
	select FolioDevolucion=	dev.DevolucionId,
			FolioVenta = v.Folio,
			MontoDevolucion = dev.Total
	from doc_corte_caja_previo cc
	INNER JOIN doc_devoluciones DEV ON 
				DEV.CreadoEl 
				between cc.FechaApertura and cc.FechaCorte 
	inner join doc_ventas v on v.VentaId = dev.VentaId
	where cc.CorteCajaId = @pCorteCajaId AND
	cc.CreadoPor = dev.CreadoPor





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_enc]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_rpt_corte_caja_enc] 2
CREATE Proc [dbo].[p_rpt_corte_caja_enc]
@pCorteCajaId int
as

	declare @egresos money,
			@apartados money,
			@vales money,
			@cajaId int,
			@efectivo money,
			@tarjetas money

	select @egresos = isnull(Gastos,0)
	from [dbo].[doc_corte_caja_egresos]
	where CorteCajaId = @pCorteCajaId

	
	select @apartados = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor


	select @vales = isnull(sum(monto),0)
	from doc_ventas_formas_pago_vale fpv
	inner join doc_ventas v on v.ventaId = fpv.VentaId
	inner join doc_corte_caja cc on cc.cortecajaid = @pCorteCajaId
	where v.cajaid = @cajaId and
	fpv.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.cajaId = v.cajaId

	/***Efectivo de ventas y apartados*****/
	select @efectivo = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja cc
	left join [dbo].[doc_corte_caja_fp] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId = 1
	left join [dbo].[doc_corte_caja_fp_apartado] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId = 1
	where cc.CorteCajaId = @pCorteCajaId


	select @tarjetas = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja cc
	left join [dbo].[doc_corte_caja_fp] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId in(2,3)
	left join [dbo].[doc_corte_caja_fp_apartado] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId in(2,3)
	where cc.CorteCajaId = @pCorteCajaId
	
	

	select
			suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')),
			RFC = emp.RFC,
			NombreEmpresa = NombreComercial,
			Apertura = cc.FechaApertura,
			Corte = cc.FechaCorte,
			FolioIni = isnull(VentaIniId,0),
			FolioFin=isnull(VentaFinId,0),
			Usuario = rh.Nombre,
			Caja = caj.Descripcion,
			CC.TotalCorte,
			Egresos = @egresos,
			FolioVenta =isnull(v.Ventaid,0),
			TotalVenta = isnull(@efectivo,0)+isnull(@tarjetas,0),--case when v.activo = 0 then 0 else  isnull(v.TotalVenta,0) end,
			TotalNV = case when isnull(v.activo,0) = 0 then 0 else V.TotalVenta end,
			cc.CorteCajaId,
			Estatus = case when v.activo = 0 then 'C' else '' END,
			TotalApartado = isnull(@apartados,0),
			TotalGeneral =isnull(@efectivo,0)+isnull(@tarjetas,0)-isnull(@egresos,0),
			Efectivo = @efectivo,
			Tarjetas=@tarjetas
		from doc_corte_caja cc
		inner join cat_cajas caj on cc.CajaId = caj.Clave
		inner join cat_sucursales suc on suc.Clave = caj.Sucursal
		inner join cat_empresas emp on emp.Clave = suc.Empresa	
		inner join cat_usuarios usu on usu.IdUsuario = CreadoPor
		inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
		LEFT join doc_ventas v on v.VentaId between VentaIniId and VentaFinId AND
									V.VentaId NOT IN(
										SELECT ap.VentaId
										FROM doc_apartados ap
										where isnull(ap.VentaId,0) > 0
									)								
		where cc.CorteCajaId = @pCorteCajaId
		



	






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_enc_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_rpt_corte_caja_enc] 2
create Proc [dbo].[p_rpt_corte_caja_enc_previo]
@pCorteCajaId int
as

	declare @egresos money,
			@apartados money,
			@vales money,
			@cajaId int,
			@efectivo money,
			@tarjetas money

	select @egresos = isnull(Gastos,0)
	from [dbo].[doc_corte_caja_egresos_previo]
	where CorteCajaId = @pCorteCajaId

	
	select @apartados = sum(a.Importe)
	from doc_apartados_pagos a
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCajaId 
	where a.FechaPago between cc.FechaApertura and cc.FechaCorte and
	cc.CreadoPor = a.CreadoPor


	select @vales = isnull(sum(monto),0)
	from doc_ventas_formas_pago_vale fpv
	inner join doc_ventas v on v.ventaId = fpv.VentaId
	inner join doc_corte_caja_previo cc on cc.cortecajaid = @pCorteCajaId
	where v.cajaid = @cajaId and
	fpv.CreadoEl between cc.FechaApertura and cc.FechaCorte and
	cc.cajaId = v.cajaId

	/***Efectivo de ventas y apartados*****/
	select @efectivo = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja_previo cc
	left join [dbo].[doc_corte_caja_fp_previo] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId = 1
	left join [dbo].[doc_corte_caja_fp_apartado_previo] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId = 1
	where cc.CorteCajaId = @pCorteCajaId


	select @tarjetas = isnull(sum(ccfp.Total),0) + isnull(sum(ccfp2.Total),0)
	from doc_corte_caja_previo cc
	left join [dbo].[doc_corte_caja_fp_previo] ccfp on ccfp.CorteCajaid = cc.CorteCajaId and
									ccfp.FormaPagoId in(2,3)
	left join [dbo].[doc_corte_caja_fp_apartado_previo] ccfp2 on ccfp2.CorteCajaid = cc.CorteCajaId and
									ccfp2.FormaPagoId in(2,3)
	where cc.CorteCajaId = @pCorteCajaId
	
	

	select
			suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')),
			RFC = emp.RFC,
			NombreEmpresa = NombreComercial,
			Apertura = cc.FechaApertura,
			Corte = cc.FechaCorte,
			FolioIni = isnull(VentaIniId,0),
			FolioFin=isnull(VentaFinId,0),
			Usuario = rh.Nombre,
			Caja = caj.Descripcion,
			CC.TotalCorte,
			Egresos = @egresos,
			FolioVenta =isnull(v.Ventaid,0),
			TotalVenta = isnull(@efectivo,0)+isnull(@tarjetas,0),--case when v.activo = 0 then 0 else  isnull(v.TotalVenta,0) end,
			TotalNV = case when isnull(v.activo,0) = 0 then 0 else V.TotalVenta end,
			cc.CorteCajaId,
			Estatus = case when v.activo = 0 then 'C' else '' END,
			TotalApartado = isnull(@apartados,0),
			TotalGeneral =isnull(@efectivo,0)+isnull(@tarjetas,0)-isnull(@egresos,0),
			Efectivo = @efectivo,
			Tarjetas=@tarjetas
		from doc_corte_caja_previo cc
		inner join cat_cajas caj on cc.CajaId = caj.Clave
		inner join cat_sucursales suc on suc.Clave = caj.Sucursal
		inner join cat_empresas emp on emp.Clave = suc.Empresa	
		inner join cat_usuarios usu on usu.IdUsuario = CreadoPor
		inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
		LEFT join doc_ventas v on v.VentaId between VentaIniId and VentaFinId AND
									V.VentaId NOT IN(
										SELECT ap.VentaId
										FROM doc_apartados ap
										where isnull(ap.VentaId,0) > 0
									)								
		where cc.CorteCajaId = @pCorteCajaId
		



	






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_fp 1
Create proc [dbo].[p_rpt_corte_caja_fp]
@pCorteCajaId int
as

	select fp.FormaPagoId,
		FormaPago =fp.Descripcion,
		Monto = sum(cc.Total)
	from doc_corte_caja_fp cc
	inner join cat_formas_pago  fp on fp.FormaPagoId = cc.FormaPagoId
	where CorteCajaId = @pCorteCajaId
	group by fp.FormaPagoId,
		fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_fp_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_caja_fp 1
create proc [dbo].[p_rpt_corte_caja_fp_previo]
@pCorteCajaId int
as

	select fp.FormaPagoId,
		FormaPago =fp.Descripcion,
		Monto = sum(cc.Total)
	from doc_corte_caja_fp_previo cc
	inner join cat_formas_pago  fp on fp.FormaPagoId = cc.FormaPagoId
	where CorteCajaId = @pCorteCajaId
	group by fp.FormaPagoId,
		fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_gastos]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_gastos 1
CREATE proc [dbo].[p_rpt_corte_caja_gastos]
@pCorteCajaId int
as

	select FolioGasto = g.GastoId,
			Fecha = g.CreadoEl,
		   g.Monto,
		   CentroCosto = cc.Descripcion,
		   Concepto = con.Descripcion
	from doc_gastos g
	inner join doc_corte_caja c on c.CorteCajaId = @pCorteCajaId
	inner join cat_centro_costos cc on cc.Clave = g.CentroCostoId
	inner join cat_gastos con on con.Clave = g.GastoConceptoId
	where g.CreadoEl
	 between c.FechaApertura and c.FechaCorte and
	g.Activo = 1 and
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_gastos_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_gastos 1
create proc [dbo].[p_rpt_corte_caja_gastos_previo]
@pCorteCajaId int
as

	select FolioGasto = g.GastoId,
			Fecha = g.CreadoEl,
		   g.Monto,
		   CentroCosto = cc.Descripcion,
		   Concepto = con.Descripcion
	from doc_gastos g
	inner join doc_corte_caja_previo c on c.CorteCajaId = @pCorteCajaId
	inner join cat_centro_costos cc on cc.Clave = g.CentroCostoId
	inner join cat_gastos con on con.Clave = g.GastoConceptoId
	where g.CreadoEl
	 between c.FechaApertura and c.FechaCorte and
	g.Activo = 1 and
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_resumido]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_resumido 1,1,'20180723','20180724'
CREATE Proc [dbo].[p_rpt_corte_caja_resumido]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money
	
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId



	select Efectivo = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end),
	Tarjeta=sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end),
	Vales = sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	Total = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	cc.CorteCajaId
	into #tmpApartadosFP
	from [doc_corte_caja_fp_apartado] fp
	inner join doc_corte_caja cc on cc.CorteCajaId = fp.CorteCajaId
	inner join cat_cajas  c on c.clave = cc.CajaId
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId,fp.FormaPagoId


	select 
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		Fecha = cast(FechaApertura as date),
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		Efectivo = sum(case when ccfp.FormaPagoId = 1 then ccfp.Total else 0 end) +
					isnull(afp.Efectivo,0),
		Tarjeta = sum(case when ccfp.FormaPagoId in( 2,3) then ccfp.Total else 0 end)+
				isnull(afp.Tarjeta,0),
		Vales = sum(case when ccfp.FormaPagoId in( 5) then ccfp.Total else 0 end) +
				isnull(afp.Vales,0),
		Total =sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			isnull(afp.Total,0) ,
		Gastos = isnull(g.total1,0),--isnull(sum(g.Monto),0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),--isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalCorte = sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			 isnull(afp.Total,0)
			-
			isnull(g.total1,0)-
			(
				select isnull(sum(sv.TotalVenta),0)
				from doc_ventas sv
				where sv.CajaId = cc.CajaId and
				sv.FechaCancelacion is not null and
				sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
			) -
			isnull(r.total1,0)-
			(
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		Vendedor = u.NombreUsuario
	from doc_corte_caja cc
	inner join doc_corte_caja_fp ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u on u.IdUsuario = cc.CreadoPor
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join #tmpApartadosFP afp on afp.CorteCajaId = cc.CorteCajaId
	

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		afp.Efectivo,
		afp.Tarjeta,
		afp.Vales,
		afp.Total
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_resumido_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_resumido 1,1,'20180723','20180724'
create Proc [dbo].[p_rpt_corte_caja_resumido_previo]
@pSucursal int,
@pCajaId int,
@pDel DateTime,
@pAl DateTime
as

	declare @gastos money,
		@retiros money
	
	select cc.CorteCajaId,total1 = isnull(sum(g.Monto),0)
	into #tmpGastos
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_gastos g on g.CajaId = cc.cajaId and
							g.CreadoEl between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId


	select cc.CorteCajaId,total1 = isnull(sum(g.MontoRetiro),0)
	into #tmpRetiros
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.cajaId
	inner join doc_retiros g on g.CajaId = cc.cajaId and
							g.FechaRetiro between FechaApertura and FechaCorte
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId



	select Efectivo = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end),
	Tarjeta=sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end),
	Vales = sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	Total = sum(case when fp.FormaPagoId = 1 then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 2,3) then fp.Total else 0 end) +
			sum(case when fp.FormaPagoId in( 5) then fp.Total else 0 end),
	cc.CorteCajaId
	into #tmpApartadosFP
	from [doc_corte_caja_fp_apartado_previo] fp
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = fp.CorteCajaId
	inner join cat_cajas  c on c.clave = cc.CajaId
	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	c.Sucursal = @pSucursal and
	@pCajaId in (0,cc.cajaId)
	group by cc.CorteCajaId,fp.FormaPagoId


	select 
		Del = @pDel,
		Al = @pAl,
		Caja = caja.Descripcion,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Folio = cc.CorteCajaId,
		Fecha = cast(FechaApertura as date),
		FechaApertura = FechaApertura,
		FechaCierre = cc.FechaCorte,
		Efectivo = sum(case when ccfp.FormaPagoId = 1 then ccfp.Total else 0 end) +
					isnull(afp.Efectivo,0),
		Tarjeta = sum(case when ccfp.FormaPagoId in( 2,3) then ccfp.Total else 0 end)+
				isnull(afp.Tarjeta,0),
		Vales = sum(case when ccfp.FormaPagoId in( 5) then ccfp.Total else 0 end) +
				isnull(afp.Vales,0),
		Total =sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			isnull(afp.Total,0) ,
		Gastos = isnull(g.total1,0),--isnull(sum(g.Monto),0),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where sv.CajaId = cc.CajaId and
			sv.FechaCancelacion is not null and
			sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
		),
		Retiros = isnull(r.total1,0),--isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		TotalCorte = sum(case when ccfp.FormaPagoId in (1,2,3,5) then ccfp.Total else 0 end)+
			 isnull(afp.Total,0)
			-
			isnull(g.total1,0)-
			(
				select isnull(sum(sv.TotalVenta),0)
				from doc_ventas sv
				where sv.CajaId = cc.CajaId and
				sv.FechaCancelacion is not null and
				sv.FechaCancelacion between cc.FechaApertura and cc.FechaCorte
			) -
			isnull(r.total1,0)-
			(
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where sv.CajaId = cc.CajaId and
			sv.Fecha between cc.FechaApertura and cc.FechaCorte
			
		),
		Vendedor = u.NombreUsuario
	from doc_corte_caja_previo cc
	inner join doc_corte_caja_fp_previo ccfp on ccfp.CorteCajaId = cc.CorteCajaId
	inner join cat_cajas caja on caja.Clave = cc.CajaId
	inner join cat_sucursales suc on suc.Clave = caja.Sucursal
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios u on u.IdUsuario = cc.CreadoPor
	left join #tmpRetiros r on r.CorteCajaId = cc.CorteCajaId
	left join #tmpGastos g on g.CorteCajaId = cc.CorteCajaId
	left join #tmpApartadosFP afp on afp.CorteCajaId = cc.CorteCajaId
	

	where convert(varchar,cc.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	@pCajaId in (cc.CajaId ,0)
	group by  cc.CorteCajaId,
		 FechaApertura,
		 cc.FechaCorte,
		 cc.CajaId,
		 cc.TotalCorte,
		 emp.NombreComercial,
		suc.NombreSucursal,
		caja.Descripcion,
		u.NombreUsuario,
		r.total1,
		g.total1,
		afp.Efectivo,
		afp.Tarjeta,
		afp.Vales,
		afp.Total
	


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_retiros]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_retiros 1
CREATE Proc [dbo].[p_rpt_corte_caja_retiros]
@pCorteCajaId int
as

	select Folio=ret.RetiroId,
		Monto=ret.MontoRetiro,
		Fecha=ret.FechaRetiro
	from doc_corte_caja cc	
	inner join doc_retiros ret on ret.CajaId = cc.CajaId and
								ret.FechaRetiro
								between cc.FechaApertura
								 and cc.FechaCorte and
								 ret.CreadoPor = cc.CreadoPor
	
	where cc.CorteCajaId = @pCorteCajaId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_retiros_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_corte_caja_retiros 1
create Proc [dbo].[p_rpt_corte_caja_retiros_previo]
@pCorteCajaId int
as

	select Folio=ret.RetiroId,
		Monto=ret.MontoRetiro,
		Fecha=ret.FechaRetiro
	from doc_corte_caja_previo cc	
	inner join doc_retiros ret on ret.CajaId = cc.CajaId and
								ret.FechaRetiro
								between cc.FechaApertura
								 and cc.FechaCorte and
								 ret.CreadoPor = cc.CreadoPor
	
	where cc.CorteCajaId = @pCorteCajaId






GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_tpv_digito]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_tpv_digito 2
create proc [dbo].[p_rpt_corte_caja_tpv_digito]
@pCorteCajaId int
as

	select Folio = v.Serie + v.Folio,
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_ventas] ccv
	inner join [dbo].[doc_ventas_formas_pago] vfp on vfp.VentaId = ccv.VentaId
	inner join doc_ventas v on v.VentaId = vfp.VentaID
	where ccv.CorteId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

	union


	select Folio = cast(v.ApartadoId as varchar),
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_apartados_pagos] ccv
	inner join [dbo].[doc_apartados_formas_pago] vfp on vfp.ApartadoPagoId = ccv.ApartadoPagoId
	inner join doc_apartados_pagos ap on  ap.ApartadoPagoId = ccv.ApartadoPagoId
	inner join [dbo].[doc_apartados] v on v.ApartadoId = ap.ApartadoId
	where ccv.CorteCajaId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_tpv_digito_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_caja_tpv_digito 2
create proc [dbo].[p_rpt_corte_caja_tpv_digito_previo]
@pCorteCajaId int
as

	select Folio = v.Serie + v.Folio,
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_ventas_previo] ccv
	inner join [dbo].[doc_ventas_formas_pago] vfp on vfp.VentaId = ccv.VentaId
	inner join doc_ventas v on v.VentaId = vfp.VentaID
	where ccv.CorteId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

	union


	select Folio = cast(v.ApartadoId as varchar),
		Importe = vfp.Cantidad,
		Digito = digitoVerificador
	from [dbo].[doc_corte_caja_apartados_pagos_previo] ccv
	inner join [dbo].[doc_apartados_formas_pago] vfp on vfp.ApartadoPagoId = ccv.ApartadoPagoId
	inner join doc_apartados_pagos ap on  ap.ApartadoPagoId = ccv.ApartadoPagoId
	inner join [dbo].[doc_apartados] v on v.ApartadoId = ap.ApartadoId
	where ccv.CorteCajaId = @pCorteCajaId and
	vfp.FormaPagoId in (2,3)

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_vales]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_rpt_corte_caja_vales]
@pCorteCaja int
as

	select Folio = isnull(v.Serie,'') + cast(v.VentaId as varchar),
		   MontoTicket = v.TotalVenta,
		   FolioVale = vale.DevolucionId,
		   MontoVale = dev.Total
	from doc_ventas v
	inner join doc_corte_caja cc on cc.CorteCajaId = @pCorteCaja and
							v.Fecha between cc.FechaApertura and cc.FechaCorte
	inner join [dbo].[doc_ventas_formas_pago_vale] vale on vale.VentaId = v.VentaId 
	inner join doc_devoluciones  dev on dev.DevolucionId = vale.DevolucionId
						

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_caja_vales_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[p_rpt_corte_caja_vales_previo]
@pCorteCaja int
as

	select Folio = isnull(v.Serie,'') + cast(v.VentaId as varchar),
		   MontoTicket = v.TotalVenta,
		   FolioVale = vale.DevolucionId,
		   MontoVale = dev.Total
	from doc_ventas v
	inner join doc_corte_caja_previo cc on cc.CorteCajaId = @pCorteCaja and
							v.Fecha between cc.FechaApertura and cc.FechaCorte
	inner join [dbo].[doc_ventas_formas_pago_vale] vale on vale.VentaId = v.VentaId 
	inner join doc_devoluciones  dev on dev.DevolucionId = vale.DevolucionId
						

GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_productos_existencias]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_corte_productos_existencias 1,1
CREATE proc [dbo].[p_rpt_corte_productos_existencias]
@pCorteCajaId int,
@pSoloConExistencia bit
as

	declare @sucursalid int

	select @sucursalid = c.Sucursal
	from doc_corte_caja cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	where CorteCajaId = @pCorteCajaId

	select p.Clave,
			Descripcion = substring(p.Descripcion,1,30),
			pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	where pe.SucursalId = @sucursalid and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)
	ORDER BY P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_productos_existencias_previo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_productos_existencias 1,1
create proc [dbo].[p_rpt_corte_productos_existencias_previo]
@pCorteCajaId int,
@pSoloConExistencia bit
as

	declare @sucursalid int

	select @sucursalid = c.Sucursal
	from doc_corte_caja_previo cc
	inner join cat_cajas c on c.Clave = cc.CajaId
	where CorteCajaId = @pCorteCajaId

	select p.Clave,
			Descripcion = substring(p.Descripcion,1,30),
			pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	where pe.SucursalId = @sucursalid and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)
	ORDER BY P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_corte_reimpresiones]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_corte_reimpresiones 1
Create proc [dbo].[p_rpt_corte_reimpresiones]
@pCorteCajaId int
as

	select  g.ReimpresionTicketId,
			Folio = conf.Serie + CAST( g.ventaid AS varchar),
			FechaReimpresion = g.CreadoEl,
			ReimpresoPor = e.Nombre
	from doc_reimpresion_ticket g
	inner join doc_corte_caja c on c.CorteCajaId = @pCorteCajaId	
	inner join cat_cajas caj on caj.Clave = c.CajaId
	inner join cat_usuarios usu on usu.IdUsuario = g.CreadoPor
	inner join rh_empleados e on e.NumEmpleado = usu.IdEmpleado
	INNER JOIN cat_configuracion_ticket_venta conf on conf.SucursalId=caj.Sucursal
	where g.CreadoEl
	between c.FechaApertura and c.FechaCorte and	
	g.CajaId = c.CajaId AND
	g.CreadoPor = c.CreadoPor

	




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_cuenta]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_cuenta 1
create proc [dbo].[p_rpt_cuenta]
@pPedidoId int
as

	declare @meseroId int

	select @meseroId = EmpleadoId
	from doc_pedidos_orden_mesero
	where PedidoOrdenId = @pPedidoId

	select 
		Folio = p.PedidoId,
		e.NombreComercial,
		Cantidad = pd.Cantidad,
		Descripcion = pr.DescripcionCorta,
		PrecioUnitario = pd.PrecioUnitario,
		Importe = pd.Total,
		Mesa = dbo.fnGetComandaMesas(p.PedidoId),
		Mesero = cast(empleado.NumEmpleado as varchar(50)),
		Total = (select sum(Total) from doc_pedidos_orden_detalle where pedidoid= @pPedidoId)
	from doc_pedidos_orden p
	inner join doc_pedidos_orden_detalle pd on pd.PedidoId = p.PedidoId
	inner join cat_sucursales suc on suc.Clave = p.SucursalId
	inner join cat_empresas e on e.Clave = suc.Empresa
	inner join cat_productos pr on pr.ProductoId = pd.ProductoId
	inner join rh_empleados empleado on empleado.NumEmpleado = @meseroId
	where p.PedidoId = @pPedidoId
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_devolucion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_devolucion 2
CREATE Proc [dbo].[p_rpt_devolucion]
@pDevolucionId int
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Total = d.Total,
		v.VentaId,
		FechaRegistro = d.CreadoEl,
		RegistradoPor = e.Nombre,
		D.DevolucionId,
		d.FechaVencimiento,
		TipoDevolucion = td.Descripcion
	from doc_devoluciones d
	inner join doc_ventas v on v.VentaId = d.VentaId
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios us on us.IdUsuario = d.CreadoPor
	inner join rh_empleados e  on e.NumEmpleado = us.IdEmpleado
	inner join cat_tipos_devolucion td on td.TipoDevolucionId = d.TipoDevolucionId
	where d.DevolucionId = @pDevolucionId

	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_existencias_agrupado]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_existencias_agrupado 1,0,0,0,1,0,0,0
create proc [dbo].[p_rpt_existencias_agrupado]
@pSucursalId int,
@pLinea int,
@pFamilia int,
@pSubFamilia int,
@pLineaAgrupado bit,
@pFamiliaAgrupado bit,
@pSubfamiliaAgrupado bit,
@pSoloConExistencia bit
as

	select pe.ProductoId,
			pe.ExistenciaTeorica,
			p.ClaveLinea,
			p.ClaveFamilia,
			p.ClaveSubFamilia,
			Sucursal = suc.NombreSucursal
	INTO #tmpExistencias
	from cat_productos_existencias pe
	inner join cat_productos p  on  p.ProductoId = pe.ProductoId
	inner join cat_sucursales suc on suc.Clave = @pSucursalId
	where
	@pLinea in (0,p.ClaveLinea) and
	@pFamilia in(0,p.ClaveFamilia) and
	@pSubFamilia in (0,p.ClaveSubFamilia)  and
	pe.SucursalId = @pSucursalId AND
	(
		(PE.ExistenciaTeorica <> 0 AND @pSoloConExistencia = 1)
		or
		@pSoloConExistencia = 0
	)
	

	if(
		@pLineaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Línea',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_lineas linea on linea.Clave = tmp.ClaveLinea
		group by linea.Clave,linea.Descripcion
	end

	if(
		@pFamiliaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Familia',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_familias linea on linea.Clave = tmp.ClaveFamilia
		group by linea.Clave,linea.Descripcion
	end

	if(
		@pSubFamiliaAgrupado = 1
	)
	begin
		select Clave = linea.Clave,
				Tipo = 'Subfamilia',
				Descripcion = linea.Descripcion,
				Existencia = Sum(tmp.ExistenciaTeorica),
				Sucursal = MAX(TMP.Sucursal)
		FROM #tmpExistencias tmp
		inner join cat_subfamilias linea on linea.Clave = tmp.ClaveFamilia
		group by linea.Clave,linea.Descripcion
	end


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_gasto_ticket]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_gasto_ticket 1
Create Proc [dbo].[p_rpt_gasto_ticket]
@pGastoId int
as

	select Empresa = NombreComercial,
		Sucursal = suc.NombreSucursal,
		g.Obervaciones,
		g.Monto,
		CentroCosto = cc.Descripcion,
		Concepto = con.Descripcion,
		RegistradoPor = empl.Nombre,
		Fecha = convert(varchar,getdate(),103)
	from doc_gastos g
	inner join cat_sucursales suc on suc.Clave = g.SucursalId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join [dbo].[cat_centro_costos] cc on cc.Clave = g.CentroCostoId
	inner join [dbo].[cat_gastos] con on con.Clave = g.GastoConceptoId
	inner join [dbo].[cat_usuarios] usu on usu.IdUsuario = g.CreadoPor
	inner join [dbo].[rh_empleados] empl on empl.NumEmpleado = usu.IdEmpleado
	where g.gastoId = @pGastoId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_notas_venta_detalle]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_notas_venta_detalle 1,1,'20180101','20180701'
CREATE PROC [dbo].[p_rpt_notas_venta_detalle]
@pSucursalId int,
@pCajaId int,
@pDel DateTime,
@pAl  DateTime
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Del = @pDel,
		Al = @pAl,
		Folio = 'NV'+cast(v.VentaId as varchar),
		Fecha = v.Fecha,
		Caja = caja.Descripcion,
		Clave = prod.Clave,
		Producto = prod.DescripcionCorta,
		Precio = vd.PrecioUnitario,
		Cantidad = vd.cantidad,
		Total = case when v.FechaCancelacion is null then  vd.Total + vd.Descuento
					else 0
				End,
		Descuento = case when v.FechaCancelacion is null then vd.Descuento 
					else 0
				End,
		Importe =case when v.FechaCancelacion is null then vd.Total 
					else 0
				End ,
		Cajero = rh.Nombre,
		v.VentaId,
		Estatus = case when v.FechaCancelacion is null then '' 
					else 'C'
				End
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_productos prod on prod.ProductoId = vd.ProductoId
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_cajas caja on caja.Clave = v.CajaId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	where v.SucursalId = @pSucursalId and
	@pCajaId  in (0,v.CajaId) and
	CONVERT(VARCHAR,v.Fecha,112)  between CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112) --and
	--v.FechaCancelacion is null
	order by v.VentaId


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_notas_venta_resumido]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_notas_venta_resumido 1,1,'20180101','20180801'
CREATE proc [dbo].[p_rpt_notas_venta_resumido]
@pSucursalId int,
@pCajaId int,
@pDel DateTime,
@pAl  DateTime
as

	select 
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Del = @pDel,
		Al = @pAl,
		Folio = 'NV'+cast(v.VentaId as varchar),
		Fecha = cast(v.Fecha as date),
		Caja = caja.Descripcion,
		Total = case when v.FechaCancelacion is null then v.TotalVenta + v.TotalDescuento else 0 end,
		Descuento =case when v.FechaCancelacion is null then v.TotalDescuento else 0 end,
		Importe = case when v.FechaCancelacion is null then v.TotalVenta else 0 end,
		Cajero = rh.Nombre,
		Estatus = case when v.FechaCancelacion is not null then 'C' else '' END
	from doc_ventas v
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join cat_cajas caja on caja.Clave = v.CajaId
	inner join cat_empresas emp on emp.Clave = suc.Empresa
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rh on rh.NumEmpleado = usu.IdEmpleado
	where v.SucursalId = @pSucursalId and
	@pCajaId  in (0,v.CajaId) and
	CONVERT(VARCHAR,v.Fecha,112)  between CONVERT(VARCHAR,@pDel,112) and CONVERT(VARCHAR,@pAl,112) --and
	--v.FechaCancelacion is null
	order by v.VentaId




GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_existencias]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_rpt_productos_existencias]1,0,0,0,0
CREATE proc [dbo].[p_rpt_productos_existencias]
@pSucursalId int,
@pClaveLinea int,
@pClaveFamilia int,
@pClaveSubfamilia int,
@pSoloConExistencia bit
as

	select 
			p.ClaveLinea,
			ClaveFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) as int),
			ClaveSubFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) + cast(p.ClaveSubFamilia as varchar) as int),
			Linea = l.Descripcion,
			Familia = f.Descripcion,
			Subfamilia = sf.Descripcion,
			p.Clave,
			Descripcion = p.Clave+'-'+p.Descripcion,
			pe.ExistenciaTeorica,
			Sucursal = suc.NombreSucursal,
			PrecioVenta = pp.Precio
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId and pp.IdPrecio = 1
	inner join cat_lineas l on l.Clave = p.ClaveLinea
	inner join cat_familias f on f.Clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	INNER JOIN cat_sucursales suc on suc.Clave = pe.SucursalId
	where pe.SucursalId = @pSucursalId and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)and @pClaveLinea in(0,p.ClaveLinea) and
	@pClaveFamilia in(0,p.ClaveFamilia) and
	@pClaveSubfamilia in(0,p.ClaveSubFamilia)
	
	ORDER BY p.ClaveLinea,P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_existencias_valuo]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_rpt_productos_existencias_valuo] 1,0,0,0,0,60
CREATE proc [dbo].[p_rpt_productos_existencias_valuo]
@pSucursalId int,
@pClaveLinea int,
@pClaveFamilia int,
@pClaveSubfamilia int,
@pSoloConExistencia bit,
@pDescuento decimal(10,2)
as

	select 
			p.ClaveLinea,
			ClaveFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) as int),
			ClaveSubFamilia=cast(cast(p.claveLinea as varchar) + cast(p.ClaveFamilia as varchar) + cast(p.ClaveSubFamilia as varchar) as int),
			Linea = l.Descripcion,
			Familia = f.Descripcion,
			Subfamilia = sf.Descripcion,
			p.Clave,
			Descripcion = p.Clave+'-'+p.Descripcion,
			pe.ExistenciaTeorica,
			Sucursal = suc.NombreSucursal,
			PrecioVenta = pp.Precio,
			ExistenciaValuada = isnull(pp.Precio,0) * isnull(pe.ExistenciaTeorica,0),
			Descuento = @pDescuento,
			PrecioConDescuento =  cast(
										isnull(pp.Precio,0) - (isnull(pp.Precio,0)*(@pDescuento / 100 ))
										
										as decimal(10,2)),
			ExistenciaDescValuada = cast(
										isnull(pp.Precio,0) - (isnull(pp.Precio,0)*(@pDescuento / 100 ))
										
										as decimal(10,2)) * pe.ExistenciaTeorica
	from cat_productos_existencias pe
	inner join cat_productos p on p.ProductoId = pe.ProductoId
	inner join cat_productos_precios pp on pp.IdProducto = p.ProductoId and pp.IdPrecio = 1
	inner join cat_lineas l on l.Clave = p.ClaveLinea
	inner join cat_familias f on f.Clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	INNER JOIN cat_sucursales suc on suc.Clave = pe.SucursalId
	where pe.SucursalId = @pSucursalId and
	(
		(isnull(pe.ExistenciaTeorica,0) <> 0 AND @pSoloConExistencia = 1) 
		or
		@pSoloConExistencia = 0
	)and @pClaveLinea in(0,p.ClaveLinea) and
	@pClaveFamilia in(0,p.ClaveFamilia) and
	@pClaveSubfamilia in(0,p.ClaveSubFamilia)
	
	ORDER BY p.ClaveLinea,P.ClaveFamilia,P.ClaveSubFamilia, p.Descripcion
	





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_importacion]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec p_rpt_productos_importacion '41129728-6e9b-4040-a092-a6da356794b6' 
create proc [dbo].[p_rpt_productos_importacion]
@pUUID uniqueidentifier
as

	select UUID,
		p.Clave,
		p.Descripcion,
		b.Cantidad,
		Movimiento = mov.Descripcion,
		Fecha = convert(varchar,b.CreadoEl,103)
	from doc_productos_importacion_bitacora  b
	inner join cat_tipos_movimiento_inventario mov on mov.TipoMovimientoInventarioId = b.TipoMovimientoInventarioId
	inner join cat_productos p on p.ProductoId = b.productoId
	where UUID  = @pUUID
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_productos_vendidos]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_productos_vendidos 1,0,0,'20180601','20180730'
create proc [dbo].[p_rpt_productos_vendidos]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as


	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad)
	into #tmpResult
	from doc_ventas v
	inner join doc_ventas_detalle vd on vd.VentaId = v.VentaId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.UsuarioCreacionId) and
	c.Sucursal = @pSucursalId and
	convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) and
	v.FechaCancelacion is null
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	--order by SUM(vd.Cantidad) desc

	insert into #tmpResult
	select 
		Del = @pDel,
		Al = @pAl,
		Empresa = emp.NombreComercial,
		Sucursal = suc.NombreSucursal,
		Linea = l.Descripcion,
		Familia = f.Descripcion,
		Subfamilia = sf.Descripcion,
		p.ProductoId,
		p.Clave,
		Producto = p.Descripcion,
		Cantidad = SUM(vd.Cantidad)
	from doc_apartados v
	inner join doc_apartados_productos vd on vd.ApartadoId = v.ApartadoId
	inner join cat_cajas c on c.clave = v.cajaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	inner join cat_lineas l on l.clave = p.ClaveLinea
	inner join cat_familias f on f.clave = p.ClaveFamilia
	inner join cat_subfamilias sf on sf.Clave = p.ClaveSubFamilia
	inner join cat_sucursales suc on suc.clave = v.SucursalId
	inner join cat_empresas emp on emp.clave = suc.empresa
	where @pCajaId in (0,v.cajaId) and
	@pCajeroId in (0,v.CreadoPor) and
	c.Sucursal = @pSucursalId and
	v.activo = 1 and
	v.saldo = 0 and
	convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112) 
	
	group by  l.Descripcion,
		f.Descripcion,
		sf.Descripcion,
		p.Descripcion,
		p.ProductoId,
		p.Clave,
		suc.NombreSucursal,
		emp.NombreComercial
	order by SUM(vd.Cantidad) desc


	select Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto ,
		Cantidad = sum(Cantidad)
	from #tmpResult
	group by 
	Del,
		Al,
		Empresa ,
		Sucursal,
		Linea ,
		Familia ,
		Subfamilia ,
		ProductoId,
		Clave,
		Producto
	order by sum(Cantidad) desc


	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_retiro_ticket]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_rpt_retiro_ticket 1
Create Proc [dbo].[p_rpt_retiro_ticket]
@pRetiroId int
as

	SELECT r.RetiroId,
		r.FEchaRetiro,
		r.MontoRetiro,
		Usuario = e.Nombre,
		em.RFC,
		Direccion =  ISNULL(suc.Calle,'') + ' '+
						ISNULL(suc.NoExt ,'') + ' ' +
						ISNULL(suc.NoInt,'') +' '+
						ISNULL(suc.Colonia, '') + ' '+
						ISNULL(suc.Ciudad,'') +','+
						ISNULL(suc.Estado,'') +','+
						ISNULL(suc.Pais,''),
		suc.NombreSucursal,
		FECHA = CONVERT(VARCHAR,r.FEchaRetiro,103),
		HORA = CONVERT(VARCHAR,r.FEchaRetiro,108),
		r.Observaciones

	FROM DOC_RETIROS r
	inner join cat_usuarios u on u.IdUsuario = r.CreadoPor
	inner join rh_empleados e on e.NumEmpleado = u.IdEmpleado
	inner join cat_empresas em on em.clave = 1
	inner join cat_sucursales suc on suc.Clave = r.SucursalId
	where r.retiroId=@pRetiroId





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_venta_ticket_formaspago]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_rpt_venta_ticket_formaspago 1
Create Proc [dbo].[p_rpt_venta_ticket_formaspago]
@pVentaId int
as

	select Monto = dfp.Cantidad,
		FormaPago=fp.Descripcion
	from doc_ventas_formas_pago dfp
	inner join cat_formas_pago fp on fp.FormaPagoId = dfp.FormaPagoId
	where VentaId = @pVentaId
	order by fp.Descripcion





GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_resumen]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_web_rpt_ventas_resumen 1
create proc [dbo].[p_rpt_ventas_resumen]
@pSucursalId int
as


	select  
		v.SucursalId,
		Sucursal = suc.NombreSucursal,
		v.Serie,
		v.Folio,
		p.Clave,
		FechaHora = v.FechaCreacion,
		p.Descripcion,
		vd.Cantidad,
		vd.Descuento,
		Cancelado =cast(case when v.FechaCancelacion is null then 0 else 1 end as bit),
		Total =  case when v.FechaCancelacion is null then  vd.Total else 0 end ,
		Cliente = c.Nombre,
		Coche = cast(aut.Modelo as varchar) + ' Color:' + isnull(aut.Color,'') +' Placas:' +  isnull(aut.Placas,''),
		Observaciones = isnull(aut.Observaciones,'') +' ' + isnull(v.MotivoCancelacion,'')
	from doc_ventas v
	inner join cat_sucursales suc on suc.Clave = v.SucursalId
	inner join doc_ventas_detalle vd on vd.VentaID= v.ventaId
	inner join cat_productos p on p.ProductoId = vd.ProductoId
	left join cat_clientes c on c.ClienteId = v.ClienteId
	left join cat_clientes_automovil aut on aut.ClienteId = c.ClienteId
	where @pSucursalId in (v.SucursalId,0)
	group by v.SucursalId, suc.NombreSucursal,
	v.Serie,
		v.Folio,
		p.Clave,
		v.FechaCreacion,
		p.Descripcion,
		vd.Cantidad,
		vd.Descuento,
		v.FechaCancelacion,
		vd.Total,
		c.Nombre,
		aut.Modelo,
		aut.Color,
		aut.Placas,
		aut.Observaciones,
		v.MotivoCancelacion
	order by v.FechaCreacion desc
	
GO
/****** Object:  StoredProcedure [dbo].[p_rpt_ventas_vendedor]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- p_rpt_ventas_vendedor 1,0,0,'20180724','20180724'
CREATE proc [dbo].[p_rpt_ventas_vendedor]
@pSucursalId int,
@pCajaId int,
@pCajeroId int,
@pDel DateTime,
@pAl DateTime
as

		select v.UsuarioCreacionId,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId in( 5) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.Fecha,112)
		into #tmpFormasPagoV
		from [doc_ventas_formas_pago] vfp
		inner join doc_ventas v on v.VentaId = vfp.VentaId
		where @pCajeroId in (0,v.UsuarioCreacionId) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and
		v.FechaCancelacion is null and
		convert(varchar,v.Fecha,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by v.UsuarioCreacionId,convert(varchar,v.Fecha,112)

		union

		select ap.CreadoPor,
			Efectivo = sum(case when vfp.FormaPagoId = 1 then Cantidad  else 0 end),
			Tarjeta = sum(case when vfp.FormaPagoId in( 2,3) then Cantidad  else 0 end),
			Vales = sum(case when vfp.FormaPagoId in( 5) then Cantidad  else 0 end),
			Total = sum(case when vfp.FormaPagoId in( 1,2,3,5) then Cantidad  else 0 end),
			Fecha = convert(varchar,v.CreadoEl,112)
		
		from doc_apartados_formas_pago vfp
		inner join doc_apartados_pagos ap on ap.ApartadoPagoId = vfp.ApartadoPagoId
		inner join doc_apartados v on v.ApartadoId = ap.ApartadoId
		where @pCajeroId in (0,ap.CreadoPor) and 
		@pCajaId IN (0,V.CajaId) and
		v.SucursalId = @pSucursalId and		
		convert(varchar,v.CreadoEl,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
		group by ap.CreadoPor,convert(varchar,v.CreadoEl,112)

		--select * from #tmpFormasPagoV


		select UsuarioCreacionId,
			Efectivo =sum(Efectivo),
			Tarjeta =sum(Tarjeta),
			Vales =sum(Vales),
			Total =sum(Total),
			Fecha
		into  #tmpFormasPagoV2
		from #tmpFormasPagoV
		group by UsuarioCreacionId,Fecha

		select 
		Del = @pDel,
		Al = @pAl,
		u.IdUsuario,
		Fecha = convert(varchar,v.Fecha,103),
		Vendedora = u.NombreUsuario,
		Efectivo = fp.Efectivo,
		Tpv = fp.Tarjeta,
		Vales = fp.Vales,
		Total = fp.Total,
		Gastos = (
			select isnull(sum(Monto),0)
			from doc_gastos g
			where @pCajaId in (0,g.cajaId) and
			g.SucursalId = @pSucursalId and
			v.UsuarioCreacionId = g.CreadoPor and
			convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103)
		),
		Cancelaciones = (
			select isnull(sum(sv.TotalVenta),0)
			from doc_ventas sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.UsuarioCancelacionId and
			sv.FechaCancelacion is not null and
			convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103)
		),
		Retiros =(
			select isnull(sum(sv.MontoRetiro),0)
			from doc_retiros sv
			where @pCajaId in(sv.CajaId,0)  and
			v.UsuarioCreacionId = sv.CreadoPor and			
			convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103)
		),-- isnull(sum(ret.MontoRetiro),0),
		Devoluciones = (
			select isnull(sum(sdev.Total),0)
			from doc_devoluciones sdev
			inner join doc_ventas sv on sv.VentaId = sdev.VentaId
			where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
			@pCajaId in (0,sv.CajaId) and
			v.UsuarioCreacionId = sdev.CreadoPor and
			sv.SucursalId = @pSucursalId		
			
		),
		TotalCorte = fp.Total 
				-
					(
					select isnull(sum(Monto),0)
					from doc_gastos g
					where @pCajaId in (0,g.cajaId) and
					g.SucursalId = @pSucursalId and
					v.UsuarioCreacionId = g.CreadoPor and
					convert(varchar,g.CreadoEl,103) = convert(varchar,v.Fecha,103) 
				)
				-
				(
					select isnull(sum(sv.TotalVenta),0)
					from doc_ventas sv
					where @pCajaId in(sv.CajaId,0)  and
					v.UsuarioCreacionId = sv.UsuarioCancelacionId and
					sv.FechaCancelacion is not null and
					convert(varchar,sv.FechaCancelacion,103) = convert(varchar,v.Fecha,103) 
				)
				-
				(
					select isnull(sum(sdev.Total),0)
					from doc_devoluciones sdev
					inner join doc_ventas sv on sv.VentaId = sdev.VentaId
					where convert(varchar,sv.Fecha,103) = convert(varchar,v.Fecha,103) and
					@pCajaId in (0,sv.CajaId) and
					v.UsuarioCreacionId = sdev.CreadoPor and
					sv.SucursalId = @pSucursalId		
			
				)
				-
				(
					select isnull(sum(sv.MontoRetiro),0)
					from doc_retiros sv
					where @pCajaId in(sv.CajaId,0)  and
					v.UsuarioCreacionId = sv.CreadoPor and			
					convert(varchar,sv.FechaRetiro,103) = convert(varchar,v.Fecha,103) 
				)			,
			Empresa = emp.NombreComercial,
			Sucursal = suc.NombreSucursal
		from doc_ventas v
		inner join #tmpFormasPagoV2 fp on 	convert(varchar,fp.Fecha,112) = convert(varchar,v.Fecha,112)
		inner join cat_usuarios u on u.IdUsuario = v.UsuarioCreacionId and
									fp.UsuarioCreacionId = u.IdUsuario
		--inner join cat_formas_pago cfp on cfp.FormaPagoId = fp.FormaPagoId
		inner join cat_sucursales suc on suc.Clave = v.SucursalId
		inner join cat_empresas emp on emp.Clave = suc.Empresa
		
		where v.SucursalId =@pSucursalId and
		@pCajaId in (0,v.CajaId) and
		@pCajeroId in (v.UsuarioCreacionId ,0) and
		convert(varchar,v.Fecha,112) 
			between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)

			group by  convert(varchar,v.Fecha,103),
			u.NombreUsuario,
			IdUsuario,
			 emp.NombreComercial,
			suc.NombreSucursal,
			v.UsuarioCreacionId,
			fp.Efectivo,
			fp.Tarjeta,
			fp.Vales,
			fp.Total


GO
/****** Object:  StoredProcedure [dbo].[p_rpt_VentaTicket]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [p_rpt_VentaTicket] 11
CREATE PROC [dbo].[p_rpt_VentaTicket]
@pVentaId INT
AS


	declare @Giro varchar(20) ,
		@Observaciones varchar(500)	

	select @Giro = Giro
	from cat_configuracion

	select @Observaciones = case when @Giro = 'AUTOLAV'
								then 'Nombre:'+cli.Nombre + ', ' +
									'Modelo:'+isnull(a.Modelo,'') + ' ' +
									isnull(a.Color,'') + ' ' +
									isnull(a.placas,'') + ', '+
									'Obs:'+isnull(a.Observaciones,'')
								else ''
							End
	from doc_ventas v
	inner join cat_clientes cli on cli.clienteId = v.ClienteId
	inner join cat_clientes_automovil a on a.ClienteId = cli.clienteId
	where VentaId = @pVentaId

	SELECT suc.NombreSucursal,
			Direccion = RTRIM(ISNULL(suc.Calle,'')) + ' '+
						RTRIM(ISNULL(suc.NoExt ,'')) + ' ' +
						RTRIM(ISNULL(suc.NoInt,'')) +' '+
						RTRIM(ISNULL(suc.Colonia, '')) + ' '+
						RTRIM(ISNULL(suc.Ciudad,'')) +','+
						RTRIM(ISNULL(suc.Estado,'')) +','+
						RTRIM(ISNULL(suc.Pais,'')) ,
			FOLIO = v.VentaId,
			vd.VentaDetalleId,
			FECHA = CONVERT(VARCHAR,v.FechaCreacion,103),
			HORA = CONVERT(VARCHAR,v.FechaCreacion,108),
			Producto = prod.DescripcionCorta + ' ' +isnull(prod.talla,''),
			Cantidad = vd.Cantidad,
			ImportePartida = vd.Total,
			TotalVenta = v.TotalVenta,
			TotalDescuentoVenta = v.TotalDescuento,
			SubTotalVenta = v.TotalVenta - v.Impuestos,
			ImpuestosVenta = v.Impuestos,
			TotalRecibido = SUM(vfp.Cantidad) + isnull(v.cambio,0),
			suc.Telefono1,
			RFC = emp.RFC,
			vd.PrecioUnitario,
			v.Cambio,
			conf.TextoCabecera1,
			conf.TextoCabecera2,
			conf.TextoPie,
			Serie = isnull(conf.Serie,''),
			Atendio = rhe.Nombre,
			MotivoCancelacion =case when isnull(v.MotivoCancelacion,'') = '' then ''
									else 'Motivo Cancelaci�n:' + isnull(v.MotivoCancelacion,'')
								End,
			TasaIVA = isnull(max(vd.TasaIVA),0),
			Observaciones = @Observaciones
	FROM dbo.doc_ventas v
	INNER JOIN dbo.doc_ventas_detalle vd ON vd.VentaId = v.VentaId
	INNER JOIN dbo.cat_productos prod ON prod.ProductoId = vd.ProductoId
	INNER JOIN dbo.cat_sucursales suc ON suc.Clave = v.SucursalId
	INNER JOIN dbo.doc_ventas_formas_pago vfp ON vfp.VentaId = v.VentaId
	inner join cat_empresas emp on emp.Clave = 1
	inner join cat_usuarios usu on usu.IdUsuario = v.UsuarioCreacionId
	inner join rh_empleados rhE on rhE.NumEmpleado = usu.IdEmpleado
	LEFT JOIN cat_configuracion_ticket_venta conf on conf.SucursalId = v.SucursalId
	
	WHERE v.VentaId = @pVentaId
	GROUP BY v.VentaId,suc.Calle,suc.NoExt ,suc.NoInt,suc.Colonia,suc.Ciudad,suc.Estado,suc.Pais,v.FechaCreacion,
	prod.DescripcionCorta,vd.Cantidad,vd.Total,v.TotalVenta,v.TotalDescuento,v.Impuestos,v.Impuestos,vd.VentaDetalleId,
	suc.NombreSucursal,suc.Telefono1,emp.RFC,vd.PrecioUnitario,v.Cambio,prod.talla,
	conf.TextoCabecera1,conf.TextoCabecera2,conf.TextoPie,conf.Serie,rhe.Nombre,v.MotivoCancelacion










GO
/****** Object:  StoredProcedure [dbo].[p_salidas_traspaso_grd]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[p_salidas_traspaso_grd]
@pFolio int,
@pDel datetime,
@pAl datetime
as

	select i.MovimientoId,
			i.SucursalId,
			i.FolioMovimiento,
			i.TipoMovimientoId,
			i.FechaMovimiento,
			i.HoraMovimiento,
			i.Comentarios,
			i.ImporteTotal,
			i.Activo,
			i.CreadoPor,
			i.CreadoEl,
			i.Autorizado,
			i.FechaAutoriza,
			i.SucursalDestinoId,
			Destino = s.NombreSucursal
	from [dbo].[doc_inv_movimiento] i
	inner join cat_sucursales s on s.clave = i.SucursalDestinoId
	where (
		MovimientoId = @pFolio and
		@pFolio > 0
	)
	Or
	(
		convert(varchar,FechaMovimiento,112) between convert(varchar,@pDel,112) and convert(varchar,@pAl,112)
	)
	and isnull(Autorizado,0) = 1





GO
/****** Object:  StoredProcedure [dbo].[p_sis_bitacora_errores_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_sis_bitacora_errores_ins]
@pIdError	int out,
@pSistema	varchar(50),
@pClase	varchar(250),
@pMetodo	varchar(250),
@pError	varchar(500)
as

	select @pIdError = isnull(max(IdError),0) + 1
	from sis_bitacora_errores

	insert into sis_bitacora_errores(
		IdError,	Sistema,	Clase,		Metodo,
		Error,		CreadoEl
	)
	values(
		@pIdError,@pSistema,@pClase,@pMetodo,
		@pError,getdate()
	)
GO
/****** Object:  StoredProcedure [dbo].[p_sis_versiones_detalle_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


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









	
GO
/****** Object:  StoredProcedure [dbo].[p_sis_versiones_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_sis_versiones_ins '2010.10.02,2010.10.03'
create proc [dbo].[p_sis_versiones_ins]
@pVersiones varchar(5000)
as

	declare @versionId int

	select @versionId = isnull(max(VersionId),0) 
	from [sis_versiones]
	
	select *
	into #tmpVersiones
	from [dbo].fnSplitString(@pVersiones,',')

	insert into [dbo].[sis_versiones](VersionId,Nombre,CreadoEl,Completado,Intentos)
	select ROW_NUMBER() OVER(ORDER BY splitdata ASC)  + @versionId,splitdata,getdate(),0,0
	from #tmpVersiones
	where not exists (
		select 1
		from [sis_versiones]
		where Nombre = splitdata
	)
	order by splitdata
GO
/****** Object:  StoredProcedure [dbo].[p_sucursales_usuario_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_sucursales_usuario_sel]
@pUsuario varchar(20)
as

	declare @esSupervisor bit

	select @esSupervisor = u.EsSupervisor
	from cat_usuarios u
	where rtrim(u.NombreUsuario) = rtrim(@pUsuario)


	if(@esSupervisor = 1)
	begin

		select s.Clave,
				s.NombreSucursal
		from cat_sucursales s
		
	end
	else
	begin
		select s.Clave,
				s.NombreSucursal
		from cat_sucursales s
		inner join cat_usuarios u on rtrim(u.NombreUsuario) = rtrim(@pUsuario) and
					u.IdSucursal = s.Clave
	end



GO
/****** Object:  StoredProcedure [dbo].[p_venta_afecta_inventario]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[p_venta_afecta_inventario]
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
	Cantidad = case when count(distinct pb.ProductoBaseId) > 0 then 0 else sum(vd.Cantidad) end,			VD.PrecioUnitario,			VD.Total,	
	--Si tiene productos base, insertar cantidad 0 ya que no se debe de inventariar, solo dejar registro		
	Disponible = case when count(distinct pb.ProductoBaseId) > 0 then 0 else sum(vd.Cantidad) end,
	v.UsuarioCreacionId,GETDATE()
	from doc_ventas V
	inner join doc_ventas_detalle vd on vd.VentaId = V.VentaId
	left join cat_productos_base pb on pb.ProductoId = vd.ProductoId
	where v.VentaId = @pVentaId AND
	V.Activo = 1
	group by vd.ProductoId,VD.PrecioUnitario,VD.Total,v.UsuarioCreacionId

	select @movimientoDetalleId = isnull(max(MovimientoDetalleId),0) + 1
	from doc_inv_movimiento_detalle

	--Detalle de movs con productos base
	insert into doc_inv_movimiento_detalle(
		MovimientoDetalleId,	MovimientoId,	ProductoId,	Consecutivo,	Cantidad,
		PrecioUnitario,			Importe,		Disponible,	CreadoPor,		CreadoEl
	)
	select @movimientoDetalleId + ROW_NUMBER() OVER(ORDER BY pb.ProductoBaseId ASC), @movimientoid, 
	pb.ProductoBaseId,ROW_NUMBER() OVER(ORDER BY pb.ProductoBaseId ASC),
	sum(pb.Cantidad),			0,			0,	
	--Si tiene productos base, insertar cantidad 0 ya que no se debe de inventariar, solo dejar registro		
	Cantidad = sum(pb.Cantidad),
	v.UsuarioCreacionId,GETDATE()
	from doc_ventas V
	inner join doc_ventas_detalle vd on vd.VentaId = V.VentaId
	inner join cat_productos_base pb on pb.ProductoId = vd.ProductoId
	where v.VentaId = @pVentaId AND
	V.Activo = 1
	group by pb.ProductoBaseId,v.UsuarioCreacionId




	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:
	

	











GO
/****** Object:  StoredProcedure [dbo].[p_web_pedido_cliente_ins]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- p_web_pedido_cliente_ins 1,0,'Daniel','8331593533',1,1,1,0,'Monaco','2015','5','Arenal',1,29,'00000'
create proc [dbo].[p_web_pedido_cliente_ins]
@pSucursalId int,
@pPedidoClienteId int out,
@pNombre varchar(100),
@pWhatsApp varchar(20),
@pProductoId int,
@pPedidoConfiguracionId int,
@pTieneCostoEnvio bit,
@pSitioEntregaId int,
@pCalle varchar(50),
@pNumeroExt varchar(10),
@pNumeroInt varchar(10),
@pColonia varchar(50),
@pMunicipioId int,
@pEstadoId int,
@pCP varchar(5)
as

	declare @pClienteId int,
		@pClienteDireccionId int,
		@municipio varchar(100),
		@pedidoClienteId int,
		@pedidoClienteDetId int

	set @pEstadoId = 29 --TAMAULIPAS
	set @pSitioEntregaId = case when isnull(@pSitioEntregaId,0) =0 then null else @pSitioEntregaId end

	set @pMunicipioId = case when @pMunicipioId = 0 then null else @pMunicipioId end

	select @municipio = Nombre
	from cat_municipios
	where MunicipioId = @pMunicipioId

	begin tran
	--Crear Cliente


	select @pClienteId = min(ClienteId)
	from cat_clientes
	where ltrim(Telefono) = ltrim(@pWhatsApp)
	Or LTRIM(Telefono2) = ltrim(@pWhatsApp)

	


	if(
		isnull(@pClienteId,0) = 0
	)
	begin

	

		select @pClienteId = isnull(max(ClienteId),0) + 1
		from cat_clientes



		insert into cat_clientes(
			ClienteId,	Nombre,		RFC,	Calle,
			NumeroExt,	NumeroInt,	Colonia,	CodigoPostal,
			EstadoId,	MunicipioId, PaisId,	Telefono,
			Telefono2,	TipoClienteId,	DiasCredito,	LimiteCredito,
			Activo		
		)
		select @pClienteId,@pNombre, '',	@pCalle,
		@pNumeroExt,	@pNumeroInt, @pColonia, @pCP,
		@pEstadoId,		@pMunicipioId, 1,		@pWhatsApp,
			@pWhatsApp,	null,		null,				null,
			1


		if @@error <> 0
		begin
			rollback tran
			goto fin
		end
	end

	--Crear direcci�n cliente
	if (
		isnull(@pSitioEntregaId,0) = 0 and
		isnull(@pCP,'') <> ''
	)
	begin
		
		select @pClienteDireccionId = MAX(ClienteDireccionId)
		from cat_clientes_direcciones
		where ClienteId = @pClienteId and
		CodigoPostal = @pCP

		IF(
			ISNULL(@pClienteDireccionId ,0) = 0
		)
		BEGIN

			SELECT @pClienteDireccionId = isnull(max(ClienteDireccionId),0) + 1
			FROM cat_clientes_direcciones

			INSERT INTO cat_clientes_direcciones(
				ClienteDireccionId,	ClienteId,			TipoDireccionId,
				Calle,				NumeroInterior,		NumeroExterior,
				Colonia,			Ciudad,				EstadoId,
				PaisId,				CodigoPostal,	CreadoEl
			)
			SELECT @pClienteDireccionId, @pClienteId, 1,
			@pCalle,		@pNumeroInt,				@pNumeroExt,
			@pColonia,			@municipio,				@pEstadoId,
			1,						@pCP,				getdate()

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
			
		END
		else
		begin
			update cat_clientes_direcciones
			set Calle = @pCalle,
				NumeroInterior = @pNumeroInt,
				NumeroExterior = @pNumeroExt,
				Colonia = @pColonia,
				Ciudad = @municipio,
				EstadoId = @pEstadoId,
				CodigoPostal = @pCP
			where ClienteDireccionId = @pClienteDireccionId

			if @@error <> 0
			begin
				rollback tran
				goto fin
			end
		end
	end

	--Crear Pedido
	select @pedidoClienteId = isnull(max(PedidoClienteId),0) + 1
	from doc_pedidos_clientes

	insert into doc_pedidos_clientes(
		PedidoClienteId,	SucursalId,		ClienteId,		EstatusId,	
		FechaEntregaProgramada,HoraEntrega,	FechaEntregaReal,SitioEntregaId,
		ClienteDireccionId,	CreadoEl,		PedidoConfiguracionId
	)
	select @pedidoClienteId,@pSucursalId,	@pClienteId,   1,
		FechaInicioEntrega,		null,		null,			@pSitioEntregaId,
		@pClienteDireccionId,GETDATE(),		@pPedidoConfiguracionId
	from doc_pedidos_configuracion
	where PedidoConfiguracionId = @pPedidoConfiguracionId
	
	if @@error <> 0
	begin
			rollback tran
			goto fin
	end

	select @pedidoClienteDetId = isnull(max(PedidoClienteDetId),0) + 1
	from doc_pedidos_clientes_det

	insert into doc_pedidos_clientes_det(
		PedidoClienteDetId,	PedidoClienteId,	ProductoId,	Cantidad,
		CreadoEl
	)
	select @pedidoClienteDetId,@pedidoClienteId,@pProductoId,1,
	GETDATE()

	if @@error <> 0
	begin
			rollback tran
			goto fin
	end




	commit tran
	
	fin:
	
GO
/****** Object:  StoredProcedure [dbo].[p_web_pedido_producto_agrupado_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_web_pedido_producto_agrupado_sel 1
create proc [dbo].[p_web_pedido_producto_agrupado_sel]
@pPedidoConfiguracionId int
as


	select Color = p.Color,
	Descripcion = pa.Descripcion,
	pa.DescripcionCorta,
	pa.Especificaciones,
	pa.Liquidacion,
	pa.Rating,
	productoImagenId = min(pi.ProductoId),
	NombreFoto = min(p2.Clave),
	PrecioVenta = confd.Precio,
	pa.ProductoAgrupadoId
	from doc_pedidos_configuracion conf
	INNER JOIN doc_pedidos_configuracion_det confd on confd.PedidoConfiguracionId = conf.PedidoConfiguracionId
	inner join cat_productos_agrupados_detalle pad on pad.ProductoId = confd.ProductoId
	
	inner join cat_productos_agrupados pa on pa.ProductoAgrupadoId = pad.ProductoAgrupadoId

	inner join cat_productos_agrupados_detalle pad2 on pad2.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = confd.ProductoId
	LEFT JOIN cat_productos_imagenes pi on pi.ProductoId = pad2.ProductoId
	left join cat_productos p2 on p2.ProductoiD = PI.ProductoId 
	
	where conf.PedidoConfiguracionId = @pPedidoConfiguracionId
	GROUP BY p.Color,pa.Descripcion,pa.DescripcionCorta,pa.Especificaciones,pa.Liquidacion,
	pa.Rating,confd.Precio,pa.ProductoAgrupadoId
	order by pa.Descripcion
	
GO
/****** Object:  StoredProcedure [dbo].[p_web_producto_agrupado_det_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- p_web_producto_agrupado_det_sel 9
CREATE proc [dbo].[p_web_producto_agrupado_det_sel]
@pProductoAgrupadoId int
as

	select pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		Rating = 0,
		Clave = p.Clave,
		p.ProductoId,
		p.Talla,
		Especificaciones = cast(pa.Especificaciones as varchar(500)),
		p.Color,
		P.Color2,
		p.SobrePedido,
		ProductoImagenId =(
			select min(s1.ProductoId)
			from cat_productos s1
			inner join cat_productos_agrupados s2 on s2.productoid=s1.productoId
			inner join cat_productos_imagenes si on si.productoId = s1.ProductoId
			where s2.ProductoAgrupadoId = pa.ProductoAgrupadoId
		),
		pe.ExistenciaTeorica
	from cat_productos_agrupados pa
	inner join cat_productos_agrupados_detalle pad on pad.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = pad.ProductoId and
							p.estatus = 1
	inner join cat_productos_existencias pe on pe.ProductoId = p.ProductoId
	inner join cat_productos_precios pre on pre.IdProducto = p.ProductoId and
									pre.IdPrecio = 1
	left join cat_productos_imagenes pi on pi.ProductoId = p.ProductoId
	where pa.ProductoAgrupadoId = @pProductoAgrupadoId and
	(
		p.SobrePedido = 1 OR
		pe.ExistenciaTeorica > 0
	)
	group by pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		p.Clave,
		p.ProductoId,
		p.Talla,
		p.Color,
		P.Color2,
		p.SobrePedido,
		PE.ExistenciaTeorica,
		pa.Especificaciones
	


GO
/****** Object:  StoredProcedure [dbo].[p_web_productos_sel]    Script Date: 8/24/2019 6:10:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- [p_web_productos_sel] 1,'',0,1,0
CREATE proc [dbo].[p_web_productos_sel]
@pSucursalId int,
@pTexto varchar(200),
@pLinea int,
@pFamilia int,
@pSubfamilia int
as

	select pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio,
		Rating = 0,
		Clave = (
			select min(s1.clave)
			from cat_productos s1
			inner join cat_productos_agrupados s2 on s2.productoid=s1.productoId
			inner join cat_productos_imagenes si on si.productoId = s1.ProductoId
			where s2.ProductoAgrupadoId = pa.ProductoAgrupadoId
		)
	from cat_productos_agrupados pa
	inner join cat_productos_agrupados_detalle pad on pad.ProductoAgrupadoId = pa.ProductoAgrupadoId
	inner join cat_productos p on p.ProductoId = pad.ProductoId and p.Estatus = 1
	
								
	inner join cat_productos_existencias pe on pe.ProductoId = p.ProductoId
	inner join cat_productos_precios pre on pre.IdProducto = p.ProductoId and
									pre.IdPrecio = 1
	where pe.SucursalId = @pSucursalId and
	(
		pa.Descripcion like '%'+isnull(@pTexto,'')+'%'
	) and
	(
		@pFamilia in(0,p.ClaveFamilia)
		OR
		(
			@pFamilia = 9999 --Liquidacion
			and 
			p.Liquidacion = 1
		)
	)
	group by pa.ProductoAgrupadoId,
		pa.Descripcion,
		pa.DescripcionCorta,
		pre.Precio
	
	



GO


fin_ERPProd_data:



