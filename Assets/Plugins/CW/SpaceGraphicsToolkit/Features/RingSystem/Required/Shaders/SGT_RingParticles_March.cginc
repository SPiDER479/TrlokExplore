BEGIN_PROPERTIES
	[HideInInspector] [NoScaleOffset] _SGT_MainTex("", 3D) = "white" {}
	_SGT_Smoothness ("Smoothness", Range(0,1)) = 0.1
	_SGT_Metallic ("Metallic", Range(0,1)) = 0
	_SGT_RingColorInfluence ("Ring Color Influence", Range(0,1)) = 1
	_SGT_MaxSteps ("Max Steps", Int) = 64
	
	[Header(DETAIL)]
	[Toggle(_SGT_DETAIL)] _SGT_Detail ("	Enable", Float) = 0
	[NoScaleOffset] _SGT_DetailTexture("	Texture (RG = Normal, B = AO, A = Height)", 2D) = "white" {}
	_SGT_DetailTiling("	Tiling", Float) = 1.0
	_SGT_DetailRelief("	Relief", Float) = 1.0
	
	[Header(DETAIL DARKEN)]
	[KeywordEnum(Off, B, InvB, A, InvA)] _SGT_Detail_Darken ("	Enable", int) = 0
	
	[Header(DETAIL EMISSION)]
	[KeywordEnum(Off, B, InvB, A, InvA)] _SGT_Detail_Emission ("	Enable", int) = 0
	_SGT_DetailEmissionColor("	Color", Color) = (0,1,0,1)
	_SGT_DetailEmissionBlend("	Blend", Range(0,1)) = 1.0
	_SGT_DetailEmissionMultiplier("	Multiplier", Float) = 1.0
	
	[Header(SHADOWS)]
	[Toggle(_SGT_SHADOWS)] _SGT_Shadows ("	Enable", Float) = 0
END_PROPERTIES

BEGIN_CBUFFER
	sampler3D _SGT_MainTex;
	float     _SGT_Smoothness;
	float     _SGT_Metallic;
	float     _SGT_RingColorInfluence;
	int       _SGT_MaxSteps;
	
	// DETAIL
	sampler2D _SGT_DetailTexture;
	float     _SGT_DetailTiling;
	float     _SGT_DetailRelief;
	
	// DETAIL EMISSION
	float4 _SGT_DetailEmissionColor;
	float  _SGT_DetailEmissionBlend;
	float  _SGT_DetailEmissionMultiplier;
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_DETAIL
	#pragma shader_feature_local _SGT_DETAIL_DARKEN_OFF _SGT_DETAIL_DARKEN_B _SGT_DETAIL_DARKEN_INVB _SGT_DETAIL_DARKEN_A _SGT_DETAIL_DARKEN_INVA
	#pragma shader_feature_local _SGT_DETAIL_EMISSION_OFF _SGT_DETAIL_EMISSION_B _SGT_DETAIL_EMISSION_INVB _SGT_DETAIL_EMISSION_A _SGT_DETAIL_EMISSION_INVA
	#pragma shader_feature_local _SGT_SHADOWS
END_DEFINES

float3 RandomUnitVector(float seed)
{
	// Create two pseudo-random values from seed
	float a = frac(sin(seed * 12.9898) * 43758.5453);
	float b = frac(sin(seed * 78.233) * 12345.6789);
	
	// Spherical coordinates
	float theta = a * 2.0 * 3.14159265; // azimuth
	float z = b * 2.0 - 1.0;            // cos(elevation)
	float r = sqrt(1.0 - z * z);        // radius in x-y plane
	
	return normalize(float3(r * cos(theta), r * sin(theta), z));
}

float SGT_GetDistance(float3 p)
{
	return tex3Dlod(_SGT_MainTex, float4(p * 0.5f + 0.5f, 0.0f)).x;
}

float3 SGT_GetNormal3(float3 p)
{
	float eps = 0.05;
	
	float3 kx = float3( 1, -1, -1);
	float3 ky = float3(-1, -1,  1);
	float3 kz = float3(-1,  1, -1);
	
	float dx = SGT_GetDistance(p + eps * kx);
	float dy = SGT_GetDistance(p + eps * ky);
	float dz = SGT_GetDistance(p + eps * kz);
	
	return -normalize(dx * kx + dy * ky + dz * kz);
}

