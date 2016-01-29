package egret.events
{
	import flash.events.Event;
	
	/**
	 * GridCaretEvent 类表示 DataGrid 控件中的插入标记由于用户交互而发生更改时分派的事件。 
	 * @author dom
	 * 
	 */	
	public class GridCaretEvent extends Event
	{
		/**
		 *GridSelectionEvent.CARET_CHANGE 常量为 caretChange 事件定义事件对象的 type 属性的值，指示当前尖号位置刚刚更改。  
		 */		
		public static const CARET_CHANGE:String = "caretChange";
		/**
		 * 构造函数。 
		 * @param type 事件类型；指示引发事件的动作。
		 * @param bubbles 指定该事件是否可以在显示列表层次结构得到冒泡处理。
		 * @param cancelable 指定是否可以防止与事件相关联的行为。
		 * @param oldRowIndex 更改前尖号位置的从零开始的列索引。如果 selectionMode 是 SelectionMode.SINGLE_ROW 或 SelectionMode.MULTIPLE_ROWS，则为 -1。
		 * @param oldColumnIndex 更改前尖号位置的从零开始的行索引。
		 * @param newRowIndex 更改后尖号位置的从零开始的列索引。如果 selectionMode 是 SelectionMode.SINGLE_ROW 或 SelectionMode.MULTIPLE_ROWS，则为 -1。
		 * @param newColumnIndex 更改后尖号位置的从零开始的行索引。
		 * 
		 */		
		public function GridCaretEvent(type:String, 
									   bubbles:Boolean = false,
									   cancelable:Boolean = false,
									   oldRowIndex:int = -1,
									   oldColumnIndex:int = -1,
									   newRowIndex:int = -1,
									   newColumnIndex:int = -1)
		{
			super(type, bubbles, cancelable);
			
			this.oldRowIndex = oldRowIndex;
			this.oldColumnIndex = oldColumnIndex;
			this.newRowIndex = newRowIndex;
			this.newColumnIndex = newColumnIndex;
		}
		/**
		 * 插入标记位置更改前，插入标记位置从零开始的行索引。 
		 */		
		public var oldRowIndex:int;
		/**
		 * 插入标记位置更改前，插入标记位置从零开始的列索引。 
		 * 
		 * <p>如果 selectionMode 为 SelectionMode.SINGLE_ROW 或
		 *  SelectionMode.MULTIPLE_ROWS，则为 -1 以指示它当前未使用。</p>
		 */		
		public var oldColumnIndex:int;
		/**
		 * 插入标记位置更改后，插入标记位置从零开始的行索引。 
		 */		 
		public var newRowIndex:int;
		/**
		 * 插入标记位置更改后，插入标记位置从零开始的列索引。
		 * 
		 * <p>如果 selectionMode 为 SelectionMode.SINGLE_ROW 或 
		 * SelectionMode.MULTIPLE_ROWS，则为 -1 以指示它当前未使用。</p>
		 */		
		public var newColumnIndex:int; 
		
		override public function clone():Event
		{
			return new GridCaretEvent(
				type, bubbles, cancelable, 
				oldRowIndex, oldColumnIndex, 
				newRowIndex, newColumnIndex);
		}
	}
	
}
