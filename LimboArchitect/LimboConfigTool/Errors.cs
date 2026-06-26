using System;

namespace LimboArchitect.Core.Diagnostics
{
    public enum ErrorCode
    {
        None = 0,                    // Nessun errore
        DuplicateObjectId = 101,     // L'ID dell'oggetto esiste già nella griglia
        DuplicateShapeId = 102,      // L'ID della forma esiste già nel registro
        OutOfBounds = 103,           // L'oggetto è fuori dai confini del livello
        OutOfGraph = 104,            // L'oggetto risulta esterno al grafo
        NonexistantObjKey = 105,     // L'oggetto cercato non esiste nelle coordinate indicate
        InvalidGateConnection = 201, // Il portale punta a se stesso o a un livello nullo
        JsonLoadError = 301,         // Il file del livello è corrotto o invalido
        FileNotFound = 302,          // Icona o scena di Godot non trovata
        UnableToSave = 303,          // Errore nel salvataggio
        InvalidPolygonPoints = 401   // Poligono inizializzato senza punti
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