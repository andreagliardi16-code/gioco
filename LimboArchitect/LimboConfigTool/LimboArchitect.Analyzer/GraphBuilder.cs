using System.ComponentModel.DataAnnotations;
using LimboArchitect.Core.Analyzer.Graph;

namespace LimboArchitect.Core.Analyzer.GraphBuilder;

public class Graph
{
    private const int ArcMaxLength = 100;
    public Dictionary<int, GraphNode> Nodes { get; } = new();
    public Dictionary<int, GraphArc> Arcs { get; } = new();

    public void AddNode(GraphNode node)
    {
        Nodes.Add(node.Id, node);
    }

    public void BuildGraph()
    {
        Dictionary<(int cx, int cy), List<GraphNode>> SpatialGrid = new();
        
    }
}