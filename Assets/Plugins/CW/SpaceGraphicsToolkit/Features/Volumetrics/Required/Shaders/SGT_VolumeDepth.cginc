BEGIN_OPTIONS
END_OPTIONS

BEGIN_PROPERTIES
END_PROPERTIES

BEGIN_CBUFFER
END_CBUFFER

BEGIN_DEFINES
END_DEFINES

void SSS_Vert(inout SSS_VertexData v)
{
}
 
void SSS_Frag(inout SSS_SurfaceData s, inout SSS_FragmentData d)
{
}

BEGIN_PASS
Pass
{
    Name "SceneDepth"
    ZWrite Off
	ZTest Always
	Blend Off
	Cull Off

    HLSLPROGRAM
		#if _SSS_HDRP
			#pragma vertex   Vert
			#pragma fragment Frag
			
			#pragma target 4.5
			
			#pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
			
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
			
			float2 _SGT_Volumetrics_ColorSize;
			
			float4 Frag(Varyings varyings) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
				uint2 pixel = (varyings.positionCS.xy / _SGT_Volumetrics_ColorSize.xy) * _ScreenSize.xy;
				
				float depth = LoadCameraDepth(pixel);
				
				PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
				
				return float4(posInput.linearDepth, 0, 0, 0);
			}
		#else
			#pragma vertex   Vert
			#pragma fragment Frag
			
			#include "UnityCG.cginc"
			
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			
			float GetSceneDepth(float2 uv)
			{
				return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
			}
			
			float GetLinearEyeDepth(float2 uv)
			{
				return LinearEyeDepth(GetSceneDepth(uv));
			} 
			
			float4 GetFullScreenTriangleVertexPosition(uint vertexID, float z)
			{
				// note: the triangle vertex position coordinates are x2 so the returned UV coordinates are in range -1, 1 on the screen.
				float2 uv = float2((vertexID << 1) & 2, vertexID & 2);
				float4 pos = float4(uv * 2.0 - 1.0, z, 1.0);
				
				return pos;
			}
			
			struct Attributes
			{
				uint vertexID : SV_VertexID;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings Vert(Attributes input)
		{
			Varyings output;
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
			// 1. Generate the correct clip-space position for a procedural triangle
			output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID, 0.5f);
    
			// 2. Procedurally generate the UVs based on the vertex ID
			float2 uv = float2((input.vertexID << 1) & 2, input.vertexID & 2);
    
			// 3. Flip the UVs (not the geometry) if the API coordinates start at the top
			#if UNITY_UV_STARTS_AT_TOP
				uv.y = 1.0 - uv.y;
			#endif
    
			output.texcoord0 = uv;
    
			return output;
		}
			
			float4 Frag(Varyings varyings) : SV_Target
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
				
				//float2 uv = varyings.screenPosition.xy / varyings.screenPosition.w;
				float2 uv = varyings.texcoord0;
				float linearDepth = GetLinearEyeDepth(uv);
				
				//return uv.x;
				return float4(linearDepth, 0, 0, 0);
			}
		#endif
    ENDHLSL
}
END_PASS