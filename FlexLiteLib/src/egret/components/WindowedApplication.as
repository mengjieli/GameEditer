package egret.components
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import egret.core.IWindow;
	import egret.events.ResizeEvent;

	/**
	 * DeskTop项目的文档类。
	 * 这个类需要手动实例化放到systemManager里，此类可以设置皮肤 
	 * @author 雷羽佳 2014.6.23 13:31
	 * 
	 */	
	public class WindowedApplication extends Application implements IWindow
	{
		private var _nativeWindow:NativeWindow;
		
		private var _bounds:Rectangle = new Rectangle(NaN,NaN,NaN,NaN);
		private var boundsChanged:Boolean = false;
		
		private var _maxWidth:Number = 2880;
		private var maxWidthChanged:Boolean = false;
		private var _minWidth:Number = 0;
		private var minWidthChanged:Boolean = false;
		private var _maxHeight:Number = 2880;
		private var maxHeightChanged:Boolean = false;
		private var _minHeight:Number = 0;
		private var minHeightChanged:Boolean = false;
		private var _nativeWindowVisible:Boolean = true;
		private var _alwaysInFront:Boolean = false;
		private var _systemChrome:String = NativeWindowSystemChrome.STANDARD;
		private var _title:String = "";
		private var titleChanged:Boolean = false;
		private var toMax:Boolean = false;
		
		public function WindowedApplication()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			_nativeWindow = this.stage.nativeWindow;
			_systemChrome = _nativeWindow.systemChrome;
			
			boundsChanged = true;
			_nativeWindow.addEventListener(Event.ACTIVATE, nativeWindow_activateHandler, false, 0, true);
			_nativeWindow.addEventListener(Event.DEACTIVATE, nativeWindow_deactivateHandler, false, 0, true);
			
			_nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,dispatchEvent);
			_nativeWindow.addEventListener("closing", dispatchEvent);
			_nativeWindow.addEventListener("close", dispatchEvent, false, 0, true);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZING, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, window_resizeHandler);
			
			invalidateProperties();
			invalidateSize();
		}
		
		
		override public function get width():Number
		{
			return _bounds.width;
		}
		override public function set width(value:Number):void
		{
			if (value < minWidth)
				value = minWidth;
			else if (value > maxWidth)
				value = maxWidth;
			_bounds.width = value;
			boundsChanged = true;
			invalidateProperties();
			invalidateSize();
			dispatchEvent(new Event("widthChanged"));
		}
		
		/**
		 *布局过程中父级要考虑的组件最大建议宽度。此值采
		 * 用组件坐标（以像素为单位）。此属性的默认值由组
		 * 件开发人员设置。
		 * <p>
		 * 组件开发人员使用此属性设置组件宽度的上限。
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定
		 * 其默认大小时不会使用此值。因此，如果父项为
		 *  Container，则此属性可能不会产生任何效果，要么
		 * 就是容器在此属性中不起作用。由于此值位于组件坐
		 * 标中，因此与其父项相关的真正 maxWidth 受 scaleX 
		 * 属性影响。有些组件从理论上没有宽度限制。
		 * @return 
		 * 
		 */		
		override public function get maxWidth():Number
		{
			if (nativeWindow  && !maxWidthChanged)
				return nativeWindow.maxSize.x - chromeWidth();
			else
				return _maxWidth;
		}
		override public function set maxWidth(value:Number):void
		{
			_maxWidth = value;
			maxWidthChanged = true;
			invalidateProperties();
		}
		
		/**
		 * 布局过程中父级要考虑的组件最小建议宽度。此值采
		 * 用组件坐标（以像素为单位）。默认值取决于组件的
		 * 实现方式。 
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定
		 * 其默认大小时不会使用此值。因此，如果父项为 Container，
		 * 则此属性可能不会产生任何效果，要么就是容器在此
		 * 属性中不起作用。由于此值位于组件坐标中，因此与
		 * 其父项相关的真正 minWidth 受 scaleX 属性影响。
		 * @return 
		 * 
		 */	
		override public function get minWidth():Number
		{
			if (nativeWindow && !minWidthChanged)
				return nativeWindow.minSize.x - chromeWidth();
			else
				return _minWidth;
		}
		override public function set minWidth(value:Number):void
		{
			_minWidth = value;
			minWidthChanged = true;
			invalidateProperties();
		}
		
		
		override public function get height():Number
		{
			return _bounds.height;
		}
		override public function set height(value:Number):void
		{
			if (value < minHeight)
				value = minHeight;
			else if (value > maxHeight)
				value = maxHeight;
			_bounds.height = value;
			boundsChanged = true;
			invalidateProperties();
			invalidateSize();
			dispatchEvent(new Event("heightChanged"));
		}
		
		/**
		 *布局过程中父级要考虑的组件最大建议高度。此值采
		 * 用组件坐标（以像素为单位）。此属性的默认值由
		 * 组件开发人员设置。 
		 * <p>
		 * 组件开发人员使用此属性设置组件高度的上限。
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确
		 * 定其默认大小时不会使用此值。因此，如果父项为
		 *  Container，则此属性可能不会产生任何效果，要
		 * 么就是容器在此属性中不起作用。由于此值位于组
		 * 件坐标中，因此与其父项相关的真正 maxHeight 
		 * 受 scaleY 属性影响。有些组件从理论上没有高度
		 * 限制。
		 * @return 
		 * 
		 */
		override public function get maxHeight():Number
		{
			if (nativeWindow && !maxHeightChanged)
				return nativeWindow.maxSize.y - chromeHeight();
			else
				return _maxHeight;
		}
		override public function set maxHeight(value:Number):void
		{
			_maxHeight = value;
			maxHeightChanged = true;
			invalidateProperties();
		}
		
		
		/**
		 * 布局过程中父级要考虑的组件最小建议高度。此值采
		 * 用组件坐标（以像素为单位）。默认值取决于组件的
		 * 实现方式。 
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定
		 * 其默认大小时不会使用此值。因此，如果父项为 Container，
		 * 则此属性可能不会产生任何效果，要么就是容器在此
		 * 属性中不起作用。由于此值位于组件坐标中，因此与
		 * 其父项相关的真正 minHeight 受 scaleY 属性影响。
		 * @return 
		 * 
		 */
		override public function get minHeight():Number
		{
			if (nativeWindow && !minHeightChanged)
				return nativeWindow.minSize.y - chromeHeight();
			else
				return _minHeight;
		}
		override public function set minHeight(value:Number):void
		{
			_minHeight = value;
			minHeightChanged = true;
			invalidateProperties();
		}
		
		/**
		 * 显示对象是否可见。
		 * @return 
		 * 
		 */		
		override public function get visible():Boolean
		{
			if (nativeWindow && nativeWindow.closed)
				return false;
			if (nativeWindow)
				return nativeWindow.visible;
			else
				return _nativeWindowVisible;
		}
		override public function set visible(value:Boolean):void
		{
			if (!nativeWindow)
			{
				_nativeWindowVisible = value;
				invalidateProperties();
			}else if (!nativeWindow.closed)
			{
				nativeWindow.visible = value;
			}
		}
		/**
		 * AIR 用于标识应用程序的标识符。 
		 * @return 
		 * 
		 */		
		public function get applicationID():String
		{
			return nativeApplication.applicationID;
		}
		/**
		 * 代表 AIR 应用程序的 NativeApplication 对象。 
		 * @return 
		 * 
		 */		
		public function get nativeApplication():NativeApplication
		{
			return NativeApplication.nativeApplication;
		}
		/**确定基础 NativeWindow 是否始终位于其它窗口之前。*/
		public function get alwaysInFront():Boolean
		{
			if (nativeWindow && !nativeWindow.closed)
				return nativeWindow.alwaysInFront;
			else
				return _alwaysInFront;
		}
		public function set alwaysInFront(value:Boolean):void
		{
			_alwaysInFront = value;
			if (nativeWindow && !nativeWindow.closed)
				nativeWindow.alwaysInFront = value;
		}
		/**
		 * 指定当关闭最后一个窗口时，AIR 应用程序是退出，还是继续在背景中运行。 
		 * @return 
		 * 
		 */		
		public function get autoExit():Boolean
		{
			return nativeApplication.autoExit;
		}
		
		public function set autoExit(value:Boolean):void
		{
			nativeApplication.autoExit = value;
		}
		
		protected function get bounds():Rectangle
		{
			return nativeWindow.bounds;
		}

		protected function set bounds(value:Rectangle):void
		{
			nativeWindow.bounds = value;
			boundsChanged = true;
			
			invalidateProperties();
			invalidateSize();
		}
		/**
		 * 如果已关闭基础窗口，则返回 true。 
		 * @return 
		 * 
		 */		
		public function get closed():Boolean
		{
			return nativeWindow.closed;
		}
		
		public function get maximizable():Boolean
		{
			if (!nativeWindow.closed)
				return nativeWindow.maximizable;
			else
				return false;
		}
		
		public function get minimizable():Boolean
		{
			if (!nativeWindow.closed)
				return nativeWindow.minimizable;
			else
				return false;
		}
		
		public function get nativeWindow():NativeWindow
		{
			if ((systemManager != null) && (systemManager.stage != null))
				return systemManager.stage.nativeWindow;
			else
				return _nativeWindow;
			
			return null;
		}
		
		public function get resizable():Boolean
		{
			if (nativeWindow.closed)
				return false;
			return nativeWindow.resizable;
		}
		
		public function get systemChrome():String
		{
			return _systemChrome;
		}
		
		public function get title():String
		{
			if(titleChanged||!nativeWindow)
				return _title;
			return nativeWindow.title;
		}
		
		public function set title(value:String):void
		{
			titleChanged = true;
			_title = value;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			dispatchEvent(new Event("titleChanged"));
		}
		
		public function get transparent():Boolean
		{
			if (nativeWindow.closed)
				return false;
			return nativeWindow.transparent;
		}
		
		public function get type():String
		{
			return NativeWindowType.NORMAL;
		}
		
		public function move(x:Number, y:Number):void
		{
			if (nativeWindow && !nativeWindow.closed)
			{
				var tmp:Rectangle = nativeWindow.bounds;
				tmp.x = x;
				tmp.y = y;
				nativeWindow.bounds = tmp;
			}
		}
		
		/**
		 * 激活基础 NativeWindow（即使此应用程序当前未处于活动状态）。 
		 * 
		 */		
		public function activate():void
		{
		
			if (!nativeWindow.closed)
			{
				nativeWindow.activate();   
				visible = true;             
			}
		}
		
		public function close():void
		{
			if (nativeWindow && !nativeWindow.closed)
			{
				var e:Event = new Event("closing", false, true);
				stage.nativeWindow.dispatchEvent(e);
				if (!(e.isDefaultPrevented()))
				{
					stage.nativeWindow.close();
				}
			}
		}
		/**
		 * 关闭窗口并退出应用程序。 
		 * 
		 */		
		public function exit():void
		{
			nativeApplication.exit();
		}
		
		public function maximize():void
		{
			if (!nativeWindow || !nativeWindow.maximizable || nativeWindow.closed)
				return;
			if (stage.nativeWindow.displayState!= NativeWindowDisplayState.MAXIMIZED)
			{
				var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, stage.nativeWindow.displayState,
					NativeWindowDisplayState.MAXIMIZED);
				stage.nativeWindow.dispatchEvent(f);
				if (!f.isDefaultPrevented())
				{
					toMax = true;
					invalidateProperties();
				}
			}
		}
		
		public function minimize():void
		{
			if (!minimizable)
				return;
			
			if (!nativeWindow.closed)
			{
				var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, nativeWindow.displayState,
					NativeWindowDisplayState.MINIMIZED)
				stage.nativeWindow.dispatchEvent(e);
				if (!e.isDefaultPrevented())
					stage.nativeWindow.minimize();
			}
		}
		
		public function restore():void
		{
			if (!nativeWindow.closed)
			{
				var e:NativeWindowDisplayStateEvent;
				if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
				{
					e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MAXIMIZED,
						NativeWindowDisplayState.NORMAL);
					stage.nativeWindow.dispatchEvent(e);
					if (!e.isDefaultPrevented())
						nativeWindow.restore();
				}
				else if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
				{
					e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MINIMIZED,
						NativeWindowDisplayState.NORMAL);
					stage.nativeWindow.dispatchEvent(e);
					if (!e.isDefaultPrevented())
						nativeWindow.restore();
				}
			}
		}
		
		/**
		 * 将窗口排序到另一个窗口的正后方。要将窗口排
		 * 序到不实现 IWindow 的 NativeWindow 之后，请
		 * 使用此窗口的 nativeWindow 的 orderInBackOf() 方法。
		 * @param window 此窗口将排序到其后方的 IWindow
		 * （Window 或 WindowedAplication）。
		 * @return 如果窗口成功排序到另一个窗口的后方，则为 true；
		 * 如果窗口不可见或处于最小化状态，则为 false。
		 * 
		 */	
		public function orderInBackOf(window:IWindow):Boolean
		{
			if (nativeWindow && !nativeWindow.closed)
				return nativeWindow.orderInBackOf(window.nativeWindow);
			else
				return false;
		}
		
		/**
		 * 将窗口排序到另一个窗口的正前方。要将该窗口排序到不实
		 * 现 IWindow 的 NativeWindow 之前，请使用此窗口的 nativeWindow
		 * 的 orderInFrontOf() 方法。
		 * @param window 此窗口将排序到其前方的 IWindow
		 * （Window 或 WindowedAplication）。
		 * @return 如果窗口成功排序到另一个窗口的前方，
		 * 则为 true；如果该窗口不可见或处于最小化状态，则为 false。
		 * 
		 */	
		public function orderInFrontOf(window:IWindow):Boolean
		{
			if (nativeWindow && !nativeWindow.closed)
				return nativeWindow.orderInFrontOf(window.nativeWindow);
			else
				return false;
		}
		/**
		 * 将窗口排序到同一应用程序中的其它所有窗口的后方。
		 * @return 
		 * 如果窗口成功排序到其它所有窗口的后方，则为 true；
		 * 如果该窗口不可见或处于最小化状态，则为 false。 
		 * 
		 */	
		public function orderToBack():Boolean
		{
			if (nativeWindow && !nativeWindow.closed)
				return nativeWindow.orderToBack();
			else
				return false;
		}
		/**
		 * 将窗口排序到同一应用程序中的其它所有窗口的前方。
		 * @return 
		 * 如果窗口成功排序到其它所有窗口的前方，则为 true；
		 * 如果该窗口不可见或处于最小化状态，则为 false。 
		 * 
		 */	
		public function orderToFront():Boolean
		{
			if (nativeWindow && !nativeWindow.closed)
				return nativeWindow.orderToFront();
			else
				return false;
		}
		
		override protected function getCurrentSkinState():String 
		{
			if (nativeWindow.closed)
				return "disabled";
			
			if (nativeWindow.active)
				return enabled ? "normal" : "disabled";
			else
				return enabled ? "normalAndInactive" : "disabledAndInactive";
			
		} 
		
		private function window_resizeHandler(event:NativeWindowBoundsEvent):void
		{
			if (stage == null)
				return;
			invalidateDisplayList();
			var dispatchWidthChangeEvent:Boolean = (bounds.width != stage.stageWidth);
			var dispatchHeightChangeEvent:Boolean = (bounds.height != stage.stageHeight);
			
			bounds.x = stage.x;
			bounds.y = stage.y;
			bounds.width = stage.stageWidth;
			bounds.height = stage.stageHeight;
			validateNow();
			dispatchEvent(new ResizeEvent(ResizeEvent.UI_RESIZE));
			if (dispatchWidthChangeEvent)
				dispatchEvent(new Event("widthChanged"));
			if (dispatchHeightChangeEvent)
				dispatchEvent(new Event("heightChanged"));
			
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(nativeWindow  == null) return;
			
			if (minWidthChanged || minHeightChanged || maxWidthChanged || maxHeightChanged)
			{
				var minSize:Point = nativeWindow.minSize;
				var maxSize:Point = nativeWindow.maxSize;
				
				var newMinWidth:Number  = minWidthChanged  ? _minWidth  + chromeWidth()  : minSize.x;
				var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : minSize.y;
				var newMaxWidth:Number  = maxWidthChanged  ? _maxWidth  + chromeWidth()  : maxSize.x;
				var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : maxSize.y;
				
				if (minWidthChanged || minHeightChanged)
				{
					// If the new min size is greater than the old max size, then
					// we need to set the new max size now.
					if ((maxWidthChanged && newMinWidth > minSize.x) || 
						(maxHeightChanged && newMinHeight > minSize.y))
					{
						nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
					}
					
					nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
				}
				
				if (newMaxWidth != maxSize.x || newMaxHeight != maxSize.y)
					nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
			}
			
			// minimum width and height
			if (minWidthChanged || minHeightChanged)
			{
				if (minWidthChanged)
				{
					minWidthChanged = false;
					if (width < minWidth)
						width = minWidth;
					dispatchEvent(new Event("minWidthChanged"));
				}
				if (minHeightChanged)
				{
					minHeightChanged = false;
					if (height < minHeight)
						height = minHeight;
					dispatchEvent(new Event("minHeightChanged"));
				}
			}
			
			// maximum width and height
			if (maxWidthChanged || maxHeightChanged)
			{
				if (maxWidthChanged)
				{
					maxWidthChanged = false;
					if (width > maxWidth)
						width = maxWidth;
					dispatchEvent(new Event("maxWidthChanged"));
				}
				if (maxHeightChanged)
				{
					maxHeightChanged = false;
					if (height > maxHeight)
						height = maxHeight;
					dispatchEvent(new Event("maxHeightChanged"));
				}
			}
			
			if (boundsChanged)
			{
				// Work around an AIR issue setting the stageHeight to zero when 
				// using system chrome. The set of the stage.stageHeight property
				// is rejected unless the nativeWindow is first set to the proper
				// height. 
				// Don't perform this workaround if the window has zero height due 
				// to being minimized. Setting the nativeWindow height to non-zero 
				// causes AIR to restore the window.
				if (_bounds.height == 0 && 
					nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED &&
					systemChrome == NativeWindowSystemChrome.STANDARD)
					nativeWindow.height = chromeHeight() + _bounds.height;
				
				// Set _width and _height.  This will update the mirroring
				// transform if applicable.
				setActualSize(_bounds.width, _bounds.height);
				
				// We use temporary variables because when we set stageWidth or 
				// stageHeight _bounds will be overwritten when we receive 
				// a RESIZE event.
				var newWidth:Number  = _bounds.width;
				var newHeight:Number = _bounds.height;
				systemManager.stage.stageWidth = newWidth;
				systemManager.stage.stageHeight = newHeight;
				boundsChanged = false;
			}
			
			if (titleChanged)
			{
				if (!nativeWindow.closed)
					systemManager.stage.nativeWindow.title = _title;
				titleChanged = false;
			}
			
			if (toMax)
			{
				toMax = false;
				if (!nativeWindow.closed)
					nativeWindow.maximize();
			}
		}
		
		private function nativeWindow_activateHandler(event:Event):void{
			dispatchEvent(new Event(Event.ACTIVATE));
			invalidateSkinState();}   
		private function nativeWindow_deactivateHandler(event:Event):void{
			dispatchEvent(new Event(Event.DEACTIVATE));
			invalidateSkinState();}
		
		
		//可能是由于原生窗体更新与虚拟机里窗体不一致等问题，经常导致无法正常获取边框尺寸。
		private function chromeWidth():Number{
			return 0}
		private function chromeHeight():Number{
			return 0}
		
	}
}