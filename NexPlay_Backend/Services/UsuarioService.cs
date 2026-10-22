using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class UsuarioService
{
    private readonly NexPlayContext _context;

    public UsuarioService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<List<UsuarioDto>> ObtenerTodosAsync()
    {
        return await _context.Set<Usuario>()
            .AsNoTracking()
            .Select(usuario => new UsuarioDto
            {
                IdUsuario = usuario.IdUsuario,
                NombreCompleto = usuario.NombreCompleto,
                Correo = usuario.Correo,
                Apodo = usuario.Apodo,
                IdAvatar = usuario.IdAvatar,
                XpTotal = usuario.XpTotal,
                Monedas = usuario.Monedas,
                Gemas = usuario.Gemas
            })
            .ToListAsync();
    }

    public async Task<UsuarioDto?> ObtenerPorIdAsync(ulong id)
    {
        var usuario = await _context.Set<Usuario>()
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.IdUsuario == id);

        return usuario?.ToDto();
    }

    public async Task<PerfilUsuarioDto?> ObtenerPerfilAsync(ulong id)
    {
        var usuario = await _context.Set<Usuario>()
            .AsNoTracking()
            .Include(u => u.IdAvatarNavigation)
            .FirstOrDefaultAsync(u => u.IdUsuario == id);

        return usuario?.ToPerfilDto();
    }

    public async Task<(bool Exito, string Mensaje, UsuarioDto? Usuario)> CrearAsync(CrearUsuarioDto dto)
    {
        var correoNormalizado = dto.Correo.Trim().ToLower();

        var correoExiste = await _context.Set<Usuario>()
            .AnyAsync(u => u.Correo.ToLower() == correoNormalizado);

        if (correoExiste)
            return (false, "El correo ya está registrado.", null);

        if (!string.IsNullOrWhiteSpace(dto.Apodo))
        {
            var apodoExiste = await _context.Set<Usuario>()
                .AnyAsync(u => u.Apodo != null && u.Apodo.ToLower() == dto.Apodo.Trim().ToLower());

            if (apodoExiste)
                return (false, "El apodo ya está en uso.", null);
        }

        if (dto.IdAvatar.HasValue)
        {
            var avatarExiste = await _context.Set<Avatar>()
                .AnyAsync(a => a.IdAvatar == dto.IdAvatar.Value);

            if (!avatarExiste)
                return (false, "El avatar seleccionado no existe.", null);
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);

        var usuario = dto.ToEntity(passwordHash);
        usuario.Correo = correoNormalizado;
        usuario.NombreCompleto = dto.NombreCompleto.Trim();

        if (!string.IsNullOrWhiteSpace(dto.Apodo))
            usuario.Apodo = dto.Apodo.Trim();

        _context.Set<Usuario>().Add(usuario);
        await _context.SaveChangesAsync();

        return (true, "Usuario creado correctamente.", usuario.ToDto());
    }

    public async Task<(bool Exito, string Mensaje, UsuarioDto? Usuario)> ActualizarAsync(
        ulong id,
        ActualizarUsuarioDto dto)
    {
        var usuario = await _context.Set<Usuario>()
            .FirstOrDefaultAsync(u => u.IdUsuario == id);

        if (usuario is null)
            return (false, "Usuario no encontrado.", null);

        if (!string.IsNullOrWhiteSpace(dto.Apodo))
        {
            var apodoExiste = await _context.Set<Usuario>()
                .AnyAsync(u =>
                    u.IdUsuario != id &&
                    u.Apodo != null &&
                    u.Apodo.ToLower() == dto.Apodo.Trim().ToLower());

            if (apodoExiste)
                return (false, "El apodo ya está en uso.", null);
        }

        if (dto.IdAvatar.HasValue)
        {
            var avatarExiste = await _context.Set<Avatar>()
                .AnyAsync(a => a.IdAvatar == dto.IdAvatar.Value);

            if (!avatarExiste)
                return (false, "El avatar seleccionado no existe.", null);
        }

        usuario.ApplyUpdate(dto);
        usuario.NombreCompleto = dto.NombreCompleto.Trim();

        if (!string.IsNullOrWhiteSpace(dto.Apodo))
            usuario.Apodo = dto.Apodo.Trim();

        await _context.SaveChangesAsync();

        return (true, "Usuario actualizado correctamente.", usuario.ToDto());
    }
}
