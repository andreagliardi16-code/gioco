using Avalonia;
using Avalonia.Controls;
using Avalonia.Markup.Xaml;

namespace LimboArchitect.Editor.Views;

public partial class CatalogView : UserControl
{
    public CatalogView()
    {
        AvaloniaXamlLoader.Load(this);;
    }
}