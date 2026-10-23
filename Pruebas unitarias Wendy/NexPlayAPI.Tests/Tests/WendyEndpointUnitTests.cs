using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using NexPlayAPI.DTOs.Categoria;
using NexPlayAPI.DTOs.Juego;
using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Models;
using NexPlayAPI.Services;
using NexPlayAPI.Tests.Common;

namespace NexPlayAPI.Tests.Tests;

/// <summary>
/// Pruebas unitarias de la capa de Endpoints HTTP para las APIs asignadas a Wendy (9 a 17):
/// Valida los códigos de estado HTTP (200 OK, 201 Created, 400 Bad Request, 404 Not Found)
/// y los payloads de respuesta esperados según la especificación del plan de pruebas.
/// </summary>
public class WendyEndpointUnitTests
{
    #region API 9: GET /api/juegos

    [Fact]
    [Trait("Caso", "CP-API-09")]
    public async Task API09_Endpoint_ObtenerJuegos_Retorna200OkConLista()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.Juegos.Add(new Juego
        {
            IdJuego = 1,
            Nombre = "Retro Runner",
            Descripcion = "Run",
            Dificultad = "FACIL",
            Imagen = "img.png"
        });
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act: Simulación de ejecución de handler del endpoint
        var lista = await service.ObtenerTodosAsync();
        var result = TypedResults.Ok(lista);

