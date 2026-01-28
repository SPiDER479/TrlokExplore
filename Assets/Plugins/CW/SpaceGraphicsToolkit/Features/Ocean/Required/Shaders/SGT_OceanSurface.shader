//<sss_checksum>3EEADC98</sss_checksum>
Shader "Space Graphics Toolkit/OceanSurface"
{
Properties
{




	[KeywordEnum(Box, Sphere)] _SGT_Shape ("Shape", Float) = 0
	
	[HideInInspector] _SGT_SurfaceColor("", Color) = (0,0,0)
	[HideInInspector] _SGT_SurfaceDensity("", Float) = 0
	[HideInInspector] _SGT_SurfaceMinimumOpacity("", Float) = 0
	[HideInInspector] _SGT_SurfaceSmoothness("", Float) = 0
	
	[HideInInspector] _SGT_UnderwaterColor("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_UnderwaterDensity("", Float) = 0
	[HideInInspector] _SGT_UnderwaterMinimumOpacity("", Float) = 0
	[HideInInspector] _SGT_UnderwaterBrightness("", Float) = 0
	[HideInInspector] _SGT_UnderwaterShadowRange("", Float) = 0
	
	[Header(REFRACTION)]
	[Toggle(_SGT_REFRACTION)] _SGT_Refraction("	Enable", Float) = 0
	_SGT_RefractionDistance("	Distance", Float) = 1

	[Header(ALBEDO)]
	[Toggle(_SGT_ALBEDO)] _SGT_Albedo("	Enable", Float) = 0
	
	[Header(LIGHTING)]
	[Toggle(_SGT_LIGHTING)] _SGT_Lighting("	Enable", Float) = 0
	
	[Header(DITHER)]
	[Toggle(_SGT_DITHER)] _SGT_Dither("	Enable", Float) = 0
	
	[Header(CLOUDS)]
	[Toggle(_SGT_CLOUDS)] _SGT_Clouds("	Enable", Float) = 0
	[HideInInspector] [NoScaleOffset] _SGT_CloudShadowTex("", 2D) = "black" {}
	[HideInInspector] _SGT_CloudShadowDirection("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_CloudShadowOpacity("", Vector) = (0,0,0,0)
	
	[Header(CAUSTICS)]
	[Toggle(_SGT_CAUSTICS)] _SGT_Caustics("	Enable", Float) = 0
	[HideInInspector] _SGT_CausticsDirection("", Vector) = (0,0,0,0)
	[NoScaleOffset] _SGT_CausticsTexure("	Texture (R)", 3D) = "black" {}
	_SGT_CausticsTopSharpness("	Top Sharpness", Float) = 1
	_SGT_CausticsBottomSharpness("	Bottom Sharpness", Float) = 0.1
	_SGT_CausticsSpeed("	Speed", Float) = 0.2
	_SGT_CausticsBrightness("	Brightness", Float) = 10.0
	
	[Header(SHORE)]
	[Toggle(_SGT_SHORE)] _SGT_Shore("	Enable", Float) = 0
	[NoScaleOffset] _SGT_ShoreTex("	Texture (RGB)", 2D) = "black" {}
	_SGT_ShoreDistance("	Distance", Float) = 50
	_SGT_ShoreWidth("	Width", Range(0.1, 10)) = 1
	_SGT_ShoreBias("	Bias", Range(0, 1)) = 0.5
	
	[Header(FAST SSR)]
	[Toggle(_SGT_FASTSSR)] _SGT_FastSSR("	Enable", Float) = 0
	_SGT_FssrFresnel("	Fresnel", Range(4, 32)) = 10

	[Header(SUBSURFACE SCATTERING)]
	[Toggle(_SGT_FASTSSS)] _SGT_SSS("	Enable", Float) = 0
	_SGT_ScatteringDistanceFade("	Distance Fade", Float) = 0.01


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
"UniversalMaterialType" = "Lit"
"Queue"="Transparent"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalLitSubTarget"
}






Pass
{
    Name "Universal Forward"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest Always
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_UNIVERSAL_FORWARD 1

#define _SSS_URP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment modified_frag

// Keywords
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _REFLECTION_PROBE_ATLAS
#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _LIGHT_LAYERS
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _LIGHT_COOKIES
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
#pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define _SURFACE_TYPE_TRANSPARENT 1
#define _ALPHATEST_ON 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP3;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP4;
#endif
 float4 tangentWS : INTERP5;
 float4 texCoord0 : INTERP6;
 float4 texCoord1 : INTERP7;
 float4 fogFactorAndVertexLight : INTERP8;
 float4 extraV2F0 : INTERP9;
 float3 positionWS : INTERP10;
 float3 normalWS : INTERP11;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.extraV2F0.xyzw = input.extraV2F0;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor; float4x4 Extra;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(inout SurfaceDescriptionInputs IN)
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), surface.Extra, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Metallic = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
surface.Smoothness = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
surface.Occlusion = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif


SurfaceDescription modified_BuildSurfaceDescription(inout Varyings varyings)
{
    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(varyings);
#if defined(HAVE_VFX_MODIFICATION)
    GraphProperties properties;
    ZERO_INITIALIZE(GraphProperties, properties);
    GetElementPixelProperties(surfaceDescriptionInputs, properties);
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs, properties);
#else
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
#endif
    varyings.positionWS = surfaceDescriptionInputs.WorldSpacePosition;varyings.normalWS = surfaceDescriptionInputs.WorldSpaceNormal;varyings.tangentWS.xyz = surfaceDescriptionInputs.WorldSpaceTangent;return surfaceDescription;
}
void modified_frag(
    PackedVaryings packedInput
    , out half4 outColor : SV_Target0
#ifdef _WRITE_RENDERING_LAYERS
    , out uint outRenderingLayers : SV_Target1
#endif
)
{
    Varyings unpacked = UnpackVaryings(packedInput);
    UNITY_SETUP_INSTANCE_ID(unpacked);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);
    SurfaceDescription surfaceDescription = modified_BuildSurfaceDescription(unpacked);

#if defined(_SURFACE_TYPE_TRANSPARENT)
    bool isTransparent = true;
#else
    bool isTransparent = false;
#endif

#if defined(_ALPHATEST_ON)
    half alpha = AlphaDiscard(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
#elif defined(_SURFACE_TYPE_TRANSPARENT)
    half alpha = surfaceDescription.Alpha;
#else
    half alpha = half(1.0);
#endif

    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
        LODFadeCrossFade(unpacked.positionCS);
    #endif

    InputData inputData;
    InitializeInputData(unpacked, surfaceDescription, inputData);
    #ifdef VARYINGS_NEED_TEXCOORD0
        SETUP_DEBUG_TEXTURE_DATA(inputData, unpacked.texCoord0);
    #else
        SETUP_DEBUG_TEXTURE_DATA_NO_UV(inputData);
    #endif

    #ifdef _SPECULAR_SETUP
        float3 specular = surfaceDescription.Specular;
        float metallic = 1;
    #else
        float3 specular = 0;
        float metallic = surfaceDescription.Metallic;
    #endif

    half3 normalTS = half3(0, 0, 0);
    #if defined(_NORMALMAP) && defined(_NORMAL_DROPOFF_TS)
        normalTS = surfaceDescription.NormalTS;
    #endif

    SurfaceData surface;
    surface.albedo              = surfaceDescription.BaseColor;
    surface.metallic            = saturate(metallic);
    surface.specular            = specular;
    surface.smoothness          = saturate(surfaceDescription.Smoothness),
    surface.occlusion           = surfaceDescription.Occlusion,
    surface.emission            = surfaceDescription.Emission,
    surface.alpha               = saturate(alpha);
    surface.normalTS            = normalTS;
    surface.clearCoatMask       = 0;
    surface.clearCoatSmoothness = 1;

    #ifdef _CLEARCOAT
        surface.clearCoatMask       = saturate(surfaceDescription.CoatMask);
        surface.clearCoatSmoothness = saturate(surfaceDescription.CoatSmoothness);
    #endif

    surface.albedo = AlphaModulate(surface.albedo, surface.alpha);

#if defined(_DBUFFER)
    ApplyDecalToSurfaceData(unpacked.positionCS, surface, inputData);
#endif

    InitializeBakedGIData(unpacked, inputData);

    half4 color = UniversalFragmentPBR(inputData, surface);
    color.rgb = MixFog(color.rgb, inputData.fogCoord);

    color.a = OutputAlpha(color.a, isTransparent);

    outColor = color;

#ifdef _WRITE_RENDERING_LAYERS
    outRenderingLayers = EncodeMeshRenderingLayer();
#endif
outColor = SSS_FinalColorModifier(outColor, surfaceDescription.Extra);}ENDHLSL
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
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest Always
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_GBUFFER 1

#define _SSS_URP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles3 glcore
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment modified_frag

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile _ _CLUSTER_LIGHT_LOOP
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _FOG_FRAGMENT 1
#define _SURFACE_TYPE_TRANSPARENT 1
#define _ALPHATEST_ON 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP3;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP4;
#endif
 float4 tangentWS : INTERP5;
 float4 texCoord0 : INTERP6;
 float4 texCoord1 : INTERP7;
 float4 fogFactorAndVertexLight : INTERP8;
 float4 extraV2F0 : INTERP9;
 float3 positionWS : INTERP10;
 float3 normalWS : INTERP11;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.extraV2F0.xyzw = input.extraV2F0;
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
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor; float4x4 Extra;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Metallic = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
surface.Smoothness = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
surface.Occlusion = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif


GBufferFragOutput modified_frag(PackedVaryings packedInput)
{
    Varyings unpacked = UnpackVaryings(packedInput);
    UNITY_SETUP_INSTANCE_ID(unpacked);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);
    SurfaceDescription surfaceDescription = BuildSurfaceDescription(unpacked);

    #if defined(_ALPHATEST_ON)
        half alpha = surfaceDescription.Alpha;
        clip(alpha - surfaceDescription.AlphaClipThreshold);
    #elif _SURFACE_TYPE_TRANSPARENT
        half alpha = surfaceDescription.Alpha;
    #else
        half alpha = 1;
    #endif

    #if defined(LOD_FADE_CROSSFADE) && USE_UNITY_CROSSFADE
        LODFadeCrossFade(unpacked.positionCS);
    #endif

    InputData inputData;
    InitializeInputData(unpacked, surfaceDescription, inputData);
    #ifdef VARYINGS_NEED_TEXCOORD0
        SETUP_DEBUG_TEXTURE_DATA(inputData, unpacked.texCoord0);
    #else
        SETUP_DEBUG_TEXTURE_DATA_NO_UV(inputData);
    #endif

    #ifdef _SPECULAR_SETUP
        float3 specular = surfaceDescription.Specular;
        float metallic = 1;
    #else
        float3 specular = 0;
        float metallic = surfaceDescription.Metallic;
    #endif

#if defined(_DBUFFER)
    ApplyDecal(unpacked.positionCS,
        surfaceDescription.BaseColor,
        specular,
        inputData.normalWS,
        metallic,
        surfaceDescription.Occlusion,
        surfaceDescription.Smoothness);
#endif

    InitializeBakedGIData(unpacked, inputData);

    // in LitForwardPass GlobalIllumination (and temporarily LightingPhysicallyBased) are called inside UniversalFragmentPBR
    // in Deferred rendering we store the sum of these values (and of emission as well) in the GBuffer
    BRDFData brdfData;
    InitializeBRDFData(surfaceDescription.BaseColor, metallic, specular, surfaceDescription.Smoothness, alpha, brdfData);

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surfaceDescription.Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);

    color = SSS_FinalColorModifier(half4(color, 1.0), surfaceDescription.Extra).xyz;
return PackGBuffersBRDFData(brdfData, inputData, surfaceDescription.Smoothness, surfaceDescription.Emission + color, surfaceDescription.Occlusion);
}ENDHLSL
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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.5
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _ALPHATEST_ON 1


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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
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
#define _SSS_PASS_DEPTHNORMALS 1

