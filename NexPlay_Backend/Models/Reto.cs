using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Reto
{
    public ulong IdReto { get; set; }

    public string Nombre { get; set; } = null!;

    public string Descripcion { get; set; } = null!;

    public string TipoObjetivo { get; set; } = null!;

    public uint ObjetivoValor { get; set; }

    public ulong? IdJuego { get; set; }

    public ushort RecompensaXp { get; set; }

    public uint RecompensaMonedas { get; set; }

    public ushort RecompensaGemas { get; set; }

    public DateTime Inicio { get; set; }

    public DateTime Fin { get; set; }

    public virtual Juego? IdJuegoNavigation { get; set; }

    public virtual ICollection<UsuarioReto> UsuarioRetos { get; set; } = new List<UsuarioReto>();
}
