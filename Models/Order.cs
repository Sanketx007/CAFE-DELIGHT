using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CAFE_DELIGHT.Models
{
    public class Order
    {
        [Key]
        public int OrderId { get; set; }

        [Required, MaxLength(20)]
        public string OrderNumber { get; set; } = string.Empty; // e.g. #ORD-0092

        public int? UserId { get; set; } // NULL for guest checkout

        [Required, MaxLength(200)]
        public string CustomerName { get; set; } = string.Empty;

        [MaxLength(255)]
        public string? Email { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        // Shipping Address
        [MaxLength(100)]
        public string? FirstName { get; set; }

        [MaxLength(100)]
        public string? LastName { get; set; }

        [MaxLength(500)]
        public string? Address { get; set; }

        [MaxLength(100)]
        public string? City { get; set; }

        [MaxLength(100)]
        public string? State { get; set; }

        [MaxLength(20)]
        public string? PostalCode { get; set; }

        // Payment
        [MaxLength(30)]
        public string PaymentMethod { get; set; } = "cod"; // card | upi | cod

        [MaxLength(4)]
        public string? CardLast4 { get; set; }

        // Totals
        [Column(TypeName = "decimal(10,2)")]
        public decimal Subtotal { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal TaxRate { get; set; } = 5.00m;

        [Column(TypeName = "decimal(10,2)")]
        public decimal TaxAmount { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal TotalAmount { get; set; }

        // Status
        [MaxLength(20)]
        public string Status { get; set; } = "Pending"; // Pending | Completed | Cancelled

        [MaxLength(1000)]
        public string? Notes { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;

        // Navigation
        [ForeignKey("UserId")]
        public User? User { get; set; }

        public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }
}
