using UnityEngine;
using Unity.Mathematics;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>Physically-based buoyancy.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Ocean Buoyancy")]
	[RequireComponent(typeof(Rigidbody))]
	public class SgtOceanBuoyancy : MonoBehaviour
	{
		/// <summary>The ocean that will apply buoyancy to this Rigidbody.
		/// None/null = The nearest one will be used.</summary>
		public SgtOcean Ocean { set { ocean = value; } get { return ocean; } } [SerializeField] private SgtOcean ocean;

		/// <summary>The radius of the buoyancy probes.</summary>
		public float ProbeRadius { set { probeRadius = value; } get { return probeRadius; } } [SerializeField] private float probeRadius = 0.5f;

		/// <summary>The local offsets of the buoyancy probes.</summary>
		public List<Vector3> ProbeOffsets { get { ValidateProbeOffsets(); return probeOffsets; } } [SerializeField] private List<Vector3> probeOffsets;

		/// <summary>The linear drag applied when submerged.</summary>
		public float LinearDrag { set { linearDrag = value; } get { return linearDrag; } } [SerializeField] private float linearDrag = 3.0f;

		/// <summary>The rotational drag applied when submerged.</summary>
		public float AngularDrag { set { angularDrag = value; } get { return angularDrag; } } [SerializeField] private float angularDrag = 1.0f;

		/// <summary>The quadratic impact drag applied when hitting the water.</summary>
		public float SlamDrag { set { slamDrag = value; } get { return slamDrag; } } [SerializeField] private float slamDrag = 0.5f;

		[System.NonSerialized]
		private Rigidbody cachedRigidbody;

		public void ValidateProbeOffsets()
		{
			if (probeOffsets == null)
			{
				probeOffsets = new List<Vector3>();
			}

			if (probeOffsets.Count == 0)
			{
				probeOffsets.Add(Vector3.zero);
			}
		}

		protected virtual void OnEnable()
		{
			cachedRigidbody = GetComponent<Rigidbody>();
		}

		protected virtual void FixedUpdate()
		{
			if (ocean == null) ocean = SgtOcean.FindNearest(transform.position);
			if (ocean == null) return;

			var worldPos   = transform.position;
			var waveResult = ocean.CalculateWaves(worldPos);
			var gravity    = Physics.gravity.magnitude;

			// waveResult.HeightAboveWater is (pos.y - water.y)
			// h is the submerged height: 0 at the bottom tip, 2*r at full submersion
			var h = Mathf.Clamp(probeRadius - waveResult.HeightAboveWater, 0.0f, 2.0f * probeRadius);

			if (h <= 0.0f) return;

			// 1. Spherical Cap Volume: V = (pi * h^2 / 3) * (3r - h)
			// This provides a realistic S-curve for buoyancy force.
			var submergedVolume = (Mathf.PI * h * h / 3.0f) * (3.0f * probeRadius - h);
	
			// 2. Buoyancy Force Calculation
			var buoyancy = waveResult.Up * (ocean.FluidDensity * gravity * submergedVolume);
			cachedRigidbody.AddForce(buoyancy, ForceMode.Force);

			// 3. Hydrodynamic Damping
			var totalVolume     = (4.0f / 3.0f) * Mathf.PI * probeRadius * probeRadius * probeRadius;
			var submersionRatio = submergedVolume / totalVolume;

			#if UNITY_6000_0_OR_NEWER || UNITY_6_0_OR_NEWER
				var velocity = cachedRigidbody.linearVelocity;
			#else
				var velocity = cachedRigidbody.velocity;
			#endif

			// Applying linear and quadratic (slam) drag scaled by submersion kills the "bobbing".
			var dragForce = -velocity * (linearDrag + slamDrag * velocity.magnitude) * submersionRatio;

			cachedRigidbody.AddForce(dragForce, ForceMode.Force);
			cachedRigidbody.AddTorque(-cachedRigidbody.angularVelocity * angularDrag * submersionRatio, ForceMode.Force);
		}

		protected virtual void OnDrawGizmosSelected()
		{
			if (probeOffsets != null)
			{
				for (var i = 0; i < probeOffsets.Count; i++)
				{
					Gizmos.DrawWireSphere(transform.TransformPoint(probeOffsets[i]), probeRadius);
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Ocean
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtOceanBuoyancy))]
	public class SgtOceanBuoyancy_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtOceanBuoyancy tgt; SgtOceanBuoyancy[] tgts; GetTargets(out tgt, out tgts);

			Draw("ocean", "The ocean that will apply buoyancy to this Rigidbody.\n\nNone/null = The nearest one will be used.");
			
			Separator();

			Draw("probeRadius", "The radius of the buoyancy probes.");
			Draw("probeOffsets", "The local offsets of the buoyancy probes.");

			Separator();

			Draw("linearDrag", "The linear drag applied when submerged.");
			Draw("angularDrag", "The rotational drag applied when submerged.");
			Draw("slamDrag", "The quadratic impact drag applied when hitting the water.");
		}
	}
}
#endif