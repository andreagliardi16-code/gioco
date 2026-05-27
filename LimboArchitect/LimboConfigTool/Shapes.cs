using System;
using System.Data.Common;
using System.Dynamic;
using System.Numerics;


namespace LimboArchitect.Core.Shapes
{
    public static class ShapesRegistry
    {
        private static readonly Dictionary<string, RectangleShape> _shapes = new();
    }
    public abstract class Area
    {
        public string Id {get; set; } = "";
        
        protected Area(string id)
        {
            Id = id;
        }
    }

    public class Shape: Area
    {
        public int X {get; set;}
        public int Y {get; set;}

        public Shape(string id) : base(id)
        {
        }
    }

    public class RectangleShape: Shape
    {
        const int DEF_RECT_SIZE = 50;


        public int Width {get; set; }
        public int Height {get; set; }

        public RectangleShape(string id, int x, int y, int width = DEF_RECT_SIZE, int height  = DEF_RECT_SIZE) : base(id)
        {
            Width = width;
            Height = height;
            Place(x, y);
            SetBorders();
        }

        private void SetBorders()
        {
            var w = Width/2;
            var h = Height/2;

            top_x = X + w;
            bot_x = X - w;
            top_y = Y - h;
            bot_y = Y + h;
        }
    }
}