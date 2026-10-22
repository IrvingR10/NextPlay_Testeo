using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class UsuarioMapping
{
    public static UsuarioDto ToDto(this Usuario usuario)
    {
        return new UsuarioDto
        {
            IdUsuario = usuario.IdUsuario,
            NombreCompleto = usuario.NombreCompleto,
            Correo = usuario.Correo,
            Apodo = usuario.Apodo,
            IdAvatar = usuario.IdAvatar,
            XpTotal = usuario.XpTotal,
            Monedas = usuario.Monedas,
            Gemas = usuario.Gemas
        };
    }

    public static PerfilUsuarioDto ToPerfilDto(this Usuario usuario)
    {
        return new PerfilUsuarioDto
        {
            IdUsuario = usuario.IdUsuario,
            NombreCompleto = usuario.NombreCompleto,
            Correo = usuario.Correo,
            Apodo = usuario.Apodo,
            IdAvatar = usuario.IdAvatar,
            NombreAvatar = usuario.IdAvatarNavigation?.Nombre,
            ImagenAvatar = usuario.IdAvatarNavigation?.Imagen,
            XpTotal = usuario.XpTotal,
            Monedas = usuario.Monedas,
            Gemas = usuario.Gemas
        };
    }

    public static Usuario ToEntity(this CrearUsuarioDto dto, string passwordHash)
    {
        return new Usuario
        {
            NombreCompleto = dto.NombreCompleto,
            Correo = dto.Correo,
            PasswordHash = passwordHash,
            Apodo = dto.Apodo,
            IdAvatar = dto.IdAvatar,
            XpTotal = 0,
            Monedas = 0,
            Gemas = 0
        };
    }

    public static void ApplyUpdate(this Usuario usuario, ActualizarUsuarioDto dto)
    {
        usuario.NombreCompleto = dto.NombreCompleto;
        usuario.Apodo = dto.Apodo;
        usuario.IdAvatar = dto.IdAvatar;
    }
}
