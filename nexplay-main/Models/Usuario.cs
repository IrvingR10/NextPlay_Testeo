using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Usuario
{
    public ulong IdUsuario { get; set; }

    public string NombreCompleto { get; set; } = null!;

    public string Correo { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string? Apodo { get; set; }

    public ushort? IdAvatar { get; set; }

    public uint XpTotal { get; set; }

    public uint Monedas { get; set; }

    public uint Gemas { get; set; }

    public virtual Avatar? IdAvatarNavigation { get; set; }

    public virtual ICollection<Partidum> Partida { get; set; } = new List<Partidum>();

    public virtual ICollection<UsuarioReto> UsuarioRetos { get; set; } = new List<UsuarioReto>();

    public virtual ICollection<Usuario> IdAmigos { get; set; } = new List<Usuario>();

    public virtual ICollection<Juego> IdJuegos { get; set; } = new List<Juego>();

    public virtual ICollection<Logro> IdLogros { get; set; } = new List<Logro>();

    public virtual ICollection<Usuario> IdUsuarios { get; set; } = new List<Usuario>();
}