#define _SSS_URP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define SHADERPASS SHADERPASS_DEPTHNORMALS
#define _ALPHATEST_ON 1


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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 NormalTS;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_META 1

#define _SSS_URP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma shader_feature _ EDITOR_VISUALIZATION
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_TEXCOORD2
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_META
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1


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
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
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
 float4 texCoord2;
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
 float4 texCoord2 : INTERP3;
 float4 extraV2F0 : INTERP4;
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
output.texCoord2.xyzw = input.texCoord2;
output.extraV2F0.xyzw = input.extraV2F0;
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
output.texCoord2 = input.texCoord2.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 Emission;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _ALPHATEST_ON 1


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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _ALPHATEST_ON 1


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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
    Name "Universal 2D"
    Tags
    {
        "LightMode" = "Universal2D"
    }

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest Always
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_UNIVERSAL_2D 1

#define _SSS_URP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define SHADERPASS SHADERPASS_2D
#define _ALPHATEST_ON 1


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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

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
"BuiltInMaterialType" = "Lit"
"Queue"="Transparent"
// DisableBatching: <None>
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="BuiltInLitSubTarget"
}
Pass
{
    Name "BuiltIn Forward"
    Tags
    {
        "LightMode" = "ForwardBase"
    }

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest Always
ZWrite Off
ColorMask RGB

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_BUILTIN_FORWARD 1

#define _SSS_BIRP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment modified_frag

// Keywords
#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV : INTERP0;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP1;
#endif
 float4 tangentWS : INTERP2;
 float4 texCoord0 : INTERP3;
 float4 texCoord1 : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float4 shadowCoord : INTERP6;
 float4 extraV2F0 : INTERP7;
 float3 positionWS : INTERP8;
 float3 normalWS : INTERP9;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.shadowCoord.xyzw = input.shadowCoord;
output.extraV2F0.xyzw = input.extraV2F0;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.shadowCoord = input.shadowCoord.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor; float4x4 Extra;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(inout SurfaceDescriptionInputs IN)
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), surface.Extra, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Metallic = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
surface.Smoothness = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
surface.Occlusion = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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

    result._ShadowCoord = varyings.shadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = varyings.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lmap.xy = varyings.lightmapUV;
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
    result.shadowCoord = surfVertex._ShadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = surfVertex.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lightmapUV = surfVertex.lmap.xy;
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
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"


