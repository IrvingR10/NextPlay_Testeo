using Microsoft.EntityFrameworkCore;
using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.DTOs.Partida;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para PartidaService.
/// Cubre los casos CP-1011 y CP-1012 del plan de pruebas.
/// </summary>
public class PartidaServiceTests
{
    // CP-1011: Crear partida válida con usuario y juego existentes
    [Fact]
    [Trait("Caso", "CP-1011")]
    public async Task CrearPartidaAsync_DatosValidos_GuardaPartidaConAsociacionesCorrectas()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        await TestData.SembrarReferenciasBasicasAsync(context);

        var service = new PartidaService(context);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 1,
            IdJuego = 1,
            Puntaje = 1500,
            Resultado = "VICTORIA",
            DuracionSegundos = 300
        };

        // Act
        var partida = await service.CrearPartidaAsync(dto);

        // Assert
        Assert.NotNull(partida);
        Assert.Equal((ulong)1, partida.IdUsuario);
        Assert.Equal((ulong)1, partida.IdJuego);
        Assert.Equal((uint)1500, partida.Puntaje);
        Assert.Equal("VICTORIA", partida.Resultado);

        // Verificar que la partida se persistió en la base
        var partidaDb = await context.Partida
            .FirstOrDefaultAsync(p => p.IdPartida == partida.IdPartida);
        Assert.NotNull(partidaDb);
        Assert.Equal((ulong)1, partidaDb.IdUsuario);
        Assert.Equal((ulong)1, partidaDb.IdJuego);
    }

    // CP-1012: Partida con usuario inexistente
    [Fact]
    [Trait("Caso", "CP-1012")]
    public async Task CrearPartidaAsync_UsuarioInexistente_LanzaKeyNotFoundException()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        // Solo creamos un juego, sin usuario
        var juego = TestData.CrearJuego(id: 1);
        context.Juegos.Add(juego);
        await context.SaveChangesAsync();

        var service = new PartidaService(context);
        var dto = new CrearPartidaDto
        {
            IdUsuario = 99999, // Usuario inexistente
            IdJuego = 1,
            Puntaje = 100,
            Resultado = "VICTORIA",
            DuracionSegundos = 60
        };

        // Act & Assert
        await Assert.ThrowsAsync<KeyNotFoundException>(
            () => service.CrearPartidaAsync(dto));

        // Verificar que no se guardó ninguna partida
        var conteoPartidas = await context.Partida.CountAsync();
        Assert.Equal(0, conteoPartidas);
    }
}
