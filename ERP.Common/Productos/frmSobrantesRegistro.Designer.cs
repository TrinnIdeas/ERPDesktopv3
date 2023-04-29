﻿namespace ERP.Common.Productos
{
    partial class frmSobrantesRegistro
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmSobrantesRegistro));
            this.layoutControl1 = new DevExpress.XtraLayout.LayoutControl();
            this.labelControl2 = new DevExpress.XtraEditors.LabelControl();
            this.uiFecha = new DevExpress.XtraEditors.DateEdit();
            this.uiTerminar = new DevExpress.XtraEditors.SimpleButton();
            this.uiSalir = new DevExpress.XtraEditors.SimpleButton();
            this.uiGuardar = new DevExpress.XtraEditors.SimpleButton();
            this.uiGrid = new DevExpress.XtraGrid.GridControl();
            this.pproductossobrantesgrdResultBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.uiGridView = new DevExpress.XtraGrid.Views.Grid.GridView();
            this.colProductoId = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colClave = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colDescripcion = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colExistencia = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colFecha = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colCantidadSobrante = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colRequiereBascula = new DevExpress.XtraGrid.Columns.GridColumn();
            this.colRepDevolucion = new DevExpress.XtraGrid.Columns.GridColumn();
            this.repDevCocina = new DevExpress.XtraEditors.Repository.RepositoryItemCalcEdit();
            this.labelControl1 = new DevExpress.XtraEditors.LabelControl();
            this.layoutControlGroup1 = new DevExpress.XtraLayout.LayoutControlGroup();
            this.layoutControlItem1 = new DevExpress.XtraLayout.LayoutControlItem();
            this.layoutControlItem2 = new DevExpress.XtraLayout.LayoutControlItem();
            this.layoutControlItem3 = new DevExpress.XtraLayout.LayoutControlItem();
            this.layoutControlItem4 = new DevExpress.XtraLayout.LayoutControlItem();
            this.layoutControlItem5 = new DevExpress.XtraLayout.LayoutControlItem();
            this.layoutControlItem6 = new DevExpress.XtraLayout.LayoutControlItem();
            this.emptySpaceItem1 = new DevExpress.XtraLayout.EmptySpaceItem();
            this.layoutControlItem7 = new DevExpress.XtraLayout.LayoutControlItem();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControl1)).BeginInit();
            this.layoutControl1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.uiFecha.Properties.CalendarTimeProperties)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiFecha.Properties)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiGrid)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pproductossobrantesgrdResultBindingSource)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiGridView)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.repDevCocina)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlGroup1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem5)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem6)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.emptySpaceItem1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem7)).BeginInit();
            this.SuspendLayout();
            // 
            // layoutControl1
            // 
            this.layoutControl1.Controls.Add(this.labelControl2);
            this.layoutControl1.Controls.Add(this.uiFecha);
            this.layoutControl1.Controls.Add(this.uiTerminar);
            this.layoutControl1.Controls.Add(this.uiSalir);
            this.layoutControl1.Controls.Add(this.uiGuardar);
            this.layoutControl1.Controls.Add(this.uiGrid);
            this.layoutControl1.Controls.Add(this.labelControl1);
            this.layoutControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.layoutControl1.Location = new System.Drawing.Point(0, 0);
            this.layoutControl1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.layoutControl1.Name = "layoutControl1";
            this.layoutControl1.OptionsView.UseDefaultDragAndDropRendering = false;
            this.layoutControl1.Root = this.layoutControlGroup1;
            this.layoutControl1.Size = new System.Drawing.Size(1058, 586);
            this.layoutControl1.TabIndex = 0;
            this.layoutControl1.Text = "layoutControl1";
            // 
            // labelControl2
            // 
            this.labelControl2.Appearance.BackColor = System.Drawing.Color.Yellow;
            this.labelControl2.Appearance.Font = new System.Drawing.Font("Tahoma", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelControl2.Appearance.ForeColor = System.Drawing.Color.Black;
            this.labelControl2.Appearance.Options.UseBackColor = true;
            this.labelControl2.Appearance.Options.UseFont = true;
            this.labelControl2.Appearance.Options.UseForeColor = true;
            this.labelControl2.Location = new System.Drawing.Point(5, 63);
            this.labelControl2.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.labelControl2.Name = "labelControl2";
            this.labelControl2.Size = new System.Drawing.Size(457, 18);
            this.labelControl2.StyleController = this.layoutControl1;
            this.labelControl2.TabIndex = 10;
            this.labelControl2.Text = "Para abrir la báscula dar clic en el check de Requiere Báscula";
            // 
            // uiFecha
            // 
            this.uiFecha.EditValue = null;
            this.uiFecha.Location = new System.Drawing.Point(185, 35);
            this.uiFecha.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.uiFecha.Name = "uiFecha";
            this.uiFecha.Properties.Buttons.AddRange(new DevExpress.XtraEditors.Controls.EditorButton[] {
            new DevExpress.XtraEditors.Controls.EditorButton(DevExpress.XtraEditors.Controls.ButtonPredefines.Combo)});
            this.uiFecha.Properties.CalendarTimeProperties.Buttons.AddRange(new DevExpress.XtraEditors.Controls.EditorButton[] {
            new DevExpress.XtraEditors.Controls.EditorButton(DevExpress.XtraEditors.Controls.ButtonPredefines.Combo)});
            this.uiFecha.Size = new System.Drawing.Size(340, 22);
            this.uiFecha.StyleController = this.layoutControl1;
            this.uiFecha.TabIndex = 9;
            // 
            // uiTerminar
            // 
            this.uiTerminar.ImageOptions.Image = ((System.Drawing.Image)(resources.GetObject("uiTerminar.ImageOptions.Image")));
            this.uiTerminar.ImageOptions.ImageToTextAlignment = DevExpress.XtraEditors.ImageAlignToText.LeftCenter;
            this.uiTerminar.Location = new System.Drawing.Point(370, 541);
            this.uiTerminar.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.uiTerminar.Name = "uiTerminar";
            this.uiTerminar.Size = new System.Drawing.Size(369, 40);
            this.uiTerminar.StyleController = this.layoutControl1;
            this.uiTerminar.TabIndex = 8;
            this.uiTerminar.Text = "TERMINAR Y AFECTAR INVENTARIO";
            this.uiTerminar.Click += new System.EventHandler(this.uiTerminar_Click);
            // 
            // uiSalir
            // 
            this.uiSalir.ImageOptions.Image = ((System.Drawing.Image)(resources.GetObject("uiSalir.ImageOptions.Image")));
            this.uiSalir.ImageOptions.ImageToTextAlignment = DevExpress.XtraEditors.ImageAlignToText.LeftCenter;
            this.uiSalir.Location = new System.Drawing.Point(745, 541);
            this.uiSalir.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.uiSalir.Name = "uiSalir";
            this.uiSalir.Size = new System.Drawing.Size(308, 40);
            this.uiSalir.StyleController = this.layoutControl1;
            this.uiSalir.TabIndex = 7;
            this.uiSalir.Text = "SALIR";
            this.uiSalir.Click += new System.EventHandler(this.uiSalir_Click);
            // 
            // uiGuardar
            // 
            this.uiGuardar.ImageOptions.Image = ((System.Drawing.Image)(resources.GetObject("uiGuardar.ImageOptions.Image")));
            this.uiGuardar.ImageOptions.ImageToTextAlignment = DevExpress.XtraEditors.ImageAlignToText.LeftCenter;
            this.uiGuardar.Location = new System.Drawing.Point(5, 541);
            this.uiGuardar.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.uiGuardar.Name = "uiGuardar";
            this.uiGuardar.Size = new System.Drawing.Size(359, 40);
            this.uiGuardar.StyleController = this.layoutControl1;
            this.uiGuardar.TabIndex = 6;
            this.uiGuardar.Text = "GUARDAR";
            this.uiGuardar.Click += new System.EventHandler(this.uiGuardar_Click);
            // 
            // uiGrid
            // 
            this.uiGrid.DataSource = this.pproductossobrantesgrdResultBindingSource;
            this.uiGrid.EmbeddedNavigator.Margin = new System.Windows.Forms.Padding(3, 5, 3, 5);
            this.uiGrid.Location = new System.Drawing.Point(5, 87);
            this.uiGrid.MainView = this.uiGridView;
            this.uiGrid.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.uiGrid.Name = "uiGrid";
            this.uiGrid.RepositoryItems.AddRange(new DevExpress.XtraEditors.Repository.RepositoryItem[] {
            this.repDevCocina});
            this.uiGrid.Size = new System.Drawing.Size(1048, 448);
            this.uiGrid.TabIndex = 5;
            this.uiGrid.ViewCollection.AddRange(new DevExpress.XtraGrid.Views.Base.BaseView[] {
            this.uiGridView});
            // 
            // pproductossobrantesgrdResultBindingSource
            // 
            this.pproductossobrantesgrdResultBindingSource.DataSource = typeof(ConexionBD.p_productos_sobrantes_grd_Result);
            // 
            // uiGridView
            // 
            this.uiGridView.Columns.AddRange(new DevExpress.XtraGrid.Columns.GridColumn[] {
            this.colProductoId,
            this.colClave,
            this.colDescripcion,
            this.colExistencia,
            this.colFecha,
            this.colCantidadSobrante,
            this.colRequiereBascula,
            this.colRepDevolucion});
            this.uiGridView.GridControl = this.uiGrid;
            this.uiGridView.Name = "uiGridView";
            this.uiGridView.OptionsView.ShowGroupPanel = false;
            this.uiGridView.RowClick += new DevExpress.XtraGrid.Views.Grid.RowClickEventHandler(this.uiGridView_RowClick);
            this.uiGridView.RowCellClick += new DevExpress.XtraGrid.Views.Grid.RowCellClickEventHandler(this.uiGridView_RowCellClick);
            this.uiGridView.ShowingEditor += new System.ComponentModel.CancelEventHandler(this.uiGridView_ShowingEditor);
            // 
            // colProductoId
            // 
            this.colProductoId.Caption = "ProductoID";
            this.colProductoId.FieldName = "ProductoId";
            this.colProductoId.Name = "colProductoId";
            this.colProductoId.OptionsColumn.AllowEdit = false;
            this.colProductoId.Visible = true;
            this.colProductoId.VisibleIndex = 0;
            this.colProductoId.Width = 73;
            // 
            // colClave
            // 
            this.colClave.FieldName = "Clave";
            this.colClave.Name = "colClave";
            this.colClave.OptionsColumn.AllowEdit = false;
            this.colClave.Visible = true;
            this.colClave.VisibleIndex = 1;
            this.colClave.Width = 93;
            // 
            // colDescripcion
            // 
            this.colDescripcion.FieldName = "Descripcion";
            this.colDescripcion.Name = "colDescripcion";
            this.colDescripcion.OptionsColumn.AllowEdit = false;
            this.colDescripcion.Visible = true;
            this.colDescripcion.VisibleIndex = 2;
            this.colDescripcion.Width = 364;
            // 
            // colExistencia
            // 
            this.colExistencia.FieldName = "Existencia";
            this.colExistencia.Name = "colExistencia";
            this.colExistencia.OptionsColumn.AllowEdit = false;
            this.colExistencia.Width = 87;
            // 
            // colFecha
            // 
            this.colFecha.FieldName = "Fecha";
            this.colFecha.Name = "colFecha";
            this.colFecha.OptionsColumn.AllowEdit = false;
            this.colFecha.Visible = true;
            this.colFecha.VisibleIndex = 3;
            this.colFecha.Width = 96;
            // 
            // colCantidadSobrante
            // 
            this.colCantidadSobrante.FieldName = "CantidadSobrante";
            this.colCantidadSobrante.Name = "colCantidadSobrante";
            this.colCantidadSobrante.Visible = true;
            this.colCantidadSobrante.VisibleIndex = 4;
            this.colCantidadSobrante.Width = 137;
            // 
            // colRequiereBascula
            // 
            this.colRequiereBascula.FieldName = "RequiereBascula";
            this.colRequiereBascula.Name = "colRequiereBascula";
            this.colRequiereBascula.OptionsColumn.AllowEdit = false;
            this.colRequiereBascula.Visible = true;
            this.colRequiereBascula.VisibleIndex = 6;
            this.colRequiereBascula.Width = 108;
            // 
            // colRepDevolucion
            // 
            this.colRepDevolucion.Caption = "Dev. Cocina";
            this.colRepDevolucion.ColumnEdit = this.repDevCocina;
            this.colRepDevolucion.FieldName = "CantidadDevolucionCocina";
            this.colRepDevolucion.Name = "colRepDevolucion";
            this.colRepDevolucion.Visible = true;
            this.colRepDevolucion.VisibleIndex = 5;
            this.colRepDevolucion.Width = 157;
            // 
            // repDevCocina
            // 
            this.repDevCocina.AutoHeight = false;
            this.repDevCocina.Buttons.AddRange(new DevExpress.XtraEditors.Controls.EditorButton[] {
            new DevExpress.XtraEditors.Controls.EditorButton(DevExpress.XtraEditors.Controls.ButtonPredefines.Combo)});
            this.repDevCocina.Name = "repDevCocina";
            // 
            // labelControl1
            // 
            this.labelControl1.Appearance.Font = new System.Drawing.Font("Tahoma", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Underline))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelControl1.Appearance.Options.UseFont = true;
            this.labelControl1.Location = new System.Drawing.Point(5, 5);
            this.labelControl1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.labelControl1.Name = "labelControl1";
            this.labelControl1.Size = new System.Drawing.Size(209, 24);
            this.labelControl1.StyleController = this.layoutControl1;
            this.labelControl1.TabIndex = 4;
            this.labelControl1.Text = "Productos Sobrantes";
            // 
            // layoutControlGroup1
            // 
            this.layoutControlGroup1.EnableIndentsWithoutBorders = DevExpress.Utils.DefaultBoolean.True;
            this.layoutControlGroup1.GroupBordersVisible = false;
            this.layoutControlGroup1.Items.AddRange(new DevExpress.XtraLayout.BaseLayoutItem[] {
            this.layoutControlItem1,
            this.layoutControlItem2,
            this.layoutControlItem3,
            this.layoutControlItem4,
            this.layoutControlItem5,
            this.layoutControlItem6,
            this.emptySpaceItem1,
            this.layoutControlItem7});
            this.layoutControlGroup1.Name = "layoutControlGroup1";
            this.layoutControlGroup1.OptionsItemText.TextToControlDistance = 5;
            this.layoutControlGroup1.Padding = new DevExpress.XtraLayout.Utils.Padding(2, 2, 2, 2);
            this.layoutControlGroup1.Size = new System.Drawing.Size(1058, 586);
            this.layoutControlGroup1.TextVisible = false;
            // 
            // layoutControlItem1
            // 
            this.layoutControlItem1.Control = this.labelControl1;
            this.layoutControlItem1.Location = new System.Drawing.Point(0, 0);
            this.layoutControlItem1.Name = "layoutControlItem1";
            this.layoutControlItem1.Size = new System.Drawing.Size(1054, 30);
            this.layoutControlItem1.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem1.TextVisible = false;
            // 
            // layoutControlItem2
            // 
            this.layoutControlItem2.Control = this.uiGrid;
            this.layoutControlItem2.Location = new System.Drawing.Point(0, 82);
            this.layoutControlItem2.Name = "layoutControlItem2";
            this.layoutControlItem2.Size = new System.Drawing.Size(1054, 454);
            this.layoutControlItem2.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem2.TextVisible = false;
            // 
            // layoutControlItem3
            // 
            this.layoutControlItem3.Control = this.uiGuardar;
            this.layoutControlItem3.Location = new System.Drawing.Point(0, 536);
            this.layoutControlItem3.Name = "layoutControlItem3";
            this.layoutControlItem3.Size = new System.Drawing.Size(365, 46);
            this.layoutControlItem3.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem3.TextVisible = false;
            // 
            // layoutControlItem4
            // 
            this.layoutControlItem4.Control = this.uiSalir;
            this.layoutControlItem4.Location = new System.Drawing.Point(740, 536);
            this.layoutControlItem4.Name = "layoutControlItem4";
            this.layoutControlItem4.Size = new System.Drawing.Size(314, 46);
            this.layoutControlItem4.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem4.TextVisible = false;
            // 
            // layoutControlItem5
            // 
            this.layoutControlItem5.Control = this.uiTerminar;
            this.layoutControlItem5.Location = new System.Drawing.Point(365, 536);
            this.layoutControlItem5.Name = "layoutControlItem5";
            this.layoutControlItem5.Size = new System.Drawing.Size(375, 46);
            this.layoutControlItem5.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem5.TextVisible = false;
            // 
            // layoutControlItem6
            // 
            this.layoutControlItem6.Control = this.uiFecha;
            this.layoutControlItem6.Location = new System.Drawing.Point(0, 30);
            this.layoutControlItem6.Name = "layoutControlItem6";
            this.layoutControlItem6.Size = new System.Drawing.Size(526, 28);
            this.layoutControlItem6.Text = "Registro de Sobrantes del Día:";
            this.layoutControlItem6.TextSize = new System.Drawing.Size(175, 16);
            // 
            // emptySpaceItem1
            // 
            this.emptySpaceItem1.AllowHotTrack = false;
            this.emptySpaceItem1.Location = new System.Drawing.Point(526, 30);
            this.emptySpaceItem1.Name = "emptySpaceItem1";
            this.emptySpaceItem1.Size = new System.Drawing.Size(528, 28);
            this.emptySpaceItem1.TextSize = new System.Drawing.Size(0, 0);
            // 
            // layoutControlItem7
            // 
            this.layoutControlItem7.Control = this.labelControl2;
            this.layoutControlItem7.Location = new System.Drawing.Point(0, 58);
            this.layoutControlItem7.Name = "layoutControlItem7";
            this.layoutControlItem7.Size = new System.Drawing.Size(1054, 24);
            this.layoutControlItem7.TextSize = new System.Drawing.Size(0, 0);
            this.layoutControlItem7.TextVisible = false;
            // 
            // frmSobrantesRegistro
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1058, 586);
            this.Controls.Add(this.layoutControl1);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "frmSobrantesRegistro";
            this.Text = "Registro de Produtos Sobrantes";
            this.Load += new System.EventHandler(this.frmSobrantesRegistro_Load);
            ((System.ComponentModel.ISupportInitialize)(this.layoutControl1)).EndInit();
            this.layoutControl1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.uiFecha.Properties.CalendarTimeProperties)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiFecha.Properties)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiGrid)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pproductossobrantesgrdResultBindingSource)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.uiGridView)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.repDevCocina)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlGroup1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem5)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem6)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.emptySpaceItem1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.layoutControlItem7)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private DevExpress.XtraLayout.LayoutControl layoutControl1;
        private DevExpress.XtraLayout.LayoutControlGroup layoutControlGroup1;
        private DevExpress.XtraEditors.LabelControl labelControl1;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem1;
        private DevExpress.XtraGrid.GridControl uiGrid;
        private DevExpress.XtraGrid.Views.Grid.GridView uiGridView;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem2;
        private System.Windows.Forms.BindingSource pproductossobrantesgrdResultBindingSource;
        private DevExpress.XtraGrid.Columns.GridColumn colProductoId;
        private DevExpress.XtraGrid.Columns.GridColumn colClave;
        private DevExpress.XtraGrid.Columns.GridColumn colDescripcion;
        private DevExpress.XtraGrid.Columns.GridColumn colExistencia;
        private DevExpress.XtraGrid.Columns.GridColumn colFecha;
        private DevExpress.XtraGrid.Columns.GridColumn colCantidadSobrante;
        private DevExpress.XtraGrid.Columns.GridColumn colRequiereBascula;
        private DevExpress.XtraEditors.SimpleButton uiSalir;
        private DevExpress.XtraEditors.SimpleButton uiGuardar;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem3;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem4;
        private DevExpress.XtraEditors.SimpleButton uiTerminar;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem5;
        private DevExpress.XtraEditors.DateEdit uiFecha;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem6;
        private DevExpress.XtraLayout.EmptySpaceItem emptySpaceItem1;
        private DevExpress.XtraEditors.LabelControl labelControl2;
        private DevExpress.XtraLayout.LayoutControlItem layoutControlItem7;
        private DevExpress.XtraGrid.Columns.GridColumn colRepDevolucion;
        private DevExpress.XtraEditors.Repository.RepositoryItemCalcEdit repDevCocina;
    }
}