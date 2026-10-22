namespace NexPlayAPI.DTOs.Logro;

public class LogroDto
{
    public uint IdLogro { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public string? Icono { get; set; }
}
