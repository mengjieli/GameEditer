package egret.events
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.components.Grid;
	import egret.components.gridClasses.GridColumn;
	import egret.components.gridClasses.IDataGridElement;
	import egret.components.gridClasses.IGridItemRenderer;
	/**
	 * GridEvent 类扩展 MouseEvent 类以包括基于相对于网格单元格的事件位置的其它网格特定信息。该信息包含以下内容： 
	 * <ul>
	 * <li>单元格的行和列索引。</li> 
	 * <li>单元格的 GridColumn 对象。 </li>
	 * <li>对应于单元格行的数据提供程序项。 </li>
	 * <li>项呈示器。 </li>
	 * </ul>
	 * <p>网格事件与鼠标事件一对一对应。分派 GridEvent 是为了响应从某个 Grid 后代到 Grid 本身而“冒泡”的鼠标事件。
	 * 一个显著区别是保证网格事件的事件侦听器能识别整个从下向上拖动鼠标动作，即使此动作的向上拖动部分不发生在网格
	 * 上。gridMouseDrag 事件对应于按住按钮的鼠标移动事件。</p>
	 * @author dom
	 * 
	 */	
	public class GridEvent extends MouseEvent
	{
		/**
		 * gridMouseDown GridEvent 的 type 属性的值。  
		 */		
		public static const GRID_MOUSE_DOWN:String = "gridMouseDown";
		/**
		 * gridMouseDrag GridEvent 的 type 属性的值。仅当侦听器处理完 mouseDown 事件，然后按住按钮的同时移动鼠标时，才会分派此事件。  
		 */		
		public static const GRID_MOUSE_DRAG:String = "gridMouseDrag";  
		/**
		 * gridMouseUp GridEvent 的 type 属性的值。
		 */		
		public static const GRID_MOUSE_UP:String = "gridMouseUp";
		/**
		 * gridClick GridEvent 的 type 属性的值。 
		 */		 
		public static const GRID_CLICK:String = "gridClick";
		/**
		 * gridDoubleClick GridEvent 的 type 属性的值。
		 */		
		public static const GRID_DOUBLE_CLICK:String = "gridDoubleClick";   
		/**
		 * gridRollOver GridEvent 的 type 属性的值。 
		 */		
		public static const GRID_ROLL_OVER:String = "gridRollOver";
		/**
		 * gridRollOut GridEvent 的 type 属性的值。 
		 */		
		public static const GRID_ROLL_OUT:String = "gridRollOut";
		/**
		 * separatorMouseDrag GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_MOUSE_DRAG:String = "separatorMouseDrag";
		/**
		 * separatorClick GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_CLICK:String = "separatorClick";
		/**
		 * separatorDoubleClick GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_DOUBLE_CLICK:String = "separatorDoubleClick";    
		/**
		 * separatorMouseDown GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_MOUSE_DOWN:String = "separatorMouseDown";
		/**
		 * separatorMouseUp GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_MOUSE_UP:String = "separatorMouseUp";
		/**
		 * separatorRollOut GridEvent 的 type 属性的值。 
		 */		
		public static const SEPARATOR_ROLL_OUT:String = "separatorRollOut";
		/**
		 * separatorRollOver GridEvent 的 type 属性的值。
		 */		
		public static const SEPARATOR_ROLL_OVER:String = "separatorRollOver";
		
		/**
		 * 为了响应鼠标事件而由 Grid 类分派的 GridEvent 是使用传入的鼠标事件的属性构造的。
		 * 网格事件的 x、y 位置（表示其 localX 和 localY 属性的值）是相对于整个网格定义的，
		 * 而不是只相对于已滚动到视图中的部分网格定义的。同样，事件的行和列索引可能对应于
		 * 未滚动到视图中的单元格。 
		 * @param type 区分导致此事件分派的鼠标动作。
		 * @param bubbles 指定该事件是否可以在显示列表层次结构得到冒泡处理。
		 * @param cancelable 指定是否可以防止与事件相关联的行为。
		 * @param localX 事件相对于网格的 x 坐标。
		 * @param localY 事件相对于网格的 y 坐标。
		 * @param relatedObject 触发此 GridEvent 的 MouseEvent 的 relatedObject 属性。
		 * @param ctrlKey 是否按下 Control 键。 
		 * @param altKey 是否按下 Alt 键。
		 * @param shiftKey 是否按下 Shift 键。   
		 * @param buttonDown 是否按下 Control 键。
		 * @param delta 未使用。
		 * @param rowIndex 发生事件的行索引，或 -1。
		 * @param columnIndex 发生事件的列索引，或 -1。
		 * @param column 发生该事件的列或 null。
		 * @param item rowIndex 中的数据提供程序项。
		 * @param itemRenderer 发生事件的可视项呈示器或 null。
		 * 
		 */		
		public function GridEvent(
			type:String,
			bubbles:Boolean = false,
			cancelable:Boolean = false,
			localX:Number = NaN,
			localY:Number = NaN,
			relatedObject:InteractiveObject = null,
			ctrlKey:Boolean = false,
			altKey:Boolean = false,
			shiftKey:Boolean = false,
			buttonDown:Boolean = false,
			delta:int = 0,
			rowIndex:int = -1,
			columnIndex:int = -1,
			column:GridColumn = null,
			item:Object = null,
			itemRenderer:IGridItemRenderer = null)
		{
			super(type, bubbles, cancelable, localX, localY, 
				relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			
			this.rowIndex = rowIndex;
			this.columnIndex = columnIndex;
			this.column = column;
			this.item = item;
			this.itemRenderer = itemRenderer;
		}
		/**
		 * 发生事件的行索引；如果在网格行中没有发生事件，则为 -1。 
		 */		
		public var rowIndex:int;
		/**
		 * 发生事件的列索引；如果在网格列中没有发生事件，则为 -1。 
		 */		
		public var columnIndex:int;
		/**
		 *  发生事件的列；如果事件没有发生在列中，则为 null。
		 */		
		public var column:GridColumn;
		/**
		 * 与此事件关联的网格。 
		 * @return 
		 * 
		 */		
		public function get grid():Grid
		{
			if (column)
				return column.grid;
			
			if (target is Grid)
				return Grid(target);
			
			const elt:IDataGridElement = target as IDataGridElement;
			if (elt && elt.dataGrid)
				return elt.dataGrid.grid;
			
			return null;
		}
		/**
		 * 此行的数据提供程序项；如果在网格行中没有发生事件，则为 null。 
		 */		
		public var item:Object;
		/**
		 * 显示此单元格的项呈示器；如果在可见单元格中没有发生事件，则为 null。 
		 */		
		public var itemRenderer:IGridItemRenderer;
		
		override public function clone():Event
		{
			var cloneEvent:GridEvent = new GridEvent(
				type, bubbles, cancelable, 
				localX, localY, 
				relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
				rowIndex, columnIndex, column, item, itemRenderer);
			
			cloneEvent.relatedObject = this.relatedObject;
			
			return cloneEvent;
		}
		
	}
}
