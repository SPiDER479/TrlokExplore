//<sss_checksum>3EEADC98</sss_checksum>
Shader "Space Graphics Toolkit/OceanDebris"
{
Properties
{



	[HideInInspector] [NoScaleOffset] _SGT_MainTex("", 2D) = "white" {}
	[HideInInspector] _SGT_Cells("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Roll("", Float) = 0
	[HideInInspector] _SGT_WrapSize("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataA("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataB("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Offset("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_UnderwaterBrightness("", Float) = 0
	[HideInInspector] _SGT_UnderwaterShadowRange("", Float) = 0
	
	[Header(CLOUDS)]
	[Toggle(_SGT_CLOUDS)] _SGT_Clouds("	Enable", Float) = 0
	[HideInInspector] [NoScaleOffset] _SGT_CloudTex("", 2D) = "black" {}
	[HideInInspector] _SGT_CloudOpacity("", Vector) = (0.0, 0.0, 0.0, 0.0)
	[HideInInspector] _SGT_CloudWarp("", Float) = 0


[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
[HideInInspector]_QueueControl("_QueueControl", Float) = -1
[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
[HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
[HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
}
SubShader
{
Tags
{
"RenderPipeline"="UniversalPipeline"
"RenderType"="Transparent"
"UniversalMaterialType" = "Unlit"
"Queue"="Transparent"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalUnlitSubTarget"
}





Pass
{
    Name "Universal Forward"
    Tags
    {
        // LightMode: <None>
    }

// Render State
Cull Back
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_UNIVERSAL_FORWARD 1

#define _SSS_URP 1


// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma shader_feature _ _SAMPLE_GI
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define _FOG_FRAGMENT 1
#define _SURFACE_TYPE_TRANSPARENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "MotionVectors"
    Tags
    {
        "LightMode" = "MotionVectors"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask RG

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_MOTIONVECTORS 1

#define _SSS_URP 1


// Pragmas
#pragma target 3.5
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_MOTION_VECTORS


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthNormalsOnly"
    Tags
    {
        "LightMode" = "DepthNormalsOnly"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_DEPTHNORMALSONLY 1

#define _SSS_URP 1


// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
#define _SURFACE_TYPE_TRANSPARENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

// Render State
Cull Back
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_GBUFFER 1

#define _SSS_URP 1


// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles3 glcore
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile _ SHADOWS_SHADOWMASK
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _SURFACE_TYPE_TRANSPARENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP0;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP1;
#endif
 float4 tangentWS : INTERP2;
 float4 texCoord0 : INTERP3;
 float4 texCoord1 : INTERP4;
 float4 extraV2F0 : INTERP5;
 float4 extraV2F1 : INTERP6;
 float3 positionWS : INTERP7;
 float3 normalWS : INTERP8;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_SCENESELECTIONPASS 1

#define _SSS_URP 1


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Back

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_SCENEPICKINGPASS 1

#define _SSS_URP 1


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

#ifdef HAVE_VFX_MODIFICATION
#if VFX_USE_GRAPH_VALUES
    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
#endif
    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

#endif

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
}
SubShader
{
Tags
{
// RenderPipeline: <None>
"RenderType"="Transparent"
"BuiltInMaterialType" = "Unlit"
"Queue"="Transparent"
// DisableBatching: <None>
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="BuiltInUnlitSubTarget"
}
Pass
{
    Name "Pass"
    Tags
    {
        "LightMode" = "ForwardBase"
    }

// Render State
Cull Back
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite Off
ColorMask RGB

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_PASS 1

#define _SSS_BIRP 1


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





CBUFFER_END


// Object and Global properties

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.texcoord   = attributes.uv0;
    result.texcoord1  = attributes.uv1;
    result.texcoord2  = attributes.uv2;
    result.texcoord3  = attributes.uv3;
    result.color      = attributes.color;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    result.instanceID = attributes.instanceID;
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    result.worldPos = varyings.positionWS;
    result.worldNormal = varyings.normalWS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    result.positionWS = surfVertex.worldPos;
    result.normalWS = surfVertex.worldNormal;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Back
Blend SrcAlpha One, One One
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_SHADOWCASTER 1

#define _SSS_BIRP 1


// Pragmas
#pragma target 3.0
#pragma multi_compile_shadowcaster
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





CBUFFER_END


// Object and Global properties

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.texcoord   = attributes.uv0;
    result.texcoord1  = attributes.uv1;
    result.texcoord2  = attributes.uv2;
    result.texcoord3  = attributes.uv3;
    result.color      = attributes.color;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    result.instanceID = attributes.instanceID;
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    result.worldPos = varyings.positionWS;
    result.worldNormal = varyings.normalWS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    result.positionWS = surfVertex.worldPos;
    result.normalWS = surfVertex.worldNormal;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_SCENESELECTIONPASS 1

#define _SSS_BIRP 1


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SceneSelectionPass
#define BUILTIN_TARGET_API 1
#define SCENESELECTIONPASS 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





CBUFFER_END


// Object and Global properties

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.texcoord   = attributes.uv0;
    result.texcoord1  = attributes.uv1;
    result.texcoord2  = attributes.uv2;
    result.texcoord3  = attributes.uv3;
    result.color      = attributes.color;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    result.instanceID = attributes.instanceID;
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    result.worldPos = varyings.positionWS;
    result.worldNormal = varyings.normalWS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    result.positionWS = surfVertex.worldPos;
    result.normalWS = surfVertex.worldNormal;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Back

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_SCENEPICKINGPASS 1

#define _SSS_BIRP 1


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TEXCOORD3
#define ATTRIBUTES_NEED_COLOR
#define ATTRIBUTES_NEED_INSTANCEID
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS ScenePickingPass
#define BUILTIN_TARGET_API 1
#define SCENEPICKINGPASS 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
#define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
#endif
#ifdef _BUILTIN_ALPHATEST_ON
#define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
#endif
#ifdef _BUILTIN_AlphaClip
#define _AlphaClip _BUILTIN_AlphaClip
#endif
#ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
#define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
#endif


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
 float4 uv3 : TEXCOORD3;
 float4 color : COLOR;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
 float4 texCoord0;
 float4 texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
 float4 extraV2F0;
 float4 extraV2F1;
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
 float4 extraV2F1;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
 float4 uv0;
 float4 uv1;
 float4 uv2;
 float4 uv3;
 float4 VertexColor;
 uint InstanceID;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float4 texCoord0 : INTERP1;
 float4 texCoord1 : INTERP2;
 float4 extraV2F0 : INTERP3;
 float4 extraV2F1 : INTERP4;
 float3 positionWS : INTERP5;
 float3 normalWS : INTERP6;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.extraV2F0.xyzw = input.extraV2F0;
output.extraV2F1.xyzw = input.extraV2F1;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
output.extraV2F1 = input.extraV2F1.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)





CBUFFER_END


// Object and Global properties

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Includes
// UNITY_SHADER_NO_UPGRADE
float3 SSS_HClipToScreen(float4 v)
{
	float3 uv = v.xyz / v.w;
	#if UNITY_UV_STARTS_AT_TOP
		uv.y = -uv.y;
	#endif
	uv.xy = uv.xy * 0.5 + 0.5;
	return uv;
}

#if _SSS_HDRP
	float3 SSS_WorldToAbsolute(float3 v) { return GetAbsolutePositionWS(v); }
	float3 SSS_AbsoluteToWorld(float3 v) { return GetCameraRelativePositionWS(v); }
#else
	float3 SSS_WorldToAbsolute(float3 v) { return v; }
	float3 SSS_AbsoluteToWorld(float3 v) { return v; }
#endif

float3 SSS_WorldToView(float3 v) { return TransformWorldToView(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToObject(float3 v) { return TransformWorldToObject(SSS_AbsoluteToWorld(v)); }
float3 SSS_WorldToScreen(float3 v) { return SSS_HClipToScreen(TransformWorldToHClip(SSS_AbsoluteToWorld(v))); }
float3 SSS_ObjectToScreen(float3 v) { return SSS_HClipToScreen(TransformObjectToHClip(v)); }
float3 SSS_ObjectToWorld(float3 v) { return SSS_WorldToAbsolute(TransformObjectToWorld(v)); }
float3 SSS_ObjectToView(float3 v) { return TransformWorldToView(TransformObjectToWorld(v)); }
float3 SSS_ScreenToWorld(float3 v) { return SSS_WorldToAbsolute(ComputeWorldSpacePosition(v.xy, v.z, UNITY_MATRIX_I_VP)); }
float3 SSS_ScreenToObject(float3 v) { return SSS_WorldToObject(SSS_ScreenToWorld(v)); }
float3 SSS_ScreenToView(float3 v) { return SSS_WorldToView(SSS_ScreenToWorld(v)); }
float3 SSS_ViewToWorld(float3 v) { return mul(UNITY_MATRIX_I_V, float4(v, 1.0)).xyz; }
float3 SSS_ViewToObject(float3 v) { return TransformWorldToObject(SSS_ViewToWorld(v)); }
float3 SSS_ViewToScreen(float3 v) { return SSS_HClipToScreen(TransformWViewToHClip(v)); }
float3 SSS_ObjectToWorldDir(float3 v)
{
	#if _SSS_BIRP
		return TransformObjectToWorldDir(v);
	#else
		return TransformObjectToWorldDir(v, true);
	#endif
}
float3 SSS_ObjectToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(TransformObjectToWorldDir(v));
	#else
		return TransformWorldToViewDir(TransformObjectToWorldDir(v, false), true);
	#endif
}
float3 SSS_WorldToObjectDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToObjectDir(v);
	#else
		return TransformWorldToObjectDir(v, true);
	#endif
}
float3 SSS_WorldToViewDir(float3 v)
{
	#if _SSS_BIRP
		return TransformWorldToViewDir(v);
	#else
		return TransformWorldToViewDir(v, true);
	#endif
}
float3 SSS_ViewToObjectDir(float3 v)
{
	#if _SSS_URP || _SSS_HDRP
		return SSS_WorldToObjectDir(mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz);
	#else
		return SSS_WorldToObjectDir(mul((float3x3)UNITY_MATRIX_I_V, v));
	#endif
}
float3 SSS_ViewToWorldDir(float3 v)
{
	return mul(UNITY_MATRIX_I_V, float4(v, 0.0)).xyz;
}

#if _SSS_NO_DERIVATIVES
	float3 SSS_GetSceneColor(float2 uv) { return float3(0.0, 0.0, 0.0); }
	float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	float  SSS_GetSceneDepth(float2 uv) { return 0.0; }
#else
	#if _SSS_URP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#elif _SSS_HDRP
		float3 SSS_GetSceneColor(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_COLOR(uv).xyz; }
		float3 SSS_GetSceneColorHD(float2 uv)
		{
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(_SURFACE_TYPE_TRANSPARENT) && defined(SHADERPASS) && (SHADERPASS != SHADERPASS_LIGHT_TRANSPORT) && (SHADERPASS != SHADERPASS_PATH_TRACING) && (SHADERPASS != SHADERPASS_RAYTRACING_VISIBILITY) && (SHADERPASS != SHADERPASS_RAYTRACING_FORWARD)
			return SampleCameraColor(uv, 0);
			#endif
			#if defined(REQUIRE_OPAQUE_TEXTURE) && defined(CUSTOM_PASS_SAMPLING_HLSL) && defined(SHADERPASS) && (SHADERPASS == SHADERPASS_DRAWPROCEDURAL || SHADERPASS == SHADERPASS_BLIT)
			return CustomPassSampleCameraColor(uv, 0);
			#endif
			return float3(0.0, 0.0, 0.0);
		}
	#else
		#if defined(UNITY_DECLARE_OPAQUE_TEXTURE_INCLUDED)
			float3 SSS_GetSceneColor(float2 uv) { return SampleSceneColor(uv); }
		#else
			sampler2D _CameraOpaqueTexture; float3 SSS_GetSceneColor(float2 uv) { return tex2D(_CameraOpaqueTexture, uv).xyz; }
		#endif
		float3 SSS_GetSceneColorHD(float2 uv) { return SSS_GetSceneColor(uv); }
	#endif

	float SSS_GetSceneDepth(float2 uv) { return SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv); }
#endif

float3 SSS_GetSceneWorldPosition(float2 screenUV, float sceneDepth)
{
	#if _SSS_BIRP
		float4 clipPos  = float4(screenUV * 2.0f - 1.0f, 0.0f, 1.0f);
		float4 viewPos  = mul(unity_CameraInvProjection, clipPos);
		float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewPos.xyz);
					
		return _WorldSpaceCameraPos + worldDir * LinearEyeDepth(sceneDepth);
	#else
		float4 clipPos = float4(screenUV * 2.0 - 1.0, sceneDepth, 1.0);
					
		#if UNITY_UV_STARTS_AT_TOP
			clipPos.y = -clipPos.y;
		#endif
					
		float4 worldPos = mul(UNITY_MATRIX_I_VP, clipPos);
					
		worldPos.xyz /= worldPos.w;
					
		#if _SSS_HDRP
			worldPos.xyz = GetAbsolutePositionWS(worldPos.xyz);
		#endif
					
		return worldPos.xyz;
	#endif
}

float SSS_GetSceneWorldDistance(float2 screenUV, float sceneDepth)
{
	return distance(_WorldSpaceCameraPos, SSS_GetSceneWorldPosition(screenUV, sceneDepth));
}

struct SSS_VertexData
{
	float  instanceID;
	float3 position;
	float3 normal;
	float3 tangent;
	float4 color;
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;
	



};

struct SSS_FragmentData
{
	float3 localSpacePosition;
	float3 localSpaceNormal;
	float3 localSpaceTangent;
	
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceTangent;
	//float tangentSign;

	float3 worldSpaceViewDir;
	//float3 tangentSpaceViewDir;
	
	float4 texcoord0;
	float4 texcoord1;
	float4 texcoord2;
	float4 texcoord3;
	
	float2 screenUV;
	float4 screenPos;

	float4 vertexColor;
	bool isFrontFace;
	
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 extraV2F3;
	float4 extraV2F4;
	float4 extraV2F5;
	float4 extraV2F6;
	float4 extraV2F7;

	float3x3 TBNMatrix;
	



};

struct SSS_SurfaceData
{
	float3 Albedo;
	float  Smoothness;
	float3 Normal;
	float3 Emission;
	float  Occlusion;
	float  Metallic;
	float  Alpha;
};

#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}
float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ��_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}







sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
		
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - cameraDistance * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}


void Vert_float
	(
	float  iInstanceID,
	float3 iPosition,
	float3 iNormal,
	float3 iTangent,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,

	out float3 oPosition,
	out float3 oNormal,
	out float3 oTangent,
	out float4 oExtraV2F0,
	out float4 oExtraV2F1,
	out float4 oExtraV2F2,
	out float4 oExtraV2F3,
	out float4 oExtraV2F4,
	out float4 oExtraV2F5,
	out float4 oExtraV2F6,
	out float4 oExtraV2F7
	)
{
	SSS_VertexData v = (SSS_VertexData)0;
	
	v.instanceID = iInstanceID;
	v.position   = iPosition;
	v.normal     = iNormal;
	v.tangent    = iTangent;
	v.color      = iColor;
	v.texcoord0  = iTexcoord0;
	v.texcoord1  = iTexcoord1;
	v.texcoord2  = iTexcoord2;
	v.texcoord3  = iTexcoord3;
	v.extraV2F0  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F1  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F2  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F3  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F4  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F5  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F6  = float4(0.0, 0.0, 0.0, 0.0);
	v.extraV2F7  = float4(0.0, 0.0, 0.0, 0.0);
	
	SSS_Vert(v);
	
	oPosition  = v.position;
	oNormal    = v.normal;
	oTangent   = v.tangent;
	oExtraV2F0 = v.extraV2F0;
	oExtraV2F1 = v.extraV2F1;
	oExtraV2F2 = v.extraV2F2;
	oExtraV2F3 = v.extraV2F3;
	oExtraV2F4 = v.extraV2F4;
	oExtraV2F5 = v.extraV2F5;
	oExtraV2F6 = v.extraV2F6;
	oExtraV2F7 = v.extraV2F7;
}

void Frag_float
	(
	inout float3 iPosition,
	inout float3 iNormal,
	inout float3 iTangent,
	bool   iIsFrontFace,
	float4 iColor,
	float4 iTexcoord0,
	float4 iTexcoord1,
	float4 iTexcoord2,
	float4 iTexcoord3,
	float4 iExtraV2F0,
	float4 iExtraV2F1,
	float4 iExtraV2F2,
	float4 iExtraV2F3,
	float4 iExtraV2F4,
	float4 iExtraV2F5,
	float4 iExtraV2F6,
	float4 iExtraV2F7,

	out float4x4 oExtra,
	out float3   oAlbedo,
	out float    oSmoothness,
	out float3   oNormal,
	out float3   oEmission,
	out float    oOcclusion,
	out float    oMetallic,
	out float    oAlpha
	)
{
	SSS_SurfaceData  s = (SSS_SurfaceData)0;
	SSS_FragmentData d = (SSS_FragmentData)0;
	
	s.Albedo = 1.0;
	s.Smoothness = 0.5;
	s.Normal = float3(0.0, 0.0, 1.0);
	s.Emission = float3(0.0, 0.0, 0.0);
	s.Occlusion = 0.0;
	s.Metallic = 0.0;
	s.Alpha = 1.0;
	
	iPosition = SSS_WorldToAbsolute(iPosition);
	
	d.localSpacePosition = SSS_WorldToObject(iPosition);
	d.localSpaceNormal   = normalize(SSS_WorldToObjectDir(iNormal));
	d.localSpaceTangent  = normalize(SSS_WorldToObjectDir(iTangent));
	
	d.worldSpacePosition = iPosition;
	d.worldSpaceNormal   = iNormal;
	d.worldSpaceTangent  = iTangent;
	//d.tangentSign;
	
	d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	//d.tangentSpaceViewDir;
	
	d.texcoord0 = iTexcoord0;
	d.texcoord1 = iTexcoord1;
	d.texcoord2 = iTexcoord2;
	d.texcoord3 = iTexcoord3;
	
	d.screenPos = float4(SSS_WorldToScreen(iPosition), 1.0);
	d.screenUV  = d.screenPos.xy;

	d.vertexColor = iColor;
	d.isFrontFace = iIsFrontFace;
	
	d.extraV2F0 = iExtraV2F0;
	d.extraV2F1 = iExtraV2F1;
	d.extraV2F2 = iExtraV2F2;
	d.extraV2F3 = iExtraV2F3;
	d.extraV2F4 = iExtraV2F4;
	d.extraV2F5 = iExtraV2F5;
	d.extraV2F6 = iExtraV2F6;
	d.extraV2F7 = iExtraV2F7;

	d.TBNMatrix = float3x3(d.worldSpaceTangent, normalize(cross(d.worldSpaceNormal, d.worldSpaceTangent)), d.worldSpaceNormal);
	
	SSS_Frag(s, d);
	
	iPosition = SSS_AbsoluteToWorld(d.worldSpacePosition); iNormal = d.worldSpaceNormal; iTangent = d.worldSpaceTangent; // Write back
	
	oExtra      = float4x4(d.extraV2F0, d.extraV2F1, d.extraV2F2, d.extraV2F3);
	oAlbedo     = s.Albedo;
	oSmoothness = s.Smoothness;
	oNormal     = s.Normal;
	oEmission   = s.Emission;
	oOcclusion  = s.Occlusion;
	oMetallic   = s.Metallic;
	oAlpha      = s.Alpha;
}



	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS



// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
float4 extraV2F0;
float4 extraV2F1;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
float4 _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4 = IN.uv0;
float4 _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4 = IN.uv1;
float4 _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4 = IN.uv2;
float4 _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4 = IN.uv3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
float3 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4;
float4 _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4;
Vert_float(IN.InstanceID, IN.ObjectSpacePosition, IN.ObjectSpaceNormal, IN.ObjectSpaceTangent, IN.VertexColor, _UV_ccc703dc3bdd420e8a8a4aa0607d4ec4_Out_0_Vector4, _UV_46571950324b44e8bf8895f08abd191f_Out_0_Vector4, _UV_ba4ef72275334f08b9b01fedf9da0065_Out_0_Vector4, _UV_255ab3a515d14af686e70c40d04416e6_Out_0_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F2_13_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F3_14_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F4_15_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F5_16_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F6_17_Vector4, _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F7_18_Vector4);
description.Position = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oPosition_0_Vector3;
description.Normal = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oNormal_5_Vector3;
description.Tangent = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oTangent_6_Vector3;
description.extraV2F0 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F0_7_Vector4;
description.extraV2F1 = _VertCustomFunction_c06714ff508d45fab2f28a5dcfca5564_oExtraV2F1_8_Vector4;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean = max(0, IN.FaceSign.x);
float4 _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4 = IN.uv0;
float4 _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4 = IN.uv1;
float4x4 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
float3 _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
float _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, IN.extraV2F1, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal =                          input.normalOS;
    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
    output.ObjectSpacePosition =                        input.positionOS;
    output.uv0 =                                        input.uv0;
    output.uv1 =                                        input.uv1;
    output.uv2 =                                        input.uv2;
    output.uv3 =                                        input.uv3;
    output.VertexColor =                                input.color;
#if UNITY_ANY_INSTANCING_ENABLED
    output.InstanceID =                                 unity_InstanceID;
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    output.InstanceID =                                 input.instanceID;
#endif

    return output;
}
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    output.extraV2F0 = input.extraV2F0;
output.extraV2F1 = input.extraV2F1;

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;

    output.WorldSpacePosition = input.positionWS;

    #if UNITY_UV_STARTS_AT_TOP
    #else
    #endif


    output.uv0 = input.texCoord0;
    output.uv1 = input.texCoord1;
#if UNITY_ANY_INSTANCING_ENABLED
#else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
    BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
}

void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
{
    result.vertex     = float4(attributes.positionOS, 1);
    result.tangent    = attributes.tangentOS;
    result.normal     = attributes.normalOS;
    result.texcoord   = attributes.uv0;
    result.texcoord1  = attributes.uv1;
    result.texcoord2  = attributes.uv2;
    result.texcoord3  = attributes.uv3;
    result.color      = attributes.color;
    result.vertex     = float4(vertexDescription.Position, 1);
    result.normal     = vertexDescription.Normal;
    result.tangent    = float4(vertexDescription.Tangent, 0);
    #if UNITY_ANY_INSTANCING_ENABLED
    result.instanceID = attributes.instanceID;
    #endif
}

void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
{
    result.pos = varyings.positionCS;
    result.worldPos = varyings.positionWS;
    result.worldNormal = varyings.normalWS;
    // World Tangent isn't an available input on v2f_surf


    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogCoord = varyings.fogFactorAndVertexLight.x;
        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
}

void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
{
    result.positionCS = surfVertex.pos;
    result.positionWS = surfVertex.worldPos;
    result.normalWS = surfVertex.worldNormal;
    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
    // World Tangent isn't an available input on v2f_surf

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    #endif
    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
    #endif

    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
}

// --------------------------------------------------
// Main

#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInUnlitGUI" ""
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}