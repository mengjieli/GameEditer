package egret.ui.events
{
	import flash.events.Event;

	/**
	 * 树的拖拽事件 
	 * @author 雷羽佳
	 * 
	 */	
	public class TreeDragEvent extends Event
	{
		/**
		 * 拖拽进入完成了
		 */		
		public static const ITEMS_DRAG_IN_COMPLETE:String = "itemsDargInComplete";
		/**
		 * 拖拽开始
		 */		
		public static const ITEMS_DRAG_START:String = "itemsDragStart";
		/**
		 * 拖拽移动结束了 
		 */		
		public static const ITEMS_DRAG_MOVE_COMPLETE:String = "itemsDargMoveComplete"
		
		public function TreeDragEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true )
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 被拖拽的数据项列表 
		 */		
		public var dragItems:Array;
		/**
		 * 拖拽接受者的数据项 
		 */		
		public var dropItem:Object;
		/**
		 * 当为ITEMS_DRAG_MOVE_COMPLETE事件的时候，此属性判断，是拖拽到了目标项之上还是目标项之下。
		 */		
		public var moveToTop:Boolean;
	}
}