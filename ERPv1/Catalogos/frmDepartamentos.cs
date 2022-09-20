﻿using ERP.Common.Base;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ERPv1.Catalogos
{
    public partial class frmDepartamentos : FormBaseXtraForm
    {
        private static frmDepartamentos _instance;
        public static frmDepartamentos GetInstance()
        {
            if (_instance == null) _instance = new frmDepartamentos();
            else _instance.BringToFront();
            return _instance;
        }
        public frmDepartamentos()
        {
            InitializeComponent();
        }
    }
}
