using System.Text.RegularExpressions;


namespace LimboArchitect.Core.Utils
{
    public static class IdGenerator
    {
        // Contatori di partenza per garantire l'esclusività dei range
        private static int _arcCounter = 100000;
        private static int _nodeCounter = 200000;

        public static string GenerateId<T>()
        {
            string className = typeof(T).Name;
            string prefix = className.ToLower().Replace("object", "").Replace("shape", "");
            string randomPart = Guid.NewGuid().ToString().Substring(0, 6);

            return $"{prefix}_{randomPart}";
        }

        public static int GenerateGraphId(bool is_node)
        {
            return is_node 
                ? Interlocked.Increment(ref _nodeCounter) 
                : Interlocked.Increment(ref _arcCounter);
        }
    }

    public static class StringExtensions
    {
        public static string ToSnakeCase(this string input)
        {
            if (string.IsNullOrEmpty(input)) 
                return input;

            string result = Regex.Replace(input, @"(?<!^)(?=[A-Z][a-z])|(?<=[a-z0-9])(?=[A-Z])", "_");
            result = Regex.Replace(result, @"[\s-]+", "_");
            return result.ToLower();
        }
    }
}