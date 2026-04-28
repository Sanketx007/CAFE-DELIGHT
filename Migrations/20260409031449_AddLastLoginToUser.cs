using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CAFE_DELIGHT.Migrations
{
    /// <inheritdoc />
    public partial class AddLastLoginToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastLogin",
                table: "Users",
                type: "datetime2",
                nullable: true);

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
                columns: new[] { "CreatedAt", "LastLogin", "UpdatedAt" },
                values: new object[] { new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(8121), null, new DateTime(2026, 4, 9, 8, 44, 48, 417, DateTimeKind.Local).AddTicks(8122) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastLogin",
                table: "Users");

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 8, 22, 14, 501, DateTimeKind.Local).AddTicks(5869));

            migrationBuilder.UpdateData(
                table: "Roles",
                keyColumn: "RoleId",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 4, 9, 8, 22, 14, 501, DateTimeKind.Local).AddTicks(5887));

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                columns: new[] { "CreatedAt", "UpdatedAt" },
                values: new object[] { new DateTime(2026, 4, 9, 8, 22, 14, 501, DateTimeKind.Local).AddTicks(6080), new DateTime(2026, 4, 9, 8, 22, 14, 501, DateTimeKind.Local).AddTicks(6081) });
        }
    }
}
