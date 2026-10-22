using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class VwMejorPuntajeUsuarioJuego
{
    public ulong IdUsuario { get; set; }

    public ulong IdJuego { get; set; }

    public uint? MejorPuntaje { get; set; }
}
