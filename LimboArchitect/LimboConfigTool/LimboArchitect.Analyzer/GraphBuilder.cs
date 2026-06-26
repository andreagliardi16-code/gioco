using LimboArchitect.Core.Analyzer.Graph;
using LimboArchitect.Core.Diagnostics;
using LimboArchitect.Core.Shapes;
using LimboArchitect.Core.Utils;


namespace LimboArchitect.Core.Analyzer.GraphBuilder;

public class Graph
{
    private const int ArcMaxSearch = 500;
    public Dictionary<int, GraphNode> Nodes { get; } = new();
    public Dictionary<int, GraphArc> Arcs { get; } = new();

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

        List<GraphNode> NodesToLink = _quadtree.Query((new_node.X, new_node.Y), ArcMaxSearch);
        List<int> AddedArcs = [];
        
        foreach (GraphNode node in NodesToLink)
        {
            if (node.Id == new_node.Id) continue;
            if(ValidateConnection(new_node, node))
            {
                AddedArcs.Add(CreateArc(new_node, node));  
            }
            if(ValidateConnection(node, new_node))
            {
                AddedArcs.Add(CreateArc(node, new_node));  
            }        
        }
    }

    private int CreateArc(GraphNode start, GraphNode end)
    {
        GraphArc new_arc = new GraphArc((start.X, start.Y), (end.X, end.Y), start.Id, end.Id);
        start.AddArc(new_arc.Id);
        Arcs.Add(new_arc.Id, new_arc);
        return new_arc.Id;
    }

    private bool ValidateConnection(GraphNode start, GraphNode target)
    {
        throw new NotImplementedException(); // controllo geometrico e ridondanza
    }
}