using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Scaffolding.Internal;

namespace NexPlayAPI.Models;

public partial class NexPlayContext : DbContext
{
    public NexPlayContext()
    {
    }

    public NexPlayContext(DbContextOptions<NexPlayContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Avatar> Avatars { get; set; }

    public virtual DbSet<CategoriaJuego> CategoriaJuegos { get; set; }

    public virtual DbSet<Juego> Juegos { get; set; }

    public virtual DbSet<Logro> Logros { get; set; }

    public virtual DbSet<Partidum> Partida { get; set; }

    public virtual DbSet<Reto> Retos { get; set; }

    public virtual DbSet<Usuario> Usuarios { get; set; }

    public virtual DbSet<UsuarioReto> UsuarioRetos { get; set; }

    public virtual DbSet<VwEstadisticasUsuario> VwEstadisticasUsuarios { get; set; }

    public virtual DbSet<VwMejorPuntajeUsuarioJuego> VwMejorPuntajeUsuarioJuegos { get; set; }

    public virtual DbSet<VwRankingGlobal> VwRankingGlobals { get; set; }

    public virtual DbSet<VwRankingSemanal> VwRankingSemanals { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_unicode_ci")
            .HasCharSet("utf8mb4");

        modelBuilder.Entity<Avatar>(entity =>
        {
            entity.HasKey(e => e.IdAvatar).HasName("PRIMARY");

            entity.ToTable("avatar");

            entity.HasIndex(e => e.Nombre, "nombre").IsUnique();

            entity.Property(e => e.IdAvatar).HasColumnName("id_avatar");
            entity.Property(e => e.Imagen)
                .HasMaxLength(255)
                .HasColumnName("imagen");
            entity.Property(e => e.Nombre)
                .HasMaxLength(50)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<CategoriaJuego>(entity =>
        {
            entity.HasKey(e => e.IdCategoria).HasName("PRIMARY");

            entity.ToTable("categoria_juego");

            entity.HasIndex(e => e.Nombre, "nombre").IsUnique();

            entity.Property(e => e.IdCategoria).HasColumnName("id_categoria");
            entity.Property(e => e.Nombre)
                .HasMaxLength(40)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<Juego>(entity =>
        {
            entity.HasKey(e => e.IdJuego).HasName("PRIMARY");

            entity.ToTable("juego");

            entity.HasIndex(e => e.Nombre, "nombre").IsUnique();

            entity.Property(e => e.IdJuego).HasColumnName("id_juego");
            entity.Property(e => e.Descripcion)
                .HasMaxLength(255)
                .HasColumnName("descripcion");
            entity.Property(e => e.Dificultad)
                .HasColumnType("enum('FACIL','MEDIA','DIFICIL','EXPERTO')")
                .HasColumnName("dificultad");
            entity.Property(e => e.Imagen)
                .HasMaxLength(255)
                .HasColumnName("imagen");
            entity.Property(e => e.MaxJugadores)
                .HasDefaultValueSql("'1'")
                .HasColumnName("max_jugadores");
            entity.Property(e => e.Nombre)
                .HasMaxLength(80)
                .HasColumnName("nombre");
            entity.Property(e => e.RecompensaGemasBase).HasColumnName("recompensa_gemas_base");
            entity.Property(e => e.RecompensaMonedasBase).HasColumnName("recompensa_monedas_base");
            entity.Property(e => e.RecompensaXpBase).HasColumnName("recompensa_xp_base");

            entity.HasMany(d => d.IdCategoria).WithMany(p => p.IdJuegos)
                .UsingEntity<Dictionary<string, object>>(
                    "JuegoCategorium",
                    r => r.HasOne<CategoriaJuego>().WithMany()
                        .HasForeignKey("IdCategoria")
                        .HasConstraintName("fk_juego_categoria_categoria"),
                    l => l.HasOne<Juego>().WithMany()
                        .HasForeignKey("IdJuego")
                        .HasConstraintName("fk_juego_categoria_juego"),
                    j =>
                    {
                        j.HasKey("IdJuego", "IdCategoria")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("juego_categoria");
                        j.HasIndex(new[] { "IdCategoria" }, "fk_juego_categoria_categoria");
                        j.IndexerProperty<ulong>("IdJuego").HasColumnName("id_juego");
                        j.IndexerProperty<ushort>("IdCategoria").HasColumnName("id_categoria");
                    });
        });

        modelBuilder.Entity<Logro>(entity =>
        {
            entity.HasKey(e => e.IdLogro).HasName("PRIMARY");

            entity.ToTable("logro");

            entity.HasIndex(e => e.Nombre, "nombre").IsUnique();

            entity.Property(e => e.IdLogro).HasColumnName("id_logro");
            entity.Property(e => e.Descripcion)
                .HasMaxLength(255)
                .HasColumnName("descripcion");
            entity.Property(e => e.Icono)
                .HasMaxLength(255)
                .HasColumnName("icono");
            entity.Property(e => e.Nombre)
                .HasMaxLength(80)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<Partidum>(entity =>
        {
            entity.HasKey(e => e.IdPartida).HasName("PRIMARY");

            entity.ToTable("partida");

            entity.HasIndex(e => e.FechaHora, "idx_partida_fecha");

            entity.HasIndex(e => e.IdJuego, "idx_partida_juego");

            entity.HasIndex(e => e.IdUsuario, "idx_partida_usuario");

            entity.HasIndex(e => new { e.IdUsuario, e.IdJuego }, "idx_partida_usuario_juego");

            entity.Property(e => e.IdPartida).HasColumnName("id_partida");
            entity.Property(e => e.DuracionSegundos).HasColumnName("duracion_segundos");
            entity.Property(e => e.FechaHora)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime")
                .HasColumnName("fecha_hora");
            entity.Property(e => e.IdJuego).HasColumnName("id_juego");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Puntaje).HasColumnName("puntaje");
            entity.Property(e => e.Resultado)
                .HasColumnType("enum('VICTORIA','DERROTA','COMPLETADA')")
                .HasColumnName("resultado");

            entity.HasOne(d => d.IdJuegoNavigation).WithMany(p => p.Partida)
                .HasForeignKey(d => d.IdJuego)
                .HasConstraintName("fk_partida_juego");

            entity.HasOne(d => d.IdUsuarioNavigation).WithMany(p => p.Partida)
                .HasForeignKey(d => d.IdUsuario)
                .HasConstraintName("fk_partida_usuario");
        });

        modelBuilder.Entity<Reto>(entity =>
        {
            entity.HasKey(e => e.IdReto).HasName("PRIMARY");

            entity.ToTable("reto");

            entity.HasIndex(e => e.IdJuego, "fk_reto_juego");

            entity.HasIndex(e => new { e.Inicio, e.Fin }, "idx_reto_vigencia");

            entity.Property(e => e.IdReto).HasColumnName("id_reto");
            entity.Property(e => e.Descripcion)
                .HasMaxLength(255)
                .HasColumnName("descripcion");
            entity.Property(e => e.Fin)
                .HasColumnType("datetime")
                .HasColumnName("fin");
            entity.Property(e => e.IdJuego).HasColumnName("id_juego");
            entity.Property(e => e.Inicio)
                .HasColumnType("datetime")
                .HasColumnName("inicio");
            entity.Property(e => e.Nombre)
                .HasMaxLength(100)
                .HasColumnName("nombre");
            entity.Property(e => e.ObjetivoValor).HasColumnName("objetivo_valor");
            entity.Property(e => e.RecompensaGemas).HasColumnName("recompensa_gemas");
            entity.Property(e => e.RecompensaMonedas).HasColumnName("recompensa_monedas");
            entity.Property(e => e.RecompensaXp).HasColumnName("recompensa_xp");
            entity.Property(e => e.TipoObjetivo)
                .HasColumnType("enum('INICIO_SESION','PARTIDAS','VICTORIAS','PUNTAJE','TIEMPO_JUGADO')")
                .HasColumnName("tipo_objetivo");

            entity.HasOne(d => d.IdJuegoNavigation).WithMany(p => p.Retos)
                .HasForeignKey(d => d.IdJuego)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_reto_juego");
        });

        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.IdUsuario).HasName("PRIMARY");

            entity.ToTable("usuario");

            entity.HasIndex(e => e.Apodo, "apodo").IsUnique();

            entity.HasIndex(e => e.Correo, "correo").IsUnique();

            entity.HasIndex(e => e.IdAvatar, "fk_usuario_avatar");

            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Apodo)
                .HasMaxLength(40)
                .HasColumnName("apodo");
            entity.Property(e => e.Correo)
                .HasMaxLength(150)
                .HasColumnName("correo");
            entity.Property(e => e.Gemas).HasColumnName("gemas");
            entity.Property(e => e.IdAvatar).HasColumnName("id_avatar");
            entity.Property(e => e.Monedas).HasColumnName("monedas");
            entity.Property(e => e.NombreCompleto)
                .HasMaxLength(100)
                .HasColumnName("nombre_completo");
            entity.Property(e => e.PasswordHash)
                .HasMaxLength(255)
                .HasColumnName("password_hash");
            entity.Property(e => e.XpTotal).HasColumnName("xp_total");

            entity.HasOne(d => d.IdAvatarNavigation).WithMany(p => p.Usuarios)
                .HasForeignKey(d => d.IdAvatar)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("fk_usuario_avatar");

            entity.HasMany(d => d.IdAmigos).WithMany(p => p.IdUsuarios)
                .UsingEntity<Dictionary<string, object>>(
                    "Amistad",
                    r => r.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdAmigo")
                        .HasConstraintName("fk_amistad_amigo"),
                    l => l.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdUsuario")
                        .HasConstraintName("fk_amistad_usuario"),
                    j =>
                    {
                        j.HasKey("IdUsuario", "IdAmigo")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("amistad");
                        j.HasIndex(new[] { "IdAmigo" }, "fk_amistad_amigo");
                        j.IndexerProperty<ulong>("IdUsuario").HasColumnName("id_usuario");
                        j.IndexerProperty<ulong>("IdAmigo").HasColumnName("id_amigo");
                    });

            entity.HasMany(d => d.IdJuegos).WithMany(p => p.IdUsuarios)
                .UsingEntity<Dictionary<string, object>>(
                    "UsuarioJuegoFavorito",
                    r => r.HasOne<Juego>().WithMany()
                        .HasForeignKey("IdJuego")
                        .HasConstraintName("fk_favorito_juego"),
                    l => l.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdUsuario")
                        .HasConstraintName("fk_favorito_usuario"),
                    j =>
                    {
                        j.HasKey("IdUsuario", "IdJuego")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("usuario_juego_favorito");
                        j.HasIndex(new[] { "IdJuego" }, "fk_favorito_juego");
                        j.IndexerProperty<ulong>("IdUsuario").HasColumnName("id_usuario");
                        j.IndexerProperty<ulong>("IdJuego").HasColumnName("id_juego");
                    });

            entity.HasMany(d => d.IdLogros).WithMany(p => p.IdUsuarios)
                .UsingEntity<Dictionary<string, object>>(
                    "UsuarioLogro",
                    r => r.HasOne<Logro>().WithMany()
                        .HasForeignKey("IdLogro")
                        .HasConstraintName("fk_usuario_logro_logro"),
                    l => l.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdUsuario")
                        .HasConstraintName("fk_usuario_logro_usuario"),
                    j =>
                    {
                        j.HasKey("IdUsuario", "IdLogro")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("usuario_logro");
                        j.HasIndex(new[] { "IdLogro" }, "fk_usuario_logro_logro");
                        j.IndexerProperty<ulong>("IdUsuario").HasColumnName("id_usuario");
                        j.IndexerProperty<uint>("IdLogro").HasColumnName("id_logro");
                    });

            entity.HasMany(d => d.IdUsuarios).WithMany(p => p.IdAmigos)
                .UsingEntity<Dictionary<string, object>>(
                    "Amistad",
                    r => r.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdUsuario")
                        .HasConstraintName("fk_amistad_usuario"),
                    l => l.HasOne<Usuario>().WithMany()
                        .HasForeignKey("IdAmigo")
                        .HasConstraintName("fk_amistad_amigo"),
                    j =>
                    {
                        j.HasKey("IdUsuario", "IdAmigo")
                            .HasName("PRIMARY")
                            .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });
                        j.ToTable("amistad");
                        j.HasIndex(new[] { "IdAmigo" }, "fk_amistad_amigo");
                        j.IndexerProperty<ulong>("IdUsuario").HasColumnName("id_usuario");
                        j.IndexerProperty<ulong>("IdAmigo").HasColumnName("id_amigo");
                    });
        });

        modelBuilder.Entity<UsuarioReto>(entity =>
        {
            entity.HasKey(e => new { e.IdUsuario, e.IdReto })
                .HasName("PRIMARY")
                .HasAnnotation("MySql:IndexPrefixLength", new[] { 0, 0 });

            entity.ToTable("usuario_reto");

            entity.HasIndex(e => e.IdReto, "fk_usuario_reto_reto");

            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.IdReto).HasColumnName("id_reto");
            entity.Property(e => e.Progreso).HasColumnName("progreso");
            entity.Property(e => e.Reclamado).HasColumnName("reclamado");

            entity.HasOne(d => d.IdRetoNavigation).WithMany(p => p.UsuarioRetos)
                .HasForeignKey(d => d.IdReto)
                .HasConstraintName("fk_usuario_reto_reto");

            entity.HasOne(d => d.IdUsuarioNavigation).WithMany(p => p.UsuarioRetos)
                .HasForeignKey(d => d.IdUsuario)
                .HasConstraintName("fk_usuario_reto_usuario");
        });

