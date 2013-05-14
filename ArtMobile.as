//test
package
{
	import art.CModule;
	import art.FlashEcho;
	import art.FlashSetup;
	import art.FlashTick;
	import art.vfs.RootFSBackingStore;
	
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.Vector3DUtils;
	import away3d.core.sort.RenderableMergeSort;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.lights.PointLight;
	import away3d.loaders.*;
	import away3d.loaders.misc.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.primitives.data.NURBSVertex;
	import away3d.textures.BitmapTexture;
	import away3d.textures.PlanarReflectionTexture;
	import away3d.textures.WebcamTexture;
	import away3d.tools.helpers.*;
	import away3d.utils.*;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.*;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.*;
	import awayphysics.events.AWPEvent;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.*;
	import flash.display.Sprite;
	import flash.display3D.Context3DCompareMode;
	import flash.events.*;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.*;
	import flash.media.Camera;
	import flash.media.Sound;
	import flash.media.Video;
	import flash.net.*;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.*;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.*;
	
	
	[SWF(backgroundColor="#000000", frameRate="20")]
	
	
	public class ArtMobile extends Sprite
	{
		// awesome comment
		
		private var playTime:int = 20;
		// text
		private var textFormat:TextFormat;
		// physics
		private var physicsWorld:AWPDynamicsWorld;
		private var debugDraw:AWPDebugDraw;
		private static var timeStep:Number = 1.0 / 20;
		private static var gravity:Number = 10;
		private static var size:Number = 2;
		private static var rigidObjectsFriction:Number = 1;
		private static var rigidObjectsMass:Number = 5;
		private static var rigidObjectsDamping:Number = 0.9;
		private static var rigidObjectsResitution:Number = 0.5;
		private var orginalMaterial:ColorMaterial;
		private var bodiesMaterial:Vector.<ColorMaterial>;
		
		private var groundVertices:Vector.<NURBSVertex>;
		private var groundNurbs:NURBSGeometry;
		
		private var boxes:Vector.<AWPCollisionObject>;
		private var rigidObjects:Vector.<AWPRigidBody>;
		private var groundMesh :Mesh;
		private var groundRigidbody:AWPRigidBody;
		private var handMesh :Mesh;
		private var handRigidbody:AWPRigidBody;
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var mylightP:PointLight;
		private var lightP:PointLight;
		//light objects
		private var light:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		private var lightDirection:Vector3D;
		
		//material objects
		private var materialR:ColorMaterial;
		private var materialG:ColorMaterial;
		private var materialB:ColorMaterial;
		private var materialY:ColorMaterial;
		private var materialWR:ColorMaterial;
		private var materialWG:ColorMaterial;
		private var materialWB:ColorMaterial;
		private var materialW:ColorMaterial;
		private var materialLast:MaterialBase;
		private var material:MaterialBase;
		private var texturemat:TextureMaterial;
		
		private var arTracker:ARTracker;
		
		// embed
		[Embed (source="./data/newLevel.mp3" )]
		private var NewLevel : Class;
		
		[Embed (source="./data/gameOver.mp3" )]
		private var GameOver : Class;
		
		//[Embed(source="C:/WINDOWS/Fonts/RAVIE.TTF", fontFamily="MyFont",fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true",  embedAsCFF="false")]
		//private var MyFont:Class;
		
		
		public function ArtMobile():void
		{
			trace("hello world");
			
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			
			//Font.registerFont(MyFont);
			textFormat = new TextFormat();
			textFormat.size = 10;
			textFormat.color = 0xAAAAAA;
			textFormat.font = "MyFont"
		    textFormat.bold = true;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			addEventListener(Event.ADDED_TO_STAGE, initStage);
		}
		
		private function initStage(e:Event):void
		{
			trace("initStage");
			removeEventListener(Event.ADDED_TO_STAGE, initStage);
			
			/////////////// init scenegraph /////////////////
			init3D();
			initMaterials();
			initPhysicsScene();
			initEvents();
		}
		
		private function initMaterials():void{
			materialR = new ColorMaterial(0xCC0000);
			materialR.lightPicker = lightPicker;
			materialG = new ColorMaterial(0x00CC00);
			materialG.lightPicker = lightPicker;
			materialB = new ColorMaterial(0x0000CC);
			materialB.lightPicker = lightPicker;
			materialY = new ColorMaterial(0xFFFF00);
			materialY.lightPicker = lightPicker;
			materialW = new ColorMaterial(0xAAAAAA);
			materialW.lightPicker = lightPicker;
			materialWR = new ColorMaterial(0xFF0000);
			materialWR.lightPicker = lightPicker;
			materialWG = new ColorMaterial(0x00FF00);
			materialWG.lightPicker = lightPicker;
			materialWB = new ColorMaterial(0x0000FF);
			materialWB.lightPicker = lightPicker;
		}
		
		private function initEvents():void{
			//////////////// setup events /////////////
			
			//////////////// stage rendering //////////////////// 
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(Event.ENTER_FRAME, render);
			
			//////////////// tracker //////////////////// 
			arTracker.addEventListener(TrackEvent.ON_MARKER_FRAME, trackingData);
			
			//////////////// timer //////////////////// 
			var playTimer:Timer=new Timer(1000,0);
			playTimer.addEventListener(TimerEvent.TIMER, playTimerHandler);
			playTimer.start();
		}
		
		private function init3D():void{
			//////////////// init tracker //////////////////// 
			arTracker = new ARTracker();
			
			//////////////// init view //////////////////// 
			view = new View3D();

			view.background= arTracker.videoBackground;
			view.camera.lens = new PerspectiveLens(29.8);
			view.camera.lens.near = 10;
			view.camera.lens.far = 2000;
			
			var eps:Number = 0.00000001;
			view.camera.x = eps;
			view.camera.y = eps;
			view.camera.z = eps;
			
			this.addChild(view);
			var awayStats:AwayStats = new AwayStats(view)
			awayStats.x = 150;
			awayStats.y = 100;
			this.addChild(awayStats);	
			
			//setup the light for the scene
			light = new DirectionalLight();
			lightPicker = new StaticLightPicker([light]);
			lightDirection = new Vector3D(0, 0, -1);
			view.scene.addChild(light);
			
			//////////////// init the physics world //////////////////// 
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			physicsWorld.collisionCallbackOn = true;
			physicsWorld.gravity = new Vector3D(0,0,-gravity);
			
			debugDraw = new AWPDebugDraw(view, physicsWorld); 
			//debugDraw.debugMode |= AWPDebugDraw.DBG_DrawRay;
			debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
		}
		
		private function initPhysicsScene():void
		{
			// create ground shape and rigidbody
			materialY.alpha = 0.5;
			materialY.alphaBlending = true;
			
			// add some writing on the ground
			var txtSprite:Sprite = new Sprite();
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.text =  "Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World ";
			textField.defaultTextFormat = textFormat;
			textField.setTextFormat(textFormat);
			textField.background = false;
			textField.selectable = false;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.width = 160;
			textField.height = 160;
			textField.x = 5;
			textField.y = 5;
			
			// add text to the stage
			stage.addChild(textField);
			
			// add text to texture
			txtSprite.addChild(textField);
			var bmpTxt:BitmapData = new BitmapData(128, 128, false, 0x000000);
			bmpTxt.draw(txtSprite, null, null, "normal", null, true);
			var textBitmap:BitmapTexture = new BitmapTexture(bmpTxt);
			var txMat:TextureMaterial = new TextureMaterial(textBitmap);
			// show text texture on billboard
			var sprite3d:Sprite3D = new Sprite3D(txMat,32,32);
			sprite3d.z = 50;
			
			// add text texture to groundplane
			groundMesh = new Mesh(new CubeGeometry(60, 60, 2), txMat);
			groundMesh.mouseEnabled = true;
			view.scene.addChild(groundMesh);
			var groundShape:AWPBoxShape = new AWPBoxShape(60, 60, 2);
			groundRigidbody = new AWPRigidBody(groundShape, groundMesh, 0);
			physicsWorld.addRigidBody(groundRigidbody);
			
			// add bilboard to ground marker
			groundMesh.addChild(sprite3d);
			
			// add arrows to ground marker
			var arrows:Trident = new Trident(40, true);
			groundMesh.addChild(arrows);
			
			materialR.alpha = 0.5;
			materialR.alphaBlending = true;
			handMesh = new Mesh(new CubeGeometry(60, 60, 2), materialR);
			handMesh.mouseEnabled = true;
			view.scene.addChild(handMesh);
			var handShape:AWPBoxShape = new AWPBoxShape(60, 60, 2);
			handRigidbody = new AWPRigidBody(handShape, handMesh, 0);
			physicsWorld.addRigidBody(handRigidbody);
			
			// add wireframegrid and arrows to hand marker
			var arrowsHand:Trident = new Trident(40, true);
			handMesh.addChild(arrowsHand);
			var axis:WireframeAxesGrid = new WireframeAxesGrid(10,60);
			handMesh.addChild(axis);
			
			
			// create rigid objects
			rigidObjects = new Vector.<AWPRigidBody>();
			// create rigidbody shapes
			var boxShape : AWPBoxShape = new AWPBoxShape(10*size, 10*size, 10*size);
			var boxShape30 : AWPBoxShape = new AWPBoxShape(10*size, 10*size, 10*size);
			var cylinderShape : AWPCylinderShape = new AWPCylinderShape(5*size, 10*size);
			var coneShape : AWPConeShape = new AWPConeShape(5*size, 10*size);
			var sphereShape : AWPSphereShape = new AWPSphereShape(5*size);
			// create rigidbodies
			var mesh : Mesh;
			var body : AWPRigidBody;
			for (var i : int; i < 4; i++ ) {
				// create boxes
				mesh = new Mesh(new CubeGeometry(10*size, 10*size, 10*size), materialG);
				view.scene.addChild(mesh);
				body = new AWPRigidBody(boxShape, mesh, rigidObjectsMass);
				body.friction = rigidObjectsFriction;
				body.linearDamping = rigidObjectsDamping;
				body.restitution = rigidObjectsResitution;
				body.position = new Vector3D(0,0,-100);
				physicsWorld.addRigidBody(body);
				rigidObjects.push(body);
				// create cylinders
				mesh = new Mesh(new CylinderGeometry(5*size, 5*size, 10*size) ,materialG);
				view.scene.addChild(mesh);
				body = new AWPRigidBody(cylinderShape, mesh, rigidObjectsMass);
				body.friction = rigidObjectsFriction;
				body.linearDamping = rigidObjectsDamping;
				body.restitution = rigidObjectsResitution;
				body.position = new Vector3D(0,0,-100);
				physicsWorld.addRigidBody(body);
				rigidObjects.push(body);
				// create the Cones
				mesh = new Mesh(new ConeGeometry(5*size, 10*size),materialG);
				view.scene.addChild(mesh);
				body = new AWPRigidBody(coneShape, mesh, rigidObjectsMass);
				body.friction = rigidObjectsFriction;
				body.linearDamping = rigidObjectsDamping;
				body.restitution = rigidObjectsResitution;
				body.position = new Vector3D(0,0,-100);
				physicsWorld.addRigidBody(body);
				rigidObjects.push(body);
				// create the Speres
				mesh = new Mesh(new SphereGeometry(5*size),materialG);
				view.scene.addChild(mesh);
				body = new AWPRigidBody(sphereShape, mesh, rigidObjectsMass);
				body.friction = rigidObjectsFriction;
				body.linearDamping = rigidObjectsDamping;
				body.restitution = rigidObjectsResitution;
				body.position = new Vector3D(0,0,-100);
				physicsWorld.addRigidBody(body);
				rigidObjects.push(body);
			}
		}
		
		private function playTimerHandler(event:TimerEvent):void {
			playTime--;
			if(playTime<=0)
			{
				resetRigids();
				// sound
				new NewLevel().play();
				// reset time
				playTime = 10;
			}
		}
		
		private function resetRigids():void
		{
			var x:Number = 1;
			var y:Number = 1;
			for (var i:int = 0; i < rigidObjects.length; i++ ) {
				rigidObjects[i].position = new Vector3D(x*20-50, y*20-50, 100);
				if(x<4){
					x++; 
				}else{ 
					x=1;
					y++;
				}
			}
		}
		
		private function render(event:Event):void
		{
			arTracker.doTracking();
			
			light.direction = lightDirection;
			
			//doTransforms();
			physicsWorld.step(timeStep);
			view.render();
		}
		
		private function onResize(event:Event = null):void{
			var sw:Number = stage.stageWidth;
			
			var w:Number = stage.stageWidth * 0.7;
			var h:Number = w * 0.75;
			
			h = stage.stageHeight;
			w = h * 1.33;
	
			view.width = w;
			view.height = h;
			view.scaleX = 1;
			view.scaleY = 1;
			view.x = (sw / 2)-(w/2);
			
			trace("resized");
		}
		
		
		private function trackingData(event:TrackEvent):void {
			//trace("m1 event: " + event.m1.position );
			//trace("m2 event: " + event.m2.position );
			var v3:Vector.<Vector3D> = new Vector.<Vector3D>(3);
			v3 = event.m1.decompose();
			view.camera.position = new Vector3D(v3[0].x, v3[0].y, v3[0].z);
			view.camera.rotationX = (v3[1].x/3.14*180);
			view.camera.rotationY = (v3[1].y/3.14*180);
			view.camera.rotationZ = (v3[1].z/3.14*180);
			
			v3 = event.m2.decompose();
			handRigidbody.position = new Vector3D(v3[0].x, v3[0].y, v3[0].z);
			handRigidbody.rotationX = (v3[1].x/3.14*180);
			handRigidbody.rotationY = (v3[1].y/3.14*180);
			handRigidbody.rotationZ = (v3[1].z/3.14*180);
		}
	}
}