float3 SGT_GetNormal6(float3 p)
{
	float eps = 0.05;
	
	float dx = SGT_GetDistance(p + float3(eps, 0, 0)) - SGT_GetDistance(p - float3(eps, 0, 0));
	float dy = SGT_GetDistance(p + float3(0, eps, 0)) - SGT_GetDistance(p - float3(0, eps, 0));
	float dz = SGT_GetDistance(p + float3(0, 0, eps)) - SGT_GetDistance(p - float3(0, 0, eps));
	
	return -normalize(float3(dx, dy, dz));
}

float4 SGT_AxisAngleToQuaternion(float3 axis, float angle)
{
	float halfAngle = angle * 0.5; return float4(axis * sin(halfAngle), cos(halfAngle));
}

float3 SGT_RotateVectorByQuaternion(float3 v, float4 q)
{
	float3 t = 2.0 * cross(q.xyz, v); return v + q.w * t + cross(q.xyz, t);
}

bool SGT_March(float3 rayPos, float3 rayDir, out float3 hitPos, float distN, float distF, float minDist)
{
	float totalD = distN;
	float hitDst = 999.9f;
	
	hitPos = rayPos;
	
	for (int r = 0; r < _SGT_MaxSteps && totalD < distF && hitDst > minDist; r++)
	{
		hitPos = rayPos + rayDir * totalD;
		
		hitDst = SGT_GetDistance(hitPos);
		
		totalD += hitDst * 2.0f;
	}
	
	return hitDst <= minDist;
}

bool SGT_IntersectUnitAABB(float3 rayOrigin, float3 rayDir, out float tNear, out float tFar)
{
	float3 t0 = (-1.0f - rayOrigin) / rayDir;
	float3 t1 = ( 1.0f - rayOrigin) / rayDir;
	
	float3 tMin = min(t0, t1);
	float3 tMax = max(t0, t1);
	
	tNear = max(max(tMin.x, tMin.y), tMin.z);
	tFar  = min(min(tMax.x, tMax.y), tMax.z);
	
	return tFar >= max(tNear, 0.0);
}

float4 SGT_SampleTriplanar(sampler2D tex, float3 worldPos, float3 worldNormal)
{
	float3 blendWeights = pow(abs(worldNormal), 5.0f);
	
	blendWeights /= (blendWeights.x + blendWeights.y + blendWeights.z + 0.001f);
	
	return
		tex2Dlod(tex, float4(worldPos.zy, 0.0f, 0.0f)) * blendWeights.x +
		tex2Dlod(tex, float4(worldPos.xz, 0.0f, 0.0f)) * blendWeights.y +
		tex2Dlod(tex, float4(worldPos.xy, 0.0f, 0.0f)) * blendWeights.z;
}
	
float3 SGT_CombineNormals(float3 worldNormal, float3 worldPoint, float3 tangentNormal)
{
	float3 N = normalize(worldNormal);
	float3 U = abs(N.y) < 0.999f ? float3(0, 1, 0) : float3(1, 0, 0);
	float3 T = cross(U, N);
	float3 B = cross(worldNormal, T);

	float3x3 TBN = float3x3(T, B, N);
	
	return normalize(mul(tangentNormal, TBN));
}

