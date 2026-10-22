using NexPlayAPI.Services;
namespace NexPlayAPI.Endpoints;

public static class JuegoEndpoints
{
    public static IEndpointRouteBuilder MapJuegoEndpoints(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/api/juegos").WithTags("Juegos");

        grupo.MapGet("/", async (JuegoService service) =>
            Results.Ok(await service.ObtenerTodosAsync()))
            .WithName("ObtenerJuegos")
            .WithSummary("Obtiene todos los juegos");

        grupo.MapGet("/{id}", async (ulong id, JuegoService service) =>
        {
            var juego = await service.ObtenerPorIdAsync(id);
            return juego is null
                ? Results.NotFound(new { mensaje = "Juego no encontrado." })
                : Results.Ok(juego);
        })
        .WithName("ObtenerJuegoPorId")
        .WithSummary("Obtiene el detalle de un juego por su ID");

        return app;
    }
}
