using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Categoria;
using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;
namespace NexPlayAPI.Services;

public class CategoriaJuegoService
{
    private readonly NexPlayContext _context;
    public CategoriaJuegoService(NexPlayContext context) => _context = context;

    public async Task<List<CategoriaJuegoDto>> ObtenerTodasAsync()
    {
        var categorias = await _context.Set<CategoriaJuego>()
            .AsNoTracking()
            .OrderBy(c => c.Nombre)
            .ToListAsync();
        return categorias.Select(c => c.ToDto()).ToList();
    }

    public async Task<List<JuegoDto>?> ObtenerJuegosPorCategoriaAsync(ushort idCategoria)
    {
        var existe = await _context.Set<CategoriaJuego>()
            .AsNoTracking()
            .AnyAsync(c => c.IdCategoria == idCategoria);

        if (!existe) return null;

        var juegos = await _context.Set<Juego>()
            .AsNoTracking()
            .Include(j => j.IdCategoria)
            .Where(j => j.IdCategoria.Any(c => c.IdCategoria == idCategoria))
            .OrderBy(j => j.Nombre)
            .ToListAsync();

        return juegos.Select(j => j.ToDto()).ToList();
    }
}
