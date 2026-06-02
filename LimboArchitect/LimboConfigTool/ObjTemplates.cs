using System;
using System.Collections.Generic;
using LimboArchitect.Core.Levels;
using LimboArchitect.Core.Object;

namespace LimboArchitect.Core.ObjTemplates
{
    public class ObjectTemplate
    {
        public string Name { get; init; }         // Es: "Timed Pogo Area"
        public string Description { get; init; }  // Es: "Piattaforma pogo che si disattiva a tempo"
        public string IconPath { get; init; }     // Il percorso dell'icona da mostrare nel menù Avalonia

        public Func<CreationContext, LevelObject> Factory { get; init; } 

        public ObjectTemplate(string name, string description, string iconPath, Func<CreationContext, LevelObject> factory)
        {
            Name = name;
            Description = description;
            IconPath = iconPath;
            Factory = factory;
        }
    }

    // OTTIMIZZAZIONE 1: La classe EditorCatalog resa "static"
    public static class EditorCatalog     // !!! TODO: Implementare tutti i percorsi !!!
    {
        // OTTIMIZZAZIONE 2: Uso di IReadOnlyList invece di List
        public static IReadOnlyList<ObjectTemplate> AvailableObjects { get; } = new List<ObjectTemplate>
        {
            new ObjectTemplate (
                "Regular Platform",
                "Piattaforma statica rettangolare",
                "Icons/...",
                // OTTIMIZZAZIONE 3: Uso del discard "_" per il context non utilizzato
                (_) => new RegularPlatform("Icons/...")
            ),
            new ObjectTemplate (
                "Polygon Platform",
                "Piattaforma statica con forma poligonale",
                "Icons/...",
                (_) => new PolygonPlatform("Icons/...")
            ),
            new ObjectTemplate (
                "Moving Platform",
                "Piattaforma rettangolare che si può muovere lungo un percorso",
                "Icons/...",
                // OTTIMIZZAZIONE 4: Stringa di default invece di stringa vuota ""
                (_) => new MovingPlatform("Icons/...", "default_anim")
            ),
            new ObjectTemplate (
                "Rotating Platform",
                "Piattaforma rettangolare che, a tempo, gira su sé stessa",
                "Icons/...",
                (_) => new RotatingPlatform("Icons/...", "default_anim")
            ),
            new ObjectTemplate (
                "Breakable Platform",
                "Piattaforma rettangolare che, dopo il contatto con il player, si rompe",
                "Icons/...",
                (_) => new BreakingPlatform("Icons/...", "default_anim")
            ),
            new ObjectTemplate (
                "Level Gate",
                "Area che permette di cambiare scena di gioco",
                "Icons/...",
                // Qui usiamo effettivamente il context!
                (context) => new LevelGate("Icons/...", context.LevelName)
            ),
            new ObjectTemplate (
                "Spawn Area",
                "Area che permette di rinascere dopo aver subito danni",
                "Icons/...",
                (_) => new SpawnArea("Icons/...")
            ),
            new ObjectTemplate (
                "NPC Placeholder",
                "Contrassegno per NPC",
                "Icons/...",
                (_) => new PlaceHolderArea("Icons/...", PlaceHolderArea.PlaceholderType.Npc)
            ),
            new ObjectTemplate (
                "Info Placeholder",
                "Contrassegno per testi di informazioni",
                "Icons/...",
                (_) => new PlaceHolderArea("Icons/...", PlaceHolderArea.PlaceholderType.Info)
            ),
            new ObjectTemplate (
                "Item Placeholder",
                "Contrassegno per oggetti collezionabili",
                "Icons/...",
                (_) => new PlaceHolderArea("Icons/...", PlaceHolderArea.PlaceholderType.Item)
            ),
            new ObjectTemplate (
                "Killzone",
                "Area di danno che provoca respawn",
                "Icons/...",
                (_) => new Killzone ("Icons/...")
            ),
            // --- AGGIUNTE: Le PogoArea che mancavano all'appello ---
            new ObjectTemplate (
                "Static Pogo Area",
                "Area circolare su cui il giocatore può rimbalzare",
                "Icons/...",
                (_) => new StaticPogoArea("Icons/...")
            ),
            new ObjectTemplate (
                "Timed Pogo Area",
                "Area pogo che si attiva e disattiva a intervalli di tempo",
                "Icons/...",
                (_) => new TimedPogoArea("Icons/...")
            )
        };
    }
}