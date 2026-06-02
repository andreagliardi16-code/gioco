using System;
using LimboArchitect.Core.Object;

namespace LimboArchitect.Core.ObjTemplates
{
    public class ObjectTemplate
    {
        public string Name { get; init; }         // Es: "Timed Pogo Area"
        public string Description { get; init; }  // Es: "Piattaforma pogo che si disattiva a tempo"
        public string IconPath { get; init; }     // Il percorso dell'icona da mostrare nel menù Avalonia

        // Questa è la magia: una funzione che, quando invocata, sputa fuori un LevelObject pronto
        public Func<LevelObject> Factory { get; init; } 

        public ObjectTemplate(string name, string description, string iconPath, Func<LevelObject> factory)
        {
            Name = name;
            Description = description;
            IconPath = iconPath;
            Factory = factory;
        }
    }

    public class EditorCatalog     // !!! TODO: Implementare tutti i percorsi !!!
    {
        public List<ObjectTemplate> AvailableObjects {get; } = new()
        {
            new ObjectTemplate (
                "Regular Platform",
                "Piattaforma statica rettangolare",
                "Icons/...",
                () => new RegularPlatform("Icons/...")
            ),
            new ObjectTemplate (
                "Polygon Platform",
                "Piattaforma statica con forma poligonale",
                "Icons/...",
                () => new PolygonPlatform("Icons/...")
            ),
            new ObjectTemplate (
                "Moving Platform",
                "Piattaforma rettangolare che si può muovere lungo un percordo",
                "Icons/...",
                () => new MovingPlatform("Icon/...", "")
            ),
            new ObjectTemplate (
                "Rotating Platform",
                "Piattaforma rettangolare che, a tempo, gira su sé stessa",
                "Icons/...",
                () => new RotatingPlatform("Icons/...", "")
            ),
            new ObjectTemplate (
                "Breakable Platform",
                "Piattaforma rettangolare che, dopo il contatto con il player, si rompe",
                "Icons/...",
                () => new BreakingPlatform("Icons/...", "")
            ),
            new ObjectTemplate (
                "Level Gate",
                "Area che permette di cambiare scena di gioco",
                "Icons/...",
                () => new LevelGate("Icons/...")
            )
        };
    }

}
