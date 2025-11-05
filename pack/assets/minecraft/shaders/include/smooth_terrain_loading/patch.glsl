vec3 absNormal = abs(Normal);
int posNegX = 0;
int posNegY = 0;
int posNegZ = 0;
if (absNormal == vec3(1.0, 0.0, 0.0)) {
    posNegX = 1;
} else if (absNormal == vec3(0.0, 1.0, 0.0)) {
    posNegY = 1;
} else if (Normal == vec3(0.0, 0.0, -1.0)) {
    posNegZ = 1;
}
vec3 pos = Position;
if (posNegX == 1) {
    pos *= rotationMatrix(Normal.zxy, -PI);
} else if (posNegY == 1) {
    pos *= rotationMatrix(Normal.yzx, HALFPI);
} else if (posNegZ == 1) {
    pos *= rotationMatrix(Normal.yzx, -PI);
}
vec3 fractPos = fract(pos);
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
if (posNegX == 1) {
    offset *= rotationMatrix(Normal.zxy, HALFPI);
} else if (posNegY == 1) {
    offset *= rotationMatrix(Normal.yzx, -HALFPI);
} else if (posNegZ == 1) {
    offset *= rotationMatrix(Normal.yzx, PI);
}
float fading = max(0.0, length((ModelViewMat * vec4(pos + offset, 1.0)).xyz) - 95.0) ^ 2.0;
if (fading > 0) {
    float random = rollRandom((Position + offset) / 100.0);
    float animation = (sin(mod((random) * 1600.0, 6.283185307179586)) / 8.0) * 0.25;
    gl_Position = matrices * vec4(pos + offset * clamp(fading * (animation + 0.75) * 0.1 / DISTANCE, 0.0, 1.0), 1.0)
        + matrices * vec4(Normal, 0.0) * fading * (0.2 / DISTANCE * random + animation * 0.04);
}
if (fading > 15.0 * DISTANCE) {
    gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
}
