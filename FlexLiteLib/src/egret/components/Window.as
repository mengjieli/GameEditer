package egret.components
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	
	import egret.core.IWindow;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.managers.SystemManager;
	import egret.utils.AppRenderMode;
	
	use namespace ns_egret;
	
	/**
	 * 窗口关闭
	 */	
	[Event(name="close", type="flash.events.Event")]
	/**
	 * 窗口即将关闭，这个事件可以取消
	 */	
	[Event(name="closing", type="flash.events.Event")]
	/**
	 * 窗口显示状态发生改变
	 */	
	[Event(name="displayStateChange", type="flash.events.NativeWindowDisplayStateEvent")]
	/**
	 * 窗口显示状态即将发生改变，这个事件可以取消
	 */	
	[Event(name="displayStateChanging", type="flash.events.NativeWindowDisplayStateEvent")]
	/**
	 * 窗口位置即将移动，这个事件可以取消
	 */	
	[Event(name="moving", type="flash.events.NativeWindowBoundsEvent")]
	/**
	 * 窗口位置发生移动
	 */	
	[Event(name="move", type="flash.events.NativeWindowBoundsEvent")]
	/**
	 * 尺寸即将发生改变，这个事件可以取消。
	 */	
	[Event(name="resizing", type="flash.events.NativeWindowBoundsEvent")]
	/**
	 * 尺寸已经发生改变
	 */	
	[Event(name="resize", type="flash.events.NativeWindowBoundsEvent")]
	
	/**
	 * 实现了自动布局和皮肤的一个窗体类，内部是实际上是创建了一个原生窗体。然后本类继承了一个
	 * SkinnableContainer，并且将自身添加到原生窗体的舞台上。
	 * @author 雷羽佳 2014.6.18 12:15
	 * 
	 */	
	public class Window extends SkinnableContainer implements IWindow
	{
		/**
		 * 构造函数
		 */		
		public function Window()
		{
			super.includeInLayout = false;
		}
		
		//------------------------------------窗体初始化参数----------------------------------------
		
		/**
		 * 是否可以最大化
		 */
		private var _maximizable:Boolean = true;
		/**
		 * 指定窗口是否可最大化。此属性的值在窗口打开后是只读的。
		 */
		public function get maximizable():Boolean{
			return _maximizable;
		}
		public function set maximizable(value:Boolean):void{
			if(!_nativeWindow) _maximizable = value;
		}
		
		/**
		 * 是否可以最小化
		 */
		private var _minimizable:Boolean = true;
		/**
		 * 指定窗口是否可最小化。此属性在窗口打开后是只读的。
		 */
		public function get minimizable():Boolean{
			return _minimizable;
		}
		public function set minimizable(value:Boolean):void{
			if(!_nativeWindow) _minimizable = value;
		}
		
		/**
		 * 是否可以调整大小
		 */
		private var _resizable:Boolean = true;
		/**
		 * 指定窗口是否可调整大小。此属性在窗口打开后是只读的。
		 */
		public function get resizable():Boolean{
			return _resizable;
		}
		public function set resizable(value:Boolean):void{
			if(!_nativeWindow) _resizable = value;
		}
		
		/**
		 * 父级窗体
		 */
		private var _ownerWindow:NativeWindow = null;
		/**
		 * 指定窗口的父级窗体。此属性在窗口打开后是只读的。<br/>
		 * 指定了父级窗体的窗体将永远至于父级窗体之上，同时会跟随父级窗体最小化与关闭
		 */
		public function get ownerWindow():NativeWindow{
			return _ownerWindow;
		}
		public function set ownerWindow(value:NativeWindow):void{
			if(!_nativeWindow) _ownerWindow = value;
		}
		
		/**
		 * 系统镶边
		 */
		private var _systemChrome:String = NativeWindowSystemChrome.STANDARD;
		/**
		 * 指定窗口具有的系统镶边类型（如果有）。
		 * 可能值集由  <code>NativeWindowSystemChrome</code>类中的常量定义。 
		 * 打开窗口后，此属性将立即变为只读模式。
		 * <p>
		 * 默认值为 <code> NativeWindowSystemChrome.STANDARD。 </code>
		 */
		public function get systemChrome():String{
			return _systemChrome;
		}
		public function set systemChrome(value:String):void{
			if(!_nativeWindow) _systemChrome = value;
		}
		
		/**
		 * 是否透明
		 */
		private var _transparent:Boolean = false;
		/**
		 * 指定窗口是否透明。对于使用系统镶边的窗口，
		 * 不支持将此属性设置为 true。
		 * <p>
		 * 此属性在窗口打开后是只读的。
		 */
		public function get transparent():Boolean{
			return _transparent;
		}
		public function set transparent(value:Boolean):void{
			if(!_nativeWindow) _transparent = value;
		}
		
		/**
		 * 类型
		 */
		private var _type:String = "normal";
		/**
		 * 指定此组件代表的  <code>NativeWindow</code>类型。
		 * 可能值集由  <code>NativeWindowType</code>类中的常量定义。 
		 * 打开窗口后，此属性将立即变为只读模式。
		 * <p>
		 * 默认值为 <code>NativeWindowType.NORMAL。</code>
		 */
		public function get type():String{
			return _type;
		}
		public function set type(value:String):void{
			if(!_nativeWindow) _type = value;
		}
		
		/**
		 * 得到窗口初始化选项 
		 */		
		protected function setupWindowInitOptions():NativeWindowInitOptions
		{
			var init:NativeWindowInitOptions = new NativeWindowInitOptions();
			init.maximizable = _maximizable;
			init.minimizable = _minimizable;
			init.resizable = _resizable;
			init.type = _type;
			init.owner = _ownerWindow;
			if(AppRenderMode.renderMode)
			{
				init.renderMode = AppRenderMode.renderMode
			}
			init.systemChrome = _systemChrome;
			if(_systemChrome==NativeWindowSystemChrome.NONE){
				init.transparent = _transparent;
			}
			return init;        
		}
		
		//------------------------------------窗体开关控制----------------------------------------
		
		private var _nativeWindow:NativeWindow;
		/**
		 * 此 Window 组件使用的基础 NativeWindow。 
		 */		
		public function get nativeWindow():NativeWindow
		{
			return _nativeWindow;
		}
		
		private var openActive:Boolean = true;
		/**
		 * 创建基础 NativeWindow 并将其打开。关闭后，
		 * Window 对象仍为一个有效的引用，但是不允许
		 * 访问大多数的属性和方法。 
		 */		
		public function open(openWindowActive:Boolean = true):void
		{
			if(!_nativeWindow)
			{
				_nativeWindow = new NativeWindow(setupWindowInitOptions());
				var sm:SystemManager = new SystemManager();
				stage.addChild(sm);
				systemManager = sm;
				sm.addElement(this);
				_nativeWindow.alwaysInFront = _alwaysInFront;
			}
			openActive = openWindowActive;
			_nativeWindow.addEventListener(Event.ACTIVATE, nativeWindow_activateHandler, false, 0, true);
			_nativeWindow.addEventListener(Event.DEACTIVATE, nativeWindow_deactivateHandler, false, 0, true);
			_nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,dispatchEvent);
			_nativeWindow.addEventListener(Event.CLOSING, dispatchEvent);
			_nativeWindow.addEventListener(Event.CLOSE, dispatchEvent, false, 0, true);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZING, dispatchEvent);
			_nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResizeHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			invalidateSkinState();
			invalidateDisplayList();
			minWidthChanged = true;
			minHeightChanged = true;
			maxWidthChanged = true;
			maxHeightChanged = true;
			titleChanged = true;
			validateProperties();
		}
		
		private var frameCounter:int = 0;
		/**
		 * 延迟两帧激活窗口
		 */		
		private function enterFrameHandler(e:Event):void
		{
			if (frameCounter == 2)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				if( _nativeWindow && !closed)
				{
					_nativeWindow.visible = _nativeWindowVisible;
					if (_nativeWindow.visible && openActive)
					{
						_nativeWindow.activate();
					}
				}
			}
			frameCounter++;
		}
		
		/**
		 * 窗口激活
		 */		
		private function nativeWindow_activateHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.ACTIVATE));
			invalidateSkinState();
		}   
		/**
		 * 窗口失去焦点
		 */		
		private function nativeWindow_deactivateHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.DEACTIVATE));
			invalidateSkinState();
		}
		
		/**
		 * 正在更新显示列表的标志
		 */		
		private var inUpdateDisplayList:Boolean = false;
		/**
		 * 窗口尺寸发生改变
		 */		
		private function onWindowResizeHandler(event:NativeWindowBoundsEvent):void
		{
			if(inUpdateDisplayList||!stage)
				return;
			width = stage.stageWidth;
			height = stage.stageHeight;
			validateNow();
			dispatchEvent(event);
		}
		
		/**
		 * 关闭窗口。可取消此操作。 
		 */		
		public function close():void
		{
			if (_nativeWindow && !closed)
			{
				var e:Event = new Event(Event.CLOSING, false, true);
				_nativeWindow.dispatchEvent(e);
				if (!(e.isDefaultPrevented()))
				{
					_closed = true;
					var sm:SystemManager = systemManager as SystemManager;
					stage.removeChild(sm);
					UIGlobals.removeStage(stage);
					_nativeWindow.close();
					_nativeWindow.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,dispatchEvent);
					_nativeWindow.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,dispatchEvent);
					_nativeWindow.removeEventListener(Event.CLOSING, dispatchEvent);
					_nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVING, dispatchEvent);
					_nativeWindow.removeEventListener(NativeWindowBoundsEvent.MOVE, dispatchEvent);
					_nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZING, dispatchEvent);
					_nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, onWindowResizeHandler);
					sm.removeElement(this);
					systemManager = null
				}
			}
		}
		
		private var _closed:Boolean = false;
		/**
		 * 窗口是否处于关闭状态
		 */			
		public function get closed():Boolean
		{
			if(nativeWindow && nativeWindow.closed)
				return true;
			return _closed;
		}
		
		//------------------------------------窗体状态关控制----------------------------------------
		
		/**
		 * 存储alwaysInFront这个属性
		 */
		private var _alwaysInFront:Boolean = false;
		/**
		 * 确定基础 <code>NativeWindow</code>是否始终显示在其他窗口的前方（包
		 * 括其他应用程序的窗口）。设置此属性的同时也就设置了基础 
		 * <code>NativeWindow</code>的 <code>alwaysInFront</code>属性。有关此项设置如何影
		 * 响窗口堆叠顺序的详细信息，请参阅 <code>NativeWindow.alwaysInFront</code>
		 * 属性说明。
		 */
		public function get alwaysInFront():Boolean
		{
			if (_nativeWindow && !_nativeWindow.closed)
				return _nativeWindow.alwaysInFront;
			else
				return _alwaysInFront;
		}
		public function set alwaysInFront(value:Boolean):void
		{
			_alwaysInFront = value;
			if (_nativeWindow && !_nativeWindow.closed)
				_nativeWindow.alwaysInFront = value;
		}
		
		private var _maxWidth:Number = 2880;
		private var maxWidthChanged:Boolean = false;
		/**
		 * 布局过程中父级要考虑的组件最大建议宽度。此值采用组件坐标（以像素为单位）。此属性的默认值由组
		 * 件开发人员设置。
		 * <p>
		 * 组件开发人员使用此属性设置组件宽度的上限。
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定 其默认大小时不会使用此值。因此，如果父项为
		 *  Container，则此属性可能不会产生任何效果，要么 就是容器在此属性中不起作用。由于此值位于组件坐
		 * 标中，因此与其父项相关的真正 maxWidth 受 scaleX 属性影响。有些组件从理论上没有宽度限制。
		 */		
		override public function get maxWidth():Number
		{
			if (_nativeWindow && !maxHeightChanged)
				return _nativeWindow.maxSize.x - chromeWidth();
			else
				return _maxWidth;
		}
		
		override public function set maxWidth(value:Number):void
		{
			_maxWidth = value;
			maxWidthChanged = true;
			invalidateProperties();
		}
		
		private var _minWidth:Number = 0;
		private var minWidthChanged:Boolean = false;
		/**
		 * 布局过程中父级要考虑的组件最小建议宽度。此值采用组件坐标（以像素为单位）。默认值取决于组件的实现方式。 
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定其默认大小时不会使用此值。因此，如果父项为 Container，
		 * 则此属性可能不会产生任何效果，要么就是容器在此属性中不起作用。由于此值位于组件坐标中，因此与
		 * 其父项相关的真正 minWidth 受 scaleX 属性影响。
		 */	
		override public function get minWidth():Number
		{
			if (_nativeWindow && !minWidthChanged)
				return _nativeWindow.minSize.x - chromeWidth();
			else
				return _minWidth;
		}
		
		override public function set minWidth(value:Number):void
		{
			_minWidth = value;
			minWidthChanged = true;
			invalidateProperties();
		}
		
		
		private var _maxHeight:Number = 2880;
		private var maxHeightChanged:Boolean = false;
		/**
		 * 布局过程中父级要考虑的组件最大建议高度。此值采用组件坐标（以像素为单位）。此属性的默认值由组件开发人员设置。 
		 * <p>
		 * 组件开发人员使用此属性设置组件高度的上限。
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定其默认大小时不会使用此值。因此，如果父项为 Container，则此属性
		 * 可能不会产生任何效果，要么就是容器在此属性中不起作用。由于此值位于组件坐标中，因此与其父项相关的真正 maxHeight 
		 * 受 scaleY 属性影响。有些组件从理论上没有高度限制。
		 */
		override public function get maxHeight():Number
		{
			if (_nativeWindow && !maxHeightChanged)
				return _nativeWindow.maxSize.y - chromeHeight();
			else
				return _maxHeight;
		}
		
		override public function set maxHeight(value:Number):void
		{
			_maxHeight = value;
			maxHeightChanged = true;
			invalidateProperties();
		}
		
		private var _minHeight:Number = 0;
		private var minHeightChanged:Boolean = false;
		
		/**
		 * 布局过程中父级要考虑的组件最小建议高度。此值采用组件坐标（以像素为单位）。默认值取决于组件的实现方式。 
		 * <p>
		 * 容器使用此值计算组件的大小和位置。组件本身确定其默认大小时不会使用此值。因此，如果父项为 Container，
		 * 则此属性可能不会产生任何效果，要么就是容器在此属性中不起作用。由于此值位于组件坐标中，因此与
		 * 其父项相关的真正 minHeight 受 scaleY 属性影响。
		 * @return 
		 */
		override public function get minHeight():Number
		{
			if (_nativeWindow && !minHeightChanged)
				return _nativeWindow.minSize.y - chromeHeight();
			else
				return _minHeight;
		}
		
		override public function set minHeight(value:Number):void
		{
			_minHeight = value;
			minHeightChanged = true;
			invalidateProperties();
		}
		
		private var _nativeWindowVisible:Boolean = true;
		
		/**
		 * 显示对象是否可见。不可见的显示对象已被禁用。例如，如果 InteractiveObject 实例的 visible=false，则无法单击该对象。 
		 * <p>
		 * 当设置为 true 时，此对象将分派 show 事件。当设置为 false 时，此对象将分派 hide 事件。无论在哪种情况下，对象的子项
		 * 都不会生成 show 或 hide 事件，除非明确地针对该对象编写一个实现来执行此操作。
		 */		
		override public function get visible():Boolean
		{
			if (_nativeWindow && _nativeWindow.closed)
				return false;
			if (_nativeWindow)
				return _nativeWindow.visible;
			else
				return _nativeWindowVisible;
		}
		
		override public function set visible(value:Boolean):void
		{
			if (!_nativeWindow)
			{
				_nativeWindowVisible = value;
				invalidateProperties();
			}else if (!_nativeWindow.closed)
			{
				_nativeWindow.visible = value;
			}
		}
		
		private var _title:String = "";
		
		private var titleChanged:Boolean = false;
		
		/**
		 *窗口标题栏和任务栏中显示的标题文本。
		 * @return 
		 * 
		 */
		public function get title():String
		{
			return _title;
		}
		public function set title(value:String):void
		{
			titleChanged = true;
			_title = value;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var toMax:Boolean = false;
		/**
		 * 最大化窗口；如果窗口已经最大化，则不执行任何操作。
		 */		
		public function maximize():void
		{
			if (!_nativeWindow || !_nativeWindow.maximizable || _nativeWindow.closed)
				return;
			if (_nativeWindow.displayState!= NativeWindowDisplayState.MAXIMIZED)
			{
				var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, _nativeWindow.displayState,
					NativeWindowDisplayState.MAXIMIZED);
				_nativeWindow.dispatchEvent(f);
				if (!f.isDefaultPrevented())
				{
					toMax = true;
					invalidateProperties();
				}
			}
		}
		
		/**
		 * 最小化窗口。 
		 */	
		public function minimize():void
		{
			if (!minimizable)
				return;
			
			if (_nativeWindow&&!_nativeWindow.closed)
			{
				var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, _nativeWindow.displayState,
					NativeWindowDisplayState.MINIMIZED)
				_nativeWindow.dispatchEvent(e);
				if (!e.isDefaultPrevented())
					_nativeWindow.minimize();
			}
		}
		
		/**
		 * 还原窗口（如果窗口处于最大化状态，则取消最大化；如果处于最小化状态，则取消最小化）。 
		 */		
		public function restore():void
		{
			if (_nativeWindow&&!_nativeWindow.closed)
			{
				var e:NativeWindowDisplayStateEvent;
				if (_nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
				{
					e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MAXIMIZED,
						NativeWindowDisplayState.NORMAL);
					_nativeWindow.dispatchEvent(e);
					if (!e.isDefaultPrevented())
						_nativeWindow.restore();
				}
				else if (_nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
				{
					e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MINIMIZED,
						NativeWindowDisplayState.NORMAL);
					_nativeWindow.dispatchEvent(e);
					if (!e.isDefaultPrevented())
						_nativeWindow.restore();
				}
			}
		}
		
		
		/**
		 * 激活基础 NativeWindow（即使此 Window 的应用程序当前未处于活动状态）。 
		 */		
		public function activate():void
		{
			if (_nativeWindow && !_nativeWindow.closed)
			{
				_nativeWindow.activate();   
				visible = true;             
			}
		}
		
		/**
		 * 将窗口排序到另一个窗口的正后方。要将窗口排序到不实现 IWindow 的 NativeWindow 之后，请使用此窗口的
		 *  nativeWindow 的 orderInBackOf() 方法。
		 * @param window 此窗口将排序到其后方的 IWindow（Window 或 WindowedAplication）。
		 * @return 如果窗口成功排序到另一个窗口的后方，则为 true；如果窗口不可见或处于最小化状态，则为 false。
		 */		
		public function orderInBackOf(window:IWindow):Boolean
		{
			if (_nativeWindow && !_nativeWindow.closed)
				return _nativeWindow.orderInBackOf(window.nativeWindow);
			else
				return false;
		}
		
		/**
		 * 将窗口排序到另一个窗口的正前方。要将该窗口排序到不实现 IWindow 的 NativeWindow 之前，请使用此窗口的 nativeWindow
		 * 的 orderInFrontOf() 方法。
		 * @param window 此窗口将排序到其前方的 IWindow（Window 或 WindowedAplication）。
		 * @return 如果窗口成功排序到另一个窗口的前方，则为 true；如果该窗口不可见或处于最小化状态，则为 false。
		 */		
		public function orderInFrontOf(window:IWindow):Boolean
		{
			if (_nativeWindow && !_nativeWindow.closed)
				return _nativeWindow.orderInFrontOf(window.nativeWindow);
			else
				return false;
		}
		
		/**
		 * 将窗口排序到同一应用程序中的其它所有窗口的后方。
		 * @return 
		 * 如果窗口成功排序到其它所有窗口的后方，则为 true; 如果该窗口不可见或处于最小化状态，则为 false。 
		 */		
		public function orderToBack():Boolean
		{
			if (_nativeWindow && !_nativeWindow.closed)
				return _nativeWindow.orderToBack();
			else
				return false;
		}
		
		/**
		 * 将窗口排序到同一应用程序中的其它所有窗口的前方。
		 * @return 
		 * 如果窗口成功排序到其它所有窗口的前方，则为 true; 如果该窗口不可见或处于最小化状态，则为 false。 
		 */		
		public function orderToFront():Boolean
		{
			if (_nativeWindow && !_nativeWindow.closed)
				return _nativeWindow.orderToFront();
			else
				return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(!_nativeWindow||_nativeWindow.closed)
				return;
			
			if (minWidthChanged || minHeightChanged || maxWidthChanged || maxHeightChanged)
			{
				var minSize:Point = _nativeWindow.minSize;
				var maxSize:Point = _nativeWindow.maxSize;
				var newMinWidth:Number  = minWidthChanged  ? _minWidth  + chromeWidth()  : minSize.x;
				var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : minSize.y;
				var newMaxWidth:Number  = maxWidthChanged  ? _maxWidth  + chromeWidth()  : maxSize.x;
				var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : maxSize.y;
				
				if (minWidthChanged || minHeightChanged)
				{
					if ((maxWidthChanged && newMinWidth > minSize.x) || 
						(maxHeightChanged && newMinHeight > minSize.y))
					{
						_nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
					}
					
					_nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
				}
				
				if (newMaxWidth != maxSize.x || newMaxHeight != maxSize.y)
					_nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
				minWidthChanged = false;
				minHeightChanged = false;
				maxWidthChanged = false;
				maxHeightChanged = false;
			}
			
			if (titleChanged)
			{
				_nativeWindow.title = _title;
				titleChanged = false;
			}
			
			if (toMax)
			{
				toMax = false;
				_nativeWindow.maximize();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			inUpdateDisplayList = true;
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(_nativeWindow&&!_nativeWindow.closed)
			{
				_nativeWindow.width = unscaledWidth+chromeWidth();
				_nativeWindow.height = unscaledHeight+chromeHeight();
			}
			inUpdateDisplayList = false;
		} 
		/**
		 * 系统边框宽度
		 */		
		private function chromeWidth():Number
		{
			return _nativeWindow.width - stage.stageWidth;
		}
		/**
		 * 系统边框高度
		 */		
		private function chromeHeight():Number
		{
			return _nativeWindow.height - stage.stageHeight;
		}
		
		override protected function getCurrentSkinState():String 
		{
			if (!_nativeWindow||_nativeWindow.closed)
				return "disabled";
			
			if (_nativeWindow.active)
				return enabled ? "normal" : "disabled";
			else
				return enabled ? "normalAndInactive" : "disabledAndInactive";
			
		} 
		
		override public function get stage():Stage
		{
			if(_nativeWindow)
				return _nativeWindow.stage;
			return null;
			
		}
		
		[Deprecated] 
		/**
		 * @inheritDoc
		 */
		override public function set includeInLayout(value:Boolean):void
		{
		}
		
		[Deprecated] 
		/**
		 * @inheritDoc
		 */
		override public function setLayoutBoundsSize(layoutWidth:Number, layoutHeight:Number):void
		{
		}
	}
}