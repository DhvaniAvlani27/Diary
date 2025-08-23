using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace DiaryApp.Migrations
{
    /// <inheritdoc />
    public partial class AddedSeedingDataDiaryEntry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "diaryEntries",
                columns: new[] { "Id", "Content", "Created", "Title" },
                values: new object[,]
                {
                    { 1, "Went hiking with Joe!", new DateTime(2025, 6, 4, 17, 48, 49, 906, DateTimeKind.Local).AddTicks(8085), "Went Hiking" },
                    { 2, "Went Shopping with Joe!", new DateTime(2025, 6, 4, 17, 48, 49, 906, DateTimeKind.Local).AddTicks(8087), "Went Shopping" },
                    { 3, "Went Diving with Joe!", new DateTime(2025, 6, 4, 17, 48, 49, 906, DateTimeKind.Local).AddTicks(8089), "Went Diving" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "diaryEntries",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "diaryEntries",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "diaryEntries",
                keyColumn: "Id",
                keyValue: 3);
        }
    }
}
