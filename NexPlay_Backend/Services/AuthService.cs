using Microsoft.EntityFrameworkCore;
using NexPlayAPI.DTOs.Auth;
using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;

namespace NexPlayAPI.Services;

public class AuthService
{
    private readonly NexPlayContext _context;

    public AuthService(NexPlayContext context)
    {
        _context = context;
    }

    public async Task<(bool Exito, string Mensaje, UsuarioDto? Usuario)> LoginAsync(LoginDto dto)
    {
        var correoNormalizado = dto.Correo.Trim().ToLower();

        var usuario = await _context.Set<Usuario>()
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Correo.ToLower() == correoNormalizado);

        if (usuario is null)
            return (false, "Correo o contraseña incorrectos.", null);

        var passwordValida = BCrypt.Net.BCrypt.Verify(dto.Password, usuario.PasswordHash);

        if (!passwordValida)
            return (false, "Correo o contraseña incorrectos.", null);

        return (true, "Inicio de sesión correcto.", usuario.ToDto());
    }
}
