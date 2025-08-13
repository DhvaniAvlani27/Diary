using Microsoft.AspNetCore.Mvc;

namespace DiaryApp.wwwroot
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