half4 modified_frag(PackedVaryings packedInput) : SV_TARGET
{
    Varyings unpacked = UnpackVaryings(packedInput);
    UNITY_SETUP_INSTANCE_ID(unpacked);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);

    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(unpacked);
    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);

    InputData inputData;unpacked.positionWS = surfaceDescriptionInputs.WorldSpacePosition;unpacked.normalWS = surfaceDescriptionInputs.WorldSpaceNormal;unpacked.tangentWS.xyz = surfaceDescriptionInputs.WorldSpaceTangent;
    BuildInputData(unpacked, surfaceDescription, inputData);

    half4 color = PBRStandardFragment(surfaceDescription, inputData, unpacked);
    return SSS_FinalColorModifier(color, surfaceDescription.Extra);
}ENDHLSL
}
Pass
{
    Name "BuiltIn ForwardAdd"
    Tags
    {
        "LightMode" = "ForwardAdd"
    }

// Render State
Blend SrcAlpha One
ZWrite Off
ColorMask RGB

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_BUILTIN_FORWARDADD 1

#define _SSS_BIRP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdadd_fullshadows
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD_ADD
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV : INTERP0;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP1;
#endif
 float4 tangentWS : INTERP2;
 float4 texCoord0 : INTERP3;
 float4 texCoord1 : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float4 shadowCoord : INTERP6;
 float4 extraV2F0 : INTERP7;
 float3 positionWS : INTERP8;
 float3 normalWS : INTERP9;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.shadowCoord.xyzw = input.shadowCoord;
output.extraV2F0.xyzw = input.extraV2F0;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.shadowCoord = input.shadowCoord.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Metallic = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
surface.Smoothness = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
surface.Occlusion = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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

    result._ShadowCoord = varyings.shadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = varyings.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lmap.xy = varyings.lightmapUV;
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
    result.shadowCoord = surfVertex._ShadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = surfVertex.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lightmapUV = surfVertex.lmap.xy;
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
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

ENDHLSL
}
Pass
{
    Name "BuiltIn Deferred"
    Tags
    {
        "LightMode" = "Deferred"
    }

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest Always
ZWrite Off
ColorMask RGB

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_BUILTIN_DEFERRED 1

#define _SSS_BIRP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 4.5
#pragma multi_compile_instancing
#pragma exclude_renderers nomrt
#pragma multi_compile_prepassfinal
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile _ _GBUFFER_NORMALS_OCT
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_CULLFACE
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEFERRED
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
 float4 shadowCoord;
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
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 WorldSpaceTangent;
 float3 WorldSpacePosition;
 float4 uv0;
 float4 uv1;
 float FaceSign;
 float4 extraV2F0;
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
#if defined(LIGHTMAP_ON)
 float2 lightmapUV : INTERP0;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP1;
#endif
 float4 tangentWS : INTERP2;
 float4 texCoord0 : INTERP3;
 float4 texCoord1 : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float4 shadowCoord : INTERP6;
 float4 extraV2F0 : INTERP7;
 float3 positionWS : INTERP8;
 float3 normalWS : INTERP9;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.shadowCoord.xyzw = input.shadowCoord;
output.extraV2F0.xyzw = input.extraV2F0;
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
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.shadowCoord = input.shadowCoord.xyzw;
output.extraV2F0 = input.extraV2F0.xyzw;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.NormalTS = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Metallic = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float;
surface.Smoothness = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float;
surface.Occlusion = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = input.normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);

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

    result._ShadowCoord = varyings.shadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = varyings.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lmap.xy = varyings.lightmapUV;
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
    result.shadowCoord = surfVertex._ShadowCoord;

    #if UNITY_ANY_INSTANCING_ENABLED
    #endif
    #if UNITY_SHOULD_SAMPLE_SH
    #if !defined(LIGHTMAP_ON)
    result.sh = surfVertex.sh;
    #endif
    #endif
    #if defined(LIGHTMAP_ON)
    result.lightmapUV = surfVertex.lmap.xy;
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
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

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
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma multi_compile_shadowcaster
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM
#define _SSS_PASS_META 1

