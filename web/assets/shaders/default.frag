#version 300 es
precision highp float;

in vec3 vNormal;
in vec4 vColor;
in vec3 vPosition;

uniform vec3 uCameraPosition;
uniform vec3 uLightPosition;
uniform vec3 uLightColor;
uniform float uAmbientStrength;

out vec4 fragColor;

void main() {
    // Ambient lighting
    vec3 ambient = uAmbientStrength * uLightColor;
    
    // Diffuse lighting
    vec3 norm = normalize(vNormal);
    vec3 lightDir = normalize(uLightPosition - vPosition);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * uLightColor;
    
    // Specular lighting
    vec3 viewDir = normalize(uCameraPosition - vPosition);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = 0.5 * spec * uLightColor;
    
    // Combine
    vec3 result = (ambient + diffuse + specular) * vColor.rgb;
    fragColor = vec4(result, vColor.a);
}
