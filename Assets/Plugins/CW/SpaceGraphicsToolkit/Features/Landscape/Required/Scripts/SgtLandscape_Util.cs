using Unity.Mathematics;
using Unity.Collections;

namespace SpaceGraphicsToolkit.Landscape
{
	public partial class SgtLandscape
	{
		private static float4 Cubic_Normalized(float v)
		{
			var n = new float4(1.0f, 2.0f, 3.0f, 4.0f) - v;
			var s = n * n * n;

			float4 o;

			o.x = s.x;
			o.y = s.y - 4.0f * s.x;
			o.z = s.z - 4.0f * s.y + 6.0f * s.x;
			o.w = 6.0f - o.x - o.y - o.z;
        
			return o / 6.0f;
		}

		public static float Sample_Cubic_Equirectangular(NativeArray<ushort> data, int2 size, double3 direction)
		{
			var s  = 1.0 / new double2(math.PI * 2.0, math.PI);
			var u  = (math.PI * 1.5 - math.atan2(direction.x, direction.z)) * s.x;
			var v  = (math.asin(direction.y) + math.PI * 0.5) * s.y;
			var uv = new double2(u, v);

			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_WrapX(data, size, x - 1, y - 1), Sample_WrapX(data, size, x + 0, y - 1), Sample_WrapX(data, size, x + 1, y - 1), Sample_WrapX(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_WrapX(data, size, x - 1, y + 0), Sample_WrapX(data, size, x + 0, y + 0), Sample_WrapX(data, size, x + 1, y + 0), Sample_WrapX(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_WrapX(data, size, x - 1, y + 1), Sample_WrapX(data, size, x + 0, y + 1), Sample_WrapX(data, size, x + 1, y + 1), Sample_WrapX(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_WrapX(data, size, x - 1, y + 2), Sample_WrapX(data, size, x + 0, y + 2), Sample_WrapX(data, size, x + 1, y + 2), Sample_WrapX(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Cubic_Equirectangular(NativeArray<byte> data, int2 size, double3 direction)
		{
			var s  = 1.0 / new double2(math.PI * 2.0, math.PI);
			var u  = (math.PI * 1.5 - math.atan2(direction.x, direction.z)) * s.x;
			var v  = (math.asin(direction.y) + math.PI * 0.5) * s.y;
			var uv = new double2(u, v);

			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_WrapX(data, size, x - 1, y - 1), Sample_WrapX(data, size, x + 0, y - 1), Sample_WrapX(data, size, x + 1, y - 1), Sample_WrapX(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_WrapX(data, size, x - 1, y + 0), Sample_WrapX(data, size, x + 0, y + 0), Sample_WrapX(data, size, x + 1, y + 0), Sample_WrapX(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_WrapX(data, size, x - 1, y + 1), Sample_WrapX(data, size, x + 0, y + 1), Sample_WrapX(data, size, x + 1, y + 1), Sample_WrapX(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_WrapX(data, size, x - 1, y + 2), Sample_WrapX(data, size, x + 0, y + 2), Sample_WrapX(data, size, x + 1, y + 2), Sample_WrapX(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Point(NativeArray<ushort> data, int2 size, int x, int y)
		{
			return data[x + y * size.x] / 65535.0f;
		}

		public static float Sample_Cubic(NativeArray<ushort> data, int2 size, double2 uv)
		{
			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_Wrap(data, size, x - 1, y - 1), Sample_Wrap(data, size, x + 0, y - 1), Sample_Wrap(data, size, x + 1, y - 1), Sample_Wrap(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_Wrap(data, size, x - 1, y + 0), Sample_Wrap(data, size, x + 0, y + 0), Sample_Wrap(data, size, x + 1, y + 0), Sample_Wrap(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_Wrap(data, size, x - 1, y + 1), Sample_Wrap(data, size, x + 0, y + 1), Sample_Wrap(data, size, x + 1, y + 1), Sample_Wrap(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_Wrap(data, size, x - 1, y + 2), Sample_Wrap(data, size, x + 0, y + 2), Sample_Wrap(data, size, x + 1, y + 2), Sample_Wrap(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Cubic(NativeArray<byte> data, int2 size, double2 uv)
		{
			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_Wrap(data, size, x - 1, y - 1), Sample_Wrap(data, size, x + 0, y - 1), Sample_Wrap(data, size, x + 1, y - 1), Sample_Wrap(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_Wrap(data, size, x - 1, y + 0), Sample_Wrap(data, size, x + 0, y + 0), Sample_Wrap(data, size, x + 1, y + 0), Sample_Wrap(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_Wrap(data, size, x - 1, y + 1), Sample_Wrap(data, size, x + 0, y + 1), Sample_Wrap(data, size, x + 1, y + 1), Sample_Wrap(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_Wrap(data, size, x - 1, y + 2), Sample_Wrap(data, size, x + 0, y + 2), Sample_Wrap(data, size, x + 1, y + 2), Sample_Wrap(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Cubic_WrapX(NativeArray<ushort> data, int2 size, double2 uv)
		{
			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_WrapX(data, size, x - 1, y - 1), Sample_WrapX(data, size, x + 0, y - 1), Sample_WrapX(data, size, x + 1, y - 1), Sample_WrapX(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_WrapX(data, size, x - 1, y + 0), Sample_WrapX(data, size, x + 0, y + 0), Sample_WrapX(data, size, x + 1, y + 0), Sample_WrapX(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_WrapX(data, size, x - 1, y + 1), Sample_WrapX(data, size, x + 0, y + 1), Sample_WrapX(data, size, x + 1, y + 1), Sample_WrapX(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_WrapX(data, size, x - 1, y + 2), Sample_WrapX(data, size, x + 0, y + 2), Sample_WrapX(data, size, x + 1, y + 2), Sample_WrapX(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Cubic_WrapX(NativeArray<byte> data, int2 size, double2 uv)
		{
			var pixelCoords = uv * size - 0.5;
			var x           = (long)math.floor(pixelCoords.x);
			var y           = (long)math.floor(pixelCoords.y);
			var weightsX    = Cubic_Normalized((float)(pixelCoords.x - x));
			var weightsY    = Cubic_Normalized((float)(pixelCoords.y - y));
			var rowA        = new float4(Sample_WrapX(data, size, x - 1, y - 1), Sample_WrapX(data, size, x + 0, y - 1), Sample_WrapX(data, size, x + 1, y - 1), Sample_WrapX(data, size, x + 2, y - 1));
			var rowB        = new float4(Sample_WrapX(data, size, x - 1, y + 0), Sample_WrapX(data, size, x + 0, y + 0), Sample_WrapX(data, size, x + 1, y + 0), Sample_WrapX(data, size, x + 2, y + 0));
			var rowC        = new float4(Sample_WrapX(data, size, x - 1, y + 1), Sample_WrapX(data, size, x + 0, y + 1), Sample_WrapX(data, size, x + 1, y + 1), Sample_WrapX(data, size, x + 2, y + 1));
			var rowD        = new float4(Sample_WrapX(data, size, x - 1, y + 2), Sample_WrapX(data, size, x + 0, y + 2), Sample_WrapX(data, size, x + 1, y + 2), Sample_WrapX(data, size, x + 2, y + 2));

			return math.dot(new float4(math.dot(rowA, weightsX), math.dot(rowB, weightsX), math.dot(rowC, weightsX), math.dot(rowD, weightsX)), weightsY);
		}

		public static float Sample_Linear(NativeArray<ushort> data, int2 size, double2 pixel)
		{
			var fracX = (float)((pixel.x % 1.0 + 1.0) % 1.0);
			var fracY = (float)((pixel.y % 1.0 + 1.0) % 1.0);
			var x     = (long)math.floor(pixel.x % size.x);
			var y     = (long)math.floor(pixel.y % size.y);

			var bl0 = Sample_Wrap(data, size, x    , y    );
			var br0 = Sample_Wrap(data, size, x + 1, y    );
			var tl0 = Sample_Wrap(data, size, x    , y + 1);
			var tr0 = Sample_Wrap(data, size, x + 1, y + 1);

			var b0 = math.lerp(bl0, br0, fracX);
			var t0 = math.lerp(tl0, tr0, fracX);

			return math.lerp(b0, t0, fracY);
		}

		public static float Sample_Linear(NativeArray<byte> data, int2 size, double2 pixel)
		{
			var fracX = (float)((pixel.x % 1.0 + 1.0) % 1.0);
			var fracY = (float)((pixel.y % 1.0 + 1.0) % 1.0);
			var x     = (long)math.floor(pixel.x % size.x);
			var y     = (long)math.floor(pixel.y % size.y);

			var bl0 = Sample_Wrap(data, size, x    , y    );
			var br0 = Sample_Wrap(data, size, x + 1, y    );
			var tl0 = Sample_Wrap(data, size, x    , y + 1);
			var tr0 = Sample_Wrap(data, size, x + 1, y + 1);

			var b0 = math.lerp(bl0, br0, fracX);
			var t0 = math.lerp(tl0, tr0, fracX);

			return math.lerp(b0, t0, fracY);
		}

		public static float Sample_Linear_Clamp(NativeArray<ushort> data, int2 size, double2 pixel)
		{
			var fracX = (float)((pixel.x % 1.0 + 1.0) % 1.0);
			var fracY = (float)((pixel.y % 1.0 + 1.0) % 1.0);
			var x     = (long)math.floor(pixel.x % size.x);
			var y     = (long)math.floor(pixel.y % size.y);

			var bl0 = Sample_Clamp(data, size, x    , y    );
			var br0 = Sample_Clamp(data, size, x + 1, y    );
			var tl0 = Sample_Clamp(data, size, x    , y + 1);
			var tr0 = Sample_Clamp(data, size, x + 1, y + 1);

			var b0 = math.lerp(bl0, br0, fracX);
			var t0 = math.lerp(tl0, tr0, fracX);

			return math.lerp(b0, t0, fracY);
		}

		public static float Sample_Linear_Clamp(NativeArray<byte> data, int2 size, double2 pixel)
		{
			var fracX = (float)((pixel.x % 1.0 + 1.0) % 1.0);
			var fracY = (float)((pixel.y % 1.0 + 1.0) % 1.0);
			var x     = (long)math.floor(pixel.x % size.x);
			var y     = (long)math.floor(pixel.y % size.y);

			var bl0 = Sample_Clamp(data, size, x    , y    );
			var br0 = Sample_Clamp(data, size, x + 1, y    );
			var tl0 = Sample_Clamp(data, size, x    , y + 1);
			var tr0 = Sample_Clamp(data, size, x + 1, y + 1);

			var b0 = math.lerp(bl0, br0, fracX);
			var t0 = math.lerp(tl0, tr0, fracX);

			return math.lerp(b0, t0, fracY);
		}

		public static float Sample_WrapX(NativeArray<ushort> data, int2 size, long x, long y)
		{
			x = (x % size.x + size.x) % size.x;
			y = math.clamp(y, 0, size.y - 1);

			return data[(int)x + (int)y * size.x] / 65535.0f;
		}

		public static float Sample_WrapX(NativeArray<byte> data, int2 size, long x, long y)
		{
			x = (x % size.x + size.x) % size.x;
			y = math.clamp(y, 0, size.y - 1);

			return data[(int)x + (int)y * size.x] / 255.0f;
		}

		public static float Sample_Clamp(NativeArray<ushort> data, int2 size, long x, long y)
		{
			x = math.clamp(x, 0, size.x - 1);
			y = math.clamp(y, 0, size.y - 1);

			return data[(int)x + (int)y * size.x] / 65535.0f;
		}

		public static float Sample_Clamp(NativeArray<byte> data, int2 size, long x, long y)
		{
			x = math.clamp(x, 0, size.x - 1);
			y = math.clamp(y, 0, size.y - 1);

			return data[(int)x + (int)y * size.x] / 255.0f;
		}

		public static float Sample_Wrap(NativeArray<ushort> data, int2 size, long x, long y)
		{
			x = (x % size.x + size.x) % size.x;
			y = (y % size.y + size.y) % size.y;

			return data[(int)x + (int)y * size.x] / 65535.0f;
		}

		public static float Sample_Wrap(NativeArray<byte> data, int2 size, long x, long y)
		{
			x = (x % size.x + size.x) % size.x;
			y = (y % size.y + size.y) % size.y;

			return data[(int)x + (int)y * size.x] / 255.0f;
		}

		public static double4 GetEquirectangularCoord(double3 direction)
		{
			var u = math.atan2(direction.z, direction.x) / (math.PI_DBL * 2.0) + 0.5;
			var v = math.asin(direction.y) / math.PI_DBL + 0.5;
			var w = direction.y * 0.3 + 0.5;

			return new double4(u, v, u, w);
		}
	}
}