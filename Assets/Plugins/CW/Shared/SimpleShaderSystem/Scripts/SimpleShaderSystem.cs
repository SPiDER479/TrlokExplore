using System;
using System.IO;
using System.Linq;
using System.Reflection;
using UnityEngine;
using System.Text;
using System.Collections.Generic;
#if UNITY_EDITOR
using System.Text.RegularExpressions;
#endif

#if !__SHADERGRAPH__
#error Shader Graph package is required. Please install it via Package Manager.
#endif

/// <summary>This scriptable object allows you to author shaders from code using Shader Graph as a backend to support most Unity version and render pipeline combinations.</summary>
public class SimpleShaderSystem : ScriptableObject
{
	/// <summary>The ShaderGraph shader that will be modified.</summary>
	public Shader ShaderTemplate { set { shaderTemplate = value; } get { return shaderTemplate; } } [SerializeField] protected Shader shaderTemplate;

	/// <summary>The .cginc containing shader code we want to insert.</summary>
	public List<TextAsset> ShaderFiles { get { if (shaderFiles == null) shaderFiles = new List<TextAsset>(); return shaderFiles; } } [SerializeField] protected List<TextAsset> shaderFiles;

	/// <summary>The .shader the compiled and modified ShaderGraph will be stored in.</summary>
	public Shader OutputShader { set { outputShader = value; } get { return outputShader; } } [SerializeField] protected Shader outputShader;

	/// <summary>The path/name that will be given to the final shader.</summary>
	public string OutputTitle { set { outputTitle = value; } get { return outputTitle; } } [SerializeField] protected string outputTitle = "Simple Shader System/NewShader";
	
#if UNITY_EDITOR
	private string GenerateChecksumHeader()
    {
        StringBuilder builder = new StringBuilder();

        // Unity version
        builder.Append(Application.unityVersion);

        // Render pipeline
        builder.Append(GetCurrentRenderPipeline());

        // TextAsset contents
        foreach (var shaderFile in shaderFiles)
        {
            if (shaderFile != null)
			{
                builder.Append(shaderFile.text);
			}
        }

        return "//<sss_checksum>" + SimpleHash(builder.ToString()) + "</sss_checksum>\n";
    }

	private static bool IsBIRP
	{
		get
		{
			var asset = UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline; return asset == null;
		}
	}

	private static bool IsURP
	{
		get
		{
			var asset = UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline; return asset != null && asset.GetType().ToString().Contains("Universal") == true;
		}
	}

	private static bool IsHDRP
	{
		get
		{
			var asset = UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline; return asset != null && asset.GetType().ToString().Contains("HDRenderPipeline") == true;
		}
	}

    private static string GetCurrentRenderPipeline()
    {
        if (IsBIRP)
            return "BIRP";
        if (IsURP)
            return "URP";
        if (IsHDRP)
            return "HDRP";

        return "Unknown";
    }

    // Simple FNV-1a style hash (pure C#, no crypto libs)
    private static string SimpleHash(string input)
    {
        const uint fnvOffset = 2166136261;
        const uint fnvPrime = 16777619;

        uint hash = fnvOffset;
        byte[] data = Encoding.UTF8.GetBytes(input);

        for (int i = 0; i < data.Length; i++)
        {
            hash ^= data[i];
            hash *= fnvPrime;
        }

        return hash.ToString("X8"); // hex string
    }

	public static string FindFunction(string hlslBlockContent, string functionName, string shaderFilePath = null)
	{
		if (string.IsNullOrEmpty(hlslBlockContent) || string.IsNullOrEmpty(functionName))
			return null;

		// Search includes from last to first
		var includes = GetIncludeDirectives(hlslBlockContent);
		for (int i = includes.Count - 1; i >= 0; i--)
		{
			string resolvedPath = ResolveIncludePath(includes[i].Path, shaderFilePath);
			if (!string.IsNullOrEmpty(resolvedPath) && File.Exists(resolvedPath))
			{
				try
				{
					string result = ExtractFunction(File.ReadAllText(resolvedPath), functionName);
					if (result != null) return result;
				}
				catch (Exception e)
				{
					Debug.LogWarning($"Failed to read include file '{resolvedPath}': {e.Message}");
				}
			}
		}

		// Check main content
		return ExtractFunction(hlslBlockContent, functionName);
	}

