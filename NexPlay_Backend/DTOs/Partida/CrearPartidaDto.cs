namespace NexPlayAPI.DTOs.Partida;

public class CrearPartidaDto
{
    public ulong IdUsuario { get; set; }

    public ulong IdJuego { get; set; }

    public uint Puntaje { get; set; }

    public string Resultado { get; set; } = "VICTORIA";

    public uint DuracionSegundos { get; set; }

    public DateTime? FechaHora { get; set; }
}
