using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para AvatarService.
/// Cubre el caso CP-1013 (avatar inexistente) del plan de pruebas.
/// </summary>
public class AvatarServiceTests
{
    // CP-1013 (parte Avatar): Consultar avatar con Id inexistente retorna null
    [Fact]
    [Trait("Caso", "CP-1013")]
    public async Task ObtenerPorIdAsync_IdInexistente_RetornaNull()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new AvatarService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync((ushort)99);

        // Assert
        Assert.Null(resultado);
    }
}
