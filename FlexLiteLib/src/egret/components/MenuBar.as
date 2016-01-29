package egret.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import egret.collections.ICollection;
	import egret.components.menuClasses.DefaultMenuDataDescriptor;
	import egret.components.menuClasses.IMenuBarItemRenderer;
	import egret.events.CollectionEvent;
	import egret.events.MenuEvent;
	
	/** 
	 * 菜单栏
	 * @author 雷羽佳
	 */ 
	public class MenuBar extends SkinnableContainer
	{
		/**
		 * MenuEvent.CHANGE 事件类型常量指示由于用户交互，所选内容已更改。  
		 */		
		[Event(name="menuChange", type="egret.events.MenuEvent")]
		 /**
		  * MenuEvent.ITEM_CLICK 事件类型常量指示用户已选择菜单项。
		  */		 
		[Event(name="itemClick", type="egret.events.MenuEvent")]
		/**
		 * MenuEvent.MENU_HIDE 事件类型常量指示菜单或子菜单已关闭。 
		 */		
		[Event(name="menuHide", type="egret.events.MenuEvent")]
		/**
		 *  MenuEvent.ITEM_ROLL_OUT 类型常量指示鼠标指针滑离菜单项。  
		 */		
		[Event(name="itemRollOut", type="egret.events.MenuEvent")]
		/**
		 * MenuEvent.ITEM_ROLL_OVER 类型常量指示鼠标指针悬停在菜单项上。 
		 */		
		[Event(name="itemRollOver", type="egret.events.MenuEvent")]
		
		/**
		 * 包含 MenuBarItem 对象的 Array; 
		 */		
		public var menuBarItems:Array = [];
		
		private var menuInstance:Menu;
		/**
		 * 构造函数 
		 */		
		public function MenuBar()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
		}
		
	
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			var isItem:Boolean = false;
			for(var i:int = 0;i<menuBarItems.length;i++)
			{
				if(menuBarItems[i] == event.target)
				{
					isItem = true;
					setTimeout(function(item:IMenuBarItemRenderer,index:int):void{
						if(item.menuDown == true)
						{
							popMenu(index);
						}
					},1,menuBarItems[i],i);
					break;
				}
			}
			if(isItem == true)
			{
				for(i = 0;i<menuBarItems.length;i++)
				{
					DisplayObject(menuBarItems[i]).addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
					IMenuBarItemRenderer(menuBarItems[i]).menuDown = true;
				}
			}else 
			{
				if(menuInstance == null)
				{
					for(i = 0;i<menuBarItems.length;i++)
					{
						DisplayObject(menuBarItems[i]).removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
						IMenuBarItemRenderer(menuBarItems[i]).menuDown = false;
					}
				}
			}
		}
		protected function hideHandler(event:MenuEvent):void
		{
			for(var i:int = 0;i<menuBarItems.length;i++)
			{
				DisplayObject(menuBarItems[i]).removeEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
				IMenuBarItemRenderer(menuBarItems[i]).menuDown = false;
			}
		}
		
		
		protected function rollOverHandler(event:Event):void
		{
			if(IMenuBarItemRenderer(event.target))
			{
				for(var i:int = 0;i<menuBarItems.length;i++)
				{
					IMenuBarItemRenderer(menuBarItems[i]).itemUp();
				}
				IMenuBarItemRenderer(event.target).itemDown();
				var index:int = menuBarItems.indexOf(IMenuBarItemRenderer(event.target));
				popMenu(index);
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			if (menuBarItems)
			{
				var n:int = menuBarItems.length;
				for (var i:int = 0; i < n; i++)
				{
					menuBarItems[i].enabled = value;
				}
			}
		}
		
		private var _dataProvider:ICollection
		private var dataProviderChanged:Boolean = false;
		/**
		 * 设置数据源 
		 */		
		public function get dataProvider():ICollection
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:ICollection):void
		{
			if (_dataProvider)
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, 
					dataProvider_collectionChangeHandler);
			
			dataProviderChanged = true;
			
			if (value)
				value.addEventListener(CollectionEvent.COLLECTION_CHANGE, 
					dataProvider_collectionChangeHandler, false, 0, true);
			
			_dataProvider = value;
			invalidateProperties();
		}
		
		private function dataProvider_collectionChangeHandler():void
		{
			dataProviderChanged = true;
			invalidateProperties();
		}
		
		
		public var menuBarItemRenderer:Class;
		public var menu:Class;
		override protected function commitProperties():void
		{
			super.commitProperties()
			if(dataProviderChanged == true)
			{
				while(menuBarItems.length>0)
				{
					menuBarItems.pop();
				}
				contentGroup.removeAllElements();
				for(var i:int = 0;i<dataProvider.length;i++)
				{
					var label:String = itemToLabel(dataProvider.getItemAt(i));
					if(label != "" && label != null)
					{
						var menuItem:IMenuBarItemRenderer = new menuBarItemRenderer();
						menuItem.data = dataProvider.getItemAt(i);
						menuItem.label = label;
						menuItem.icon = itemToIcon(dataProvider.getItemAt(i));
						contentGroup.addElement(menuItem);
						menuBarItems.push(menuItem);
					}
				}
				dataProviderChanged = false;
			}
		}
		
		
		
		/**
		 * 项转换成标签
		 */
		public function itemToLabel(item:Object):String
		{
			if (item is String)
				return String(item);
			
			if (item is XML)
			{
				return item.@label;
			}
			else if (item is Object)
			{
				return item.label;
			}
			return " ";
		}
		
		/**
		 * 项转换成图标
		 */
		public function itemToIcon(item:Object):Object
		{
			if (item is String)
				return String(item);
			
			if (item is XML)
			{
				return String(item.@icon);
			}
			else if (item is Object)
			{
				return item.icon;
			}
			return null;
		}
		
		private var defaultMenuDataDescriptor:DefaultMenuDataDescriptor = new DefaultMenuDataDescriptor();
		private function popMenu(menuBarItemIndex:int):void
		{
			var itemderer:IMenuBarItemRenderer = menuBarItems[menuBarItemIndex];
			var tmpDpSource:Object = dataProvider.getItemAt(menuBarItemIndex);
			var tmpDp:ICollection = defaultMenuDataDescriptor.getChildren(tmpDpSource);
			if(menuInstance == null)
			{
				menuInstance = new menu();
				Menu.popUpMenu(menuInstance , this , tmpDp);
				menuInstance.addEventListener(MenuEvent.MENU_CHANGE,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_ROLL_OUT,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_ROLL_OVER,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_CLICK,menuEventListener);
				menuInstance.addEventListener(MenuEvent.MENU_HIDE,menuEventListener);
				menuInstance.addEventListener(MenuEvent.MENU_SHOW,menuEventListener);
				menuInstance.labelField = "@label";
				menuInstance.iconField = "@icon";
			}
			menuInstance.dataProvider = tmpDp;
			
			setTimeout(function():void{
				menuInstance.removeEventListener(MenuEvent.MENU_HIDE,hideHandler);
				menuInstance.hide();
				menuInstance.addEventListener(MenuEvent.MENU_HIDE,hideHandler);
				menuInstance.show(itemderer.x,itemderer.y+itemderer.height);
			},1);
		}
		
		
		
		private function menuEventListener(e:MenuEvent):void
		{
			this.dispatchEvent(e);
		}
	}
}