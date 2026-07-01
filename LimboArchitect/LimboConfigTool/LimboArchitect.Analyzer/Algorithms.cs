using System.Numerics;


namespace LimboArchitect.Core.Analyzer.Algorithms;

public enum ConnectionType
{
    Fall = 0,
    Jump = 1,
    MaxJump = 2,
    Dash = 3,
    JumpAndDash = 4,
    DashAndFall =5,
    VertPogo = 6,
    LatPogo = 7,
    PogoAndDash = 8,
    MaybeOther = 9,
    Impossible = 10
}

public static class ArcsEvaluator
{
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
        float maxSpeed = stats.HorizontalMovement.MaxSpeed*MagicNumbers.ShortJumpHCoeff;
        List<Vector2> arcSteps = CalcJumpPoints(start, target, maxSpeed, stats.Jump.FakeJumpForce, stats.Gravity);

        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f; 

        return isValid ? (arcSteps, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcMaxJumpParable((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        List<Vector2> arcSteps = CalcJumpPoints(start, target, stats.HorizontalMovement.MaxSpeed, stats.Jump.JumpForce, stats.Gravity);

        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f; 

        return isValid ? (arcSteps, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcDash((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        float deltaX = target.X - start.X;
        float directionX = Math.Sign(deltaX);

        float baseDashLength = directionX*stats.Dash.DashSpeedAmt*stats.Dash.DashTime;

        var startPoint = new Vector2(start.X, start.Y);
        var endPoint = new Vector2(baseDashLength + start.X, start.Y);

        var Segment = new List<Vector2> {startPoint, endPoint};

        bool isValid = (baseDashLength + start.X) <= target.X + 5.0f; 

        return isValid ? (Segment, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcVertPogo((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        float maxSpeed = stats.HorizontalMovement.MaxSpeed * MagicNumbers.VertPogoCoeff;

        
        List<Vector2> arcSteps = CalcJumpPoints(start, target, maxSpeed, stats.Pogo.VerticalForce, stats.Gravity);


        bool isValid = arcSteps[^1].Y <= target.Y + 5.0f;
        return isValid ? (arcSteps, true) : ([], false);
    }

    private static (List<Vector2>, bool) CalcLatPogo((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        
    }

/* La logica che calcola il salto "corto" va rivista. Un salto più breve non ha semplicemente velocità minore, ma anche un apice più basso
una forma effettivamente diversa. */
    private static List<Vector2> CalcJumpPoints((int X, int Y)start, (int X, int Y)target, float maxSpeed, float jumpForce, GravitySection gravity)
    {
        List<Vector2> Steps = [];

        float deltaX = target.X - start.X;
        float directionX = Math.Sign(deltaX);
        float totalTime = Math.Abs(deltaX) / maxSpeed;

        const int steps = 9;
        float timeStep = totalTime/steps;

        Vector2 previousPoint = new Vector2(start.X, start.Y);
        Steps.Add(previousPoint);

        for (int i = 1; i <= steps; i++)
        {
            float t = i * timeStep;

            float currentX = start.X + (maxSpeed * directionX * t);
            float currentY = start.Y + (jumpForce * t) + (0.5f * GetRightGravity(gravity, jumpForce, t) * t * t);
            
            Vector2 currentPoint = new Vector2(currentX, currentY);
            Steps.Add(currentPoint);

            previousPoint = currentPoint;
        }

        return Steps;
    }

// TODO: controllare giuste variabili gravità
    private static float GetRightGravity(GravitySection gravSection, float jumpForce, float t)
    {
        float apexTime = Math.Abs(jumpForce) / gravSection.DefaultGravity;
        if (t < apexTime) return gravSection.DefaultGravity;
        else return gravSection.FallGravity;
    }
}