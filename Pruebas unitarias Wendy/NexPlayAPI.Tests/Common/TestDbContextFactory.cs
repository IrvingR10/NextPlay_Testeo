using Microsoft.EntityFrameworkCore;
using NexPlayAPI.Models;

namespace NexPlayAPI.Tests.Common;

/// <summary>
/// Contexto especializado para pruebas unitarias.
/// Permite configurar llaves primarias en las vistas para poder agregar datos simulados en memoria.
/// </summary>
public class TestNexPlayContext : NexPlayContext
{
    public TestNexPlayContext(DbContextOptions<NexPlayContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        // Las vistas de MySQL en producción no tienen clave primaria definida directamente en la tabla,
        // pero para poder realizar pruebas en memoria con EF Core, definimos sus claves lógicas.
        modelBuilder.Entity<VwEstadisticasUsuario>().HasKey(e => e.IdUsuario);
        modelBuilder.Entity<VwMejorPuntajeUsuarioJuego>().HasKey(e => new { e.IdUsuario, e.IdJuego });
        modelBuilder.Entity<VwRankingGlobal>().HasKey(e => e.IdUsuario);
        modelBuilder.Entity<VwRankingSemanal>().HasKey(e => e.IdUsuario);
    }
}

/// <summary>
/// Fábrica para crear instancias aisladas de NexPlayContext en memoria.
/// </summary>
public static class TestDbContextFactory
{
    public static TestNexPlayContext CreateContext(string? dbName = null)
    {
        var options = new DbContextOptionsBuilder<NexPlayContext>()
            .UseInMemoryDatabase(databaseName: dbName ?? Guid.NewGuid().ToString())
            .Options;

        var context = new TestNexPlayContext(options);
        context.Database.EnsureCreated();
        return context;
    }
}
