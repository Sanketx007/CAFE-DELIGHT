using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace CAFE_DELIGHT.Migrations
{
    /// <inheritdoc />
    public partial class RestoreOriginalData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "CategoryId", "CategoryName", "CreatedAt", "Description", "IsActive", "SortOrder" },
                values: new object[,]
                {
                    { 1, "Hot Coffee", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(193), "Warm and energizing brewed coffee", true, 0 },
                    { 2, "Cold Coffee", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(201), "Chilled and refreshing coffee drinks", true, 0 },
                    { 3, "Bakery", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(206), "Freshly baked pastries and treats", true, 0 },
                    { 4, "Snacks", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(210), "Quick bites and savory snacks", true, 0 }
                });

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 9, 1, 16, 768, DateTimeKind.Local).AddTicks(9771));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 9, 1, 16, 768, DateTimeKind.Local).AddTicks(9817));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "UpdatedAt" },
                values: new object[] { new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Admin@123", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "UserId", "AvatarUrl", "CreatedAt", "Email", "FullName", "IsDeleted", "LastLogin", "PasswordHash", "Phone", "RoleId", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 2, null, new DateTime(2024, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), "priya.sharma@gmail.com", "Priya Sharma", false, null, "User@123", null, 2, "Active", new DateTime(2024, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 3, null, new DateTime(2024, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), "maria@gmail.com", "Maria Rodriguez", false, null, "User@123", null, 2, "Active", new DateTime(2024, 1, 3, 0, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 4, null, new DateTime(2024, 1, 4, 0, 0, 0, 0, DateTimeKind.Unspecified), "robert@gmail.com", "Robert Johnson", false, null, "User@123", null, 2, "Blocked", new DateTime(2024, 1, 4, 0, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "ProductId", "CategoryId", "CreatedAt", "Description", "ImageUrl", "IsDeleted", "Price", "ProductName", "Status", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(275), "Rich espresso topped with silky steamed milk foam.", "https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=800", false, 180.00m, "Cappuccino", "Active", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(276) },
                    { 2, 3, new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(293), "Flaky, golden-brown pastry made with pure butter.", "https://images.pexels.com/photos/1860209/pexels-photo-1860209.jpeg?auto=compress&cs=tinysrgb&w=800", false, 120.00m, "Butter Croissant", "Active", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(294) },
                    { 3, 2, new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(301), "Chilled coffee with chocolate syrup, milk, and ice.", "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg?auto=compress&cs=tinysrgb&w=800", false, 240.00m, "Iced Mocha", "Active", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(302) },
                    { 4, 3, new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(308), "Moist chocolate muffin topped with dark choco chips.", "https://images.pexels.com/photos/6930269/pexels-photo-6930269.jpeg?auto=compress&cs=tinysrgb&w=800", false, 170.00m, "Chocolate Muffin", "Active", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(309) },
                    { 5, 1, new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(315), "Strong, concentrated coffee served in a small cup.", "https://images.pexels.com/photos/2396220/pexels-photo-2396220.jpeg?auto=compress&cs=tinysrgb&w=800", false, 140.00m, "Double Espresso", "Active", new DateTime(2026, 4, 9, 9, 1, 16, 769, DateTimeKind.Local).AddTicks(316) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Products",
                keyColumn: "ProductId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "CategoryId",
                keyValue: 3);

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(7935));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(7950));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                columns: new[] { "CreatedAt", "PasswordHash", "UpdatedAt" },
                values: new object[] { new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(8121), "admin123", new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(8122) });
        }
    }
}
