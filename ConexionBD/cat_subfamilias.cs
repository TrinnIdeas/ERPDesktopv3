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
    
    public partial class cat_subfamilias
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public cat_subfamilias()
        {
            this.cat_productos = new HashSet<cat_productos>();
            this.cat_productos1 = new HashSet<cat_productos>();
            this.doc_promociones_detalle = new HashSet<doc_promociones_detalle>();
            this.doc_promociones_excepcion = new HashSet<doc_promociones_excepcion>();
            this.cat_rest_platillo_adicionales_sfam = new HashSet<cat_rest_platillo_adicionales_sfam>();
        }
    
        public int Clave { get; set; }
        public string Descripcion { get; set; }
        public int Familia { get; set; }
        public Nullable<bool> Estatus { get; set; }
        public Nullable<int> Empresa { get; set; }
        public Nullable<int> Sucursal { get; set; }
    
        public virtual cat_empresas cat_empresas { get; set; }
        public virtual cat_empresas cat_empresas1 { get; set; }
        public virtual cat_empresas cat_empresas2 { get; set; }
        public virtual cat_empresas cat_empresas3 { get; set; }
        public virtual cat_familias cat_familias { get; set; }
        public virtual cat_familias cat_familias1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<cat_productos> cat_productos { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<cat_productos> cat_productos1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_promociones_detalle> doc_promociones_detalle { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_promociones_excepcion> doc_promociones_excepcion { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<cat_rest_platillo_adicionales_sfam> cat_rest_platillo_adicionales_sfam { get; set; }
    }
}
