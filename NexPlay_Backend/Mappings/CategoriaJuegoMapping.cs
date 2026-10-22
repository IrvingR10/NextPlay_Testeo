using NexPlayAPI.DTOs.Categoria;
using NexPlayAPI.Models;
namespace NexPlayAPI.Mappings;
public static class CategoriaJuegoMapping
{
    public static CategoriaJuegoDto ToDto(this CategoriaJuego categoria) => new()
    {
        IdCategoria = categoria.IdCategoria,
        Nombre = categoria.Nombre
    };
}
