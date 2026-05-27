using System;
using System.Data.Common;
using System.Dynamic;


namespace LimboArchitect.Core.Physics
{
    public struct Material   //collegare a logica materiali di Godot
    {
        public string Id {get; set; }
        public float Friction {get; }

        public Material (string id, float friction)
        {
            Id = id;
            Friction = friction;
        }
    }

    public static class MaterialDatabase
    {
        private static readonly Dictionary <string, Material> _materials = new();

        static MaterialDatabase ()
        {
            // costruttore
            LoadDefaultMaterials();
        }

        private static void LoadDefaultMaterials()
        {
            _materials["def_material"] = new Material("def_material", 1.0f);
            _materials["ice_material"] = new Material("ice_material", 0.3f);
            _materials["air_material"] = new Material("air_material", 0.5f);
        }

        public static Material GetMaterial(string id)
        {
            if (_materials.TryGetValue(id, out var material))
            {
                return material;
            }

            // se l'Id non viene trovato
            return _materials["def_material"];
        }

        // Funzione per aggiornare il DB quando importerai il JSON da Godot
        public static void RegisterMaterial(Material mat)
        {
            _materials[mat.Id] = mat;
        }
    }
}
