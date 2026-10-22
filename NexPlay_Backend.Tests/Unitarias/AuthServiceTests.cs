using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.DTOs.Auth;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para AuthService.
/// Cubre los casos CP-1001 a CP-1004 del plan de pruebas.
/// </summary>
public class AuthServiceTests
{
    // CP-1001: Login con credenciales correctas
    [Fact]
    [Trait("Caso", "CP-1001")]
    public async Task LoginAsync_CredencialesCorrectas_RetornaExitoConUsuario()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var passwordOriginal = "Password123!";
        var usuario = TestData.CrearUsuario(
            id: 1,
            correo: "usuario@nexplay.com",
            password: passwordOriginal,
            nombre: "Juan Pérez",
            apodo: "JuanP");
        context.Usuarios.Add(usuario);
        await context.SaveChangesAsync();

        var service = new AuthService(context);
        var loginDto = new LoginDto
        {
            Correo = "usuario@nexplay.com",
            Password = passwordOriginal
        };

        // Act
        var (exito, mensaje, usuarioDto) = await service.LoginAsync(loginDto);

        // Assert
        Assert.True(exito);
        Assert.Equal("Inicio de sesión correcto.", mensaje);
        Assert.NotNull(usuarioDto);
        Assert.Equal("Juan Pérez", usuarioDto.NombreCompleto);
        Assert.Equal("usuario@nexplay.com", usuarioDto.Correo);
        Assert.Equal("JuanP", usuarioDto.Apodo);
    }

    // CP-1002: Login con correo inexistente
    [Fact]
    [Trait("Caso", "CP-1002")]
    public async Task LoginAsync_CorreoInexistente_RetornaFalloConMensaje()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new AuthService(context);
        var loginDto = new LoginDto
        {
            Correo = "noexiste@nexplay.com",
            Password = "Password123!"
        };

        // Act
        var (exito, mensaje, usuarioDto) = await service.LoginAsync(loginDto);

        // Assert
        Assert.False(exito);
        Assert.Equal("Correo o contraseña incorrectos.", mensaje);
        Assert.Null(usuarioDto);
    }

    // CP-1003: Login con contraseña incorrecta
    [Fact]
    [Trait("Caso", "CP-1003")]
    public async Task LoginAsync_ContrasenaIncorrecta_RetornaFalloConMensaje()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var usuario = TestData.CrearUsuario(
            id: 1,
            correo: "usuario@nexplay.com",
            password: "Password123!");
        context.Usuarios.Add(usuario);
        await context.SaveChangesAsync();

        var service = new AuthService(context);
        var loginDto = new LoginDto
        {
            Correo = "usuario@nexplay.com",
            Password = "PasswordIncorrecta!"
        };

        // Act
        var (exito, mensaje, usuarioDto) = await service.LoginAsync(loginDto);

        // Assert
        Assert.False(exito);
        Assert.Equal("Correo o contraseña incorrectos.", mensaje);
        Assert.Null(usuarioDto);
    }

    // CP-1004: Normalizar correo en login (mayúsculas y espacios)
    [Fact]
    [Trait("Caso", "CP-1004")]
    public async Task LoginAsync_CorreoConMayusculasYEspacios_NormalizaYRetornaExito()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var passwordOriginal = "Password123!";
        var usuario = TestData.CrearUsuario(
            id: 1,
            correo: "usuario@nexplay.com",
            password: passwordOriginal);
        context.Usuarios.Add(usuario);
        await context.SaveChangesAsync();

        var service = new AuthService(context);
        var loginDto = new LoginDto
        {
            Correo = "  USUARIO@NexPlay.COM  ",
            Password = passwordOriginal
        };

        // Act
        var (exito, mensaje, usuarioDto) = await service.LoginAsync(loginDto);

        // Assert
        Assert.True(exito);
        Assert.Equal("Inicio de sesión correcto.", mensaje);
        Assert.NotNull(usuarioDto);
    }
}
