using NexPlayAPI.DTOs.Categoria;
using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.Models;
namespace NexPlayAPI.Mappings;

public static class JuegoMapping
{
    public static JuegoDto ToDto(this Juego juego) => new()
    {
        IdJuego = juego.IdJuego,
        Nombre = juego.Nombre,
        Descripcion = juego.Descripcion,
        Dificultad = juego.Dificultad,
        MaxJugadores = juego.MaxJugadores,
        Imagen = juego.Imagen,
        RecompensaXpBase = juego.RecompensaXpBase,
        RecompensaMonedasBase = juego.RecompensaMonedasBase,
        RecompensaGemasBase = juego.RecompensaGemasBase,
        Categorias = juego.IdCategoria.Select(c => new CategoriaJuegoDto
        {
            IdCategoria = c.IdCategoria,
            Nombre = c.Nombre
        }).ToList()
    };

    public static DetalleJuegoDto ToDetalleDto(this Juego juego) => new()
    {
        IdJuego = juego.IdJuego,
        Nombre = juego.Nombre,
        Descripcion = juego.Descripcion,
        Dificultad = juego.Dificultad,
        MaxJugadores = juego.MaxJugadores,
        Imagen = juego.Imagen,
        RecompensaXpBase = juego.RecompensaXpBase,
        RecompensaMonedasBase = juego.RecompensaMonedasBase,
        RecompensaGemasBase = juego.RecompensaGemasBase,
        Categorias = juego.IdCategoria.Select(c => new CategoriaJuegoDto
        {
            IdCategoria = c.IdCategoria,
            Nombre = c.Nombre
        }).ToList()
    };
}
