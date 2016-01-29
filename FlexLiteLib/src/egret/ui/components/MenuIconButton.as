package egret.ui.components
{
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import egret.collections.ArrayCollection;
	import egret.collections.ICollection;
	import egret.components.Button;
	import egret.components.Menu;
	import egret.events.MenuEvent;
	
	/**
	 * 有下拉菜单的图标按钮
	 * @author 雷羽佳
	 * 
	 */	
	public class MenuIconButton extends Button
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
		 * MenuEvent.MENU_SHOW 类型常量指示鼠标指针已滑离打开的菜单或子菜单。 
		 */		
		[Event(name="menuShow", type="egret.events.MenuEvent")]
		
		
		public function MenuIconButton()
		{
			super();
			this.mouseChildren = true;
			this.mouseEnabled = true;
		}
		
		private var _dataProvider:ICollection = new ArrayCollection();
		public function get dataProvider():ICollection
		{
			return _dataProvider;
		}

		public function set dataProvider(value:ICollection):void
		{
			_dataProvider = value;
		}

		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		private var _icon:Object
		public function get icon():Object
		{
			return _icon;
		}
		
		public function set icon(value:Object):void
		{
			_icon = value;
			if(iconButton != null)
			{
				iconButton.icon = _icon;
			}
		}
		
		
		
		private var menuInstance:Menu;
		public var iconButton:IconButton;
		public var menuButton:IconButton;
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance == iconButton)
			{
				if(_icon)
				{
					iconButton.icon = _icon;
				}
			}
			if(instance == menuButton)
			{
				menuButton.addEventListener(MouseEvent.MOUSE_DOWN,menuMouseDownHandler);
			}
		}
		
		
	
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if(instance == menuButton)
			{
				menuButton.removeEventListener(MouseEvent.MOUSE_DOWN,menuMouseDownHandler);
			}
		}
		
		protected function menuMouseDownHandler(event:MouseEvent):void
		{
			if(menuInstance == null)
			{
				menuInstance = new Menu();
				Menu.popUpMenu(menuInstance , this , _dataProvider);
				menuInstance.addEventListener(MenuEvent.MENU_CHANGE,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_ROLL_OUT,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_ROLL_OVER,menuEventListener);
				menuInstance.addEventListener(MenuEvent.ITEM_CLICK,menuEventListener);
				menuInstance.addEventListener(MenuEvent.MENU_HIDE,menuEventListener);
				menuInstance.addEventListener(MenuEvent.MENU_SHOW,menuEventListener);
				menuInstance.labelField = "@label";
				menuInstance.iconField = "@icon";
			}
			opening();
			menuInstance.dataProvider = _dataProvider;
			setTimeout(function():void{
				menuInstance.hide();
				menuInstance.show(iconButton.x,iconButton.y+iconButton.height);
			},1);
		}
		
		protected function menuEventListener(event:MenuEvent):void
		{
			this.dispatchEvent(event);
		}
		
		protected function opening():void
		{
			
		}
	}
}