using NexPlayAPI.Services;
namespace NexPlayAPI.Endpoints;

public static class CategoriaJuegoEndpoints
{
    public static IEndpointRouteBuilder MapCategoriaJuegoEndpoints(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/api/categorias").WithTags("Categorías");

        grupo.MapGet("/", async (CategoriaJuegoService service) =>
            Results.Ok(await service.ObtenerTodasAsync()))
            .WithName("ObtenerCategorias")
            .WithSummary("Obtiene todas las categorías de juegos");

        grupo.MapGet("/{id}/juegos", async (ushort id, CategoriaJuegoService service) =>
        {
            var juegos = await service.ObtenerJuegosPorCategoriaAsync(id);
            return juegos is null
                ? Results.NotFound(new { mensaje = "Categoría no encontrada." })
                : Results.Ok(juegos);
        })
        .WithName("ObtenerJuegosPorCategoria")
        .WithSummary("Obtiene los juegos de una categoría");

        return app;
    }
}
