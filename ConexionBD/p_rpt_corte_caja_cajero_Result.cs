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
    
    public partial class p_rpt_corte_caja_cajero_Result
    {
        public int CorteCajaId { get; set; }
        public string Caja { get; set; }
        public decimal TotalCorte { get; set; }
        public System.DateTime FechaCorte { get; set; }
        public string HoraCorte { get; set; }
        public string NombreUsuario { get; set; }
        public decimal Efectivo { get; set; }
        public decimal OtrasFP { get; set; }
        public decimal FondoInicial { get; set; }
        public decimal Gastos { get; set; }
        public decimal Retiros { get; set; }
        public Nullable<decimal> TotalGlobal { get; set; }
        public decimal Ingresado { get; set; }
        public Nullable<decimal> Faltante { get; set; }
        public Nullable<decimal> Excedente { get; set; }
        public decimal VentasTelefono { get; set; }
        public string Denominacion { get; set; }
        public Nullable<decimal> DenominacionValor { get; set; }
        public Nullable<decimal> DenominacionCantidad { get; set; }
    }
}
