float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToOcean;
float4x4 _SGT_OceanToObject;
float4x4 _SGT_WorldToLocal;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

sampler2D _SGT_WaveTexture;
float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

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

float CW_CalculateDisplacement(float4 coords, float3 direction)
{
	float pole = smoothstep(0.0f, 1.0f, saturate((abs(direction.y) - 0.7f) * 30.0f));
	
	float4 wavesA = tex2Dlod(_SGT_WaveTexture, float4(coords.xy, 0, 0));
	float4 wavesB = tex2Dlod(_SGT_WaveTexture, float4(coords.zw, 0, 0));
	
	return lerp(wavesA, wavesB, pole).w * _SGT_WaveData.y;
}

float3 CW_CalculateVertexData(inout float4 vertex, inout float4 texcoord0, inout float4 texcoord1, inout float4 texcoord2, inout float4 texcoord3)
{
	float  weight     = 1.0f;
	float3 weights    = vertex.xyz;
	float  batchIndex = 0;

	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		batchIndex = unity_InstanceID;
	#endif

	float3 origin = _SGT_Origins[batchIndex].xyz;
	float  depth  = _SGT_Origins[batchIndex].w;

	float4 position = _SGT_PositionsA[batchIndex] * weights.x + _SGT_PositionsB[batchIndex] * weights.y + _SGT_PositionsC[batchIndex] * weights.z;
	float3 normalPos = position.xyz + origin;

	position.xyz += _SGT_Offset + origin;

	float4 coordX = mul(_SGT_CoordsX[batchIndex], float4(weights, 0));
	float4 coordY = mul(_SGT_CoordsY[batchIndex], float4(weights, 0));
	float4 coordZ = mul(_SGT_CoordsZ[batchIndex], float4(weights, 0));
	float4 coordW = mul(_SGT_CoordsW[batchIndex], float4(weights, 0));

	float3 direction = normalize(normalPos.xyz);

	#if _SGT_SHAPE_SPHERE
		float3 direction0 = normalize(_SGT_PositionsA[batchIndex].xyz + origin);
		float3 direction1 = normalize(_SGT_PositionsB[batchIndex].xyz + origin);
		float3 direction2 = normalize(_SGT_PositionsC[batchIndex].xyz + origin);
		float3 directionM = max(max(direction0, direction1), direction2) - min(min(direction0, direction1), direction2);
		
		if ((directionM.x + directionM.y + directionM.z) > 0.001f)
		{
			float3 triangleD = normalize(direction0 + direction1 + direction2);
			float4 coords    = triangleD.x > 0.0f ? CW_CalculateCoords(direction) : CW_CalculateCoords2(direction);
	
			coordX = coords * _SGT_WaveData.x;
			coordY = coords * _SGT_SurfaceTiling.y;
			coordZ = coords * _SGT_SurfaceTiling.z;
			coordW = coords * _SGT_SurfaceTiling.w;
		}

		position.xyz = direction * _SGT_Radius + _SGT_Offset;
	#endif

	texcoord0 = coordX;
	texcoord1 = coordY;
	texcoord2 = coordZ;
	texcoord3 = coordW;

	vertex.xyz = position.xyz;

	weight = position.w;

	float height = 505;

	#if _SGT_SHAPE_BOX
		vertex.y += height * weight;
	#elif _SGT_SHAPE_SPHERE
		//vertex.xyz = normalize(vertex.xyz) * (weight + height);
	#endif
	
	#if _SGT_DISPLACEMENT_ON
		float3 normal = float3(0,1,0);
		
		#if _SGT_SHAPE_SPHERE
			normal = direction;
		#endif
		
		vertex.xyz += normal * CW_CalculateDisplacement(texcoord0, direction);
	#endif
	
	//vertex.y += sin(vertex.x * _SGT_WaveData.y);
	
	return normalPos;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}