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
    
    public partial class cat_gastos
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public cat_gastos()
        {
            this.doc_gastos = new HashSet<doc_gastos>();
        }
    
        public int Clave { get; set; }
        public string Descripcion { get; set; }
        public Nullable<int> ClaveCentroCosto { get; set; }
        public Nullable<bool> Estatus { get; set; }
        public Nullable<int> Empresa { get; set; }
        public Nullable<int> Sucursal { get; set; }
        public Nullable<decimal> Monto { get; set; }
        public string Observaciones { get; set; }
        public Nullable<int> ConceptoId { get; set; }
        public Nullable<int> CreadoPor { get; set; }
        public Nullable<System.DateTime> CreadoEl { get; set; }
        public Nullable<int> CajaId { get; set; }
    
        public virtual cat_cajas cat_cajas { get; set; }
        public virtual cat_cajas cat_cajas1 { get; set; }
        public virtual cat_centro_costos cat_centro_costos { get; set; }
        public virtual cat_centro_costos cat_centro_costos1 { get; set; }
        public virtual cat_conceptos cat_conceptos { get; set; }
        public virtual cat_conceptos cat_conceptos1 { get; set; }
        public virtual cat_empresas cat_empresas { get; set; }
        public virtual cat_empresas cat_empresas1 { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_sucursales cat_sucursales1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_gastos> doc_gastos { get; set; }
    }
}
