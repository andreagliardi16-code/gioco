using CommunityToolkit.Mvvm.ComponentModel;


namespace LimboArchitect.Editor.ViewModels;

public partial class MainWindowViewModel : ViewModelBase
{
    [ObservableProperty]
    private object _currentPage;// usare CurrentPage per riferirsi a questa


    public MainWindowViewModel()
    {
        // All'avvio mostra schermata vuota
        CurrentPage = new WelcomeViewModel();
    }

    // --- METODI PER COLLEGAMENTO TASTI ---

    public void CreateNewLevelAction()
    {
        CurrentPage = new LevelMap(newLevel: true);
    }

    public void LoadLevelAction()
    {
        // Aggiungere metodo per trovare JSON
        CurrentPage = new LevelMap(newLevel: false);
    }
}
