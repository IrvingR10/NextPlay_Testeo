using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class RankingEndpoints
{
    public static void MapRankingEndpoints(this WebApplication app)
    {
        var rankGroup = app.MapGroup("/api/ranking");

        rankGroup.MapGet("/global", async (RankingService service) =>
        {
            var ranking = await service.ObtenerRankingGlobalAsync();
            return Results.Ok(ranking);
        });

        rankGroup.MapGet("/semanal", async (RankingService service) =>
        {
            var ranking = await service.ObtenerRankingSemanalAsync();
            return Results.Ok(ranking);
        });
    }
}
