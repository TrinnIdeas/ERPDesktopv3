﻿using System;
using System.Drawing;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;

namespace ERP.Reports
{
    /// <summary>
    /// Summary description for rptCorteCajaResumido.
    /// </summary>
    public partial class rptCorteCajaResumido : GrapeCity.ActiveReports.SectionReport
    {

        public rptCorteCajaResumido()
        {
            //
            // Required for Windows Form Designer support
            //
            InitializeComponent();
        }

        private void pageHeader_Format(object sender, EventArgs e)
        {
            subRptLogo oReportFoto = new subRptLogo();
            subRepFoto.Report = oReportFoto;
        }
    }
}
