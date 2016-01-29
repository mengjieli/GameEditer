package egret.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	
	import egret.components.supportClasses.DefaultSkinAdapter;
	import egret.core.ILayoutElement;
	import egret.core.ISkin;
	import egret.core.ISkinAdapter;
	import egret.core.IStateClient;
	import egret.core.Injector;
	import egret.core.UIComponent;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.events.SkinPartEvent;
	import egret.events.UIEvent;
	import egret.utils.SkinPartUtil;
	
	use namespace ns_egret;
	
	/**
	 * 皮肤部件附加事件 
	 */	
	[Event(name="partAdded", type="egret.events.SkinPartEvent")]
	/**
	 * 皮肤部件卸载事件 
	 */	
	[Event(name="partRemoved", type="egret.events.SkinPartEvent")]
	
	[EXML(show="false")]
	
	[SkinState("normal")]
	[SkinState("disabled")]
	
	/**
	 * 复杂可设置外观组件的基类，接受ISkin类或任何显示对象作为皮肤。
	 * 当皮肤为ISkin时，将自动匹配两个实例内同名的公开属性(显示对象)，
	 * 并将皮肤的属性引用赋值到此类定义的同名属性(必须没有默认值)上,
	 * 如果要对公共属性添加事件监听或其他操作，
	 * 请覆盖partAdded()和partRemoved()方法
	 * @author dom
	 */
	public class SkinnableComponent extends UIComponent
	{
		/**
		 * 构造函数
		 */		
		public function SkinnableComponent()
		{
			super();
		}
		/**
		 * 主机组件标识符。用于唯一确定一个组件的名称。
		 * 在解析skinName时，会把此属性的值传递给ISkinAdapter.getSkin()方法，以参与皮肤解析的规则判断。
		 * 用户自定义的组件若不对此属性赋值，将会继承父级的标识符定义。
		 */
		public var hostComponentKey:String = "";
		
		/**
		 * 外部显式设置了皮肤名
		 */
		ns_egret var skinNameExplicitlySet:Boolean = false;
		
		ns_egret var _skinName:Object;
		/**
		 * 皮肤标识符。可以为Class,String,或DisplayObject实例等任意类型，具体规则由项目注入的素材适配器决定，
		 * 适配器根据此属性值解析获取对应的显示对象，并赋值给skin属性。
		 */
		public function get skinName():Object{
			return _skinName;
		}
		
		public function set skinName(value:Object):void{
			if(_skinName==value)
				return;
			_skinName = value;
			skinNameExplicitlySet = true;
			if(createChildrenCalled){
				parseSkinName();
			}
		}
		
		ns_egret var _skin:Object;
		/**
		 * 皮肤对象实例。
		 */
		public function get skin():Object{
			return _skin;
		}
		
		private var createChildrenCalled:Boolean = false;
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void{
			super.createChildren();
			parseSkinName();
			createChildrenCalled = true;
		}
		
		/**
		 * 皮肤解析适配器
		 */
		private static var skinAdapter:ISkinAdapter;
		private static var defaultTheme:Theme;
		/**
		 * 解析skinName
		 */
		private function parseSkinName():void{
			var adapter:ISkinAdapter = skinAdapter;
			if(!adapter)
				adapter = getSkinAdapter();
			
			var skin:Object = adapter.getSkin(_skinName,this);
			if(!skin)
			{
				var theme:Theme = defaultTheme;
				if(!theme)
					theme = getDefaultTheme();
				skin = theme.getDefaultSkin(this);
			}
			var oldSkin:Object = this._skin;
			detachSkin(oldSkin);
			if(oldSkin is DisplayObject){
				removeFromDisplayList(DisplayObject(oldSkin));
			}
			
			this._skin = skin;
			if(skin is DisplayObject){
				addToDisplayListAt(DisplayObject(skin),0);
			}
			attachSkin(skin);
			invalidateSkinState();
			invalidateSize();
			invalidateDisplayList();
			
			if(hasEventListener(UIEvent.SKIN_CHANGED)){
				var event:UIEvent = new UIEvent(UIEvent.SKIN_CHANGED);
				dispatchEvent(event);
			}
		}
		
		private function getDefaultTheme():Theme
		{
			var theme:Theme;
			try{
				theme = Injector.getInstance(Theme);
			}
			catch(e:Error){
				theme = new Theme();
			}
			SkinnableComponent.defaultTheme = theme;
			return theme;
		}
		/**
		 * 获取皮肤适配器
		 */
		private function getSkinAdapter():ISkinAdapter{
			var adapter:ISkinAdapter;
			try{
				adapter = Injector.getInstance(ISkinAdapter);
			}
			catch(e:Error){
				adapter = new DefaultSkinAdapter();
			}
			SkinnableComponent.skinAdapter = adapter;
			return adapter;
		}
		
		private var skinLayoutEnabled:Boolean = false;
		/**
		 * 附加皮肤
		 */		
		protected function attachSkin(skin:Object):void
		{
			if(skin&&!(skin is DisplayObject))
				skinLayoutEnabled = true;
			else
				skinLayoutEnabled = false;
			if(skin is ISkin)
			{
				var newSkin:ISkin = skin as ISkin;
				newSkin.hostComponent = this;
				findSkinParts();
			}
		}
		
		private static const ID_MAP:QName = new QName(ns_egret, "idMap");
		/**
		 * 匹配皮肤和主机组件的公共变量，并完成实例的注入。此方法在附加皮肤时会自动执行一次。
		 * 若皮肤中含有延迟实例化的子部件，在子部件实例化完成时需要从外部再次调用此方法,完成注入。
		 */	
		public function findSkinParts():void
		{
			var curSkin:Object = this._skin;
			if(!curSkin||!(curSkin is ISkin))
				return;
			if(curSkin[ID_MAP])
				curSkin = curSkin[ID_MAP];
			var skinParts:Vector.<String> = SkinPartUtil.getSkinParts(this);
			
			for each(var partName:String in skinParts)
			{
				if((partName in this)&&(partName in curSkin)&&curSkin[partName] != null
					&&this[partName]==null)
				{
					try
					{
						this[partName] = curSkin[partName];
						partAdded(partName,curSkin[partName]);
					}
					catch(e:Error)
					{
					}
				}
			}
		}
		
		/**
		 * 卸载皮肤
		 */		
		protected function detachSkin(skin:Object):void
		{       
			if(skin is ISkin)
			{
				var skinParts:Vector.<String> = SkinPartUtil.getSkinParts(this);
				for each(var partName:String in skinParts)
				{
					if(!(partName in this) || !(partName in skin))
						continue;
					if (this[partName] != null)
					{
						partRemoved(partName,this[partName]);
					}
					this[partName] = null;
				}
				(skin as ISkin).hostComponent = null;
			}
		}
		
		/**
		 * 若皮肤是ISkinPartHost,则调用此方法附加皮肤中的公共部件
		 */		
		protected function partAdded(partName:String,instance:Object):void
		{
			var event:SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_ADDED);
			event.partName = partName;
			event.instance = instance;
			dispatchEvent(event);
		}
		/**
		 * 若皮肤是ISkinPartHost，则调用此方法卸载皮肤之前注入的公共部件
		 */		
		protected function partRemoved(partName:String,instance:Object):void
		{
			var event:SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_REMOVED);
			event.partName = partName;
			event.instance = instance;
			dispatchEvent(event);
		}
		
		
		
		//========================皮肤视图状态=====================start=======================
		
		private var stateIsDirty:Boolean = false;
		
		/**
		 * 标记当前需要重新验证皮肤状态
		 */		
		public function invalidateSkinState():void
		{
			if (stateIsDirty)
				return;
			
			stateIsDirty = true;
			invalidateProperties();
		}
		
		/**
		 * 灰度滤镜
		 */		
		private static var grayFilters:Array = [new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1])];
		/**
		 * 旧的滤镜列表
		 */		
		private var oldFilters:Array;
		/**
		 * 被替换过灰色滤镜的标志
		 */		
		private var grayFilterIsSet:Boolean = false;
		
		/**
		 * 子类覆盖此方法,应用当前的皮肤状态
		 */		
		protected function validateSkinState():void
		{
			var curState:String = getCurrentSkinState();
			var hasState:Boolean = false;
			var curSkin:Object = this._skin;
			if(curSkin is IStateClient)
			{
				(curSkin as IStateClient).currentState = curState;
				hasState = (curSkin as IStateClient).hasState(curState);
			}
			if(hasEventListener("stateChanged"))
				dispatchEvent(new Event("stateChanged"));
			if(enabled)
			{
				if(grayFilterIsSet)
				{
					filters = oldFilters;
					oldFilters = null;
					grayFilterIsSet = false;
				}
			}
			else
			{
				if(!hasState&&!grayFilterIsSet)
				{
					oldFilters = filters;
					filters = grayFilters;
					grayFilterIsSet = true;
				}
			}
		}
		
		private var _autoMouseEnabled:Boolean = true;
		/**
		 * 在enabled属性发生改变时是否自动开启或禁用鼠标事件的响应。默认值为true。
		 */
		public function get autoMouseEnabled():Boolean
		{
			return _autoMouseEnabled;
		}
		
		public function set autoMouseEnabled(value:Boolean):void
		{
			if(_autoMouseEnabled==value)
				return;
			_autoMouseEnabled = value;
			if(_autoMouseEnabled)
			{
				super.mouseChildren = enabled ? explicitMouseChildren : false;
				super.mouseEnabled  = enabled ? explicitMouseEnabled  : false;
			}
			else
			{
				super.mouseChildren = explicitMouseChildren;
				super.mouseEnabled  = explicitMouseEnabled;
			}
		}
		
		/**
		 * 外部显式设置的mouseChildren属性值 
		 */		
		private var explicitMouseChildren:Boolean = true;
		/**
		 * @inheritDoc
		 */		
		override public function set mouseChildren(value:Boolean):void
		{
			if(enabled)
				super.mouseChildren = value;
			explicitMouseChildren = value;
		}
		/**
		 * 外部显式设置的mouseEnabled属性值
		 */		
		private var explicitMouseEnabled:Boolean = true;
		/**
		 * @inheritDoc
		 */	
		override public function set mouseEnabled(value:Boolean):void
		{
			if(enabled)
				super.mouseEnabled = value;
			explicitMouseEnabled = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set enabled(value:Boolean):void
		{
			if(super.enabled==value)
				return;
			super.enabled = value;
			if(_autoMouseEnabled)
			{
				super.mouseChildren = value ? explicitMouseChildren : false;
				super.mouseEnabled  = value ? explicitMouseEnabled  : false;
			}
			else
			{
				super.mouseChildren = explicitMouseChildren;
				super.mouseEnabled  = explicitMouseEnabled;
			}
			invalidateSkinState();
		}
		
		/**
		 * 返回组件当前的皮肤状态名称,子类覆盖此方法定义各种状态名
		 */		
		protected function getCurrentSkinState():String 
		{
			return enabled?"normal":"disabled"
		}
		
		//========================皮肤视图状态===================end========================
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(stateIsDirty)
			{
				stateIsDirty = false;
				validateSkinState();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function childXYChanged():void
		{
			if(this.skinLayoutEnabled)
			{
				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			super.measure();
			var skin:Object = this._skin;
			if(!skin)
				return;
			if(this.skinLayoutEnabled)
			{
				skin.measure();
				this.measuredWidth = skin.preferredWidth;
				if(!UIGlobals.getForEgret(this))
					this.measuredMinWidth = skin._hasWidthSet ? Math.min(skin.minWidth,skin.preferredWidth) : skin.minWidth;
				this.measuredHeight = skin.preferredHeight;
				if(!UIGlobals.getForEgret(this))
					this.measuredMinHeight = skin._hasHeightSet ? Math.min(skin.minHeight,skin.preferredHeight) : skin.minHeight;
			}
			else
			{
				if(skin is ILayoutElement)
				{
					this.measuredWidth = ILayoutElement(skin).preferredWidth;
					if(!UIGlobals.getForEgret(this))
						this.measuredMinWidth = ILayoutElement(skin).minWidth;
					this.measuredHeight = ILayoutElement(skin).preferredHeight;
					if(!UIGlobals.getForEgret(this))
						this.measuredMinHeight = ILayoutElement(skin).minHeight;
				}
				else
				{
					var oldScaleX:Number = skin.scaleX;
					var oldScaleY:Number = skin.scaleY;
					skin.scaleX = 1;
					skin.scaleY = 1;
					this.measuredWidth = skin.width;
					this.measuredHeight = skin.height;
					skin.scaleX = oldScaleX;
					skin.scaleY = oldScaleY;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var skin:Object = this._skin;
			if(skin) 
			{
				if(this.skinLayoutEnabled)
				{
					skin.updateDisplayList(unscaledWidth,unscaledHeight);
				}
				else if(skin is ILayoutElement)
				{
					if((skin as ILayoutElement).includeInLayout)
					{
						(skin as ILayoutElement).setLayoutBoundsSize(unscaledWidth,unscaledHeight);
					}
				}
				else if(skin is DisplayObject)
				{
					skin.width = unscaledWidth;
					skin.height = unscaledHeight;
				}
			}
		}
		
		private static const errorStr:String = "在此组件中不可用，若此组件为容器类，请使用";
		[Deprecated] 
		/**
		 * @copy egret.components.Group#addChild()
		 */		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("addChild()"+errorStr+"addElement()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#addChildAt()
		 */		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw(new Error("addChildAt()"+errorStr+"addElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#removeChild()
		 */		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("removeChild()"+errorStr+"removeElement()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#removeChildAt()
		 */		
		override public function removeChildAt(index:int):DisplayObject
		{
			throw(new Error("removeChildAt()"+errorStr+"removeElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#setChildIndex()
		 */		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			throw(new Error("setChildIndex()"+errorStr+"setElementIndex()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#swapChildren()
		 */		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			throw(new Error("swapChildren()"+errorStr+"swapElements()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#swapChildrenAt()
		 */		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			throw(new Error("swapChildrenAt()"+errorStr+"swapElementsAt()代替"));
		}
	}
}