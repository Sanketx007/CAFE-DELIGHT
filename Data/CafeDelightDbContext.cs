using Microsoft.EntityFrameworkCore;
using CAFE_DELIGHT.Models;

namespace CAFE_DELIGHT.Data
{
    public class CafeDelightDbContext : DbContext
    {
        public CafeDelightDbContext(DbContextOptions<CafeDelightDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<ContactMessage> ContactMessages { get; set; }
        public DbSet<AdminSetting> AdminSettings { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure relationships and seed data if needed

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role { RoleId = 1, RoleName = "Admin", Description = "System Administrator" },
                new Role { RoleId = 2, RoleName = "Customer", Description = "Regular Customer" }
            );

            // Seed Categories
            modelBuilder.Entity<Category>().HasData(
                new Category { CategoryId = 1, CategoryName = "Hot Coffee", Description = "Warm and energizing brewed coffee", IsActive = true },
                new Category { CategoryId = 2, CategoryName = "Cold Coffee", Description = "Chilled and refreshing coffee drinks", IsActive = true },
                new Category { CategoryId = 3, CategoryName = "Bakery", Description = "Freshly baked pastries and treats", IsActive = true },
                new Category { CategoryId = 4, CategoryName = "Snacks", Description = "Quick bites and savory snacks", IsActive = true }
            );

            // Seed Products
            modelBuilder.Entity<Product>().HasData(
                new Product { ProductId = 1, ProductName = "Cappuccino", CategoryId = 1, Price = 180.00m, Description = "Rich espresso topped with silky steamed milk foam.", ImageUrl = "https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=800", Status = "Active", IsDeleted = false },
                new Product { ProductId = 2, ProductName = "Butter Croissant", CategoryId = 3, Price = 120.00m, Description = "Flaky, golden-brown pastry made with pure butter.", ImageUrl = "https://images.pexels.com/photos/1860209/pexels-photo-1860209.jpeg?auto=compress&cs=tinysrgb&w=800", Status = "Active", IsDeleted = false },
                new Product { ProductId = 3, ProductName = "Iced Mocha", CategoryId = 2, Price = 240.00m, Description = "Chilled coffee with chocolate syrup, milk, and ice.", ImageUrl = "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg?auto=compress&cs=tinysrgb&w=800", Status = "Active", IsDeleted = false },
                new Product { ProductId = 4, ProductName = "Chocolate Muffin", CategoryId = 3, Price = 170.00m, Description = "Moist chocolate muffin topped with dark choco chips.", ImageUrl = "https://images.pexels.com/photos/6930269/pexels-photo-6930269.jpeg?auto=compress&cs=tinysrgb&w=800", Status = "Active", IsDeleted = false },
                new Product { ProductId = 5, ProductName = "Double Espresso", CategoryId = 1, Price = 140.00m, Description = "Strong, concentrated coffee served in a small cup.", ImageUrl = "https://images.pexels.com/photos/2396220/pexels-photo-2396220.jpeg?auto=compress&cs=tinysrgb&w=800", Status = "Active", IsDeleted = false }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                { 
                    UserId = 1, 
                    FullName = "Admin User", 
                    Email = "admin@cafedelight.com", 
                    PasswordHash = "Admin@123", 
                    RoleId = 1,
                    Status = "Active",
                    CreatedAt = new DateTime(2024, 1, 1),
                    UpdatedAt = new DateTime(2024, 1, 1)
                },
                new User 
                { 
                    UserId = 2, 
                    FullName = "Priya Sharma", 
                    Email = "priya.sharma@gmail.com", 
                    PasswordHash = "User@123", 
                    RoleId = 2,
                    Status = "Active",
                    CreatedAt = new DateTime(2024, 1, 2),
                    UpdatedAt = new DateTime(2024, 1, 2)
                },
                new User 
                { 
                    UserId = 3, 
                    FullName = "Maria Rodriguez", 
                    Email = "maria@gmail.com", 
                    PasswordHash = "User@123", 
                    RoleId = 2,
                    Status = "Active",
                    CreatedAt = new DateTime(2024, 1, 3),
                    UpdatedAt = new DateTime(2024, 1, 3)
                },
                new User 
                { 
                    UserId = 4, 
                    FullName = "Robert Johnson", 
                    Email = "robert@gmail.com", 
                    PasswordHash = "User@123", 
                    RoleId = 2,
                    Status = "Blocked",
                    CreatedAt = new DateTime(2024, 1, 4),
                    UpdatedAt = new DateTime(2024, 1, 4)
                }
            );
        }
    }
}
