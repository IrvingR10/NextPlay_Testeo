namespace NexPlayAPI.DTOs.Usuario;

public class UsuarioDto
{
    public ulong IdUsuario { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Correo { get; set; } = string.Empty;
    public string? Apodo { get; set; }
    public ushort? IdAvatar { get; set; }
    public uint XpTotal { get; set; }
    public uint Monedas { get; set; }
    public uint Gemas { get; set; }
}
