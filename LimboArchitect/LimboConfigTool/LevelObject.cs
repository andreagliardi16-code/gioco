using System;
using System.Formats.Asn1;
using System.Numerics;
using System.Runtime.CompilerServices;
using System.Text.Json;
using LimboArchitect.Core.Levels;
using LimboArchitect.Core.Physics;
using LimboArchitect.Core.Shapes;
using LimboArchitect.Core.Utils;


namespace LimboArchitect.Core.Object
{
    public abstract class LevelObject
    {
        //utili a compilatore e conversione in Godot
        public string GodotClassName {get; set;}

        //posizione sulla griglia
        public int GridX {get; set;}
        public int GridY {get; set;}

        //riferimento al livello
        public GameLevel? ParentLevel {get; set; }
        public string Id {get; init; }  //viene assegnato nei costruttori dei figli

        //per la UI
        public string DisplayName { get; set; }  // Es: "Piattaforma Mobile"
        public string IconPath { get; set; }     // Icona da mostrare nella palette di Avalonia
        public string Category { get; set; }     // Per dividere la UI in schede (es: "Terreno", "Trappole")

        protected LevelObject(string godotClassName, string displayName, string iconPath, string category)
        {
            GodotClassName = godotClassName;
            DisplayName = displayName;
            IconPath = iconPath;
            Category = category;
            Id = default!;
        }
        
        public abstract (bool, string) TrySave(string extraDataJson);
        public abstract string ExportToGDScript(string extraDataJson);
    }

    
    public abstract class PhysicObject: LevelObject
    {
        public string MaterialId = "normal_mar";
        public string AreaId {get; set; }
        
        public Material CurrentMaterial => MaterialDatabase.GetMaterial(MaterialId);

        protected PhysicObject(string areaId, string godotClassName, string displayName, string iconPath, string category)
            : base(godotClassName, displayName, iconPath, category)
        {
            AreaId = areaId;
        }

    }

    public abstract class StaticObject: PhysicObject
    {
        protected StaticObject(string areaId, string godotClassName, string displayName, string iconPath)
            : base(areaId, godotClassName, displayName, iconPath, "Static Platforms")
        {
        }
    }

    public class RegularPlatform: StaticObject
    {
        public Area Shape {get; set; }

        // COSTRUTTORE 1: da UI
        public RegularPlatform(string iconPath)
            : base("default_rectangle_platform","StaticPlatform", "Platform", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle("default_rectangle_platform", 128, 16);
            Id = IdGenerator.GenerateId<RegularPlatform>();
        }
        // COSTRUTTORE 2: da JSON
        public RegularPlatform(string shapeId, string iconPath, string id)
            : base(shapeId, "StaticPlatform", "Platform", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);
            Id = id;
        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Shape == null || Id == null)
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            var ObjectData = new
            {
                id=Id,
                class_name=GodotClassName,
                shape_id=AreaId,
                x=GridX,
                y=GridY,
                extra_data = extraDataJson
            };

