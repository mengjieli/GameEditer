package egret.events
{
	import flash.events.Event;
	
	import egret.components.gridClasses.GridColumn;

	
	/**
	 * GridItemEditorEvent 类表示在项编辑器的生命周期内分派的事件。 
	 * 
	 * <p>生命周期从 GRID_ITEM_EDITOR_SESSION_STARTING 事件的分派时开始。
	 * 您可以通过在事件侦听器中调用 preventDefault() 方法取消事件，来停止编辑会话。</p>
	 * 
	 * <p>项编辑器打开之后，会分派 GRID_ITEM_EDITOR_SESSION_START 来通知侦听器已打开编辑器。</p>
	 * 
	 * <p>可以保存或取消编辑会话。如果已保存此会话，则会分派 GRID_ITEM_EDITOR_SESSION_SAVE 事件。
	 * 如果已取消编辑器，则会分派 GRID_ITEM_EDITOR_SESSION_CANCEL 事件。 </p>
	 * @author dom
	 * 
	 */	
	public class GridItemEditorEvent extends Event
	{
		/**
		 * GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING 常量为 startGridItemEditorSession 
		 * 事件定义事件对象的 type 属性的值。在请求新的项编辑器会话时分派。侦听器可以动态确定单元格是否
		 * 可编辑，如果单元格不可编辑，则通过调用 preventDefault() 方法取消编辑。侦听器也可以动态更改所
		 * 使用的编辑器，方法是将其它项编辑器指定给网格列。 
		 * 
		 * <p>如果取消该事件，则不会创建项编辑器。</p>
		 */		
		public static const GRID_ITEM_EDITOR_SESSION_STARTING:String = "gridItemEditorSessionStarting";
		/**
		 * GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START 常量为 openGridItemEditor 事件定义事
		 * 件对象的 type 属性的值。在项编辑器打开之后立即分派。  
		 */		
		public static const GRID_ITEM_EDITOR_SESSION_START:String = "gridItemEditorSessionStart";
		/**
		 * GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE 常量为 saveGridItemEditor 事件定义事件
		 * 对象的 type 属性的值。在项编辑器中的数据已保存到数据提供程序中，并且编辑器已经关闭之后分派。  
		 */	
		public static const GRID_ITEM_EDITOR_SESSION_SAVE:String = "gridItemEditorSessionSave";
		/**
		 * GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL 常量为 cancelridItemEditor 事件定义
		 * 事件对象的 type 属性的值。在不保存数据的情况下关闭项编辑器之后分派。 
		 */
		public static const GRID_ITEM_EDITOR_SESSION_CANCEL:String = "gridItemEditorSessionCancel";
		/**
		 * 构造函数。 
		 * @param type 事件类型；指示引发事件的动作。
		 * @param bubbles 指定该事件是否可以在显示列表层次结构得到冒泡处理。
		 * @param cancelable 指定是否可以防止与事件相关联的行为。
		 * @param rowIndex 正在编辑的从零开始的列索引。
		 * @param columnIndex 正在编辑的从零开始的列索引。
		 * @param column 正在编辑的列。
		 * 
		 */		
		public function GridItemEditorEvent(type:String, 
											bubbles:Boolean = false, 
											cancelable:Boolean = false,
											rowIndex:int = -1,
											columnIndex:int = -1, 
											column:GridColumn = null)
		{
			super(type, bubbles, cancelable);
			
			this.rowIndex = rowIndex;
			this.columnIndex = columnIndex;
			this.column = column;
		}
		/**
		 * 正在编辑的从零开始的列索引。 
		 */		
		public var columnIndex:int;
		/**
		 * 正在编辑的单元格列。 
		 */		
		public var column:GridColumn;
		/**
		 * 正在编辑的行索引。 
		 */		
		public var rowIndex:int;
		override public function clone():Event
		{
			var cloneEvent:GridItemEditorEvent = new GridItemEditorEvent(type, bubbles, cancelable, 
				rowIndex, columnIndex, column); 
			
			return cloneEvent;
		}
		
	}
}