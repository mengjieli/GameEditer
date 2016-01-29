package egret.ui.components
{
	import flash.desktop.NotificationType;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowResize;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	import egret.components.Application;
	import egret.components.Button;
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.components.WindowedApplication;
	import egret.core.ns_egret;
	import egret.managers.CursorManager;
	import egret.ui.core.Cursors;
	import egret.ui.skins.macWindowSkin.MacWindowSkin;
	import egret.ui.skins.winWindowSkin.WinWindowSkin;
	import egret.utils.ScreensUtil;
	import egret.utils.SharedObjectTool;
	import egret.utils.SystemInfo;
	import egret.utils.callLater;
	
	import locales.locale_egret_lib;
	
	use namespace ns_egret;
	
	/**
	 * 最大化状态
	 */	
	[SkinState("maximized")]
	/**
	 * 最小化状态
	 */	
	[SkinState("minimized")]
	/**
	 * 最大化且未激活状态
	 */	
	[SkinState("maximizedAndInactive")]
	/**
	 * 关闭程序事件,可以取消
	 */	
	[Event(name="exiting", type="flash.events.Event")]
	
	/**
	 * 窗口顶级容器  
	 * @author 雷羽佳
	 */	
	public class Application extends WindowedApplication
	{
		/**
		 * 顶级应用程序实例
		 */		
		ns_egret static var topApp:egret.ui.components.Application;
		/**
		 * 应用程序ID
		 */		
		private var appID:String = nativeApplication.applicationID;
		private var resizedByUs:Boolean = false;
		
		public function Application()
		{
			locale_egret_lib.init();
			Cursors.initCursors();
			topApp = this;
			if(SystemInfo.isMacOS)
			{
				this.skinName = MacWindowSkin;
			}	
			else
			{
				this.skinName = WinWindowSkin;
			}
			this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,onDisplayStateChange);
			if(!SystemInfo.isMacOS)
				this.addEventListener(Event.ENTER_FRAME,fixAutoPadding_handler);
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
		
		
		override protected function addedToStageHandler(event:Event):void
		{
			var window:NativeWindow = this.stage.nativeWindow;
			window.addEventListener(Event.CLOSING,onWindowClosing);
			window.addEventListener(Event.CLOSE,onWindowClosed);
			var windowWidth:Number = SharedObjectTool.read(appID,"windowWidth");
			var windowHeight:Number = SharedObjectTool.read(appID,"windowHeight");
			
			var finalRect:Rectangle = new Rectangle();
			
			if(!isNaN(windowWidth) && !isNaN(windowHeight))
			{
				finalRect.width = windowWidth;
				finalRect.height = windowHeight;
			}
			else if(!isNaN(this.width) && !isNaN(this.height))
			{
				finalRect.width = this.width;
				finalRect.height = this.height;
			}else
			{
				finalRect.width = Capabilities.screenResolutionX-400;
				finalRect.height = Capabilities.screenResolutionY-200;
			}
			var windowX:Number = SharedObjectTool.read(appID,"windowX");
			var windowY:Number = SharedObjectTool.read(appID,"windowY");
			
			if(!isNaN(windowX)&&!isNaN(windowY))
			{
				
				finalRect.x = windowX;
				finalRect.y = windowY;
			}else
			{
				finalRect.x = Capabilities.screenResolutionX/2-finalRect.width/2;
				finalRect.y = Capabilities.screenResolutionY/2-finalRect.height/2;
			}
			
			//修复在记录扩展显示器的位置，而恢复大小的时候没有扩展显示器的情况。
			finalRect = ScreensUtil.fixRectInScreens(finalRect,new Rectangle(0,0,100,100));
			
			this.stage.nativeWindow.x = finalRect.x;
			this.stage.nativeWindow.y = finalRect.y;
			this.stage.nativeWindow.width = finalRect.width;
			this.stage.nativeWindow.height = finalRect.height;
			this.width = finalRect.width;
			this.height = finalRect.height;
			this.x = finalRect.x;
			this.y = finalRect.y;
			
			var state:String = SharedObjectTool.read(appID,"windowDisplayState");
			if(state==NativeWindowDisplayState.MAXIMIZED)
			{
				window.maximize();
			}
			
			super.addedToStageHandler(event);
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
			SharedObjectTool.write(appID,"windowDisplayState",event.afterDisplayState);
		}
		
		override protected function getCurrentSkinState():String
		{
			if (nativeWindow.closed)
				return "disabled";
			if (nativeWindow.displayState==NativeWindowDisplayState.MINIMIZED)
				return "minimized";
			if (nativeWindow.active)
				return nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED ? "maximized" : "normal";
			else
				return nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED ? "maximizedAndInactive" : "normalAndInactive";
		}
		
		/**
		 * [SkinPart]窗口标题
		 */		
		public var titleDisplay:Label;
		/**
		 * [SkinPart]标题区域容器
		 */		
		public var titleGroup:Group;
		/**
		 * [SkinPart]窗口图标
		 */		
		public var appIcon:UIAsset;
		/**
		 * [SkinPart]模态遮罩
		 */		
		public var modalMask:UIAsset;
		/**
		 * [SkinPart]关闭按钮
		 */		
		public var closeButton:Button;
		/**
		 * [SkinPart]最大化或者恢复按钮
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
		
		public var titleLeftGroup:Group;
		public var titleRightGroup:Group;
		
		ns_egret var _openedWindows:Vector.<Window> = new Vector.<Window>();
		/**
		 * 当前打开的Window列表。
		 */
		ns_egret function get openedWindows():Vector.<Window>
		{
			return _openedWindows.concat();
		}
		
		private var modalWindow:Window;
		
		/**
		 * 获取顶层的模态窗口
		 */		
		private function updateModalWindows():void
		{
			var index:int = -1;
			for(var i:int=_openedWindows.length-1;i>=0;i--)
			{
				if(_openedWindows[i].modal)
				{
					index = i;
					break;
				}
			}
			modalWindow = index==-1?null:_openedWindows[index];
			modalMask.visible = Boolean(index!=-1);
			if(modalWindow)
			{
				nativeWindow.addEventListener(Event.ACTIVATE,onModalMaskActive);
			}
			else
			{
				nativeWindow.removeEventListener(Event.ACTIVATE,onModalMaskActive);
			}
			var win:Window;
			
			
			for(i=_openedWindows.length-1;i>=0;i--)
			{
				win = _openedWindows[i];
				if(i==index)
				{
					win.showModalMask = false;
					win.nativeWindow.removeEventListener(Event.ACTIVATE,onModalMaskActive);
				}
				else
				{
					win.showModalMask = modalMask.visible;
					win.nativeWindow.addEventListener(Event.ACTIVATE,onModalMaskActive);
				}
			}
		}
		
		/**
		 * 添加一个打开的Window
		 */		
		ns_egret function pushWindow(window:Window):void
		{
			if(_openedWindows.indexOf(window)==-1)
			{
				_openedWindows.push(window);
				updateModalWindows();
			}
		}
		
		/**
		 * 移除一个关闭的Window
		 */		
		ns_egret function removeWindow(window:Window):void
		{
			var index:int = _openedWindows.indexOf(window);
			if(index!=-1)
			{
				_openedWindows.splice(index,1);
				updateModalWindows();
			}
		}
		
		
		private var _titleVisible:Boolean = true;
		public function get titleVisible():Boolean
		{
			return _titleVisible;
		}
		
		public function set titleVisible(value:Boolean):void
		{
			_titleVisible = value;
			if(this.titleDisplay)
			{
				titleDisplay.visible = _titleVisible;
			}
		}
		
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
				minimizeButton.addEventListener(MouseEvent.CLICK,onMinimizeButtonClick);
				minimizeButton.enabled = this.stage.nativeWindow.minimizable;
			}
			else if(instance==maxAndRestoreButton)
			{
				maxAndRestoreButton.addEventListener(MouseEvent.CLICK,onMaxAndRestoreButtonClick);
				maxAndRestoreButton.enabled = this.stage.nativeWindow.maximizable && this.stage.nativeWindow.resizable;
			}
			else if(instance==closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
			else if(instance==modalMask)
			{
				modalMask.visible = Boolean(modalWindow);
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
				appIcon.source = _titleIcon;
			}
			if(instance==titleDisplay)
			{
				titleDisplay.text = title;
				titleDisplay.visible = _titleVisible;
			}
		}
		
		/**
		 * 模态层被点击
		 */		
		private function onModalMaskActive(event:Event):void
		{
			if(modalWindow)
			{
				for (var i:int = 0; i < openedWindows.length; i++) 
				{
					if(!openedWindows[i].closed && openedWindows[i].modal)
						openedWindows[i].nativeWindow.orderToFront();
				}
				modalWindow.activate();
				if(modalWindow.nativeWindow)
					modalWindow.nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
				modalWindow.playSpark();
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
			super.title =  value;
			if(titleDisplay)
			{
				titleDisplay.text = value;
			}
		}
		
		private var _titleIcon:*;
		public function set titleIcon(value:*):void
		{
			_titleIcon = value;
			if(appIcon)
			{
				appIcon.source = value;
			}
		}
		
		private var inDragAndResize:Boolean = false;
		/**
		 * 鼠标在调整窗口大小按钮上经过
		 */		
		private function onResizeRollOver(event:MouseEvent):void
		{
			if(!resizable)
				return;
			if(event.buttonDown)
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
		/**
		 * 鼠标在调整窗口大小按钮上移出
		 */		
		private function onResizeRollOut(event:MouseEvent):void
		{
			if(event.buttonDown)
				return;
			if(!inDragAndResize)
			{
				CursorManager.setCursor(Cursors.AUTO);
			}
		}
		
		/**
		 * 鼠标在调整窗口大小按钮上按下
		 */		
		private function onResizeMouseDown(event:MouseEvent):void
		{
			if(!this.stage.nativeWindow.resizable)
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
			inDragAndResize = false;
			mouseChildren = true;
			var sm:DisplayObject = systemManager as DisplayObject;
			sm.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			sm.removeEventListener(Event.MOUSE_LEAVE,onStageMouseUp);
			sm.removeEventListener(MouseEvent.RIGHT_MOUSE_UP,onStageMouseUp);
			callLater(function():void{
				CursorManager.setCursor(Cursors.AUTO);
			});
			var window:NativeWindow = nativeWindow;
			if(window.closed)
				return;
			SharedObjectTool.write(appID,"windowX",window.x);
			SharedObjectTool.write(appID,"windowY",window.y);
			SharedObjectTool.write(appID,"windowWidth",window.width);
			SharedObjectTool.write(appID,"windowHeight",window.height);
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
			var window:NativeWindow = nativeWindow;
			if(window.closed)
				return;
			SharedObjectTool.write(appID,"windowX",window.x);
			SharedObjectTool.write(appID,"windowY",window.y);
		}
		
		/**
		 * 双击标题栏
		 */		
		private function onMoveAreaDoubleClick(event:MouseEvent):void
		{
			if(nativeWindow.displayState==NativeWindowDisplayState.MAXIMIZED)
				restore();
			else
				maximize();
		}
		
		/**
		 * 最小化窗口
		 */		
		private function onMinimizeButtonClick(event:MouseEvent):void
		{
			minimize();
		}
		
		/**
		 * 最大化或者恢复窗口
		 */		
		private function onMaxAndRestoreButtonClick(event:MouseEvent):void
		{
			if(maximizable&&resizable)
			{
				//				if(SystemInfo.isMacOS)
				//				{
				//					stage.displayState =   stage.displayState == StageDisplayState.NORMAL ?
				//						StageDisplayState.FULL_SCREEN_INTERACTIVE :
				//						StageDisplayState.NORMAL;
				//				}else
				//				{
				if(nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
					restore();
				else
					maximize();
				//				}
			}
		}
		
		private function onCloseButtonClick(event:Event):void
		{
			var evt:Event = new Event(Event.CLOSING,false,true);
			if(nativeWindow.dispatchEvent(evt))
			{
				if(nativeWindow&&!nativeWindow.closed)
					nativeWindow.close();
			}
		}
		
		private function onWindowClosing(event:Event):void
		{
			if(!nativeApplication.dispatchEvent(new Event(Event.EXITING,false,true)))
			{
				event.preventDefault();
			}
		}
		
		/**
		 * 关闭窗口
		 */		
		protected function onWindowClosed(event:Event):void
		{
			nativeApplication.exit();
			this.removeEventListener(Event.ENTER_FRAME,fixAutoPadding_handler);
		}
	}
}