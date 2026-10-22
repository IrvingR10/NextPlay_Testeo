using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Ranking;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class RankingService
{
    private readonly NexPlayContext _context;

    public RankingService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<List<RankingDto>> ObtenerRankingGlobalAsync()
    {
        var ranking = await _context.VwRankingGlobals
            .AsNoTracking()
            .OrderBy(r => r.Posicion)
            .ToListAsync();

        return ranking.Select(r => r.ToDto()).ToList();
    }

    public async Task<List<RankingDto>> ObtenerRankingSemanalAsync()
    {
        var ranking = await _context.VwRankingSemanals
            .AsNoTracking()
            .OrderBy(r => r.Posicion)
            .ToListAsync();

        return ranking.Select(r => r.ToDto()).ToList();
    }
}
