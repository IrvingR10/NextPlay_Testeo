using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Avatar
{
    public ushort IdAvatar { get; set; }

    public string Nombre { get; set; } = null!;

    public string Imagen { get; set; } = null!;

    public virtual ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
}
