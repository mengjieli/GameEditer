package egret.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.collections.ICollection;
	import egret.components.menuClasses.DefaultMenuDataDescriptor;
	import egret.components.menuClasses.IMenuDataDescriptor;
	import egret.components.menuClasses.IMenuItemRenderer;
	import egret.components.menuClasses.MenuItemRenderer;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	import egret.events.MenuEvent;
	import egret.events.RendererExistenceEvent;
	import egret.managers.PopUpManager;
	import egret.utils.callLater;
	
	use namespace ns_egret;
	
	/**
	 * 指示用户执行了将鼠标指针滑过控件中某个项呈示器的操作。 
	 */	
	[Event(name="itemRollOver", type="egret.events.MenuEvent")]
	/**
	 * 指示用户执行了将鼠标指针从控件中某个项呈示器上移开的操作  
	 */	
	[Event(name="itemRollOut", type="egret.events.MenuEvent")]
	/**
	 * 指示用户执行了将鼠标在某个项呈示器上单击的操作。 
	 */	
	[Event(name="itemClick", type="egret.events.MenuEvent")]
	
	/**
	 * 指示由于用户交互，所选内容已更改。  
	 */
	[Event(name="menuChange", type="egret.events.MenuEvent")]

	/**
	 * 指示菜单或子菜单已关闭。 
	 */
	[Event(name="menuHide", type="egret.events.MenuEvent")]

	/**
	 * 指示鼠标指针已滑离打开的菜单或子菜单。 
	 */
	[Event(name="menuShow", type="egret.events.MenuEvent")]
	
	/** 
	 * Menu 控件创建可分别选择的选项的弹出菜单，
	 * 此弹出菜单类似于大多数软件应用程序中的“文件”或“编辑”菜单。
	 * 弹出菜单可以具有所需的任何数目的子菜单级别。
	 * 打开 Menu 控件后，此控件将一直可见，直到通过下列任一操作将其关闭： 
	 *  <ul>
	 *   <li>调用 Menu.hide() 方法。 </li>
	 *   <li>用户选择已启用的菜单项。 </li>
	 *   <li>用户在 Menu 控件外部单击。 </li>
	 *   <li>用户选择该应用程序中的其他组件。 </li>
	 *  </ul>
	 * @author xzper
	 */ 
	public class Menu extends List
	{
		public function Menu()
		{
			super();
		}
		
		/**
		 * 创建并返回 Menu 类的实例。Menu 控件的内容由此方法的 mdp 参数确定。
		 * Menu 控件放置在由此方法的 parent 参数指定的父容器中。
		 * 此方法并不显示 Menu 控件，它只是创建 Menu 控件，并允许在显示此 Menu 之前修改 Menu 实例。
		 * 要显示该 Menu，请调用 Menu.show() 方法。
		 * @param parent PopUpManager 用于放置 Menu 控件的容器。Menu 控件实际上可能并非由此对象产生。
		 * @param mdp Menu 控件的数据提供程序。
		 * @return Menu 类的一个实例。
		 */
		public static function createMenu(parent:DisplayObjectContainer, mdp:ICollection):Menu
		{
			var menu:Menu = new Menu();
			menu.tabEnabled = false;
			popUpMenu(menu, parent, mdp);
			return menu;
		}
		
		/**
		 * 设置现有 Menu 控件的 dataProvider，并将该 Menu 控件放在指定的父容器中。
		 * 此方法不显示 Menu 控件；您必须使用 Menu.show() 方法来显示 Menu 控件。
		 * Menu.createMenu() 方法使用此方法。
		 * @param menu 要弹出的 Menu 控件。
		 * @param parent PopUpManager 用于放置 Menu 控件的容器。Menu 控件实际上可能并非由此对象产生。
		 * @param mdp Menu 控件的数据提供程序。
		 */
		public static function popUpMenu(menu:Menu, parent:DisplayObjectContainer, mdp:ICollection):void
		{
			menu.parentDisplayObject = parent ? parent : DisplayObject(menu.systemManager);
			menu.dataProvider = mdp;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			if(!itemRenderer)
				itemRenderer = MenuItemRenderer;
			super.createChildren();
		}
		
		private var _dataDescriptor:IMenuDataDescriptor = new DefaultMenuDataDescriptor;
		/**
		 * 访问并处理数据提供程序中数据的对象。Menu 控件委托数据描述符来提供其数据的相关信息。
		 * 然后，这些数据用于分析和移动数据源。为根菜单定义的数据描述符可用于所有子菜单。
		 * 默认值为 DefaultMenuDataDescriptor 类的内部实例。
		 */
		public function get dataDescriptor():IMenuDataDescriptor
		{
			return IMenuDataDescriptor(_dataDescriptor);
		}
		
		public function set dataDescriptor(value:IMenuDataDescriptor):void
		{
			_dataDescriptor = value;
		}
		
		private var _parentMenu:Menu;
		/**
		 * 菜单层次结构链中的父菜单（在该层次结构链中，当前菜单是该父菜单的子菜单）。
		 */
		public function get parentMenu():Menu
		{
			return _parentMenu;
		}
		
		public function set parentMenu(value:Menu):void
		{
			_parentMenu = value;
		}
		
		/**
		 * 图标字段或函数改变标志
		 */		
		private var iconFieldOrFunctionChanged:Boolean = false;
		
		private var _iconField:String;
		/**
		 * 数据项中用来确定图标skinName属性值的字段名称。另请参考UIAsset.skinName。
		 * 若设置了iconFunction，则设置此属性无效。
		 */		
		public function get iconField():String
		{
			return _iconField;
		}
		public function set iconField(value:String):void
		{
			if(_iconField==value)
				return;
			_iconField = value;
			iconFieldOrFunctionChanged = true;
			invalidateProperties();
		}
		
		private var _iconFunction:Function;
		/**
		 * 用户提供的函数，在每个数据项目上运行以确定其图标的skinName值。另请参考UIAsset.skinName。
		 * 示例：iconFunction(item:Object):Object
		 */		
		public function get iconFunction():Function
		{
			return _iconFunction;
		}
		public function set iconFunction(value:Function):void
		{
			if(_iconFunction==value)
				return;
			_iconFunction = value;
			iconFieldOrFunctionChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateRenderer(renderer:IItemRenderer, itemIndex:int, data:Object):IItemRenderer
		{
			if(renderer is IMenuItemRenderer)
			{
				var treeRenderer:IMenuItemRenderer = renderer as IMenuItemRenderer;
				treeRenderer.hasChildren = _dataDescriptor.hasChildren(data);
				treeRenderer.type = _dataDescriptor.getType(data);
				treeRenderer.isEnabled = _dataDescriptor.isEnabled(data);
				treeRenderer.isToggled = _dataDescriptor.isToggled(data);
				treeRenderer.iconSkinName = itemToIcon(data);
			}
			return super.updateRenderer(renderer, itemIndex, data);
		}
		
		/**
		 * 根据数据项返回项呈示器中图标的skinName属性值
		 */		
		public function itemToIcon(data:Object):Object
		{
			if(!data)
				return null;
			if(_iconFunction!=null)
				return _iconFunction(data);
			var skinName:Object;
			if(data is XML)
			{
				try
				{
					if(data[iconField].length() != 0)
					{
						skinName = String(data[iconField]);
					}
				}
				catch(e:Error)
				{
				}
			}
			else if(data is Object)
			{
				try
				{
					if(data[iconField])
					{
						skinName = data[iconField];
					}
				}
				catch(e:Error)
				{
				}
			}
			return skinName;
		}
		
		/**
		 * 子菜单
		 */
		private var subMenu:Menu;
		
		/**
		 * 显示子菜单
		 */
		private function openSubMenu(menuItem:IMenuItemRenderer):void
		{
			if(!menuItem.hasChildren)
			{
				this.selectedIndex = -1;
				if(subMenu)
					subMenu.hide();
				return;
			}else
				this.selectedIndex = menuItem.itemIndex;
			var r:Menu = getRootMenu();
			
			//获取子节点数据
			var dp:ICollection = _dataDescriptor.getChildren(menuItem.data);
			
			if(!subMenu)
			{
				subMenu = new Menu();
				subMenu.skinName = this.skinName;
				subMenu.parentMenu = this;
				subMenu.labelField = r.labelField;
				subMenu.labelFunction = r.labelFunction;
				subMenu.iconField = r.iconField;
				subMenu.iconFunction = r.iconFunction;
				subMenu.itemRenderer = r.itemRenderer;
				subMenu.itemRendererSkinName = r.itemRendererSkinName;
				subMenu.scaleY = r.scaleY;
				subMenu.scaleX = r.scaleX;
			}
			else
			{
				subMenu.hide();
			}
			Menu.popUpMenu(subMenu , this , dp);
			
			var point:Point = getSubMenuPoint(menuItem);
			subMenu.show(point.x , point.y);
		}
		
		/**
		 * 是否反向显示
		 */
		private var isTurn:Boolean;
		
		/**
		 * 返回子菜单的位置
		 */
		protected function getSubMenuPoint(menuItem:IMenuItemRenderer):Point
		{
			var point:Point = new Point(
				menuItem.layoutBoundsX +menuItem.layoutBoundsWidth,
				menuItem.layoutBoundsY);
			
			if(this.localToGlobal(point).y + subMenu.layoutBoundsHeight > systemManager.stage.stageHeight)
			{
				point.y = systemManager.stage.stageHeight - subMenu.layoutBoundsHeight;
				point = this.globalToLocal(point);
				point.x = menuItem.layoutBoundsX +menuItem.layoutBoundsWidth;
			}
			if(this.localToGlobal(point).x + subMenu.layoutBoundsWidth > systemManager.stage.stageWidth || isTurn)
			{
				point.x = menuItem.layoutBoundsX - subMenu.layoutBoundsWidth;
				subMenu.isTurn = true;
			}
			return point;
		}
		
		/**
		 * 获取根菜单
		 */
		private function getRootMenu():Menu
		{
			var target:Menu = this;
			while (target.parentMenu)
				target = target.parentMenu;
			return target;
		}
		
		/**
		 * 如果 Menu 控件可见，则隐藏 Menu 控件及其所有子菜单。
		 */
		public function hide():void
		{
			var rootMenu:Menu = getRootMenu();
			if(rootMenu == null || rootMenu.systemManager == null)
			{
				return;
			}
			if (visible && rootMenu.systemManager.stage)
			{
				this.visible = false;
				if(subMenu)
					subMenu.hide();
				
				if(rootMenu == this)
				{
					rootMenu.systemManager.stage.removeEventListener(
						MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler);
				}
				var menuEvent:MenuEvent = new MenuEvent(MenuEvent.MENU_HIDE);
				menuEvent.menu = this;
				this.dispatchEvent(menuEvent);
			}
		}
		
		/**
		 * 用于放置 Menu 控件的容器。Menu 控件实际上可能并非由此对象产生。
		 */
		private var parentDisplayObject:DisplayObject;
		/**
		 * 显示 Menu 控件。如果 Menu 控件不可见，此方法会将 Menu 放置在父应用程序左上角的给定坐标处，
		 * 根据需要调整 Menu 控件大小，并使 Menu 控件可见。
		 * @param xShow Menu 控件左上角的水平位置
		 * @param yShow Menu 控件左上角的垂直位置
		 */
		public function show(xShow:Number = 0, yShow:Number = 0):void
		{
			if (!dataProvider || dataProvider.length == 0)
			{
				return;
			}
			if (parentMenu && !parentMenu.visible)
			{
				return;
			}
			if(visible && stage)
			{
				return;
			}
			if(!parentDisplayObject)
				parentDisplayObject = DisplayObject(this.systemManager);
			
			if (!parent || !parent.contains(parentDisplayObject))
			{
				PopUpManager.addPopUp(this, false , false);
				this.visible = false;
				callLater(function():void{
					visible = true;
				} , null , 1);
				addEventListener(MenuEvent.MENU_HIDE, menuHideHandler, false, -50);
			}
			
			var rootMenu:Menu = getRootMenu();
			var menuEvent:MenuEvent = new MenuEvent(MenuEvent.MENU_SHOW);
			menuEvent.menu = this;
			rootMenu.dispatchEvent(menuEvent);
			
			var sbRoot:Stage = rootMenu.systemManager.stage;
			var pt:Point = new Point(xShow, yShow);
			pt =parentDisplayObject.localToGlobal(pt);
			pt = DisplayObject(rootMenu.systemManager).globalToLocal(pt);
			
			this.x = pt.x;
			this.y = pt.y;
			
			this.selectedIndex = -1;
			setFocus();
			
			if(rootMenu == this)
				sbRoot.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOutsideHandler, false, 0, true);
		}
		
		/**
		 * 切换菜单项。菜单项类型标识符必须是复选框或单选按钮，否则此方法将无效。
		 * @param menuItem 要切换的菜单项.
		 * @param toggle 用于指示是否切换该项目的布尔值。
		 */
		protected function setMenuItemToggled(menuItem:IMenuItemRenderer, toggle:Boolean):void
		{
			if (_dataDescriptor.getType(menuItem.data) == "radio")
			{
				var groupName:String = _dataDescriptor.getGroupName(menuItem.data);
				
				var length:int = dataGroup.numElements;
				var itemRenderer:IMenuItemRenderer;
				for (var i:int = 0; i < length; i++)
				{
					itemRenderer = dataGroup.getElementAt(i) as IMenuItemRenderer;
					if (_dataDescriptor.getType(itemRenderer.data) == "radio" &&
						_dataDescriptor.getGroupName(itemRenderer.data) == groupName)
					{
						_dataDescriptor.setToggled(itemRenderer.data, (itemRenderer == menuItem));
						itemRenderer.isToggled = _dataDescriptor.isToggled(menuItem.data);
					}
				}
			}
			
			if (toggle != _dataDescriptor.isToggled(menuItem.data))
			{
				_dataDescriptor.setToggled(menuItem.data, toggle);
				menuItem.isToggled = toggle;
			}
		}
		
		/**
		 * 抛出菜单事件
		 * @param mouseEvent 相关联的鼠标事件
		 * @param type 事件名称
		 * @param itemRenderer 关联的条目渲染器实例
		 */		
		override ns_egret function dispatchListEvent(mouseEvent:MouseEvent,type:String,itemRenderer:IItemRenderer):void
		{
			var itemIndex:int = -1;
			if (itemRenderer)
				itemIndex = itemRenderer.itemIndex;
			else
				itemIndex = dataGroup.getElementIndex(mouseEvent.currentTarget as IVisualElement);
			
			var menuEvent:MenuEvent = new MenuEvent(type, false, false, 
				this ,itemRenderer.data , itemIndex , IMenuItemRenderer(itemRenderer));
			getRootMenu().dispatchEvent(menuEvent);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererAddHandler(event);
			var renderer:DisplayObject = event.renderer as DisplayObject;
			if (renderer == null)
				return;
			renderer.addEventListener(MouseEvent.ROLL_OVER, item_rollOverHandler);
			renderer.addEventListener(MouseEvent.MOUSE_UP, menuItem_mouseUpHandler , false , 1);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
		{
			super.dataGroup_rendererRemoveHandler(event);
			var renderer:DisplayObject = event.renderer as DisplayObject;
			if (renderer == null)
				return;
			renderer.removeEventListener(MouseEvent.ROLL_OVER, item_rollOverHandler);
			renderer.removeEventListener(MouseEvent.MOUSE_UP, menuItem_mouseUpHandler);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			var renderer:IMenuItemRenderer = event.currentTarget as IMenuItemRenderer;
			if(renderer.hasChildren || !renderer.isEnabled)
				return;
			super.item_mouseDownHandler(event);
		}
		
		/**
		 * 鼠标在项呈示器上弹起
		 */
		private function menuItem_mouseUpHandler(event:MouseEvent):void
		{
			var renderer:IMenuItemRenderer = event.currentTarget as IMenuItemRenderer;
			if(renderer.hasChildren || !renderer.isEnabled)
				return;
			
			var type:String = _dataDescriptor.getType(renderer.data);
			if(type)
			{
				var toggleItem:Boolean = _dataDescriptor.getType(renderer.data) != "radio" 
					|| !_dataDescriptor.isToggled(renderer.data);
				
				if (toggleItem)
				{
					setMenuItemToggled(renderer, !_dataDescriptor.isToggled(renderer.data));
					this.dispatchListEvent(event , MenuEvent.MENU_CHANGE , renderer);
				}
			}
			callLater(hideAllMenus);
		}
		
		/**
		 * 鼠标移动到项呈示器
		 */
		private function item_rollOverHandler(event:MouseEvent):void
		{
			var menuItem:IMenuItemRenderer = event.currentTarget as IMenuItemRenderer;
			openSubMenu(menuItem);
		}
		
		protected function menuHideHandler(event:MenuEvent):void
		{
			var menu:Menu = Menu(event.target);
			if (!event.isDefaultPrevented() && menu == event.menu)
			{
				PopUpManager.removePopUp(event.menu);
				menu.removeEventListener(MenuEvent.MENU_HIDE, menuHideHandler);
			}
		}
		
		protected function mouseDownOutsideHandler(event:MouseEvent):void
		{
			if (!isMouseOverMenu(event))
				hideAllMenus();
		}
		
		private function isMouseOverMenu(event:MouseEvent):Boolean
		{
			var target:DisplayObject = DisplayObject(event.target);
			while (target)
			{
				if (target is Menu)
					return true;
				target = target.parent;
			}
			return false;
		}
		
		private function hideAllMenus():void
		{
			getRootMenu().hide();
		}
	}
}