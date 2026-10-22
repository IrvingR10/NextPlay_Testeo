using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Partidum
{
    public ulong IdPartida { get; set; }

    public ulong IdUsuario { get; set; }

    public ulong IdJuego { get; set; }

    public uint Puntaje { get; set; }

    public string Resultado { get; set; } = null!;

    public uint DuracionSegundos { get; set; }

    public DateTime FechaHora { get; set; }

    public virtual Juego IdJuegoNavigation { get; set; } = null!;

    public virtual Usuario IdUsuarioNavigation { get; set; } = null!;
}
