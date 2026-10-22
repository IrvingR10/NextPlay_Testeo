using NexPlayAPI.DTOs.Logro;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class LogroMapping
{
    public static LogroDto ToDto(this Logro logro)
    {
        ArgumentNullException.ThrowIfNull(logro);

        return new LogroDto
        {
            IdLogro = logro.IdLogro,
            Nombre = logro.Nombre,
            Descripcion = logro.Descripcion,
            Icono = logro.Icono
        };
    }
}
