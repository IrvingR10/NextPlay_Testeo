using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Avatar;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class AvatarService
{
    private readonly NexPlayContext _context;

    public AvatarService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<List<AvatarDto>> ObtenerTodosAsync()
    {
        var avatares = await _context.Set<Avatar>()
            .AsNoTracking()
            .OrderBy(a => a.IdAvatar)
            .ToListAsync();

        return avatares.Select(a => a.ToDto()).ToList();
    }

    public async Task<AvatarDto?> ObtenerPorIdAsync(ushort id)
    {
        var avatar = await _context.Set<Avatar>()
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.IdAvatar == id);

        return avatar?.ToDto();
    }
}
