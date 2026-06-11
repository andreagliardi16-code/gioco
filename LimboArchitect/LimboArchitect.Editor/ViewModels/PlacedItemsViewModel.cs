using System;
using CommunityToolkit.Mvvm.ComponentModel;
using LimboArchitect.Core.Object;


namespace LimboArchitect.Editor.ViewModels
{
    

    public partial class PlacedObjectViewModel : ObservableObject
    {
        public LevelObject BackendObject {get; }

        public int X
        {
            get => BackendObject.GridX;

            set
            {
                if (BackendObject.GridX != value)
                {
                    BackendObject.GridX = value;
                    OnPropertyChanged(nameof(X));
                    OnPropertyChanged(nameof(PixelX));
                }
            }
        }

        public int Y
        {
            get => BackendObject.GridY;

            set
            {
                if (BackendObject.GridX != value)
                {
                    BackendObject.GridX = value;
                    OnPropertyChanged(nameof(Y));
                    OnPropertyChanged(nameof(PixelY));
                }
            }
        }

        public Double PixelX => X*32;
        public Double PixelY => Y*32;

        public PlacedObjectViewModel(LevelObject backendObject, int x, int y)
        {
            BackendObject = backendObject; // Agganciamo l'oggetto vero
            X = x;
            Y = y;
        }

    }
}