#ifndef SDF_OPERATIONS_INCLUDED
#define SDF_OPERATIONS_INCLUDED

// ---- internal versions (used inside other .hlsl files) ----

float opUnion(float a, float b)
{
    return min(a, b);
}

float opSubtraction(float a, float b)
{
    return max(-a, b);
}

float opIntersection(float a, float b)
{
    return max(a, b);
}

float opSmoothUnion(float a, float b, float k)
{
    k *= 4.0;
    float h = max(k - abs(a - b), 0.0);
    return min(a, b) - h * h * 0.25 / k;
}

float opSmoothSubtraction(float a, float b, float k)
{
    return -opSmoothUnion(a,-b,k);
}

float opSmoothIntersection(float a, float b, float k)
{
    return -opSmoothUnion(-a, -b, k); // negation trick is valid here
}


// ---- Shader Graph node wrappers (out param versions) ----

void Union_float(float a, float b, out float dist)
{
    dist = opUnion(a, b);
}

void Subtraction_float(float a, float b, out float dist)
{
    dist = opSubtraction(a, b);
}

void Intersection_float(float a, float b, out float dist)
{
    dist = opIntersection(a, b);
}

void SmoothUnion_float(float a, float b, float k, out float dist)
{
    dist = opSmoothUnion(a, b, k);
}

void SmoothSubtraction_float(float a, float b, float k, out float dist)
{
    dist = opSmoothSubtraction(a, b, k);
}

void SmoothIntersection_float(float a, float b, float k, out float dist)
{
    dist = opSmoothIntersection(a, b, k);
}

#endif