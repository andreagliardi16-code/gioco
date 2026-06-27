using System.Numerics;
using LimboArchitect.Core.Analyzer.Graph;


namespace LimboArchitect.Core.Analyzer.Algorithms;

public enum ConnectionType
{
    Fall = 0,
    Jump = 1,
    MaxJump = 2,
    Dash = 3,
    JumpAndDash = 4,
    Pogo = 5,
    PogoAndDash = 6,
    MaybeOther = 7,   // Quando ci saranno molti power-up sarà impossibile calcolare tutte le combinazioni di movimento
    Impossible = 8
}

public class ArcsEvaluator
{
    // calcolo il salto come parabola semplice, necessito di diversi calcoli per diversi tipi di movimento.
    private List<Vector2> ArcSteps = [];

    public (float, ConnectionType) AnalyzeArc()
    {
        
        

        throw new NotImplementedException();
    }

    public bool CalcJumpParable((int X, int Y)start, (int X, int Y)target, PlayerStatsSection stats)
    {
        float deltaX = target.X - start.X;
        float directionX = Math.Sign(deltaX);
        float totalTime = Math.Abs(deltaX) / stats.HorizontalMovement.MaxSpeed;

        const int steps = 9;
        float timeStep = totalTime/steps;

        Vector2 previousPoint = new Vector2(start.X, start.Y);
        ArcSteps.Add(previousPoint);   

        for (int i = 1; i <= steps; i++)
        {
            float t = i * timeStep;

            float currentX = start.X + (stats.HorizontalMovement.MaxSpeed * directionX * t);
            float currentY = start.Y + (stats.Jump.JumpForce * t) + (0.5f * GetRightGravity(stats.Gravity, t, totalTime) * t * t);
            
            Vector2 currentPoint = new Vector2(currentX, currentY);
            ArcSteps.Add(currentPoint);

            previousPoint = currentPoint;
        }

        if (Math.Abs(ArcSteps[^1].X) < Math.Abs(target.X))
        {
            // Il salto è troppo corto
            ArcSteps.Clear();
            return false;
        }
        else
        {
            return true;
        }
    }

    private static float GetRightGravity(GravitySection gravSection, float t, float totalTime)
    {
        if (t > totalTime/2) return gravSection.DefaultGravity;
        else return gravSection.FallGravity;
    }
}