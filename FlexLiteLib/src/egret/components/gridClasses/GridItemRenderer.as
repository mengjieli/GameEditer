package egret.components.gridClasses
{
	import egret.components.Grid;
	import egret.components.SkinnableComponent;
	import egret.core.IDisplayText;
	import egret.core.IToolTip;
	import egret.core.ns_egret;
	import egret.events.ToolTipEvent;
	import egret.managers.IToolTipManagerClient;
	import egret.managers.ToolTipManager;
	import egret.skins.vector.ButtonSkin;
	
	use namespace ns_egret;
	
	/**
	 * 表格的数据单元渲染器。 
	 * @author dom
	 * 
	 */	
	public class GridItemRenderer extends SkinnableComponent implements IGridItemRenderer
	{
		/**
		 * 如果此列的showDataTips改变了，那本渲染器的tooltip属性就就绪。真正的tooltip提示工作是在下面的 TOOL_TIP_SHOW事件监听器中执行的。
		 * @param renderer
		 * 
		 */		
		static ns_egret function initializeRendererToolTip(renderer:IGridItemRenderer):void
		{
			var toolTipClient:IToolTipManagerClient = renderer as IToolTipManagerClient;
			if (!toolTipClient)
				return;
			
			var showDataTips:Boolean = (renderer.rowIndex != -1) && renderer.column && renderer.column.getShowDataTips();
			var dataTip:Object = toolTipClient.toolTip;
			
			if (!dataTip && showDataTips)
				toolTipClient.toolTip = "<dataTip>";
			else if (dataTip && !showDataTips)
				toolTipClient.toolTip = null;
		}
		
		/**
		 * 显示一个表格数据单元的tooltip
		 * @param event
		 * 
		 */		
		static ns_egret function toolTipShowHandler(event:ToolTipEvent):void
		{
			var toolTip:IToolTip = event.toolTip;
			
			var renderer:IGridItemRenderer = event.currentTarget as IGridItemRenderer;
			if (!renderer)
				return;
			var toolTipClient:IToolTipManagerClient = event.currentTarget as IToolTipManagerClient;
			if (!toolTipClient)
				return;
			
			toolTip.toolTipData = renderer.column.itemToDataTip(renderer.data);
			ToolTipManager.positionTip(toolTip,toolTipClient);
		}
		
		public function GridItemRenderer()
		{
			super();
			this.skinName = ButtonSkin;
			addEventListener(ToolTipEvent.TOOL_TIP_SHOW, GridItemRenderer.toolTipShowHandler);           
		}
		
		/**
		 * [SkinPart]按钮上的文本标签
		 */
		public var labelDisplay:IDisplayText;
		
		private var _label:String = "";
		/**
		 * 要在按钮上显示的文本
		 */		
		public function set label(value:String):void
		{
			_label = value;
			if(labelDisplay)
			{
				labelDisplay.text = value;
			}
		}
		
		public function get label():String          
		{
			if(labelDisplay)
			{
				return labelDisplay.text;
			}
			else
			{
				return _label;
			}
		}
		
		private var _column:GridColumn = null;
		/**
		 * 与此渲染器相关联的列的 GridColumn对象。
		 * @return 
		 * 
		 */		
		public function get column():GridColumn
		{
			return _column;
		}
		
		public function set column(value:GridColumn):void
		{
			if (_column == value)
				return;
			_column = value;
		}

		/**
		 * 该渲染器的所在单元格的列索引。这是与 column.columnIndex 相同的值。 
		 * @return 
		 * 
		 */		
		public function get columnIndex():int
		{
			return (column) ? column.columnIndex : -1;
		}
		
		private var _data:Object = null;
		
		/**
		 * 与该渲染器相对应行的对象。此对象与调用 dataProvider.getItemAt(rowIndex) 方法所返回的对象相对应。 
		 * @return 
		 * 
		 */		
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			if (_data == value)
				return;
			_data = value;
			
		}
		
		private var _down:Boolean = false;
		/**
		 * 当鼠标按下或者触摸屏幕的时候，这个值为true。反向操作为false。 
		 * @return 
		 * 
		 */		
		public function get down():Boolean
		{
			return _down;
		}

		public function set down(value:Boolean):void
		{
			if (value == _down)
				return;
			_down = value;
			invalidateSkinState();
		}

		/**
		 * 返回与该渲染器相关联的 Grid。与 column.grid 相同。 
		 * @return 
		 * 
		 */		
		public function get grid():Grid
		{
			return (column) ? column.grid : null;
		}   
		
		private var _hovered:Boolean = false;
		
		/**
		 * 触碰了为true 
		 * @return 
		 * 
		 */		
		public function get hovered():Boolean
		{
			return _hovered;
		}

		public function set hovered(value:Boolean):void
		{
			if (value == _hovered)
				return;
			
			_hovered = value;
			invalidateSkinState();
		}
		
		private var _rowIndex:int = -1;
		
		/**
		 * 该渲染器的行索引 
		 * @return 
		 * 
		 */		
		public function get rowIndex():int
		{
			return _rowIndex;
		}

		public function set rowIndex(value:int):void
		{
			if (_rowIndex == value)
				return;
			_rowIndex = value;
		}
		
		private var _showsCaret:Boolean = false;
		
		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}
		public function set showsCaret(value:Boolean):void
		{
			if (_showsCaret == value)
				return;
			
			_showsCaret = value;
			invalidateSkinState();
		}
		
		private var _selected:Boolean = false;
		/**
		 * 是否被选择 
		 * @return 
		 * 
		 */		
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if (_selected == value)
				return;
			_selected = value;
			invalidateSkinState();
		}
		
		private var _dragging:Boolean = false;
		
		/**
		 * 是否正在拖拽 
		 * @return 
		 * 
		 */		
		public function get dragging():Boolean
		{
			return _dragging;
		}

		public function set dragging(value:Boolean):void
		{
			if (_dragging == value)
				return;
			
			_dragging = value;
			invalidateSkinState();  
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			if(_selected)
				return "down";
			if (!enabled)
				return super.getCurrentSkinState();
			if (_down)
				return "down";
			if (_hovered)
				return "over";
			return "up";
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == labelDisplay)
			{
				labelDisplay.text = _label;
			}
		}


		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(width, height);
			
			initializeRendererToolTip(this);
		} 
		/**
		 * 在呈现之前，由父级的updateDisplayList()调用。之类重写实现具体操作。
		 *  
		 * @param hasBeenRecycled 表示这个渲染器是否可再生
		 * 
		 */		
		public function prepare(hasBeenRecycled:Boolean):void
		{
			
		}
		/**
		 * 在已确定该渲染器将不再可见时，由父级的 updateDisplayList() 方法调用。 子类重写实现具体操作。
		 * @param willBeRecycled 表示这个渲染器是否要被未来重用。
		 * 
		 */
		public function discard(willBeRecycled:Boolean):void
		{
			
		}
	}
}