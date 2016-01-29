package egret.text.edit
{
	import egret.text.TextFlow;

	/**
	 * 文本的选中状态描述数据
	 * @author dom
	 */	
	public class SelectionState
	{		
		/**
		 * 构造函数
		 * @param root 与选中状态关联的文本流对象
		 * @param anchorPosition 字符位置，用于指定扩展选区时保持固定的选区的未端。
		 * @param activePosition 字符位置，用于指定扩展选区时移动的选区的未端。
		 */		
		public function SelectionState(root:TextFlow,anchorIndex:int,activeIndex:int)
		{
			_textFlow = root;
			
			if (anchorIndex != -1 || activeIndex != -1)
			{
				anchorIndex = clampToRange(anchorIndex);
				activeIndex = clampToRange(activeIndex);
			}
			
			_anchorPosition = anchorIndex;
			_activePosition = activeIndex;
		}
		
		private var _textFlow:TextFlow;
		/**
		 * 与选中状态关联的文本流对象
		 */		
		public function get textFlow():TextFlow
		{ 
			return _textFlow; 
		}
		public function set textFlow(value:TextFlow):void
		{ 
			_textFlow = value; 
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
		public function set anchorPosition(value:int):void
		{ 
			_anchorPosition = value; 
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
		public function set activePosition(value:int):void
		{ 
			_activePosition = value; 
		}
		/**
		 * 选择部分开头的文本位置，是自文本流起始位置的偏移。
		 * 绝对起点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠前。
		 */		
		public function get absoluteStart():int
		{ 
			return _activePosition < _anchorPosition ? _activePosition : _anchorPosition; 
		}
		public function set absoluteStart(value:int):void
		{
			if (_activePosition < _anchorPosition)
				_activePosition = value;
			else
				_anchorPosition = value;
		}
		/**
		 * 选择部分末尾的文本位置，是自文本流起始位置的偏移。
		 * 绝对终点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠后。
		 */	
		public function get absoluteEnd():int
		{ 
			return _activePosition > _anchorPosition ? _activePosition : _anchorPosition; 
		}
		public function set absoluteEnd(value:int):void
		{
			if (_activePosition > _anchorPosition)
				_activePosition = value;
			else
				_anchorPosition = value;
		}	
		
		private function clampToRange(index:int):int
		{
			if (index < 0)
				return 0;
			if (index > _textFlow.textLength)
				return _textFlow.textLength;
			return index;
		}
		
		/**
		 * 设置选中范围
		 */		
		public function updateRange(newAnchorPosition:int,newActivePosition:int):Boolean
		{
			if (newAnchorPosition != -1 || newActivePosition != -1)
			{
				newAnchorPosition = clampToRange(newAnchorPosition);
				newActivePosition = clampToRange(newActivePosition);
			}
			
			if (_anchorPosition != newAnchorPosition || _activePosition != newActivePosition)
			{
				_anchorPosition = newAnchorPosition;
				_activePosition = newActivePosition;
				return true;
			}
			return false;
		}
		
		public function clone():SelectionState
		{
			return new SelectionState(_textFlow,_anchorPosition,_activePosition);
		}
	}
}