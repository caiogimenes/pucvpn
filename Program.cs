var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/vpn/{nome}/{email}/{country}/{state}/{local}/{org}/{unit}/{common}", async context =>
{
    var nome = context.Request.RouteValues["nome"];
    var email = context.Request.RouteValues["email"];
    var country = context.Request.RouteValues["country"];
    var state = context.Request.RouteValues["state"];
    var local = context.Request.RouteValues["local"];
    var org = context.Request.RouteValues["org"];
    var unit = context.Request.RouteValues["unit"];
    var common = context.Request.RouteValues["common"];

System.Diagnostics.ProcessStartInfo process = new System.Diagnostics.ProcessStartInfo();
    process.UseShellExecute = false;
    process.WorkingDirectory = "/bin";
    process.FileName = "sh";
    process.Arguments = $"/home/caio/adduser.sh {nome} {email} {country} {state} {local} {org} {unit} {common}";
    process.RedirectStandardOutput = true;
    System.Diagnostics.Process cmd = System.Diagnostics.Process.Start(process);
    cmd.WaitForExit();
//  await context.Response.WriteAsync($"Par 1: {p1} Par 2: {p2}");
});

app.Run();