using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class VwRankingSemanal
{
    public ulong IdUsuario { get; set; }

    public string? Apodo { get; set; }

    public decimal Puntos { get; set; }

    public ulong Posicion { get; set; }
}
