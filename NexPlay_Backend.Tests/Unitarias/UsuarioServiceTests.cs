using System.Text.Json;
using NexPlay_Backend.Tests.Helpers;
using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.Services;

namespace NexPlay_Backend.Tests.Unitarias;

/// <summary>
/// Pruebas unitarias para UsuarioService.
/// Cubre los casos CP-1005 a CP-1010 del plan de pruebas.
/// </summary>
public class UsuarioServiceTests
{
    // CP-1005: Crear usuario válido
    [Fact]
    [Trait("Caso", "CP-1005")]
    public async Task CrearAsync_DatosValidos_CreaUsuarioConCorreoNormalizadoYHashVerificable()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new UsuarioService(context);
        var passwordOriginal = "MiPassword123!";
        var dto = new CrearUsuarioDto
        {
            NombreCompleto = "  María García  ",
            Correo = " Maria@NexPlay.COM ",
            Password = passwordOriginal,
            Apodo = "MariaG"
        };

        // Act
        var (exito, mensaje, usuarioDto) = await service.CrearAsync(dto);

        // Assert
        Assert.True(exito);
        Assert.Equal("Usuario creado correctamente.", mensaje);
        Assert.NotNull(usuarioDto);

        // Verificar que el correo se normalizó a minúsculas y sin espacios
        Assert.Equal("maria@nexplay.com", usuarioDto.Correo);

        // Verificar que el nombre se recortó (trim)
        Assert.Equal("María García", usuarioDto.NombreCompleto);

        // Verificar que el PasswordHash es distinto de la contraseña y verificable con BCrypt
        var usuarioDb = await context.Usuarios.FindAsync(usuarioDto.IdUsuario);
        Assert.NotNull(usuarioDb);
        Assert.NotEqual(passwordOriginal, usuarioDb.PasswordHash);
        Assert.True(BCrypt.Net.BCrypt.Verify(passwordOriginal, usuarioDb.PasswordHash));
    }

    // CP-1006: Correo duplicado con variaciones de mayúsculas y espacios
    [Theory]
    [Trait("Caso", "CP-1006")]
    [InlineData("usuario@nexplay.com")]
    [InlineData("USUARIO@NEXPLAY.COM")]
    [InlineData("  Usuario@NexPlay.com  ")]
    [InlineData(" USUARIO@nexplay.COM")]
    public async Task CrearAsync_CorreoDuplicadoConVariaciones_RetornaFalloSinCrearUsuario(string correoVariante)
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var usuarioExistente = TestData.CrearUsuario(
            id: 1,
            correo: "usuario@nexplay.com",
            apodo: "Existente");
        context.Usuarios.Add(usuarioExistente);
        await context.SaveChangesAsync();

        var service = new UsuarioService(context);
        var dto = new CrearUsuarioDto
        {
            NombreCompleto = "Nuevo Usuario",
            Correo = correoVariante,
            Password = "NuevoPassword123!",
            Apodo = "NuevoApodo"
        };

        var conteoAntes = context.Usuarios.Count();

        // Act
        var (exito, mensaje, usuarioDto) = await service.CrearAsync(dto);

        // Assert
        Assert.False(exito);
        Assert.Equal("El correo ya está registrado.", mensaje);
        Assert.Null(usuarioDto);

        // Verificar que no se creó un usuario adicional
        var conteoDespues = context.Usuarios.Count();
        Assert.Equal(conteoAntes, conteoDespues);
    }

    // CP-1007: Apodo duplicado (case-insensitive)
    [Fact]
    [Trait("Caso", "CP-1007")]
    public async Task CrearAsync_ApodoDuplicadoCaseInsensitive_RetornaFalloSinCrearUsuario()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var usuarioExistente = TestData.CrearUsuario(
            id: 1,
            correo: "existente@nexplay.com",
            apodo: "PlayerOne");
        context.Usuarios.Add(usuarioExistente);
        await context.SaveChangesAsync();

        var service = new UsuarioService(context);
        var dto = new CrearUsuarioDto
        {
            NombreCompleto = "Nuevo Usuario",
            Correo = "nuevo@nexplay.com",
            Password = "Password123!",
            Apodo = "playerone" // misma apodo en minúsculas
        };

        var conteoAntes = context.Usuarios.Count();

        // Act
        var (exito, mensaje, usuarioDto) = await service.CrearAsync(dto);

        // Assert
        Assert.False(exito);
        Assert.Equal("El apodo ya está en uso.", mensaje);
        Assert.Null(usuarioDto);

        // Verificar que no se creó el usuario
        var conteoDespues = context.Usuarios.Count();
        Assert.Equal(conteoAntes, conteoDespues);
    }

    // CP-1008: Consultar usuario existente y verificar que no se expone el hash
    [Fact]
    [Trait("Caso", "CP-1008")]
    public async Task ObtenerPorIdAsync_UsuarioExistente_RetornaDtoSinExponerPasswordHash()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var passwordOriginal = "Password123!";
        var usuario = TestData.CrearUsuario(
            id: 1,
            nombre: "Juan Pérez",
            correo: "juan@nexplay.com",
            password: passwordOriginal,
            apodo: "JuanP");
        context.Usuarios.Add(usuario);
        await context.SaveChangesAsync();

        var service = new UsuarioService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync(1);

        // Assert
        Assert.NotNull(resultado);
        Assert.Equal((ulong)1, resultado.IdUsuario);
        Assert.Equal("Juan Pérez", resultado.NombreCompleto);
        Assert.Equal("juan@nexplay.com", resultado.Correo);
        Assert.Equal("JuanP", resultado.Apodo);

        // Verificar que la serialización JSON del DTO no contiene PasswordHash ni el valor del hash
        var json = JsonSerializer.Serialize(resultado);
        Assert.DoesNotContain("PasswordHash", json, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain(usuario.PasswordHash, json);
    }

    // CP-1009: Consultar usuario inexistente
    [Fact]
    [Trait("Caso", "CP-1009")]
    public async Task ObtenerPorIdAsync_IdInexistente_RetornaNull()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new UsuarioService(context);

        // Act
        var resultado = await service.ObtenerPorIdAsync(99999);

        // Assert
        Assert.Null(resultado);
    }

    // CP-1010: Actualizar usuario inexistente
    [Fact]
    [Trait("Caso", "CP-1010")]
    public async Task ActualizarAsync_IdInexistente_RetornaFalloSinModificarRegistros()
    {
        // Arrange
        using var context = TestData.CrearContexto();
        var service = new UsuarioService(context);
        var dto = new ActualizarUsuarioDto
        {
            NombreCompleto = "Nombre Actualizado",
            Apodo = "NuevoApodo"
        };

        var conteoAntes = context.Usuarios.Count();

        // Act
        var (exito, mensaje, usuarioDto) = await service.ActualizarAsync(99999, dto);

        // Assert
        Assert.False(exito);
        Assert.Equal("Usuario no encontrado.", mensaje);
        Assert.Null(usuarioDto);

        // Verificar que no se creó ni modificó ningún registro
        var conteoDespues = context.Usuarios.Count();
        Assert.Equal(conteoAntes, conteoDespues);
    }
}
