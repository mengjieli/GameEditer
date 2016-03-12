package com.flower.cocos2dx.core
{
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.core.camera.CameraBase;
	import com.flower.cocos2dx.core.camera.NormalCamera;
	import com.flower.cocos2dx.core.mouseManager.MouseManager;
	import com.flower.cocos2dx.display.DisplayObject;
	import com.flower.cocos2dx.display.DisplayObjectContainer;
	import com.flower.cocos2dx.event.CameraEvent;
	import com.jc.utils.Matrix;
	
	import cocos2dx.display.CCDirector;
	import cocos2dx.display.CCScene;
	
	import renderEngine2D.events.MouseEvent;

	public class StageCocos2DX extends DisplayObjectContainer
	{
		//基本属性
		private var _renderType:uint;
		private var _camera:CameraBase;
		private var _stageWidth:uint;
		private var _stageHeight:uint;
		
		//在Cocos2DX渲染模式下的属性
		private var _scene:CCScene;
		
		public function StageCocos2DX()
		{
			super(true);
			if(classLock == true)
			{
				DebugInfo.debug("不可创建StageCocos2DX对象，请访问单例方法StageCocos2DX.getInstance()",DebugInfo.ERROR);
				return;
			}
			
			//设置基本属性
			_renderType = 5;
			_stageWidth = CCDirector.getInstance().getWinSize().width;
			_stageHeight = CCDirector.getInstance().getWinSize().height;
			this.setCamera(new NormalCamera(_stageWidth,_stageHeight));
			
			//注册鼠标事件
			MouseManager.getInstance().init(this);
			
			//创建scene 和 show作为引擎的基
			_scene = CCScene.create();
			if(CCDirector.getInstance().getRunningScene()) CCDirector.getInstance().replaceScene(_scene);
			else CCDirector.getInstance().runWithScene(_scene);
			this._show = new StageNode();
			_scene.addChild(this._show);
			this._show.setAnchorPoint(0,0);
			
			//进行鼠标监听
		}
		
		//////////////////////////////////////////////////////////////////////////鼠标事件///////////////////////////////////////////////////////////////////////////
		/**
		 *获取鼠标所指对象
		 * @param mouseX
		 * @param mouseY
		 * @return 
		 * 
		 */		
		public function getMouseTarget2(mouseX:int,mouseY:int,mutiply:Boolean):DisplayObject
		{
			var matrix:Matrix = _camera.getMatrix();
			matrix.save();
			_camera.loadMouseMatrix(mouseX,mouseY);
			var target:DisplayObject = getMouseTarget(matrix,mutiply);
			matrix.setTo.apply(null,matrix._saves.pop());
			if(target == null) target = this;
			return target;
		}
		//////////////////////////////////////////////////////////////////////////鼠标事件//////////////////////////////////////////////////////////////////////////
		
		/////////////////////////////////////////////////////////////////////////方法//////////////////////////////////////////////////////////////////////////////////
		//未完善，暂不对外提供
		private function setCamera(val:CameraBase):void
		{
			if(_camera)
			{
				(_camera as CameraBase).addEventListener(CameraEvent.MOVE,onCameraMove,this);
				_camera = null;
			}
			_camera = val;
		}
		
		//镜头移动
		private function onCameraMove(e:CameraEvent):void
		{
			setPosition(_x,_y);
		}
		/////////////////////////////////////////////////////////////////////////End方法//////////////////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////////属性获取/////////////////////////////////////////////////////////////////////////
		override public function getWidth():int
		{
			return _stageWidth;
		}
		override public function getHeight():int
		{
			return _stageHeight;
		}
		
		public function getScene():CCScene
		{
			return _scene;
		}
		
		private static var ist:StageCocos2DX;
		private static var classLock:Boolean = true;
		public static function getInstance():StageCocos2DX
		{
			if(!ist)
			{
				classLock = false;
				ist = new StageCocos2DX();
				classLock = true;
			}
			return ist;
		}
		
		/**
		 *开始StageCocos2DX 
		 * 
		 */		
		public static function start():void
		{
			getInstance();
		}
	}
}