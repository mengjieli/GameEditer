package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowResize;
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import egret.components.Button;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.components.Window;
	import egret.core.ns_egret;
	import egret.effects.animation.Animation;
	import egret.effects.animation.MotionPath;
	import egret.effects.animation.SimpleMotionPath;
	import egret.managers.CursorManager;
	import egret.ui.core.Cursors;
	import egret.ui.skins.macWindowSkin.MacWindowSkin;
	import egret.ui.skins.winWindowSkin.WinWindowSkin;
	import egret.utils.ScreensUtil;
	import egret.utils.SystemInfo;
	import egret.utils.callLater;
	
	use namespace ns_egret;
	
	
	/**
	 * 最大化状态
	 */	
	[SkinState("maximized")]
	/**
	 * 最大化且未激活状态
	 */	
	[SkinState("maximizedAndInactive")]
	/**
	 * 最小化状态
	 */	
	[SkinState("minimized")]
	
	/**
	 * 普通未激活
	 */
	[SkinState("normalAndInactive")]
	
	/**
	 * 基本桌面窗体 
	 * @author 雷羽佳
	 */	
	public class Window extends egret.components.Window
	{
		/**
		 * 默认的窗口图标。
		 */		
		public static var defaultTitleIcon:Object;
		
		private var _stage:Stage;
		public function Window()
		{
			Cursors.initCursors();
			super();
			if(SystemInfo.isMacOS)
			{
				this.skinName = MacWindowSkin;
			}else
			{
				this.skinName = WinWindowSkin;
			}
			transparent = true;
			systemChrome = "none";
			minimizable = false;
			super.measuredHeight;
			this.focusEnabled = true;
			this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,onDisplayStateChange);
			
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			this.addEventListener(Event.ACTIVATE,activateHandler);
		}
		
		private function activateHandler(e:Event):void
		{
			this.removeEventListener(Event.ACTIVATE,activateHandler);
			updateWindowSize();
		}
		
		private function updateWindowSize():void
		{
			validateNow();
			var bounds:Rectangle;
			if(Application && Application.topApp && !Application.topApp.nativeWindow.closed)
			{
				Application.topApp.pushWindow(this);
				bounds = Application.topApp.nativeWindow.bounds;
			}else
			{
				bounds = Screen.mainScreen.bounds;
			}
			if(!nativeWindow.closed)
			{
				nativeWindow.addEventListener(Event.CLOSE,onWindowClosed,false,2048);
				var finalPos:Point = new Point();
				finalPos.x = Math.round(bounds.x + bounds.width*0.5-nativeWindow.width*0.5);
				finalPos.y = Math.round(bounds.y+bounds.height*0.5-nativeWindow.height*0.5);
				var finalRect:Rectangle = new Rectangle(finalPos.x,finalPos.y,nativeWindow.width,nativeWindow.height);
				var globalPoint:Point = new Point(finalPos.x+nativeWindow.width/2,finalPos.y+nativeWindow.height/2);
				var currentScreen:Screen = ScreensUtil.getScreenByCloseGlobalPos(globalPoint);
				if(!currentScreen) currentScreen = Screen.mainScreen;
				finalRect = ScreensUtil.fixRectInScreensWithTargetScreen(finalRect,new Rectangle(0,0,nativeWindow.width,nativeWindow.height),currentScreen);
				finalPos.x = finalRect.x;
				finalPos.y = finalRect.y;
				nativeWindow.x = finalPos.x;
				nativeWindow.y = finalPos.y;
				if(!SystemInfo.isMacOS)
					this.addEventListener(Event.ENTER_FRAME,fixAutoPadding_handler);
			}
		}
		
		private function addedToStageHandler(e:Event):void
		{
			if(_stage != null)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_UP,stageMouseUpHandler);
				this.stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			}
			_stage = stage;
			this.stage.addEventListener(MouseEvent.MOUSE_UP,stageMouseUpHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		
		private var eventMap:Object = {rightMouseDown:"mouseDown",rightMouseUp:"mouseUp"};
		
		
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		/**
		 * 窗口已经关闭
		 */		
		private function onWindowClosed(event:Event):void
		{
			if(Application.topApp)
				Application.topApp.removeWindow(this);
			this.removeEventListener(Event.ENTER_FRAME,fixAutoPadding_handler);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode==Keyboard.ESCAPE)
			{
				onCloseButtonClick();
			}
		}
		
		private var _modal:Boolean = true;
		/**
		 * 是否启用模态，默认true。
		 */
		public function get modal():Boolean
		{
			return _modal;
		}
		
		public function set modal(value:Boolean):void
		{
			_modal = value;
		}
		
		override public function open(openWindowActive:Boolean = true):void
		{
			super.open(openWindowActive);
			updateWindowSize();
		}
		
		private var previousAutoPadding:String = "";
		private var currentAutoPadding:String = "";
		protected function fixAutoPadding_handler(event:Event):void
		{
			if(nativeWindow && stage)
			{
				var globalPos:Point = nativeWindow.globalToScreen(new Point(stage.mouseX,stage.mouseY));
				var currentScreen:Screen = ScreensUtil.getScreenByGlobalPos(globalPos);
				if(currentScreen)
				{
					var visibleBounds:Rectangle = currentScreen.visibleBounds;
					if(
						nativeWindow.displayState == NativeWindowDisplayState.NORMAL && 
						(nativeWindow.x+nativeWindow.width == visibleBounds.x+visibleBounds.width || nativeWindow.x == visibleBounds.x) &&
						nativeWindow.y == visibleBounds.y &&
						nativeWindow.height == visibleBounds.height
					)
					{
						currentAutoPadding = "H";
					}else if(
						nativeWindow.displayState == NativeWindowDisplayState.NORMAL && 
						nativeWindow.y == visibleBounds.y &&
						nativeWindow.height == visibleBounds.height
					)
					{
						currentAutoPadding = "V";
					}else
					{
						currentAutoPadding = "";
					}
				}
				if(currentAutoPadding != previousAutoPadding)
				{
					if(currentAutoPadding == "H")
					{
						nativeWindow.x -= 8;
						nativeWindow.y -= 8;
						nativeWindow.height += 16;
						nativeWindow.width += 16;
					}else if(currentAutoPadding == "V")
					{
						nativeWindow.y -= 8;
						nativeWindow.height += 16;
					}
				}
				previousAutoPadding = currentAutoPadding;
			}
		}		
		
		override public function activate():void
		{
			if (nativeWindow && !nativeWindow.closed)
			{
				nativeWindow.activate();   
				
				visible = true;             
			}
		}
		
		private var animator:Animation;
		/**
		 * 播放闪烁动画
		 */		
		ns_egret function playSpark():void
		{
			if(!shadow)
				return;
			if (!animator)
			{
				animator = new Animation(animationUpdateHandler);
				animator.repeatCount = 4;
			}
			
			if (animator.isPlaying)
				animator.stop();
			
			animator.duration = 200;
			animator.motionPaths = new <MotionPath>[
				new SimpleMotionPath("alpha", 0, 1)];
			animator.play();
		}
		
		private function animationUpdateHandler(animation:Animation):void
		{
			shadow.alpha = animation.currentValue["alpha"];
		}
		
		private var _showModalMask:Boolean = false;
		/**
		 * 是否显示模态遮罩
		 */
		ns_egret function get showModalMask():Boolean
		{
			return _showModalMask;
		}
		ns_egret function set showModalMask(value:Boolean):void
		{
			if(_showModalMask==value)
				return;
			_showModalMask = value;
			if(modalMask)
				modalMask.visible = value;
		}
		
		/**
		 * 窗口状态发生改变。
		 */		
		private function onDisplayStateChange(event:NativeWindowDisplayStateEvent):void
		{
			var window:NativeWindow = nativeWindow;
			if(window.closed)
				return;
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			if (nativeWindow.closed)
				return "disabled";
			if (nativeWindow.displayState==NativeWindowDisplayState.MINIMIZED)
				return "minimized";
			else
			{
				if (nativeWindow.active)
					return nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED ? "maximized" : "normal";
				else
					return nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED ? "maximizedAndInactive" : "normalAndInactive";
			}
		}
		
		/**
		 * [SkinPart]模态遮罩
		 */		
		public var modalMask:UIAsset;
		/**
		 * [SkinPart]窗口阴影
		 */		
		public var shadow:UIAsset;
		/**
		 * [SkinPart] 窗口标题
		 */		
		public var titleDisplay:egret.components.Label;
		/**
		 * [SkinPart]窗口图标
		 */		
		public var appIcon:UIAsset;
		/**
		 * [SkinPart]关闭按钮 
		 */		
		public var closeButton:Button;
		/**
		 * [SkinPart]最大化或者还原按钮
		 */		
		public var maxAndRestoreButton:Button;
		/**
		 * [SkinPart]最小化按钮
		 */		
		public var minimizeButton:Button;
		
		/**
		 * [SkinPart]可移动区域
		 */		
		public var moveArea:InteractiveObject;
		
		public var topLeftResize:InteractiveObject;
		public var topRightResize:InteractiveObject;
		public var bottomRightResize:InteractiveObject;
		public var bottomLeftResize:InteractiveObject;
		public var leftResize:InteractiveObject;
		public var rightResize:InteractiveObject;
		public var topResize:InteractiveObject;
		public var bottomResize:InteractiveObject;
		
		private var _showAllButton:Boolean = true;
		/**
		 * 是否显示全部按钮,设置为false时只显示一个关闭按钮。此属性在Mac OS中无效。
		 */
		public function get showAllButton():Boolean
		{
			return _showAllButton;
		}
		
		public function set showAllButton(value:Boolean):void
		{
			if(_showAllButton==value)
				return;
			_showAllButton = value;
			if(minimizeButton)
				minimizeButton.visible = _showAllButton;
			if(maxAndRestoreButton)
				maxAndRestoreButton.visible = _showAllButton;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set maximizable(value:Boolean):void
		{
			super.maximizable = value;
			if(maxAndRestoreButton)
				maxAndRestoreButton.enabled = value&&resizable;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set minimizable(value:Boolean):void
		{
			super.minimizable = value;
			if(minimizeButton)
				minimizeButton.enabled = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set resizable(value:Boolean):void
		{
			super.resizable = value;
			if(maxAndRestoreButton)
				maxAndRestoreButton.enabled = value&&maximizable;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==moveArea || instance == titleDisplay || instance == appIcon)
			{
				instance.addEventListener(MouseEvent.MOUSE_DOWN,onMoveAreaMouseDown);
				instance.doubleClickEnabled = true;
				instance.addEventListener(MouseEvent.DOUBLE_CLICK,onMoveAreaDoubleClick);
			}
			else if(instance==minimizeButton)
			{
				minimizeButton.enabled = minimizable&&_showAllButton;
				minimizeButton.visible = _showAllButton;
				minimizeButton.addEventListener(MouseEvent.CLICK,onMinimizeButtonClick);
			}
			else if(instance==maxAndRestoreButton)
			{
				maxAndRestoreButton.enabled = maximizable&&resizable&&_showAllButton;
				maxAndRestoreButton.visible = _showAllButton;
				maxAndRestoreButton.addEventListener(MouseEvent.CLICK,onMaxAndRestoreButtonClick);
			}
			else if(instance==closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==modalMask)
			{
				modalMask.visible = _showModalMask;
			}
			else if(instance==topLeftResize||instance==topRightResize||instance==bottomRightResize
				||instance==bottomLeftResize||instance==leftResize||instance==rightResize
				||instance==bottomResize||instance==topResize)
			{
				(instance as InteractiveObject).addEventListener(MouseEvent.MOUSE_DOWN,onResizeMouseDown);
				(instance as InteractiveObject).addEventListener(MouseEvent.ROLL_OVER,onResizeRollOver);
				(instance as InteractiveObject).addEventListener(MouseEvent.ROLL_OUT,onResizeRollOut);
			}
			if(instance==appIcon)
			{
				appIcon.source = _titleIcon ? _titleIcon:defaultTitleIcon;
			}
			if(instance==titleDisplay)
			{
				titleDisplay.text = title;
			}
		}
		
		/**
		 * 鼠标在调整窗口大小按钮上经过
		 */
		private function onResizeRollOver(event:MouseEvent):void
		{
			if(!resizable||event.buttonDown)
				return;
			if(inDragAndResize)
				return;
			switch(event.currentTarget)
			{
				case topLeftResize:
				case bottomRightResize:
					CursorManager.setCursor(Cursors.DESKTOP_RESIZE_NWSE);
					break;
				case topRightResize:
				case bottomLeftResize:
					CursorManager.setCursor(Cursors.DESKTOP_RESIZE_NESW);
					break;
				case leftResize:
				case rightResize:
					CursorManager.setCursor(Cursors.DESKTOP_RESIZE_EW);
					break;
				case topResize:
				case bottomResize:
					CursorManager.setCursor(Cursors.DESKTOP_RESIZE_NS);
					break;
			}
		}
		
		private function stageMouseUpHandler(e:MouseEvent):void
		{
			if(
				CursorManager.cursor == Cursors.DESKTOP_RESIZE_EW ||
				CursorManager.cursor == Cursors.DESKTOP_RESIZE_NESW ||
				CursorManager.cursor == Cursors.DESKTOP_RESIZE_NWSE ||
				CursorManager.cursor == Cursors.DESKTOP_RESIZE_NS 
			)
			{
				CursorManager.removeCursor(CursorManager.cursor);
			}
		}
		/**
		 * 鼠标在调整窗口大小按钮上移出
		 */		
		private function onResizeRollOut(event:MouseEvent):void
		{
			if(!resizable||event.buttonDown)
				return;
			if(!inDragAndResize)
			{
				CursorManager.setCursor(Cursors.AUTO);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if(instance==moveArea || instance == titleDisplay || instance == appIcon)
			{
				instance.removeEventListener(MouseEvent.MOUSE_DOWN,onMoveAreaMouseDown);
				instance.removeEventListener(MouseEvent.DOUBLE_CLICK,onMoveAreaDoubleClick);
			}
				
			else if(instance==minimizeButton)
			{
				minimizeButton.removeEventListener(MouseEvent.CLICK,onMinimizeButtonClick);
			}
			else if(instance==maxAndRestoreButton)
			{
				maxAndRestoreButton.removeEventListener(MouseEvent.CLICK,onMaxAndRestoreButtonClick);
			}
			else if(instance==closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==topLeftResize||instance==topRightResize||instance==bottomRightResize
				||instance==bottomLeftResize||instance==leftResize||instance==rightResize
				||instance==bottomResize||instance==topResize)
			{
				(instance as InteractiveObject).removeEventListener(MouseEvent.MOUSE_DOWN,onResizeMouseDown);
			}
		}
		
		override public function set title(value:String):void
		{
			super.title = value;
			if(titleDisplay)
			{
				titleDisplay.text = value;
			}
		}
		
		private var _titleIcon:*;
		/**
		 * 标题图标
		 */
		public function set titleIcon(value:Object):void
		{
			_titleIcon = value;
			if(appIcon)
			{
				appIcon.source = value;
			}
		}
		
		private var inDragAndResize:Boolean = false;
		/**
		 * 鼠标在调整窗口大小按钮上按下
		 */		
		private function onResizeMouseDown(event:MouseEvent):void
		{
			if(!resizable)
				return;
			inDragAndResize = true;
			mouseChildren = false;
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			sm.addEventListener(Event.MOUSE_LEAVE,onStageMouseUp);
			sm.addEventListener(MouseEvent.RIGHT_MOUSE_UP,onStageMouseUp);
			switch(event.currentTarget)
			{
				case topLeftResize:
					nativeWindow.startResize(NativeWindowResize.TOP_LEFT);
					break;
				case topRightResize:
					nativeWindow.startResize(NativeWindowResize.TOP_RIGHT);
					break;
				case bottomRightResize:
					nativeWindow.startResize(NativeWindowResize.BOTTOM_RIGHT);
					break;
				case bottomLeftResize:
					nativeWindow.startResize(NativeWindowResize.BOTTOM_LEFT);
					break;
				case leftResize:
					nativeWindow.startResize(NativeWindowResize.LEFT);
					break;
				case rightResize:
					nativeWindow.startResize(NativeWindowResize.RIGHT);
					break;
				case topResize:
					nativeWindow.startResize(NativeWindowResize.TOP);
					break;
				case bottomResize:
					nativeWindow.startResize(NativeWindowResize.BOTTOM);
					break;
			}
		}
		
		private function onStageMouseUp(event:Event):void
		{
			mouseChildren = true;
			inDragAndResize = false;
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			sm.removeEventListener(Event.MOUSE_LEAVE,onStageMouseUp);
			sm.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,onStageMouseUp);
		}
		
		/**
		 * 移动窗口
		 */		
		private function onMoveAreaMouseDown(event:MouseEvent):void
		{
			var sm:DisplayObject = systemManager as DisplayObject;
			if(nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED)
			{
				if(SystemInfo.isMacOS)
				{
					nativeWindow.startMove();
				}else
				{
					sm.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				}
			}
			else
			{
				nativeWindow.startMove();
			}
			sm.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			sm.addEventListener(Event.MOUSE_LEAVE,onMouseUp);
			sm.addEventListener(MouseEvent.RIGHT_MOUSE_UP,onMouseUp);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			var globalPos:Point = nativeWindow.globalToScreen(new Point(nativeWindow.stage.mouseX,nativeWindow.stage.mouseY));
			var left:Boolean = nativeWindow.stage.mouseX < nativeWindow.stage.stageWidth/2;
			var offsetX:int = nativeWindow.stage.mouseX;
			var offsetY:int = nativeWindow.stage.mouseY;
			if(!left) offsetX = nativeWindow.stage.stageWidth - offsetX;
			restore();
			callLater(function():void{
				nativeWindow.y = globalPos.y-offsetY;
				if(left)
					nativeWindow.x = globalPos.x-offsetX;
				else
					nativeWindow.x = globalPos.x+offsetX-nativeWindow.width;
				nativeWindow.startMove();
			});
		}
		
		private function onMouseUp(event:Event):void
		{
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			sm.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			sm.removeEventListener(Event.MOUSE_LEAVE,onMouseUp);
			sm.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,onMouseUp);
		}
		
		/**
		 * 双击标题栏
		 */		
		private function onMoveAreaDoubleClick(event:MouseEvent):void
		{
			if(maximizable&&resizable)
			{
				if(nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED)
					restore();
				else
					maximize();
			}
		}
		
		/**
		 * 最小化窗口
		 */		
		private function onMinimizeButtonClick(event:MouseEvent):void
		{
			if(minimizable)
				minimize();
		}
		/**
		 * 最大化或者恢复窗口
		 */		
		private function onMaxAndRestoreButtonClick(event:MouseEvent):void
		{
			if(maximizable&&resizable)
			{
				if(nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
					restore();
				else
					maximize();
			}
		}
		
		/**
		 * 关闭窗口
		 */		
		protected function onCloseButtonClick(event:MouseEvent=null):void
		{
			close();
		}
	}
}