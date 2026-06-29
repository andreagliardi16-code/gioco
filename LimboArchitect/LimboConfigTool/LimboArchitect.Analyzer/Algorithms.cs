using System.Numerics;


namespace LimboArchitect.Core.Analyzer.Algorithms;

public enum ConnectionType
{
    Fall = 0,
    Jump = 1,
    MaxJump = 2,
    ShortDash = 9,
    Dash = 3,
    JumpAndDash = 4,
    Pogo = 5,
    PogoAndDash = 6,
    MaybeOther = 7,
    Impossible = 8
}

public static class ArcsEvaluator
{
    // il numero di controlli da fare
    private const int checks_num = 7;

    public static (float, ConnectionType) AnalyzeArc()
    {
        throw new NotImplementedException();
    }

    private static (List<Vector2>, bool) CalcFall((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        List<Vector2> arcSteps = [];

        float deltaX = target.X - start.X;
        float directionX = Math.Sign(deltaX);
        float totalTime = Math.Abs(deltaX) / stats.HorizontalMovement.MaxSpeed;

        const int steps = 7;
        float timeStep = totalTime/steps;

        Vector2 previousPoint = new Vector2(start.X, start.Y);
        arcSteps.Add(previousPoint);

        for (int i = 1; i <= steps; i++)
        {
            float t = i * timeStep;

            float currentX = start.X + (stats.HorizontalMovement.MaxSpeed * directionX * t);
            float currentY = start.Y + (0.5f * stats.Gravity.FallGravity * t * t);
            
            Vector2 currentPoint = new Vector2(currentX, currentY);
            arcSteps.Add(currentPoint);

            previousPoint = currentPoint;
        }

        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f; 

        return isValid ? (arcSteps, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcJumpParable((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        List<Vector2> arcSteps = CalcJumpPoints(start, target, stats);

        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f; 

        return isValid ? (arcSteps, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcMaxJumpParable((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        List<Vector2> arcSteps = CalcJumpPoints(start, target, stats, maxJump: true);

        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f; 

        return isValid ? (arcSteps, true) : ([], false);
    }

    private static List<Vector2> CalcJumpPoints((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats, bool maxJump = false)
    {
        List<Vector2> Steps = [];

        float maxSpeed = (maxJump)? stats.HorizontalMovement.MaxSpeed : stats.HorizontalMovement.MaxSpeed/2;
        float deltaX = target.X - start.X;
        float directionX = Math.Sign(deltaX);
        float totalTime = Math.Abs(deltaX) / stats.HorizontalMovement.MaxSpeed;

        const int steps = 9;
        float timeStep = totalTime/steps;

        Vector2 previousPoint = new Vector2(start.X, start.Y);
        Steps.Add(previousPoint);

        for (int i = 1; i <= steps; i++)
        {
            float t = i * timeStep;

            float currentX = start.X + (maxSpeed * directionX * t);
            float currentY = start.Y + (stats.Jump.JumpForce * t) + (0.5f * GetRightGravity(stats.Gravity, t, totalTime) * t * t);
            
            Vector2 currentPoint = new Vector2(currentX, currentY);
            Steps.Add(currentPoint);

            previousPoint = currentPoint;
        }

        return Steps;
    }

// TODO: controllare giuste variabili gravità
    private static float GetRightGravity(GravitySection gravSection, float t, float totalTime)
    {
        // TempoApice = ValoreAssoluto(JumpForce) / DefaultGravity
        if (t < totalTime/2) return gravSection.DefaultGravity;
        else return gravSection.FallGravity;
    }
}