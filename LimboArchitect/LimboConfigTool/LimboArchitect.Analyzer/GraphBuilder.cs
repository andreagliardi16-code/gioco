using LimboArchitect.Core.Analyzer.Graph;
using LimboArchitect.Core.Diagnostics;
using LimboArchitect.Core.Shapes;
using LimboArchitect.Core.Utils;

namespace LimboArchitect.Core.Analyzer.GraphBuilder;

public class Graph
{
    private const int ArcMaxLength = 100;
    public Dictionary<int, GraphNode> Nodes { get; } = new();
    public Dictionary<int, GraphArc>? Arcs { get; }

    // Mappa dei nodi ad albero. Valutare se costruirla una tantum e tenerla o ricostruirla ogni volta.
    private Quadtree _quadtree;

    public Graph((int X, int Y, int width, int height)levelData, List<GraphNode> nodes)
    {
        RectBoundary boundary = new(levelData.X, levelData.Y, levelData.width, levelData.height);
        _quadtree = new Quadtree(boundary);

        foreach(GraphNode node in nodes)
        {
            AddNode(node);
        }
    }

    public void AddNode(GraphNode node)
    {
        Nodes.Add(node.Id, node);
        this.BuildGraph(node);
    }

    public void BuildGraph(GraphNode new_node)
    {
        bool ok = _quadtree.Insert(new_node);

        if (!ok)
        {
            throw new LimboArchitectException(ErrorCode.OutOfGraph, $"L'oggetto {new_node} risulta esterno ai confini assegnati al grafo");
        }
    }
}