using NexPlayAPI.DTOs.Auth;
using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/api/auth")
            .WithTags("Autenticación");

        grupo.MapPost("/login", async (LoginDto dto, AuthService service) =>
        {
            if (string.IsNullOrWhiteSpace(dto.Correo) ||
                string.IsNullOrWhiteSpace(dto.Password))
            {
                return Results.BadRequest(new
                {
                    mensaje = "Correo y contraseña son obligatorios."
                });
            }

            var resultado = await service.LoginAsync(dto);

            if (!resultado.Exito)
                return Results.Unauthorized();

            return Results.Ok(new
            {
                mensaje = resultado.Mensaje,
                usuario = resultado.Usuario
            });
        })
        .WithName("IniciarSesion")
        .WithSummary("Inicia sesión con correo y contraseña");

        return app;
    }
}
