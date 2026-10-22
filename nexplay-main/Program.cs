using Microsoft.EntityFrameworkCore;
using NexPlayAPI.Endpoints;
using NexPlayAPI.Models;
using NexPlayAPI.Services;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration
    .GetConnectionString("NexPlayConnection")
    ?? throw new InvalidOperationException(
        "No se encontrÃ³ la cadena de conexiÃ³n NexPlayConnection."
    );

builder.Services.AddDbContext<NexPlayContext>(options =>
    options.UseMySql(
        connectionString,
        ServerVersion.AutoDetect(connectionString)
    ));

// Servicios de Paola
builder.Services.AddScoped<UsuarioService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<AvatarService>();
builder.Services.AddScoped<JuegoService>();
builder.Services.AddScoped<CategoriaJuegoService>();

// Servicios de Joselin
builder.Services.AddScoped<PartidaService>();
builder.Services.AddScoped<RetoService>();
builder.Services.AddScoped<LogroService>();
builder.Services.AddScoped<RankingService>();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Endpoints de Paola
app.MapUsuarioEndpoints();
app.MapAuthEndpoints();
app.MapAvatarEndpoints();
app.MapJuegoEndpoints();
app.MapCategoriaJuegoEndpoints();

// Endpoints de Joselin
app.MapPartidaEndpoints();
app.MapRetoEndpoints();
app.MapLogroEndpoints();
app.MapRankingEndpoints();

app.Run();
