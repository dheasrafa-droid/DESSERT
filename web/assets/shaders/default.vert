#version 300 es
precision highp float;

in vec3 aPosition;
in vec3 aNormal;
in vec4 aColor;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

out vec3 vNormal;
out vec4 vColor;
out vec3 vPosition;

void main() {
    vec4 worldPosition = uModelMatrix * vec4(aPosition, 1.0);
    vec4 viewPosition = uViewMatrix * worldPosition;
    gl_Position = uProjectionMatrix * viewPosition;
    
    vNormal = normalize(mat3(uModelMatrix) * aNormal);
    vColor = aColor;
    vPosition = worldPosition.xyz;
}
