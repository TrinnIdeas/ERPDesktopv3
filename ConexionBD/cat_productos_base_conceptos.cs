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
    
    public partial class cat_productos_base_conceptos
    {
        public int Id { get; set; }
        public int ProductoId { get; set; }
        public int ConceptoId { get; set; }
        public Nullable<bool> RegistrarTiempo { get; set; }
        public Nullable<bool> RegistrarVolumen { get; set; }
        public string CreadoEl { get; set; }
    
        public virtual cat_conceptos cat_conceptos { get; set; }
        public virtual cat_productos cat_productos { get; set; }
    }
}