            return JsonSerializer.Serialize(ObjectData);
        }
    }

    public class PolygonPlatform: StaticObject
    {
        public Area Polygon {get; set; }

        // COSTRUTTORE 1: da UI
        public PolygonPlatform(string iconPath)
            : base("default_polygon", "StaticPlatform", "Floor", iconPath)
        {
            Polygon = ShapesRegistry.GetOrCreatePolygon("default_polygon");
            Id = IdGenerator.GenerateId<PolygonPlatform>();
        }
        // COSTRUTTORE 2: da JSON
        public PolygonPlatform(string shapeId, string id, string iconPath)
            : base(shapeId, "StaticPlatform", "Floor", iconPath)
        {
            Polygon = ShapesRegistry.GetOrCreatePolygon(shapeId);
            Id = id;
        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Polygon == null || Id == null)
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            var ObjectData = new
            {
                id=Id,
                class_name=GodotClassName,
                shape_id=AreaId,
                x=GridX,
                y=GridY,
                extra_data=extraDataJson
            };

            return JsonSerializer.Serialize(ObjectData);
        }
    }

    public abstract class MovableObject: PhysicObject
    {
        public string? AnimId {get; init; }

        public MovableObject(string animId, string areaId, string godotClassName, string displayName, string iconPath)
            : base(areaId, godotClassName, displayName, iconPath, "Animated Platforms")
        {
            AnimId = animId;
        }
    }

    public class MovingPlatform: MovableObject
    {
        public Vector2 TargetPos {get; set; }
        public float StopTime {get; set; }
        public float MoveTime {get; set; }
        public Area Shape {get; set; }

        // COSTRUTTORE 1: da UI
        public MovingPlatform(string iconPath, string animId)
            : base("default_rectangle_platform",animId, "MovingPlatform", "Moving Platform", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle("default_rectangle_platform", 128, 16);
            Id = IdGenerator.GenerateId<MovingPlatform>();
            TargetPos = new Vector2(0, 0);
            StopTime = 1f;
            MoveTime = 5f;
        }
        // COSTRUTTORE 2: da JSON
        public MovingPlatform(string shapeId, Vector2 targetPos, float stopTime, float moveTime, string iconPath, string animId, string id)
            : base(shapeId, animId, "MovingPlatform", "Moving Platform", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);
            TargetPos = targetPos;
            StopTime = stopTime;
            MoveTime = moveTime;
            Id = id;
        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Shape == null || Id == null || AnimId==null)
            {
                return (false, "");
            }
            else if (MoveTime <= 0 || StopTime < 0) 
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        }
    }

    public class RotatingPlatform: MovableObject
    {
        public float StopTime {get; set; }
        public float MoveTime {get; set; }
        public Area Shape {get; set; }

        // COSTRUTTORE 1: da UI
        public RotatingPlatform(string iconPath, string animId)
            : base("default_rectangle_platform", animId, "RotatingPlatform", "Rotating Platform", iconPath)
        {
            StopTime = 1f;
            MoveTime = 5f;
            Id = IdGenerator.GenerateId<RotatingPlatform>();
            Shape = ShapesRegistry.GetOrCreateRectangle("default_rectangle_platform", 128, 16);

        }
        // COSTRUTTORE 2: da JSON
        public RotatingPlatform(string shapeId, float stopTime, float moveTime, string iconPath, string animId, string id)
            : base(shapeId, animId, "RotatingPlatform", "Rotating Platform", iconPath)
        {
            StopTime = stopTime;
            MoveTime = moveTime;
            Id = id;
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);

        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Shape == null || Id == null || AnimId== null)
            {
                return (false, "");
            }
            else if (MoveTime <= 0 || StopTime < 0) 
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        }
    }

    public class BreakingPlatform: MovableObject
    {
        public float BreakingTime {get; set; }
        public float RestTime {get; set; }
        public Area Shape {get; set; }

        // COSTRUTTORE 1: da UI
        public BreakingPlatform(string iconPath, string animId)
            : base("default_rectangle_platform",animId, "BreakingPlatform", "Breakable Platform", iconPath)
        {
            BreakingTime = 1.5f;
            RestTime = 2f;
            Id = IdGenerator.GenerateId<BreakingPlatform>();
            Shape = ShapesRegistry.GetOrCreateRectangle("default_rectangle_platform", 128, 16);
        }
        // COSTRUTTORE 2: da JSON
        public BreakingPlatform(string shapeId,string iconPath, string animId, float breakingTime, float restTime, string id)
            : base(shapeId, animId, "BreakingPlatform", "Breakable Platform", iconPath)
        {
            BreakingTime = breakingTime;
            RestTime = restTime;
            Id = id;
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);
        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Shape == null || Id == null || AnimId==null)
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        }
    }

    /* TODO: aree ancora da implementare ANCHE IN ENGINE

    public abstract class InteractiveObject: PhysicObject
    {
        
    }

    public class Trampoline: InteractiveObject
    {
        
    }

    public class Boost: InteractiveObject
    {
        
    }
    */

    //Aree
    public abstract class AreaObject: LevelObject
    {
        public string AreaId = "rectangle";
        private bool PhysicsRelevant {get; init; }

        protected AreaObject(bool physicsRelevant, string areaId, string godotClassName, string displayName, string iconPath, string category)
            : base(godotClassName, displayName, iconPath, category)
        {
            AreaId = areaId;
            PhysicsRelevant = physicsRelevant;
        }
    }

    public abstract class UtilityArea: AreaObject
    {
        protected UtilityArea (string areaId, string godotClassName, string displayName, string iconPath)
            : base(false, areaId, godotClassName, displayName, iconPath, "Utility")
        {
        }
    }

    public abstract class GameArea: AreaObject
    {
        protected GameArea (string areaId, string godotClassName, string displayName, string iconPath)
            : base(true, areaId, godotClassName, displayName, iconPath, "Game Areas")
        {
        }
    }

    public class LevelGate: UtilityArea
    {
        public string? OwnPtr {get; set; }
        public string? GatePtr {get; set;}
        public string? NextLevelPtr {get; set; }
        public string OwnLevelPtr {get; set; } = "";

        public RectangleShape Shape{get; set; }

        // COSTRUTTORE 1: da UI
        public LevelGate (string iconPath, string levelId)
            : base("def_rect", "LevelGate", "Level Gate", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle("def_rect");
            Id = IdGenerator.GenerateId<LevelGate>();
        }
        // COSTRUTTORE 2: da JSON
        public LevelGate (string shapeId, string ownPtr, string gatePtr, string nextLevelPtr, string id, string iconPath)
            : base(shapeId, "LevelGate", "Level Gate", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);
            OwnPtr = ownPtr;
            GatePtr = gatePtr;
            NextLevelPtr = nextLevelPtr;
            Id = id;
        }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (OwnPtr == null||GatePtr==null||NextLevelPtr==null||OwnLevelPtr==null)
            {
                return (false, "");
            }
            else if (Id == null)
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            var ObjectData = new
            {
                id=Id,
                class_name=GodotClassName,
                x=GridX,
                y=GridY,
                shape_id = AreaId,
                own_ptr=OwnPtr,
                gate_ptr=GatePtr,
                own_level_ptr=OwnLevelPtr,
                next_level_ptr=NextLevelPtr,
                extra_data= extraDataJson
            };
            return JsonSerializer.Serialize(ObjectData);
        }
    }

    public class SpawnArea: UtilityArea
    {
        public RectangleShape Shape{get; set; }

        // COSTRUTTORE 1: da UI
        public SpawnArea (string iconPath)
            : base("def_rect", "RespawnArea", "Spawn Area", iconPath) 
            {
                Shape = ShapesRegistry.GetOrCreateRectangle("def_rect");
                Id = IdGenerator.GenerateId<SpawnArea>();
            }
        // COSTRUTTORE 2: da JSON
        public SpawnArea (string shapeId, string iconPath, string id)
            : base(shapeId, "RespawnArea", "Spawn Area", iconPath)
            {
                Shape = ShapesRegistry.GetOrCreateRectangle("def_rect");
                Id = id;
                // aggiustare spawn point se utile
            }

        public override (bool, string) TrySave(string extraDataJson)
        {
            if (Shape==null||Id==null)
            {
                return (false, "");
            }
            else
            {
                var a = ExportToGDScript(extraDataJson);
                return (true, a);
            }
        }
        public override string ExportToGDScript(string extraDataJson)
        {
            var ObjectData = new
            {
                id=Id,
                class_name = GodotClassName,
                shape_id = AreaId,
                x=GridX,
                y=GridY,
                extra_data = extraDataJson
            };
            return JsonSerializer.Serialize(ObjectData);
        }
    }

    public class PlaceHolderArea: UtilityArea
    {
        public enum PlaceholderType
        {
            Npc,
            Item,
            Info
        }
        public PlaceholderType CurrentType { get; set; }

        public Area Shape {get; set; }

        public PlaceHolderArea (string iconPath, PlaceholderType type)
            : base("def_rect", "PlaceHolderArea", "Place Holder", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle("def_rect");
            Id = IdGenerator.GenerateId<PlaceHolderArea>();
            CurrentType = type;
        }

        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        } 
    }

    public class Killzone: GameArea
    {
        public Area Shape {get; set; }

        public Killzone (string iconPath)
            : base("def_rect", "KillZone", "Killzone", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle("def_rectangle");
            Id = IdGenerator.GenerateId<Killzone>();
        }
        public Killzone (string iconPath, string shapeId, string id)
            : base("def_rect", "KillZone", "Killzone", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateRectangle(shapeId);
            Id = id;
        }

        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        } 
    }

    public abstract class PogoArea: GameArea
    {
        public Area Shape {get; set; }

        public PogoArea (string iconPath, string godotClassName)
            : base("def_circle", godotClassName, "Pogo Area", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateCircle("def_circle");
        }
        public PogoArea (string iconPath, string godotClassName, string shapeId) 
            : base("def_circle", godotClassName, "Pogo Area", iconPath)
        {
            Shape = ShapesRegistry.GetOrCreateCircle(shapeId);
        }
    }

    public class StaticPogoArea: PogoArea
    {
        // COSTRUTTORE 1: da UI
        public StaticPogoArea (string iconPath)
            : base(iconPath, "PoagoableArea")
        {
            Id = IdGenerator.GenerateId<StaticPogoArea>();
        }
        //COSTRUTTORE 2: da JSON
        public StaticPogoArea (string iconPath, string shapeId, string id)
            : base(iconPath, "PogoableArea", shapeId)
        {
            Id = id;
        }

        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        }
    }

    public class TimedPogoArea: PogoArea
    {
        public float Timer {get; set; }

        // COSTRUTTORE 1: da UI
        public TimedPogoArea (string iconPath)
            : base(iconPath, "PogoableArea")
        {
            Id = IdGenerator.GenerateId<StaticPogoArea>();
            Timer = 0f;
        }
        //COSTRUTTORE 2: da JSON
        public TimedPogoArea (string iconPath, string shapeId, string id, float timer)
            : base(iconPath, "PogoableArea", shapeId)
        {
            Id = id;
            Timer = timer;
        }

        public override string ExportToGDScript(string extraDataJson)
        {
            throw new NotImplementedException();
        }
    }
}