#version 120

#define PI 3.14159265359
uniform vec2 resolution;
varying vec2 textureCoord;
uniform float beat;
uniform float time;
uniform sampler2D sampler0;
varying vec2 imageCoord;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform float amt = 1;

void main()
{
	gl_FragColor = texture2D(sampler0, gl_TexCoord[0].st);
}