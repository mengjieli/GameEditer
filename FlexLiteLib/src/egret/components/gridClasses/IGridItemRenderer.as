package egret.components.gridClasses
{
	import egret.components.Grid;
	import egret.components.IDataRenderer;
	import egret.core.IVisualElement;
	
	/**
	 * DataGrid中数据单元的渲染器
	 * @author dom
	 * 
	 */	
	public interface IGridItemRenderer extends IDataRenderer, IVisualElement
	{
		/**
		 * 与此项呈示器相关联的 Grid，通常是 column.grid 的值。 
		 */		
		function get grid():Grid;
		/**
		 * 正在呈示的单元格的从零开始的行索引。 
		 */		
		function get rowIndex():int;
		function set rowIndex(value:int):void;
		/**
		 * <p>在网格单元格中发生以下两个输入动作之一时，该属性设置为 true：按鼠标按键或按触摸屏。
		 * 当释放鼠标按键、用户的手指离开触摸屏或将鼠标/触摸拖离网格单元格时，down 属性重置为 false。</p>
		 * <p>与 List 项呈示器不同，Grid 项呈示器不专门负责显示按下指示符。Grid 本身为所选行或单元格呈示按下指示符。
		 * 项呈示器还可以更改其 visual 属性以强调正在按此项呈示器。</p>
		 */		
		function get down():Boolean;
		function set down(value:Boolean):void;
		/**
		 * 如果正在拖动项呈示器（通常作为拖放操作的一部分），则包含 true。
		 */		
		function get dragging():Boolean;
		function set dragging(value:Boolean):void;
		/**
		 * <p>如果项呈示器位于鼠标下，而 Grid 的 selectionMode 为 GridSelectionMode.SINGLE_CELL 或 GridSelectionMode.MULTIPLE_CELLS，
		 * 或者如果鼠标在项呈示器所属的行中，而 Grid 的 selectionMode 为 GridSelectionMode.SINGLE_ROW 或 GridSelectionMode.MULTIPLE_ROWS，
		 * 则包含 true。 </p>
		 * <p>与 List 项呈示器不同，Grid 项呈示器不专门负责显示内容以指明呈示器或其行位于鼠标下。
		 * Grid 本身为悬浮行或单元格自动显示 hoverIndicator 外观部件。Grid 项呈示器还可以更改其属性以强调在此项呈示器上悬浮。</p>
		 */		
		function get hovered():Boolean;
		function set hovered(value:Boolean):void;
		/**
		 * <p>要在项呈示器中显示的 String。 </p>
		 * <p>如果 labelDisplay 元素已指定，GridItemRenderer 类会自动将该属性的值复制到该元素的 text 属性。
		 * Grid 将 label 设置为由列的 itemToLabel() 方法返回的值。</p>
		 */		
		function get label():String;
		function set label(value:String):void;
		/**
		 * <p>如果项呈示器的单元格属于当前选定内容，则包含 true。 </p>
		 * <p>与 List 项呈示器不同，Grid 项呈示器不专门负责显示内容以指明它们是选定内容的一部分。
		 * Grid 本身为选定行或单元格自动显示 selectionIndicator 外观部件。
		 * 项呈示器还可以更改其 visual 属性以强调它属于选定内容。</p>
		 */		
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		/**
		 * <p>如果插入标记指明项呈示器的单元格，则包含 true。</p> 
		 * <p>与 List 项呈示器不同，Grid 项呈示器不专门负责显示内容以指明它们的单元格或行含有插入标记。
		 * Grid 本身为插入标记行或单元格自动显示 caretIndicator 外观部件。
		 * 项呈示器还可以更改其 visual 属性以强调它含有插入标记。</p>
		 */		
		function get showsCaret():Boolean;
		function set showsCaret(value:Boolean):void;   
		/**
		 * 表示与此项呈示器相关联的列的 GridColumn 对象。 
		 */		
		function get column():GridColumn;
		function set column(value:GridColumn):void;
		/**
		 * 此项呈示器的单元格的列索引。这是与 column.columnIndex 相同的值。 
		 */		
		function get columnIndex():int;  
		/**
		 * <p>在设置了呈示器的所有属性后，从项呈示器父代的 updateDisplayList() 方法调用。如果以前从未使用过此呈示器，
		 * 则 hasBeenRecycled 参数为 false，表示此呈示器不可再生。当呈示器将要可见时，每次因呈示器属性更改而重新
		 * 显示呈示器时，或显式请求重新显示时，调用此方法。 </p>
		 * <p>此方法可以用来配置呈示器的所有可视元素和属性。使用此方法与将 data 属性绑定到可视元素属性相比，效率会更
		 * 高。注意：由于 prepare() 方法经常被调用，因此请确保已对其进行高效编码。</p>
		 * <p>在调用 discard() 方法之前，可能会多次调用 prepare() 方法。</p>
		 * <p>不可直接调用此方法。它将被 DataGrid 实现调用。</p>
		 * @param willBeRecycled 如果要将此呈示器添加到所有者的内部空闲列表以重用，则为 true。
		 */		
		function prepare(hasBeenRecycled:Boolean):void;
		/**
		 * <p>在已确定此呈示器将不再可见时，从项呈示器父代的 updateDisplayList() 方法调用。
		 * 如果 willBeRecycled 参数设置为 true，则所有者将此呈示器添加到其内部空闲列表以重用。
		 * 实现可使用此方法清除任何不再需要的呈示器属性。 </p>
		 * <p>不可直接调用此方法。它将被 DataGrid 实现调用。</p>
		 * @param willBeRecycled 如果要将此呈示器添加到所有者的内部空闲列表以重用，则为 true。
		 */		
		function discard(willBeRecycled:Boolean):void;
	}
}