using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Logro;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class LogroService
{
    private readonly NexPlayContext _context;

    public LogroService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<List<LogroDto>> ObtenerTodosAsync()
    {
        var logros = await _context.Logros
            .AsNoTracking()
            .OrderBy(l => l.IdLogro)
            .ToListAsync();

        return logros.Select(l => l.ToDto()).ToList();
    }

    public async Task<LogroDto?> ObtenerPorIdAsync(uint id)
    {
        var logro = await _context.Logros
            .AsNoTracking()
            .FirstOrDefaultAsync(l => l.IdLogro == id);

        return logro?.ToDto();
    }

    public async Task<List<LogroDto>> ObtenerPorUsuarioAsync(ulong idUsuario)
    {
        var usuario = await _context.Usuarios
            .AsNoTracking()
            .Include(u => u.IdLogros)
            .FirstOrDefaultAsync(u => u.IdUsuario == idUsuario);

        if (usuario is null)
        {
            return new List<LogroDto>();
        }

        return usuario.IdLogros
            .OrderBy(l => l.IdLogro)
            .Select(l => l.ToDto())
            .ToList();
    }
}
