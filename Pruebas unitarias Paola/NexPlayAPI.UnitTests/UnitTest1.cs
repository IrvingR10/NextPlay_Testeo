using Microsoft.EntityFrameworkCore;
using NexPlayAPI.Models;
using NexPlayAPI.Services;
using NexPlayAPI.DTOs.Usuario;
using NexPlayAPI.DTOs.Auth;

namespace NexPlayAPI.UnitTests;

public class UnitTest1
{
    private static NexPlayContext CrearContexto()
    {
        var opciones = new DbContextOptionsBuilder<NexPlayContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new NexPlayContext(opciones);
    }

    private static Usuario CrearUsuarioPrueba(ulong id = 1)
    {
        return new Usuario
        {
            IdUsuario = id,
            NombreCompleto = "Paola Vides",
            Correo = "paola@nexplay.test",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Clave123"),
            Apodo = "PaoGamer",
            XpTotal = 100,
            Monedas = 50,
            Gemas = 10
        };
    }

    private static Avatar CrearAvatarPrueba()
    {
        return new Avatar
        {
            IdAvatar = 1,
            Nombre = "Avatar Inicial",
            Imagen = "avatar.png"
        };
    }

    [Fact]
    public async Task CP01_ObtenerTodosLosUsuarios()
    {
        using var contexto = CrearContexto();
        contexto.Usuarios.Add(CrearUsuarioPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new UsuarioService(contexto);
        var resultado = await servicio.ObtenerTodosAsync();

        Assert.Single(resultado);
        Assert.Equal("Paola Vides", resultado[0].NombreCompleto);
    }

    [Fact]
    public async Task CP02_ObtenerUsuarioPorId()
    {
        using var contexto = CrearContexto();
        contexto.Usuarios.Add(CrearUsuarioPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new UsuarioService(contexto);
        var resultado = await servicio.ObtenerPorIdAsync(1);

        Assert.NotNull(resultado);
        Assert.Equal((ulong)1, resultado.IdUsuario);
        Assert.Equal("PaoGamer", resultado.Apodo);
    }

    [Fact]
    public async Task CP03_ObtenerPerfilUsuario()
    {
        using var contexto = CrearContexto();

        var usuario = CrearUsuarioPrueba();
        usuario.IdAvatarNavigation = CrearAvatarPrueba();
        usuario.IdAvatar = 1;

        contexto.Usuarios.Add(usuario);
        await contexto.SaveChangesAsync();

        var servicio = new UsuarioService(contexto);
        var resultado = await servicio.ObtenerPerfilAsync(1);

        Assert.NotNull(resultado);
        Assert.Equal("Paola Vides", resultado.NombreCompleto);
        Assert.Equal("Avatar Inicial", resultado.NombreAvatar);
        Assert.Equal((uint)100, resultado.XpTotal);
    }

    [Fact]
    public async Task CP04_RegistrarNuevoUsuario()
    {
        using var contexto = CrearContexto();

        var servicio = new UsuarioService(contexto);

        var dto = new CrearUsuarioDto
        {
            NombreCompleto = "Usuario Nuevo",
            Correo = "nuevo@nexplay.test",
            Password = "ClaveSegura123",
            Apodo = "NuevoGamer"
        };

        var resultado = await servicio.CrearAsync(dto);

        Assert.True(resultado.Exito);
        Assert.NotNull(resultado.Usuario);
        Assert.Equal("nuevo@nexplay.test", resultado.Usuario.Correo);
        Assert.Single(await contexto.Usuarios.ToListAsync());

        var guardado = await contexto.Usuarios.SingleAsync();
        Assert.True(BCrypt.Net.BCrypt.Verify(
            "ClaveSegura123", guardado.PasswordHash));
    }

    [Fact]
    public async Task CP05_ActualizarUsuario()
    {
        using var contexto = CrearContexto();
        contexto.Usuarios.Add(CrearUsuarioPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new UsuarioService(contexto);

        var dto = new ActualizarUsuarioDto
        {
            NombreCompleto = "Paola Actualizada",
            Apodo = "PaoPro"
        };

        var resultado = await servicio.ActualizarAsync(1, dto);

        Assert.True(resultado.Exito);
        Assert.NotNull(resultado.Usuario);
        Assert.Equal("Paola Actualizada",
            resultado.Usuario.NombreCompleto);

        var guardado = await contexto.Usuarios.FindAsync((ulong)1);
        Assert.NotNull(guardado);
        Assert.Equal("PaoPro", guardado.Apodo);
    }

    [Fact]
    public async Task CP06_IniciarSesion()
    {
        using var contexto = CrearContexto();
        contexto.Usuarios.Add(CrearUsuarioPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new AuthService(contexto);

        var dto = new LoginDto
        {
            Correo = "paola@nexplay.test",
            Password = "Clave123"
        };

        var resultado = await servicio.LoginAsync(dto);

        Assert.True(resultado.Exito);
        Assert.NotNull(resultado.Usuario);
        Assert.Equal("PaoGamer", resultado.Usuario.Apodo);
    }

    [Fact]
    public async Task CP07_ObtenerTodosLosAvatares()
    {
        using var contexto = CrearContexto();
        contexto.Avatars.Add(CrearAvatarPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new AvatarService(contexto);
        var resultado = await servicio.ObtenerTodosAsync();

        Assert.Single(resultado);
        Assert.Equal("Avatar Inicial", resultado[0].Nombre);
    }

    [Fact]
    public async Task CP08_ObtenerAvatarPorId()
    {
        using var contexto = CrearContexto();
        contexto.Avatars.Add(CrearAvatarPrueba());
        await contexto.SaveChangesAsync();

        var servicio = new AvatarService(contexto);
        var resultado = await servicio.ObtenerPorIdAsync(1);

        Assert.NotNull(resultado);
        Assert.Equal("Avatar Inicial", resultado.Nombre);
        Assert.Equal("avatar.png", resultado.Imagen);
    }
}
