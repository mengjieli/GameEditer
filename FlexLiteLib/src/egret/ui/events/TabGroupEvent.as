package egret.ui.events
{
	import flash.events.Event;
	
	import egret.ui.components.ITabPanel;
	
	
	/**
	 * 选项卡组事件
	 * @author dom
	 */
	public class TabGroupEvent extends Event
	{
		/**
		 * 最大化选项卡组
		 */		
		public static const MAXIMIZED:String = "maximizedTabGroup";
		/**
		 * 最小化选项卡组
		 */		
		public static const MINIMIZED:String = "minimizedTabGroup";
		/**
		 * 关闭选项卡组
		 */
		public static const CLOSE:String = "closeTabGroup";
		/**
		 * 即将关闭选项卡事件，仅当用户与此控件交互时才抛出此事件。 
		 */
		public static const CLOSING_PANEL:String = "closingPanel";
		/**
		 * 添加了一个面板
		 */		
		public static const PANEL_OPENED:String = "panelOpened";
		/**
		 * 关闭选项卡事件，仅当用户与此控件交互时才抛出此事件。 
		 */
		public static const CLOSE_PANEL:String = "closePanel";
		
		public function TabGroupEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var event:TabGroupEvent = new TabGroupEvent(type , bubbles ,cancelable);
			event.relateObject = relateObject;
			event.relatePanel = relatePanel;
			return event;
		}
		
		/**
		 * 事件关联的数据
		 */
		public var relateObject:Object;
		
		/**
		 * 事件关联的面板 , 有可能为空
		 */
		public var relatePanel:ITabPanel;
	}
}