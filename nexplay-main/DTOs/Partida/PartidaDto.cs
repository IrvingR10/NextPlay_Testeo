namespace NexPlayAPI.DTOs.Partida;

public class PartidaDto
{
    public ulong IdPartida { get; set; }

    public ulong IdUsuario { get; set; }

    public ulong IdJuego { get; set; }

    public uint Puntaje { get; set; }

    public string Resultado { get; set; } = string.Empty;

    public uint DuracionSegundos { get; set; }

    public DateTime FechaHora { get; set; }
}
