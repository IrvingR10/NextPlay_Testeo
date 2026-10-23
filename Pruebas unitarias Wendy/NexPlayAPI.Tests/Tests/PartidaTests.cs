using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Mappings;
using NexPlayAPI.Models;
using NexPlayAPI.Services;
using NexPlayAPI.Tests.Common;

namespace NexPlayAPI.Tests.Tests;

/// <summary>
/// Pruebas unitarias correspondientes a las asignaciones de Wendy:
/// - API 13: POST /api/partidas (Registrar partida)
/// - API 14: GET /api/partidas/{id} (Obtener partida por ID)
/// - API 15: GET /api/partidas/usuario/{idUsuario} (Obtener partidas por usuario)
/// - API 16: GET /api/partidas/usuario/{idUsuario}/estadisticas (Obtener estadísticas por usuario)
/// - API 17: GET /api/partidas/usuario/{idUsuario}/mejor-puntaje (Obtener mejor puntaje por juego para usuario)
/// </summary>
public class PartidaTests
{
    #region Helper de inicialización de dependencias base

    private static async Task<(Usuario usuario, Juego juego)> InicializarUsuarioYJuegoAsync(TestNexPlayContext context, ulong idUsuario = 20, ulong idJuego = 1)
    {
        var avatar = new Avatar { IdAvatar = 1, Nombre = "Guerrero", Imagen = "avatar1.png" };
        var usuario = new Usuario
        {
            IdUsuario = idUsuario,
            NombreCompleto = "Wendy Tester",
            Apodo = "WendyGamer",
            Correo = "wendy@test.com",
            PasswordHash = "hashedPassword",
            IdAvatar = 1
        };
        var juego = new Juego
        {
            IdJuego = idJuego,
            Nombre = "Pixel Racer",
            Descripcion = "Juego de carreras",
            Dificultad = "FACIL",
            Imagen = "pixel.png"
        };

        context.Avatars.Add(avatar);
        context.Usuarios.Add(usuario);
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        return (usuario, juego);
    }

    #endregion

    #region API 13: POST /api/partidas

    [Fact]
    public async Task API13_CrearPartidaAsync_DatosValidos_CreaYPersistePartidaExitosamente()
    {
        // Arrange: Preparar usuario y juego existentes
        using var context = TestDbContextFactory.CreateContext();
        await InicializarUsuarioYJuegoAsync(context, idUsuario: 20, idJuego: 1);

        var service = new PartidaService(context);
        var fechaPrueba = new DateTime(2026, 10, 21, 10, 0, 0, DateTimeKind.Utc);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 2500,
            Resultado = " VICTORIA ",
            DuracionSegundos = 180,
            FechaHora = fechaPrueba
        };

        // Act: Registrar la partida
        var partidaCreada = await service.CrearPartidaAsync(dto);

        // Assert: Validar datos persistidos y asignación de ID
        Assert.NotNull(partidaCreada);
        Assert.True(partidaCreada.IdPartida > 0);
        Assert.Equal((ulong)20, partidaCreada.IdUsuario);
        Assert.Equal((ulong)1, partidaCreada.IdJuego);
        Assert.Equal((uint)2500, partidaCreada.Puntaje);
        Assert.Equal("VICTORIA", partidaCreada.Resultado); // Verifica limpieza de espacios con Trim()
        Assert.Equal((uint)180, partidaCreada.DuracionSegundos);
        Assert.Equal(fechaPrueba, partidaCreada.FechaHora);

