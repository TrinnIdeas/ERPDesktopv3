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
    
    public partial class sis_usuarios_roles
    {
        public int UsuarioId { get; set; }
        public short RolId { get; set; }
        public System.DateTime CreadoEl { get; set; }
    
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual sis_roles sis_roles { get; set; }
    }
}
