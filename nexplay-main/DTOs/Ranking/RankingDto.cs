namespace NexPlayAPI.DTOs.Ranking;

public class RankingDto
{
    public ulong IdUsuario { get; set; }

    public string? Apodo { get; set; }

    public decimal Puntos { get; set; }

    public ulong Posicion { get; set; }
}
