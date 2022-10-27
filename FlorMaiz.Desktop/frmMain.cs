﻿using ConexionBD;
using ConexionBD.Models;
using DevExpress.XtraEditors;
using DevExpress.XtraReports.UI;

using ERP.Common.Basculas;
using ERP.Common.Catalogos;
using ERP.Common.Inventarios;
using ERP.Common.Productos;
using ERP.Common.PuntoVenta;
using ERP.Common.Seguridad;
using ERP.Common.Traspasos;
using ERP.Common.Utils;
using ERP.Common.Ventas;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.Entity;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FlorMaiz.Desktop
{
    public partial class frmMain : XtraForm
    {
        string error = "";
        ERPProdEntities oContext;
        public PuntoVentaContext puntoVentaContext;
        private static frmMain _instance;

        public static frmMain GetInstance()
        {
            if (_instance == null) _instance = new frmMain();
            else _instance.BringToFront();
            return _instance;
        }
       
        public frmMain()
        {
            InitializeComponent();
        }

        private void ribbonControl1_Click(object sender, EventArgs e)
        {

        }

        private void frmMain_Load(object sender, EventArgs e)
        {
            oContext = new ERPProdEntities();
            if(oContext.sis_preferencias_empresa
                .Where(w=> w.sis_preferencias.Preferencia == "PermitirEntradaDirectaPV").Count() > 0)
            {
                uiEntradaDirecta.Visibility = DevExpress.XtraBars.BarItemVisibility.Always;
            }
            else
            {
                uiEntradaDirecta.Visibility = DevExpress.XtraBars.BarItemVisibility.Never;
            }

            if(ERP.Business.PreferenciaBusiness.AplicaPreferencia(this.puntoVentaContext.empresaId,
                this.puntoVentaContext.sucursalId, "PVBotonRegistroBasculaPedidosApp", this.puntoVentaContext.usuarioId))
            {
                frmBasculaExpressVenta frmo = frmBasculaExpressVenta.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    frmo.WindowState = FormWindowState.Maximized;
                    frmo.Show();
                }
            }
            else
            {
                frmPuntoVenta frmo = frmPuntoVenta.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.MdiParent = this;
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.WindowState = FormWindowState.Maximized;
                    frmo.Show();

                }
            }
            
        }

        private void uiMenuNuevaVenta_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmPuntoVenta frmo = frmPuntoVenta.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.Show();
               

            }
            else
            {               
                frmo.inicializar();
            }
        }

        private void uiMenuConfigBascula_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            BasculaConfiguracion frmo = BasculaConfiguracion.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.Show();

            }
        }

        private void frmMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();

        }

        private void barButtonItem1_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmVentasList frmo = frmVentasList.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.StartPosition = FormStartPosition.CenterScreen;
                frmo.Show();

            }
        }

        private void barButtonItem2_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            BasculaConfiguracion frmo = BasculaConfiguracion.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.Show();

            }
        }

        private void barButtonItem3_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            oContext = new ERPProdEntities();

            cat_configuracion entity = oContext.cat_configuracion.FirstOrDefault();

            bool abrir = false;

            if (entity.RetiroReqClaveSup ?? false)
            {
                frmAdminPass oForm = new frmAdminPass();

                oForm.StartPosition = FormStartPosition.CenterScreen;
                oForm.ShowDialog();

                if (oForm.DialogResult == DialogResult.OK)
                {
                    abrir = true;
                }

            }
            else
            {
                abrir = true;

            }

            if (abrir)
            {
                string error = RawPrinterHelper.AbreCajon(this.puntoVentaContext.nombreImpresoraCaja);
                if (error.Length > 0)
                {
                    XtraMessageBox.Show(error, "ERROR", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }

                frmRetiros frm = new frmRetiros();
                frm.puntoVentaContext = this.puntoVentaContext;
                frm.ShowDialog();
            }

        }

        private void barButtonItem4_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            oContext = new ERPProdEntities();

            cat_configuracion entity = oContext.cat_configuracion.FirstOrDefault();

            bool abrir = false;

            if (entity.ReqClaveSupGastosPV ?? false)
            {
                frmAdminPass oForm = new frmAdminPass();

                oForm.StartPosition = FormStartPosition.CenterScreen;
                oForm.ShowDialog();

                if (oForm.DialogResult == DialogResult.OK)
                {
                    abrir = true;
                }

            }
            else
            {
                abrir = true;

            }

            if (abrir)
            {
                abrirGastos();
            }
        }

        public void abrirGastos()
        {
            string error = RawPrinterHelper.AbreCajon(this.puntoVentaContext.nombreImpresoraCaja);
            if (error.Length > 0)
            {
                XtraMessageBox.Show(error, "ERROR", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

            frmGastosList frmo = frmGastosList.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.MdiParent = this;
                frmo.Show();
            }
        }

        private void barButtonItem6_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {

            frmAdminPass oForm = new frmAdminPass();
            oForm.WindowState = FormWindowState.Normal;
            oForm.StartPosition = FormStartPosition.CenterScreen;

            oForm.ShowDialog();

            if (oForm.DialogResult == DialogResult.OK)
            {
                frmImpresoras frmo = frmImpresoras.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    frmo.WindowState = FormWindowState.Maximized;
                    frmo.Show();
                }
            }
        }

        private void barButtonItem7_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmAdminPass oForm = new frmAdminPass();
            oForm.WindowState = FormWindowState.Normal;
            oForm.StartPosition = FormStartPosition.CenterScreen;

            oForm.ShowDialog();

            if (oForm.DialogResult == DialogResult.OK)
            {
                frmCajasImpresoras frmo = frmCajasImpresoras.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    frmo.WindowState = FormWindowState.Normal;
                    frmo.Show();
                }
            }
        }

        private void barButtonItem8_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            if (puntoVentaContext.esSupervisor)
            {
                try
                {
                    oContext = new ERPProdEntities();

                    int sesionId = puntoVentaContext.sesionId;
                    doc_sesiones_punto_venta entity = oContext.doc_sesiones_punto_venta
                        .Where(w => w.SesionId == sesionId).FirstOrDefault();

                    entity.Finalizada = true;
                    entity.FechaUltimaConexion = oContext.p_GetDateTimeServer().FirstOrDefault().Value;

                    oContext.SaveChanges();

                    this.Close();
                    // System.Windows.Forms.Application.Exit();
                }
                catch (Exception ex)
                {

                    MessageBox.Show(ex.Message, "ERROR", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            else
            {
                this.Close();
            }
        }

        private void barButtonItem9_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            if (!ERP.Business.PreferenciaBusiness.AplicaPreferencia(this.puntoVentaContext.empresaId,
                this.puntoVentaContext.sucursalId,
                "PVCorteCajaOcultarDetalleCajero",this.puntoVentaContext.usuarioId))
            {
                frmCorteCajaGen frmo = frmCorteCajaGen.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    frmo.Show();
                }
            }
            else
            {
                frmCorteCajaGen frmo = frmCorteCajaGen.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    if (frmo.generarCorteCaja(false,false))
                    {
                        error = ERP.Business.CorteCajaBusiness.imprimirCorteCajero(puntoVentaContext.sucursalId,puntoVentaContext.cajaId,puntoVentaContext.usuarioId);
                        
                        if (error.Length > 0)
                        {
                            ERP.Utils.MessageBoxUtil.ShowError(error);
                        }
                        else
                        {
                            ERP.Utils.MessageBoxUtil.ShowWarning("SE REINICIARÁ EL SISTEMA");
                            System.Diagnostics.Process.Start(Application.ExecutablePath); // to start new instance of application
                            Application.Exit();
                            this.Close();
                        }
                        
                    }
                }
            }
            
        }

   
        private void timerClearMemoryData_Tick(object sender, EventArgs e)
        {
            //ERP.Business.DataMemory.DataBucket.ClearData();
        }

        private void barButtonItem10_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
           
            frmBasculaExpressVenta frmo = frmBasculaExpressVenta.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.MdiParent = this;
                frmo.Show();
            }
        }

        private void uiProductoSobrante_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {           

            frmSobrantesRegistro oForm = new frmSobrantesRegistro();

            oForm.dtProcess = oContext.p_GetDateTimeServer().FirstOrDefault().Value;
            oForm.habilitarFecha = false;
            oForm.puntoVentaContext = this.puntoVentaContext;
            oForm.StartPosition = FormStartPosition.CenterScreen;
            oForm.ShowDialog();
        }

        private void barButtonItem11_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmCapturaInventarioReal frmo = frmCapturaInventarioReal.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.MdiParent = this;
                frmo.Show();
            }
        }

        private void barButtonItem12_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmAceptacionSucursal frmo = frmAceptacionSucursal.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.MdiParent = this;
                frmo.Show();
            }
        }

        private void btnDesperdicioMasa_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmRecepcionProducto frmo = frmRecepcionProducto.GetInstance();
            if (!frmo.Visible)
            {
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.StartPosition = FormStartPosition.CenterScreen;
                frmo.WindowState = FormWindowState.Normal;
                frmo.tipoMovimiento = Enumerados.tipoMovsInventario.desperdicioInventario;
                frmo.ClaveProductoDefault = "2";
                frmo.ShowDialog();
            }
        }

        private void uiDesperdicioTortilla_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmRecepcionProducto frmo = frmRecepcionProducto.GetInstance();
            if (!frmo.Visible)
            {
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.StartPosition = FormStartPosition.CenterScreen;
                frmo.WindowState = FormWindowState.Normal;
                frmo.tipoMovimiento = Enumerados.tipoMovsInventario.desperdicioInventario;
                frmo.ClaveProductoDefault = "1";
                frmo.ShowDialog();
            }
        }

        private void uiTraspasos_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmTraspasosSalidaLite frmo = frmTraspasosSalidaLite.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.MdiParent = frmMain.GetInstance();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.WindowState = FormWindowState.Maximized;

                frmo.Show();

            }
        }

        private void uiDevoluciones_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            abrirDevoluciones();
        }

        public void abrirDevoluciones()
        {
            frmDevoluciones frmo = frmDevoluciones.GetInstance();

            if (!frmo.Visible)
            {
                //frmo = new frmPuntoVenta();
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.MdiParent = this;

                frmo.Show();
            }
        }

        private void uiEntradaDirecta_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmRecepcionProducto frmo = frmRecepcionProducto.GetInstance();
            if (!frmo.Visible)
            {
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.StartPosition = FormStartPosition.CenterScreen;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.tipoMovimiento = Enumerados.tipoMovsInventario.entradaDirecta;
                frmo.Show();
            }
        }

        private void uiSalidaDirecta_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmRecepcionProducto frmo = frmRecepcionProducto.GetInstance();
            if (!frmo.Visible)
            {
                frmo.MdiParent = this;
                frmo.puntoVentaContext = this.puntoVentaContext;
                frmo.StartPosition = FormStartPosition.CenterScreen;
                frmo.WindowState = FormWindowState.Maximized;
                frmo.tipoMovimiento = Enumerados.tipoMovsInventario.ajustePorSalida;
                frmo.Show();
            }
        }

        private void uiSincronizar_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            ERP.Business.DataMemory.DataBucket.GetProductosMemory(true);
            ERP.Business.DataMemory.DataBucket.GetClientesProductosPrecios(true);
            ERP.Business.DataMemory.DataBucket.GetFamiliasMemory(true);
            ERP.Business.DataMemory.DataBucket.GetProductosProduccionMemory(true, ERP.Business.Enumerados.tipoProductoProduccion.TODO);
        }

        private void uiMnuBascula_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            try
            {
                if (Process.GetProcessesByName("ERP.Background.Task").Count() > 0)
                {
                    ERP.Utils.MessageBoxUtil.ShowWarning("Ya existe una instanacia de la tarea abierta");
                }
                else
                {
                    Process p = new Process();
                    ProcessStartInfo psi = new ProcessStartInfo(@"Bascula\ERP.Background.Task.exe");

                    p.StartInfo = psi;
                    p.Start();
                }
            }
            catch (Exception ex)
            {

                int err = ERP.Business.SisBitacoraBusiness.Insert(frmMain.GetInstance().puntoVentaContext.usuarioId,
                                       "ERP",
                                       this.Name,
                                       ex);
                ERP.Utils.MessageBoxUtil.ShowErrorBita(err);
            }
            
        }

        private void btnReimprimirUltimoCorteCajero_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            ERP.Business.CorteCajaBusiness.imprimirCorteCajero(puntoVentaContext.sucursalId, puntoVentaContext.cajaId, puntoVentaContext.usuarioId);
        }

        private void frmMain_HelpButtonClicked(object sender, CancelEventArgs e)
        {

        }

        private void frmMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            oContext = new ERPProdEntities();

            int sesionId = puntoVentaContext.sesionId;
            doc_sesiones_punto_venta entity = oContext.doc_sesiones_punto_venta
                .Where(w => w.SesionId == sesionId).FirstOrDefault();

            entity.Finalizada = true;
            entity.FechaUltimaConexion = oContext.p_GetDateTimeServer().FirstOrDefault().Value;

            oContext.SaveChanges();

        }

        private void uiMenuReimprimirCorteSupervisor_ItemClick(object sender, DevExpress.XtraBars.ItemClickEventArgs e)
        {
            frmAdminPass oForm = new frmAdminPass();

            oForm.StartPosition = FormStartPosition.CenterScreen;
            oForm.ShowDialog();

            if (oForm.DialogResult == DialogResult.OK)
            {
                frmCorteCajaGen frmo = frmCorteCajaGen.GetInstance();

                if (!frmo.Visible)
                {
                    //frmo = new frmPuntoVenta();
                    frmo.puntoVentaContext = this.puntoVentaContext;
                    frmo.MdiParent = this;
                    frmo.Show();
                }
            }
            
        }
    }
}
