using System.Collections.Generic;
using System.Collections.ObjectModel;
using LimboArchitect.Core.Levels;
using LimboArchitect.Core.Object;
using LimboArchitect.Core.ObjTemplates;
using System.Linq;


namespace LimboArchitect.Editor.ViewModels
{
    public class LevelMap
    {
        public ObservableCollection<PlacedObjectViewModel> ItemsMap {get; }
        private GameLevel? LevelRef {get; set; }

        public void PlaceObject(int x, int y, ObjectTemplate template)
        {
            if (LevelRef == null)
            {
                return;
            }
            LevelObject newObj = template.Factory(LevelRef.Context);
            PlacedObjectViewModel newItem = new(newObj, x, y);

            if (!CanPlaceItem(newItem))
            {
                return;      //implementare nuova exception
            }
            
            ItemsMap.Add(newItem);
            LevelRef.PlaceObject(newObj);
        }

        public bool CanPlaceItem(PlacedObjectViewModel item)
        {
            List<LevelObject> ExistingObjects = LevelRef.FindObject(item.X, item.Y);
            LevelObject obj = item.BackendObject;

            if (ExistingObjects.Count == 0 || obj is AreaObject)  // TODO: controllare anche sovrapposizioni
            {
                return true;
            }
            else if (ExistingObjects.Any(o => o is PhysicObject))
            {
                return false;
            }
            return true;
        }

        public LevelMap()
        {
            ItemsMap = new ObservableCollection<PlacedObjectViewModel>();
        }
    }
}