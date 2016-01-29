package egret.text.operations
{
	import egret.text.TextFlow;
	import egret.text.edit.SelectionState;
	import egret.text.undo.IOperation;
	
	/**
	 * 文本操作基类
	 * @author dom
	 */
	public class TextOperation implements IOperation
	{
		public function TextOperation(originalSelection:SelectionState,allowMerge:Boolean=false)
		{
			if(originalSelection)
			{
				this.textFlow = originalSelection.textFlow;
				this.originalSelection = originalSelection;
			}
			this._allowMerge = allowMerge;
		}
		
		/**
		 * 与操作关联的文本流对象
		 */
		public var textFlow:TextFlow;
		/**
		 * 执行操作之前文本原始的选择范围
		 */
		public var originalSelection:SelectionState;
		
		private var _allowMerge:Boolean = false;
		/**
		 * 是否允许跟其他操作合并,默认false。
		 */
		public function get allowMerge():Boolean
		{
			return _allowMerge;
		}

		
		/**
		 * 与下一个操作合并
		 */		
		public function merge(operation:TextOperation):TextOperation
		{
			return null;
		}
		/**
		 * 执行操作
		 */		
		public function doOperation():void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function undo():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function redo():void
		{
		}
		
		private var _doNext:Boolean;
		/**
		 * @inheritDoc
		 */
		public function get doNext():Boolean
		{
			return _doNext;
		}

		public function set doNext(value:Boolean):void
		{
			_doNext = value;
		}
	}
}