using System.Runtime.InteropServices.Swift;
using System.Text.RegularExpressions;
using System.Xml;
using LimboArchitect.Core.Analyzer.Graph;
using LimboArchitect.Core.Shapes;


namespace LimboArchitect.Core.Utils
{
    // Serve per ottimizzare la costruzione e l'analisi del grafo limitando l'accesso tra i nodi dividendo lo spazio in regioni
    public class Quadtree
    {
        private const int maxNodesPerBoundary = 8;
        public RectBoundary Boundary {get; private set; }
        private List<GraphNode> _nodes = new();

        private Quadtree[] _children = null;
        private bool _isDivided = false;

        public Quadtree(RectBoundary boundary)
        {
            Boundary = boundary;
        }

        // Metodo per inserire un nodo nell'albero
        public bool Insert(GraphNode node)
        {
            if (!Boundary.Contains(node.X, node.Y)) return false;

            // Se c'è ancora spazio e non siamo divisi, aggiungilo qui
            if (_nodes.Count < maxNodesPerBoundary && !_isDivided)
            {
                _nodes.Add(node);
                return true;
            }

            if (!_isDivided) Subdivide();

            if (_children[0].Insert(node)) return true;
            if (_children[1].Insert(node)) return true;
            if (_children[2].Insert(node)) return true;
            if (_children[3].Insert(node)) return true;

            return false;
        }

        // metodo per dividere il quadrante in quattro altri quadranti
        private void Subdivide()
        {
            int nextHalfWidth = Boundary.HalfWidth / 2;
            int nextHalfHeight = Boundary.HalfHeight / 2;

            RectBoundary rect1 = new RectBoundary (
                Boundary.Position.X+nextHalfWidth,
                Boundary.Position.Y-nextHalfHeight,
                Boundary.HalfWidth,
                Boundary.HalfHeight
            );
            RectBoundary rect2 = new RectBoundary (
                Boundary.Position.X-nextHalfWidth,
                Boundary.Position.Y-nextHalfHeight,
                Boundary.HalfWidth,
                Boundary.HalfHeight
            );
            RectBoundary rect3 = new RectBoundary (
                Boundary.Position.X-nextHalfWidth,
                Boundary.Position.Y+nextHalfHeight,
                Boundary.HalfWidth,
                Boundary.HalfHeight
            );
            RectBoundary rect4 = new RectBoundary (
                Boundary.Position.X+nextHalfWidth,
                Boundary.Position.Y+nextHalfHeight,
                Boundary.HalfWidth,
                Boundary.HalfHeight
            );

            _children = new Quadtree[4] {
                new Quadtree(rect1),
                new Quadtree(rect2),
                new Quadtree(rect3),
                new Quadtree(rect4)
            };
            
            _isDivided = true;

            foreach (GraphNode node in _nodes)
            {
                if (_children[0].Insert(node)) continue;
                if (_children[1].Insert(node)) continue;
                if (_children[2].Insert(node)) continue;
                if (_children[3].Insert(node)) continue;
            }

            _nodes.Clear();
        }

        // Cerca tutti i nodi che intersecano un'area di ricerca (es. il raggio d'azione del salto)
        public List<GraphNode> Query((int x, int y)center, int radius)
        {
            List<GraphNode> foundNodes = new();

            if (!Boundary.Intersects(center, radius)) return foundNodes;

            int sqrRadius = radius*radius;
            foreach (var node in _nodes)
            {
                int n = (node.X-center.x)*(node.X-center.x);
                int m = (node.Y-center.y)*(node.Y-center.y);

                if (n+m <= sqrRadius)
                {
                    foundNodes.Add(node);
                }
            }

            if (_isDivided)
            {
                foundNodes.AddRange(_children[0].Query(center, radius));
                foundNodes.AddRange(_children[1].Query(center, radius));
                foundNodes.AddRange(_children[2].Query(center, radius));
                foundNodes.AddRange(_children[3].Query(center, radius));
            }

            return foundNodes;
        }

    }

    public static class IdGenerator
    {
        // Contatori di partenza per garantire l'esclusività dei range
        private static int _arcCounter = 100000;
        private static int _nodeCounter = 200000;

        public static string GenerateId<T>()
        {
            string className = typeof(T).Name;
            string prefix = className.ToLower().Replace("object", "").Replace("shape", "");
            string randomPart = Guid.NewGuid().ToString().Substring(0, 6);

            return $"{prefix}_{randomPart}";
        }

        public static int GenerateGraphId(bool is_node)
        {
            return is_node 
                ? Interlocked.Increment(ref _nodeCounter) 
                : Interlocked.Increment(ref _arcCounter);
        }
    }

    public static class StringExtensions
    {
        public static string ToSnakeCase(this string input)
        {
            if (string.IsNullOrEmpty(input)) 
                return input;

            string result = Regex.Replace(input, @"(?<!^)(?=[A-Z][a-z])|(?<=[a-z0-9])(?=[A-Z])", "_");
            result = Regex.Replace(result, @"[\s-]+", "_");
            return result.ToLower();
        }
    }
}