using System;
using System.ComponentModel;
using System.IO;
using System.Text.Json;
using LimboArchitect.Core.Levels;
using LimboArchitect.Core.Object;

namespace LimboArchitect.Core.Setup
{
    public class StartFunctions
    {
        private static void SetupJson()
        {
            string jsonPath = @"C:\Users\Andrea\Desktop\ascatasuna\ext_game_data\game_data.json";

            GameConfig config = null;

            if (File.Exists(jsonPath))
            {
                string jsonString = File.ReadAllText(jsonPath);

                //deserializzazione automatica ad albero nativa .NET
                config = JsonSerializer.Deserialize<GameConfig>(jsonString);

                //Console.WriteLine("[LimboArchitect] JSON caricato con successo");
                //Console.WriteLine("-> Valori di gioco letti con successo");
            }
            else
            {
                //Console.WriteLine($"ERRORE: file JSON non trovato al percorso {jsonPath}");
                return;
            }
        }

        public static void CreateGenericLevel()
        {
            // Creazione livello di prova (SOSTITUIRE CON VERA LOGICA)
            GameLevel livelloProva = new("livello_prova");

            //Console.WriteLine($"\n--- Rendering di {livelloProva.LevelName} ---");

            livelloProva.CalcMargins();

            // Cicliamo su una mini-finestra di coordinate da Y=0 a 5 e X=0 a 5
            for (int y = livelloProva.MinY; y <= livelloProva.MaxY; y++)
            {
                string rigaScena = "";


                for (int x = livelloProva.MinX; x <= livelloProva.MaxX; x++)
                {
                    if (livelloProva.Grid.TryGetValue((x, y), out LevelObject obj))
                    {
                    }
                    else
                    {
                        rigaScena += ". "; // Spazio vuoto
                    }
                }
                //Console.WriteLine(rigaScena);
            }

            //Console.WriteLine("\n[LEGENDA]: # Piattaforma | X Spina | O Portale | . Vuoto"); 
        }    
    }
}
