using NexPlayAPI.DTOs.Reto;
using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class RetoEndpoints
{
    public static void MapRetoEndpoints(this WebApplication app)
    {
        var retosGroup = app.MapGroup("/api/retos");

        retosGroup.MapGet("", async (RetoService service) =>
        {
            var retos = await service.ObtenerTodosAsync();
            return Results.Ok(retos);
        });

        retosGroup.MapGet("/{id:long}", async (ulong id, RetoService service) =>
        {
            var reto = await service.ObtenerPorIdAsync(id);
            return reto is null ? Results.NotFound() : Results.Ok(reto);
        });

        var usuariosGroup = app.MapGroup("/api/usuarios");

        usuariosGroup.MapGet("/{idUsuario:long}/retos", async (ulong idUsuario, RetoService service) =>
        {
            var retos = await service.ObtenerRetosPorUsuarioAsync(idUsuario);
            return Results.Ok(retos);
        });

        usuariosGroup.MapPatch("/{idUsuario:long}/retos/{idReto:long}", async (ulong idUsuario, ulong idReto, UsuarioRetoDto dto, RetoService service) =>
        {
            if (dto is null)
            {
                return Results.BadRequest("Los datos del reto son obligatorios.");
            }

            try
            {
                var actualizado = await service.ActualizarProgresoAsync(idUsuario, idReto, dto);
                return Results.Ok(actualizado);
            }
            catch (KeyNotFoundException ex)
            {
                return Results.NotFound(ex.Message);
            }
            catch (Exception)
            {
                return Results.BadRequest("No se pudo actualizar el progreso del reto.");
            }
        });
    }
}