	private static string ExtractFunction(string content, string functionName)
	{
		// Pattern: returnType FunctionName(params) { ... }
		// Handles optional semantics like : SV_Target but doesn't require them
		string pattern = $@"\w+\s+{Regex.Escape(functionName)}\s*\([^)]*\)[^{{]*\{{";
    
		var match = Regex.Match(content, pattern, RegexOptions.Singleline);
		if (!match.Success)
			return null;

		int braceStart = match.Index + match.Length - 1;
		int braceEnd = FindMatchingBrace(content, braceStart);
    
		return braceEnd == -1 ? null : content.Substring(match.Index, braceEnd - match.Index + 1);
	}

	private static int FindMatchingBrace(string content, int openIndex)
	{
		int depth = 1;
		int i = openIndex + 1;

		while (i < content.Length && depth > 0)
		{
			char c = content[i];

			// Skip // comments
			if (c == '/' && i + 1 < content.Length)
			{
				if (content[i + 1] == '/')
				{
					i = content.IndexOf('\n', i + 2);
					if (i == -1) break;
					i++;
					continue;
				}
				// Skip /* */ comments
				if (content[i + 1] == '*')
				{
					i = content.IndexOf("*/", i + 2);
					if (i == -1) break;
					i += 2;
					continue;
				}
			}

			// Skip string/char literals
			if (c == '"' || c == '\'')
			{
				char quote = c;
				i++;
				while (i < content.Length && content[i] != quote)
				{
					if (content[i] == '\\') i++;
					i++;
				}
				i++;
				continue;
			}

			if (c == '{') depth++;
			else if (c == '}') depth--;
			i++;
		}

		return depth == 0 ? i - 1 : -1;
	}

	/// <summary>
	/// Gets all include directives from the HLSL content
	/// </summary>
	private static List<IncludeDirective> GetIncludeDirectives(string content)
	{
		List<IncludeDirective> includes = new List<IncludeDirective>();

		// Match #include "path" or #include <path>
		var includeRegex = new System.Text.RegularExpressions.Regex(@"#include\s*[""<]([^"">\r\n]+)[>""]");
		var matches = includeRegex.Matches(content);

		foreach (System.Text.RegularExpressions.Match match in matches)
		{
			includes.Add(new IncludeDirective
			{
				Path = match.Groups[1].Value,
				Index = match.Index
			});
		}

		return includes;
	}

	/// <summary>
	/// Resolves include paths to actual file system paths
	/// </summary>
	private static string ResolveIncludePath(string includePath, string shaderFilePath)
	{
		// Handle Unity package paths
		if (includePath.StartsWith("Packages/"))
		{
			string packagePath = Path.GetFullPath(Path.Combine(Application.dataPath, "..", includePath));
			if (File.Exists(packagePath))
				return packagePath;
		}

		// Handle Assets paths
		if (includePath.StartsWith("Assets/"))
		{
			string assetsPath = Path.GetFullPath(Path.Combine(Application.dataPath, "..", includePath));
			if (File.Exists(assetsPath))
				return assetsPath;
		}

		// Handle relative paths based on shader file location
		if (!string.IsNullOrEmpty(shaderFilePath))
		{
			string shaderDir = Path.GetDirectoryName(shaderFilePath);
			if (!string.IsNullOrEmpty(shaderDir))
			{
				string relativePath = Path.GetFullPath(Path.Combine(shaderDir, includePath));
				if (File.Exists(relativePath))
					return relativePath;
			}
		}

#if UNITY_EDITOR
		// Try Unity's CGIncludes folder for built-in includes
		string unityEditorPath = Path.GetDirectoryName(UnityEditor.EditorApplication.applicationPath);
		if (!string.IsNullOrEmpty(unityEditorPath))
		{
			string cgIncludePath = Path.Combine(unityEditorPath, "Data", "CGIncludes", includePath);
			if (File.Exists(cgIncludePath))
				return cgIncludePath;
			
			// Also check Resources folder
			string resourcesPath = Path.Combine(unityEditorPath, "Data", "Resources", "PackageManager", "BuiltInPackages", includePath);
			if (File.Exists(resourcesPath))
				return resourcesPath;
		}
#endif

		return null;
	}

	private struct IncludeDirective
	{
		public string Path;
		public int Index;
	}

	private static string ReplaceShaderPath(string input, string newShaderPath)
	{
		const string prefix = "Shader \"Shader Graphs/";
		int startIndex = input.IndexOf(prefix);

		if (startIndex == -1)
			return input; // nothing to replace

		// Find where the path ends (closing quote)
		int endQuoteIndex = input.IndexOf('"', startIndex + prefix.Length);
		if (endQuoteIndex == -1)
			return input; // malformed, just return original

		string replacement = $"Shader \"{newShaderPath}\"";

		return input.Substring(0, startIndex) + replacement + input.Substring(endQuoteIndex + 1);
	}