        modelBuilder.Entity<VwEstadisticasUsuario>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_estadisticas_usuario");

            entity.Property(e => e.Apodo)
                .HasMaxLength(40)
                .HasColumnName("apodo");
            entity.Property(e => e.Gemas).HasColumnName("gemas");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.MejorPuntaje).HasColumnName("mejor_puntaje");
            entity.Property(e => e.Monedas).HasColumnName("monedas");
            entity.Property(e => e.PartidasJugadas).HasColumnName("partidas_jugadas");
            entity.Property(e => e.TiempoJugadoSegundos)
                .HasPrecision(32)
                .HasColumnName("tiempo_jugado_segundos");
            entity.Property(e => e.Victorias)
                .HasPrecision(23)
                .HasColumnName("victorias");
            entity.Property(e => e.XpTotal).HasColumnName("xp_total");
        });

        modelBuilder.Entity<VwMejorPuntajeUsuarioJuego>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_mejor_puntaje_usuario_juego");

            entity.Property(e => e.IdJuego).HasColumnName("id_juego");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.MejorPuntaje).HasColumnName("mejor_puntaje");
        });

        modelBuilder.Entity<VwRankingGlobal>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_ranking_global");

            entity.Property(e => e.Apodo)
                .HasMaxLength(40)
                .HasColumnName("apodo");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Posicion).HasColumnName("posicion");
            entity.Property(e => e.Puntos)
                .HasPrecision(32)
                .HasColumnName("puntos");
        });

        modelBuilder.Entity<VwRankingSemanal>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_ranking_semanal");

            entity.Property(e => e.Apodo)
                .HasMaxLength(40)
                .HasColumnName("apodo");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Posicion).HasColumnName("posicion");
            entity.Property(e => e.Puntos)
                .HasPrecision(32)
                .HasColumnName("puntos");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
