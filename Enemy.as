package
{
	import flash.geom.Vector3D;
	
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPCollisionEvent;
	import awayphysics.events.AWPEvent;

	public class Enemy
	{
		private var mesh : Mesh;
		private var collision:AWPRigidBody;
		private var movementSpeed:Number;
		public function Enemy(_mesh:Mesh, spawnPoint:Vector3D, _movementSpeed:Number)
		{
			//trace('new enemy');
			ArtMobile.enemies.push(this);
			mesh = new Mesh(_mesh.geometry, _mesh.material);
			mesh.scale(4);
			mesh.position = spawnPoint.clone();
			ArtMobile.currentScene.addChild(mesh);
			//mesh.translate(mesh.position, 3);
			var handShape:AWPBoxShape = new AWPBoxShape(1, 1, 1);
			var _sphereShape:AWPSphereShape = new AWPSphereShape(20);
			//collision = new AWPRigidBody(handShape, mesh, 0.1);
			collision = new AWPRigidBody(_sphereShape, mesh, 2);
			collision.position = spawnPoint;
			
			//collision = new AWPCollisionObject(_sphereShape, mesh );
			
			
			ArtMobile.physicsWorld.addRigidBody(collision);
			collision.addEventListener(AWPEvent.COLLISION_ADDED, onCollision); 
			collision.applyCentralForce(new Vector3D(2.0, -2.0, -2.9));
			
		}
		public function onCollision(e:AWPEvent):void {
			
		
			
			if(ArtMobile.bullets.indexOf(e.collisionObject) != -1) {
				
				//create Explosion
				ArtMobile.artMobile.createExplosion(mesh.position);
				new ArtMobile.artMobile.ExplodeSound().play();
				
				ArtMobile.enemies.splice(ArtMobile.enemies.indexOf(this),1);
				ArtMobile.currentScene.removeChild(mesh);
				ArtMobile.physicsWorld.removeCollisionObject(collision);
				ArtMobile.artMobile.addToPlayerScore(1);
				ArtMobile.artMobile.addToZombieScore(-1);
			}
		}
		
		public static function interpolate(pt1:Number, pt2:Number, f:Number):Number {
			return f * pt1 + (1 - f) * pt2;
		}
		private var count:Number = 0.2;
		private var currentCount:Number = 1.0;
		private var minCount:Number = 1.0;
		private var maxCount:Number = 2.7;
		public function update(delta:Number):void {
			
			var force:Vector3D = mesh.position.clone();
			force.negate();
			force.normalize();
			force.scaleBy(3);
			collision.applyCentralForce(force);
			//mesh.scale(mesh.scaleX + 1.0);
			if(currentCount > 1.0) {
				count = -0.05;
			}
			if(0.0 > currentCount) {
				count = 0.05;
			}
			currentCount += count;
			//trace(currentCount);
			var scale = interpolate(minCount,maxCount,currentCount);
			collision.scale.x = scale;
			collision.scale.y = scale;
			collision.scale.z = scale;
			collision.rotationX += 1;
			collision.rotationZ += 1;
			if(collision.position.y < 0) {
				collision.position.y = 0;
			}
			//collision.scale(collision.scale);

			//mesh.translate(mesh.position, -3);
			
			if(mesh.position.length < 3.5) {
				ArtMobile.enemies.splice(ArtMobile.enemies.indexOf(this),1);
				ArtMobile.currentScene.removeChild(mesh);
				ArtMobile.physicsWorld.removeCollisionObject(collision);
				ArtMobile.artMobile.addToPlayerScore(-1);
				ArtMobile.artMobile.addToZombieScore(1);
				
			}
			
			//trace('dööörb');
		}
	}
}