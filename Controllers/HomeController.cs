using System.Diagnostics;
using CAFE_DELIGHT.Models;
using CAFE_DELIGHT.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Mvc;

namespace CAFE_DELIGHT.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly CafeDelightDbContext _context;

        public HomeController(ILogger<HomeController> logger, CafeDelightDbContext context)
        {
            _logger = logger;
            _context = context;
        }

        public IActionResult Index()
        {
            var products = _context.Products.Include(p => p.Category).Where(p => !p.IsDeleted && p.Status == "Active").Take(6).ToList();
            return View(products);
        }

        public IActionResult Menu()
        {
            var products = _context.Products.Include(p => p.Category).Where(p => !p.IsDeleted).ToList();
            ViewBag.Categories = _context.Categories.Where(c => c.IsActive).ToList();
            return View(products);
        }

        public IActionResult About()
        {
            return View();
        }

        public IActionResult Contact()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
