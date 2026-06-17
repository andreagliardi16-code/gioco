using System.Diagnostics;
using System.IO.Enumeration;
using System.Security.AccessControl;
using System.Text.Json;
using System.Text.Json.Nodes;
using LimboArchitect.Core.Diagnostics;
using LimboArchitect.Core.Levels;


namespace LimboArchitect.Core.System
{
    public static class SystemMethods
    {
        const string jsonPath = @"res://ext_game_data\game_data.json";
        const string jsonLevelsPath = @"res://ext_levels/";


        private static void SetupJson()
        {
            GameConfig? config = null;

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

        public static bool CreateLevelJson(string levelName, List<JsonNode> levelObjects, out string ErrorMessage)
        {
            levelName = levelName.Trim();
            levelName = Utils.StringExtensions.ToSnakeCase(levelName);

            var levelText = new
            {
                name=levelName,
                script_name="level.gd",
                items=levelObjects
            };

            string CompleteJson = JsonSerializer.Serialize(levelText);

            bool err = SaveJsonOnDisc(levelName, jsonLevelsPath, CompleteJson, out ErrorMessage);

            if (!err)
            {
                // C'è stato un errore
                return false;
            }
            else
            {
                return true;
            }
        }

        public static bool SaveJsonOnDisc(string fileName, string path, string jsonFile, out string ErrorMessage)
        {
            ErrorMessage = string.Empty;

            try
            {
                if(!Directory.Exists(path))
                {
                    Debug.WriteLine("Il percorso della cartella non è stato trovato. Ne è stata creata una.");
                    Directory.CreateDirectory(path);
                }

                string FileName = fileName + ".json";
                string completePath = Path.Combine(path, FileName);

                File.WriteAllText(completePath, jsonFile);
                return true;
            }
            catch (Exception ex)
            {
                ErrorMessage = ex.Message;
                return false;
            }
        }
    }
}
