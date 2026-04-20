#ifndef SDF_RAYMARCH_INCLUDED
#define SDF_RAYMARCH_INCLUDED

#include "Assets/Shaders Resources/Includes/SDF/SDF_Shapes.hlsl"
#include "Assets/Shaders Resources/Includes/SDF/SDF_Operations.hlsl"

struct SceneContext
{
    float3 positionOffset;
    float  overallScale;
    float  animationTimescale;
    float  smallShapesSize;
    float  smoothness;
    float  unionSmoothness;
    float  intersectionSmoothness;
    float  subtractionSmoothness;
    float3 moveScale;
    float3 conePos;
    float2 coneSize;
};

float GetDist(float3 p, SceneContext ctx)
{
    p -= ctx.positionOffset;
    p /= ctx.overallScale; // ← scale space DOWN (makes scene appear bigger)
    
    float t = _Time.y * ctx.animationTimescale;

    float3 s1 = float3(sin(t* .337), sin(t* .428), sin(t*-.989));
    float3 s2 = float3(sin(t*-.214), sin(t*-.725), sin(t* .560));
    float3 s3 = float3(sin(t*-.671), sin(t* .272), sin(t* .773));
    float3 s4 = float3(sin(t*-.9),   sin(t*-.1),   sin(t* .256));
    float3 s5 = float3(sin(t*-.5),   sin(t* .645), sin(t* .456));

    float sp1 = sdSphere(p - s1 * ctx.moveScale, ctx.smallShapesSize * 0.50);
    float sp2 = sdSphere(p - s2 * ctx.moveScale, ctx.smallShapesSize * 0.75);
    float sp3 = sdSphere(p - s3 * ctx.moveScale, ctx.smallShapesSize       );
    float sp4 = sdSphere(p - s4 * ctx.moveScale, ctx.smallShapesSize * 0.25);
    float sp5 = sdSphere(p - s5 * ctx.moveScale, ctx.smallShapesSize * 0.60);
    float spBase = sdSphere(p, 0.8);

    float d;
    d = opSmoothUnion(sp1, sp2, ctx.unionSmoothness);
    d = opSmoothUnion(d,   sp3, ctx.unionSmoothness);
    d = opSmoothUnion(d,   sp4, ctx.unionSmoothness);
    d = opSmoothUnion(d,   sp5, ctx.unionSmoothness);
    d = opSmoothUnion(spBase, d, ctx.unionSmoothness);

    return d * ctx.overallScale; // ← scale distance BACK UP to fix SDF correctness
}

float3 GetNormals(float3 p, SceneContext ctx)
{
    float2 e = float2(0.01, 0.0);
    float  d = GetDist(p, ctx);
    float3 n = d - float3
    (
        GetDist(p - e.xyy, ctx),
        GetDist(p - e.yxy, ctx),
        GetDist(p - e.yyx, ctx)
    );
    return normalize(n);
}

void RayMarch_float(
    float3      rayOrigin,
    float3      rayDirection,
    float       maxSteps,
    float       maxDist,
    float       surfDist,
    SceneContext ctx,
    out float   dist,
    out float3  normal)
{
    dist = 0.0;

    for (int i = 0; i < maxSteps; i++)
    {
        float3 p          = rayOrigin + rayDirection * dist;
        float  distToScene = GetDist(p, ctx);
        dist              += distToScene;

        if (dist > maxDist || distToScene < surfDist) break;
    }

    normal = GetNormals(rayOrigin + rayDirection * dist, ctx);
}

// ---- Shader Graph entry point ----
void RayMarchScene_float(
    float3 rayOrigin,
    float3 rayDirection,
    float  maxSteps,
    float  maxDist,
    float  surfDist,
    float3 positionOffset,
    float  overallScale,
    float  animationTimescale,
    float  smallShapesSize,
    float  smoothness,
    float  unionSmoothness,
    float  intersectionSmoothness,
    float  subtractionSmoothness,
    float3 moveScale,
    out float  dist,
    out float3 normal)
{
    SceneContext ctx;
    ctx.positionOffset         = positionOffset;
    ctx.overallScale           = overallScale;
    ctx.animationTimescale     = animationTimescale;
    ctx.smallShapesSize        = smallShapesSize;
    ctx.smoothness             = smoothness;
    ctx.unionSmoothness        = unionSmoothness;
    ctx.intersectionSmoothness = intersectionSmoothness;
    ctx.subtractionSmoothness  = subtractionSmoothness;
    ctx.moveScale              = moveScale;

    RayMarch_float(rayOrigin, rayDirection,
                   maxSteps, maxDist, surfDist,
                   ctx, dist, normal);
}

#endif