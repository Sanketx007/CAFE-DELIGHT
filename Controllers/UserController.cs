using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CAFE_DELIGHT.Data;
using CAFE_DELIGHT.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace CAFE_DELIGHT.Controllers
{
    [Authorize]
    public class UserController : Controller
    {
        private readonly CafeDelightDbContext _context;

        public UserController(CafeDelightDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Profile()
        {
            var userIdStr = User.FindFirstValue("UserId");
            if (string.IsNullOrEmpty(userIdStr)) return RedirectToAction("Login", "Account");

            int userId = int.Parse(userIdStr);
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null) return NotFound();

            return View(user);
        }

        public async Task<IActionResult> Orders()
        {
            var userIdStr = User.FindFirstValue("UserId");
            if (string.IsNullOrEmpty(userIdStr)) return RedirectToAction("Login", "Account");

            int userId = int.Parse(userIdStr);
            var orders = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            return View(orders);
        }
    }
}
