using NexPlayAPI.DTOs.Avatar;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class AvatarMapping
{
    public static AvatarDto ToDto(this Avatar avatar)
    {
        return new AvatarDto
        {
            IdAvatar = avatar.IdAvatar,
            Nombre = avatar.Nombre,
            Imagen = avatar.Imagen
        };
    }
}
