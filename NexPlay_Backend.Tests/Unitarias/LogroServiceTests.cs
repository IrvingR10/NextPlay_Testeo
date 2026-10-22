using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para LogroService.
/// Cubre el caso CP-1013 (logro inexistente) del plan de pruebas.
/// </summary>
public class LogroServiceTests
{
    // CP-1013 (parte Logro): Consultar logro con Id inexistente retorna null
    [Fact]
    [Trait("Caso", "CP-1013")]
    public async Task ObtenerPorIdAsync_IdInexistente_RetornaNull()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new LogroService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync((uint)99999);

        // Assert
        Assert.Null(resultado);
    }
}
