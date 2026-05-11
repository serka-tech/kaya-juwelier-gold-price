using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace KayaJuwelier.GoldPrice.Api.Migrations
{
    /// <inheritdoc />
    public partial class Add14KGoldPrice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "PriceGram14K",
                table: "gold_price_snapshots",
                type: "decimal(10,4)",
                precision: 10,
                scale: 4,
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PriceGram14K",
                table: "gold_price_snapshots");
        }
    }
}
