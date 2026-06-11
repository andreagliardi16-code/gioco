using Avalonia;
using Avalonia.Controls;
using Avalonia.Markup.Xaml;
using LimboArchitect.Editor.ViewModels;

namespace LimboArchitect.Editor.Views;

public partial class CatalogView : UserControl
{
    public CatalogView()
    {
        AvaloniaXamlLoader.Load(this);

        DataContext = new CatalogViewModel();
    }
}