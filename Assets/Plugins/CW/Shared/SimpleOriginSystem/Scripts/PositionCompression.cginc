float2 _CW_PositionCompressionData; // x = start distance, y = max distance limit

#define DEBUG_SCALE 0.001

float SSS_GetCompressionRatio(float worldDist)
{
    float M       = _CW_PositionCompressionData.y - _CW_PositionCompressionData.x;
    float excess  = max(0.0, worldDist - _CW_PositionCompressionData.x);
    float newDist = worldDist - excess + (excess * M) / (excess + M + 0.0001);
	
	//return DEBUG_SCALE;
	
    return worldDist > 0.001 ? (newDist / worldDist) : 1.0;
}

float SSS_DecompressWorldDist(float compressedDist)
{
    float M = _CW_PositionCompressionData.y - _CW_PositionCompressionData.x;
	
    float compressedExcess = clamp(compressedDist - _CW_PositionCompressionData.x, 0.0, M - 0.001);
	
	//return compressedDist / DEBUG_SCALE;
	
    return compressedDist - compressedExcess + (compressedExcess * M) / (M - compressedExcess);
}

float3 SSS_CompressWorld(float3 worldPos, float3 worldCenter, float worldRadius, out float ratio) 
{
    float3 worldDelta = worldPos - _WorldSpaceCameraPos;
    float  farDist    = distance(_WorldSpaceCameraPos, worldCenter) + worldRadius;
    
    ratio = SSS_GetCompressionRatio(farDist);
    
    return _WorldSpaceCameraPos + worldDelta * ratio;
}

float3 SSS_CompressWorld(float3 worldPos) 
{
    float3 worldDelta = worldPos - _WorldSpaceCameraPos;
    float  worldDist  = length(worldDelta);
    
    return _WorldSpaceCameraPos + worldDelta * SSS_GetCompressionRatio(worldDist);
}

float3 SSS_DecompressWorld(float3 worldPos)
{
    float3 worldDelta = worldPos - _WorldSpaceCameraPos;
    float  worldDist  = length(worldDelta);
    
    return worldDist > 0.001 ? _WorldSpaceCameraPos + (worldDelta / worldDist) * SSS_DecompressWorldDist(worldDist) : _WorldSpaceCameraPos;
}

float3 SSS_DecompressWorld(float3 worldPos, float ratio) 
{
    float3 worldDelta = worldPos - _WorldSpaceCameraPos;
    return _WorldSpaceCameraPos + worldDelta / ratio;
}