	public static string ModifyShaderPasses(string shaderCode, string shaderFilePath, string customOptions, string customCode, string includeString, string sharedCode)
	{
		var hlslBlockPattern = new System.Text.RegularExpressions.Regex(@"HLSLPROGRAM([\s\S]*?)ENDHLSL");
		var passNamePattern = new System.Text.RegularExpressions.Regex(@"Name\s+""([^""]+)""");

		var matches = hlslBlockPattern.Matches(shaderCode);

		if (matches.Count == 0)
			return shaderCode;

		var result = new StringBuilder();
		int lastIndex = 0;

		foreach (System.Text.RegularExpressions.Match match in matches)
		{
			var hlslContent      = match.Groups[1].Value;
			var textBeforeBlock  = shaderCode.Substring(0, match.Index); // Look backwards from HLSLPROGRAM to find the nearest pass Name
			var nameMatches      = passNamePattern.Matches(textBeforeBlock);
			var passName         = nameMatches.Count > 0 ? nameMatches[nameMatches.Count - 1].Groups[1].Value : string.Empty;
			var processedContent = ProcessHLSLBlock(passName, hlslContent, shaderFilePath, customOptions, customCode);
			var defineName       = SanitizePassName(passName);
			var passSharedCode   = sharedCode;

			result.Append(shaderCode, lastIndex, match.Index - lastIndex);
			result.Append("HLSLPROGRAM");
			result.Append($"\n#define _SSS_PASS_{defineName} 1\n");

			if (processedContent.Contains("Packages/com.unity.render-pipelines.high-definition") == true)
			{
				result.Append($"\n#define _SSS_HDRP 1\n");
			}
			else if (processedContent.Contains("Packages/com.unity.render-pipelines.universal") == true)
			{
				result.Append($"\n#define _SSS_URP 1\n");
			}
			else if (processedContent.Contains("com.unity.shadergraph/Editor/Generation/Targets/BuiltIn") == true)
			{
				result.Append($"\n#define _SSS_BIRP 1\n");
			}

			if (customCode.Contains("SSS_GetSceneDepth") == true)
			{
				result.Append("\n#define REQUIRE_DEPTH_TEXTURE\n");
			}

			if (customCode.Contains("SSS_GetSceneColor") == true)
			{
				result.Append("\n#define REQUIRE_OPAQUE_TEXTURE\n");
			}

			if (passName.Contains("DXR") == true)
			{
				result.Append($"\n#define _SSS_NO_DERIVATIVES 1\n");
			}
			else
			{
				passSharedCode = passSharedCode.Replace("//SSS_Vert//", "SSS_Vert(v);"); // Replace dummy text with actual call to vertex shader
				passSharedCode = passSharedCode.Replace("//SSS_Frag//", "SSS_Frag(s, d);"); // Replace dummy text with actual call to fragment shader
				passSharedCode = passSharedCode.Replace("//SSS_Include//", customCode); // Replace dummy text with actual shader code
			}

			processedContent = processedContent.Replace(includeString, passSharedCode); // Replace dummy Custom Function node include with actual code

			result.Append(processedContent);
			result.Append("ENDHLSL");

			lastIndex = match.Index + match.Length;
		}

		// Append remaining code after the last block
		result.Append(shaderCode, lastIndex, shaderCode.Length - lastIndex);

		return result.ToString();
	}

	public static string ProcessHLSLBlock(string passName, string hlslContent, string shaderFilePath, string customOptions, string customCode)
	{
		if (customCode.Contains("SSS_FinalColorModifier") == true)
		{
			if (passName == "Pass")
			{
				InjectModifiedFragFunction_BIRP_Unlit(ref hlslContent, shaderFilePath);
			}
			else if (passName == "BuiltIn Forward")
			{
				InjectModifiedFragFunction_BIRP_Lit(ref hlslContent, shaderFilePath);
			}
			else if (passName == "Universal Forward")
			{
				if (IsURP == true) InjectModifiedFragFunction_URP_Lit(ref hlslContent, shaderFilePath);
			}
			else if (passName == "GBuffer")
			{
				if (IsURP == true) InjectModifiedFragFunction_URP_GBuffer(ref hlslContent, shaderFilePath);
			}
			else if (passName == "ForwardOnly")
			{
				if (IsHDRP == true) InjectModifiedFragFunction_HDRP_ForwardOnly(ref hlslContent, shaderFilePath);
			}
			else if (passName == "Forward")
			{
				if (IsHDRP == true) InjectModifiedFragFunction_HDRP_Forward(ref hlslContent, shaderFilePath);
			}
		}

		return hlslContent;
	}

