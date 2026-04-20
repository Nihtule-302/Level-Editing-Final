#ifndef SDF_SHAPES_INCLUDED
#define SDF_SHAPES_INCLUDED

// ---- all primitives centered at origin ----
// caller is responsible for: p = worldP - shapePosition

float sdSphere(float3 p, float r)
{
    return length(p) - r;
}

float sdBox(float3 p, float3 halfExtents)
{
    float3 q = abs(p) - halfExtents;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCapsule(float3 p, float h, float r)
{
    p.y -= clamp(p.y, 0.0, h);
    return length(p) - r;
}

float sdTorus(float3 p, float2 t)
{
    // t.x = major radius, t.y = minor radius
    float2 q = float2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}

float sdCone(float3 p, float2 q)
{
    p.y = -(p.y - q.y); // shift base to origin, flip direction
    
    float2 w = float2(length(p.xz), p.y);
    float2 a = w - q * clamp(dot(w, q) / dot(q, q), 0.0, 1.0);
    float2 b = w - q * float2(clamp(w.x / q.x, 0.0, 1.0), 1.0);
    float  k = sign(q.y);
    float  d = min(dot(a, a), dot(b, b));
    float  s = max(k * (w.x * q.y - w.y * q.x), k * (w.y - q.y));
    return sqrt(d) * sign(s);
}

float sdCylinder(float3 p, float h, float r)
{
    float2 d = abs(float2(length(p.xz), p.y)) - float2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}


// ---- Shader Graph node wrappers ---- // unity needs the methods to have "_type" at the end so i made wrappers 
//these are what i will use if i want to call them from shader graph
//while the one on the top i will use them in other scripts

void SdSphere_float(float3 p, float3 position, float r, out float dist)
{
    dist = sdSphere(p - position, r);
}

void SdBox_float(float3 p, float3 position, float3 halfExtents, out float dist)
{
    dist = sdBox(p - position, halfExtents);
}

void SdTorus_float(float3 p, float3 position, float majorR, float minorR, out float dist)
{
    dist = sdTorus(p - position, float2(majorR, minorR));
}

void SdCone_float(float3 p, float3 position, float2 q, out float dist)
{
    dist = sdCone(p - position, q);
}

void SdCylinder_float(float3 p, float3 position, float h, float r, out float dist)
{
    dist = sdCylinder(p - position, h, r);
}

#endif