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
    
    public partial class doc_productos_compra
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public doc_productos_compra()
        {
            this.doc_inv_movimiento = new HashSet<doc_inv_movimiento>();
            this.doc_inv_movimiento1 = new HashSet<doc_inv_movimiento>();
            this.doc_productos_compra_detalle = new HashSet<doc_productos_compra_detalle>();
            this.doc_productos_compra_cargos = new HashSet<doc_productos_compra_cargos>();
        }
    
        public int ProductoCompraId { get; set; }
        public int ProveedorId { get; set; }
        public System.DateTime FechaRegistro { get; set; }
        public string NumeroRemision { get; set; }
        public decimal Descuento { get; set; }
        public decimal Subtotal { get; set; }
        public decimal Impuestos { get; set; }
        public decimal Total { get; set; }
        public int CreadoPor { get; set; }
        public System.DateTime CreadoEl { get; set; }
        public Nullable<int> ModificadoPor { get; set; }
        public Nullable<System.DateTime> ModificadoEl { get; set; }
        public bool Activo { get; set; }
        public Nullable<System.DateTime> FechaCancelacion { get; set; }
        public Nullable<int> CanceladoPor { get; set; }
        public Nullable<System.DateTime> FechaRemision { get; set; }
        public Nullable<bool> PrecioAfectado { get; set; }
        public Nullable<bool> PrecioConImpuestos { get; set; }
        public Nullable<int> SucursalId { get; set; }
    
        public virtual cat_proveedores cat_proveedores { get; set; }
        public virtual cat_sucursales cat_sucursales { get; set; }
        public virtual cat_usuarios cat_usuarios { get; set; }
        public virtual cat_usuarios cat_usuarios1 { get; set; }
        public virtual cat_usuarios cat_usuarios2 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_inv_movimiento> doc_inv_movimiento { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_inv_movimiento> doc_inv_movimiento1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_productos_compra_detalle> doc_productos_compra_detalle { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<doc_productos_compra_cargos> doc_productos_compra_cargos { get; set; }
    }
}
