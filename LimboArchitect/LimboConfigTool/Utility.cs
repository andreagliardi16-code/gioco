using System.Text.RegularExpressions;


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

    public static class StringExtensions
    {
        public static string ToSnakeCase(this string input)
        {
            if (string.IsNullOrEmpty(input)) 
                return input;

            // 1. Trova i cambi di lettera da minuscola a maiuscola (es. "aB" -> "a_B")
            // o tra numeri e lettere maiuscole.
            string result = Regex.Replace(input, @"(?<!^)(?=[A-Z][a-z])|(?<=[a-z0-9])(?=[A-Z])", "_");

            // 2. Sostituisce eventuali spazi o trattini con un underscore
            result = Regex.Replace(result, @"[\s-]+", "_");

            // 3. Converte tutto in minuscolo
            return result.ToLower();
        }
    }
}