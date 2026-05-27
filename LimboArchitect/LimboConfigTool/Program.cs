using System;
using System.ComponentModel;
using System.IO;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;

string jsonPath = @"C:\Users\Andrea\Desktop\ascatasuna\ext_game_data\game_data.json";

GameConfig config = null;

if (File.Exists(jsonPath))
{
    string jsonString = File.ReadAllText(jsonPath);

    //deserializzazione automatica ad albero nativa .NET
    config = JsonSerializer.Deserialize<GameConfig>(jsonString);

    Console.WriteLine("[LimboArchitect] JSON caricato con successo");
    Console.WriteLine("-> Valori di gioco letti con successo");
}
else
{
    Console.WriteLine($"ERRORE: file JSON non trovato al percorso {jsonPath}");
    return;
}

// Creazione livello di prova (SOSTITUIRE CON VERA LOGICA)
GameLevel livelloProva = new GameLevel { LevelName = "livello_Prova_01" };

livelloProva.PlaceObject(0, 4, "platform");
livelloProva.PlaceObject(1, 2, "platform");
livelloProva.PlaceObject(3, 5, "spikes");
livelloProva.PlaceObject(0, 5, "gate");

Console.WriteLine($"\n--- Rendering di {livelloProva.LevelName} ---");

livelloProva.CalcMargins();

// Cicliamo su una mini-finestra di coordinate da Y=0 a 5 e X=0 a 5
for (int y = livelloProva.MinY; y <= livelloProva.MaxY; y++)
{
    string rigaScena = "";


    for (int x = livelloProva.MinX; x <= livelloProva.MaxX; x++)
    {
        if (livelloProva.Grid.TryGetValue((x, y), out LevelObject obj))
        {
            // Sostituiamo il TypeId con un carattere grafico
            rigaScena += obj.TypeID switch
            {
                "platform" => "# ",
                "spikes" => "X ",
                "gate" => "O ",
                _ => "? "
            };
        }
        else
        {
            rigaScena += ". "; // Spazio vuoto
        }
    }
    Console.WriteLine(rigaScena);
}

Console.WriteLine("\n[LEGENDA]: # Piattaforma | X Spina | O Portale | . Vuoto");
