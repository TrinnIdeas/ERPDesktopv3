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
    
    public partial class cat_impresoras_comandas
    {
        public short ImpresoraId { get; set; }
        public System.DateTime CreadoEl { get; set; }
    
        public virtual cat_impresoras cat_impresoras { get; set; }
    }
}
