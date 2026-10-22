using System;
using System.Collections.Generic;

namespace NexPlayAPI.Models;

public partial class CategoriaJuego
{
    public ushort IdCategoria { get; set; }

    public string Nombre { get; set; } = null!;

    public virtual ICollection<Juego> IdJuegos { get; set; } = new List<Juego>();
}
