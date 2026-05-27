using System;
using LimboArchitect.Core.Physics;
using LimboArchitect.Core.Shapes;
using LimboArchitect.Core.Utils;


namespace LimboArchitect.Core.Object
{
    public abstract class LevelObject
    {
        //utili a compilatore e conversione in Godot
        public string TypeID {get; set;}   //il set potrebbe dover essere tolto
        public string GodotClassName {get; set;}

        //posizione sulla griglia
        public int GridX {get; set;}
        public int GridY {get; set;}

        //riferimento al livello
        public GameLevel? ParentLevel {get; set; }
        public string Id {get; init; }

        //per la UI
        public string DisplayName { get; set; }  // Es: "Piattaforma Mobile"
        public string IconPath { get; set; }     // Icona da mostrare nella palette di Avalonia
        public string Category { get; set; }     // Per dividere la UI in schede (es: "Terreno", "Trappole")

        protected LevelObject(string typeId, string godotClassName, string displayName, string iconPath, string category)
        {
            TypeID = typeId;
            GodotClassName = godotClassName;
            DisplayName = displayName;
            IconPath = iconPath;
            Category = category;
            Id = IdGenerator.GenerateId(this);
        }

        public abstract string ExportToGDScript(string extraDataJson);
    }

    
    public abstract class PhysicObject: LevelObject
    {
        public string MaterialId = "normal_mar";
        
        public Material CurrentMaterial => MaterialDatabase.GetMaterial(MaterialId);

        protected PhysicObject(string id, string godotClassName, string displayName, string iconPath, string category, int x, int y)
            : base(id, godotClassName, displayName, iconPath, category)
        {
        }

    }

    public class StaticObject: PhysicObject
    {
        
    }

    public class RegularPlatform: StaticObject
    {
        
    }

    public class PolygonPlatform: StaticObject
    {
        
    }

    public abstract class MovableObject: PhysicObject
    {
        
    }

    public class MovingPlatform: MovableObject
    {
        
    }

    public class RotatingPlatform: MovableObject
    {
        
    }

    public class BreakingPlatform: MovableObject
    {
        
    }

    public abstract class InteractiveObject: PhysicObject
    {
        
    }

    public class Trampoline: InteractiveObject
    {
        
    }

    public class Boost: InteractiveObject
    {
        
    }

    //Aree
    public abstract class AreaObject: LevelObject
    {
        public string AreaShape = "rectangle";
        private bool PhysicsRelevant {get; init; }

        protected AreaObject(bool physicsRelevant, string areaShape, string id, string godotClassName, string displayName, string iconPath, string category)
            : base(id, godotClassName, displayName, iconPath, category)
        {
            AreaShape = areaShape;
            PhysicsRelevant = physicsRelevant;
        }
    }

    public abstract class UtilityArea: AreaObject
    {
        protected UtilityArea (string areaShape, string id, string godotClassName, string displayName, string iconPath)
            : base(false, areaShape, id, godotClassName, displayName, iconPath, "Utility")
        {
        }
    }

    public abstract class GameArea: AreaObject
    {
        protected GameArea (string areaShape, string id, string godotClassName, string displayName, string iconPath, string category)
            : base(true, areaShape, id, godotClassName, displayName, iconPath, category)
        {
        }
    }

    public class LevelGate: UtilityArea
    {
        public string OwnPtr;
        public string GatePtr;
        public string NextLevelPtr {get; set; } = "";
        public string OwnLevelPtr {get; set; } = "";

        public LevelGate (string areaShape, string id, string godotClassName, string displayName, string iconPath, string category)
            : base(areaShape, id, godotClassName, displayName, iconPath)
        {
            
        }

        public string ExportToGDScript(string extraDataJson)
        {
            return "";
        }
    }

    public class SpawnArea: UtilityArea
    {
        
    }

    public class PlaceHolderArea: UtilityArea
    {
        
    }

    public class Killzone: GameArea
    {
        
    }

    public class PogoArea: GameArea
    {
        
    }

    
}