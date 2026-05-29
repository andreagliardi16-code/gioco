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

        public static void AddShape (Area area)
        {
            if (_shapes.ContainsKey(area.Id))
            {
                throw new LimboArchitectException(
                    ErrorCode.DuplicateShapeId,
                    $"Impossibile aggiungere l'oggetto {area.Id}, esiste già un area con lo stesso identificativo"
                );
            }

            _shapes.Add(area.Id, area);
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
            ShapesRegistry.AddShape(this);
        }
    }
}