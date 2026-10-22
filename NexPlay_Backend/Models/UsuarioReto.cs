using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class UsuarioReto
{
    public ulong IdUsuario { get; set; }

    public ulong IdReto { get; set; }

    public uint Progreso { get; set; }

    public bool Reclamado { get; set; }

    public virtual Reto IdRetoNavigation { get; set; } = null!;

    public virtual Usuario IdUsuarioNavigation { get; set; } = null!;
}
