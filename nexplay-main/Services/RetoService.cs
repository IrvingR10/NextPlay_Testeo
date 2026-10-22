using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Reto;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class RetoService
{
    private readonly NexPlayContext _context;

    public RetoService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<List<RetoDto>> ObtenerTodosAsync()
    {
        var retos = await _context.Retos
            .AsNoTracking()
            .OrderBy(r => r.Inicio)
            .ToListAsync();

        return retos.Select(r => r.ToDto()).ToList();
    }

    public async Task<RetoDto?> ObtenerPorIdAsync(ulong id)
    {
        var reto = await _context.Retos
            .AsNoTracking()
            .FirstOrDefaultAsync(r => r.IdReto == id);

        return reto?.ToDto();
    }

    public async Task<List<UsuarioRetoDto>> ObtenerRetosPorUsuarioAsync(ulong idUsuario)
    {
        var usuarioRetos = await _context.UsuarioRetos
            .AsNoTracking()
            .Include(ur => ur.IdRetoNavigation)
            .Where(ur => ur.IdUsuario == idUsuario)
            .OrderByDescending(ur => ur.IdRetoNavigation.Inicio)
            .ToListAsync();

        return usuarioRetos.Select(ur => ur.ToDto()).ToList();
    }

    public async Task<UsuarioRetoDto?> ObtenerRetoUsuarioAsync(ulong idUsuario, ulong idReto)
    {
        var usuarioReto = await _context.UsuarioRetos
            .AsNoTracking()
            .Include(ur => ur.IdRetoNavigation)
            .FirstOrDefaultAsync(ur => ur.IdUsuario == idUsuario && ur.IdReto == idReto);

        return usuarioReto?.ToDto();
    }

    public async Task<UsuarioRetoDto> ActualizarProgresoAsync(ulong idUsuario, ulong idReto, UsuarioRetoDto dto)
    {
        ArgumentNullException.ThrowIfNull(dto);

        var usuarioReto = await _context.UsuarioRetos
            .FirstOrDefaultAsync(ur => ur.IdUsuario == idUsuario && ur.IdReto == idReto);

        if (usuarioReto is null)
        {
            var retoExiste = await _context.Retos.AsNoTracking().AnyAsync(r => r.IdReto == idReto);
            if (!retoExiste)
            {
                throw new KeyNotFoundException($"No existe el reto con id {idReto}.");
            }

            var usuarioExiste = await _context.Usuarios.AsNoTracking().AnyAsync(u => u.IdUsuario == idUsuario);
            if (!usuarioExiste)
            {
                throw new KeyNotFoundException($"No existe el usuario con id {idUsuario}.");
            }

            usuarioReto = new UsuarioReto
            {
                IdUsuario = idUsuario,
                IdReto = idReto,
                Progreso = dto.Progreso,
                Reclamado = dto.Reclamado
            };

            _context.UsuarioRetos.Add(usuarioReto);
        }
        else
        {
            usuarioReto.Progreso = dto.Progreso;
            usuarioReto.Reclamado = dto.Reclamado;
        }

        await _context.SaveChangesAsync();

        var actualizado = await _context.UsuarioRetos
            .AsNoTracking()
            .Include(ur => ur.IdRetoNavigation)
            .FirstOrDefaultAsync(ur => ur.IdUsuario == idUsuario && ur.IdReto == idReto);

        return actualizado!.ToDto();
    }
}
