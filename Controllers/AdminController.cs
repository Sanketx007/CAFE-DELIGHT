using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CAFE_DELIGHT.Data;
using CAFE_DELIGHT.Models;

namespace CAFE_DELIGHT.Controllers
{
    public class AdminController : Controller
    {
        private readonly CafeDelightDbContext _context;

        public AdminController(CafeDelightDbContext context)
        {
            _context = context;
        }

        public IActionResult Dashboard()
        {
            // Simple stats for the dashboard
            ViewBag.ProductCount = _context.Products.Count(p => !p.IsDeleted);
            ViewBag.UserCount = _context.Users.Count(u => !u.IsDeleted);
            ViewBag.OrderCount = _context.Orders.Count();
            ViewBag.TotalRevenue = _context.Orders.Sum(o => o.TotalAmount);

            var recentOrders = _context.Orders
                .Include(o => o.User)
                .OrderByDescending(o => o.CreatedAt)
                .Take(5)
                .ToList();

            var products = _context.Products
                .Include(p => p.Category)
                .Where(p => !p.IsDeleted)
                .Take(5)
                .ToList();

            ViewBag.RecentOrders = recentOrders;
            return View(products);
        }

        public IActionResult Index()
        {
            var products = _context.Products
                .Include(p => p.Category)
                .Where(p => !p.IsDeleted)
                .ToList();
            return View(products);
        }

        /// <summary>Add product form.</summary>
        public IActionResult AddProduct()
        {
            ViewBag.Categories = _context.Categories.Where(c => c.IsActive).ToList();
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> EditProduct(int id, string category, decimal price, string status, string imageUrl)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            product.Price = price;
            product.Status = status;
            product.ImageUrl = imageUrl;
            // Handle category if needed (simplified for now)
            
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpPost]
        public async Task<IActionResult> DeleteProduct(int id)
        {
            var product = await _context.Products.FindAsync(id);
            if (product == null) return NotFound();

            product.IsDeleted = true;
            await _context.SaveChangesAsync();
            return Ok();
        }

        public IActionResult Users()
        {
            var users = _context.Users
                .Include(u => u.Role)
                .Where(u => !u.IsDeleted)
                .ToList();
            return View(users);
        }

        [HttpPost]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user != null)
            {
                user.IsDeleted = true;
                await _context.SaveChangesAsync();
            }
            return RedirectToAction("Users");
        }

        public IActionResult AddUser()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddUser(User user)
        {
            if (ModelState.IsValid)
            {
                user.CreatedAt = DateTime.Now;
                user.UpdatedAt = DateTime.Now;
                user.Status = "Active";
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                return RedirectToAction("Users");
            }
            return View(user);
        }

        public IActionResult Orders()
        {
            var orders = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .OrderByDescending(o => o.CreatedAt)
                .ToList();
            return View(orders);
        }

        public IActionResult Settings()
        {
            return View();
        }
    }
}

