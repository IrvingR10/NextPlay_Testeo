using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para JuegoService.
/// Cubre el caso CP-1013 (juego inexistente) del plan de pruebas.
/// </summary>
public class JuegoServiceTests
{
    // CP-1013 (parte Juego): Consultar juego con Id inexistente retorna null
    [Fact]
    [Trait("Caso", "CP-1013")]
    public async Task ObtenerPorIdAsync_IdInexistente_RetornaNull()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new JuegoService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync((ulong)99999);

        // Assert
        Assert.Null(resultado);
    }
}