        // Verificar que realmente se guardó en la base de datos
        var guardadaEnDb = await context.Partida.FindAsync(partidaCreada.IdPartida);
        Assert.NotNull(guardadaEnDb);
        Assert.Equal((uint)2500, guardadaEnDb.Puntaje);
    }

    [Fact]
    public async Task API13_CrearPartidaAsync_FechaHoraNula_AsignaFechaUtcPorDefecto()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        await InicializarUsuarioYJuegoAsync(context, idUsuario: 20, idJuego: 1);

        var service = new PartidaService(context);
        var antesDeLlamar = DateTime.UtcNow.AddSeconds(-1);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 800,
            Resultado = "DERROTA",
            DuracionSegundos = 45,
            FechaHora = null // Fecha nula
        };

        // Act
        var partida = await service.CrearPartidaAsync(dto);

        // Assert: FechaHora debe haberse asignado automáticamente con fecha actual cercana
        Assert.True(partida.FechaHora >= antesDeLlamar);
        Assert.True(partida.FechaHora <= DateTime.UtcNow.AddSeconds(5));
    }

    [Fact]
    public async Task API13_CrearPartidaAsync_UsuarioInexistente_LanzaKeyNotFoundException()
    {
        // Arrange: Juego existe pero usuario 999 no existe
        using var context = TestDbContextFactory.CreateContext();
        var juego = new Juego { IdJuego = 1, Nombre = "Juego 1", Descripcion = "D", Dificultad = "FACIL", Imagen = "i.png" };
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 999, // Inexistente
            IdJuego = 1,
            Puntaje = 500,
            Resultado = "VICTORIA"
        };

        // Act & Assert: Debe lanzar KeyNotFoundException indicando el ID de usuario faltante
        var ex = await Assert.ThrowsAsync<KeyNotFoundException>(() => service.CrearPartidaAsync(dto));
        Assert.Contains("No existe el usuario con id 999", ex.Message);
    }

    [Fact]
    public async Task API13_CrearPartidaAsync_JuegoInexistente_LanzaKeyNotFoundException()
    {
        // Arrange: Usuario existe pero juego 888 no existe
        using var context = TestDbContextFactory.CreateContext();
        var usuario = new Usuario
        {
            IdUsuario = 20,
            NombreCompleto = "Wendy Tester",
            Apodo = "Wendy",
            Correo = "w@test.com",
            PasswordHash = "hash",
            IdAvatar = 1
        };
        context.Usuarios.Add(usuario);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 20,
            IdJuego = 888, // Inexistente
            Puntaje = 500,
            Resultado = "VICTORIA"
        };

        // Act & Assert: Debe lanzar KeyNotFoundException indicando el ID de juego faltante
        var ex = await Assert.ThrowsAsync<KeyNotFoundException>(() => service.CrearPartidaAsync(dto));
        Assert.Contains("No existe el juego con id 888", ex.Message);
    }

    [Fact]
    public async Task API13_CrearPartidaAsync_DtoNulo_LanzaArgumentNullException()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() => service.CrearPartidaAsync(null!));
    }

    #endregion

    #region API 14: GET /api/partidas/{id}

    [Fact]
    public async Task API14_ObtenerPorIdAsync_PartidaExistente_RetornaPartidaConTodosSusDatos()
    {
        // Arrange: Partida creada con ID 1
        using var context = TestDbContextFactory.CreateContext();
        var fecha = new DateTime(2026, 10, 20, 15, 30, 0, DateTimeKind.Utc);
        var partida = new Partidum
        {
            IdPartida = 1,
            IdUsuario = 20,
            IdJuego = 5,
            Puntaje = 1250,
            Resultado = "VICTORIA",
            DuracionSegundos = 240,
            FechaHora = fecha
        };

        context.Partida.Add(partida);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act: Obtener partida con ID 1
        var resultado = await service.ObtenerPorIdAsync(1);

        // Assert: Validar datos
        Assert.NotNull(resultado);
        Assert.Equal((ulong)1, resultado.IdPartida);
        Assert.Equal((ulong)20, resultado.IdUsuario);
        Assert.Equal((ulong)5, resultado.IdJuego);
        Assert.Equal((uint)1250, resultado.Puntaje);
        Assert.Equal("VICTORIA", resultado.Resultado);
        Assert.Equal((uint)240, resultado.DuracionSegundos);
        Assert.Equal(fecha, resultado.FechaHora);

        // Verificar mapeo a DTO ToDto()
        var dto = resultado.ToDto();
        Assert.Equal((ulong)1, dto.IdPartida);
        Assert.Equal((ulong)20, dto.IdUsuario);
        Assert.Equal((uint)1250, dto.Puntaje);
    }

    [Fact]
    public async Task API14_ObtenerPorIdAsync_PartidaInexistente_RetornaNull()
    {
        // Arrange: Base de datos vacía
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync(999);

        // Assert: Retorna null para que el Endpoint produzca 404 Not Found
        Assert.Null(resultado);
    }

    #endregion

    #region API 15: GET /api/partidas/usuario/{idUsuario}

    [Fact]
    public async Task API15_ObtenerPorUsuarioAsync_UsuarioConPartidas_RetornaPartidasOrdenadasPorFechaDescendente()
    {
        // Arrange: Crear 3 partidas para el usuario 20 con fechas cronológicas distintas y 1 partida para otro usuario
        using var context = TestDbContextFactory.CreateContext();
        var p1 = new Partidum
        {
            IdPartida = 101,
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 500,
            Resultado = "VICTORIA",
            DuracionSegundos = 60,
            FechaHora = new DateTime(2026, 10, 1, 10, 0, 0, DateTimeKind.Utc)
        };
        var p2 = new Partidum
        {
            IdPartida = 102,
            IdUsuario = 20,
            IdJuego = 2,
            Puntaje = 950,
            Resultado = "VICTORIA",
            DuracionSegundos = 120,
            FechaHora = new DateTime(2026, 10, 15, 12, 0, 0, DateTimeKind.Utc) // Más reciente
        };
        var p3 = new Partidum
        {
            IdPartida = 103,
            IdUsuario = 20,
            IdJuego = 1,
            Puntaje = 700,
            Resultado = "DERROTA",
            DuracionSegundos = 90,
            FechaHora = new DateTime(2026, 10, 10, 14, 0, 0, DateTimeKind.Utc)
        };
        var pOtroUsuario = new Partidum
        {
            IdPartida = 104,
            IdUsuario = 99, // Otro usuario
            IdJuego = 1,
            Puntaje = 2000,
            Resultado = "VICTORIA",
            DuracionSegundos = 150,
            FechaHora = new DateTime(2026, 10, 20, 10, 0, 0, DateTimeKind.Utc)
        };

        context.Partida.AddRange(p1, p2, p3, pOtroUsuario);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act: Consultar historial de partidas del usuario 20
        var resultado = await service.ObtenerPorUsuarioAsync(20);

        // Assert: Retorna exactamente 3 partidas, ordenadas descendente (102, 103, 101)
        Assert.NotNull(resultado);
        Assert.Equal(3, resultado.Count);

        Assert.Equal((ulong)102, resultado[0].IdPartida); // 15 de oct
        Assert.Equal((ulong)103, resultado[1].IdPartida); // 10 de oct
        Assert.Equal((ulong)101, resultado[2].IdPartida); // 1 de oct

        // Validar que no incluye la partida del usuario 99
        Assert.DoesNotContain(resultado, p => p.IdUsuario != 20);
    }

    [Fact]
    public async Task API15_ObtenerPorUsuarioAsync_UsuarioSinPartidas_RetornaListaVacia()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act: Usuario 20 sin ninguna partida registrada
        var resultado = await service.ObtenerPorUsuarioAsync(20);

        // Assert: Retorna lista vacía no nula
        Assert.NotNull(resultado);
        Assert.Empty(resultado);
    }

    #endregion

    #region API 16: GET /api/partidas/usuario/{idUsuario}/estadisticas

    [Fact]
    public async Task API16_ObtenerEstadisticasUsuarioAsync_UsuarioConEstadisticas_RetornaVwEstadisticasUsuario()
    {
        // Arrange: Datos simulados de la vista para el usuario 20
        using var context = TestDbContextFactory.CreateContext();
        var stats = new VwEstadisticasUsuario
        {
            IdUsuario = 20,
            Apodo = "WendyPro",
            XpTotal = 15400,
            Monedas = 3500,
            Gemas = 85,
            PartidasJugadas = 42,
            Victorias = 35,
            MejorPuntaje = 9800,
            TiempoJugadoSegundos = 7200
        };

        context.VwEstadisticasUsuarios.Add(stats);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act: Obtener estadísticas del usuario 20
        var resultado = await service.ObtenerEstadisticasUsuarioAsync(20);

        // Assert: Valida campos completos
        Assert.NotNull(resultado);
        Assert.Equal((ulong)20, resultado.IdUsuario);
        Assert.Equal("WendyPro", resultado.Apodo);
        Assert.Equal((uint)15400, resultado.XpTotal);
        Assert.Equal((uint)3500, resultado.Monedas);
        Assert.Equal((uint)85, resultado.Gemas);
        Assert.Equal(42, resultado.PartidasJugadas);
        Assert.Equal(35m, resultado.Victorias);
        Assert.Equal(9800, resultado.MejorPuntaje);
        Assert.Equal(7200m, resultado.TiempoJugadoSegundos);

        // Validar mapeo a DTO ToDto()
        var dto = resultado.ToDto();
        Assert.Equal((ulong)20, dto.IdUsuario);
        Assert.Equal("WendyPro", dto.Apodo);
        Assert.Equal((uint)15400, dto.XpTotal);
        Assert.Equal(42, dto.PartidasJugadas);
        Assert.Equal(35m, dto.Victorias);
    }

    [Fact]
    public async Task API16_ObtenerEstadisticasUsuarioAsync_UsuarioSinEstadisticas_RetornaNull()
    {
        // Arrange: Base de datos sin registro para usuario 20
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act
        var resultado = await service.ObtenerEstadisticasUsuarioAsync(20);

        // Assert: Retorna null (lo cual en el endpoint produce 404 NotFound)
        Assert.Null(resultado);
    }

    #endregion

    #region API 17: GET /api/partidas/usuario/{idUsuario}/mejor-puntaje

    [Fact]
    public async Task API17_ObtenerMejorPuntajePorJuegoAsync_UsuarioConPuntajes_RetornaListaOrdenadaPorIdJuego()
    {
        // Arrange: Crear mejores puntajes para usuario 20 en 3 juegos distintos y registros de otro usuario
        using var context = TestDbContextFactory.CreateContext();
        var scoreJuego3 = new VwMejorPuntajeUsuarioJuego { IdUsuario = 20, IdJuego = 3, MejorPuntaje = 4500 };
        var scoreJuego1 = new VwMejorPuntajeUsuarioJuego { IdUsuario = 20, IdJuego = 1, MejorPuntaje = 9800 };
        var scoreJuego2 = new VwMejorPuntajeUsuarioJuego { IdUsuario = 20, IdJuego = 2, MejorPuntaje = 6200 };
        var scoreOtroUser = new VwMejorPuntajeUsuarioJuego { IdUsuario = 50, IdJuego = 1, MejorPuntaje = 10000 };

        context.VwMejorPuntajeUsuarioJuegos.AddRange(scoreJuego3, scoreJuego1, scoreJuego2, scoreOtroUser);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);

        // Act: Obtener mejores puntajes para el usuario 20
        var resultado = await service.ObtenerMejorPuntajePorJuegoAsync(20);

        // Assert: Retorna 3 elementos ordenados por IdJuego (1, 2, 3)
        Assert.NotNull(resultado);
        Assert.Equal(3, resultado.Count);

        Assert.Equal((ulong)1, resultado[0].IdJuego);
        Assert.Equal((uint?)9800, resultado[0].MejorPuntaje);

        Assert.Equal((ulong)2, resultado[1].IdJuego);
        Assert.Equal((uint?)6200, resultado[1].MejorPuntaje);

        Assert.Equal((ulong)3, resultado[2].IdJuego);
        Assert.Equal((uint?)4500, resultado[2].MejorPuntaje);

        // Validar que no contiene registros del usuario 50
        Assert.DoesNotContain(resultado, s => s.IdUsuario != 20);
    }

    [Fact]
    public async Task API17_ObtenerMejorPuntajePorJuegoAsync_UsuarioSinPuntajes_RetornaListaVacia()
    {
        // Arrange
        using var context = TestDbContextFactory.CreateContext();
        var service = new PartidaService(context);

        // Act
        var resultado = await service.ObtenerMejorPuntajePorJuegoAsync(20);

        // Assert: Retorna lista vacía no nula
        Assert.NotNull(resultado);
        Assert.Empty(resultado);
    }

    #endregion
}
