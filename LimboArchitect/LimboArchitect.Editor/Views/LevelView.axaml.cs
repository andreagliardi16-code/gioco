using Avalonia;
using Avalonia.Controls;
using Avalonia.Markup.Xaml;

namespace LimboArchitect.Editor.Views;

public partial class LevelMapView : UserControl
{
    public LevelMapView() 
    {
        AvaloniaXamlLoader.Load(this);
    }
}