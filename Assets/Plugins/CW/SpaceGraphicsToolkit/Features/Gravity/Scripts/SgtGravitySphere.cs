using UnityEngine;
using Unity.Mathematics;
using Unity.Collections;
using Unity.Jobs;
using Unity.Burst;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Gravity
{
	/// <summary>This component applies physically accurate spherical gravity and atmospheric drag that behaves like Unity's built-in Rigidbody drag.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Gravity Sphere")]
	public class SgtGravitySphere : MonoBehaviour
	{
		[BurstCompile]
		public struct PlanetData
		{
			public double4x4 WorldToLocal;
			public double4x4 LocalToWorld;
			public double    Mass;
			public double    Drag;
			public double    AngularDrag;
			public double    Radius;
			public double    Height;
		}

		[BurstCompile]
		public struct BodyData
		{
			public double3 WorldPosition;
			public double3 WorldVelocity;
			public double3 WorldAngularVelocity;
			public double  Mass;
			public double  LinearDragMult;
			public double  AngularDragMult;
			public float3  ResultWorldForce;
			public float3  ResultWorldTorque;
		}

		public static LinkedList<SgtGravitySphere> Instances = new LinkedList<SgtGravitySphere>();

		[System.NonSerialized] private LinkedListNode<SgtGravitySphere> node;

		/// <summary>The mass of this gravity source in kilograms.</summary>
		public float Mass { set { mass = value; } get { return mass; } } [SerializeField] private float mass = 5.972e+24f;

		/// <summary>The linear drag coefficient.</summary>
		public float Drag { set { drag = value; } get { return drag; } } [SerializeField] private float drag = 1.0f;

		/// <summary>The angular drag coefficient.</summary>
		public float AngularDrag { set { angularDrag = value; } get { return angularDrag; } } [SerializeField] private float angularDrag = 0.1f;

		/// <summary>The local radius of the planet's surface.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] private float radius;

		/// <summary>The local height of the atmosphere above the surface.</summary>
		public float Height { set { height = value; } get { return height; } } [SerializeField] private float height;

		public const double G = 6.67430e-11;

		private static NativeList<PlanetData> planetBuffer;
		private static NativeList<BodyData>   bodyBuffer;
		private static List<Rigidbody>        bodyReferences = new List<Rigidbody>();

		[BurstCompile]
		struct GravityJob : IJobParallelFor
		{
			[ReadOnly] public NativeArray<PlanetData> Planets;
			public NativeArray<BodyData> Bodies;
			public float DeltaTime;

			public void Execute(int index)
			{
				var body        = Bodies[index];
				var totalForce  = double3.zero;
				var totalTorque = double3.zero;

				for (var i = 0; i < Planets.Length; i++)
				{
					var planet   = Planets[i];
					var localPos = math.transform(planet.WorldToLocal, body.WorldPosition);
					var dist     = math.length(localPos);

					// Gravity Calculation
					if (dist > 0.0001)
					{
						var accel     = (G * planet.Mass) / (dist * dist);
						var localDir  = math.normalize(-localPos);
						var localGrav = localDir * (accel * body.Mass);

						totalForce += math.rotate(planet.LocalToWorld, localGrav);
					}

					// Atmosphere Logic
					var intensity = 0.0;
					if (planet.Height > 0.0)
					{
						var altitude = dist - planet.Radius;
						if (altitude < planet.Height)
						{
							intensity = math.pow(math.clamp(1.0 - (altitude / planet.Height), 0.0, 1.0), 3.0);
						}
					}

					if (intensity > 0.0)
					{
						// Linear Drag matching Unity formula
						var effectiveDrag = planet.Drag * body.LinearDragMult;
						if (effectiveDrag > 0.0)
						{
							var dragForce = (body.WorldVelocity * effectiveDrag * intensity) / (1.0 + effectiveDrag * intensity * DeltaTime);
							totalForce -= dragForce * body.Mass;
						}

						// Angular Drag matching Unity formula
						var effectiveAngularDrag = planet.AngularDrag * body.AngularDragMult;
						if (effectiveAngularDrag > 0.0)
						{
							var dragTorque = (body.WorldAngularVelocity * effectiveAngularDrag * intensity) / (1.0 + effectiveAngularDrag * intensity * DeltaTime);
							totalTorque -= dragTorque * body.Mass;
						}
					}
				}

				body.ResultWorldForce  = (float3)totalForce;
				body.ResultWorldTorque = (float3)totalTorque;
				Bodies[index]          = body;
			}
		}

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);
			if (Instances.Count == 1)
			{
				planetBuffer = new NativeList<PlanetData>(16,  Allocator.Persistent);
				bodyBuffer   = new NativeList<BodyData>  (128, Allocator.Persistent);
			}
		}

		protected virtual void OnDisable()
		{
			Instances.Remove(node);
			if (Instances.Count == 0)
			{
				if (planetBuffer.IsCreated) planetBuffer.Dispose();
				if (bodyBuffer.IsCreated) bodyBuffer.Dispose();
				bodyReferences.Clear();
			}
		}

		protected virtual void FixedUpdate()
		{
			if (Instances.First != node) return;
			if (SgtGravityRigidbody.Instances.Count == 0) return;

			planetBuffer.Clear();
			bodyBuffer.Clear();
			bodyReferences.Clear();

			foreach (var planet in Instances)
			{
				planetBuffer.Add(new PlanetData
				{
					WorldToLocal = new double4x4(planet.transform.worldToLocalMatrix),
					LocalToWorld = new double4x4(planet.transform.localToWorldMatrix),
					Mass         = planet.Mass,
					Drag         = planet.Drag,
					AngularDrag  = planet.AngularDrag,
					Radius       = planet.Radius,
					Height       = planet.Height
				});
			}

			foreach (var body in SgtGravityRigidbody.Instances)
			{
				bodyBuffer.Add(new BodyData
				{
					WorldPosition        = (double3)(float3)body.CachedRigidbody.position,
					WorldAngularVelocity = (double3)(float3)body.CachedRigidbody.angularVelocity,
					Mass                 = body.CachedRigidbody.mass,
					LinearDragMult       = body.LinearDragMultiplier,
					AngularDragMult      = body.AngularDragMultiplier,
#if UNITY_6000_0_OR_NEWER || UNITY_6_0_OR_NEWER
					WorldVelocity        = (double3)(float3)body.CachedRigidbody.linearVelocity
#else
					WorldVelocity        = (double3)(float3)body.CachedRigidbody.velocity
#endif
				});
				bodyReferences.Add(body.CachedRigidbody);
			}

			new GravityJob
			{
				Planets   = planetBuffer.AsArray(),
				Bodies    = bodyBuffer.AsArray(),
				DeltaTime = Time.fixedDeltaTime
			}.Schedule(bodyBuffer.Length, 32).Complete();

			for (var i = 0; i < bodyReferences.Count; i++)
			{
				bodyReferences[i].AddForce((Vector3)bodyBuffer[i].ResultWorldForce, ForceMode.Force);
				bodyReferences[i].AddTorque((Vector3)bodyBuffer[i].ResultWorldTorque, ForceMode.Force);
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			if (radius <= 0 && height <= 0) return;
			Gizmos.matrix = transform.localToWorldMatrix;
			Gizmos.color  = new Color(0, 1, 1, 0.4f);
			Gizmos.DrawWireSphere(Vector3.zero, radius);
			Gizmos.color  = new Color(0, 1, 1, 0.15f);
			Gizmos.DrawWireSphere(Vector3.zero, radius + height);
		}
#endif
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Gravity
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtGravitySphere))]
	public class SgtGravitySphere_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtGravitySphere tgt; SgtGravitySphere[] tgts; GetTargets(out tgt, out tgts);

			Draw("mass", "The mass of the planet in kilograms.");
			Draw("drag", "The linear drag coefficient (Matches Rigidbody.linearDrag).");
			Draw("angularDrag", "The angular drag coefficient (Matches Rigidbody.angularDrag).");

			Separator();

			Draw("radius", "The local radius of the planet's surface.");
			Draw("height", "The local height of the atmosphere above the surface.");

			Separator();

			EditorGUILayout.LabelField("Mass Examples (kg):", EditorStyles.boldLabel);
			if (Button("Earth (5.97e+24)")) { Each(tgts, t => t.Mass = 5.972e+24f, true); }
			if (Button("Moon (7.34e+22)"))  { Each(tgts, t => t.Mass = 7.347e+22f, true); }
			if (Button("Mars (6.39e+23)"))  { Each(tgts, t => t.Mass = 6.39e+23f,  true); }
			if (Button("Sun (1.98e+30)"))   { Each(tgts, t => t.Mass = 1.989e+30f, true); }

			if (SgtGravityRigidbody.Instances.Count == 0)
			{
				Warning("No SgtGravityRigidbody found in scene.");
			}
		}
	}
}
#endif