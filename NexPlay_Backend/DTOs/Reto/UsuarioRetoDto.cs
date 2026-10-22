namespace NexPlayAPI.DTOs.Reto;

public class UsuarioRetoDto
{
    public ulong IdUsuario { get; set; }

    public ulong IdReto { get; set; }

    public uint Progreso { get; set; }

    public bool Reclamado { get; set; }

    public string NombreReto { get; set; } = string.Empty;

    public string DescripcionReto { get; set; } = string.Empty;

    public string TipoObjetivo { get; set; } = string.Empty;

    public uint ObjetivoValor { get; set; }

    public ushort RecompensaXp { get; set; }

    public uint RecompensaMonedas { get; set; }

    public ushort RecompensaGemas { get; set; }

    public DateTime Inicio { get; set; }

    public DateTime Fin { get; set; }
}
