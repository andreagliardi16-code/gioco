using LimboArchitect.Core.ObjTemplates;
using LimboArchitect.Core.Object;
using CommunityToolkit.Mvvm.ComponentModel;
using System.Collections.Generic;

namespace LimboArchitect.Editor.ViewModels
{
    public class CatalogViewModel : ViewModelBase
    {
        [ObservableProperty]
        private IReadOnlyList<ObjectTemplate> ObgTemplatesList{get; } = EditorCatalog.AvailableObjects
    }
}