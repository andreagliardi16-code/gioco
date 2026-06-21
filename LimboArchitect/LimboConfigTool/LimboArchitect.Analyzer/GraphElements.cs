using LimboArchitect.Core.Utils;


namespace LimboArchitect.Core.Analyzer.Graph;

public enum GraphNodeType
{
    Undefined = 0,
    StaticPlatform,
    AnimatedPlatform,
    PogoArea,
}

public class GraphArc
{
    public (int x, int y) Start {get; init;}
    public (int x, int y) End {get; init;}
    public int Id {get; init;}
    public float Weight {get; private set; } = 0f;   // Deve venir determinato
    public readonly float Length = 0;

    public GraphArc((int, int)start, (int, int)end)
    {
        Start = start;
        End = end;
        Id = IdGenerator.GenerateGraphId(is_node: false);

        float deltaX = End.x - Start.x;
        float deltaY = End.y - Start.y;
        Length = MathF.Sqrt((deltaX * deltaX) + (deltaY * deltaY));
    }

    public void SetWeight(float weight) => Weight = weight;
}

public class GraphNode
{
    public int X {get; init;}
    public int Y {get; init;}
    public int Id {get; init;}
    public GraphNodeType ObjType {get; init; }   // Implementare con enum per sicurezza e performance, indica il tipo di oggetto che rappresenta
    public float Weight {get; private set; } = 0f;   // Deve venir determinato

    public GraphNode(int x, int y, GraphNodeType type)
    {
        X = x;
        Y = y;
        ObjType = type;
        Id = IdGenerator.GenerateGraphId(is_node: true);
    }

    public void SetWeight(float weight) => Weight = weight;
}