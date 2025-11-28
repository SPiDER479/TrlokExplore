using UnityEngine;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add a texture to a <b>SgtCloudBundle</b>.</summary>
	public abstract class SgtCloudBundleSlice : MonoBehaviour
	{
		public class SliceInstance
		{
			public SgtCloudBundleSlice Parent;

			[System.NonSerialized]
			public int CreatedHeight;

			[System.NonSerialized]
			public Vector2 CreatedLocation;

			[System.NonSerialized]
			public int CreatedOffset;
		}

		public abstract SliceInstance TryCreate(int width, int offset);

		public abstract void Write(SliceInstance sliceInstance, RenderTexture target);

		public abstract void Dispose(SliceInstance sliceInstance);

		public abstract void HandleLateUpdate(SliceInstance sliceInstance, RenderTexture target);

		[System.NonSerialized]
		protected List<SliceInstance> sliceInstances = new List<SliceInstance>();
	}
}