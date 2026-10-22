using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Mappings;
using NexPlayAPI.Services;

namespace NexPlayAPI.Endpoints;

public static class PartidaEndpoints
{
    public static void MapPartidaEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/partidas");

        group.MapPost("", async (CrearPartidaDto dto, PartidaService service) =>
        {
            if (dto is null)
            {
                return Results.BadRequest("La partida es obligatoria.");
            }

            if (dto.IdUsuario == 0 || dto.IdJuego == 0)
            {
                return Results.BadRequest("Los campos IdUsuario e IdJuego son obligatorios.");
            }

            try
            {
                var partidaCreada = await service.CrearPartidaAsync(dto);
                return Results.Created($"/api/partidas/{partidaCreada.IdPartida}", partidaCreada.ToDto());
            }
            catch (KeyNotFoundException ex)
            {
                return Results.NotFound(ex.Message);
            }
            catch (Exception)
            {
                return Results.BadRequest("No se pudo registrar la partida.");
            }
        });

        group.MapGet("/{id:long}", async (ulong id, PartidaService service) =>
        {
            var partida = await service.ObtenerPorIdAsync(id);

            if (partida is null)
            {
                return Results.NotFound();
            }

            return Results.Ok(partida.ToDto());
        });

        group.MapGet("/usuario/{idUsuario:long}", async (ulong idUsuario, PartidaService service) =>
        {
            var partidas = await service.ObtenerPorUsuarioAsync(idUsuario);
            return Results.Ok(partidas.Select(p => p.ToDto()).ToList());
        });

        group.MapGet("/usuario/{idUsuario:long}/estadisticas", async (ulong idUsuario, PartidaService service) =>
        {
            var estadisticas = await service.ObtenerEstadisticasUsuarioAsync(idUsuario);

            if (estadisticas is null)
            {
                return Results.NotFound();
            }

            return Results.Ok(estadisticas.ToDto());
        });

        group.MapGet("/usuario/{idUsuario:long}/mejor-puntaje", async (ulong idUsuario, PartidaService service) =>
        {
            var mejoresPuntajes = await service.ObtenerMejorPuntajePorJuegoAsync(idUsuario);
            return Results.Ok(mejoresPuntajes);
        });
    }
}
