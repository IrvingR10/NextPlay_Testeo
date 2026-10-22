using NexPlayAPI.DTOs.Categoria;
namespace NexPlayAPI.DTOs.Juego;
public class DetalleJuegoDto
{
    public ulong IdJuego { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Dificultad { get; set; } = string.Empty;
    public byte MaxJugadores { get; set; }
    public string Imagen { get; set; } = string.Empty;
    public ushort RecompensaXpBase { get; set; }
    public uint RecompensaMonedasBase { get; set; }
    public ushort RecompensaGemasBase { get; set; }
    public List<CategoriaJuegoDto> Categorias { get; set; } = new();
}
