using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;
namespace NexPlayAPI.Services;

public class JuegoService
{
    private readonly NexPlayContext _context;
    public JuegoService(NexPlayContext context) => _context = context;

    public async Task<List<JuegoDto>> ObtenerTodosAsync()
    {
        var juegos = await _context.Set<Juego>()
            .AsNoTracking()
            .Include(j => j.IdCategoria)
            .OrderBy(j => j.Nombre)
            .ToListAsync();
        return juegos.Select(j => j.ToDto()).ToList();
    }

    public async Task<DetalleJuegoDto?> ObtenerPorIdAsync(ulong id)
    {
        var juego = await _context.Set<Juego>()
            .AsNoTracking()
            .Include(j => j.IdCategoria)
            .FirstOrDefaultAsync(j => j.IdJuego == id);
        return juego?.ToDetalleDto();
    }
}
