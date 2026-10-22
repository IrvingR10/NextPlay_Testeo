using Microsoft.EntityFrameworkCore;
using NexPlayAPI.Models;

namespace NexPlay_Backend.Tests.Helpers;

/// <summary>
/// Datos de prueba reutilizables para las pruebas unitarias de NexPlay.
/// Cada método crea entidades independientes para garantizar aislamiento entre pruebas.
/// </summary>
public static class TestData
{
    /// <summary>
    /// Crea un NexPlayContext con base de datos InMemory aislada (nombre único por invocación).
    /// </summary>
    public static NexPlayContext CrearContexto()
    {
        var options = new DbContextOptionsBuilder<NexPlayContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var context = new NexPlayContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    /// <summary>
    /// Crea una entidad Usuario con valores por defecto razonables.
    /// El password se hashea con BCrypt para simular un registro real.
    /// </summary>
    public static Usuario CrearUsuario(
        ulong id = 1,
        string nombre = "Usuario Prueba",
        string correo = "test@nexplay.com",
        string password = "Password123!",
        string? apodo = "TestPlayer",
        ushort? idAvatar = null)
    {
        return new Usuario
        {
            IdUsuario = id,
            NombreCompleto = nombre,
            Correo = correo,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
            Apodo = apodo,
            IdAvatar = idAvatar,
            XpTotal = 0,
            Monedas = 0,
            Gemas = 0
        };
    }

    /// <summary>
    /// Crea una entidad Avatar con valores por defecto.
    /// </summary>
    public static Avatar CrearAvatar(
        ushort id = 1,
        string nombre = "Avatar Prueba",
        string imagen = "avatar_prueba.png")
    {
        return new Avatar
        {
            IdAvatar = id,
            Nombre = nombre,
            Imagen = imagen
        };
    }

    /// <summary>
    /// Crea una entidad Juego con valores por defecto.
    /// </summary>
    public static Juego CrearJuego(
        ulong id = 1,
        string nombre = "Juego Prueba",
        string descripcion = "Descripción del juego de prueba",
        string dificultad = "FACIL",
        byte maxJugadores = 1,
        string imagen = "juego_prueba.png")
    {
        return new Juego
        {
            IdJuego = id,
            Nombre = nombre,
            Descripcion = descripcion,
            Dificultad = dificultad,
            MaxJugadores = maxJugadores,
            Imagen = imagen,
            RecompensaXpBase = 100,
            RecompensaMonedasBase = 50,
            RecompensaGemasBase = 10
        };
    }

    /// <summary>
    /// Crea una entidad Reto con valores por defecto.
    /// </summary>
    public static Reto CrearReto(
        uint id = 1,
        string nombre = "Reto Prueba",
        string descripcion = "Descripción del reto de prueba",
        ulong? idJuego = null)
    {
        return new Reto
        {
            IdReto = id,
            Nombre = nombre,
            Descripcion = descripcion,
            TipoObjetivo = "PARTIDAS",
            ObjetivoValor = 5,
            Inicio = DateTime.UtcNow.AddDays(-1),
            Fin = DateTime.UtcNow.AddDays(7),
            IdJuego = idJuego,
            RecompensaXp = 200,
            RecompensaMonedas = 100,
            RecompensaGemas = 20
        };
    }

    /// <summary>
    /// Crea una entidad Logro con valores por defecto.
    /// </summary>
    public static Logro CrearLogro(
        uint id = 1,
        string nombre = "Logro Prueba",
        string descripcion = "Descripción del logro de prueba",
        string? icono = "logro_prueba.png")
    {
        return new Logro
        {
            IdLogro = id,
            Nombre = nombre,
            Descripcion = descripcion,
            Icono = icono
        };
    }

    /// <summary>
    /// Siembra datos de referencia básicos: un avatar, un juego y un usuario.
    /// Útil para pruebas que necesitan relaciones válidas (partidas, retos, etc.).
    /// </summary>
    public static async Task SembrarReferenciasBasicasAsync(NexPlayContext context)
    {
        var avatar = CrearAvatar(id: 1);
        var juego = CrearJuego(id: 1);
        var usuario = CrearUsuario(id: 1, idAvatar: 1);

        context.Avatars.Add(avatar);
        context.Juegos.Add(juego);
        context.Usuarios.Add(usuario);

        await context.SaveChangesAsync();
    }
}
