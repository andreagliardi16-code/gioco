using Avalonia;
using Avalonia.Controls;
using Avalonia.Media;
using LimboArchitect.Core;

namespace LimboArchitect.Editor.Views;

public class GridBackground : Control
{
    public override void Render(DrawingContext context)
    {
        // 1. Disegna prima lo sfondo solido scuro (se impostato nel XAML)
        context.DrawRectangle(new SolidColorBrush(Color.Parse("#060606")), null, new Rect(0, 0, Bounds.Width, Bounds.Height));

        // 2. Prepariamo la penna per il reticolo grigio scuro
        var gridPen = new Pen(new SolidColorBrush(Color.Parse("#222222")), 1.0);
        int cellSize = (int)Constants.CellSize;

        // 3. Disegna le linee verticali della griglia
        for (double x = 0; x <= Bounds.Width; x += cellSize)
        {
            context.DrawLine(gridPen, new Point(x, 0), new Point(x, Bounds.Height));
        }

        // 4. Disegna le linee orizzontali della griglia
        for (double y = 0; y <= Bounds.Height; y += cellSize)
        {
            context.DrawLine(gridPen, new Point(0, y), new Point(Bounds.Width, y));
        }

        // 5. FONDAMENTALE: Chiama il render base per fare in modo che Avalonia 
        // disegni i tuoi blocchi blu SOPRA la griglia appena tracciata
        //base.Render(context);
    }
}