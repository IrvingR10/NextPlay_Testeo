using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Models;

namespace NexPlayAPI.Mappings;

public static class PartidaMapping
{
    public static Partidum ToEntity(this CrearPartidaDto dto)
    {
        ArgumentNullException.ThrowIfNull(dto);

        return new Partidum
        {
            IdUsuario = dto.IdUsuario,
            IdJuego = dto.IdJuego,
            Puntaje = dto.Puntaje,
            Resultado = dto.Resultado.Trim(),
            DuracionSegundos = dto.DuracionSegundos,
            FechaHora = dto.FechaHora ?? DateTime.UtcNow
        };
    }

    public static PartidaDto ToDto(this Partidum partida)
    {
        ArgumentNullException.ThrowIfNull(partida);

        return new PartidaDto
        {
            IdPartida = partida.IdPartida,
            IdUsuario = partida.IdUsuario,
            IdJuego = partida.IdJuego,
            Puntaje = partida.Puntaje,
            Resultado = partida.Resultado,
            DuracionSegundos = partida.DuracionSegundos,
            FechaHora = partida.FechaHora
        };
    }

    public static EstadisticaUsuarioDto ToDto(this VwEstadisticasUsuario estadisticas)
    {
        ArgumentNullException.ThrowIfNull(estadisticas);

        return new EstadisticaUsuarioDto
        {
            IdUsuario = estadisticas.IdUsuario,
            Apodo = estadisticas.Apodo,
            XpTotal = estadisticas.XpTotal,
            Monedas = estadisticas.Monedas,
            Gemas = estadisticas.Gemas,
            PartidasJugadas = estadisticas.PartidasJugadas,
            Victorias = estadisticas.Victorias,
            MejorPuntaje = estadisticas.MejorPuntaje,
            TiempoJugadoSegundos = estadisticas.TiempoJugadoSegundos
        };
    }

    public static MejorPuntajeUsuarioJuegoDto ToDto(this VwMejorPuntajeUsuarioJuego mejorPuntaje)
    {
        ArgumentNullException.ThrowIfNull(mejorPuntaje);

        return new MejorPuntajeUsuarioJuegoDto
        {
            IdUsuario = mejorPuntaje.IdUsuario,
            IdJuego = mejorPuntaje.IdJuego,
            MejorPuntaje = mejorPuntaje.MejorPuntaje
        };
    }
}
