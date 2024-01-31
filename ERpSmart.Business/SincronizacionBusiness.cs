﻿using ConexionBD;
using ERP.Models.Sincronizacion;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ERP.Business
{
    public class SincronizacionBusiness:BusinessObject
    {
        
        SisCuentaBusiness sisCuenta;
        ERPProdEntities contextNube;
        ERPProdEntities contextLocal;
        EntityConnectionStringBuilder builder1;
        EntityConnectionStringBuilder builder2;
        int sucursalId = 0;
        int err;
        public List<SincronizaResultadoModel> lstResultado;
        //public SincronizacionBusiness()
        //{
        //    sisCuenta = new SisCuentaBusiness();
        //    contextDestino = new ERPProdEntities();
        //    contextOrigen = new ERPProdEntities(ConexionBD.Sistema.scMain);

        //}


       
        public SincronizacionBusiness()
        {
            string directorioRaiz = AppDomain.CurrentDomain.BaseDirectory;
            sisCuenta = new SisCuentaBusiness();
            builder1 = new EntityConnectionStringBuilder(ConfigurationManager.ConnectionStrings["ERPProdCloudMater"].ConnectionString);
             builder2 = new EntityConnectionStringBuilder(ConfigurationManager.ConnectionStrings["ERPProdEntities"].ConnectionString);



            contextNube = new ERPProdEntities(builder1.ProviderConnectionString);
            contextLocal = new ERPProdEntities(builder2.ProviderConnectionString);

            lstResultado = new List<SincronizaResultadoModel>();

        }

        public string ImportarALocal()
        {
            try
            {
                var cuenta = sisCuenta.ObtieneArchivoConfiguracionCuenta();
                sucursalId = cuenta.ClaveSucursal??0;

                List<cat_empresas> lstEmpresasOri = contextNube.cat_empresas.ToList();
                List<cat_cajas> lstCajasOri = contextNube.cat_cajas.ToList();
                List<cat_configuracion> lstConfiguracion = contextNube.cat_configuracion.ToList();
                List<cat_tipos_cajas> lsTiposCajas = contextNube.cat_tipos_cajas.ToList();
                List<cat_sucursales> sucursalOri = contextNube.cat_sucursales.ToList();
                List<cat_usuarios> lstUsuariosOri = contextNube.cat_usuarios
                    .Where(w => w.cat_usuarios_sucursales.Where(s1 => s1.SucursalId == sucursalId).Count() > 0 || w.NombreUsuario.Contains("ADMIN")).ToList();
                List<cat_usuarios_sucursales> lstUsuariosSucursalesOri = contextNube.cat_usuarios_sucursales
                   .Where(w => w.SucursalId == sucursalId).ToList();
                List<cat_familias> lstFamiliasOri = contextNube.cat_familias.ToList();
                List<cat_conceptos> lstConceptos = contextNube.cat_conceptos.ToList();

                List<cat_centro_costos> lstCentroCostos = contextNube.cat_centro_costos.ToList();
                List<cat_gastos> lstCatGastos = contextNube.cat_gastos.ToList();
                List<cat_subfamilias> lstSubFamiliasOri = contextNube.cat_subfamilias.ToList();
                List<cat_lineas> lstLineasOri = contextNube.cat_lineas.ToList();
                List<cat_formas_pago> lstFormasPago = contextNube.cat_formas_pago.ToList();
                List<cat_productos> lstProductosOri = contextNube.cat_productos.ToList();
                List<cat_tipos_pedido> lstTiposPedido = contextNube.cat_tipos_pedido.ToList();
                List<cat_tipos_movimiento_inventario> lstTiposMov = contextNube.cat_tipos_movimiento_inventario.ToList();
                List<cat_productos_precios> lstProductosPrecioOri = contextNube
                    .cat_productos_precios.ToList();
                List<rh_empleados> lstRHEmpleados = contextNube.rh_empleados.ToList();
                List<rh_puestos> lstPuestos = contextNube.rh_puestos.ToList();
                List<cat_sucursales_productos> lstSucursalesProductos = contextNube.cat_sucursales_productos.Where(w=> w.SucursalId == sucursalId).ToList();
                List<cat_marcas> lstMarcas = contextNube.cat_marcas.ToList();
                List<cat_unidadesmed> lstUnidadesMedida = contextNube.cat_unidadesmed.ToList();
                List<cat_precios> lstPrecios = contextNube.cat_precios.ToList();
                List<cat_clientes> lstClientes = contextNube.cat_clientes.Where(w=> w.SucursalBaseId == sucursalId).ToList();
                List<doc_precios_especiales> lstPreciosEspeciales = contextNube.doc_precios_especiales.Where(w => w.SucursalId == sucursalId).ToList();
                List<doc_precios_especiales_detalle> lstPreciosEspecialesDetalle = contextNube.doc_precios_especiales_detalle.Where(w => w.doc_precios_especiales.SucursalId == sucursalId).ToList();
                List<sis_preferencias> lstPreferencias = contextNube.sis_preferencias.ToList();
                List<sis_preferencias_empresa> lstPreferenciasEmpresa = contextNube.sis_preferencias_empresa.ToList();
                List<sis_preferencias_sucursales> lstPreferenciasSucursal = contextNube.sis_preferencias_sucursales.Where(W=> W.SucursalId == sucursalId).ToList();
                List<doc_clientes_productos_precios> lstClientesProductosPrecos = contextNube.doc_clientes_productos_precios.Where(W => W.cat_clientes.SucursalBaseId == sucursalId).ToList();
                List<cat_productos_principales> lstProductosPrincipales = contextNube.cat_productos_principales.Where(W => W.SucursalId == 1).ToList();
                List<doc_productos_sobrantes_config> lstProductosSobrantesConfig = contextNube.doc_productos_sobrantes_config.ToList();


                ImportEmpresas(ref contextLocal, lstEmpresasOri);
                ImportSucursales(ref contextLocal, sucursalOri);
                ImportConfiguraciones(lstConfiguracion);
                ImportPreferencias(ref contextLocal, lstPreferencias);
                ImportPreferenciasEmpresa(ref contextLocal, lstPreferenciasEmpresa);
                ImportPreferenciasSucursales(ref contextLocal, lstPreferenciasSucursal);
                ImportTiposCajas(ref contextLocal, lsTiposCajas);
                ImportTiposMovimientoInventario(lstTiposMov);
                ImportConceptos(lstConceptos);
                ImportCentroCostos(lstCentroCostos);
                ImportcatGastos(lstCatGastos);

                ImportCajas(ref contextLocal, lstCajasOri);
                ImportPuestos(ref contextLocal, lstPuestos);
                ImportEmpleados(ref contextLocal, lstRHEmpleados);
                ImportUsuarios(ref contextLocal, lstUsuariosOri);
                ImportUsuariosSucursales(ref contextLocal, lstUsuariosSucursalesOri);
                ImportLineas(ref contextLocal, lstLineasOri);
                ImportFamilias(ref contextLocal, lstFamiliasOri);
                ImportTiposPedido(lstTiposPedido);
                ImportMarcas(ref contextLocal, lstMarcas);
                ImportSubFamilias(ref contextLocal, lstSubFamiliasOri);
                ImportFormasPago(lstFormasPago);
                ImportUnidadesMed(ref contextLocal, lstUnidadesMedida);
                ImportPrecios(ref contextLocal, lstPrecios);
                ImportProductos(ref contextLocal, lstProductosOri);
                ImportProductosPrincipales(lstProductosPrincipales);
                ImportProductosPrecios(ref contextLocal, lstProductosPrecioOri);
                ImportSucursalesProductos(ref contextLocal, lstSucursalesProductos);
                ImportClientes(ref contextLocal, lstClientes);
                ImportClientesProductosPrecios(lstClientesProductosPrecos);
                ImportPreciosEspeciales(ref contextLocal, lstPreciosEspeciales, lstPreciosEspecialesDetalle);
                ImportProductosSobrantesConfig(lstProductosSobrantesConfig);
                return "";
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.Importar",
                                                          ex);

                return "Ocurrió un error al importar, revise el registro de bitácora [" + err.ToString() + "]";

            }
        }

        public bool ImportConfiguraciones(List<cat_configuracion> lstConfiguraciones)
        {
            SqlConnection connection = new SqlConnection(builder2.ProviderConnectionString);
            try
            {
               
                connection.Open();

                foreach (cat_configuracion itemConfiguracion in lstConfiguraciones)
                {
                    using (SqlCommand cmd = new SqlCommand("p_cat_configuracion_ins_upd", connection))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Parámetros del procedimiento almacenado
                        cmd.Parameters.AddWithValue("@pConfiguradorId", itemConfiguracion.ConfiguradorId);
                        cmd.Parameters.AddWithValue("@pUnaFormaPago", itemConfiguracion.UnaFormaPago);
                        cmd.Parameters.AddWithValue("@pMasUnaFormaPago", itemConfiguracion.MasUnaFormaPago);
                        cmd.Parameters.AddWithValue("@pCosteoUEPS", itemConfiguracion.CosteoUEPS);
                        cmd.Parameters.AddWithValue("@pCosteoPEPS", itemConfiguracion.CosteoPEPS);
                        cmd.Parameters.AddWithValue("@pCosteoPromedio", itemConfiguracion.CosteoPromedio);
                        cmd.Parameters.AddWithValue("@pAfectarInventarioLinea", itemConfiguracion.AfectarInventarioLinea);
                        cmd.Parameters.AddWithValue("@pAfectarInventarioManual", itemConfiguracion.AfectarInventarioManual);
                        cmd.Parameters.AddWithValue("@pAfectarInventarioCorte", itemConfiguracion.AfectarInventarioCorte);
                        cmd.Parameters.AddWithValue("@pEnlazarPuntoVentaInventario", itemConfiguracion.EnlazarPuntoVentaInventario);
                        cmd.Parameters.AddWithValue("@pCajeroIncluirDetalleVenta", itemConfiguracion.CajeroIncluirDetalleVenta);
                        cmd.Parameters.AddWithValue("@pCajeroReqClaveSupervisor", itemConfiguracion.CajeroReqClaveSupervisor);
                        cmd.Parameters.AddWithValue("@pSuperIncluirDetalleVenta", itemConfiguracion.SuperIncluirDetalleVenta);
                        cmd.Parameters.AddWithValue("@pSuperIncluirVentaTel", itemConfiguracion.SuperIncluirVentaTel);
                        cmd.Parameters.AddWithValue("@pSuperIncluirDetGastos", itemConfiguracion.SuperIncluirDetGastos);
                        cmd.Parameters.AddWithValue("@pSuperEmail1", itemConfiguracion.SuperEmail1);
                        cmd.Parameters.AddWithValue("@pSuperEmail2", itemConfiguracion.SuperEmail2);
                        cmd.Parameters.AddWithValue("@pSuperEmail3", itemConfiguracion.SuperEmail3);
                        cmd.Parameters.AddWithValue("@pSuperEmail4", itemConfiguracion.SuperEmail4);
                        cmd.Parameters.AddWithValue("@pRetiroMontoEfec", itemConfiguracion.RetiroMontoEfec);
                        cmd.Parameters.AddWithValue("@pRetiroLectura", itemConfiguracion.RetiroLectura);
                        cmd.Parameters.AddWithValue("@pRetiroEscritura", itemConfiguracion.RetiroEscritura);
                        cmd.Parameters.AddWithValue("@pNombreImpresora", itemConfiguracion.NombreImpresora);
                        cmd.Parameters.AddWithValue("@pHardwareCaracterCajon", itemConfiguracion.HardwareCaracterCajon);
                        cmd.Parameters.AddWithValue("@pEmpleadoPorcDescuento", itemConfiguracion.EmpleadoPorcDescuento);
                        cmd.Parameters.AddWithValue("@pEmpleadoGlobal", itemConfiguracion.EmpleadoGlobal);
                        cmd.Parameters.AddWithValue("@pEmpleadoIndividual", itemConfiguracion.EmpleadoIndividual);
                        cmd.Parameters.AddWithValue("@pMontoImpresionTicket", itemConfiguracion.MontoImpresionTicket);
                        cmd.Parameters.AddWithValue("@pApartadoAnticipo1", itemConfiguracion.ApartadoAnticipo1);
                        cmd.Parameters.AddWithValue("@pApartadoAnticipoHasta1", itemConfiguracion.ApartadoAnticipoHasta1);
                        cmd.Parameters.AddWithValue("@pApartadoAnticipo2", itemConfiguracion.ApartadoAnticipo2);
                        cmd.Parameters.AddWithValue("@pApatadoAnticipoEnAdelante2", itemConfiguracion.ApatadoAnticipoEnAdelante2);
                        cmd.Parameters.AddWithValue("@pPorcentajeUtilidadProd", itemConfiguracion.PorcentajeUtilidadProd);
                        cmd.Parameters.AddWithValue("@pDesgloceMontoTicket", itemConfiguracion.DesgloceMontoTicket);
                        cmd.Parameters.AddWithValue("@pRetiroReqClaveSup", itemConfiguracion.RetiroReqClaveSup);
                        cmd.Parameters.AddWithValue("@pCajDeclaracionFondoCorte", itemConfiguracion.CajDeclaracionFondoCorte);
                        cmd.Parameters.AddWithValue("@pSupDeclaracionFondoCorte", itemConfiguracion.SupDeclaracionFondoCorte);
                        cmd.Parameters.AddWithValue("@pvistaPreviaImpresion", itemConfiguracion.vistaPreviaImpresion);
                        cmd.Parameters.AddWithValue("@pCajeroCorteDetGasto", itemConfiguracion.CajeroCorteDetGasto);
                        cmd.Parameters.AddWithValue("@pSupCorteDetGasto", itemConfiguracion.SupCorteDetGasto);
                        cmd.Parameters.AddWithValue("@pCajeroCorteCancelaciones", itemConfiguracion.CajeroCorteCancelaciones);
                        cmd.Parameters.AddWithValue("@pSupCorteCancelaciones", itemConfiguracion.SupCorteCancelaciones);
                        cmd.Parameters.AddWithValue("@pDevDiasVale", itemConfiguracion.DevDiasVale);
                        cmd.Parameters.AddWithValue("@pDevDiasGarantia", itemConfiguracion.DevDiasGarantia);
                        cmd.Parameters.AddWithValue("@pDevHorasGarantia", itemConfiguracion.DevHorasGarantia);
                        cmd.Parameters.AddWithValue("@pApartadoDiasLiq", itemConfiguracion.ApartadoDiasLiq);
                        cmd.Parameters.AddWithValue("@pApartadoDiasProrroga", itemConfiguracion.ApartadoDiasProrroga);
                        cmd.Parameters.AddWithValue("@pReqClaveSupReimpresionTicketPV", itemConfiguracion.ReqClaveSupReimpresionTicketPV);
                        cmd.Parameters.AddWithValue("@pReqClaveSupCancelaTicketPV", itemConfiguracion.ReqClaveSupCancelaTicketPV);
                        cmd.Parameters.AddWithValue("@pReqClaveSupGastosPV", itemConfiguracion.ReqClaveSupGastosPV);
                        cmd.Parameters.AddWithValue("@pReqClaveSupDevolucionPV", itemConfiguracion.ReqClaveSupDevolucionPV);
                        cmd.Parameters.AddWithValue("@pReqClaveSupApartadoPV", itemConfiguracion.ReqClaveSupApartadoPV);
                        cmd.Parameters.AddWithValue("@pReqClaveSupExistenciaPV", itemConfiguracion.ReqClaveSupExistenciaPV);
                        cmd.Parameters.AddWithValue("@pCorteCajaIncluirExistencia", itemConfiguracion.CorteCajaIncluirExistencia);
                        cmd.Parameters.AddWithValue("@pImprimirTicketMediaCarta", itemConfiguracion.ImprimirTicketMediaCarta);
                        cmd.Parameters.AddWithValue("@pSolicitarComanda", itemConfiguracion.SolicitarComanda);
                        cmd.Parameters.AddWithValue("@pGiro", itemConfiguracion.Giro);
                        cmd.Parameters.AddWithValue("@pPedidoAnticipoPorc", itemConfiguracion.PedidoAnticipoPorc);
                        cmd.Parameters.AddWithValue("@pPedidoPoliticaId", itemConfiguracion.PedidoPoliticaId);

                        // Ejecuta el procedimiento almacenado
                        cmd.ExecuteNonQuery();
                    }
                }

                connection.Close();

                lstResultado.Add(new SincronizaResultadoModel() {Tipo = "Importar", Entidad = "Configuraciones",Exitoso = true });
                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                             "ERP",
                                                             "ERP.Business.SincronizacionBusiness.ImportConfiguraciones",
                                                             ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Configuraciones", Exitoso = false,Detalle = String.Format("Bitácora error:{0}",err.ToString()) });
                connection.Close();
                // Manejo de errores
                return false;
            }
            
        }


        public bool ImportCajas(ref ERPProdEntities context, List<cat_cajas> lstCajas)
        {
            try
            {
                foreach (cat_cajas itemCaja in lstCajas)
                {
                    cat_cajas cajaSinc = context.cat_cajas
                        
                        .Where(w => w.Clave == itemCaja.Clave)
                        .FirstOrDefault();

                    if (cajaSinc != null)
                    {
                        cajaSinc.Descripcion = itemCaja.Descripcion;
                        cajaSinc.Ubicacion = itemCaja.Ubicacion;
                        cajaSinc.Estatus = itemCaja.Estatus;
                        cajaSinc.Empresa = itemCaja.Empresa;
                        cajaSinc.Sucursal = itemCaja.Sucursal;
                        cajaSinc.TipoCajaId = itemCaja.TipoCajaId;
                        context.SaveChanges();
                    }
                    else
                    {
                        cajaSinc = new cat_cajas();
                        cajaSinc.Clave = itemCaja.Clave;
                        cajaSinc.Descripcion = itemCaja.Descripcion;
                        cajaSinc.Ubicacion = itemCaja.Ubicacion;
                        cajaSinc.Estatus = itemCaja.Estatus;
                        cajaSinc.Empresa = itemCaja.Empresa;
                        cajaSinc.Sucursal = itemCaja.Sucursal;
                        cajaSinc.TipoCajaId = itemCaja.TipoCajaId;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_cajas.Add(cajaSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Cajas", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportCajas",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Cajas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });
                return false;
            }
        }

        public bool ImportEmpresas(ref ERPProdEntities context, List<cat_empresas> lstEmpresasOri)
        {
            try
            {
                
                foreach (cat_empresas itemEmpresa in lstEmpresasOri)
                {
                    cat_empresas empresaSinc = context.cat_empresas
                        .Where(w => w.Clave == itemEmpresa.Clave).FirstOrDefault();

                    if(empresaSinc != null)
                    {
                        empresaSinc.Nombre = itemEmpresa.Nombre;
                        empresaSinc.NombreComercial = itemEmpresa.NombreComercial;
                        empresaSinc.RFC = itemEmpresa.RFC;
                        empresaSinc.Estatus = itemEmpresa.Estatus;
                        empresaSinc.Logo = itemEmpresa.Logo;
                        context.SaveChanges();
                    }
                    else
                    {
                        empresaSinc = new cat_empresas();
                        empresaSinc.Nombre = itemEmpresa.Nombre;
                        empresaSinc.NombreComercial = itemEmpresa.NombreComercial;
                        empresaSinc.RFC = itemEmpresa.RFC;
                        empresaSinc.Estatus = itemEmpresa.Estatus;
                        empresaSinc.Logo = itemEmpresa.Logo;
                        empresaSinc.Clave = itemEmpresa.Clave;

                        context.cat_empresas.Add(empresaSinc);
                        context.SaveChanges();
                    }
                    lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Empresas", Exitoso = true, Detalle = "" });

                }

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportEmpresas",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Empresas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }

        public bool ImportSucursales(ref ERPProdEntities context, List<cat_sucursales> lstSucursales)
        {
            try
            {
                foreach (cat_sucursales itemSucursal in lstSucursales)
                {
                    cat_sucursales sucursalSinc = context.cat_sucursales
                        
                        .Where(w => w.Clave == itemSucursal.Clave)
                        .FirstOrDefault();

                    if (sucursalSinc != null)
                    {
                        sucursalSinc.Empresa = itemSucursal.Empresa;
                        sucursalSinc.Calle = itemSucursal.Calle;
                        sucursalSinc.Colonia = itemSucursal.Colonia;
                        sucursalSinc.NoExt = itemSucursal.NoExt;
                        sucursalSinc.NoInt = itemSucursal.NoInt;
                        sucursalSinc.Ciudad = itemSucursal.Ciudad;
                        sucursalSinc.Estado = itemSucursal.Estado;
                        sucursalSinc.Pais = itemSucursal.Pais;
                        sucursalSinc.Telefono1 = itemSucursal.Telefono1;
                        sucursalSinc.Telefono2 = itemSucursal.Telefono2;
                        sucursalSinc.Email = itemSucursal.Email;
                        sucursalSinc.Estatus = itemSucursal.Estatus;
                        sucursalSinc.NombreSucursal = itemSucursal.NombreSucursal;
                        sucursalSinc.CP = itemSucursal.CP;
                        sucursalSinc.ServidorMailSMTP = itemSucursal.ServidorMailSMTP;
                        sucursalSinc.ServidorMailFrom = itemSucursal.ServidorMailFrom;
                        sucursalSinc.ServidorMailPort = itemSucursal.ServidorMailPort;
                        sucursalSinc.ServidorMailPassword = itemSucursal.ServidorMailPassword;

                        // Puedes asignar otras propiedades según sea necesario

                        context.SaveChanges();
                    }
                    else
                    {
                        sucursalSinc = new cat_sucursales();

                        sucursalSinc.Clave = itemSucursal.Clave;
                        sucursalSinc.Empresa = itemSucursal.Empresa;
                        sucursalSinc.Calle = itemSucursal.Calle;
                        sucursalSinc.Colonia = itemSucursal.Colonia;
                        sucursalSinc.NoExt = itemSucursal.NoExt;
                        sucursalSinc.NoInt = itemSucursal.NoInt;
                        sucursalSinc.Ciudad = itemSucursal.Ciudad;
                        sucursalSinc.Estado = itemSucursal.Estado;
                        sucursalSinc.Pais = itemSucursal.Pais;
                        sucursalSinc.Telefono1 = itemSucursal.Telefono1;
                        sucursalSinc.Telefono2 = itemSucursal.Telefono2;
                        sucursalSinc.Email = itemSucursal.Email;
                        sucursalSinc.Estatus = itemSucursal.Estatus;
                        sucursalSinc.NombreSucursal = itemSucursal.NombreSucursal;
                        sucursalSinc.CP = itemSucursal.CP;
                        sucursalSinc.ServidorMailSMTP = itemSucursal.ServidorMailSMTP;
                        sucursalSinc.ServidorMailFrom = itemSucursal.ServidorMailFrom;
                        sucursalSinc.ServidorMailPort = itemSucursal.ServidorMailPort;
                        sucursalSinc.ServidorMailPassword = itemSucursal.ServidorMailPassword;

                        // Puedes asignar otras propiedades según sea necesario

                        context.cat_sucursales.Add(sucursalSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Sucursales", Exitoso = true, Detalle = "" });
                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportSucursales",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Sucursales", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        public bool ImportUsuarios(ref ERPProdEntities context, List<cat_usuarios> lstUsuarios)
        {
            try
            {
                foreach (cat_usuarios itemUsuario in lstUsuarios)
                {
                    cat_usuarios usuarioSinc = context.cat_usuarios
                        
                        .Where(w => w.IdUsuario == itemUsuario.IdUsuario).FirstOrDefault();

                    if (usuarioSinc != null)
                    {
                        usuarioSinc.Password = itemUsuario.Password;
                        usuarioSinc.PasswordSupervisor = itemUsuario.PasswordSupervisor;
                        usuarioSinc.PasswordSupervisorCajero = itemUsuario.PasswordSupervisorCajero;
                        usuarioSinc.Activo = itemUsuario.Activo;
                        usuarioSinc.CajaDefaultId = itemUsuario.CajaDefaultId;
                        usuarioSinc.EsSupervisor = itemUsuario.EsSupervisor;
                        usuarioSinc.EsSupervisorCajero = itemUsuario.EsSupervisorCajero;
                        usuarioSinc.NombreUsuario = itemUsuario.NombreUsuario;
                        usuarioSinc.IdSucursal = itemUsuario.IdSucursal;
                        usuarioSinc.Email = itemUsuario.Email;
                        context.SaveChanges();

                    }
                    else {
                        usuarioSinc = new cat_usuarios();

                        usuarioSinc.Password = itemUsuario.Password;
                        usuarioSinc.PasswordSupervisor = itemUsuario.PasswordSupervisor;
                        usuarioSinc.PasswordSupervisorCajero = itemUsuario.PasswordSupervisorCajero;
                        usuarioSinc.Activo = itemUsuario.Activo;
                        usuarioSinc.CajaDefaultId = itemUsuario.CajaDefaultId;
                        usuarioSinc.EsSupervisor = itemUsuario.EsSupervisor;
                        usuarioSinc.EsSupervisorCajero = itemUsuario.EsSupervisorCajero;
                        usuarioSinc.NombreUsuario = itemUsuario.NombreUsuario;
                        usuarioSinc.CreadoEl = itemUsuario.CreadoEl;
                        usuarioSinc.IdEmpleado = itemUsuario.IdEmpleado;
                        usuarioSinc.IdUsuario = itemUsuario.IdUsuario;
                        usuarioSinc.IdSucursal = itemUsuario.IdSucursal;
                        usuarioSinc.Email = itemUsuario.Email;

                        context.cat_usuarios.Add(usuarioSinc);
                        context.SaveChanges();

                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Usuarios", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {

                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportUsuarios",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Usuarios", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportUsuariosSucursales(ref ERPProdEntities context, List<cat_usuarios_sucursales> lstUsuariosSucursales)
        {
            try
            {
                foreach (cat_usuarios_sucursales itemUsuario in lstUsuariosSucursales)
                {
                    cat_usuarios_sucursales usuarioSinc = context.cat_usuarios_sucursales
                        
                        .Where(w => w.SucursalId == itemUsuario.SucursalId && 
                        w.UsuarioId == itemUsuario.UsuarioId).FirstOrDefault();

                    if (usuarioSinc == null)
                    {
                        usuarioSinc = new cat_usuarios_sucursales();

                        usuarioSinc.CreadoEl = DateTime.Now;
                        usuarioSinc.SucursalId = itemUsuario.SucursalId;
                        usuarioSinc.UsuarioId = itemUsuario.UsuarioId;

                        context.cat_usuarios_sucursales.Add(usuarioSinc);
                        

                    }
                  
                }

                context.SaveChanges();

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Usuarios Sucursales", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {

                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportUsuariosSucursales",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Usuarios Sucursales", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportLineas(ref ERPProdEntities context, List<cat_lineas> lstLineasOri)
        {
            try
            {

                foreach (cat_lineas itemLinea in lstLineasOri)
                {
                    cat_lineas lineaSinc = context.cat_lineas
                        .Where(w => w.Clave == itemLinea.Clave).FirstOrDefault();

                    if (lineaSinc != null)
                    {
                        lineaSinc.Descripcion = itemLinea.Descripcion;
                        lineaSinc.Empresa = itemLinea.Empresa;
                        lineaSinc.Estatus = itemLinea.Estatus;
                        lineaSinc.Sucursal = itemLinea.Sucursal;                       

                        context.SaveChanges();
                    }
                    else
                    {
                        lineaSinc = new cat_lineas();
                        lineaSinc.Descripcion = itemLinea.Descripcion;
                        lineaSinc.Empresa = itemLinea.Empresa;
                        lineaSinc.Estatus = itemLinea.Estatus;
                        lineaSinc.Sucursal = itemLinea.Sucursal;
                        lineaSinc.Clave = itemLinea.Clave;
                        context.cat_lineas.Add(lineaSinc);
                        context.SaveChanges();
                    }


                }
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Líneas", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportLineas",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Líneas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }

        public bool ImportFamilias(ref ERPProdEntities context, List<cat_familias> lstFamiliasOri)
        {
            try
            {

                foreach (cat_familias itemFamilia in lstFamiliasOri)
                {
                    cat_familias familiaSinc = context.cat_familias
                        .Where(w => w.Clave == itemFamilia.Clave).FirstOrDefault();

                    if (familiaSinc != null)
                    {
                        familiaSinc.Descripcion = itemFamilia.Descripcion;
                        familiaSinc.Empresa = itemFamilia.Empresa;
                        familiaSinc.Estatus = itemFamilia.Estatus;
                        familiaSinc.Orden = itemFamilia.Orden;
                        familiaSinc.ProductoPortadaId = itemFamilia.ProductoPortadaId;
                        familiaSinc.Sucursal = itemFamilia.Sucursal;
                        
                        context.SaveChanges();
                    }
                    else
                    {
                        familiaSinc = new cat_familias();
                        familiaSinc.Descripcion = itemFamilia.Descripcion;
                        familiaSinc.Empresa = itemFamilia.Empresa;
                        familiaSinc.Estatus = itemFamilia.Estatus;
                        familiaSinc.Orden = itemFamilia.Orden;
                        familiaSinc.ProductoPortadaId = itemFamilia.ProductoPortadaId;
                        familiaSinc.Sucursal = itemFamilia.Sucursal;
                        familiaSinc.Clave = itemFamilia.Clave;
                        context.cat_familias.Add(familiaSinc);
                        context.SaveChanges();
                    }


                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Familias", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportFamilias",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Familias", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }

        public bool ImportSubFamilias(ref ERPProdEntities context, List<cat_subfamilias> lstSubFamiliasOri)
        {
            try
            {

                foreach (cat_subfamilias itemSubFamilia in lstSubFamiliasOri)
                {
                    cat_subfamilias subfamiliaSinc = context.cat_subfamilias
                        .Where(w => w.Clave == itemSubFamilia.Clave).FirstOrDefault();

                    if (subfamiliaSinc != null)
                    {
                        subfamiliaSinc.Descripcion = itemSubFamilia.Descripcion;
                        subfamiliaSinc.Empresa = itemSubFamilia.Empresa;
                        subfamiliaSinc.Estatus = itemSubFamilia.Estatus;
                        subfamiliaSinc.Familia = itemSubFamilia.Familia;
                        subfamiliaSinc.Sucursal = itemSubFamilia.Sucursal;                       

                        context.SaveChanges();
                    }
                    else
                    {
                        subfamiliaSinc = new cat_subfamilias();

                        subfamiliaSinc.Descripcion = itemSubFamilia.Descripcion;
                        subfamiliaSinc.Empresa = itemSubFamilia.Empresa;
                        subfamiliaSinc.Estatus = itemSubFamilia.Estatus;
                        subfamiliaSinc.Familia = itemSubFamilia.Familia;
                        subfamiliaSinc.Sucursal = itemSubFamilia.Sucursal;
                        subfamiliaSinc.Clave = itemSubFamilia.Clave;
                        context.cat_subfamilias.Add(subfamiliaSinc);
                        context.SaveChanges();
                    }


                }
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Subfamilias", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportSubFamilias",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Subfamilias", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }

        public bool ImportProductos(ref ERPProdEntities context, List<cat_productos> lstProductosOri)
        {
            try
            {

                foreach (cat_productos itemProducto in lstProductosOri)
                {
                    cat_productos productosSinc = context.cat_productos
                        .AsNoTracking()
                        .Where(w => w.ProductoId == itemProducto.ProductoId).FirstOrDefault();

                    if (productosSinc != null)
                    {
                        productosSinc.ClaveAlmacen = itemProducto.ClaveAlmacen;
                        productosSinc.ClaveAnden = itemProducto.ClaveAnden;
                        productosSinc.ClaveFamilia = itemProducto.ClaveFamilia;
                        productosSinc.ClaveInventariadoPor = itemProducto.ClaveInventariadoPor;
                        productosSinc.ClaveLinea = itemProducto.ClaveLinea;
                        productosSinc.ClaveLote = itemProducto.ClaveLote;
                        productosSinc.ClaveMarca = itemProducto.ClaveMarca;
                        productosSinc.ClaveSubFamilia = itemProducto.ClaveSubFamilia;
                        productosSinc.ClaveUnidadMedida = itemProducto.ClaveUnidadMedida;
                        productosSinc.ClaveVendidaPor = itemProducto.ClaveVendidaPor;
                        productosSinc.CodigoBarras = itemProducto.CodigoBarras;
                        productosSinc.Color = itemProducto.Color;
                        productosSinc.Color2 = itemProducto.Color2;
                        productosSinc.ContenidoCaja = itemProducto.ContenidoCaja;
                        productosSinc.Descripcion = itemProducto.Descripcion;
                        productosSinc.DescripcionCorta = itemProducto.DescripcionCorta;
                        productosSinc.Empresa = itemProducto.Empresa;
                        productosSinc.Especificaciones = itemProducto.Especificaciones;
                        productosSinc.Estatus = itemProducto.Estatus;
                        productosSinc.FechaAlta = itemProducto.FechaAlta;
                        productosSinc.FechaCaducidad = itemProducto.FechaCaducidad;
                        productosSinc.Foto = itemProducto.Foto;
                        productosSinc.Inventariable = itemProducto.Inventariable;
                        productosSinc.Liquidacion = itemProducto.Liquidacion;
                        productosSinc.MateriaPrima = itemProducto.MateriaPrima;
                        productosSinc.MaximoInventario = itemProducto.MaximoInventario;
                        productosSinc.MinimoInventario = itemProducto.MinimoInventario;
                        productosSinc.NumeroDecimales = itemProducto.NumeroDecimales;
                        productosSinc.PorcUtilidad = itemProducto.PorcUtilidad;
                        productosSinc.ProdParaVenta = itemProducto.ProdParaVenta;
                        productosSinc.ProductoTerminado = itemProducto.ProductoTerminado;
                        productosSinc.ProdVtaBascula = itemProducto.ProdVtaBascula;
                        productosSinc.Seriado = itemProducto.Seriado;
                        productosSinc.SobrePedido = itemProducto.SobrePedido;
                        productosSinc.Sucursal = itemProducto.Sucursal;
                        productosSinc.Clave = itemProducto.Clave;

                        context.SaveChanges();
                    }
                    else
                    {
                        productosSinc = new cat_productos();
                        productosSinc.ClaveAlmacen = itemProducto.ClaveAlmacen;
                        productosSinc.ClaveAnden = itemProducto.ClaveAnden;
                        productosSinc.ClaveFamilia = itemProducto.ClaveFamilia;
                        productosSinc.ClaveInventariadoPor = itemProducto.ClaveInventariadoPor;
                        productosSinc.ClaveLinea = itemProducto.ClaveLinea;
                        productosSinc.ClaveLote = itemProducto.ClaveLote;
                        productosSinc.ClaveMarca = itemProducto.ClaveMarca;
                        productosSinc.ClaveSubFamilia = itemProducto.ClaveSubFamilia;
                        productosSinc.ClaveUnidadMedida = itemProducto.ClaveUnidadMedida;
                        productosSinc.ClaveVendidaPor = itemProducto.ClaveVendidaPor;
                        productosSinc.CodigoBarras = itemProducto.CodigoBarras;
                        productosSinc.Color = itemProducto.Color;
                        productosSinc.Color2 = itemProducto.Color2;
                        productosSinc.ContenidoCaja = itemProducto.ContenidoCaja;
                        productosSinc.Descripcion = itemProducto.Descripcion;
                        productosSinc.DescripcionCorta = itemProducto.DescripcionCorta;
                        productosSinc.Empresa = itemProducto.Empresa;
                        productosSinc.Especificaciones = itemProducto.Especificaciones;
                        productosSinc.Estatus = itemProducto.Estatus;
                        productosSinc.FechaAlta = itemProducto.FechaAlta;
                        productosSinc.FechaCaducidad = itemProducto.FechaCaducidad;
                        productosSinc.Foto = itemProducto.Foto;
                        productosSinc.Inventariable = itemProducto.Inventariable;
                        productosSinc.Liquidacion = itemProducto.Liquidacion;
                        productosSinc.MateriaPrima = itemProducto.MateriaPrima;
                        productosSinc.MaximoInventario = itemProducto.MaximoInventario;
                        productosSinc.MinimoInventario = itemProducto.MinimoInventario;
                        productosSinc.NumeroDecimales = itemProducto.NumeroDecimales;
                        productosSinc.PorcUtilidad = itemProducto.PorcUtilidad;
                        productosSinc.ProdParaVenta = itemProducto.ProdParaVenta;
                        productosSinc.ProductoTerminado = itemProducto.ProductoTerminado;
                        productosSinc.ProdVtaBascula = itemProducto.ProdVtaBascula;
                        productosSinc.Seriado = itemProducto.Seriado;
                        productosSinc.SobrePedido = itemProducto.SobrePedido;
                        productosSinc.Sucursal = itemProducto.Sucursal;
                        productosSinc.ProductoId = itemProducto.ProductoId;
                        productosSinc.Clave = itemProducto.Clave;
                        context.cat_productos.Add(productosSinc);
                        context.SaveChanges();
                    }


                }
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Productos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportProductos",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Productos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }

        public bool ImportProductosPrecios(ref ERPProdEntities context, List<cat_productos_precios> lstProductosPreciosOri)
        {
            try
            {

                foreach (cat_productos_precios itemProductoPrecio in lstProductosPreciosOri)
                {
                    cat_productos_precios productoPrecioSinc = context.cat_productos_precios
                        .Where(w => w.IdProductoPrecio == itemProductoPrecio.IdProductoPrecio).FirstOrDefault();

                    if (productoPrecioSinc != null)
                    {
                        productoPrecioSinc.IdPrecio = itemProductoPrecio.IdPrecio;
                        productoPrecioSinc.IdProducto = itemProductoPrecio.IdProducto;
                        productoPrecioSinc.MontoDescuento = itemProductoPrecio.MontoDescuento;
                        productoPrecioSinc.PorcDescuento = itemProductoPrecio.PorcDescuento;
                        productoPrecioSinc.Precio = itemProductoPrecio.Precio;                        

                        context.SaveChanges();
                    }
                    else
                    {
                        productoPrecioSinc = new cat_productos_precios();

                        productoPrecioSinc.IdPrecio = itemProductoPrecio.IdPrecio;
                        productoPrecioSinc.IdProducto = itemProductoPrecio.IdProducto;
                        productoPrecioSinc.MontoDescuento = itemProductoPrecio.MontoDescuento;
                        productoPrecioSinc.PorcDescuento = itemProductoPrecio.PorcDescuento;
                        productoPrecioSinc.Precio = itemProductoPrecio.Precio;
                        productoPrecioSinc.IdProductoPrecio = itemProductoPrecio.IdProductoPrecio;

                        context.cat_productos_precios.Add(productoPrecioSinc);
                        context.SaveChanges();
                    }


                }
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Precios", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.ImportProductosPrecios",
                                                          ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Precios", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;

            }
        }


        public bool ImportTiposCajas(ref ERPProdEntities context, List<cat_tipos_cajas> lstTiposCajas)
        {
            try
            {
                foreach (cat_tipos_cajas itemTipoCaja in lstTiposCajas)
                {
                    cat_tipos_cajas tipoCajaSinc = context.cat_tipos_cajas
                        
                        .Where(w => w.TipoCajaId == itemTipoCaja.TipoCajaId)
                        .FirstOrDefault();

                    if (tipoCajaSinc != null)
                    {
                        tipoCajaSinc.Nombre = itemTipoCaja.Nombre;
                        tipoCajaSinc.Activo = itemTipoCaja.Activo;
                        context.SaveChanges();
                    }
                    else
                    {
                        tipoCajaSinc = new cat_tipos_cajas();
                       
                        tipoCajaSinc.TipoCajaId = itemTipoCaja.TipoCajaId;
                        tipoCajaSinc.Nombre = itemTipoCaja.Nombre;
                        tipoCajaSinc.Activo = itemTipoCaja.Activo;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_tipos_cajas.Add(tipoCajaSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos de Cajas", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportTiposCajas",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos de Cajas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportEmpleados(ref ERPProdEntities context, List<rh_empleados> lstEmpleados)
        {
            try
            {
                foreach (rh_empleados itemEmpleado in lstEmpleados)
                {
                    rh_empleados empleadoSinc = context.rh_empleados
                       
                        .Where(w => w.NumEmpleado == itemEmpleado.NumEmpleado)
                        .FirstOrDefault();

                    if (empleadoSinc != null)
                    {
                        empleadoSinc.Nombre = itemEmpleado.Nombre;
                        empleadoSinc.SueldoNeto = itemEmpleado.SueldoNeto;
                        empleadoSinc.SueldoDiario = itemEmpleado.SueldoDiario;
                        empleadoSinc.SueldoHra = itemEmpleado.SueldoHra;
                        empleadoSinc.FormaPago = itemEmpleado.FormaPago;
                        empleadoSinc.TipoContrato = itemEmpleado.TipoContrato;
                        empleadoSinc.Puesto = itemEmpleado.Puesto;
                        empleadoSinc.Departamento = itemEmpleado.Departamento;
                        empleadoSinc.FechaIngreso = itemEmpleado.FechaIngreso;
                        empleadoSinc.FechaInicioLab = itemEmpleado.FechaInicioLab;
                        empleadoSinc.Estatus = itemEmpleado.Estatus;
                        empleadoSinc.Foto = itemEmpleado.Foto;
                        empleadoSinc.Empresa = itemEmpleado.Empresa;
                        empleadoSinc.Sucursal = itemEmpleado.Sucursal;

                        // Puedes asignar otras propiedades según sea necesario

                        context.SaveChanges();
                    }
                    else
                    {
                        empleadoSinc = new rh_empleados();

                        empleadoSinc.NumEmpleado = itemEmpleado.NumEmpleado;
                        empleadoSinc.Nombre = itemEmpleado.Nombre;
                        empleadoSinc.SueldoNeto = itemEmpleado.SueldoNeto;
                        empleadoSinc.SueldoDiario = itemEmpleado.SueldoDiario;
                        empleadoSinc.SueldoHra = itemEmpleado.SueldoHra;
                        empleadoSinc.FormaPago = itemEmpleado.FormaPago;
                        empleadoSinc.TipoContrato = itemEmpleado.TipoContrato;
                        empleadoSinc.Puesto = itemEmpleado.Puesto;
                        empleadoSinc.Departamento = itemEmpleado.Departamento;
                        empleadoSinc.FechaIngreso = itemEmpleado.FechaIngreso;
                        empleadoSinc.FechaInicioLab = itemEmpleado.FechaInicioLab;
                        empleadoSinc.Estatus = itemEmpleado.Estatus;
                        empleadoSinc.Foto = itemEmpleado.Foto;
                        empleadoSinc.Empresa = itemEmpleado.Empresa;
                        empleadoSinc.Sucursal = itemEmpleado.Sucursal;

                        // Puedes asignar otras propiedades según sea necesario

                        context.rh_empleados.Add(empleadoSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Empleados", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportEmpleados",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Empleados", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportPuestos(ref ERPProdEntities context, List<rh_puestos> lstPuestos)
        {
            try
            {
                foreach (rh_puestos itemPuesto in lstPuestos)
                {
                    rh_puestos puestoSinc = context.rh_puestos
                        
                        .Where(w => w.Clave == itemPuesto.Clave)
                        .FirstOrDefault();

                    if (puestoSinc != null)
                    {
                        puestoSinc.Descripcion = itemPuesto.Descripcion;
                        puestoSinc.Estatus = itemPuesto.Estatus;
                        puestoSinc.Empresa = itemPuesto.Empresa;
                        puestoSinc.Sucursal = itemPuesto.Sucursal;
                        puestoSinc.PermitirEliminar = itemPuesto.PermitirEliminar;
                        puestoSinc.Mostrar = itemPuesto.Mostrar;

                        // Puedes asignar otras propiedades según sea necesario

                        context.SaveChanges();
                    }
                    else
                    {
                        puestoSinc = new rh_puestos();

                        puestoSinc.Clave = itemPuesto.Clave;
                        puestoSinc.Descripcion = itemPuesto.Descripcion;
                        puestoSinc.Estatus = itemPuesto.Estatus;
                        puestoSinc.Empresa = itemPuesto.Empresa;
                        puestoSinc.Sucursal = itemPuesto.Sucursal;
                        puestoSinc.PermitirEliminar = itemPuesto.PermitirEliminar;
                        puestoSinc.Mostrar = itemPuesto.Mostrar;

                        // Puedes asignar otras propiedades según sea necesario

                        context.rh_puestos.Add(puestoSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Puestos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPuestos",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Puestos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportSucursalesProductos(ref ERPProdEntities context, List<cat_sucursales_productos> lstSucursalesProductos)
        {
            try
            {
                foreach (cat_sucursales_productos itemSucursalProducto in lstSucursalesProductos)
                {
                    cat_sucursales_productos sucursalProductoSinc = context.cat_sucursales_productos
                        .AsNoTracking()
                        .Where(w => w.SucursalId == itemSucursalProducto.SucursalId && w.ProductoId == itemSucursalProducto.ProductoId)
                        .FirstOrDefault();

                    if (sucursalProductoSinc == null)
                    {
                        sucursalProductoSinc = new cat_sucursales_productos();
                        sucursalProductoSinc.SucursalId = itemSucursalProducto.SucursalId;
                        sucursalProductoSinc.ProductoId = itemSucursalProducto.ProductoId;
                        sucursalProductoSinc.CreadoEl = DateTime.Now;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_sucursales_productos.Add(sucursalProductoSinc);
                       
                    }
                   
                }

                context.SaveChanges();

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos por Sucursal", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportSucursalesProductos",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos por Sucursal", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportMarcas(ref ERPProdEntities context, List<cat_marcas> lstMarcas)
        {
            try
            {
                foreach (cat_marcas itemMarca in lstMarcas)
                {
                    cat_marcas marcaSinc = context.cat_marcas
                        .Where(w => w.Clave == itemMarca.Clave)
                        .FirstOrDefault();

                    if (marcaSinc != null)
                    {
                        marcaSinc.Descripcion = itemMarca.Descripcion;
                        marcaSinc.Estatus = itemMarca.Estatus;
                        marcaSinc.Empresa = itemMarca.Empresa;
                        marcaSinc.Sucursal = itemMarca.Sucursal;
                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        marcaSinc = new cat_marcas();
                        marcaSinc.Clave = itemMarca.Clave;
                        marcaSinc.Descripcion = itemMarca.Descripcion;
                        marcaSinc.Estatus = itemMarca.Estatus;
                        marcaSinc.Empresa = itemMarca.Empresa;
                        marcaSinc.Sucursal = itemMarca.Sucursal;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_marcas.Add(marcaSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Marcas", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportMarcas",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Marcas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportUnidadesMed(ref ERPProdEntities context, List<cat_unidadesmed> lstUnidadesMed)
        {
            try
            {
                foreach (cat_unidadesmed itemUnidadMed in lstUnidadesMed)
                {
                    cat_unidadesmed unidadMedSinc = context.cat_unidadesmed
                        .Where(w => w.Clave == itemUnidadMed.Clave)
                        .FirstOrDefault();

                    if (unidadMedSinc != null)
                    {
                        unidadMedSinc.Descripcion = itemUnidadMed.Descripcion;
                        unidadMedSinc.DescripcionCorta = itemUnidadMed.DescripcionCorta;
                        unidadMedSinc.Decimales = itemUnidadMed.Decimales;
                        unidadMedSinc.Estatus = itemUnidadMed.Estatus;
                        unidadMedSinc.Empresa = itemUnidadMed.Empresa;
                        unidadMedSinc.Sucursal = itemUnidadMed.Sucursal;
                        unidadMedSinc.IdCodigoSAT = itemUnidadMed.IdCodigoSAT;
                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        unidadMedSinc = new cat_unidadesmed();
                        unidadMedSinc.Clave = itemUnidadMed.Clave;
                        unidadMedSinc.Descripcion = itemUnidadMed.Descripcion;
                        unidadMedSinc.DescripcionCorta = itemUnidadMed.DescripcionCorta;
                        unidadMedSinc.Decimales = itemUnidadMed.Decimales;
                        unidadMedSinc.Estatus = itemUnidadMed.Estatus;
                        unidadMedSinc.Empresa = itemUnidadMed.Empresa;
                        unidadMedSinc.Sucursal = itemUnidadMed.Sucursal;
                        unidadMedSinc.IdCodigoSAT = itemUnidadMed.IdCodigoSAT;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_unidadesmed.Add(unidadMedSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Unidades de Medida", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportUnidadesMed",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Unidades de Medida", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportPrecios(ref ERPProdEntities context, List<cat_precios> lstPrecios)
        {
            try
            {
                foreach (cat_precios itemPrecio in lstPrecios)
                {
                    cat_precios precioSinc = context.cat_precios
                        .Where(w => w.IdPrecio == itemPrecio.IdPrecio)
                        .FirstOrDefault();

                    if (precioSinc != null)
                    {
                        precioSinc.Descripcion = itemPrecio.Descripcion;
                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        precioSinc = new cat_precios();
                        precioSinc.IdPrecio = itemPrecio.IdPrecio;
                        precioSinc.Descripcion = itemPrecio.Descripcion;
                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_precios.Add(precioSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Tipos de Precio", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPrecios",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Tipos de Precio", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportClientes(ref ERPProdEntities context, List<cat_clientes> lstClientes)
        {
            try
            {
                foreach (cat_clientes itemCliente in lstClientes)
                {
                    cat_clientes clienteSinc = context.cat_clientes
                        .Where(w => w.ClienteId == itemCliente.ClienteId)
                        .FirstOrDefault();

                    if (clienteSinc != null)
                    {
                        clienteSinc.Nombre = itemCliente.Nombre;
                        clienteSinc.RFC = itemCliente.RFC;
                        clienteSinc.Calle = itemCliente.Calle;
                        clienteSinc.NumeroExt = itemCliente.NumeroExt;
                        clienteSinc.NumeroInt = itemCliente.NumeroInt;
                        clienteSinc.Colonia = itemCliente.Colonia;
                        clienteSinc.CodigoPostal = itemCliente.CodigoPostal;
                        clienteSinc.EstadoId = itemCliente.EstadoId;
                        clienteSinc.MunicipioId = itemCliente.MunicipioId;
                        clienteSinc.PaisId = itemCliente.PaisId;
                        clienteSinc.Telefono = itemCliente.Telefono;
                        clienteSinc.Telefono2 = itemCliente.Telefono2;
                        clienteSinc.TipoClienteId = itemCliente.TipoClienteId;
                        clienteSinc.DiasCredito = itemCliente.DiasCredito;
                        clienteSinc.LimiteCredito = itemCliente.LimiteCredito;
                        clienteSinc.AntecedenteId = itemCliente.AntecedenteId;
                        clienteSinc.CreditoDisponible = itemCliente.CreditoDisponible;
                        clienteSinc.SaldoGlobal = itemCliente.SaldoGlobal;
                        clienteSinc.Activo = itemCliente.Activo;
                        clienteSinc.ClienteEspecial = itemCliente.ClienteEspecial;
                        clienteSinc.ClienteGral = itemCliente.ClienteGral;
                        clienteSinc.PrecioId = itemCliente.PrecioId;
                        clienteSinc.GiroId = itemCliente.GiroId;
                        clienteSinc.GiroNegocioId = itemCliente.GiroNegocioId;
                        clienteSinc.ApellidoPaterno = itemCliente.ApellidoPaterno;
                        clienteSinc.ApellidoMaterno = itemCliente.ApellidoMaterno;
                        clienteSinc.UUID = itemCliente.UUID;
                        clienteSinc.KeyClient = itemCliente.KeyClient;
                        clienteSinc.EmpleadoId = itemCliente.EmpleadoId;
                        clienteSinc.Clave = itemCliente.Clave;
                        clienteSinc.SucursalBaseId = itemCliente.SucursalBaseId;
                        clienteSinc.pass = itemCliente.pass;

                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        clienteSinc = new cat_clientes();
                        clienteSinc.ClienteId = itemCliente.ClienteId;
                        clienteSinc.Nombre = itemCliente.Nombre;
                        clienteSinc.RFC = itemCliente.RFC;
                        clienteSinc.Calle = itemCliente.Calle;
                        clienteSinc.NumeroExt = itemCliente.NumeroExt;
                        clienteSinc.NumeroInt = itemCliente.NumeroInt;
                        clienteSinc.Colonia = itemCliente.Colonia;
                        clienteSinc.CodigoPostal = itemCliente.CodigoPostal;
                        clienteSinc.EstadoId = itemCliente.EstadoId;
                        clienteSinc.MunicipioId = itemCliente.MunicipioId;
                        clienteSinc.PaisId = itemCliente.PaisId;
                        clienteSinc.Telefono = itemCliente.Telefono;
                        clienteSinc.Telefono2 = itemCliente.Telefono2;
                        clienteSinc.TipoClienteId = itemCliente.TipoClienteId;
                        clienteSinc.DiasCredito = itemCliente.DiasCredito;
                        clienteSinc.LimiteCredito = itemCliente.LimiteCredito;
                        clienteSinc.AntecedenteId = itemCliente.AntecedenteId;
                        clienteSinc.CreditoDisponible = itemCliente.CreditoDisponible;
                        clienteSinc.SaldoGlobal = itemCliente.SaldoGlobal;
                        clienteSinc.Activo = itemCliente.Activo;
                        clienteSinc.ClienteEspecial = itemCliente.ClienteEspecial;
                        clienteSinc.ClienteGral = itemCliente.ClienteGral;
                        clienteSinc.PrecioId = itemCliente.PrecioId;
                        clienteSinc.GiroId = itemCliente.GiroId;
                        clienteSinc.GiroNegocioId = itemCliente.GiroNegocioId;
                        clienteSinc.ApellidoPaterno = itemCliente.ApellidoPaterno;
                        clienteSinc.ApellidoMaterno = itemCliente.ApellidoMaterno;
                        clienteSinc.UUID = itemCliente.UUID;
                        clienteSinc.KeyClient = itemCliente.KeyClient;
                        clienteSinc.EmpleadoId = itemCliente.EmpleadoId;
                        clienteSinc.Clave = itemCliente.Clave;
                        clienteSinc.SucursalBaseId = itemCliente.SucursalBaseId;
                        clienteSinc.pass = itemCliente.pass;

                        // Puedes asignar otras propiedades según sea necesario
                        context.cat_clientes.Add(clienteSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Clientes", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportClientes",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Clientes", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportPreciosEspeciales(ref ERPProdEntities context, List<doc_precios_especiales> lstPreciosEspeciales, List<doc_precios_especiales_detalle> lstPreciosEspecialesDetalle)
        {
            try
            {
                context.Database.ExecuteSqlCommand("DELETE FROM doc_precios_especiales_detalle");

                context.Database.ExecuteSqlCommand("DELETE FROM doc_precios_especiales WHERE SucursalId = @SucursalId", new SqlParameter("SucursalId", this.sucursalId));

                
                foreach (doc_precios_especiales itemPrecioEspecial in lstPreciosEspeciales)
                {
                    doc_precios_especiales precioEspecialSinc = new doc_precios_especiales();

                    precioEspecialSinc.Descripcion = itemPrecioEspecial.Descripcion;
                    precioEspecialSinc.FechaVigencia = itemPrecioEspecial.FechaVigencia;
                    precioEspecialSinc.HoraVigencia = itemPrecioEspecial.HoraVigencia;
                    precioEspecialSinc.CreadoEl = itemPrecioEspecial.CreadoEl;
                    precioEspecialSinc.CreadoPor = itemPrecioEspecial.CreadoPor;
                    precioEspecialSinc.SucursalId = itemPrecioEspecial.SucursalId;

                    // Actualizar otras propiedades según sea necesario
                    context.doc_precios_especiales.Add(precioEspecialSinc);
                    context.SaveChanges();

                    foreach (doc_precios_especiales_detalle itemDetalle in lstPreciosEspecialesDetalle.Where(w=>w.PrecioEspeciaId == itemPrecioEspecial.Id))
                    {
                        doc_precios_especiales_detalle precioEspecialSincDetalle = new doc_precios_especiales_detalle();

                        precioEspecialSincDetalle.CreadoEl = itemDetalle.CreadoEl;
                        precioEspecialSincDetalle.CreadoPor = itemDetalle.CreadoPor;
                        precioEspecialSincDetalle.ModificadoEl = itemDetalle.ModificadoEl;
                        precioEspecialSincDetalle.ModificadoPor = itemDetalle.ModificadoPor;
                        precioEspecialSincDetalle.MontoAdicional = itemDetalle.MontoAdicional;
                        precioEspecialSincDetalle.PrecioEspeciaId = precioEspecialSinc.Id;
                        precioEspecialSincDetalle.PrecioEspecial = itemDetalle.PrecioEspecial;
                        precioEspecialSincDetalle.ProductoId = itemDetalle.ProductoId;

                        context.doc_precios_especiales_detalle.Add(precioEspecialSincDetalle);
                        

                    }

                    context.SaveChanges();
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Precios Especiales", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPreciosEspeciales",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Precios Especiales", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportPreferencias(ref ERPProdEntities context, List<sis_preferencias> lstPreferencias)
        {
            try
            {
                foreach (sis_preferencias itemPreferencia in lstPreferencias)
                {
                    sis_preferencias preferenciaSinc = context.sis_preferencias
                        .Where(w => w.Preferencia == itemPreferencia.Preferencia)
                        .FirstOrDefault();

                    if (preferenciaSinc != null)
                    {
                        preferenciaSinc.Preferencia = itemPreferencia.Preferencia;
                        preferenciaSinc.Descripcion = itemPreferencia.Descripcion;
                        preferenciaSinc.ParaEmpresa = itemPreferencia.ParaEmpresa;
                        preferenciaSinc.ParaUsuario = itemPreferencia.ParaUsuario;
                        preferenciaSinc.CreadoEl = itemPreferencia.CreadoEl;

                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        preferenciaSinc = new sis_preferencias();
                        preferenciaSinc.Preferencia = itemPreferencia.Preferencia;
                        preferenciaSinc.Descripcion = itemPreferencia.Descripcion;
                        preferenciaSinc.ParaEmpresa = itemPreferencia.ParaEmpresa;
                        preferenciaSinc.ParaUsuario = itemPreferencia.ParaUsuario;
                        preferenciaSinc.CreadoEl = itemPreferencia.CreadoEl;

                        // Puedes asignar otras propiedades según sea necesario
                        context.sis_preferencias.Add(preferenciaSinc);
                        context.SaveChanges();
                    }
                }


                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Preferencias", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPreferencias",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Preferencias", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        public bool ImportPreferenciasEmpresa(ref ERPProdEntities context, List<sis_preferencias_empresa> lstPreferenciasEmpresa)
        {
            try
            {
                foreach (sis_preferencias_empresa itemPreferenciaEmpresa in lstPreferenciasEmpresa)
                {
                    sis_preferencias_empresa preferenciaEmpresaSinc = context.sis_preferencias_empresa
                        .Where(w => w.EmpresaId == 1 && w.sis_preferencias.Preferencia == itemPreferenciaEmpresa.sis_preferencias.Preferencia)
                        .FirstOrDefault();

                    if (preferenciaEmpresaSinc != null)
                    {
                        preferenciaEmpresaSinc.PreferenciaId = itemPreferenciaEmpresa.PreferenciaId;
                        preferenciaEmpresaSinc.EmpresaId = itemPreferenciaEmpresa.EmpresaId;
                        preferenciaEmpresaSinc.Valor = itemPreferenciaEmpresa.Valor;
                        preferenciaEmpresaSinc.CreadoEl = itemPreferenciaEmpresa.CreadoEl;

                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        preferenciaEmpresaSinc = new sis_preferencias_empresa();
                        preferenciaEmpresaSinc.PreferenciaId = itemPreferenciaEmpresa.PreferenciaId;
                        preferenciaEmpresaSinc.EmpresaId = itemPreferenciaEmpresa.EmpresaId;
                        preferenciaEmpresaSinc.Valor = itemPreferenciaEmpresa.Valor;
                        preferenciaEmpresaSinc.CreadoEl = itemPreferenciaEmpresa.CreadoEl;

                        // Puedes asignar otras propiedades según sea necesario
                        context.sis_preferencias_empresa.Add(preferenciaEmpresaSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Preferencias-Empresa", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPreferenciasEmpresa",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Preferencias-Empresa", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportPreferenciasSucursales(ref ERPProdEntities context, List<sis_preferencias_sucursales> lstPreferenciasSucursales)
        {
            try
            {
                foreach (sis_preferencias_sucursales itemPreferenciaSucursal in lstPreferenciasSucursales)
                {
                    sis_preferencias_sucursales preferenciaSucursalSinc = context.sis_preferencias_sucursales
                        .Where(w => w.Id == itemPreferenciaSucursal.Id)
                        .FirstOrDefault();

                    if (preferenciaSucursalSinc != null)
                    {
                        preferenciaSucursalSinc.SucursalId = itemPreferenciaSucursal.SucursalId;
                        preferenciaSucursalSinc.PreferenciaId = itemPreferenciaSucursal.PreferenciaId;
                        preferenciaSucursalSinc.Valor = itemPreferenciaSucursal.Valor;
                        preferenciaSucursalSinc.CreadoEl = itemPreferenciaSucursal.CreadoEl;

                        // Actualizar otras propiedades según sea necesario
                        context.SaveChanges();
                    }
                    else
                    {
                        preferenciaSucursalSinc = new sis_preferencias_sucursales();
                        preferenciaSucursalSinc.SucursalId = itemPreferenciaSucursal.SucursalId;
                        preferenciaSucursalSinc.PreferenciaId = itemPreferenciaSucursal.PreferenciaId;
                        preferenciaSucursalSinc.Valor = itemPreferenciaSucursal.Valor;
                        preferenciaSucursalSinc.CreadoEl = itemPreferenciaSucursal.CreadoEl;
                        preferenciaSucursalSinc.Id = itemPreferenciaSucursal.Id;
                        // Puedes asignar otras propiedades según sea necesario
                        context.sis_preferencias_sucursales.Add(preferenciaSucursalSinc);
                        context.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Preferencias-Sucursal", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportPreferenciasSucursales",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Preferencias-Sucursal", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        public bool ImportClientesProductosPrecios(List<doc_clientes_productos_precios> lstClientesProductosPrecios)
        {
            try
            {
                foreach (doc_clientes_productos_precios itemClienteProductoPrecio in lstClientesProductosPrecios)
                {
                    doc_clientes_productos_precios clienteProductoPrecioSinc = this.contextLocal.doc_clientes_productos_precios
                        .Where(w => w.ClienteProductoPrecioId == itemClienteProductoPrecio.ClienteProductoPrecioId)
                        .FirstOrDefault();

                    if (clienteProductoPrecioSinc != null)
                    {
                        clienteProductoPrecioSinc.ClienteId = itemClienteProductoPrecio.ClienteId;
                        clienteProductoPrecioSinc.ProductoId = itemClienteProductoPrecio.ProductoId;
                        clienteProductoPrecioSinc.Precio = itemClienteProductoPrecio.Precio;
                        clienteProductoPrecioSinc.CreadoEl = itemClienteProductoPrecio.CreadoEl;

                        // Actualizar otras propiedades según sea necesario
                        this.contextLocal.SaveChanges();
                    }
                    else
                    {
                        clienteProductoPrecioSinc = new doc_clientes_productos_precios();
                        clienteProductoPrecioSinc.ClienteProductoPrecioId = itemClienteProductoPrecio.ClienteProductoPrecioId;
                        clienteProductoPrecioSinc.ClienteId = itemClienteProductoPrecio.ClienteId;
                        clienteProductoPrecioSinc.ProductoId = itemClienteProductoPrecio.ProductoId;
                        clienteProductoPrecioSinc.Precio = itemClienteProductoPrecio.Precio;
                        clienteProductoPrecioSinc.CreadoEl = itemClienteProductoPrecio.CreadoEl;

                        // Puedes asignar otras propiedades según sea necesario
                        this.contextLocal.doc_clientes_productos_precios.Add(clienteProductoPrecioSinc);
                        this.contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos-Precios", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportClientesProductosPrecios",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos-Precios", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportProductosPrincipales(List<cat_productos_principales> lstProductosPrincipales)
        {
            try
            {
                foreach (cat_productos_principales itemProductoPrincipal in lstProductosPrincipales)
                {
                    cat_productos_principales productoPrincipalSinc = this.contextLocal.cat_productos_principales
                        .Where(w => w.SucursalId == itemProductoPrincipal.SucursalId && w.ProductoId == itemProductoPrincipal.ProductoId)
                        .FirstOrDefault();

                    if (productoPrincipalSinc != null)
                    {
                        productoPrincipalSinc.CreadoEl = itemProductoPrincipal.CreadoEl;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        productoPrincipalSinc = new cat_productos_principales();
                        productoPrincipalSinc.SucursalId = itemProductoPrincipal.SucursalId;
                        productoPrincipalSinc.ProductoId = itemProductoPrincipal.ProductoId;
                        productoPrincipalSinc.CreadoEl = itemProductoPrincipal.CreadoEl;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_productos_principales.Add(productoPrincipalSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos Principales", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportProductosPrincipales",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos Principales", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        public bool ImportFormasPago(List<cat_formas_pago> lstFormasPago)
        {
            try
            {
                foreach (cat_formas_pago itemFormaPago in lstFormasPago)
                {
                    cat_formas_pago formaPagoSinc = this.contextLocal.cat_formas_pago
                        .Where(w => w.FormaPagoId == itemFormaPago.FormaPagoId)
                        .FirstOrDefault();

                    if (formaPagoSinc != null)
                    {
                        formaPagoSinc.Descripcion = itemFormaPago.Descripcion;
                        formaPagoSinc.Abreviatura = itemFormaPago.Abreviatura;
                        formaPagoSinc.Orden = itemFormaPago.Orden;
                        formaPagoSinc.RequiereDigVerificador = itemFormaPago.RequiereDigVerificador;
                        formaPagoSinc.Activo = itemFormaPago.Activo;
                        formaPagoSinc.Signo = itemFormaPago.Signo;
                        formaPagoSinc.NumeroHacienda = itemFormaPago.NumeroHacienda;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        formaPagoSinc = new cat_formas_pago();
                        formaPagoSinc.FormaPagoId = itemFormaPago.FormaPagoId;
                        formaPagoSinc.Descripcion = itemFormaPago.Descripcion;
                        formaPagoSinc.Abreviatura = itemFormaPago.Abreviatura;
                        formaPagoSinc.Orden = itemFormaPago.Orden;
                        formaPagoSinc.RequiereDigVerificador = itemFormaPago.RequiereDigVerificador;
                        formaPagoSinc.Activo = itemFormaPago.Activo;
                        formaPagoSinc.Signo = itemFormaPago.Signo;
                        formaPagoSinc.NumeroHacienda = itemFormaPago.NumeroHacienda;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_formas_pago.Add(formaPagoSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Formas Pago", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportFormasPago",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Formas Pago", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });


                return false;
            }
        }

        public bool ImportTiposPedido(List<cat_tipos_pedido> lstTiposPedido)
        {
            try
            {
                foreach (cat_tipos_pedido itemTipoPedido in lstTiposPedido)
                {
                    cat_tipos_pedido tipoPedidoSinc = contextLocal.cat_tipos_pedido
                        .Where(w => w.TipoPedidoId == itemTipoPedido.TipoPedidoId)
                        .FirstOrDefault();

                    if (tipoPedidoSinc != null)
                    {
                        tipoPedidoSinc.Nombre = itemTipoPedido.Nombre;
                        tipoPedidoSinc.Folio = itemTipoPedido.Folio;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        tipoPedidoSinc = new cat_tipos_pedido();
                        tipoPedidoSinc.TipoPedidoId = itemTipoPedido.TipoPedidoId;
                        tipoPedidoSinc.Nombre = itemTipoPedido.Nombre;
                        tipoPedidoSinc.Folio = itemTipoPedido.Folio;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_tipos_pedido.Add(tipoPedidoSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos Pedido", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportTiposPedido",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos Pedido", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportTiposMovimientoInventario(List<cat_tipos_movimiento_inventario> lstTiposMovimiento)
        {
            try
            {
                foreach (cat_tipos_movimiento_inventario itemTipoMovimiento in lstTiposMovimiento)
                {
                    cat_tipos_movimiento_inventario tipoMovimientoSinc = this.contextLocal.cat_tipos_movimiento_inventario
                        .Where(w => w.TipoMovimientoInventarioId == itemTipoMovimiento.TipoMovimientoInventarioId)
                        .FirstOrDefault();

                    if (tipoMovimientoSinc != null)
                    {
                        tipoMovimientoSinc.Descripcion = itemTipoMovimiento.Descripcion;
                        tipoMovimientoSinc.Activo = itemTipoMovimiento.Activo;
                        tipoMovimientoSinc.EsEntrada = itemTipoMovimiento.EsEntrada;
                        tipoMovimientoSinc.TipoMovimientoCancelacionId = itemTipoMovimiento.TipoMovimientoCancelacionId;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        tipoMovimientoSinc = new cat_tipos_movimiento_inventario();
                        tipoMovimientoSinc.TipoMovimientoInventarioId = itemTipoMovimiento.TipoMovimientoInventarioId;
                        tipoMovimientoSinc.Descripcion = itemTipoMovimiento.Descripcion;
                        tipoMovimientoSinc.Activo = itemTipoMovimiento.Activo;
                        tipoMovimientoSinc.EsEntrada = itemTipoMovimiento.EsEntrada;
                        //tipoMovimientoSinc.TipoMovimientoCancelacionId = itemTipoMovimiento.TipoMovimientoCancelacionId;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_tipos_movimiento_inventario.Add(tipoMovimientoSinc);
                        contextLocal.SaveChanges();
                    }
                }

                foreach (cat_tipos_movimiento_inventario itemTipoMovimiento in lstTiposMovimiento)
                {
                    cat_tipos_movimiento_inventario tipoMovimientoSinc = this.contextLocal.cat_tipos_movimiento_inventario
                        .Where(w => w.TipoMovimientoInventarioId == itemTipoMovimiento.TipoMovimientoInventarioId)
                        .FirstOrDefault();

                    if (tipoMovimientoSinc != null)
                    {
                       
                        tipoMovimientoSinc.TipoMovimientoCancelacionId = itemTipoMovimiento.TipoMovimientoCancelacionId;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                   
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos de Movimiento de Inventario", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportTiposMovimientoInventario",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos de Movimiento de Inventario", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportConceptos( List<cat_conceptos> lstConceptos)
        {
            try
            {
                foreach (cat_conceptos itemConcepto in lstConceptos)
                {
                    cat_conceptos conceptoSinc = this.contextLocal.cat_conceptos
                        .Where(w => w.ConceptoId == itemConcepto.ConceptoId)
                        .FirstOrDefault();

                    if (conceptoSinc != null)
                    {
                        conceptoSinc.Descripcion = itemConcepto.Descripcion;
                        conceptoSinc.FechaRegistro = itemConcepto.FechaRegistro;
                        conceptoSinc.Activo = itemConcepto.Activo;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        conceptoSinc = new cat_conceptos();
                        conceptoSinc.ConceptoId = itemConcepto.ConceptoId;
                        conceptoSinc.Descripcion = itemConcepto.Descripcion;
                        conceptoSinc.FechaRegistro = itemConcepto.FechaRegistro;
                        conceptoSinc.Activo = itemConcepto.Activo;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_conceptos.Add(conceptoSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Conceptos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportConceptos",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Conceptos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportCentroCostos(List<cat_centro_costos> lstCentroCostos)
        {
            try
            {
                foreach (cat_centro_costos itemCentroCostos in lstCentroCostos)
                {
                    cat_centro_costos centroCostosSinc = this.contextLocal.cat_centro_costos
                        .Where(w => w.Clave == itemCentroCostos.Clave)
                        .FirstOrDefault();

                    if (centroCostosSinc != null)
                    {
                        centroCostosSinc.Descripcion = itemCentroCostos.Descripcion;
                        centroCostosSinc.Estatus = itemCentroCostos.Estatus;
                        centroCostosSinc.Empresa = itemCentroCostos.Empresa;
                        centroCostosSinc.Sucursal = itemCentroCostos.Sucursal;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        centroCostosSinc = new cat_centro_costos();
                        centroCostosSinc.Clave = itemCentroCostos.Clave;
                        centroCostosSinc.Descripcion = itemCentroCostos.Descripcion;
                        centroCostosSinc.Estatus = itemCentroCostos.Estatus;
                        centroCostosSinc.Empresa = itemCentroCostos.Empresa;
                        centroCostosSinc.Sucursal = itemCentroCostos.Sucursal;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_centro_costos.Add(centroCostosSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Centro Costos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportCentroCostos",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Centro Costos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportcatGastos(List<cat_gastos> lstGastos)
        {
            try
            {
                foreach (cat_gastos itemGasto in lstGastos)
                {
                    cat_gastos gastoSinc = this.contextLocal.cat_gastos
                        .Where(w => w.Clave == itemGasto.Clave)
                        .FirstOrDefault();

                    if (gastoSinc != null)
                    {
                        gastoSinc.Descripcion = itemGasto.Descripcion;
                        gastoSinc.ClaveCentroCosto = itemGasto.ClaveCentroCosto;
                        gastoSinc.Estatus = itemGasto.Estatus;
                        gastoSinc.Empresa = itemGasto.Empresa;
                        gastoSinc.Sucursal = itemGasto.Sucursal;
                        gastoSinc.Monto = itemGasto.Monto;
                        gastoSinc.Observaciones = itemGasto.Observaciones;
                        gastoSinc.ConceptoId = itemGasto.ConceptoId;
                        gastoSinc.CreadoPor = itemGasto.CreadoPor;
                        gastoSinc.CreadoEl = itemGasto.CreadoEl;
                        gastoSinc.CajaId = itemGasto.CajaId;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        gastoSinc = new cat_gastos();
                        gastoSinc.Clave = itemGasto.Clave;
                        gastoSinc.Descripcion = itemGasto.Descripcion;
                        gastoSinc.ClaveCentroCosto = itemGasto.ClaveCentroCosto;
                        gastoSinc.Estatus = itemGasto.Estatus;
                        gastoSinc.Empresa = itemGasto.Empresa;
                        gastoSinc.Sucursal = itemGasto.Sucursal;
                        gastoSinc.Monto = itemGasto.Monto;
                        gastoSinc.Observaciones = itemGasto.Observaciones;
                        gastoSinc.ConceptoId = itemGasto.ConceptoId;
                        gastoSinc.CreadoPor = itemGasto.CreadoPor;
                        gastoSinc.CreadoEl = itemGasto.CreadoEl;
                        gastoSinc.CajaId = itemGasto.CajaId;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.cat_gastos.Add(gastoSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo Tipos de Gastos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportGastos",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Catálogo de Tipos de Gastos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ImportProductosSobrantesConfig(List<doc_productos_sobrantes_config> lstProductosSobrantesConfig)
        {
            try
            {
                foreach (doc_productos_sobrantes_config itemConfig in lstProductosSobrantesConfig)
                {
                    doc_productos_sobrantes_config configSinc = contextLocal.doc_productos_sobrantes_config
                        .Where(w => w.EmpresaId == itemConfig.EmpresaId && w.ProductoSobranteId == itemConfig.ProductoSobranteId)
                        .FirstOrDefault();

                    if (configSinc != null)
                    {
                        configSinc.EmpresaId = itemConfig.EmpresaId;
                        configSinc.ProductoSobranteId = itemConfig.ProductoSobranteId;
                        configSinc.ProductoConvertirId = itemConfig.ProductoConvertirId;
                        configSinc.Convertir = itemConfig.Convertir;
                        configSinc.CreadoEl = itemConfig.CreadoEl;
                        configSinc.CreadoPor = itemConfig.CreadoPor;
                        configSinc.DejarEnCero = itemConfig.DejarEnCero;

                        // Actualizar otras propiedades según sea necesario
                        contextLocal.SaveChanges();
                    }
                    else
                    {
                        configSinc = new doc_productos_sobrantes_config();
                        configSinc.EmpresaId = itemConfig.EmpresaId;
                        configSinc.ProductoSobranteId = itemConfig.ProductoSobranteId;
                        configSinc.ProductoConvertirId = itemConfig.ProductoConvertirId;
                        configSinc.Convertir = itemConfig.Convertir;
                        configSinc.CreadoEl = itemConfig.CreadoEl;
                        configSinc.CreadoPor = itemConfig.CreadoPor;
                        configSinc.DejarEnCero = itemConfig.DejarEnCero;

                        // Puedes asignar otras propiedades según sea necesario
                        contextLocal.doc_productos_sobrantes_config.Add(configSinc);
                        contextLocal.SaveChanges();
                    }
                }

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos Sobrantes - Configuración", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ImportProductosSobrantesConfig",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Importar", Entidad = "Productos Sobrantes - Configuración", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        //Exportar hacia la NUBE
        public string ExportANube()
        {
            try
            {
                this.ExportGastos();
                this.ExportRetiros();
                this.ExportMaizMasecaRendimiento();
                this.ExportProductosSobrantesRegistro();
                this.ExportPedidosOrden_Ventas();
                return "";
            }
            catch (Exception ex)
            {

                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                          "ERP",
                                                          "ERP.Business.SincronizacionBusiness.Importar",
                                                          ex);

                return "Ocurrió un error al importar, revise el registro de bitácora [" + err.ToString() + "]";
            }
        }

        public bool ExportGastos()
        {
            try
            {
                List<doc_gastos> listaGastos = this.contextLocal.doc_gastos.ToList();

                using (var dbContextTransaction = contextNube.Database.BeginTransaction())
                {
                    try
                    {
                        foreach (doc_gastos gasto in listaGastos)
                        {
                            doc_gastos exists = this.contextNube.doc_gastos.Where(w => w.CreadoEl == gasto.CreadoEl &&
                            w.GastoConceptoId == gasto.GastoConceptoId &&
                            w.Monto == gasto.Monto &&
                            w.Obervaciones == gasto.Obervaciones).FirstOrDefault();

                            if (exists == null)
                            {
                                exists = new doc_gastos
                                {
                                    GastoId = (this.contextNube.doc_gastos.Max(m => (int?)m.GastoId) ?? 0) + 1,
                                    CentroCostoId = gasto.CentroCostoId,
                                    GastoConceptoId = gasto.GastoConceptoId,
                                    Obervaciones = gasto.Obervaciones,
                                    Monto = gasto.Monto,
                                    CajaId = gasto.CajaId,
                                    CreadoEl = gasto.CreadoEl,
                                    CreadoPor = gasto.CreadoPor,
                                    SucursalId = gasto.SucursalId,
                                    Activo = gasto.Activo

                                };
                                this.contextNube.doc_gastos.Add(exists);

                                this.contextNube.SaveChanges();
                            }
                           



                        }
                        
                        dbContextTransaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        dbContextTransaction.Rollback();
                        err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportGastos",
                                                              ex);

                        return false;
                    }
                    
                }

                this.contextLocal.Database.ExecuteSqlCommand("DELETE FROM doc_gastos");


                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Gastos", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportGastos",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Gastos", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ExportRetiros()
        {
            try
            {
                List<doc_retiros> listaRetiros = this.contextLocal.doc_retiros.ToList();

                using (var dbContextTransaction = contextNube.Database.BeginTransaction())
                {
                    try
                    {
                        foreach (doc_retiros retiro in listaRetiros)
                        {
                            doc_retiros exists = this.contextNube.doc_retiros
                                .Where(w => w.FechaRetiro == retiro.FechaRetiro &&
                                            w.MontoRetiro == retiro.MontoRetiro &&                                            
                                            w.CajaId == retiro.CajaId &&
                                            w.SucursalId == retiro.SucursalId &&
                                            w.Observaciones == retiro.Observaciones)
                                .FirstOrDefault();

                            if (exists == null)
                            {
                                exists = new doc_retiros
                                {
                                    RetiroId = (this.contextNube.doc_retiros.Max(m => (int?)m.RetiroId) ?? 0) + 1,
                                    FechaRetiro = retiro.FechaRetiro,
                                    MontoRetiro = retiro.MontoRetiro,
                                    CreadoPor = retiro.CreadoPor,
                                    CajaId = retiro.CajaId,
                                    SucursalId = retiro.SucursalId,
                                    Observaciones = retiro.Observaciones
                                };

                                this.contextNube.doc_retiros.Add(exists);
                                this.contextNube.SaveChanges();
                            }
                        }

                        dbContextTransaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        dbContextTransaction.Rollback();
                        err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                                      "ERP",
                                                                      "ERP.Business.SincronizacionBusiness.ExportRetiros",
                                                                      ex);
                        return false;
                    }
                }

                this.contextLocal.Database.ExecuteSqlCommand("DELETE FROM doc_retiros");


                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Retiros", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportRetiros",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Retiros", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ExportMaizMasecaRendimiento()
        {
            try
            {
                List<doc_maiz_maseca_rendimiento> listaRendimientos = this.contextLocal.doc_maiz_maseca_rendimiento.ToList();

                using (var dbContextTransaction = contextNube.Database.BeginTransaction())
                {
                    try
                    {
                        foreach (doc_maiz_maseca_rendimiento rendimiento in listaRendimientos)
                        {
                            doc_maiz_maseca_rendimiento exists = this.contextNube.doc_maiz_maseca_rendimiento
                                .Where(w => w.SucursalId == rendimiento.SucursalId &&
                                            w.Fecha == rendimiento.Fecha)
                                .FirstOrDefault();

                            if (exists == null)
                            {
                                exists = new doc_maiz_maseca_rendimiento
                                {
                                    SucursalId = rendimiento.SucursalId,
                                    Fecha = rendimiento.Fecha,
                                    MaizSacos = rendimiento.MaizSacos,
                                    MasecaSacos = rendimiento.MasecaSacos,
                                    TortillaMaizRendimiento = rendimiento.TortillaMaizRendimiento,
                                    TortillaMasecaRendimiento = rendimiento.TortillaMasecaRendimiento,
                                    TortillaTotalRendimiento = rendimiento.TortillaTotalRendimiento,
                                    CreadoEl = rendimiento.CreadoEl,
                                    CreadoPor = rendimiento.CreadoPor,
                                    ModificadoEl = rendimiento.ModificadoEl,
                                    ModificadoPor = rendimiento.ModificadoPor
                                };

                                this.contextNube.doc_maiz_maseca_rendimiento.Add(exists);
                                this.contextNube.SaveChanges();
                            }
                            
                        }

                        dbContextTransaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        dbContextTransaction.Rollback();
                        err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                                      "ERP",
                                                                      "ERP.Business.SincronizacionBusiness.ExportMaizMasecaRendimiento",
                                                                      ex);
                        return false;
                    }
                }

                // Eliminar los registros exportados de la base de datos local
                this.contextLocal.Database.ExecuteSqlCommand("DELETE FROM doc_maiz_maseca_rendimiento");

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Maiz Maseca Rendimiento", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportMaizMasecaRendimiento",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Maiz Maseca Rendimiento", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public bool ExportProductosSobrantesRegistro()
        {
            try
            {
                List<doc_productos_sobrantes_registro> listaSobrantes = this.contextLocal.doc_productos_sobrantes_registro.ToList();

                using (var dbContextTransaction = contextNube.Database.BeginTransaction())
                {
                    try
                    {
                        foreach (doc_productos_sobrantes_registro sobrante in listaSobrantes)
                        {
                            doc_productos_sobrantes_registro exists = this.contextNube.doc_productos_sobrantes_registro
                                .Where(w => w.ProductoId == sobrante.ProductoId &&
                                w.SucursalId == sobrante.SucursalId &&
                                w.CreadoEl == sobrante.CreadoEl)
                                .FirstOrDefault();

                            if (exists == null)
                            {
                                exists = new doc_productos_sobrantes_registro
                                {
                                    Id = (this.contextNube.doc_productos_sobrantes_registro.Max(m=> (int?)m.Id)??0)+1,
                                    SucursalId = sobrante.SucursalId,
                                    ProductoId = sobrante.ProductoId,
                                    CantidadSobrante = sobrante.CantidadSobrante,
                                    CreadoEl = sobrante.CreadoEl,
                                    CreadoPor = sobrante.CreadoPor,
                                    Cerrado = sobrante.Cerrado,
                                    CerradoEl = sobrante.CerradoEl,
                                    CerradoPor = sobrante.CerradoPor,
                                    CantidadInventario = sobrante.CantidadInventario
                                };

                                this.contextNube.doc_productos_sobrantes_registro.Add(exists);
                                this.contextNube.SaveChanges();
                            }
                            else
                            {
                                // Actualizar existente si es necesario
                                // exists.SucursalId = sobrante.SucursalId;
                                // exists.ProductoId = sobrante.ProductoId;
                                // ... (actualizar otras propiedades según tus necesidades)
                            }
                        }

                        dbContextTransaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        dbContextTransaction.Rollback();
                        err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                                      "ERP",
                                                                      "ERP.Business.SincronizacionBusiness.ExportProductosSobrantesRegistro",
                                                                      ex);
                        return false;
                    }
                }

                // Eliminar los registros exportados de la base de datos local
                this.contextLocal.Database.ExecuteSqlCommand("DELETE FROM doc_productos_sobrantes_registro");


                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Producto Sobrante", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportProductosSobrantesRegistro",
                                                              ex);

                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Producto Sobrante", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }


        public bool ExportPedidosOrden_Ventas()
        {
            try
            {
                List<doc_pedidos_orden> listaPedidosOrden = this.contextLocal.doc_pedidos_orden.ToList();
                List<doc_pedidos_orden_detalle> listaPedidosOrdenDetalle = this.contextLocal.doc_pedidos_orden_detalle.ToList();
                List<doc_ventas> listaVentas = this.contextLocal.doc_ventas.ToList();
                List<doc_ventas_detalle> listaVentasDetalle = this.contextLocal.doc_ventas_detalle.ToList();

                using (var dbContextTransaction = contextNube.Database.BeginTransaction())
                {
                    try
                    {
                        foreach (doc_pedidos_orden pedidoOrden in listaPedidosOrden)
                        {
                            doc_pedidos_orden exists = null;

                            if (exists == null)
                            {
                                exists = new doc_pedidos_orden
                                {
                                    PedidoId = (this.contextNube.doc_pedidos_orden.Max(m=> (int?)m.PedidoId) ??0)+1,
                                    SucursalId = pedidoOrden.SucursalId,
                                    ComandaId = pedidoOrden.ComandaId,
                                    PorcDescuento = pedidoOrden.PorcDescuento,
                                    Subtotal = pedidoOrden.Subtotal,
                                    Descuento = pedidoOrden.Descuento,
                                    Impuestos = pedidoOrden.Impuestos,
                                    Total = pedidoOrden.Total,
                                    ClienteId = pedidoOrden.ClienteId,
                                    MotivoCancelacion = pedidoOrden.MotivoCancelacion,
                                    Activo = pedidoOrden.Activo,
                                    CreadoEl = pedidoOrden.CreadoEl,
                                    CreadoPor = pedidoOrden.CreadoPor,
                                    Personas = pedidoOrden.Personas,
                                    FechaApertura = pedidoOrden.FechaApertura,
                                    FechaCierre = pedidoOrden.FechaCierre,
                                    //VentaId = pedidoOrden.VentaId,
                                    Cancelada = pedidoOrden.Cancelada,
                                    FechaCancelacion = pedidoOrden.FechaCancelacion,
                                    CanceladoPor = pedidoOrden.CanceladoPor,
                                    UberEats = pedidoOrden.UberEats,
                                    Para = pedidoOrden.Para,
                                    Notas = pedidoOrden.Notas,
                                    CargoId = pedidoOrden.CargoId,
                                    CajaId = pedidoOrden.CajaId,
                                    TipoPedidoId = pedidoOrden.TipoPedidoId,
                                    Folio = pedidoOrden.Folio,
                                    Facturar = pedidoOrden.Facturar,
                                    SucursalCobroId = pedidoOrden.SucursalCobroId,
                                    Credito = pedidoOrden.Credito
                                };

                                this.contextNube.doc_pedidos_orden.Add(exists);
                                this.contextNube.SaveChanges();

                                //INSERTAR doc_pedidos_orden_detalle
                                foreach (doc_pedidos_orden_detalle itemPedidoOrdenDetalle in listaPedidosOrdenDetalle.Where(w=> w.PedidoId == pedidoOrden.PedidoId))
                                {
                                    doc_pedidos_orden_detalle itemPedidoOrdenDetalleNEW = new doc_pedidos_orden_detalle();

                                    itemPedidoOrdenDetalleNEW.Cancelado = itemPedidoOrdenDetalle.Cancelado;
                                    itemPedidoOrdenDetalleNEW.Cantidad = itemPedidoOrdenDetalle.Cantidad;
                                    itemPedidoOrdenDetalleNEW.CantidadDevolucion = itemPedidoOrdenDetalle.CantidadDevolucion;
                                    itemPedidoOrdenDetalleNEW.CantidadOriginal = itemPedidoOrdenDetalle.CantidadOriginal;
                                    itemPedidoOrdenDetalleNEW.CargoAdicionalId = itemPedidoOrdenDetalle.CargoAdicionalId;
                                    itemPedidoOrdenDetalleNEW.CargoAdicionalMonto = itemPedidoOrdenDetalle.CargoAdicionalMonto;
                                    itemPedidoOrdenDetalleNEW.ComandaId = itemPedidoOrdenDetalle.ComandaId;
                                    itemPedidoOrdenDetalleNEW.CreadoEl = itemPedidoOrdenDetalle.CreadoEl;
                                    itemPedidoOrdenDetalleNEW.CreadoPor = itemPedidoOrdenDetalle.CreadoPor;
                                    itemPedidoOrdenDetalleNEW.Descripcion = itemPedidoOrdenDetalle.Descripcion;
                                    itemPedidoOrdenDetalleNEW.Descuento = itemPedidoOrdenDetalle.Descuento;
                                    itemPedidoOrdenDetalleNEW.Impreso = itemPedidoOrdenDetalle.Impreso;
                                    itemPedidoOrdenDetalleNEW.Impuestos = itemPedidoOrdenDetalle.Impuestos;
                                    itemPedidoOrdenDetalleNEW.Notas = itemPedidoOrdenDetalle.Notas;
                                    itemPedidoOrdenDetalleNEW.Parallevar = itemPedidoOrdenDetalle.Parallevar;
                                    itemPedidoOrdenDetalleNEW.PedidoDetalleId = (this.contextNube.doc_pedidos_orden_detalle.Max(m=> (int?)m.PedidoDetalleId)??0)+1;
                                    itemPedidoOrdenDetalleNEW.PedidoId = exists.PedidoId;
                                    itemPedidoOrdenDetalleNEW.PorcDescuento = itemPedidoOrdenDetalle.PorcDescuento;
                                    itemPedidoOrdenDetalleNEW.PrecioUnitario = itemPedidoOrdenDetalle.PrecioUnitario;
                                    itemPedidoOrdenDetalleNEW.ProductoId = itemPedidoOrdenDetalle.ProductoId;
                                    itemPedidoOrdenDetalleNEW.PromocionCMId = itemPedidoOrdenDetalle.PromocionCMId;
                                    itemPedidoOrdenDetalleNEW.TasaIVA = itemPedidoOrdenDetalle.TasaIVA;
                                    itemPedidoOrdenDetalleNEW.TipoDescuentoId = itemPedidoOrdenDetalle.TipoDescuentoId;
                                    itemPedidoOrdenDetalleNEW.Total = itemPedidoOrdenDetalle.Total;
                                   
                                    this.contextNube.doc_pedidos_orden_detalle.Add(itemPedidoOrdenDetalleNEW);
                                    this.contextNube.SaveChanges();
                                }

                                //INSERTAR doc_venta
                                doc_ventas itemVenta = listaVentas.Where(w=> w.VentaId == pedidoOrden.VentaId).FirstOrDefault();

                                if(itemVenta != null)
                                {
                                    doc_ventas itemVentaNEW = new doc_ventas();

                                    itemVentaNEW.VentaId = (this.contextNube.doc_ventas.Max(m => (int?)m.VentaId) ?? 0) + 1;
                                    itemVentaNEW.Activo = itemVenta.Activo;
                                    itemVentaNEW.CajaId = itemVenta.CajaId;
                                    itemVentaNEW.Cambio = itemVenta.Cambio;
                                    itemVentaNEW.ClienteId = itemVenta.ClienteId;
                                    itemVentaNEW.DescuentoEnPartidas = itemVenta.DescuentoEnPartidas;
                                    itemVentaNEW.DescuentoVentaSiNo = itemVenta.DescuentoVentaSiNo;
                                    itemVentaNEW.EmpleadoId = itemVenta.EmpleadoId;
                                    itemVentaNEW.Facturar = itemVenta.Facturar;
                                    itemVentaNEW.Fecha = itemVenta.Fecha;
                                    itemVentaNEW.FechaCancelacion = itemVenta.FechaCancelacion;
                                    itemVentaNEW.FechaCreacion = itemVenta.FechaCreacion;
                                    itemVentaNEW.Folio = itemVenta.Folio;
                                    itemVentaNEW.Impuestos = itemVenta.Impuestos;
                                    itemVentaNEW.MontoDescuentoVenta = itemVenta.MontoDescuentoVenta;
                                    itemVentaNEW.MotivoCancelacion = itemVenta.MotivoCancelacion;
                                    itemVentaNEW.PorcDescuentoVenta = itemVenta.PorcDescuentoVenta;
                                    itemVentaNEW.Rec = itemVenta.Rec;
                                    itemVentaNEW.Serie = itemVenta.Serie;
                                    itemVentaNEW.SubTotal = itemVenta.SubTotal;
                                    itemVentaNEW.SucursalId = itemVenta.SucursalId;
                                    itemVentaNEW.TotalDescuento = itemVenta.TotalDescuento;
                                    itemVentaNEW.TotalRecibido = itemVenta.TotalRecibido;
                                    itemVentaNEW.TotalVenta = itemVenta.TotalVenta;
                                    itemVentaNEW.UsuarioCancelacionId = itemVenta.UsuarioCancelacionId;
                                    itemVentaNEW.UsuarioCreacionId = itemVenta.UsuarioCreacionId;
                                    

                                    this.contextNube.doc_ventas.Add(itemVentaNEW);

                                    this.contextNube.SaveChanges();

                                    //INSERTAR VENTA DETALLE
                                    foreach (doc_ventas_detalle itemVentaDetalle in listaVentasDetalle.Where(W=> W.VentaId == itemVenta.VentaId))
                                    {
                                        doc_ventas_detalle itemVentaDetalleNEW = new doc_ventas_detalle();

                                        itemVentaDetalleNEW.VentaDetalleId = (this.contextNube.doc_ventas_detalle.Max(m => (int?)m.VentaDetalleId) ?? 0) + 1;
                                        itemVentaDetalleNEW.Cantidad = itemVentaDetalle.Cantidad;
                                        itemVentaDetalleNEW.CargoAdicionalId = itemVentaDetalle.CargoAdicionalId;
                                        itemVentaDetalleNEW.CargoDetalleId = itemVentaDetalle.CargoDetalleId;
                                        itemVentaDetalleNEW.Descripcion = itemVentaDetalle.Descripcion;
                                        itemVentaDetalleNEW.Descuento = itemVentaDetalle.Descuento;
                                        itemVentaDetalleNEW.FechaCreacion = itemVentaDetalle.FechaCreacion;
                                        itemVentaDetalleNEW.Impuestos = itemVentaDetalle.Impuestos;
                                        itemVentaDetalleNEW.ParaLlevar = itemVentaDetalle.ParaLlevar;
                                        itemVentaDetalleNEW.ParaMesa = itemVentaDetalle.ParaMesa;
                                        itemVentaDetalleNEW.PorcDescuneto = itemVentaDetalle.PorcDescuneto;
                                        itemVentaDetalleNEW.PrecioUnitario = itemVentaDetalle.PrecioUnitario;
                                        itemVentaDetalleNEW.ProductoId = itemVentaDetalle.ProductoId;
                                        itemVentaDetalleNEW.PromocionCMId = itemVentaDetalle.PromocionCMId;
                                        itemVentaDetalleNEW.TasaIVA = itemVentaDetalle.TasaIVA;
                                        itemVentaDetalleNEW.TipoDescuentoId = itemVentaDetalle.TipoDescuentoId;
                                        itemVentaDetalleNEW.Total = itemVentaDetalle.Total;
                                        itemVentaDetalleNEW.UsuarioCreacionId = itemVentaDetalle.UsuarioCreacionId;
                                        itemVentaDetalleNEW.VentaId = itemVentaNEW.VentaId;


                                        this.contextNube.doc_ventas_detalle.Add(itemVentaDetalleNEW);
                                        this.contextNube.SaveChanges();
                                    }
                                }

                            }

                        }

                        foreach (doc_ventas itemVentaSP in listaVentas.Where(w=> w.doc_pedidos_orden.Where(s1=>s1.PedidoId > 0).Count() >0))
                        {
                            doc_ventas itemVentaNEWSP = new doc_ventas();

                            itemVentaNEWSP.VentaId = (this.contextNube.doc_ventas.Max(m => (int?)m.VentaId) ?? 0) + 1;
                            itemVentaNEWSP.Activo = itemVentaSP.Activo;
                            itemVentaNEWSP.CajaId = itemVentaSP.CajaId;
                            itemVentaNEWSP.Cambio = itemVentaSP.Cambio;
                            itemVentaNEWSP.ClienteId = itemVentaSP.ClienteId;
                            itemVentaNEWSP.DescuentoEnPartidas = itemVentaSP.DescuentoEnPartidas;
                            itemVentaNEWSP.DescuentoVentaSiNo = itemVentaSP.DescuentoVentaSiNo;
                            itemVentaNEWSP.EmpleadoId = itemVentaSP.EmpleadoId;
                            itemVentaNEWSP.Facturar = itemVentaSP.Facturar;
                            itemVentaNEWSP.Fecha = itemVentaSP.Fecha;
                            itemVentaNEWSP.FechaCancelacion = itemVentaSP.FechaCancelacion;
                            itemVentaNEWSP.FechaCreacion = itemVentaSP.FechaCreacion;
                            itemVentaNEWSP.Folio = itemVentaSP.Folio;
                            itemVentaNEWSP.Impuestos = itemVentaSP.Impuestos;
                            itemVentaNEWSP.MontoDescuentoVenta = itemVentaSP.MontoDescuentoVenta;
                            itemVentaNEWSP.MotivoCancelacion = itemVentaSP.MotivoCancelacion;
                            itemVentaNEWSP.PorcDescuentoVenta = itemVentaSP.PorcDescuentoVenta;
                            itemVentaNEWSP.Rec = itemVentaSP.Rec;
                            itemVentaNEWSP.Serie = itemVentaSP.Serie;
                            itemVentaNEWSP.SubTotal = itemVentaSP.SubTotal;
                            itemVentaNEWSP.SucursalId = itemVentaSP.SucursalId;
                            itemVentaNEWSP.TotalDescuento = itemVentaSP.TotalDescuento;
                            itemVentaNEWSP.TotalRecibido = itemVentaSP.TotalRecibido;
                            itemVentaNEWSP.TotalVenta = itemVentaSP.TotalVenta;
                            itemVentaNEWSP.UsuarioCancelacionId = itemVentaSP.UsuarioCancelacionId;
                            itemVentaNEWSP.UsuarioCreacionId = itemVentaSP.UsuarioCreacionId;

                            this.contextNube.doc_ventas.Add(itemVentaNEWSP);
                            this.contextNube.SaveChanges();

                            foreach (doc_ventas_detalle itemVentaDetalleSP in listaVentasDetalle.Where(w=> w.VentaId== itemVentaSP.VentaId))
                            {
                                doc_ventas_detalle itemVentaDetalleSPNEW = new doc_ventas_detalle();

                                itemVentaDetalleSPNEW.VentaDetalleId = (this.contextNube.doc_ventas_detalle.Max(m => (int?)m.VentaDetalleId) ?? 0) + 1;
                                itemVentaDetalleSPNEW.Cantidad = itemVentaDetalleSP.Cantidad;
                                itemVentaDetalleSPNEW.CargoAdicionalId = itemVentaDetalleSP.CargoAdicionalId;
                                itemVentaDetalleSPNEW.CargoDetalleId = itemVentaDetalleSP.CargoDetalleId;
                                itemVentaDetalleSPNEW.Descripcion = itemVentaDetalleSP.Descripcion;
                                itemVentaDetalleSPNEW.Descuento = itemVentaDetalleSP.Descuento;
                                itemVentaDetalleSPNEW.FechaCreacion = itemVentaDetalleSP.FechaCreacion;
                                itemVentaDetalleSPNEW.Impuestos = itemVentaDetalleSP.Impuestos;
                                itemVentaDetalleSPNEW.ParaLlevar = itemVentaDetalleSP.ParaLlevar;
                                itemVentaDetalleSPNEW.ParaMesa = itemVentaDetalleSP.ParaMesa;
                                itemVentaDetalleSPNEW.PorcDescuneto = itemVentaDetalleSP.PorcDescuneto;
                                itemVentaDetalleSPNEW.PrecioUnitario = itemVentaDetalleSP.PrecioUnitario;
                                itemVentaDetalleSPNEW.ProductoId = itemVentaDetalleSP.ProductoId;
                                itemVentaDetalleSPNEW.PromocionCMId = itemVentaDetalleSP.PromocionCMId;
                                itemVentaDetalleSPNEW.TasaIVA = itemVentaDetalleSP.TasaIVA;
                                itemVentaDetalleSPNEW.TipoDescuentoId = itemVentaDetalleSP.TipoDescuentoId;
                                itemVentaDetalleSPNEW.Total = itemVentaDetalleSP.Total;
                                itemVentaDetalleSPNEW.UsuarioCreacionId = itemVentaDetalleSP.UsuarioCreacionId;
                                itemVentaDetalleSPNEW.VentaId = itemVentaNEWSP.VentaId;


                                this.contextNube.doc_ventas_detalle.Add(itemVentaDetalleSPNEW);
                                this.contextNube.SaveChanges();
                            }
                        }
                        dbContextTransaction.Rollback();
                    }
                    catch (Exception ex)
                    {
                        dbContextTransaction.Rollback();
                        err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                                      "ERP",
                                                                      "ERP.Business.SincronizacionBusiness.ExportPedidosOrden",
                                                                      ex);
                        return false;
                    }
                }

                // Eliminar los registros exportados de la base de datos local
                //this.contextLocal.Database.ExecuteSqlCommand("DELETE FROM doc_pedidos_orden");


                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Pedidos y Ventas", Exitoso = true, Detalle = "" });

                return true;
            }
            catch (Exception ex)
            {
                // Manejo de errores
                err = ERP.Business.SisBitacoraBusiness.Insert(1,
                                                              "ERP",
                                                              "ERP.Business.SincronizacionBusiness.ExportPedidosOrden",
                                                              ex);
                lstResultado.Add(new SincronizaResultadoModel() { Tipo = "Exportar", Entidad = "Pedidos y Ventas", Exitoso = false, Detalle = String.Format("Bitácora error:{0}", err.ToString()) });

                return false;
            }
        }

        public void ImportarExportar()
        {
            this.lstResultado = new List<SincronizaResultadoModel>();

            this.ImportarALocal();
            this.ExportANube();
        }
    }
}
