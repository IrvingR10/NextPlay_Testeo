using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Juego
{
    public ulong IdJuego { get; set; }

    public string Nombre { get; set; } = null!;

    public string Descripcion { get; set; } = null!;

    public string Dificultad { get; set; } = null!;

    public byte MaxJugadores { get; set; }

    public string Imagen { get; set; } = null!;

    public ushort RecompensaXpBase { get; set; }

    public uint RecompensaMonedasBase { get; set; }

    public ushort RecompensaGemasBase { get; set; }

    public virtual ICollection<Partidum> Partida { get; set; } = new List<Partidum>();

    public virtual ICollection<Reto> Retos { get; set; } = new List<Reto>();

    public virtual ICollection<CategoriaJuego> IdCategoria { get; set; } = new List<CategoriaJuego>();

    public virtual ICollection<Usuario> IdUsuarios { get; set; } = new List<Usuario>();
}
