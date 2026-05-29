using System;
using LimboArchitect.Core.Object;

namespace LimboArchitect.Core.Utils
{
    public static class IdGenerator
    {
        public static string GenerateId<T>()
        {
            // typeof(T).Name prende il nome della classe come stringa (es. "PlatformObject")
            string className = typeof(T).Name;

            // Puliamo il nome: togliamo "Object" o "Shape" e lo facciamo minuscolo
            string prefix = className.ToLower().Replace("object", "").Replace("shape", "");

            string randomPart = Guid.NewGuid().ToString().Substring(0, 6);

            return $"{prefix}_{randomPart}";
        }
    }
}