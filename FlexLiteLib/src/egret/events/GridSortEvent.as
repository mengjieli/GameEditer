package egret.events
{
	
	import flash.events.Event;
	
	import egret.components.gridClasses.GridColumn;
	/**
	 * GridSortEvent 类表示 Spark DataGrid 控件的数据提供程序按用户单击 
	 * DataGrid 中列标题的结果进行排序时分派的事件。 
	 * @author dom
	 * 
	 */	
	public class GridSortEvent extends Event
	{
		/**
		 * GridSortEvent.SORT_CHANGE 常量为 sortChange 事件定义事件对象的 type 属性值，
		 * 其指示排序过滤器已应用于网格的 dataProvider 集合。 
		 * 
		 * <p>通常，如果列标题鼠标单击触发了该排序，则 columnIndices 的上一个索引是列索引。
		 * 请注意，交互式排序不需要由鼠标单击触发。</p>
		 * 
		 * <p>当用户与此控件交互时，将分派此事件。通过编程方式对数据提供程序的集合进行排序时，
		 * 此组件不会分派 sortChange 事件。 </p>
		 */		
		public static const SORT_CHANGE:String = "sortChange";
		/**
		 * GridSortEvent.SORT_CHANGING 常量为 sortChanging 事件定义事件对象的 type 属性值，
		 * 其指示排序过滤器将应用于网格的 dataProvider 集合。对该事件调用 preventDefault() 
		 * 可防止排序发生，或者如果要更改排序的默认行为，可以修改 columnIndices 和 newSortFields。 
		 * 
		 * <p>通常，如果列标题鼠标单击触发了该排序，则 columnIndices 的上一个索引是列索引。请注
		 * 意，交互式排序不需要由鼠标单击触发。</p>
		 * 
		 * <p>当用户与此控件交互时，将分派此事件。通过编程方式对数据提供程序的集合进行排序时，
		 * 此组件不会分派 sortChanging 事件。 </p>
		 */		
		public static const SORT_CHANGING:String = "sortChanging";
		/**
		 * 构造函数。 
		 * @param type 事件类型；指示引发事件的动作。
		 * @param bubbles 指定该事件是否可以在显示列表层次结构得到冒泡处理。
		 * @param cancelable 指定是否可以防止与事件相关联的行为。
		 * @param column
		 * 
		 */	
		public function GridSortEvent(type:String, 
									  bubbles:Boolean,
									  cancelable:Boolean,
									  column:GridColumn)  
		{
			super(type, bubbles, cancelable);
			
			this.column = column;
		}
		
		public var column:GridColumn;
		
		override public function clone():Event
		{
			return new GridSortEvent(type, bubbles, cancelable, column);
		}
	}
	
}
