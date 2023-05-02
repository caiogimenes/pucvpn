var builder = WebApplication.CreateBuilder(args);
// Cria um objeto usando a classe Builder
var app = builder.Build();

// Usa o método MapGet para criar um rota da pagina que passa variaveis ao servidor para criar um certificado
app.MapGet("/vpn/{nome}/{email}/{country}/{state}/{local}/{org}/{unit}/{common}", async context =>
{
    // Recebe em nome o valor passado na posicao nome
    var nome = context.Request.RouteValues["nome"];
    // Recebe em email o valor passado na posicao email
    var email = context.Request.RouteValues["email"];
    // Recebe em country o valor passado na posicao country
    var country = context.Request.RouteValues["country"];
    // Recebe em state o valor passado na posicao state
    var state = context.Request.RouteValues["state"];
    // Recebe em local o valor passado na posicao local
    var local = context.Request.RouteValues["local"];
    // Recebe em org o valor passado na posicao org
    var org = context.Request.RouteValues["org"];
    // Recebe em unit o valor passado na posicao unit
    var unit = context.Request.RouteValues["unit"];
    // Recebe em common o valor passado na posicao common
    var common = context.Request.RouteValues["common"];

System.Diagnostics.ProcessStartInfo process = new System.Diagnostics.ProcessStartInfo();
    // Desabilita recurso da shell
    process.UseShellExecute = false;
    // Define o diretorio onde se encontra o sh
    process.WorkingDirectory = "/bin";
    // Define o binario a ser executado
    process.FileName = "sh";
    // Define o argumento a ser executado na shell
    process.Arguments = $"/home/caio/GitHub/pucvpn/src/Script/adduser.sh {nome} {email} {country} {state} {local} {org} {unit} {common}";
    // Redireciona o stout
    process.RedirectStandardOutput = true;
    // Executa
    System.Diagnostics.Process cmd = System.Diagnostics.Process.Start(process);
    cmd.WaitForExit();
//  await context.Response.WriteAsync($"Par 1: {p1} Par 2: {p2}");
});

// Usa o método MapGet para criar um rota da pagina que passa variaveis ao servidor para revogar um certificado
app.MapGet("/rvpn/{nome}", async context =>
{
    // Recebe em nome o valor passado na posicao nome
    var nome = context.Request.RouteValues["nome"];

System.Diagnostics.ProcessStartInfo process = new System.Diagnostics.ProcessStartInfo();
    // Desabilita recurso da shell
    process.UseShellExecute = false;
    // Define o diretorio onde se encontra o sh
    process.WorkingDirectory = "/bin";
    // Define o binario a ser executado
    process.FileName = "sh";
    // Define o argumento a ser executado na shell
    process.Arguments = $"/home/caio/GitHub/pucvpn/src/Script/revoke.sh {nome}";
    // Redireciona o stout
    process.RedirectStandardOutput = true;
    // Executa
    System.Diagnostics.Process cmd = System.Diagnostics.Process.Start(process);
    cmd.WaitForExit();
//  await context.Response.WriteAsync($"Par 1: {p1} Par 2: {p2}");
});

// Executa
app.Run();