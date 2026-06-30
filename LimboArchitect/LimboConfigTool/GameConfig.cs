using System.Text.Json.Serialization;


// Classe per rappresentare la configurazione del gioco, con sezioni per le statistiche del giocatore e del mondo.
// Ogni sezione contiene proprietà specifiche che possono essere deserializzate da un file JSON.
// La sezione MagicNumbers serve solo a Limbo Architect, quindi non viene serializzata.


public class GameConfig
{
    [JsonPropertyName("player_stats")]
    public PlayerStatsSection PlayerStats { get; set; } = new();

    [JsonPropertyName("world_stats")]
    public WorldStatsSection WorldStats { get; set; } = new();
    // Aggiungere flag per non serializzare sezione
    public MagicNumbersSection MagicNumbers {get; set; } = new();
}

public class PlayerStatsSection
{
    [JsonPropertyName("gravity")] public GravitySection Gravity { get; set; } = new();
    [JsonPropertyName("jump")] public JumpSection Jump { get; set; } = new();
    [JsonPropertyName("horizontal_movement")] public HorizontalMovementSection HorizontalMovement { get; set; } = new();
    [JsonPropertyName("camera")] public CameraSection Camera { get; set; } = new();
    [JsonPropertyName("dash")] public DashSection Dash { get; set; } = new();
    [JsonPropertyName("energy")] public EnergySection Energy { get; set; } = new();
    [JsonPropertyName("pogo")] public PogoSection Pogo { get; set; } = new();
}

public class GravitySection
{
    [JsonPropertyName("default_gravity")] public float DefaultGravity { get; set; }
    [JsonPropertyName("fall_gravity")] public float FallGravity { get; set; }
    [JsonPropertyName("cut_gravity")] public float CutGravity { get; set; }
}

public class JumpSection
{
    [JsonPropertyName("coyote_time")] public float CoyoteTime { get; set; }
    [JsonPropertyName("jump_cut_time")] public float JumpCutTime { get; set; }
    [JsonPropertyName("jump_force")] public float JumpForce { get; set; }
    [JsonPropertyName("max_jump_time")] public float MaxJumpTime { get; set; }
    [JsonPropertyName("min_jump_time")] public float MinJumpTime { get; set; }
}
public class HorizontalMovementSection
{
    [JsonPropertyName("max_speed")] public float MaxSpeed { get; set; }
    [JsonPropertyName("acceleration")] public float Acceleration { get; set; }
    [JsonPropertyName("deceleration")] public float Deceleration { get; set; }
    [JsonPropertyName("max_speed_change")] public float MaxSpeedChange { get; set; }
}

public class CameraSection
{
    [JsonPropertyName("zoom")] public float Zoom { get; set; }
    [JsonPropertyName("distance_n")] public float DistanceN { get; set; }
    [JsonPropertyName("max_distance")] public float MaxDistance { get; set; }
    [JsonPropertyName("x_pan_target")] public float XPanTarget { get; set; }
    [JsonPropertyName("y_pan_target")] public float YPanTarget { get; set; }
}

public class DashSection
{
    [JsonPropertyName("dash_speed_amt")] public float DashSpeedAmt { get; set; }
    [JsonPropertyName("dash_time")] public float DashTime { get; set; }
    [JsonPropertyName("dash_cut")] public float DashCut { get; set; }
    [JsonPropertyName("dash_cooldown")] public float DashCooldown { get; set; }
}

public class EnergySection
{
    [JsonPropertyName("max_energy")] public float MaxEnergy { get; set; }
    [JsonPropertyName("regen_rate")] public float RegenRate { get; set; }
    [JsonPropertyName("max_cooldown")] public float MaxCooldown { get; set; }
    [JsonPropertyName("max_regen_time")] public float MaxRegenTime { get; set; }
}

public class PogoSection
{
    [JsonPropertyName("side_force")] public float SideForce { get; set; }
    [JsonPropertyName("vertical_force")] public float VerticalForce { get; set; }
    [JsonPropertyName("impulse_duration")] public float ImpulseDuration { get; set; }
    [JsonPropertyName("fade_duration")] public float FadeDuration { get; set; }
    [JsonPropertyName("area_detection_time")] public float AreaDetectionTime { get; set; }
}

public class WorldStatsSection
{
    [JsonPropertyName("friction")] public FrictionSection Friction { get; set; } = new();
    [JsonPropertyName("gates")] public GatesSection Gates { get; set; } = new();
}

public class FrictionSection
{
    [JsonPropertyName("air_friction")] public float AirFriction { get; set; }
    [JsonPropertyName("def_material_friction")] public float DefMaterialFriction { get; set; }
}

public class GatesSection
{
    [JsonPropertyName("gate_spawn_offset")] public float GateSpawnOffset { get; set; }
}

public class MagicNumbersSection
{
    public float ShortJumpCoeff {get; } = 0.7f; // coefficente che riassume la velocità media di un salto che parte da fermo
    public float NormVertPogoCoeff {get; } = 0.9f; // coefficente che riassume la velocità media di un pogo verso il basso e poi accel. lateralmente (il dover spostare l'analogico in basso rallenta il movimento orizzontale)
    public int NodeSearchRadius {get; } = 300;  // raggio del cerchio intorno a un nodo in cui si ricercano altri nodi a cui collegarsi

}