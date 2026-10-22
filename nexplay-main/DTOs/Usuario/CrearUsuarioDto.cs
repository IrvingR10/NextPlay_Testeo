namespace NexPlayAPI.DTOs.Usuario;

public class CrearUsuarioDto
{
    public string NombreCompleto { get; set; } = string.Empty;
    public string Correo { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? Apodo { get; set; }
    public ushort? IdAvatar { get; set; }
}
