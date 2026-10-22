using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class UsuarioEndpoints
{
    public static IEndpointRouteBuilder MapUsuarioEndpoints(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/api/usuarios")
            .WithTags("Usuarios");

        grupo.MapGet("/", async (UsuarioService service) =>
        {
            var usuarios = await service.ObtenerTodosAsync();
            return Results.Ok(usuarios);
        })
        .WithName("ObtenerUsuarios")
        .WithSummary("Obtiene todos los usuarios");

        grupo.MapGet("/{id:long}", async (ulong id, UsuarioService service) =>
        {
            var usuario = await service.ObtenerPorIdAsync(id);

            return usuario is null
                ? Results.NotFound(new { mensaje = "Usuario no encontrado." })
                : Results.Ok(usuario);
        })
        .WithName("ObtenerUsuarioPorId")
        .WithSummary("Obtiene un usuario por su ID");

        grupo.MapGet("/{id:long}/perfil", async (ulong id, UsuarioService service) =>
        {
            var perfil = await service.ObtenerPerfilAsync(id);

            return perfil is null
                ? Results.NotFound(new { mensaje = "Usuario no encontrado." })
                : Results.Ok(perfil);
        })
        .WithName("ObtenerPerfilUsuario")
        .WithSummary("Obtiene el perfil completo de un usuario");

        grupo.MapPost("/", async (CrearUsuarioDto dto, UsuarioService service) =>
        {
            if (string.IsNullOrWhiteSpace(dto.NombreCompleto) ||
                string.IsNullOrWhiteSpace(dto.Correo) ||
                string.IsNullOrWhiteSpace(dto.Password))
            {
                return Results.BadRequest(new
                {
                    mensaje = "Nombre completo, correo y contraseña son obligatorios."
                });
            }

            var resultado = await service.CrearAsync(dto);

            if (!resultado.Exito)
                return Results.BadRequest(new { mensaje = resultado.Mensaje });

            return Results.Created(
                $"/api/usuarios/{resultado.Usuario!.IdUsuario}",
                new
                {
                    mensaje = resultado.Mensaje,
                    usuario = resultado.Usuario
                });
        })
        .WithName("CrearUsuario")
        .WithSummary("Registra un nuevo usuario");

        grupo.MapPut("/{id:long}", async (
            ulong id,
            ActualizarUsuarioDto dto,
            UsuarioService service) =>
        {
            if (string.IsNullOrWhiteSpace(dto.NombreCompleto))
            {
                return Results.BadRequest(new
                {
                    mensaje = "El nombre completo es obligatorio."
                });
            }

            var resultado = await service.ActualizarAsync(id, dto);

            if (!resultado.Exito)
            {
                if (resultado.Mensaje == "Usuario no encontrado.")
                    return Results.NotFound(new { mensaje = resultado.Mensaje });

                return Results.BadRequest(new { mensaje = resultado.Mensaje });
            }

            return Results.Ok(new
            {
                mensaje = resultado.Mensaje,
                usuario = resultado.Usuario
            });
        })
        .WithName("ActualizarUsuario")
        .WithSummary("Actualiza los datos principales de un usuario");

        return app;
    }
}
