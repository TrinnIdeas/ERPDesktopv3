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
    
    public partial class cat_clientes_automovil
    {
        public int ClienteAutoId { get; set; }
        public int ClienteId { get; set; }
        public string Modelo { get; set; }
        public string Color { get; set; }
        public string Placas { get; set; }
        public string Observaciones { get; set; }
        public System.DateTime CreadoEl { get; set; }
    
        public virtual cat_clientes cat_clientes { get; set; }
    }
}
