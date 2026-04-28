using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CAFE_DELIGHT.Models
{
    public class CartItem
    {
        [Key]
        public int CartItemId { get; set; }

        [Required, MaxLength(100)]
        public string SessionId { get; set; } = string.Empty;

        public int? UserId { get; set; }

        public int ProductId { get; set; }

        [Required, MaxLength(200)]
        public string ProductName { get; set; } = string.Empty;

        [Column(TypeName = "decimal(10,2)")]
        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; } = 1;

        [MaxLength(1000)]
        public string? ImageUrl { get; set; }

        public DateTime AddedAt { get; set; } = DateTime.Now;

        // Navigation
        [ForeignKey("UserId")]
        public User? User { get; set; }

        [ForeignKey("ProductId")]
        public Product? Product { get; set; }
    }
}
