#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp(uv / 256.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0)));
}

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

void main() {
    mat4 matrices = ProjMat * ModelViewMat;

    vec3 pos = Position + ModelOffset;
    gl_Position = matrices * (vec4(pos, 1.0));
    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;

    vec3 absNormal = abs(Normal);
    int PosNegX = 0;
    int PosNegY = 0;
    int PosNegZ = 0;
    if (absNormal == vec3(1.0, 0.0, 0.0)) {
        PosNegX = 1;
    } else if (absNormal == vec3(0.0, 1.0, 0.0)) {
        PosNegY = 1;
    } else if (Normal == vec3(0.0, 0.0, -1.0)) {
        PosNegZ = 1;
    }
    vec3 fractPos = Position;
    if (PosNegX == 1) {
        fractPos *= rotationMatrix(Normal.zxy, -HALFPI);
    }
    else if (PosNegY == 1) {
        fractPos *= rotationMatrix(Normal.yzx, HALFPI);
    }
    else if (PosNegZ == 1) {
        fractPos *= rotationMatrix(Normal.yzx, -PI);
    }
    fractPos = fract(fractPos);
    float fractPosX = fractPos.x;
    float fractPosY = fractPos.y;
    vec3 offset = vec3(0.5, 0.5, 0.0);
    float offsetX = offset.x;
    float offsetY = offset.y;
    if (fractPosX > 0.001 && fractPosX < 0.999) {
        offset.x = 0.5 - fractPosX;
    }
    if (fractPosY > 0.001 && fractPosY < 0.999) {
        offset.y = 0.5 - fractPosY;
    }
    float vertexId = mod(gl_VertexID, 4.0);
    if (vertexId == 0.0 && offsetY == 0.5) {
        offset.y *= -1.0;
    } else if (vertexId == 2.0 && offsetX == 0.5) {
        offset.x *= -1.0;
    } else if (vertexId == 3.0) {
        if (offsetX == 0.5) {
            offset.x *= -1.0;
        }
        if (offsetY == 0.5) {
            offset.y *= -1.0;
        }
    }
    if (PosNegX == 1) {
        offset *= rotationMatrix(Normal.zxy, HALFPI);
    }
    else if (PosNegY == 1) {
        offset *= rotationMatrix(Normal.yzx, -HALFPI);
    }
    else if (PosNegZ == 1) {
        offset *= rotationMatrix(Normal.yzx, PI);
    }
    float fade = max(0.0, length((ModelViewMat * vec4(pos + offset, 1.0)).xyz) - 95.0);
    fade *= fade;
    if (fade > 0) {
        float random = rollRandom((Position + offset) / 100.0);
        float animation = (sin(mod((random) * 1600.0, 6.283185307179586)) / 8.0) * 0.25;
        gl_Position = matrices * vec4(pos + offset * clamp(fade * (animation + 0.75) * 0.1 / DISTANCE, 0.0, 1.0), 1.0) + matrices * vec4(Normal, 0.0) * fade * (0.2 / DISTANCE * random + animation * 0.04);
    }
    if (fade > 15.0 * DISTANCE) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}
