using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class PartidaService
{
    private readonly NexPlayContext _context;

    public PartidaService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<Partidum> CrearPartidaAsync(CrearPartidaDto dto)
    {
        ArgumentNullException.ThrowIfNull(dto);

        var usuarioExiste = await _context.Usuarios
            .AsNoTracking()
            .AnyAsync(u => u.IdUsuario == dto.IdUsuario);

        if (!usuarioExiste)
        {
            throw new KeyNotFoundException($"No existe el usuario con id {dto.IdUsuario}.");
        }

        var juegoExiste = await _context.Juegos
            .AsNoTracking()
            .AnyAsync(j => j.IdJuego == dto.IdJuego);

        if (!juegoExiste)
        {
            throw new KeyNotFoundException($"No existe el juego con id {dto.IdJuego}.");
        }

        var partida = dto.ToEntity();
        _context.Partida.Add(partida);
        await _context.SaveChangesAsync();

        return partida;
    }

    public async Task<Partidum?> ObtenerPorIdAsync(ulong id)
    {
        return await _context.Partida
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.IdPartida == id);
    }

    public async Task<List<Partidum>> ObtenerPorUsuarioAsync(ulong idUsuario)
    {
        return await _context.Partida
            .AsNoTracking()
            .Where(p => p.IdUsuario == idUsuario)
            .OrderByDescending(p => p.FechaHora)
            .ToListAsync();
    }

    public async Task<VwEstadisticasUsuario?> ObtenerEstadisticasUsuarioAsync(ulong idUsuario)
    {
        return await _context.VwEstadisticasUsuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.IdUsuario == idUsuario);
    }

    public async Task<List<MejorPuntajeUsuarioJuegoDto>> ObtenerMejorPuntajePorJuegoAsync(ulong idUsuario)
    {
        var mejores = await _context.VwMejorPuntajeUsuarioJuegos
            .AsNoTracking()
            .Where(m => m.IdUsuario == idUsuario)
            .OrderBy(m => m.IdJuego)
            .ToListAsync();

        return mejores.Select(m => m.ToDto()).ToList();
    }
}
