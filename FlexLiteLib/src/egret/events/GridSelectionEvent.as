package egret.events
{
	
	import flash.events.Event;
	
	import egret.components.gridClasses.CellRegion;

	/**
	 * GridSelectionEvent 类表示当 Spark DataGrid 控件中的选定内容由于用户交互而发生更改时分派的事件。 
	 * @author dom
	 * 
	 */	
	public class GridSelectionEvent extends Event
	{
		/**
		 * GridSelectionEvent.SELECTION_CHANGE 常量为 selectionChange 事件定义事件对象的 type 属性值，
		 * 指示当前选定内容刚刚更改。 
		 * 
		 * <p>当用户与此控件交互时，将分派此事件。通过编程方式对数据提供程序的集合进行排序时，此组件不会
		 * 分派 selectionChange 事件。 </p>
		 */		
		public static const SELECTION_CHANGE:String = "selectionChange";
		/**
		 *GridSelectionEvent.SELECTION_CHANGING 常量为 selectionChanging 事件定义事件对象的 type 属性
		 * 的值，指示当前选定内容将要更改。对此事件调用 preventDefault() 以防止更改选定内容。 
		 * 
		 * <p>当用户与此控件交互时，将分派此事件。通过编程方式对数据提供程序的集合进行排序时，此组件不会分
		 * 派 selectionChanging 事件。 </p>
		 */		
		public static const SELECTION_CHANGING:String = "selectionChanging";
		/**
		 * 构造函数。 
		 * @param type 事件类型；指示引发事件的动作。
		 * @param bubbles 指定该事件是否可以在显示列表层次结构得到冒泡处理。
		 * @param cancelable 指定是否可以防止与事件相关联的行为。
		 * @param kind changing 事件的类型。有效值定义为 GridSelectionEventKind 类中的常量。此值确定使用事件中的哪些属性。
		 * @param selectionChange 对当前选定内容建议的或接受的更改。使用 Spark DataGrid 选择方法确定当前选定内容。
		 * 
		 */		
		public function GridSelectionEvent(type:String, 
										   bubbles:Boolean = false,
										   cancelable:Boolean = false,
										   kind:String = null,
										   selectionChange:CellRegion = null)
		{
			super(type, bubbles, cancelable);
			
			this.kind = kind;       
			this.selectionChange = selectionChange;
		}
		/**
		 * 指示发生的事件类型。属性值可以是 GridSelectionEventKind 类中的一个值，也可以是 null，后者指示类型未知。 
		 */		
		public var kind:String;
		/**
		 * 由某些用户操作触发的后续或刚刚完成的选定内容更改。如果将此更改添加到当前选定内容，则它将不会表示完成的选择。使用 DataGrid 选择方法确定选定内容。
		 */		
		public var selectionChange:CellRegion;
		override public function toString():String
		{
			return formatToString(
				"GridSelectionEvent", "type", 
				"bubbles", "cancelable", "eventPhase",
				"kind", 
				"selectionChange");
		}
		override public function clone():Event
		{
			return new GridSelectionEvent(
				type, bubbles, cancelable, kind, selectionChange);
		}
	}
	
}
