using System;
using System.Data.Common;
using System.Dynamic;
using System.Numerics;
using LimboArchitect.Core.Diagnostics;


namespace LimboArchitect.Core.Shapes
{
    public static class ShapesRegistry
    {
        private static readonly Dictionary<string, Area> _shapes = new();

        // Invece di un metodo 'void' che aggiunge e basta, creiamo un metodo che "Cerca o Crea"
        public static RectangleShape GetOrCreateRectangle(string id, int width = 50, int height = 50)
        {
            // 1. Se esiste già, lo restituiamo senza lanciare eccezioni (Riuso stile Godot!)
            if (_shapes.TryGetValue(id, out var existingShape) && existingShape is RectangleShape rect)
            {
                return rect;
            }

            // 2. Se l'ID esiste ma è di un tipo diverso (es. un cerchio), allora sì che è un errore
            if (_shapes.ContainsKey(id))
            {
                throw new LimboArchitectException(
                    ErrorCode.DuplicateShapeId,
                    $"L'identificativo '{id}' è già usato da un tipo di forma diverso."
                );
            }

            // 3. Se non esiste, creiamo il rettangolo e lo registriamo
            var newRect = new RectangleShape(id, width, height);
            _shapes.Add(id, newRect);

            return newRect;
        }

        public static CircleShape GetOrCreateCircle(string id, int radius = 50)
        {
            // 1. Se esiste già, lo restituiamo senza lanciare eccezioni (Riuso stile Godot!)
            if (_shapes.TryGetValue(id, out var existingShape) && existingShape is CircleShape circ)
            {
                return circ;
            }

            // 2. Se l'ID esiste ma è una forma diversa, allora sì che è un errore
            if (_shapes.ContainsKey(id))
            {
                throw new LimboArchitectException(
                    ErrorCode.DuplicateShapeId,
                    $"L'identificativo '{id}' è già usato da un tipo di forma diverso."
                );
            }

            // 3. Se non esiste, creiamo il cerchio e lo registriamo
            var newCircle = new CircleShape(id, radius);
            _shapes.Add(id, newCircle);

            return newCircle;
        }

        public static PolygonShape GetOrCreatePolygon(string id)
        {
            if (_shapes.TryGetValue(id, out var existingShape) && existingShape is PolygonShape poly)
            {
                return poly;
            }

            // Se l'id esiste già ma è una forma diversa:
            if (_shapes.ContainsKey(id))
            {
                throw new LimboArchitectException(
                    ErrorCode.DuplicateShapeId,
                    $"L'identificativo '{id}' è già usato da un tipo di forma diverso."
                );
            }

            // Se non esiste, creiamo un nuovo poligono con i punti passati come argomento
            var newPolygon = new PolygonShape(id);
            _shapes.Add(id, newPolygon);

            return newPolygon;
        }
    }

    public abstract class Area
    {
        public string Id {get; set; } = "";
        
        protected Area(string id)
        {
            Id = id;
        }
    }

    public class RectangleShape: Area
    {
        const int DEF_RECT_SIZE = 50;


        public int Width {get; set; }
        public int Height {get; set; }

        public RectangleShape(string id, int width = DEF_RECT_SIZE, int height  = DEF_RECT_SIZE) : base(id)
        {
            Width = width;
            Height = height;
        }
    }

    public class CircleShape: Area
    {
        const int DEF_CIRC_SIZE = 25;

        public int Radius {get; set; }

        public CircleShape(string id, int radius = DEF_CIRC_SIZE) : base(id)
        {
            Radius = radius;
        }
    }

    public class PolygonShape: Area
    {
        public List<Vector2> Points {get; set; }   // Points hanno posizioni relative al primo punto inserito.
        private Vector2 AnchorPoint {get; set; }

        public PolygonShape(string id) : base(id)
        {
            Points = new List<Vector2>();
            AnchorPoint = new Vector2(0f,0f);
            Points.Add(AnchorPoint);
        }

        public void AddPoint(Vector2 newPoint, int index = -1)    // trovare la posizione relativa di new_point è un problema
        {
            if (Points.Contains(newPoint)) 
            { 
                return; 
            }
            
            if (index < 0 || index == 0)  // non posso cambiare anchor point, quindi non posso passare 0
            {
                Points.Add(newPoint);
                return;
            }

            Points.Insert(index, newPoint);
        }

        public void RemovePoint(int index)
        {
            if (index < 0)
            {
                return;
            }

            if (index == 0)
            {
                AnchorPoint = Points[1];
            }

            Points.RemoveAt(index);
        }

        public void SavePolygon()
        {
            if (Points.Count < 3)
            {
                throw new LimboArchitectException (
                    ErrorCode.InvalidPolygonPoints,
                    "Il poligono deve essere salvato con almeno 3 punti"
                );
            }
        }
    }
}