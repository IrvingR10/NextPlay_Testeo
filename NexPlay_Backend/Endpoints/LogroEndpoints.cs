using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class LogroEndpoints
{
    public static void MapLogroEndpoints(this WebApplication app)
    {
        var logrosGroup = app.MapGroup("/api/logros");

        logrosGroup.MapGet("", async (LogroService service) =>
        {
            var logros = await service.ObtenerTodosAsync();
            return Results.Ok(logros);
        });

        logrosGroup.MapGet("/{id:long}", async (uint id, LogroService service) =>
        {
            var logro = await service.ObtenerPorIdAsync(id);
            return logro is null ? Results.NotFound() : Results.Ok(logro);
        });

        var usuariosGroup = app.MapGroup("/api/usuarios");

        usuariosGroup.MapGet("/{idUsuario:long}/logros", async (ulong idUsuario, LogroService service) =>
        {
            var logros = await service.ObtenerPorUsuarioAsync(idUsuario);
            return Results.Ok(logros);
        });
    }
}
