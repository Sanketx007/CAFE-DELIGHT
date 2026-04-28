using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CAFE_DELIGHT.Data;
using CAFE_DELIGHT.Models;
using System.Security.Claims;

namespace CAFE_DELIGHT.Controllers
{
    public class CartController : Controller
    {
        private readonly CafeDelightDbContext _context;

        public CartController(CafeDelightDbContext context)
        {
            _context = context;
        }
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddToCart(int productId, int quantity = 1)
        {
            var userIdStr = User.FindFirstValue("UserId");
            if (string.IsNullOrEmpty(userIdStr))
            {
                // Guest cart logic (simplified)
                return Ok(new { success = true, guest = true });
            }

            int userId = int.Parse(userIdStr);
            var cartItem = await _context.CartItems
                .FirstOrDefaultAsync(c => c.UserId == userId && c.ProductId == productId);

            if (cartItem != null)
            {
                cartItem.Quantity += quantity;
            }
            else
            {
                cartItem = new CartItem
                {
                    UserId = userId,
                    ProductId = productId,
                    Quantity = quantity,
                    AddedAt = DateTime.Now
                };
                _context.CartItems.Add(cartItem);
            }

            await _context.SaveChangesAsync();
            return Ok(new { success = true });
        }

        public IActionResult Checkout()
        {
             var userIdStr = User.FindFirstValue("UserId");
            if (string.IsNullOrEmpty(userIdStr)) return RedirectToAction("Login", "Account");
            
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> ProcessCheckout(string address, string phone)
        {
            var userIdStr = User.FindFirstValue("UserId");
            if (string.IsNullOrEmpty(userIdStr)) return Unauthorized();

            int userId = int.Parse(userIdStr);
            var cartItems = await _context.CartItems
                .Include(c => c.Product)
                .Where(c => c.UserId == userId)
                .ToListAsync();

            if (!cartItems.Any()) return BadRequest("Cart is empty");

            var order = new Order
            {
                UserId = userId,
                OrderNumber = "ORD-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper(),
                CustomerName = User.Identity?.Name ?? "Customer",
                CreatedAt = DateTime.Now,
                TotalAmount = cartItems.Sum(c => c.Product!.Price * c.Quantity),
                Status = "Pending",
                Address = address,
                Phone = phone
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            foreach (var item in cartItems)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.OrderId,
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = item.Product!.Price
                };
                _context.OrderItems.Add(orderItem);
            }

            // Clear cart
            _context.CartItems.RemoveRange(cartItems);
            await _context.SaveChangesAsync();

            return RedirectToAction("OrderSuccess");
        }

        public IActionResult OrderSuccess()
        {
            return View();
        }
    }
}

