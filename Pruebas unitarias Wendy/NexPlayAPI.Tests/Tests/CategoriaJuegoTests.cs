using NexPlayAPI.DTOs.Categoria;
using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.Models;
using NexPlayAPI.Services;
using NexPlayAPI.Tests.Common;

namespace NexPlayAPI.Tests.Tests;

/// <summary>
/// Pruebas unitarias correspondientes a las asignaciones de Wendy:
/// - API 11: GET /api/categorias (Obtener todas las categorías)
/// - API 12: GET /api/categorias/{id}/juegos (Obtener juegos de una categoría)
/// </summary>
public class CategoriaJuegoTests
{
    #region API 11: GET /api/categorias

    [Fact]
    public async Task API11_ObtenerTodasAsync_ConCategoriasEnBaseDeDatos_RetornaListaOrdenadaAlfabeticamente()
    {
        // Arrange: Crear varias categorías desordenadas en BD
        using var context = TestDbContextFactory.CreateContext();
        var catPuzzles = new CategoriaJuego { IdCategoria = 1, Nombre = "Puzzles" };
        var catAccion = new CategoriaJuego { IdCategoria = 2, Nombre = "Acción" };
        var catDeportes = new CategoriaJuego { IdCategoria = 3, Nombre = "Deportes" };

        context.CategoriaJuegos.AddRange(catPuzzles, catAccion, catDeportes);
        await context.SaveChangesAsync();

        var service = new CategoriaJuegoService(context);

        // Act
        var resultado = await service.ObtenerTodasAsync();

        // Assert: Valida cantidad y orden alfabético ("Acción", "Deportes", "Puzzles")
        Assert.NotNull(resultado);
        Assert.Equal(3, resultado.Count);

        Assert.Equal("Acción", resultado[0].Nombre);
        Assert.Equal((ushort)2, resultado[0].IdCategoria);

        Assert.Equal("Deportes", resultado[1].Nombre);
        Assert.Equal((ushort)3, resultado[1].IdCategoria);

        Assert.Equal("Puzzles", resultado[2].Nombre);
        Assert.Equal((ushort)1, resultado[2].IdCategoria);
    }

    [Fact]
    public async Task API11_ObtenerTodasAsync_SinCategoriasEnBaseDeDatos_RetornaListaVacia()
    {
        // Arrange: Contexto vacío
        using var context = TestDbContextFactory.CreateContext();
        var service = new CategoriaJuegoService(context);

        // Act
        var resultado = await service.ObtenerTodasAsync();

        // Assert: Retorna lista vacía no nula
        Assert.NotNull(resultado);
        Assert.Empty(resultado);
    }

    #endregion

    #region API 12: GET /api/categorias/{id}/juegos

    [Fact]
    public async Task API12_ObtenerJuegosPorCategoriaAsync_CategoriaExistenteConJuegos_RetornaListaJuegosOrdenados()
    {
        // Arrange: Categoría con juegos asociados
        using var context = TestDbContextFactory.CreateContext();
        var catCarreras = new CategoriaJuego { IdCategoria = 1, Nombre = "Carreras" };
        var catAventura = new CategoriaJuego { IdCategoria = 2, Nombre = "Aventura" };

        var juegoTurbo = new Juego
        {
            IdJuego = 10,
            Nombre = "Turbo Drifters",
            Descripcion = "Drift en autopistas",
            Dificultad = "MEDIA",
            MaxJugadores = 4,
            Imagen = "turbo.png",
            IdCategoria = new List<CategoriaJuego> { catCarreras }
        };

        var juegoAlpha = new Juego
        {
            IdJuego = 11,
            Nombre = "Alpha Racing",
            Descripcion = "Carreras de fórmula uno",
            Dificultad = "DIFICIL",
            MaxJugadores = 2,
            Imagen = "alpha.png",
            IdCategoria = new List<CategoriaJuego> { catCarreras }
        };

        var juegoAventura = new Juego
        {
            IdJuego = 12,
            Nombre = "Lost Island",
            Descripcion = "Sobrevive a la isla",
            Dificultad = "FACIL",
            MaxJugadores = 1,
            Imagen = "island.png",
            IdCategoria = new List<CategoriaJuego> { catAventura }
        };

        context.CategoriaJuegos.AddRange(catCarreras, catAventura);
        context.Juegos.AddRange(juegoTurbo, juegoAlpha, juegoAventura);
        await context.SaveChangesAsync();

        var service = new CategoriaJuegoService(context);

        // Act: Consultar juegos de la categoría 1 ("Carreras")
        var resultado = await service.ObtenerJuegosPorCategoriaAsync(1);

        // Assert: Retorna exactamente los 2 juegos de carreras ordenados alfabéticamente ("Alpha Racing", "Turbo Drifters")
        Assert.NotNull(resultado);
        Assert.Equal(2, resultado.Count);

        Assert.Equal("Alpha Racing", resultado[0].Nombre);
        Assert.Equal((ulong)11, resultado[0].IdJuego);

        Assert.Equal("Turbo Drifters", resultado[1].Nombre);
        Assert.Equal((ulong)10, resultado[1].IdJuego);

        // Asegura que no incluye juegos de otra categoría ("Lost Island")
        Assert.DoesNotContain(resultado, j => j.Nombre == "Lost Island");
    }

    [Fact]
    public async Task API12_ObtenerJuegosPorCategoriaAsync_CategoriaExistenteSinJuegos_RetornaListaVacia()
    {
        // Arrange: Categoría creada en base de datos, pero sin ningún juego asignado
        using var context = TestDbContextFactory.CreateContext();
        var catVacia = new CategoriaJuego { IdCategoria = 5, Nombre = "Estrategia Vacía" };
        context.CategoriaJuegos.Add(catVacia);
        await context.SaveChangesAsync();

        var service = new CategoriaJuegoService(context);

        // Act
        var resultado = await service.ObtenerJuegosPorCategoriaAsync(5);

        // Assert: Debe retornar una lista vacía, NO debe retornar null (porque la categoría sí existe)
        Assert.NotNull(resultado);
        Assert.Empty(resultado);
    }

    [Fact]
    public async Task API12_ObtenerJuegosPorCategoriaAsync_CategoriaInexistente_RetornaNull()
    {
        // Arrange: Contexto sin la categoría 99
        using var context = TestDbContextFactory.CreateContext();
        var service = new CategoriaJuegoService(context);

        // Act: Consultar ID de categoría que no existe
        var resultado = await service.ObtenerJuegosPorCategoriaAsync(99);

        // Assert: Debe retornar null para que el Endpoint responda 404 Not Found
        Assert.Null(resultado);
    }

    #endregion
}
