package egret.components.gridClasses
{
	import egret.components.DataGrid;
	import egret.components.IDataRenderer;
	import egret.core.IVisualElement;
	
	/**
	 * 数据表格编辑器的接口 
	 * <p>
	 * 项编辑器的所有属性都由所有者在启动编辑器会话期间设置。data 属性是最后一个设置的属性。
	 * 在设置 data 属性之后，项编辑器应设置编辑器控件的值。然后，调用编辑器的 prepare() 方法。
	 * IGridItemEditor 实现应覆盖 prepare() 方法，从而对其属性或其可视元素的任何方面进行任何最终调整。
	 * 在关闭编辑器时，将调用 discard() 方法。</p>
	 * <p>
	 * 在关闭编辑器时，可以保存或取消输入的值。如果保存，编辑器将调用 save() 函数以在与已编辑的单元格的行相对应的数据提供程序元素中写入新值。
	 * </p>
	 * @author dom
	 * 
	 */	
	public interface IGridItemEditor extends IDataRenderer, IVisualElement
	{
		/**
		 * 拥有此项编辑器的数据表格控件。 
		 */		
		function get dataGrid():DataGrid;
		/**
		 * 正在编辑的单元格的列。 
		 */		
		function get column():GridColumn;	
		function set column(value:GridColumn):void;
		/**
		 * 正在编辑的从零开始的列索引。 
		 */	
		function get columnIndex():int;
		/**
		 * 正在编辑的单元格的从零开始的行索引。 
		 */		
		function get rowIndex():int;
		function set rowIndex(value:int):void;
		/**
		 * <p>在已创建编辑器并设置其大小之后，而编辑器可见之前调用。在编辑器可见之前，
		 * 使用此方法调整编辑器的外观、添加事件侦听器或执行任何其它初始化。</p>
		 * 
		 * <p>无需直接调用此方法。应仅由承载项编辑器的控件来调用。</p>
		 * 
		 */		
		function prepare():void;
		
		/**
		 * <p>恰好在关闭编辑器之前调用。使用此方法执行任何最后清理，如清理在 prepare() 方法中设置的任何内容。 </p>
		 * <p>无需直接调用此方法。应仅由承载项编辑器的控件来调用。</p>
		 * 
		 */		
		function discard():void;
		/**
		 * <p>将编辑器中的值保存到项呈示器所有者的数据提供程序中。此方法更新与已编辑的单元格的行相对应的数据提供程序元素。
		 * 此函数调用 GridItemEditor.validate() 以验证是否可以保存数据。如果数据无效，则不保存数据，且不关闭编辑器。 </p>
		 * 
		 * <p>无需直接调用此方法。应仅由承载项编辑器的控件来调用。要保存并关闭编辑器，请调用项呈示器所有者的 endItemEditorSession() 方法。</p>
		 * @return 
		 * 
		 */		
		function save():Boolean;
		
	}
}