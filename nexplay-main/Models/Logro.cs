using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class Logro
{
    public uint IdLogro { get; set; }

    public string Nombre { get; set; } = null!;

    public string Descripcion { get; set; } = null!;

    public string? Icono { get; set; }

    public virtual ICollection<Usuario> IdUsuarios { get; set; } = new List<Usuario>();
}
