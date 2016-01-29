package egret.text.events
{
	import flash.events.Event;
	/**
	 * 文本选中范围改变事件
	 * @author dom
	 */	
	public class SelectionEvent extends Event
	{
		/**
		 * 文本选中范围改变事件
		 */		
		public static const SELECTION_CHANGE:String = "selectionChange";
		
		/**
		 * 构造函数
		 */		
		public function SelectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,
									   anchorPosition:int=-1,activePosition:int=-1)
		{
			super(type, bubbles, cancelable);
			this._activePosition = activePosition;
			this._anchorPosition = anchorPosition;
		}
		
		private var _anchorPosition:int;
		/**
		 * 相对于 text 字符串开头的字符位置，用于指定用箭头键扩展选区时该选区的终点。活动位置可以是选区的起点或终点。
		 * 例如，如果拖动选择位置 12 到位置 8 之间的区域，则 selectionAnchorPosition 将为 12，
		 * selectionActivePosition 将为 8，按向左箭头后 selectionActivePosition 将变为 7。
		 * 值为 -1 时，表示“未设置”。
		 */									
		public function get anchorPosition():int
		{ 
			return _anchorPosition; 
		}
		
		private var _activePosition:int;
		/**
		 * 相对于 text 字符串开头的字符位置，用于指定用箭头键扩展选区时该选区的终点。活动位置可以是选区的起点或终点。
		 * 例如，如果拖动选择位置 12 到位置 8 之间的区域，则 selectionAnchorPosition 将为 12，
		 * selectionActivePosition 将为 8，按向左箭头后 selectionActivePosition 将变为 7。
		 * 值为 -1 时，表示“未设置”。
		 */										
		public function get activePosition():int
		{ 
			return _activePosition; 
		}
		
		override public function clone():Event
		{
			return new SelectionEvent(type, bubbles, cancelable, _anchorPosition,_activePosition);
		}
		
	}
}