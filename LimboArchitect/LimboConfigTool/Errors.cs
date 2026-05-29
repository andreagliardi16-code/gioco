using System;

namespace LimboArchitect.Core.Diagnostics
{
    public enum ErrorCode
    {
        None = 0,                  // Nessun errore
        DuplicateObjectId = 67,   // L'ID dell'oggetto esiste già nella griglia
        DuplicateShapeId = 102,    // L'ID della forma esiste già nel registro
        OutOfBounds = 103,         // L'oggetto è fuori dai confini del livello
        InvalidGateConnection = 201,// Il portale punta a se stesso o a un livello nullo
        JsonLoadError = 301,       // Il file del livello è corrotto o invalido
        FileNotFound = 302         // Icona o scena di Godot non trovata
    }

    public class LimboArchitectException: Exception
    {
        public ErrorCode Code {get; }

        // Costruttore che accetta il codice e un messaggio personalizzato
        public LimboArchitectException(ErrorCode code, string message) : base(message)
        {
            Code = code;
        }
    }
}