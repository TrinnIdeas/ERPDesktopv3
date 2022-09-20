﻿namespace ERP.Reports
{
    /// <summary>
    /// Summary description for rptClientesApartados.
    /// </summary>
    partial class rptClientesApartados
    {
        private GrapeCity.ActiveReports.SectionReportModel.PageHeader pageHeader;
        private GrapeCity.ActiveReports.SectionReportModel.Detail detail;
        private GrapeCity.ActiveReports.SectionReportModel.PageFooter pageFooter;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
            }
            base.Dispose(disposing);
        }

        #region ActiveReport Designer generated code
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Resources.ResourceManager resources = new System.Resources.ResourceManager(typeof(rptClientesApartados));
            this.pageHeader = new GrapeCity.ActiveReports.SectionReportModel.PageHeader();
            this.label1 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label2 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label5 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.subRepFoto = new GrapeCity.ActiveReports.SectionReportModel.SubReport();
            this.label3 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label4 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label6 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label7 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label8 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label9 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.label10 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.detail = new GrapeCity.ActiveReports.SectionReportModel.Detail();
            this.textBox1 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox2 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox3 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox4 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox5 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox6 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.textBox7 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.pageFooter = new GrapeCity.ActiveReports.SectionReportModel.PageFooter();
            this.groupHeader1 = new GrapeCity.ActiveReports.SectionReportModel.GroupHeader();
            this.groupFooter1 = new GrapeCity.ActiveReports.SectionReportModel.GroupFooter();
            this.label11 = new GrapeCity.ActiveReports.SectionReportModel.Label();
            this.textBox8 = new GrapeCity.ActiveReports.SectionReportModel.TextBox();
            this.line1 = new GrapeCity.ActiveReports.SectionReportModel.Line();
            this.line2 = new GrapeCity.ActiveReports.SectionReportModel.Line();
            ((System.ComponentModel.ISupportInitialize)(this.label1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label5)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label6)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label7)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label8)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label9)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label10)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox5)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox6)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox7)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.label11)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox8)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();
            // 
            // pageHeader
            // 
            this.pageHeader.Controls.AddRange(new GrapeCity.ActiveReports.SectionReportModel.ARControl[] {
            this.label1,
            this.label2,
            this.label5,
            this.subRepFoto,
            this.label3,
            this.label4,
            this.label6,
            this.label7,
            this.label8,
            this.label9,
            this.label10,
            this.line1});
            this.pageHeader.Height = 1.562501F;
            this.pageHeader.Name = "pageHeader";
            this.pageHeader.Format += new System.EventHandler(this.pageHeader_Format);
            // 
            // label1
            // 
            this.label1.DataField = "Empresa";
            this.label1.Height = 0.2F;
            this.label1.HyperLink = null;
            this.label1.Left = 2.162F;
            this.label1.Name = "label1";
            this.label1.Style = "font-size: 9.75pt; font-weight: bold; text-align: center; ddo-char-set: 0";
            this.label1.Text = "label1";
            this.label1.Top = 0.121F;
            this.label1.Width = 3.989F;
            // 
            // label2
            // 
            this.label2.DataField = "Sucursal";
            this.label2.Height = 0.2F;
            this.label2.HyperLink = null;
            this.label2.Left = 2.162F;
            this.label2.Name = "label2";
            this.label2.Style = "font-size: 9.75pt; font-weight: bold; text-align: center; ddo-char-set: 0";
            this.label2.Text = "label1";
            this.label2.Top = 0.321F;
            this.label2.Width = 3.989F;
            // 
            // label5
            // 
            this.label5.Height = 0.2F;
            this.label5.HyperLink = null;
            this.label5.Left = 2.162F;
            this.label5.Name = "label5";
            this.label5.Style = "font-size: 9.75pt; font-weight: bold; text-align: center; ddo-char-set: 0";
            this.label5.Text = "Clientes";
            this.label5.Top = 0.63F;
            this.label5.Width = 3.989F;
            // 
            // subRepFoto
            // 
            this.subRepFoto.CloseBorder = false;
            this.subRepFoto.Height = 1.076F;
            this.subRepFoto.Left = 0.224F;
            this.subRepFoto.Name = "subRepFoto";
            this.subRepFoto.Report = null;
            this.subRepFoto.ReportName = "";
            this.subRepFoto.Top = 0.108F;
            this.subRepFoto.Width = 1.875F;
            // 
            // label3
            // 
            this.label3.Height = 0.2F;
            this.label3.HyperLink = null;
            this.label3.Left = 0.224F;
            this.label3.Name = "label3";
            this.label3.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label3.Text = "CLIENTE";
            this.label3.Top = 1.352F;
            this.label3.Width = 0.6670001F;
            // 
            // label4
            // 
            this.label4.Height = 0.2F;
            this.label4.HyperLink = null;
            this.label4.Left = 0.891F;
            this.label4.Name = "label4";
            this.label4.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label4.Text = "NOMBRE";
            this.label4.Top = 1.352F;
            this.label4.Width = 1.769F;
            // 
            // label6
            // 
            this.label6.Height = 0.2F;
            this.label6.HyperLink = null;
            this.label6.Left = 2.66F;
            this.label6.Name = "label6";
            this.label6.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label6.Text = "TELÉFONO";
            this.label6.Top = 1.352F;
            this.label6.Width = 1.084F;
            // 
            // label7
            // 
            this.label7.Height = 0.3680001F;
            this.label7.HyperLink = null;
            this.label7.Left = 3.744F;
            this.label7.Name = "label7";
            this.label7.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label7.Text = "FECHA APARTADO";
            this.label7.Top = 1.184F;
            this.label7.Width = 0.802F;
            // 
            // label8
            // 
            this.label8.Height = 0.3680001F;
            this.label8.HyperLink = null;
            this.label8.Left = 4.546F;
            this.label8.Name = "label8";
            this.label8.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label8.Text = "FECHA VENCIMIENTO";
            this.label8.Top = 1.184F;
            this.label8.Width = 0.8440002F;
            // 
            // label9
            // 
            this.label9.Height = 0.2F;
            this.label9.HyperLink = null;
            this.label9.Left = 5.39F;
            this.label9.Name = "label9";
            this.label9.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label9.Text = "PRODUCTO";
            this.label9.Top = 1.352F;
            this.label9.Width = 0.7609997F;
            // 
            // label10
            // 
            this.label10.Height = 0.316F;
            this.label10.HyperLink = null;
            this.label10.Left = 6.151F;
            this.label10.Name = "label10";
            this.label10.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label10.Text = "CANTIDAD PENDIENTE";
            this.label10.Top = 1.236F;
            this.label10.Width = 0.7610002F;
            // 
            // detail
            // 
            this.detail.Controls.AddRange(new GrapeCity.ActiveReports.SectionReportModel.ARControl[] {
            this.textBox1,
            this.textBox2,
            this.textBox3,
            this.textBox4,
            this.textBox5,
            this.textBox6,
            this.textBox7});
            this.detail.Height = 0.21875F;
            this.detail.Name = "detail";
            // 
            // textBox1
            // 
            this.textBox1.DataField = "ClienteId";
            this.textBox1.Height = 0.2F;
            this.textBox1.Left = 0.224F;
            this.textBox1.Name = "textBox1";
            this.textBox1.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox1.Text = "textBox1";
            this.textBox1.Top = 0F;
            this.textBox1.Width = 0.6670001F;
            // 
            // textBox2
            // 
            this.textBox2.DataField = "Nombre";
            this.textBox2.Height = 0.2F;
            this.textBox2.Left = 0.891F;
            this.textBox2.Name = "textBox2";
            this.textBox2.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox2.Text = "textBox1";
            this.textBox2.Top = 0F;
            this.textBox2.Width = 1.769F;
            // 
            // textBox3
            // 
            this.textBox3.DataField = "Telefono";
            this.textBox3.Height = 0.2F;
            this.textBox3.Left = 2.66F;
            this.textBox3.Name = "textBox3";
            this.textBox3.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox3.Text = "textBox1";
            this.textBox3.Top = 0F;
            this.textBox3.Width = 1.084F;
            // 
            // textBox4
            // 
            this.textBox4.DataField = "FechaApartado";
            this.textBox4.Height = 0.2F;
            this.textBox4.Left = 3.744F;
            this.textBox4.Name = "textBox4";
            this.textBox4.OutputFormat = resources.GetString("textBox4.OutputFormat");
            this.textBox4.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox4.Text = "textBox1";
            this.textBox4.Top = 0F;
            this.textBox4.Width = 0.8019997F;
            // 
            // textBox5
            // 
            this.textBox5.DataField = "FechaVencimiento";
            this.textBox5.Height = 0.2F;
            this.textBox5.Left = 4.546F;
            this.textBox5.Name = "textBox5";
            this.textBox5.OutputFormat = resources.GetString("textBox5.OutputFormat");
            this.textBox5.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox5.Text = "textBox1";
            this.textBox5.Top = 0F;
            this.textBox5.Width = 0.802F;
            // 
            // textBox6
            // 
            this.textBox6.DataField = "Producto";
            this.textBox6.Height = 0.2F;
            this.textBox6.Left = 5.39F;
            this.textBox6.Name = "textBox6";
            this.textBox6.Style = "font-size: 8.25pt; ddo-char-set: 0";
            this.textBox6.Text = "textBox1";
            this.textBox6.Top = 0F;
            this.textBox6.Width = 0.7610001F;
            // 
            // textBox7
            // 
            this.textBox7.CurrencyCulture = new System.Globalization.CultureInfo("es-MX");
            this.textBox7.DataField = "Saldo";
            this.textBox7.Height = 0.2F;
            this.textBox7.Left = 6.151F;
            this.textBox7.Name = "textBox7";
            this.textBox7.OutputFormat = resources.GetString("textBox7.OutputFormat");
            this.textBox7.Style = "font-size: 8.25pt; text-align: right; ddo-char-set: 0";
            this.textBox7.Text = "textBox1";
            this.textBox7.Top = 0F;
            this.textBox7.Width = 0.761F;
            // 
            // pageFooter
            // 
            this.pageFooter.Height = 0F;
            this.pageFooter.Name = "pageFooter";
            // 
            // groupHeader1
            // 
            this.groupHeader1.Height = 0F;
            this.groupHeader1.Name = "groupHeader1";
            // 
            // groupFooter1
            // 
            this.groupFooter1.Controls.AddRange(new GrapeCity.ActiveReports.SectionReportModel.ARControl[] {
            this.label11,
            this.textBox8,
            this.line2});
            this.groupFooter1.Height = 0.2395834F;
            this.groupFooter1.Name = "groupFooter1";
            // 
            // label11
            // 
            this.label11.Height = 0.2F;
            this.label11.HyperLink = null;
            this.label11.Left = 5.067F;
            this.label11.Name = "label11";
            this.label11.Style = "font-size: 8.25pt; font-weight: bold; ddo-char-set: 0";
            this.label11.Text = "TOTAL";
            this.label11.Top = 0F;
            this.label11.Width = 1.084F;
            // 
            // textBox8
            // 
            this.textBox8.CurrencyCulture = new System.Globalization.CultureInfo("es-MX");
            this.textBox8.DataField = "Saldo";
            this.textBox8.Height = 0.2F;
            this.textBox8.Left = 6.151F;
            this.textBox8.Name = "textBox8";
            this.textBox8.OutputFormat = resources.GetString("textBox8.OutputFormat");
            this.textBox8.Style = "font-size: 8.25pt; text-align: right; ddo-char-set: 0";
            this.textBox8.SummaryGroup = "groupHeader1";
            this.textBox8.SummaryRunning = GrapeCity.ActiveReports.SectionReportModel.SummaryRunning.All;
            this.textBox8.SummaryType = GrapeCity.ActiveReports.SectionReportModel.SummaryType.GrandTotal;
            this.textBox8.Text = "textBox1";
            this.textBox8.Top = 0F;
            this.textBox8.Width = 0.761F;
            // 
            // line1
            // 
            this.line1.Height = 0F;
            this.line1.Left = 0.224F;
            this.line1.LineWeight = 1F;
            this.line1.Name = "line1";
            this.line1.Top = 1.552F;
            this.line1.Width = 6.688F;
            this.line1.X1 = 0.224F;
            this.line1.X2 = 6.912F;
            this.line1.Y1 = 1.552F;
            this.line1.Y2 = 1.552F;
            // 
            // line2
            // 
            this.line2.Height = 0F;
            this.line2.Left = 0.224F;
            this.line2.LineWeight = 1F;
            this.line2.Name = "line2";
            this.line2.Top = 0F;
            this.line2.Width = 6.688F;
            this.line2.X1 = 0.224F;
            this.line2.X2 = 6.912F;
            this.line2.Y1 = 0F;
            this.line2.Y2 = 0F;
            // 
            // rptClientesApartados
            // 
            this.MasterReport = false;
            this.PageSettings.Margins.Bottom = 0.5F;
            this.PageSettings.Margins.Left = 0.5F;
            this.PageSettings.Margins.Right = 0.5F;
            this.PageSettings.Margins.Top = 0.5F;
            this.PageSettings.PaperHeight = 11F;
            this.PageSettings.PaperWidth = 8.5F;
            this.PrintWidth = 6.964085F;
            this.Sections.Add(this.pageHeader);
            this.Sections.Add(this.groupHeader1);
            this.Sections.Add(this.detail);
            this.Sections.Add(this.groupFooter1);
            this.Sections.Add(this.pageFooter);
            this.StyleSheet.Add(new DDCssLib.StyleSheetRule("font-family: Arial; font-style: normal; text-decoration: none; font-weight: norma" +
            "l; font-size: 10pt; color: Black", "Normal"));
            this.StyleSheet.Add(new DDCssLib.StyleSheetRule("font-size: 16pt; font-weight: bold", "Heading1", "Normal"));
            this.StyleSheet.Add(new DDCssLib.StyleSheetRule("font-family: Times New Roman; font-size: 14pt; font-weight: bold; font-style: ita" +
            "lic", "Heading2", "Normal"));
            this.StyleSheet.Add(new DDCssLib.StyleSheetRule("font-size: 13pt; font-weight: bold", "Heading3", "Normal"));
            ((System.ComponentModel.ISupportInitialize)(this.label1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label5)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label6)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label7)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label8)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label9)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label10)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox5)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox6)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox7)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.label11)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.textBox8)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

        }
        #endregion

        private GrapeCity.ActiveReports.SectionReportModel.Label label1;
        private GrapeCity.ActiveReports.SectionReportModel.Label label2;
        private GrapeCity.ActiveReports.SectionReportModel.Label label5;
        private GrapeCity.ActiveReports.SectionReportModel.SubReport subRepFoto;
        private GrapeCity.ActiveReports.SectionReportModel.Label label3;
        private GrapeCity.ActiveReports.SectionReportModel.Label label4;
        private GrapeCity.ActiveReports.SectionReportModel.Label label6;
        private GrapeCity.ActiveReports.SectionReportModel.Label label7;
        private GrapeCity.ActiveReports.SectionReportModel.Label label8;
        private GrapeCity.ActiveReports.SectionReportModel.Label label9;
        private GrapeCity.ActiveReports.SectionReportModel.Label label10;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox1;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox2;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox3;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox4;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox5;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox6;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox7;
        private GrapeCity.ActiveReports.SectionReportModel.GroupHeader groupHeader1;
        private GrapeCity.ActiveReports.SectionReportModel.GroupFooter groupFooter1;
        private GrapeCity.ActiveReports.SectionReportModel.Label label11;
        private GrapeCity.ActiveReports.SectionReportModel.TextBox textBox8;
        private GrapeCity.ActiveReports.SectionReportModel.Line line1;
        private GrapeCity.ActiveReports.SectionReportModel.Line line2;
    }
}
