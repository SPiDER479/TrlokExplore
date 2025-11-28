using UnityEngine;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component spawns the specified finger under the screen using a physics raycast.</summary>
	public class CwTapToSpawn : MonoBehaviour
	{
		/// <summary>The finger/mouse/key that triggers the spawning.</summary>
		public CwInputManager.Trigger spawnControls = new CwInputManager.Trigger(true, true, KeyCode.None);

		/// <summary>The prefab this component will be spawned.</summary>
		public GameObject Prefab { set { prefab = value; } get { return prefab; } } [SerializeField] protected GameObject prefab;

		/// <summary>The amount of damage applied to spaceship parts.</summary>
		public float Damage { set { damage = value; } get { return damage; } } [SerializeField] protected float damage;

		/// <summary>The amount of seconds between each spawn if you hold down the mouse/finger.
		/// -1 = Only spawn once per click/tap.</summary>
		public float Interval { set { interval = value; } get { return interval; } } [SerializeField] protected float interval = -1.0f;

		[System.NonSerialized]
		private float cooldown;

		protected virtual void Start()
		{
			CwInputManager.EnsureThisComponentExists();
		}

		protected virtual void Update()
		{
			var fingers = CwInputManager.GetFingers(true);

			foreach (var finger in fingers)
			{
				if (interval >= 0.0f)
				{
					if (spawnControls.IsDown(finger) == true)
					{
						TrySpawn(finger.ScreenPosition);
					}
				}
				else
				{
					if (spawnControls.WentDown(finger) == true)
					{
						TrySpawn(finger.ScreenPosition);
					}
				}
			}

			cooldown -= Time.deltaTime;
		}

		private void TrySpawn(Vector2 screenPosition)
		{
			if (cooldown <= 0.0f)
			{
				cooldown = interval;

				var camera = Camera.main;

				if (camera != null && prefab)
				{
					var ray = camera.ScreenPointToRay(screenPosition);
					var hit = default(RaycastHit);

					if (Physics.Raycast(ray, out hit, 1000.0f, Physics.DefaultRaycastLayers) == true)
					{
						var rotation  = Quaternion.LookRotation(ray.direction, Vector3.up);
						var spaceship = hit.collider.GetComponentInParent<CwLoader>();
						var clone     = Instantiate(prefab, hit.point, rotation);

						clone.gameObject.SetActive(true);

						if (spaceship != null)
						{
							spaceship.DamagePart(hit.collider, damage);
						}
					}
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwTapToSpawn;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwTapToSpawn_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			Draw("spawnControls", "The finger/mouse/key that triggers the spawning.");
			BeginError(Any(tgts, t => t.Prefab == null));
				Draw("prefab", "The prefab this component will be spawned.");
			EndError();
			Draw("damage", "The amount of damage applied to spaceship parts.");
			Draw("interval", "The amount of seconds between each spawn if you hold down the mouse/finger.\n\n-1 = Only spawn once per click/tap.");
		}
	}
}
#endif