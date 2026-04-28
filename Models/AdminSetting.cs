using System.ComponentModel.DataAnnotations;

namespace CAFE_DELIGHT.Models
{
    public class AdminSetting
    {
        [Key]
        public int SettingId { get; set; }

        [Required, MaxLength(100)]
        public string SettingKey { get; set; } = string.Empty;

        public string? SettingValue { get; set; }

        public DateTime UpdatedAt { get; set; } = DateTime.Now;
    }
}
