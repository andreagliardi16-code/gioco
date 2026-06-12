using Avalonia;
using Avalonia.Controls;
using Avalonia.Media;
using LimboArchitect.Core;

namespace LimboArchitect.Editor.Views;

public class GridBackground : Control
{
    private static readonly IBrush BackgroundBrush = new SolidColorBrush(Color.Parse("#060606"));
    private static readonly Pen FineGridPen = new Pen(new SolidColorBrush(Color.Parse("#222222")), 0.2);
    private static readonly Pen LargeGridPen = new Pen(new SolidColorBrush(Color.Parse("#4c4c4c")), 0.4);

    public override void Render(DrawingContext context)
    {
        // 1. Disegna prima lo sfondo solido scuro (se impostato nel XAML)
        context.DrawRectangle(BackgroundBrush, null, new Rect(0, 0, Bounds.Width, Bounds.Height));

        // 2. Prepariamo la penna per il reticolo grigio scuro
        int fineCellSize = (int)Constants.CellSize;

        // 3. Disegna le linee verticali della griglia
        for (double x = 0; x <= Bounds.Width; x += fineCellSize)
        {
            context.DrawLine(FineGridPen, new Point(x, 0), new Point(x, Bounds.Height));
        }

        // 4. Disegna le linee orizzontali della griglia
        for (double y = 0; y <= Bounds.Height; y += fineCellSize)
        {
            context.DrawLine(FineGridPen, new Point(0, y), new Point(Bounds.Width, y));
        }

        // 5. Creo la penna per una griglia più visibile e larga
        int largeCellSize = (int)Constants.CellSize*10;

        // 6. Disegno anche la nuova griglia
        for (double x = 0; x <= Bounds.Width; x += largeCellSize)
        {
            context.DrawLine(LargeGridPen, new Point(x, 0), new Point(x, Bounds.Height));
        }

        for (double y = 0; y <= Bounds.Height; y += largeCellSize)
        {
            context.DrawLine(LargeGridPen, new Point(0, y), new Point(Bounds.Width, y));
        }

        // IMPORTANTE: Chiama il render base per fare in modo che Avalonia 
        // disegni i tuoi blocchi blu SOPRA la griglia appena tracciata
        //base.Render(context);
    }
}