void SSS_Vert(inout SSS_VertexData v)
{
	SSS_BaseVert(v);
	
	float  seed       = v.seed;
	float3 wpos       = v.position;
	float  wdst       = distance(_WorldSpaceCameraPos, wpos.xyz);
	float  rangeRecip = _SGT_OctaveRanges[v.octave].y;
	float  radius     = _SGT_OctaveRanges[v.octave].x;
			
	v.extraV2F2.w = radius; // Store pre fade radius
			
	radius *= 1.0f - pow(saturate(wdst * rangeRecip),5); // Far fade
			
	radius *= v.visible;
			
	float3 wcen = wpos;
			
	// Expand in world space
	float3 axis1 = wpos - _WorldSpaceCameraPos;
	float3 axis2 = cross(axis1, float3(0,1,0));
	float3 axis3 = cross(axis1, axis2);
	wpos -= normalize(axis1) * radius;
	wpos += normalize(axis2) * v.texcoord0.x * radius;
	wpos += normalize(axis3) * v.texcoord0.y * radius;
	v.position = wpos;
			
	// March data
	float3   axis = RandomUnitVector(seed);
	float    spin = _SGT_AnimationData.z * seed;
	float4   rot  = SGT_AxisAngleToQuaternion(axis, spin);
	
	float3 rayPos = (wcen - _WorldSpaceCameraPos) / max(0.000001f, radius);
	float3 rayDir = normalize(_WorldSpaceCameraPos - wpos);
	
	v.extraV2F1.xyz = SGT_RotateVectorByQuaternion(rayPos, rot);
	v.extraV2F1.w   = radius;
	v.extraV2F2.xyz = SGT_RotateVectorByQuaternion(rayDir, rot);
	v.extraV2F2.w   = seed * 3;
	
	v.extraV2F3 = float4(-rot.xyz, rot.w); // Inverse
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor = lerp(1.0f, d.extraV2F0, _SGT_RingColorInfluence);
	
	float3 rayPos = d.extraV2F1.xyz;
	float  radius = d.extraV2F1.w;
	float3 rayDir = normalize(d.extraV2F2.xyz);
	float  offset = d.extraV2F2.w;
	float4 invRot = d.extraV2F3;
	
	float3 hitPos; float distN; float distF;
			
	if (SGT_IntersectUnitAABB(rayPos, rayDir, distN, distF) == true && SGT_March(rayPos, rayDir, hitPos, distN, distF, 0.001f) == true)
	{
		//finalColor *= pow(length(hitPos),5);
		
		float3 normal = SGT_GetNormal6(hitPos);
		
		o.Smoothness = _SGT_Smoothness;
		o.Metallic   = _SGT_Metallic;
		
		#if _SGT_DETAIL
			float4 detail       = SGT_SampleTriplanar(_SGT_DetailTexture, hitPos * _SGT_DetailTiling * radius + offset, normal);
			float3 detailNormal;

			detailNormal.xy = (detail.xy * 2.0f - 1.0f) * _SGT_DetailRelief;
			detailNormal.z  = sqrt(saturate(1.0f - dot(detailNormal.xy, detailNormal.xy)));
					
			#if !_SGT_DETAIL_DARKEN_OFF
				#if _SGT_DETAIL_DARKEN_B
					float darken = detail.b;
				#elif _SGT_DETAIL_DARKEN_INVB
					float darken = 1.0f - detail.b;
				#elif _SGT_DETAIL_DARKEN_A
					float darken = detail.a;
				#elif _SGT_DETAIL_DARKEN_INVA
					float darken = 1.0f - detail.a;
				#endif
				finalColor *= darken;
			#endif
					
			#if !_SGT_DETAIL_EMISSION_OFF
				#if _SGT_DETAIL_EMISSION_B
					float emission = detail.b;
				#elif _SGT_DETAIL_EMISSION_INVB
					float emission = 1.0f - detail.b;
				#elif _SGT_DETAIL_EMISSION_A
					float emission = detail.a;
				#elif _SGT_DETAIL_EMISSION_INVA
					float emission = 1.0f - detail.a;
				#endif
				o.Emission = lerp(_SGT_DetailEmissionColor.xyz, d.vertexColor.xyz, _SGT_DetailEmissionBlend) * emission * _SGT_DetailEmissionMultiplier;
			#endif
					
			normal = SGT_CombineNormals(normal, hitPos, detailNormal);
		#endif
				
		o.Normal = SGT_RotateVectorByQuaternion(normal, invRot);
	}
	else
	{
		discard;
	}

	#if _SGT_SHADOWS
		finalColor *= SGT_ShadowColor(d.worldSpacePosition);
	#endif
	
	o.Albedo = finalColor.xyz;
}