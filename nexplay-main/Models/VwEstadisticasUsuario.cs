using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class VwEstadisticasUsuario
{
    public ulong IdUsuario { get; set; }

    public string? Apodo { get; set; }

    public uint XpTotal { get; set; }

    public uint Monedas { get; set; }

    public uint Gemas { get; set; }

    public long PartidasJugadas { get; set; }

    public decimal Victorias { get; set; }

    public long MejorPuntaje { get; set; }

    public decimal TiempoJugadoSegundos { get; set; }
}
