using DiaryApp.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<ApplicationDbContext>(
    options => options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Kestrel based on environment
if (builder.Environment.IsDevelopment())
{
    // Local development port
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.ListenAnyIP(5298);
    });
}
else
{
    // Production/Docker port
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.ListenAnyIP(8080);
    });
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    // Development: Show detailed errors
    app.UseDeveloperExceptionPage();
}
else
{
    // Production: Use custom error pages
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    
    // Ensure HTTPS in production
    app.UseHttpsRedirection();
}

app.UseStaticFiles(); // Ensure static files are served
app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
//small change