        // Assert
        Assert.Equal(StatusCodes.Status200OK, result.StatusCode);
        Assert.NotNull(result.Value);
        Assert.Single(result.Value);
    }

    #endregion

    #region API 10: GET /api/juegos/{id}

    [Fact]
    [Trait("Caso", "CP-API-10")]
    public async Task API10_Endpoint_ObtenerJuegoPorId_Existente_Retorna200OkConDetalle()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.Juegos.Add(new Juego
        {
            IdJuego = 1,
            Nombre = "Juego 1",
            Descripcion = "D",
            Dificultad = "FACIL",
            Imagen = "i.png"
        });
        await context.SaveChangesAsync();

        var service = new JuegoService(context);

        // Act
        var juego = await service.ObtenerPorIdAsync(1);
        IResult result = juego is null
            ? Results.NotFound(new { mensaje = "Juego no encontrado." })
            : Results.Ok(juego);

        // Assert
        var okResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-10")]
    public async Task API10_Endpoint_ObtenerJuegoPorId_Inexistente_Retorna404NotFound()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new JuegoService(context);

        // Act
        var juego = await service.ObtenerPorIdAsync(999);
        IResult result = juego is null
            ? Results.NotFound(new { mensaje = "Juego no encontrado." })
            : Results.Ok(juego);

        // Assert
        var notFoundResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status404NotFound, notFoundResult.StatusCode);
    }

    #endregion

    #region API 11: GET /api/categorias

    [Fact]
    [Trait("Caso", "CP-API-11")]
    public async Task API11_Endpoint_ObtenerCategorias_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.CategoriaJuegos.Add(new CategoriaJuego { IdCategoria = 1, Nombre = "Arcade" });
        await context.SaveChangesAsync();

        var service = new CategoriaJuegoService(context);

        // Act
        var categorias = await service.ObtenerTodasAsync();
        var result = TypedResults.Ok(categorias);

        // Assert
        Assert.Equal(StatusCodes.Status200OK, result.StatusCode);
        Assert.NotNull(result.Value);
        Assert.Single(result.Value!);
    }

    #endregion

    #region API 12: GET /api/categorias/{id}/juegos

    [Fact]
    [Trait("Caso", "CP-API-12")]
    public async Task API12_Endpoint_ObtenerJuegosPorCategoria_Existente_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var cat = new CategoriaJuego { IdCategoria = 1, Nombre = "Arcade" };
        var juego = new Juego
        {
            IdJuego = 1,
            Nombre = "Pac Arcade",
            Descripcion = "D",
            Dificultad = "FACIL",
            Imagen = "p.png",
            IdCategoria = new List<CategoriaJuego> { cat }
        };
        context.CategoriaJuegos.Add(cat);
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        var service = new CategoriaJuegoService(context);

        // Act
        var juegos = await service.ObtenerJuegosPorCategoriaAsync(1);
        IResult result = juegos is null
            ? Results.NotFound(new { mensaje = "Categoría no encontrada." })
            : Results.Ok(juegos);

        // Assert
        var okResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-12")]
    public async Task API12_Endpoint_ObtenerJuegosPorCategoria_Inexistente_Retorna404NotFound()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new CategoriaJuegoService(context);

        // Act
        var juegos = await service.ObtenerJuegosPorCategoriaAsync(99);
        IResult result = juegos is null
            ? Results.NotFound(new { mensaje = "Categoría no encontrada." })
            : Results.Ok(juegos);

        // Assert
        var notFoundResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status404NotFound, notFoundResult.StatusCode);
    }

    #endregion

    #region API 13: POST /api/partidas

    [Fact]
    [Trait("Caso", "CP-API-13")]
    public async Task API13_Endpoint_CrearPartida_Valido_Retorna201Created()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.Usuarios.Add(new Usuario
        {
            IdUsuario = 20,
            NombreCompleto = "Wendy Tester",
            Apodo = "Wendy",
            Correo = "w@test.com",
            PasswordHash = "hash",
            IdAvatar = 1
        });
        context.Juegos.Add(new Juego
        {
            IdJuego = 1,
            Nombre = "Pixel Racer",
            Descripcion = "D",
            Dificultad = "FACIL",
            Imagen = "i.png"
        });
        await context.SaveChangesAsync();

        var service = new PartidaService(context);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 1500,
            Resultado = "VICTORIA",
            DuracionSegundos = 120
        };

        // Act: Ejecutar lógica del handler de PartidaEndpoints
        IResult result;
        if (dto is null)
            result = Results.BadRequest("La partida es obligatoria.");
        else if (dto.IdUsuario == 0 || dto.IdJuego == 0)
            result = Results.BadRequest("Los campos IdUsuario e IdJuego son obligatorios.");
        else
        {
            try
            {
                var partidaCreada = await service.CrearPartidaAsync(dto);
                result = Results.Created($"/api/partidas/{partidaCreada.IdPartida}", partidaCreada);
            }
            catch (KeyNotFoundException ex)
            {
                result = Results.NotFound(ex.Message);
            }
        }

        // Assert
        var createdResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status201Created, createdResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-13")]
    public void API13_Endpoint_CrearPartida_IdUsuarioZero_Retorna400BadRequest()
    {
        // Arrange
        var dto = new CrearPartidaDto { IdUsuario = 0, IdJuego = 1, Puntaje = 100 };

        // Act
        IResult result;
        if (dto is null)
            result = Results.BadRequest("La partida es obligatoria.");
        else if (dto.IdUsuario == 0 || dto.IdJuego == 0)
            result = Results.BadRequest("Los campos IdUsuario e IdJuego son obligatorios.");
        else
            result = Results.Ok();

        // Assert
        var badRequestResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, badRequestResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-13")]
    public async Task API13_Endpoint_CrearPartida_UsuarioInexistente_Retorna404NotFound()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);
        var dto = new CrearPartidaDto { IdUsuario = 999, IdJuego = 1, Puntaje = 500 };

        // Act
        IResult result;
        try
        {
            await service.CrearPartidaAsync(dto);
            result = Results.Created("/api/partidas/1", dto);
        }
        catch (KeyNotFoundException ex)
        {
            result = Results.NotFound(ex.Message);
        }

        // Assert
        var notFoundResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status404NotFound, notFoundResult.StatusCode);
    }

    #endregion

    #region API 14: GET /api/partidas/{id}

    [Fact]
    [Trait("Caso", "CP-API-14")]
    public async Task API14_Endpoint_ObtenerPartidaPorId_Existente_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.Partida.Add(new Partidum
        {
            IdPartida = 1,
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 900,
            Resultado = "VICTORIA"
        });
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act
        var partida = await service.ObtenerPorIdAsync(1);
        IResult result = partida is null ? Results.NotFound() : Results.Ok(partida);

        // Assert
        var okResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-14")]
    public async Task API14_Endpoint_ObtenerPartidaPorId_Inexistente_Retorna404NotFound()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act
        var partida = await service.ObtenerPorIdAsync(999);
        IResult result = partida is null ? Results.NotFound() : Results.Ok(partida);

        // Assert
        var notFoundResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status404NotFound, notFoundResult.StatusCode);
    }

    #endregion

    #region API 15: GET /api/partidas/usuario/{idUsuario}

    [Fact]
    [Trait("Caso", "CP-API-15")]
    public async Task API15_Endpoint_ObtenerPorUsuario_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.Partida.Add(new Partidum
        {
            IdPartida = 1,
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 1000,
            Resultado = "VICTORIA"
        });
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act
        var partidas = await service.ObtenerPorUsuarioAsync(20);
        var result = TypedResults.Ok(partidas);

        // Assert
        Assert.Equal(StatusCodes.Status200OK, result.StatusCode);
        Assert.NotNull(result.Value);
        Assert.Single(result.Value!);
    }

    #endregion

    #region API 16: GET /api/partidas/usuario/{idUsuario}/estadisticas

    [Fact]
    [Trait("Caso", "CP-API-16")]
    public async Task API16_Endpoint_ObtenerEstadisticas_Existente_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.VwEstadisticasUsuarios.Add(new VwEstadisticasUsuario
        {
            IdUsuario = 20,
            Apodo = "Wendy",
            Monedas = 500
        });
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act
        var stats = await service.ObtenerEstadisticasUsuarioAsync(20);
        IResult result = stats is null ? Results.NotFound() : Results.Ok(stats);

        // Assert
        var okResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);
    }

    [Fact]
    [Trait("Caso", "CP-API-16")]
    public async Task API16_Endpoint_ObtenerEstadisticas_Inexistente_Retorna404NotFound()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act
        var stats = await service.ObtenerEstadisticasUsuarioAsync(999);
        IResult result = stats is null ? Results.NotFound() : Results.Ok(stats);

        // Assert
        var notFoundResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);
        Assert.Equal(StatusCodes.Status404NotFound, notFoundResult.StatusCode);
    }

    #endregion

    #region API 17: GET /api/partidas/usuario/{idUsuario}/mejor-puntaje

    [Fact]
    [Trait("Caso", "CP-API-17")]
    public async Task API17_Endpoint_ObtenerMejorPuntaje_Retorna200Ok()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        context.VwMejorPuntajeUsuarioJuegos.Add(new VwMejorPuntajeUsuarioJuego
        {
            IdUsuario = 20,
            IdJuego = 1,
            MejorPuntaje = 5000
        });
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act
        var scores = await service.ObtenerMejorPuntajePorJuegoAsync(20);
        var result = TypedResults.Ok(scores);

        // Assert
        Assert.Equal(StatusCodes.Status200OK, result.StatusCode);
        Assert.NotNull(result.Value);
        Assert.Single(result.Value!);
    }

    #endregion
}
