//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ConexionBD
{
    using System;
    using System.Collections.Generic;
    
    public partial class cat_monedas
    {
        public int Clave { get; set; }
        public string Descripcion { get; set; }
        public string Abreviacion { get; set; }
        public Nullable<decimal> TipoCambio { get; set; }
        public Nullable<bool> Estatus { get; set; }
        public Nullable<int> Empresa { get; set; }
        public Nullable<int> Sucursal { get; set; }
        public Nullable<int> IdMonedaAbreviatura { get; set; }
    
        public virtual cat_empresas cat_empresas { get; set; }
        public virtual cat_empresas cat_empresas1 { get; set; }
        public virtual cat_empresas cat_empresas2 { get; set; }
        public virtual cat_empresas cat_empresas3 { get; set; }
        public virtual cat_monedas_abreviaturas cat_monedas_abreviaturas { get; set; }
    }
}
