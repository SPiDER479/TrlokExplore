BEGIN_PROPERTIES
    [HideInInspector] [NoScaleOffset] _SGT_MainTex("", 2D) = "white" {}
	[HideInInspector] _SGT_Cells("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Roll("", Float) = 0
	_SGT_RingColorInfluence ("Ring Color Influence", Range(0,1)) = 1
	
	[Header(SHADOWS)]
	[Toggle(_SGT_SHADOWS)] _SGT_Shadows ("	Enable", Float) = 0
END_PROPERTIES

BEGIN_CBUFFER
	sampler2D _SGT_MainTex;
	float4    _SGT_Cells;
	float     _SGT_Roll;
	float     _SGT_RingColorInfluence;
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_SHADOWS
END_DEFINES

float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	SSS_BaseVert(v);
	
	float  seed       = v.texcoord0.w;
	float3 wcam       = _WorldSpaceCameraPos;
	float3 wpos       = v.position;
	float  randomCell = (seed * 31) % 1;
	float  wdst       = distance(wcam, wpos);
	float  rangeRecip = _SGT_OctaveRanges[v.octave].y;
	float  radius     = _SGT_OctaveRanges[v.octave].x;
	
	v.extraV2F1.w = 1.0f;
	
	v.extraV2F1.w *= 1.0f - pow(saturate(wdst * rangeRecip), 2); // Far fade
	
	radius *= v.visible;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 vertexV = SSS_ObjectToView(v.position);
	vertexV.xy += SGT_Rotate(v.texcoord0.xy, roll) * radius;
	v.position = SSS_ViewToObject(vertexV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F1.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F1.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F1.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F1.xy /= _SGT_Cells.xy;
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor = lerp(1.0f, d.extraV2F0, _SGT_RingColorInfluence) * _SGT_Data.x;
	float  radius     = _SGT_Data.y;
	
	float wdst = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
	
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F1.xy).x;
	
	finalColor *= d.extraV2F1.w;
	
	finalColor *= saturate((wdst - (radius + _ProjectionParams.y)) / (radius * 10)); // Near fade
	
	#if _SGT_SHADOWS
		finalColor *= SGT_ShadowColor(d.worldSpacePosition);
	#endif
	
	o.Albedo = finalColor.xyz;
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		o.Albedo *= GetCurrentExposureMultiplier();
	#endif
}