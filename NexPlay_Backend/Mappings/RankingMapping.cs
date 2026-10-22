using NexPlayAPI.DTOs.Ranking;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class RankingMapping
{
    public static RankingDto ToDto(this VwRankingGlobal ranking)
    {
        ArgumentNullException.ThrowIfNull(ranking);

        return new RankingDto
        {
            IdUsuario = ranking.IdUsuario,
            Apodo = ranking.Apodo,
            Puntos = ranking.Puntos,
            Posicion = ranking.Posicion
        };
    }

    public static RankingDto ToDto(this VwRankingSemanal ranking)
    {
        ArgumentNullException.ThrowIfNull(ranking);

        return new RankingDto
        {
            IdUsuario = ranking.IdUsuario,
            Apodo = ranking.Apodo,
            Puntos = ranking.Puntos,
            Posicion = ranking.Posicion
        };
    }
}
