using NexPlayAPI.DTOs.Reto;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class RetoMapping
{
    public static RetoDto ToDto(this Reto reto)
    {
        ArgumentNullException.ThrowIfNull(reto);

        return new RetoDto
        {
            IdReto = reto.IdReto,
            Nombre = reto.Nombre,
            Descripcion = reto.Descripcion,
            TipoObjetivo = reto.TipoObjetivo,
            ObjetivoValor = reto.ObjetivoValor,
            IdJuego = reto.IdJuego,
            RecompensaXp = reto.RecompensaXp,
            RecompensaMonedas = reto.RecompensaMonedas,
            RecompensaGemas = reto.RecompensaGemas,
            Inicio = reto.Inicio,
            Fin = reto.Fin
        };
    }

    public static UsuarioRetoDto ToDto(this UsuarioReto usuarioReto)
    {
        ArgumentNullException.ThrowIfNull(usuarioReto);

        return new UsuarioRetoDto
        {
            IdUsuario = usuarioReto.IdUsuario,
            IdReto = usuarioReto.IdReto,
            Progreso = usuarioReto.Progreso,
            Reclamado = usuarioReto.Reclamado,
            NombreReto = usuarioReto.IdRetoNavigation?.Nombre ?? string.Empty,
            DescripcionReto = usuarioReto.IdRetoNavigation?.Descripcion ?? string.Empty,
            TipoObjetivo = usuarioReto.IdRetoNavigation?.TipoObjetivo ?? string.Empty,
            ObjetivoValor = usuarioReto.IdRetoNavigation?.ObjetivoValor ?? 0,
            RecompensaXp = usuarioReto.IdRetoNavigation?.RecompensaXp ?? 0,
            RecompensaMonedas = usuarioReto.IdRetoNavigation?.RecompensaMonedas ?? 0,
            RecompensaGemas = usuarioReto.IdRetoNavigation?.RecompensaGemas ?? 0,
            Inicio = usuarioReto.IdRetoNavigation?.Inicio ?? DateTime.MinValue,
            Fin = usuarioReto.IdRetoNavigation?.Fin ?? DateTime.MinValue
        };
    }
}