#define _SSS_BIRP 1

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define SHADERPASS SHADERPASS_META
#define BUILTIN_TARGET_API 1
#define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 Emission;
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.BaseColor = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3;
surface.Emission = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3;
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
#include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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

#define REQUIRE_DEPTH_TEXTURE

#define REQUIRE_OPAQUE_TEXTURE


// Pragmas
#pragma target 3.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
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
#define _BUILTIN_AlphaClip 1
#define _BUILTIN_ALPHATEST_ON 1
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
 float3 positionWS : INTERP4;
 float3 normalWS : INTERP5;
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
#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30�� increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0��
	float2(0.866025, 0.5),      // 30��
	float2(0.5, 0.866025),      // 60��
	float2(0.0, 1.0),           // 90��
	float2(-0.5, 0.866025),     // 120��
	float2(-0.866025, 0.5),     // 150��
	float2(-1.0, 0.0),          // 180��
	float2(-0.866025, -0.5),    // 210��
	float2(-0.5, -0.866025),    // 240��
	float2(0.0, -1.0),          // 270��
	float2(0.5, -0.866025),     // 300��
	float2(0.866025, -0.5),     // 330��
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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
    float3 ambientColor,
    float  cameraDepth,
    float3 waterColor, // The "Deep" convergence color
    float  waterDensity)
{
    // 1. Artist-Friendly Absorption Profile
    // Typical ocean water absorbs Red much faster than Blue.
    // We use these coefficients to scale the extinction per channel.
    // Higher value = color disappears faster with depth.
    float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
    
    // 2. Derive Coefficients
    // Extinction must be float3 for color shifting to happen.
    float3 extinction = absorptionWeight * waterDensity;
    
    // To ensure convergence to waterColor at infinite depth, 
    // the scattering/extinction ratio must equal waterColor.
    float3 scatt = waterColor * extinction;
    
    // 3. Transmittance (The "Nice Shift" happens here)
    // Red channel will drop to 0 much faster than Blue.
    transmittance = exp(-extinction * waterDepth);
    
    float viewCos = abs(viewDir.y);
    float sunCos = max(sunDir.y, 0.01);
    
    // 4. Sun Scattering
    float3 sunExt = extinction * (1.0 + viewCos / sunCos);
    float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
    float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
    
    // Volume scattering formula with float3 coefficients
    scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
    
    // 5. Ambient Scattering (Converges to waterColor when ambient=1)
    float  geomFactor = (1.0 + viewCos * 2.0); 
    float3 ambExt = extinction * geomFactor;
    float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
    
    // This term simplifies to (scatt / extinction) at infinite depth
    scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}








float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST SSR
float _SGT_FssrFresnel;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
}

float SGT_InterleavedGradientNoise(float2 screenPos)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;

	wfar = min(wfar, worldEyeDepth);


	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
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




	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS



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
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
output.extraV2F0 = input.extraV2F0;
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
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
Frag_float(IN.WorldSpacePosition, IN.WorldSpaceNormal, IN.WorldSpaceTangent, _IsFrontFace_5b03f99e2e7841c3a7d2ae306590b576_Out_0_Boolean, float4 (0, 0, 0, 0), _UV_c1e39353e82e434da821b9bdc4338e4b_Out_0_Vector4, _UV_64d51b5974bc4ecf849e7307e6de2727_Out_0_Vector4, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), IN.extraV2F0, float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), float4 (0, 0, 0, 0), _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oExtra_23_Matrix4, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlbedo_0_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oSmoothness_5_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oNormal_6_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oEmission_7_Vector3, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oOcclusion_8_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oMetallic_9_Float, _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float);
surface.Alpha = _FragCustomFunction_a9f9336e3bc541cd8ae52be701d51fdc_oAlpha_10_Float;
surface.AlphaClipThreshold = float(0);
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
CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}