	private static readonly string extraArgPattern1 = @",\s*_FragCustomFunction_[A-Za-z0-9]+_oExtra_[A-Za-z0-9]+,";
	private static readonly string extraArgPattern2 = @",\s*_FragCustomFunction_[A-Za-z0-9_]+_oExtra_[A-Za-z0-9_]+_Matrix4,";

	private static void InjectModifiedFragFunction_BIRP_Unlit(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern1, ", surface.Extra,");

			frag = frag.Replace("frag(", "modified_frag(");
			frag = frag.Replace( "return half4(surfaceDescription.BaseColor, alpha);", "return SSS_FinalColorModifier(half4(surfaceDescription.BaseColor, alpha), surfaceDescription.Extra);");

			hlslContent += "\n" + frag;
		}
	}

	private static void InjectModifiedFragFunction_BIRP_Lit(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = hlslContent.Replace("SurfaceDescriptionFunction(SurfaceDescriptionInputs", "SurfaceDescriptionFunction(inout SurfaceDescriptionInputs");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern1, ", surface.Extra,"); // 2021.3
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern2, ", surface.Extra,"); // 6000.0

			frag = frag.Replace("frag(", "modified_frag(");
			frag = frag.Replace("return color;", "return SSS_FinalColorModifier(color, surfaceDescription.Extra);");
			frag = frag.Replace("InputData inputData;", "InputData inputData;"
				+ "unpacked.positionWS = surfaceDescriptionInputs.WorldSpacePosition;"
				+ "unpacked.normalWS = surfaceDescriptionInputs.WorldSpaceNormal;"
				+ "unpacked.tangentWS.xyz = surfaceDescriptionInputs.WorldSpaceTangent;"
				//+ "unpacked.viewDirectionWS = normalize(_WorldSpaceCameraPos - unpacked.positionWS);"
				);

			hlslContent += "\n" + frag;
		}
	}

	private static void InjectModifiedFragFunction_URP_Lit(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = hlslContent.Replace("SurfaceDescriptionFunction(SurfaceDescriptionInputs", "SurfaceDescriptionFunction(inout SurfaceDescriptionInputs");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern1, ", surface.Extra,");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern2, ", surface.Extra,");

			frag = frag.Replace("frag(", "modified_frag(");

			if (frag.Contains("out float4 outColor") == true)
			{
				frag = frag.Insert(frag.LastIndexOf('}'), "outColor = SSS_FinalColorModifier(outColor, surfaceDescription.Extra);");
			}
			else if (frag.Contains("out half4 outColor") == true)
			{
				frag = frag.Insert(frag.LastIndexOf('}'), "outColor = SSS_FinalColorModifier(outColor, surfaceDescription.Extra);");
			}
			else
			{
				frag = frag.Replace("return color;", "return SSS_FinalColorModifier(color, surfaceDescription.Extra);"); // 2021.3
			}

			// Write back PNT
			var bsd = FindFunction(hlslContent, "BuildSurfaceDescription", shaderFilePath);

			if (string.IsNullOrEmpty(bsd) == false)
			{
				frag = frag.Replace("BuildSurfaceDescription(", "modified_BuildSurfaceDescription(");
				bsd = bsd.Replace("BuildSurfaceDescription(Varyings varyings)", "modified_BuildSurfaceDescription(inout Varyings varyings)");
				bsd = bsd.Replace("return surfaceDescription;",
					"varyings.positionWS = surfaceDescriptionInputs.WorldSpacePosition;" +
					"varyings.normalWS = surfaceDescriptionInputs.WorldSpaceNormal;" +
					"varyings.tangentWS.xyz = surfaceDescriptionInputs.WorldSpaceTangent;" +
					"return surfaceDescription;");

				hlslContent += "\n" + bsd;
			}

			hlslContent += "\n" + frag;
		}
	}

	private static void InjectModifiedFragFunction_URP_GBuffer(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern1, ", surface.Extra,");

			frag = frag.Replace("frag(", "modified_frag(");
			frag = frag.Replace("return PackGBuffersBRDFData(brdfData", "color = SSS_FinalColorModifier(half4(color, 1.0), surfaceDescription.Extra).xyz;\nreturn PackGBuffersBRDFData(brdfData");

			hlslContent += "\n" + frag;
		}
	}

	private static void InjectModifiedFragFunction_HDRP_ForwardOnly(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "Frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment Frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern2, ", surface.Extra,");

			frag = frag.Replace("Frag(", "modified_frag(");

			frag.Insert(frag.LastIndexOf('}'), "outColor = SSS_FinalColorModifier(outColor, surfaceDescription.Extra);");

			hlslContent += "\n" + frag;
		}
	}
		public static bool InjectIntoFunction( ref string fullCode, string functionName, string customCode)
		{
			// Match only the signature + the opening brace
			var pattern = $@"(?<returnType>\w+)\s+{Regex.Escape(functionName)}\s*\((?<params>[^\)]*)\)\s*\{{";
			var match   = Regex.Match(fullCode, pattern, RegexOptions.Singleline);
			if (!match.Success) return false;

			var start = match.Index;
			var openBraceIndex = match.Index + match.Length - 1;

			// Brace matching
			var depth = 0;
			var i = openBraceIndex;
			for (; i < fullCode.Length; i++)
			{
				if (fullCode[i] == '{') depth++;
				else if (fullCode[i] == '}')
				{
					depth--;
					if (depth == 0) break; // Found the closing brace of the function
				}
			}

			if (depth != 0) return false; // malformed code

			// Assemble modified function
			var before = fullCode.Substring(0, start);

			var signature = $"float4x4 {functionName}({match.Groups["params"].Value})";
			var body = fullCode.Substring(openBraceIndex + 1, i - openBraceIndex - 1);

			// ensure newline
			if (!body.EndsWith("\n")) body += "\n";
			var newBody = body + customCode + "\n";

			var after = fullCode.Substring(i + 1);

			fullCode = before + signature + "\n{" + newBody + "}" + after;
			return true;
		}


	private static void InjectModifiedFragFunction_HDRP_Forward(ref string hlslContent, string shaderFilePath)
	{
		var frag = FindFunction(hlslContent, "Frag", shaderFilePath);

		if (string.IsNullOrEmpty(frag) == false)
		{
			hlslContent = hlslContent.Replace("#pragma fragment Frag", "#pragma fragment modified_frag");
			hlslContent = hlslContent.Replace("float3 BaseColor;", "float3 BaseColor; float4x4 Extra;");
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern1, ", surface.Extra,"); // 2021.3
			hlslContent = System.Text.RegularExpressions.Regex.Replace(hlslContent, extraArgPattern2, ", surface.Extra,");
			hlslContent = hlslContent.Replace("SurfaceDescriptionFunction(SurfaceDescriptionInputs", "SurfaceDescriptionFunction(inout SurfaceDescriptionInputs");
			hlslContent = hlslContent.Replace("BuildSurfaceData(fragInputs",
				"fragInputs.positionRWS = surfaceDescriptionInputs.WorldSpacePosition;" + 
				"float3 T_ws = normalize(surfaceDescriptionInputs.WorldSpaceTangent);" +
				"float3 N_ws = normalize(surfaceDescriptionInputs.WorldSpaceNormal);" +
				"T_ws = normalize(T_ws - N_ws * dot(N_ws, T_ws));" +
				"fragInputs.tangentToWorld = float3x3(T_ws, cross(N_ws, T_ws), N_ws);" +
				"BuildSurfaceData(fragInputs");

			InjectIntoFunction(ref hlslContent, "GetSurfaceAndBuiltinData", "return surfaceDescription.Extra;");

			frag = frag.Replace("Frag(", "modified_frag("); // Change frag name to match pragma

			frag = frag.Replace("GetSurfaceAndBuiltinData(input", "float4x4 extra = GetSurfaceAndBuiltinData(input"); // Capture new return value

			frag = frag.Insert(frag.LastIndexOf('}'), "outColor = SSS_FinalColorModifier(outColor, extra);");

			hlslContent += "\n" + frag;
		}
	}

	private static string SanitizePassName(string passName)
	{
		// 1. Convert to uppercase
		string formattedName = passName.ToUpperInvariant();
		
		// 2. Replace any non-alphanumeric/non-underscore characters with an underscore
		StringBuilder sanitized = new StringBuilder();
		foreach (char c in formattedName)
		{
			if (char.IsLetterOrDigit(c) || c == '_')
			{
				sanitized.Append(c);
			}
			else
			{
				// Replace invalid characters with an underscore
				sanitized.Append('_');
			}
		}

		return sanitized.ToString();
	}

	private string GetCustomCode(out string finalProperties, out string finalCbuffer, out string finalDefines, out string finalOptions, out string finalPass, out string finalBlackboard)
	{
		var finalCode = "";

		finalProperties = "";
		finalCbuffer    = "";
		finalDefines    = "";
		finalOptions    = "";
		finalPass       = "";
		finalBlackboard = "";

		foreach (var shaderFile in shaderFiles)
		{
			if (shaderFile != null)
			{
				var path       = UnityEditor.AssetDatabase.GetAssetPath(shaderFile);
				var code       = File.ReadAllText(path);
				var properties = default(string);
				var cbuffer    = default(string);
				var defines    = default(string);
				var options    = default(string);
				var pass       = default(string);
				var blackboard = default(string);

				code = ExtractBlock(code, "BEGIN_PROPERTIES", "END_PROPERTIES", out properties);
				code = ExtractBlock(code, "BEGIN_CBUFFER"   , "END_CBUFFER"   , out cbuffer   );
				code = ExtractBlock(code, "BEGIN_DEFINES"   , "END_DEFINES"   , out defines   );
				code = ExtractBlock(code, "BEGIN_OPTIONS"   , "END_OPTIONS"   , out options   );
				code = ExtractBlock(code, "BEGIN_PASS"      , "END_PASS"      , out pass      );
				code = ExtractBlock(code, "BEGIN_BLACKBOARD", "END_BLACKBOARD", out blackboard);

				finalCode       += code       + "\n";
				finalProperties += properties + "\n";
				finalCbuffer    += cbuffer    + "\n";
				finalDefines    += defines    + "\n";
				finalOptions    += options    + "\n";
				finalPass       += pass       + "\n";
				finalBlackboard += blackboard + "\n";
			}
		}

		return finalCode;
	}

	private static string ExtractBlock(string input, string beginToken, string endToken, out string extracted)
	{
		extracted = string.Empty;

		if (string.IsNullOrEmpty(input) || string.IsNullOrEmpty(beginToken) || string.IsNullOrEmpty(endToken)) return input;

		var beginIndex = input.IndexOf(beginToken);
		if (beginIndex < 0)
			return input; // no begin token found

		var endIndex = input.IndexOf(endToken, beginIndex + beginToken.Length);
		if (endIndex < 0)
			return input; // no end token found

		// Start of the extracted content
		var contentStart = beginIndex + beginToken.Length;

		// Length of the extracted content (exclude tokens)
		var contentLength = endIndex - contentStart;

		extracted = input.Substring(contentStart, contentLength);

		// Remove the whole block including tokens
		var output = input.Remove(beginIndex, (endIndex + endToken.Length) - beginIndex);

		return output;
	}

	public static void FindSharedInclude(string input, out string extractedPath, out string originalIncludeLine)
	{
		extractedPath = null;
		originalIncludeLine = null;

		const string targetEnd = "SSS_Shared.cginc\"";

		int endQuote = input.IndexOf(targetEnd, StringComparison.Ordinal);
		if (endQuote < 0)
			return;

		endQuote += targetEnd.Length - 1;   // point at the final quote
		int openQuote = input.LastIndexOf('"', endQuote - 1);
		if (openQuote < 0)
			return;

		extractedPath = input.Substring(openQuote + 1, endQuote - openQuote - 1);

		int start = input.LastIndexOf("#include", openQuote, StringComparison.Ordinal);
		if (start < 0)
			return;

		int end = endQuote + 1;
		originalIncludeLine = input.Substring(start, end - start);
	}

	private string GetPipelineDefine()
	{
		var crp = UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline;

		if (crp != null)
		{
			var title = crp.GetType().ToString();

			if (title.Contains("Universal") == true)
			{
				return "#define _SSS_URP 1";
			}

			if (title.Contains("HighDefinition") == true)
			{
				return "#define _SSS_HDRP 1";
			}
		}

		return "#define _SSS_BIRP 1";
	}

	public void CheckForChanges()
	{
		if (outputShader != null)
		{
			var path = UnityEditor.AssetDatabase.GetAssetPath(outputShader);

			if (string.IsNullOrEmpty(path) == false)
			{
				if (File.ReadAllText(path).Contains(GenerateChecksumHeader()) == true)
				{
					return;
				}
			}
		}

		Build();
	}

	public string InsertPassBeforeFirstPass(string shaderCode, string customPass)
	{
		if (string.IsNullOrEmpty(shaderCode) || string.IsNullOrEmpty(customPass))
			return shaderCode;

		// Find the first occurrence of "Pass" followed by "{"
		const string passMarker = "Pass";
		int passIndex = shaderCode.IndexOf(passMarker);

		if (passIndex < 0)
			return shaderCode; // No Pass found

		// Ensure the next non-whitespace character is '{'
		int braceIndex = shaderCode.IndexOf('{', passIndex);
		if (braceIndex < 0)
			return shaderCode; // malformed Pass block

		// Insert custom pass BEFORE the found Pass block
		string insertBefore = shaderCode.Substring(0, passIndex);
		string rest = shaderCode.Substring(passIndex);

		customPass = customPass.Replace("HLSLPROGRAM", "HLSLPROGRAM\n" + GetPipelineDefine());

		// Ensure formatting with proper line breaks
		return insertBefore + customPass + "\n\n" + rest;
	}

	[ContextMenu("Build")]
	public void Build()
	{
		#if !__SHADERGRAPH__
			return;
		#endif

		var checksum = GenerateChecksumHeader();
		var code     = CompileShaderGraph(shaderTemplate);

		if (string.IsNullOrEmpty(code) == true)
		{
			Debug.LogError("Error extracting shader " + shaderTemplate); return;
		}

		var path          = UnityEditor.AssetDatabase.GetAssetPath(outputShader);
		var includeString = default(string);
		var includePath   = default(string);

		FindSharedInclude(code, out includePath, out includeString);

		var sharedCode       = File.ReadAllText(includePath);
		var customProperties = default(string);
		var customCbuffer    = default(string);
		var customDefines    = default(string);
		var customOptions    = default(string);
		var customPass       = default(string);
		var customBlackboard = default(string);
		var customCode       = GetCustomCode(out customProperties, out customCbuffer, out customDefines, out customOptions, out customPass, out customBlackboard);

		sharedCode = sharedCode + "\n" + customDefines; // Add defines at top

		sharedCode = sharedCode.Replace("//SSS_Blackboard//", customBlackboard);
		
		code = ModifyShaderPasses(code, path, customOptions, customCode, includeString, sharedCode);

		code = ReplaceShaderPath(code, outputTitle); // Replace shader name with actual name
		code = InsertPassBeforeFirstPass(code, customPass); // Insert custom passes
		code = code.Replace("_SSS_Property(\"SSS_Property\", Float) = 0", customProperties); // Replace dummy shaderlab property with actual properties
		code = code.Replace("float _SSS_Property;", customCbuffer); // Replace dummy cbuffer property with actual cbuffer properties
		code = code.Replace("\r\n", "\n").Replace("\r", "\n"); // Fix line endings

		File.WriteAllText(path, GenerateChecksumHeader() + code);

		UnityEngine.Rendering.RenderPipelineManager.activeRenderPipelineTypeChanged += () => {};

		UnityEditor.AssetDatabase.ImportAsset(path);
	}

	public static string CompileShaderGraph(Shader shader)
	{
		try
		{
			var t = Type.GetType("UnityEditor.ShaderGraph.ShaderGraphImporter, Unity.ShaderGraph.Editor");
			var m = t.GetMethods(BindingFlags.Static | BindingFlags.NonPublic)
				.Where(x => x.Name == "GetShaderText" && x.ReturnType == typeof(string))
				.OrderBy(x => x.GetParameters().Length)
				.First();

			var p = m.GetParameters();
			var a = new object[p.Length]; // Arg count depends on Unity version

			a[0] = UnityEditor.AssetDatabase.GetAssetPath(shader); // We only care about setting the shader path

			return (string)m.Invoke(null, a);
		}
		catch (Exception ex)
		{
			return "Error extracting shader code: " + ex;
		}
	}
