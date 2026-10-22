namespace NexPlayAPI.DTOs.Reto;

public class RetoDto
{
    public ulong IdReto { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public string TipoObjetivo { get; set; } = string.Empty;

    public uint ObjetivoValor { get; set; }

    public ulong? IdJuego { get; set; }

    public ushort RecompensaXp { get; set; }

    public uint RecompensaMonedas { get; set; }

    public ushort RecompensaGemas { get; set; }

    public DateTime Inicio { get; set; }

    public DateTime Fin { get; set; }
}
