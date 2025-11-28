Shader "Hidden/SgtGasGiantFluid"
{
	Properties
	{
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "SgtGasGiantFluid.cginc"

			float2 SGT_CalculateExternalForce(float2 uv)
			{
				float x = sin(uv.y * 3.141592654f * _SGT_Emission.x);
				float y = sin(uv.x * 11111) * 0.05f;

				return float2(pow(abs(x), _SGT_Emission.w) * sign(x) * _SGT_Emission.y, y);
			}

			float4 Frag(v2f i) : SV_Target
			{
				float2 uv            = SGT_SnapToPixel(i.texcoord0.xy, _SGT_DataSize.xy);
				float4 pixel         = float4(1.0f / _SGT_DataSize.xy, 0.0f, 0.0f);
				float2 externalForce = SGT_CalculateExternalForce(uv);

				float4 data = SGT_Sample(uv);
				float4 fr   = SGT_Sample(uv + pixel.xz);
				float4 fl   = SGT_Sample(uv - pixel.xz);
				float4 fu   = SGT_Sample(uv + pixel.zy);
				float4 fd   = SGT_Sample(uv - pixel.zy);
				
				// Gradients
				float3 udx = (fr.xyz - fl.xyz) * 0.5f;
				float3 udy = (fu.xyz - fd.xyz) * 0.5f;
				float2 ddx = float2(udx.z, udy.z);

				// Density update
				data.z -= _SGT_Constants.z * dot(float3(ddx, udx.x + udy.y), data.xyz);

				// Pressure + viscosity
				float2 pdx            = _SGT_Constants.x / _SGT_Constants.z * ddx;
				float2 laplacian      = (fu.xy + fd.xy + fr.xy + fl.xy) - 4.0f * data.xy;
				float2 viscosityForce = laplacian * _SGT_Constants.y;

				// Semi-Lagrangian advection
				float2 was = uv - _SGT_Constants.z * data.xy * pixel.xy;
				data.xyw = SGT_Sample(was).xyw;
				data.xy += _SGT_Constants.z * (viscosityForce - pdx + externalForce);

				data.y += (data.z - fr.z) * _SGT_Constants.w;
				data.y -= (data.z - fl.z) * _SGT_Constants.w;
				data.x += (data.z - fu.z) * _SGT_Constants.w;
				data.x -= (data.z - fd.z) * _SGT_Constants.w;

				// Fade poles
				float pole = abs(uv.y * 2.0f - 1.0f);
				data *= 1.0f - pow(pole, _SGT_DataSize.y * 0.200f) * 0.5f;
				data *= 1.0f - pow(pole, _SGT_DataSize.y * 0.175f) * 0.5f;

				data.w += length(data.xy) * 0.002f * _SGT_Emission.z;
				data.w *= 0.99f;

				return clamp(data, float4(-10, -10, 0.5f, 0.0f), float4(10, 10, 3.0f, 1.0f));
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "SgtGasGiantFluid.cginc"

			float4 Frag(v2f i) : SV_Target
			{
				float2 uv   = SGT_SnapToPixel(i.texcoord0.xy, _SGT_DataSize.xy);
				float4 data = tex2D(_SGT_DataTex, uv);

				data.x = lerp(-10.0f, 10.0f, data.x);
				data.y = lerp(-10.0f, 10.0f, data.y);
				data.z = lerp(  0.5f,  3.0f, data.z);
				data.w = lerp(  0.0f,  1.0f, data.w);

				return data;
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "SgtGasGiantFluid.cginc"

			float4 Frag(v2f i) : SV_Target
			{
				float2 uv   = SGT_SnapToPixel(i.texcoord0.xy, _SGT_DataSize.xy);
				float4 data = tex2D(_SGT_DataTex, uv);

				data.x = SGT_InverseLerp(-10.0f, 10.0f, data.x);
				data.y = SGT_InverseLerp(-10.0f, 10.0f, data.y);
				data.z = SGT_InverseLerp(  0.5f,  3.0f, data.z);
				data.w = SGT_InverseLerp(  0.0f,  1.0f, data.w);

				return data;
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "SgtGasGiantFluid.cginc"

			float4 Frag(v2f i) : SV_Target
			{
				//float2 uv      = SGT_SnapToPixel(i.texcoord0.xy, _SGT_DataSize.xy);
				float2 uv = i.texcoord0.xy;
				float4 oldData = tex2Dlod(_SGT_OldDataTex, float4(uv, 0, 0));
				float4 newData = tex2Dlod(_SGT_NewDataTex, float4(uv, 0, 0));
				float4 midData = lerp(oldData, newData, _SGT_OldNewTransition);

				return float4(pow(midData.w, _SGT_Power), 0, 0, 1);
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "SgtGasGiantFluid.cginc"

			float4 Frag(v2f i) : SV_Target
			{
				//float2 uv      = SGT_SnapToPixel(i.texcoord0.xy, _SGT_DataSize.xy);
				float2 uv = i.texcoord0.xy;
				float4 oldData = tex2Dlod(_SGT_OldDataTex, float4(uv, 0, 0));
				float4 newData = tex2Dlod(_SGT_NewDataTex, float4(uv, 0, 0));
				float4 midData = lerp(oldData, newData, _SGT_OldNewTransition);

				return midData;
			}
			ENDCG
		} // Pass
	}
}
