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
    
    public partial class doc_declaracion_fondo_inicial_detalle
    {
        public int DeclaracionFondoDetalleId { get; set; }
        public int DeclaracionFondoId { get; set; }
        public int DenominacionId { get; set; }
        public int Cantidad { get; set; }
        public decimal Total { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public Nullable<int> CreadoPor { get; set; }
    
        public virtual cat_denominaciones cat_denominaciones { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual doc_declaracion_fondo_inicial doc_declaracion_fondo_inicial { get; set; }
    }
}
