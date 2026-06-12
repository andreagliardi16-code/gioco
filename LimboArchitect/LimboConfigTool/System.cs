using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text.Json;
using LimboArchitect.Core.Diagnostics;
using LimboArchitect.Core.Levels;


namespace LimboArchitect.Core.System
{
    public static class SystemMethods
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

        public static GameLevel CreateGenericLevel(string levelName = "nuovo_livello")
        {
            if (!CorrectLevelName(levelName))
            {
                levelName = "nuovo_livello";
            }

            GameLevel NewLevel = new GameLevel(levelName);
            NewLevel.CalcMargins();

            return NewLevel;
        }

        private static bool CorrectLevelName(string name)
        {
            if (name == "" || LevelNameDB.TryRegisterLevelName(name) == false)
            {
                return false;
            }
            else
            { 
                return true; 
            }
        }
    }
}
