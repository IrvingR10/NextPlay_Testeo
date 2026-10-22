namespace NexPlayAPI.DTOs.Partida;

public class MejorPuntajeUsuarioJuegoDto
{
    public ulong IdUsuario { get; set; }

    public ulong IdJuego { get; set; }

    public uint? MejorPuntaje { get; set; }
}
