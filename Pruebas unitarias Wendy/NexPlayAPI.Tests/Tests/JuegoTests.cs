using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.Models;
using NexPlayAPI.Services;
using NexPlayAPI.Tests.Common;

namespace NexPlayAPI.Tests.Tests;

/// <summary>
/// Pruebas unitarias correspondientes a las asignaciones de Wendy:
/// - API 9: GET /api/juegos (Obtener todos los juegos)
/// - API 10: GET /api/juegos/{id} (Obtener juego por ID)
/// </summary>
public class JuegoTests
{
    #region API 9: GET /api/juegos

    [Fact]
    public async Task API09_ObtenerTodosAsync_ConJuegosEnBaseDeDatos_RetornaListaOrdenadaAlfabeticamenteConCategorias()
    {
        // Arrange: Preparar contexto en memoria con juegos y categorías
        using var context = TestDbContextFactory.CreateContext();
        var catAccion = new CategoriaJuego { IdCategoria = 1, Nombre = "Acción" };
        var catCarreras = new CategoriaJuego { IdCategoria = 2, Nombre = "Carreras" };

        var juegoZ = new Juego
        {
            IdJuego = 1,
            Nombre = "Zombie Runner",
            Descripcion = "Corre y sobrevive a las hordas",
            Dificultad = "MEDIA",
            MaxJugadores = 1,
            Imagen = "zombie.png",
            RecompensaXpBase = 50,
            RecompensaMonedasBase = 100,
            RecompensaGemasBase = 5,
            IdCategoria = new List<CategoriaJuego> { catAccion }
        };

        var juegoP = new Juego
        {
            IdJuego = 2,
            Nombre = "Pixel Racer",
            Descripcion = "Carreras retro a toda velocidad",
            Dificultad = "FACIL",
            MaxJugadores = 2,
            Imagen = "pixel-racer.png",
            RecompensaXpBase = 30,
            RecompensaMonedasBase = 60,
            RecompensaGemasBase = 2,
            IdCategoria = new List<CategoriaJuego> { catCarreras }
        };

        context.CategoriaJuegos.AddRange(catAccion, catCarreras);
        context.Juegos.AddRange(juegoZ, juegoP);
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act: Invocar el método del servicio correspondiente a API 9
        var resultado = await service.ObtenerTodosAsync();

        // Assert: Validar que retorna 2 juegos, ordenados por nombre ("Pixel Racer" antes de "Zombie Runner")
        Assert.NotNull(resultado);
        Assert.Equal(2, resultado.Count);

        // Verificar orden alfabético
        Assert.Equal("Pixel Racer", resultado[0].Nombre);
        Assert.Equal("Zombie Runner", resultado[1].Nombre);

        // Verificar mapeo de campos y categorías del primer juego
        var primerJuego = resultado[0];
        Assert.Equal((ulong)2, primerJuego.IdJuego);
        Assert.Equal("Carreras retro a toda velocidad", primerJuego.Descripcion);
        Assert.Equal("FACIL", primerJuego.Dificultad);
        Assert.Equal((byte)2, primerJuego.MaxJugadores);
        Assert.Equal("pixel-racer.png", primerJuego.Imagen);
        Assert.Equal((ushort)30, primerJuego.RecompensaXpBase);
        Assert.Equal((uint)60, primerJuego.RecompensaMonedasBase);
        Assert.Equal((ushort)2, primerJuego.RecompensaGemasBase);
        Assert.Single(primerJuego.Categorias);
        Assert.Equal("Carreras", primerJuego.Categorias[0].Nombre);
    }

    [Fact]
    public async Task API09_ObtenerTodosAsync_SinJuegosEnBaseDeDatos_RetornaListaVacia()
    {
        // Arrange: Contexto vacío
        using var context = TestDbContextFactory.CreateContext();
        var service = new JuegoService(context);

        // Act: Obtener todos los juegos
        var resultado = await service.ObtenerTodosAsync();

        // Assert: Debe retornar una lista vacía, no nula ni causar excepción
        Assert.NotNull(resultado);
        Assert.Empty(resultado);
    }

    #endregion

    #region API 10: GET /api/juegos/{id}

    [Fact]
    public async Task API10_ObtenerPorIdAsync_IdExistente_RetornaDetalleJuegoDtoConCategorias()
    {
        // Arrange: Juego existente con ID 1
        using var context = TestDbContextFactory.CreateContext();
        var cat = new CategoriaJuego { IdCategoria = 10, Nombre = "Estrategia" };
        var juego = new Juego
        {
            IdJuego = 1,
            Nombre = "Ajedrez Maestro",
            Descripcion = "Juego de ajedrez táctico",
            Dificultad = "DIFICIL",
            MaxJugadores = 2,
            Imagen = "chess.png",
            RecompensaXpBase = 80,
            RecompensaMonedasBase = 150,
            RecompensaGemasBase = 10,
            IdCategoria = new List<CategoriaJuego> { cat }
        };

        context.CategoriaJuegos.Add(cat);
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act: Consultar juego con ID 1
        var resultado = await service.ObtenerPorIdAsync(1);

        // Assert: Valida que el detalle coincida
        Assert.NotNull(resultado);
        Assert.Equal((ulong)1, resultado.IdJuego);
        Assert.Equal("Ajedrez Maestro", resultado.Nombre);
        Assert.Equal("Juego de ajedrez táctico", resultado.Descripcion);
        Assert.Equal("DIFICIL", resultado.Dificultad);
        Assert.Equal((byte)2, resultado.MaxJugadores);
        Assert.Equal("chess.png", resultado.Imagen);
        Assert.Equal((ushort)80, resultado.RecompensaXpBase);
        Assert.Equal((uint)150, resultado.RecompensaMonedasBase);
        Assert.Equal((ushort)10, resultado.RecompensaGemasBase);
        Assert.Single(resultado.Categorias);
        Assert.Equal("Estrategia", resultado.Categorias[0].Nombre);
    }

    [Fact]
    public async Task API10_ObtenerPorIdAsync_IdInexistente_RetornaNull()
    {
        // Arrange: Base de datos con un juego de ID 1, pero consultaremos ID 999
        using var context = TestDbContextFactory.CreateContext();
        var juego = new Juego
        {
            IdJuego = 1,
            Nombre = "Space Invaders",
            Descripcion = "Arcade espacial",
            Dificultad = "FACIL",
            MaxJugadores = 1,
            Imagen = "space.png"
        };
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act: Consultar ID inexistente 999
        var resultado = await service.ObtenerPorIdAsync(999);

        // Assert: Debe retornar null (lo que en el endpoint producirá 404 NotFound)
        Assert.Null(resultado);
    }

    [Fact]
    public async Task API10_ObtenerPorIdAsync_MultiplesJuegos_RetornaUnicamenteElJuegoSolicitado()
    {
        // Arrange: Varios juegos en la base de datos
        using var context = TestDbContextFactory.CreateContext();
        var juego1 = new Juego { IdJuego = 1, Nombre = "Juego 1", Descripcion = "Desc 1", Dificultad = "FACIL", Imagen = "img1.png" };
        var juego2 = new Juego { IdJuego = 2, Nombre = "Juego 2", Descripcion = "Desc 2", Dificultad = "MEDIA", Imagen = "img2.png" };
        context.Juegos.AddRange(juego1, juego2);
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync(2);

        // Assert: Retorna exactamente el juego con ID 2
        Assert.NotNull(resultado);
        Assert.Equal((ulong)2, resultado.IdJuego);
        Assert.Equal("Juego 2", resultado.Nombre);
    }

    #endregion
}
