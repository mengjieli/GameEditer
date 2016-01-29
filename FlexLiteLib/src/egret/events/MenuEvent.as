package egret.events
{
	import flash.events.Event;
	
	import egret.components.Menu;
	import egret.components.menuClasses.IMenuItemRenderer;
	
	/** 
	 * Menu事件
	 * @author xzper
	 */ 
	public class MenuEvent extends ListEvent
	{
		/**
		 * MenuEvent.MENU_CHANGE 事件类型常量指示由于用户交互，所选内容已更改。  
		 */		
		public static const MENU_CHANGE:String = "menuChange";
		
		/**
		 * MenuEvent.MENU_HIDE 事件类型常量指示菜单或子菜单已关闭。 
		 */
		public static const MENU_HIDE:String = "menuHide";
		
		/**
		 * MenuEvent.MENU_SHOW 类型常量指示鼠标指针已滑离打开的菜单或子菜单。 
		 */
		public static const MENU_SHOW:String = "menuShow";
		
		/**
		 * MenuEvent.ITEM_CLICK 事件类型常量指示用户已选择菜单项。 
		 */
		public static const ITEM_CLICK:String = "itemClick";
		
		/**
		 * MenuEvent.ITEM_ROLL_OUT 类型常量指示鼠标指针滑离菜单项。 
		 */
		public static const ITEM_ROLL_OUT:String = "itemRollOut";
		
		/**
		 * MenuEvent.ITEM_ROLL_OVER 类型常量指示鼠标指针悬停在菜单项上。 
		 */
		public static const ITEM_ROLL_OVER:String = "itemRollOver";
		
		public function MenuEvent(type:String, bubbles:Boolean = false,
								  cancelable:Boolean = true,
								  menu:Menu = null,
								  item:Object = null,
								  itemIndex:int = -1,
								  itemRenderer:IMenuItemRenderer = null)
		{
			super(type, bubbles, cancelable);
			this.menu = menu;
			this.item = item;
			this.itemRenderer = itemRenderer;
			this.itemIndex = itemIndex;
		}
		
		/**
		 * 相关联的Menu对象
		 */
		public var menu:Menu;
		
		override public function clone():Event
		{
			var cloneEvent:MenuEvent = new MenuEvent(type, bubbles, cancelable, 
				menu ,item ,itemIndex, IMenuItemRenderer(itemRenderer));
			return cloneEvent;
		}
	}
}