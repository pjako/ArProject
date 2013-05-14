//test
package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	import flash.media.Sound;
	import flash.media.Video;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	import flash.net.URLRequest;
	
	import art.CModule;
	import art.FlashEcho;
	import art.FlashSetup;
	import art.FlashTick;
	import art.vfs.RootFSBackingStore;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.math.Vector3DUtils;
	import away3d.core.sort.RenderableMergeSort;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.events.MouseEvent3D;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.*;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.NURBSGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.data.NURBSVertex;
	import away3d.textures.BitmapTexture;
	import away3d.textures.PlanarReflectionTexture;
	import away3d.textures.WebcamTexture;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	
	
	
	[SWF(backgroundColor="#000000", frameRate="20")]
	public class ArtMobile extends Sprite {
		private var arTracker:ARTracker;
		static public var currentCamera:Camera3D;
		static public var view:View3D;
		public static var currentScene:Scene3D;
		public static var currentController:Controller;
		public static var physicsWorld:AWPDynamicsWorld;
		public static var cameraTracker:Tracker;
		public static var tracker1:Tracker;
		public static var tracker2:Tracker;
		public static var debugDraw:AWPDebugDraw;
		// This is not optimal physics timesteps should be always 15ms
		private static var timeStep:Number = 1.0 / 20;
		
		//light objects
		private var light:DirectionalLight;
		public static var lightPicker:StaticLightPicker;
		private var lightDirection:Vector3D;
		
		//3d Assets loader + models *********
		private var loader3D:Loader3D;
		//private var modelURL:URLRequest;
	
		[Embed(source="../3d/tomb.awd", mimeType="application/octet-stream")]
		public static var Model:Class;
		[Embed(source="/../3d/Tomb01_D.png")]
		public static var mTexture:Class;
		
		public function ArtMobile():void {
			// Performance optimization
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			addEventListener(Event.ADDED_TO_STAGE, initStage);
		}
		
		private function initGame():void {
			// handles PlayerInput
			currentController = new Controller();
		}
		
		
		private function trackingData(event:TrackEvent):void {
			// First Tracker
			var v3:Vector.<Vector3D> = event.m1.decompose();
			
			// Use setTo to reduce garbage
			
			

			
			cameraTracker.rotation.setTo(
				v3[1].x/3.14*180,
				v3[1].y/3.14*180,
				v3[1].z/3.14*180);
			cameraTracker.position.setTo(
				v3[0].x,
				v3[0].y,
				v3[0].z);
			currentCamera.position = new Vector3D(v3[0].x,v3[0].y,v3[0].z);
				/*.setTo(
				v3[0].x,
				v3[0].y,
				v3[0].z);*/
			currentCamera.rotationX = cameraTracker.rotation.x;
			currentCamera.rotationY = cameraTracker.rotation.y;
			currentCamera.rotationZ = cameraTracker.rotation.z;
					
			//Second Tracker
			v3 = event.m2.decompose();
			
			tracker1.rotation.setTo(
				v3[1].x/3.14*180,
				v3[1].y/3.14*180,
				v3[1].z/3.14*180);
			tracker1.position.setTo(
				v3[0].x,
				v3[0].y,
				v3[0].z);
			
			// Third Tracker
			v3 = event.m3.decompose();
			tracker2.rotation.setTo(
				v3[1].x/3.14*180,
				v3[1].y/3.14*180,
				v3[1].z/3.14*180);
			tracker2.position.setTo(
				v3[0].x,
				v3[0].y,
				v3[0].z);
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
		
		
		private function initStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initStage);
			
			// Init Scene
			
			// Init Tracker
			arTracker = new ARTracker();
			cameraTracker = new Tracker();
			tracker1 = new Tracker();
			tracker2 = new Tracker();
			
			// Init Viewport
			view = new View3D();
			// set Background to AR-VideoCamera
			view.background= arTracker.videoBackground;
			// set camera
			initCamera();
			
			this.addChild(view);
			
			
			initStatWindow();
			initLight();
			currentScene = view.scene;
			currentCamera = view.camera;
			initAssets();
			initPhysics();
			initEvents();
			initGame();
			
			
		}
		
		private function initAssets():void {
			
			// 3d import
			
			var assetLoaderContext:AssetLoaderContext = new AssetLoaderContext();
			assetLoaderContext.mapUrlToData("Tomb01_D.png", new mTexture());
			
			Parsers.enableAllBundled();

			loader3D = new Loader3D(true, null);
			loader3D.position.x=0;
			loader3D.position.y=0;
			loader3D.position.z=0;
			loader3D.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3D.loadData(new Model(),assetLoaderContext);

			currentScene.addChild(loader3D);

			
		}
		
		
		private function initCamera():void {
			view.camera.lens = new PerspectiveLens(29.8);
			view.camera.lens.near = 10;
			view.camera.lens.far = 2000;
			var eps:Number = 0.00000001;
			view.camera.x = eps;
			view.camera.y = eps;
			view.camera.z = eps;
			
		}		
		
		private function initStatWindow():void {
			var awayStats:AwayStats = new AwayStats(view)
			awayStats.x = 150;
			awayStats.y = 100;
			this.addChild(awayStats);
			
		}
		private function initLight():void {
			//setup the light for the scene
			light = new DirectionalLight();
			lightPicker = new StaticLightPicker([light]);
			lightDirection = new Vector3D(0, 0, -1);
			view.scene.addChild(light);
		}
		private function initPhysics():void {
			//////////////// init the physics world //////////////////// 
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			physicsWorld.collisionCallbackOn = true;
			physicsWorld.gravity = new Vector3D(0,0,0);//-gravity);
			
			debugDraw = new AWPDebugDraw(view, physicsWorld); 
			debugDraw.debugMode |= AWPDebugDraw.DBG_DrawRay;
			//debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
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
		
		private function playTimerHandler(event:TimerEvent):void {
			/*
			playTime--;
			if(playTime<=0)
			{
				resetRigids();
				// sound
				new NewLevel().play();
				// reset time
				playTime = 10;
			}*/
		}
		
		private function onAssetComplete(event:AssetEvent):void {
			//Event Handler for Assets
			
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				mesh.castsShadows = true;
			} else if (event.asset.assetType == AssetType.MATERIAL) {
				var material:TextureMaterial = event.asset as TextureMaterial;
				material.shadowMethod = new FilteredShadowMapMethod(light);
				material.lightPicker = lightPicker;
				material.gloss = 30;
				material.specular = 1;
				material.ambientColor = 0x303040;
				material.ambient = 1;
			}
			
		}
		
		
		
		
		
	}
	
	/*
	public class ArtMobile extends Sprite
	{
		public static var currentScene:Scene3D;
		public static var currentController:Controller;
		// awesome comment
		
		private var playTime:int = 20;
		// text
		private var textFormat:TextFormat;
		// physics
		public static var physicsWorld:AWPDynamicsWorld;
		public static var debugDraw:AWPDebugDraw;
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
		static public var view:View3D;
		private var mylightP:PointLight;
		private var lightP:PointLight;
		//light objects
		private var light:DirectionalLight;
		public static var lightPicker:StaticLightPicker;
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
			physicsWorld.gravity = new Vector3D(0,0,0);//-gravity);
			
			debugDraw = new AWPDebugDraw(view, physicsWorld); 
			debugDraw.debugMode |= AWPDebugDraw.DBG_DrawRay;
			//debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
			
			
			currentScene = view.scene;
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
			
			
			//var col:CollisionObject = new CollisionObject();
			//col.setLight(lightPicker);
			
			// add text texture to groundplane
			
			//groundMesh = new Mesh(new CubeGeometry(60, 60, 2), txMat);
			//groundMesh.mouseEnabled = true;
			//view.scene.addChild(groundMesh);
			//var groundShape:AWPBoxShape = new AWPBoxShape(60, 60, 2);
			//groundRigidbody = new AWPRigidBody(groundShape, groundMesh, 0);
			//physicsWorld.addRigidBody(groundRigidbody);
			
			
			// add bilboard to ground marker
			//groundMesh.addChild(sprite3d);
			
			// add arrows to ground marker
			var arrows:Trident = new Trident(40, true);
			//groundMesh.addChild(arrows);
			
			materialR.alpha = 0.5;
			materialR.alphaBlending = true;
			handMesh = new Mesh(new CubeGeometry(60, 60, 2), materialR);
			handMesh.mouseEnabled = true;
			view.scene.addChild(handMesh);
			var handShape:AWPBoxShape = new AWPBoxShape(60, 60, 2);
			handRigidbody = new AWPRigidBody(handShape, handMesh, 0);
			physicsWorld.addRigidBody(handRigidbody);
			
			
			
			currentController = new Controller(view.camera);
			
			
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
	}*/
}