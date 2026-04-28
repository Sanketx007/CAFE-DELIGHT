using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CAFE_DELIGHT.Models
{
    public class User
    {
        [Key]
        public int UserId { get; set; }

        [Required, MaxLength(150)]
        public string FullName { get; set; } = string.Empty;

        [Required, MaxLength(255)]
        public string Email { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? Phone { get; set; }

        [Required, MaxLength(512)]
        public string PasswordHash { get; set; } = string.Empty;

        public int RoleId { get; set; } = 2; // Default: Customer

        [MaxLength(20)]
        public string Status { get; set; } = "Active"; // Active | Blocked

        [MaxLength(500)]
        public string? AvatarUrl { get; set; }

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
        public DateTime? LastLogin { get; set; }

        // Navigation
        [ForeignKey("RoleId")]
        public Role? Role { get; set; }

        public ICollection<Order> Orders { get; set; } = new List<Order>();
        public ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();
    }
}
