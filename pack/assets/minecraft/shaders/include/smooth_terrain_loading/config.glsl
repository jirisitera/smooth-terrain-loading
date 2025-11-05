#define DISTANCE 50.0
#define PI 3.141592653589793238
#define HALFPI 1.570796326794896619
float rollRandom(vec3 seed) {
    return fract(sin(dot(seed.xyz, vec3(12.9898,78.233,144.7272))) * 43758.5453);
}
mat3 rotationMatrix(vec3 axis, float angle) {
    vec3 normalAxis = normalize(axis);
    float sine = sin(angle);
    float cosine = cos(angle);
    float negCos = 1.0 - cosine;
    float axisX = normalAxis.x;
    float axisY = normalAxis.y;
    float axisZ = normalAxis.z;
    return mat3(
        negCos * axisX * axisX + cosine,       negCos * axisX * axisY - axisZ * sine, negCos * axisZ * axisX + axisY * sine,
        negCos * axisX * axisY + axisZ * sine, negCos * axisY * axisY + cosine,       negCos * axisY * axisZ - axisX * sine,
        negCos * axisZ * axisX - axisY * sine, negCos * axisY * axisZ + axisX * sine, negCos * axisZ * axisZ + cosine
    );
}
