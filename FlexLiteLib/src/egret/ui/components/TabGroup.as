package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import egret.collections.ArrayCollection;
	import egret.components.Button;
	import egret.components.DataGroup;
	import egret.components.Group;
	import egret.components.Rect;
	import egret.components.SkinnableComponent;
	import egret.components.TabBar;
	import egret.components.ViewStack;
	import egret.core.IInvalidating;
	import egret.core.IUIComponent;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.CollectionEventKind;
	import egret.events.IndexChangeEvent;
	import egret.events.ResizeEvent;
	import egret.events.UIEvent;
	import egret.layouts.ScrollBasicLayout;
	import egret.managers.Translator;
	import egret.ui.components.boxClasses.IBoxElement;
	import egret.ui.components.boxClasses.IBoxElementContainer;
	import egret.ui.core.Factory;
	import egret.ui.events.TabGroupEvent;
	import egret.ui.skins.TabGroupSkin;
	import egret.utils.callLater;
	
	use namespace ns_egret;
	
	/**
	 * 指示索引即将更改,可以通过调用preventDefault()方法阻止索引发生更改
	 */	
	[Event(name="changing", type="egret.events.IndexChangeEvent")]
	/**
	 * 选中项改变事件。仅当用户与此控件交互时才抛出此事件。 
	 * 以编程方式更改 selectedIndex 或 selectedItem 属性的值时，该控件并不抛出change事件，而是抛出valueCommit事件。
	 */	
	[Event(name="change", type="egret.events.IndexChangeEvent")]
	/**
	 * 属性改变事件
	 */	
	[Event(name="valueCommit", type="egret.events.UIEvent")]
	
	/**
	 * 选项卡组
	 */
	public class TabGroup extends SkinnableComponent implements IBoxElement
	{
		public function TabGroup()
		{
			super();
			this.skinName = TabGroupSkin;
			this.dataProvider = new ArrayCollection();
			this.selectedIndex = 0;
			
			this.addEventListener(ResizeEvent.UI_RESIZE,onResize);
			this.addEventListener(TabGroupEvent.CLOSE , onClose);
			this.addEventListener(FocusEvent.FOCUS_IN , onFocusIn);
			this.addEventListener(FocusEvent.FOCUS_OUT , onFocusOut);
		}
		
		protected function onClose(event:TabGroupEvent):void
		{
			_isFocus = false;
			validateSkinState();
		}
		
		/**
		 * 当前持有焦点的TabGroup
		 */		
		ns_egret static var currentFocusTabGroup:TabGroup;
		/**
		 * 是否是焦点面板
		 */
		private var _isFocus:Boolean;
		protected function onFocusOut(event:FocusEvent=null):void
		{
			if(!stage || !stage.focus)
			{
				return;
			}
			_isFocus = false;
			currentFocusTabGroup = null;
			validateSkinState();
		}
		
		protected function onFocusIn(event:FocusEvent):void
		{
			if(!selectedPanel)
				return;
			if(currentFocusTabGroup)
			{
				currentFocusTabGroup.onFocusOut();
			}
			currentFocusTabGroup = this;
			
			if(!DisplayObjectContainer(selectedPanel).contains(this.stage.focus))
			{
				setFocus();
			}
			
			_isFocus = true;
			validateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			if(this._isFocus)
				return "focus";
			return super.getCurrentSkinState();
		}
		
		/**
		 * [SkinPart] 可移动区域
		 */		
		public var moveArea:InteractiveObject;
		/**
		 * [SkinPart] 选项卡
		 */
		public var titleTabBar:TabBar;
		/**
		 * [SkinPart] 堆叠容器
		 */
		public var viewStack:ViewStack;
		/**
		 * [SkinPart] 菜单按钮
		 */		
		public var menuButton:Button;
		/**
		 * [SkinPart] 标题工具组 
		 */		
		public var titleGroup:Group;
		
		private var _elementId:int = -1;
		public function get elementId():int
		{
			return _elementId;
		}
		
		public function set elementId(value:int):void
		{
			_elementId = value;
		}
		
		private var _ownerBox:IBoxElement;
		/**
		 * 所属的盒式容器
		 */
		public function get ownerBox():IBoxElement
		{
			return _ownerBox;
		}
		
		public function set ownerBox(value:IBoxElement):void
		{
			_ownerBox = value;
		}
		
		private var _isFirstElement:Boolean = true;
		/**
		 * 是否作为父级的第一个元素
		 */
		public function get isFirstElement():Boolean
		{
			return _isFirstElement;
		}
		
		public function set isFirstElement(value:Boolean):void
		{
			_isFirstElement = value;
		}
		
		public function setLayoutSize(width:Number, height:Number):void
		{
			super.setLayoutBoundsSize(width,height);
		}
		
		private var _defaultWidth:Number = 265;
		/**
		 * 默认宽度
		 */
		public function get defaultWidth():Number
		{
			return _defaultWidth;
		}
		public function set defaultWidth(value:Number):void
		{
			_defaultWidth = value;
		}
		
		private var _defaultHeight:Number = 250;
		/**
		 * 默认高度
		 */
		public function get defaultHeight():Number
		{
			return _defaultHeight;
		}
		public function set defaultHeight(value:Number):void
		{
			_defaultHeight = value;
		}
		
		private var _minimized:Boolean = false;
		/**
		 * 是否处于最小化状态
		 */
		public function get minimized():Boolean
		{
			return _minimized;
		}
		public function set minimized(value:Boolean):void
		{
			if(_minimized==value)
				return;
			_minimized = value;
			var oldVisible:Boolean = super.visible;
			if(value)
				super.visible = false;
			else
				super.visible = explicitVisible;
			if(visible!=oldVisible)
			{
				dispatchEvent(new Event("visibleChanged"));
			}
			dispatchEvent(new Event("minimizedChanged",true));
		}
		
		private var explicitVisible:Boolean = true;
		override public function set visible(value:Boolean):void
		{
			explicitVisible = value;
			if(super.visible == value)
				return;
			super.visible = value;
			dispatchEvent(new Event("visibleChanged"));
		}
		
		override public function get explicitHeight():Number
		{
			if(isNaN(super.explicitHeight))
			{
				var p:ITabPanel = selectedPanel;
				return p?p.explicitHeight:NaN;
			}
			return super.explicitHeight;
		}
		override public function get explicitWidth():Number
		{
			if(isNaN(super.explicitWidth))
			{
				var p:ITabPanel = selectedPanel;
				return p?p.explicitWidth:NaN;
			}
			return super.explicitWidth;
		}
		
		final ns_egret function get $explicitWidth():Number
		{
			return super.explicitWidth;
		}
		
		final ns_egret function get $explicitHeight():Number
		{
			return super.explicitHeight;
		}
		
		private var _parentBox:IBoxElementContainer;
		public function get parentBox():IBoxElementContainer
		{
			return _parentBox;
		}
		
		public function parentBoxChanged(box:IBoxElementContainer,checkOldParent:Boolean=true):void
		{
			if(checkOldParent&&_parentBox)
			{
				if(isFirstElement)
					IBoxElementContainer(_parentBox).firstElement = null;
				else
					IBoxElementContainer(_parentBox).secondElement = null;
			}
			_parentBox = box;
		}
		
		private function onResize(event:ResizeEvent):void
		{
			if(titleTabBar && titleTabBar.dataGroup)
			{
				var dataGroup:DataGroup = titleTabBar.dataGroup;
				dataGroup.maxWidth = Math.max(0,width-22);
				for(var i:int=dataGroup.numElements-1;i>=0;i--)
				{
					var elt:IVisualElement = dataGroup.getElementAt(i);
					if(elt)
						IInvalidating(elt["labelDisplay"]).invalidateSize();
				}
			}
		}
		
		/**
		 * 项呈示器实例到item的引用
		 */
		private var rendererToItemMap:Dictionary = new Dictionary(true);
		
		/**
		 * 添加一个面板
		 * @param panel 添加的面板实例
		 * @param index 要添加到的位置 , -1 表示添加到末尾
		 * @param data 面板的数据，不设置则默认使用面板的data属性。
		 */
		public function addElement(panel:ITabPanel):void
		{
			addElementAt(panel);
			var opendEvent:TabGroupEvent = new TabGroupEvent(TabGroupEvent.PANEL_OPENED,true,true);
			opendEvent.relatePanel = panel;
			dispatchEvent(opendEvent);
		}
		
		/**
		 * 添加一个面板
		 * @param panel 添加的面板实例
		 * @param index 要添加到的位置 , -1 表示添加到末尾
		 * @param data 面板的数据，不设置则默认使用面板的data属性。
		 */
		public function addElementAt(panel:ITabPanel , index:int = -1 , data:Object = null):void
		{
			if(panel.owner && panel.owner is TabGroup)
			{
				if(panel.owner == this && panel.itemIndex == index)
					return;
				else
					TabGroup(panel.owner).removeElement(panel);
			}
			if(!data)
			{
				if(panel.data)
					data = panel.data;
				else
				{
					data = {};
					if(labelField)
						data[labelField] = panel.title;
				}
			}
			if(!dataProvider)
				dataProvider = new ArrayCollection();
			if(index == -1)
				index = dataProvider.length;
			rendererToItemMap[panel] = data;
			dataProvider.addItemAt(data , index);
			var opendEvent:TabGroupEvent = new TabGroupEvent(TabGroupEvent.PANEL_OPENED,true,true);
			opendEvent.relatePanel = panel;
			dispatchEvent(opendEvent);
		}
		
		/**
		 * 移除指定位置的元素
		 */
		public function removeElementAt(index:int):ITabPanel
		{
			var panel:ITabPanel  = getElementAt(index);
			removeElement(panel);
			return panel;
		}
		
		/**
		 * 移除一个面板
		 */
		public function removeElement(panel:ITabPanel):void
		{
			if(!panel || !dataProvider)
				return;
			var index:int = dataProvider.getItemIndex(panel.data);
			if(index>=0)
			{
				dataProvider.removeItemAt(index);
				if(cachePanel == panel)
					pushTitleGroupToTabPanel(panel as TabPanel);
			}
		}
		
		/**
		 * 未设置缓存选中项的值
		 */
		ns_egret static const NO_PROPOSED_SELECTION:int = -2;
		
		/**
		 * 选中项，可能不是最新的。要获取最新的使用selectedIndex属性
		 */
		ns_egret var _selectedIndex:int = -1;
		/**
		 * 在属性提交前缓存选中项索引
		 */		
		private var proposedSelectedIndex:int = NO_PROPOSED_SELECTION;
		
		/**
		 * 当前可见子元素的索引。索引从0开始。
		 */		
		public function get selectedIndex():int
		{
			return proposedSelectedIndex!=NO_PROPOSED_SELECTION?proposedSelectedIndex:_selectedIndex;
		}
		public function set selectedIndex(value:int):void
		{
			setSelectedIndex(value);
		}
		
		/**
		 * 索引到项呈示器的转换数组 
		 */		
		private var indexToRenderer:Array = [];
		
		/**
		 * @inheritDoc
		 */	
		public function get selectedPanel():ITabPanel
		{
			var index:int = selectedIndex;
			if (index>=0&&index<numElements)
				return indexToRenderer[index];
			return null;
		}
		public function set selectedPanel(value:ITabPanel):void
		{
			var index:int = indexToRenderer.indexOf(value);
			if(index>=0&&index<numElements)
				setSelectedIndex(index);
		}
		
		/**
		 * 获取指定位置的面板，如果不存在则立即创建
		 */
		public function getElementAt(index:int):ITabPanel
		{
			if(!indexToRenderer[index])
			{
				var data:Object = dataProvider.getItemAt(index);
				var renderer:ITabPanel = createOneRenderer(data);
				indexToRenderer[index] =  renderer;
				updateRenderer(renderer , index , data);
			}
			return indexToRenderer[index];
		}
		
		private var _panelRenderer:Class;
		/**
		 * 用于创建Panel的呈示器。该类必须实现 ITabPanel 接口。
		 */
		public function get panelRenderer():Class
		{
			return _panelRenderer;
		}
		
		public function set panelRenderer(value:Class):void
		{
			_panelRenderer = value;
		}
		
		private var _panelRendererFunction:Function;
		/**
		 * 创建ITabPanel的函数， 示例 panelRendererFunction(data:Object):Class
		 */
		public function get panelRendererFunction():Function
		{
			return _panelRendererFunction;
		}
		
		public function set panelRendererFunction(value:Function):void
		{
			_panelRendererFunction = value;
		}
		
		private var _labelField:String = "label";
		/**
		 * 显示标题的字段
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		
		public function set labelField(value:String):void
		{
			_labelField = value;
			if(titleTabBar)
				titleTabBar.labelField = labelField;
		}
		
		/**
		 * 元素的数量
		 */
		public function get numElements():int
		{
			if(!_dataProvider)
				return 0;
			return _dataProvider.length;
		}
		
		/**
		 * 设置选中项索引
		 */
		ns_egret function setSelectedIndex(value:int):void
		{
			if (value == selectedIndex)
				return;
			
			proposedSelectedIndex = value;
			if(titleTabBar)
				titleTabBar.setSelectedIndex(value , false);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (dataProviderChanged)
			{
				var oldSelectedIndex:int = selectedIndex;
				removeAllRenderers();
				dataProviderChanged = false;
				if(_dataProvider)
					_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE,onCollectionChange);
				titleTabBar.dataProvider = _dataProvider;
				this.selectedIndex = oldSelectedIndex;
			}
		}
		
		/**
		 * 提交选中项  , 是否派发值提交事件
		 */
		protected function commitSelection(newIndex:int , dispatch:Boolean = true):void
		{
			if(newIndex>=0&&newIndex<numElements &&
				proposedSelectedIndex != newIndex && proposedSelectedIndex != NO_PROPOSED_SELECTION)
			{
				// 这里这样写就是为了防止titleTabBar的adjustSelection与想要的不同步的情况
				titleTabBar.setSelectedIndex(proposedSelectedIndex);
				titleTabBar.validateProperties();
				return;
			}
			proposedSelectedIndex = NO_PROPOSED_SELECTION;
			if(selectedPanel)
				selectedPanel.show = false;
			if(newIndex>=0&&newIndex<numElements)
			{
				_selectedIndex = newIndex;
				if(!indexToRenderer[newIndex])
				{
					var data:Object = dataProvider.getItemAt(newIndex);
					var renderer:ITabPanel = createOneRenderer(data);
					indexToRenderer[newIndex] = renderer;
					updateRenderer(renderer , newIndex , data);
				}
				selectedPanel.show = true;
				viewStack.selectedChild = selectedPanel;
			}
			else
			{
				_selectedIndex = -1;
				viewStack.setSelectedIndex(-1 , false);
			}
			if(dispatch)
				dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
			setFocus();
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * 为特定的数据项返回项呈示器类定义
		 */		
		private function itemToRendererClass(item:Object):Class
		{
			var rendererClass:Class;
			if(_panelRendererFunction!=null)
			{
				rendererClass = _panelRendererFunction(item);
				if(!rendererClass)
					rendererClass = _panelRenderer;
			}
			else
			{
				rendererClass = _panelRenderer;
			}
			return rendererClass?rendererClass:TabPanel;
		}
		
		/**
		 * 根据数据创建一个Renderer,并添加到显示列表
		 */
		private function createOneRenderer(item:Object):ITabPanel
		{
			for (var renderer:* in rendererToItemMap) 
			{
				if(rendererToItemMap[renderer] == item)
				{
					viewStack.addElement(renderer);
					return renderer;
				}
			}
			var clazz:Class = itemToRendererClass(item);
			return createOneRenderer2(clazz);
		}
		
		/**
		 * 根据rendererClass创建一个Renderer,并添加到显示列表
		 */		
		private function createOneRenderer2(rendererClass:Class):ITabPanel
		{
			var renderer:ITabPanel;
			if(recyclerDic[rendererClass])
			{
				var hasExtra:Boolean = false;
				for(var key:* in recyclerDic[rendererClass])
				{
					if(!renderer)
					{
						renderer = key as ITabPanel;
					}
					else
					{
						hasExtra = true;
						break;
					}
				}
				delete recyclerDic[rendererClass][renderer];
				if(!hasExtra)
					delete recyclerDic[rendererClass];
				
				if(renderer && (rendererToItemMap[renderer] || renderer.parent))
					renderer = null;
			}
			if(!renderer)
			{
				if(Factory.hasMapRule(rendererClass))
					renderer = Factory.getInstance(rendererClass);
				else
					renderer = new rendererClass() as ITabPanel;
				rendererToClassMap[renderer] = rendererClass;
			}
			if(!renderer||!(renderer is DisplayObject))
				return null;
			viewStack.addElement(renderer);
			return renderer;
		}
		
		/**
		 * 更新项呈示器
		 */		
		protected function updateRenderer(renderer:ITabPanel, itemIndex:int, data:Object):ITabPanel
		{
			renderer.ownerChanged(this);
			renderer.itemIndex = itemIndex;
			renderer.data = data;
			renderer.show = selectedIndex == itemIndex;
			return renderer;
		}
		
		override public function setFocus():void
		{
			if(selectedPanel && selectedPanel is IUIComponent)
				IUIComponent(selectedPanel).setFocus();
			else
				super.setFocus();
		}
		
		private var dataProviderChanged:Boolean;
		private var _dataProvider:ArrayCollection;
		/**
		 * 数据源
		 */
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:ArrayCollection):void
		{
			if(value == _dataProvider)
				return;
			removeDataProviderListener();
			_dataProvider = value;
			dataProviderChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * 移除数据源监听
		 */		
		private function removeDataProviderListener():void
		{
			if(_dataProvider)
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,onCollectionChange);
		}
		
		/**
		 * 数据源改变事件处理
		 */		
		private function onCollectionChange(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD:
					itemAddedHandler(event.items,event.location);
					break;
				case CollectionEventKind.MOVE:
					itemMovedHandler(event.items[0],event.location,event.oldLocation);
					break;
				case CollectionEventKind.REMOVE:
					itemRemovedHandler(event.items,event.location);
					break;
				case CollectionEventKind.UPDATE:
					itemUpdatedHandler(event.items[0],event.location);
					break;
				case CollectionEventKind.REPLACE:
					itemRemoved(event.oldItems[0],event.location);
					itemAdded(event.items[0], event.location);
					break;
				case CollectionEventKind.RESET:
				case CollectionEventKind.REFRESH:
					removeDataProviderListener();
					dataProviderChanged = true;
					invalidateProperties();
					break;
			}
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * 数据源更新或替换项目事件处理
		 */	
		private function itemUpdatedHandler(item:Object,location:int):void
		{
			var renderer:ITabPanel = indexToRenderer[location];
			if(renderer)
				updateRenderer(renderer,location,item);
		}
		
		/**
		 * 数据源添加项目事件处理
		 */
		private function itemAddedHandler(items:Array,index:int):void
		{
			var length:int = items.length;
			for (var i:int = 0; i < length; i++)
			{
				itemAdded(items[i], index + i);
			}
			resetRenderersIndices();
		}
		
		/**
		 * 数据源移动项目事件处理
		 */		
		private function itemMovedHandler(item:Object,location:int,oldLocation:int):void
		{
			itemRemoved(item,oldLocation);
			itemAdded(item,location);
			resetRenderersIndices();
		}
		/**
		 * 数据源移除项目事件处理
		 */		
		private function itemRemovedHandler(items:Array,location:int):void
		{
			var length:int = items.length;
			for (var i:int = length-1; i >= 0; i--)
			{
				itemRemoved(items[i], location + i);
			}
			resetRenderersIndices();
		}
		
		/**
		 * 添加一项
		 */		
		protected function itemAdded(item:Object,index:int):void
		{
			var renderer:ITabPanel = createOneRenderer(item);
			if(index > indexToRenderer.length)
				indexToRenderer.length = index;
			indexToRenderer.splice(index,0,renderer);
			if(!renderer)
				return;
			updateRenderer(renderer,index,item);
		}
		
		/**
		 * 移除一项
		 */
		protected function itemRemoved(item:Object, index:int):void
		{
			const oldRenderer:ITabPanel = indexToRenderer[index];
			
			if (indexToRenderer.length > index)
				indexToRenderer.splice(index, 1);
			
			if(oldRenderer&&oldRenderer is DisplayObject)
			{
				recycle(oldRenderer);
			}
		}
		
		/**
		 * 对象池字典
		 */		
		private var recyclerDic:Dictionary = new Dictionary();
		private var rendererToClassMap:Dictionary = new Dictionary(true);
		
		/**
		 * 回收一个ItemRenderer实例
		 */		
		private function recycle(renderer:ITabPanel):void
		{
			if(renderer.parent)
				viewStack.removeElement(renderer);
			renderer.ownerChanged(null);
			renderer.show = false;
			if(rendererToItemMap[renderer])
			{
				delete rendererToItemMap[renderer];
				return;
			}
			var rendererClass:Class = rendererToClassMap[renderer];
			if(!recyclerDic[rendererClass])
			{
				recyclerDic[rendererClass] = new Dictionary(true);
			}
			recyclerDic[rendererClass][renderer] = null;
		}
		
		/**
		 * 更新当前所有项的索引
		 */		
		private function resetRenderersIndices():void
		{
			if (indexToRenderer.length == 0)
				return;
			const indexToRendererLength:int = indexToRenderer.length;
			for (var index:int = 0; index < indexToRendererLength; index++)
				resetRendererItemIndex(index);
		}
		
		/**
		 * 调整指定项呈示器的索引值
		 */		
		private function resetRendererItemIndex(index:int):void
		{
			var renderer:ITabPanel = indexToRenderer[index] as ITabPanel;
			if (renderer)
				renderer.itemIndex = index;    
		}
		
		/**
		 * 移除所有项呈示器
		 */		
		private function removeAllRenderers():void
		{
			var length:int = indexToRenderer.length;
			var renderer:ITabPanel;
			for(var i:int=0;i<length;i++)
			{
				renderer = indexToRenderer[i];
				if(renderer)
				{
					recycle(renderer);
				}
			}
			indexToRenderer = [];
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==titleTabBar)
			{
				titleTabBar.labelField = labelField;
				titleTabBar.focusEnabled = false;
				titleTabBar.dataProvider = _dataProvider;
				titleTabBar.selectedIndex = selectedIndex;
				titleTabBar.addEventListener(UIEvent.VALUE_COMMIT , onTabBarValueCommit);
				titleTabBar.addEventListener(IndexChangeEvent.CHANGE,onTabBarIndexChanged);
				titleTabBar.addEventListener(IndexChangeEvent.CHANGING,onTabBarIndexChanging);
				titleTabBar.doubleClickEnabled = true;
				titleTabBar.addEventListener(MouseEvent.DOUBLE_CLICK,onTitleDoubClick);
			}
			else if(instance==viewStack)
			{
				viewStack.layout = new ScrollBasicLayout();
			}
			else if(instance==moveArea)
			{
				moveArea.doubleClickEnabled = true;
				moveArea.addEventListener(MouseEvent.DOUBLE_CLICK,onTitleDoubClick);
			}
			else if(instance==menuButton)
			{
				menuButton.addEventListener(MouseEvent.MOUSE_DOWN,onMenuMouseDown);
			}
		}
		
		/**
		 * 双击标题
		 */
		private function onTitleDoubClick(event:MouseEvent):void
		{
			dispatchEvent(new TabGroupEvent(TabGroupEvent.MAXIMIZED,true));
		}
		
		protected function onTabBarValueCommit(event:Event):void
		{
			if(hasCommit)
			{
				hasCommit = false;
				return;
			}
			commitSelection(titleTabBar.selectedIndex);
		}
		
		/**
		 * 改变时马上提交选中的标志
		 */
		private var hasCommit:Boolean;
		/**
		 * 鼠标点击选中项改变
		 */
		protected function onTabBarIndexChanged(event:IndexChangeEvent):void
		{
			hasCommit = true;
			commitSelection(event.newIndex);
			dispatchEvent(event);
		}
		
		/**
		 * 鼠标点击选中项即将改变
		 */
		protected function onTabBarIndexChanging(event:IndexChangeEvent):void
		{
			if(!dispatchEvent(event))
				event.preventDefault();
		}
		
		/**
		 * 菜单
		 */
		private var tabMenu:NativeMenu;
		protected function onMenuMouseDown(event:MouseEvent):void
		{
			if(!tabMenu)
			{
				tabMenu = createMenu([
					Translator.getText("TabGroup.Close"),
					Translator.getText("TabGroup.Minimum"),
					Translator.getText("TabGroup.CloseTab")]);
			}
			tabMenu.getItemAt(0).enabled = Boolean(numElements>0);
			var pos:Point = menuButton.localToGlobal(new Point(menuButton.width,menuButton.height*0.5));
			tabMenu.display(stage,pos.x,pos.y);
		}
		
		private function createMenu(labelList:Array):NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			var index:int = 0;
			for each(var label:String in labelList)
			{
				item = new NativeMenuItem(label,!label);
				if(label)
					item.addEventListener(Event.SELECT,onMenuSelect);
				menu.addItem(item);
				index++;
			}
			return menu;
		}
		
		/**
		 * 菜单被点击
		 */		
		private function onMenuSelect(event:Event):void
		{
			switch(event.target.label)
			{
				case Translator.getText("TabGroup.Close"):
					onClosePanel(selectedIndex);
					break;
				case Translator.getText("TabGroup.Minimum"):
					dispatchEvent(new TabGroupEvent(TabGroupEvent.MINIMIZED,true));
					break;
				case Translator.getText("TabGroup.CloseTab"):
					dispatchEvent(new TabGroupEvent(TabGroupEvent.CLOSE,true));
					break;
			}
		}
		
		/**
		 * 用户操作关闭index处的面板
		 */
		protected function onClosePanel(index:int,direct:Boolean = false):void
		{
			if(index>-1)
			{
				var closeEvent:TabGroupEvent;
				var doClose:Boolean = true;
				if(!direct)
				{
					var closingEvent:TabGroupEvent = new TabGroupEvent(TabGroupEvent.CLOSING_PANEL,true,true);
					closingEvent.relateObject = dataProvider.getItemAt(index);
					closingEvent.relatePanel = indexToRenderer[index];
					doClose = dispatchEvent(closingEvent);
				}
				if(doClose)
				{
					closeEvent = new TabGroupEvent(TabGroupEvent.CLOSE_PANEL,true);
					closeEvent.relateObject = dataProvider.getItemAt(index);
					closeEvent.relatePanel = indexToRenderer[index];
					dataProvider.removeItemAt(index);
					dispatchEvent(closeEvent);
					if(numElements==0)
						dispatchEvent(new TabGroupEvent(TabGroupEvent.CLOSE,true));
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth , unscaledHeight);
			callLater(updateTitleGroup)
		}
		
		private var cachePanel:TabPanel;
		protected function updateTitleGroup():void
		{
			if(!titleGroup)
				return;
			if(cachePanel && cachePanel != selectedPanel)
			{
				var temp:TabPanel = new TabPanel();
				pushTitleGroupToTabPanel(cachePanel);
				if(temp.owner && temp.owner != this)
					temp.owner.validateDisplayList();
			}
			if(selectedPanel)
			{
				var panelTitleGroup:Group = (selectedPanel as TabPanel).titleGroup;
				var gapLine:Rect = (selectedPanel as TabPanel).gapLine;
				
				if(panelTitleGroup && panelTitleGroup.width>0)
				{
					if(gapLine)
						gapLine.visible = gapLine.includeInLayout = true;
					if(titleTabBar.width+panelTitleGroup.width+menuButton.width+10<width)
					{
						pushTitleGroupToTabGroup(selectedPanel as TabPanel);
					}
				}
				else if(titleGroup.width > 0)
				{
					if(gapLine)
						gapLine.visible = gapLine.includeInLayout = false;
					if(titleTabBar.width+titleGroup.width+menuButton.width+10>width)
					{
						pushTitleGroupToTabPanel(selectedPanel as TabPanel);
					}
				}
			}
		}
		
		/**
		 * 将标题栏工具组的内容放到TabGroup里 
		 */		
		private function pushTitleGroupToTabGroup(panel:TabPanel):void
		{
			if(panel && titleGroup && panel.titleGroup)
			{
				while(panel.titleGroup.numElements>0)
				{
					this.titleGroup.addElement(panel.titleGroup.getElementAt(0));
				}
				if(panel.gapLine)
					panel.gapLine.visible = panel.gapLine.includeInLayout = false;
			}
			cachePanel = panel;
			validateNow();
		}
		/**
		 * 将标题栏工具组的内容放回到TabPanel里 
		 */
		private function pushTitleGroupToTabPanel(panel:TabPanel):void
		{
			if(panel && titleGroup && panel.titleGroup)
			{
				while(titleGroup.numElements>0)
				{
					panel.titleGroup.addElement(titleGroup.getElementAt(0));
				}
				if(panel.gapLine)
					panel.gapLine.visible = panel.gapLine.includeInLayout = true;
			}
			cachePanel = null;
			validateNow();
		}
		
	}
}