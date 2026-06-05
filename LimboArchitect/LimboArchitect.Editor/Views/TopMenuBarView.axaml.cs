using Avalonia;
using Avalonia.Controls;
using Avalonia.Markup.Xaml;

namespace LimboArchitect.Editor.Views;

public partial class TopMenuBarView : UserControl
{
    public TopMenuBarView()
    {
        AvaloniaXamlLoader.Load(this);
    }
}