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
    
    public partial class cat_basculas_configuracion
    {
        public int EquipoComputoId { get; set; }
        public int BasculaId { get; set; }
        public string PortName { get; set; }
        public int BaudRate { get; set; }
        public int ReadBufferSize { get; set; }
        public int WriteBufferSize { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public int CreadoPor { get; set; }
        public Nullable<decimal> PesoDefault { get; set; }
    
        public virtual cat_basculas cat_basculas { get; set; }
        public virtual cat_equipos_computo cat_equipos_computo { get; set; }
    }
}