#endif
}

#if UNITY_EDITOR
namespace Inspector
{
	using UnityEditor;
	using UnityEditor.UIElements;
	using UnityEngine.UIElements;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SimpleShaderSystem))]
	public class SimpleShaderSystem_Editor : Editor
	{
		private Button CreateBuildButton()
		{
			return new Button(() =>
			{
				serializedObject.ApplyModifiedProperties();

				foreach (var obj in targets)
				{
					if (obj is SimpleShaderSystem system)
					{
						system.Build();
						EditorUtility.SetDirty(system);
					}
				}
			})
			{
				text = "Build"
			};
		}

		private Button CreateBuildAllButton()
		{
			return new Button(() =>
			{
				var guids = AssetDatabase.FindAssets("t:SimpleShaderSystem");

				foreach (var guid in guids)
				{
					var path = AssetDatabase.GUIDToAssetPath(guid);
					var system = AssetDatabase.LoadAssetAtPath<SimpleShaderSystem>(path);

					if (system != null)
					{
						system.Build();
						EditorUtility.SetDirty(system);
					}
				}

				AssetDatabase.SaveAssets();
			})
			{
				text = "Build All"
			};
		}

		public override VisualElement CreateInspectorGUI()
		{
			var root = new VisualElement(); root.style.marginTop = 10; root.style.marginBottom = 10;

			root.Add(new PropertyField(serializedObject.FindProperty("shaderTemplate")));
			root.Add(new PropertyField(serializedObject.FindProperty("shaderFiles")));
			root.Add(new PropertyField(serializedObject.FindProperty("outputShader")));
			root.Add(new PropertyField(serializedObject.FindProperty("outputTitle")));
			root.Add(CreateBuildButton());
			root.Add(CreateBuildAllButton());

			return root;
		}

		[MenuItem("Assets/Create/CW/Simple Shader System/Shader")]
		private static void CreateAsset()
		{
			var guids = Selection.assetGUIDs;
			var path  = guids.Length > 0 ? AssetDatabase.GUIDToAssetPath(guids[0]) : default(string);

			CreateNewAsset(path);
		}

		private static void CreateNewAsset(string path)
		{
			var asset = CreateInstance<SimpleShaderSystem>();
			var name  = "SimpleShader";

			if (string.IsNullOrEmpty(path) == true || path.StartsWith("Library/", System.StringComparison.InvariantCultureIgnoreCase))
			{
				path = "Assets";
			}
			else if (AssetDatabase.IsValidFolder(path) == false)
			{
				path = Path.GetDirectoryName(path);
			}

			var assetPathAndName = AssetDatabase.GenerateUniqueAssetPath(path + "/" + name + ".asset");

			AssetDatabase.CreateAsset(asset, assetPathAndName);

			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh();
			EditorUtility.FocusProjectWindow();

			Selection.activeObject = asset; EditorGUIUtility.PingObject(asset);
		}
	}

	[InitializeOnLoad]
	public class SimpleShaderSystem_Checker : AssetPostprocessor
	{
		static SimpleShaderSystem_Checker()
		{
			UnityEngine.Rendering.RenderPipelineManager.activeRenderPipelineTypeChanged += CheckForChangesAll;

			CheckForChangesAll();
		}

		private static void CheckForChangesAll()
		{
			foreach (string guid in AssetDatabase.FindAssets("t:SimpleShaderSystem"))
			{
				var sss = AssetDatabase.LoadAssetAtPath<SimpleShaderSystem>(AssetDatabase.GUIDToAssetPath(guid));

				if (sss != null)
				{
					sss.CheckForChanges();
				}
			}
		}

		private static void OnPostprocessAllAssets(string[] importedAssetPaths, string[] deletedAssetPaths, string[] movedAssetPaths, string[] movedFromAssetPaths)
		{
			// Associate all shader file paths with SSS
			var pathToShader = new Dictionary<string, List<SimpleShaderSystem>>();

			foreach (string guid in AssetDatabase.FindAssets("t:SimpleShaderSystem"))
			{
				var sss = AssetDatabase.LoadAssetAtPath<SimpleShaderSystem>(AssetDatabase.GUIDToAssetPath(guid));

				if (sss != null)
				{
					foreach (var shaderFile in sss.ShaderFiles)
					{
						if (shaderFile != null)
						{
							var shaderFilePath = AssetDatabase.GetAssetPath(shaderFile);

							if (string.IsNullOrEmpty(shaderFilePath) == false)
							{
								if (pathToShader.ContainsKey(shaderFilePath) == true)
								{
									var list = pathToShader[shaderFilePath];

									if (list.Contains(sss) == false)
									{
										list.Add(sss);
									}
								}
								else
								{
									var list = new List<SimpleShaderSystem>();

									list.Add(sss);

									pathToShader.Add(shaderFilePath, list);
								}
							}
						}
					}
				}
			}

			var pendingUpdate = new HashSet<SimpleShaderSystem>();

			foreach (var importedAssetPath in importedAssetPaths)
			{
				var list = default(List<SimpleShaderSystem>);

				if (pathToShader.TryGetValue(importedAssetPath, out list) == true)
				{
					foreach (var sss in list)
					{
						pendingUpdate.Add(sss);
					}
				}
			}

			foreach (var sss in pendingUpdate)
			{
				sss.Build();
			}
		}
	}
}
#endif