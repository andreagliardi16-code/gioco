using LimboArchitect.Core.Diagnostics;
using LimboArchitect.Core.Object;

namespace LimboArchitect.Core.Levels
{
    public class CreationContext
    {
        public string LevelName { get; init; }
        //Aggiungere altri campi necessari

        public CreationContext(string levelName)
            {
                LevelName = levelName;
            }
    }

    public class GameLevel
    {
        // 1. PROPRIETÀ IN SOLA LETTURA (Notazione PascalCase per il C#)
        // Chiunque fuori dalla classe può leggerle, nessuno può modificarle dall'esterno
        public int MinX { get; private set; }
        public int MaxX { get; private set; }
        public int MinY { get; private set; }
        public int MaxY { get; private set; }
        public CreationContext Context {get; private set; }
        public string LevelName{ get; set; } = "nuovo_livello";

        public Dictionary<(int X, int Y), List<LevelObject>> Grid { get; set; } 


        public GameLevel(string id)
        {
            LevelName = id;
            Grid = new Dictionary<(int, int), List<LevelObject>>();
            Context = new CreationContext(LevelName);
        }

        //Metodo per inserire o sovrascrivere un oggetto
        public void PlaceObject(LevelObject obj)
        {
            var coord = (obj.GridX, obj.GridY);
            
            LevelObject newObj = obj;

            if (Grid.TryGetValue(coord, out var list))
            {
                list.Add(newObj);
            } 
            else
            {
                Grid.Add(coord, new List<LevelObject>{newObj});
            }

            if (newObj is LevelGate)
            {
                
            }
        }

        public void RemoveAllObjects(int x, int y)
        {
            var coord = (x, y);
            if (Grid.ContainsKey(coord))
                Grid.Remove(coord); // Rimuove l'oggetto se esiste
        }

        public void RemoveObject(int x, int y, LevelObject obj)
        {
            var coord = (x, y);
            if (Grid.TryGetValue(coord, out var list))
            {
                list.Remove(obj);
                // pulizia dizionario in caso si svuoti la cella
                if (list.Count == 0)
                {
                    Grid.Remove(coord);
                }
            }
            else
            {
                throw new LimboArchitectException(
                    ErrorCode.NonexistantObjKey,
                    $"Non esiste alcun oggetto alle coordinate {coord}"
                    );
            }
        }

        // METODO UTILE AL VIEWMODEL
        public List<LevelObject> FindObject(int x, int y)
        {
            var coord = (x, y);

            if (!Grid.ContainsKey(coord))
            {
                return [];  // lista vuota
            }
            else 
            {
                return Grid[coord];
            }
            
        }

        // 2. IL METODO DI AGGIORNAMENTO
        // Ora il metodo non ha nemmeno più bisogno di restituire una Tupla! 
        // Può tornare a essere 'void' perché il suo unico scopo è aggiornare lo stato della classe.
        public void CalcMargins()
        {
            // Variabili locali temporanee per fare il calcolo "pulito" senza sporcare 
            // le proprietà pubbliche mentre il ciclo è ancora in corso
            int tempMinX = int.MaxValue;
            int tempMaxX = int.MinValue;
            int tempMinY = int.MaxValue;
            int tempMaxY = int.MinValue;

            if (Grid.Count <= 0)
            {
                Console.WriteLine("Il livello è vuoto.");
                MinX = 0; MaxX = 0; MinY = 0; MaxY = 0;
                return;
            }

            foreach(var coord in Grid.Keys)
            {
                if (coord.X < tempMinX) tempMinX = coord.X;
                if (coord.X > tempMaxX) tempMaxX = coord.X;
                if (coord.Y < tempMinY) tempMinY = coord.Y;
                if (coord.Y > tempMaxY) tempMaxY = coord.Y;
            }

            int offset = 2;
            tempMaxX += offset;
            tempMaxY += offset;
            tempMinX -= offset;
            tempMinY -= offset;

            if (tempMaxX > 30) tempMaxX = 30;
            if (tempMaxY > 15) tempMaxY = 15;

            // SOLO ORA, a calcolo finito e sicuro, salviamo i dati nelle proprietà della classe
            MinX = tempMinX;
            MaxX = tempMaxX;
            MinY = tempMinY;
            MaxY = tempMaxY;

            Console.WriteLine($"Stato Livello Aggiornato -> X: da {MinX} a {MaxX} | Y: da {MinY} a {MaxY}");
        }
    }


    public static class LevelNameDB
    {
        private static readonly List<string> _levelUsedNames = new();

        public static bool TryRegisterLevelName(string name)
        {
            string CleanedName = name.Trim();

            if (_levelUsedNames.Contains(CleanedName))
            {
                return false;  //il nome è già usato
            }

            return true;
        }
    }
}
