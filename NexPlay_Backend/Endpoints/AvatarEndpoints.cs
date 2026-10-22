using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class AvatarEndpoints
{
    public static IEndpointRouteBuilder MapAvatarEndpoints(this IEndpointRouteBuilder app)
    {
        var grupo = app.MapGroup("/api/avatares")
            .WithTags("Avatares");

        grupo.MapGet("/", async (AvatarService service) =>
        {
            var avatares = await service.ObtenerTodosAsync();
            return Results.Ok(avatares);
        })
        .WithName("ObtenerAvatares")
        .WithSummary("Obtiene todos los avatares");

        grupo.MapGet("/{id:int}", async (ushort id, AvatarService service) =>
        {
            var avatar = await service.ObtenerPorIdAsync(id);

            return avatar is null
                ? Results.NotFound(new { mensaje = "Avatar no encontrado." })
                : Results.Ok(avatar);
        })
        .WithName("ObtenerAvatarPorId")
        .WithSummary("Obtiene un avatar por su ID");

        return app;
    }
}
