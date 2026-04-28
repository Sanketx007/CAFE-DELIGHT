using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CAFE_DELIGHT.Data;
using CAFE_DELIGHT.Models;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;

namespace CAFE_DELIGHT.Controllers
{
    public class AccountController : Controller
    {
        private readonly CafeDelightDbContext _context;

        public AccountController(CafeDelightDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> Login()
        {
            var users = await _context.Users.Include(u => u.Role).ToListAsync();
            return View(users);
        }

        [HttpPost]
        public async Task<IActionResult> Login(string email, string password)
        {
            if (!ModelState.IsValid) return View();

            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Email == email && u.PasswordHash == password); // Simple pass check

            if (user == null)
            {
                ModelState.AddModelError("Email", "Invalid email or password.");
                return View();
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role?.RoleName ?? "Customer"),
                new Claim("UserId", user.UserId.ToString())
            };

            user.LastLogin = DateTime.Now;
            await _context.SaveChangesAsync();

            var claimsIdentity = new ClaimsIdentity(claims, "CookieAuth");
            await HttpContext.SignInAsync("CookieAuth", new ClaimsPrincipal(claimsIdentity));

            // Redirect based on role
            if (user.Role?.RoleName == "Admin")
            {
                return RedirectToAction("Dashboard", "Admin");
            }

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Register(string fullName, string email, string phone, string password, string confirmPassword)
        {
            if (password != confirmPassword)
            {
                ModelState.AddModelError("ConfirmPassword", "Passwords do not match.");
            }

            if (await _context.Users.AnyAsync(u => u.Email == email))
            {
                ModelState.AddModelError("Email", "Email already registered.");
            }

            if (!ModelState.IsValid) return View();

            var newUser = new User
            {
                FullName = fullName,
                Email = email,
                Phone = phone,
                PasswordHash = password, // Simplified
                RoleId = 2, // Default: Customer
                Status = "Active",
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return RedirectToAction("Login");
        }

        [HttpPost]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync("CookieAuth");
            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult ForgotPassword()
        {
            return View();
        }

        [HttpPost]
        public IActionResult ForgotPassword(string email)
        {
            // In a real app you would send a reset email here.
            return RedirectToAction("CheckEmail");
        }

        [HttpGet]
        public IActionResult CheckEmail()
        {
            return View();
        }
    }
}

