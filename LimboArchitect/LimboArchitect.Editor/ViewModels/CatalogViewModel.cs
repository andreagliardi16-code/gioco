using LimboArchitect.Core.ObjTemplates;
using System.Collections.ObjectModel;
using System.Linq;
using System.Diagnostics;

namespace LimboArchitect.Editor.ViewModels
{
    public class GroupCategory
    {
        public string Category {get; set; } = "";
        public ObservableCollection<ObjectTemplate> Elements {get; set; } = new();
    }
    public class CatalogViewModel : ViewModelBase
    {
        public ObservableCollection<GroupCategory> GroupedCategories{get; }

        public CatalogViewModel()
        {
            GroupedCategories = new ObservableCollection<GroupCategory>();

            var groups = EditorCatalog.AvailableObjects.GroupBy(t => t.Category);

            foreach (var g in groups)
            {
                var newCategory = new GroupCategory{ Category = g.Key};

                foreach (var item in g)
                {
                    newCategory.Elements.Add(item);
                }

                GroupedCategories.Add(newCategory);
            }

            Debug.WriteLine($"[DEBUG] Il catalogo contiene {GroupedCategories.Count} categorie.");
            foreach (var cat in GroupedCategories)
            {
                Debug.WriteLine($" -> Categoria: {cat.Category} (Contiene {cat.Elements.Count} elementi)");
                foreach (var elem in cat.Elements)
                {
                    Debug.WriteLine($"     - Oggetto: {elem.Name}");
                }
            }
        }
    }
}