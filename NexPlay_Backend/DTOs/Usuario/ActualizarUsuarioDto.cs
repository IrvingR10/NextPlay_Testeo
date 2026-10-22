namespace NexPlayAPI.DTOs.Usuario;

public class ActualizarUsuarioDto
{
    public string NombreCompleto { get; set; } = string.Empty;
    public string? Apodo { get; set; }
    public ushort? IdAvatar { get; set; }
}
