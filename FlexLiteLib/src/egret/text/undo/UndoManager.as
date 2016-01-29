package egret.text.undo
{
			
	/**
	 * 撤销管理器
	 * @author dom
	 */	
	public class UndoManager implements IUndoManager
	{
		private var undoStack:Array;
		private var redoStack:Array;
		
		/**
		 * 创建一个撤销管理器。
		 */			
		public function UndoManager()
		{
			undoStack = new Array();
			redoStack = new Array();
		}
		
		/**
		 * @copy IUndoManager#clearAll()
		 */	
		public function clearAll():void
		{
			undoStack.length = 0;
			redoStack.length = 0;			
		}
		
		/**
		 * @copy IUndoManager#canUndo()
		 */
		public function canUndo():Boolean
		{
			return undoStack.length > 0;
		}
		
		/**
		 * @copy IUndoManager#peekUndo()
		 */
		public function peekUndo():IOperation
		{
			return undoStack.length > 0 ? undoStack[undoStack.length-1] : null;
		}
		
		/**
		 * @copy IUndoManager#popUndo()
		 */
		public function popUndo():IOperation
		{
			return IOperation(undoStack.pop());
		}

		/**
		 * @copy IUndoManager#pushUndo()
		 */
		public function pushUndo(operation:IOperation):void
		{
			undoStack.push(operation);
			trimUndoRedoStacks();
		}
		
		/**
		 * @copy IUndoManager#canRedo()
		 */
		public function canRedo():Boolean
		{
			return redoStack.length > 0;
		}

		/**
		 * @copy IUndoManager#clearRedo()
		 */
		public function clearRedo():void
		{
			redoStack.length = 0;
		}

		/**
		 * @copy IUndoManager#peekRedo()
		 */
		public function peekRedo():IOperation
		{
			return redoStack.length > 0 ? redoStack[redoStack.length-1] : null;
		}
		
		/**
		 * @copy IUndoManager#popRedo()
		 */
		public function popRedo():IOperation
		{
			return IOperation(redoStack.pop());
		}

		/**
		 * @copy IUndoManager#pushRedo()
		 */
		public function pushRedo(operation:IOperation):void
		{
			redoStack.push(operation);
			trimUndoRedoStacks();
		}

		private var _undoAndRedoItemLimit:int = int.MAX_VALUE;
		/**
		 * @copy IUndoManager#undoAndRedoItemLimit
		 */
		public function get undoAndRedoItemLimit():int
		{ 
			return _undoAndRedoItemLimit; 
		}
		public function set undoAndRedoItemLimit(value:int):void
		{ 
			_undoAndRedoItemLimit = value;
			trimUndoRedoStacks();
		}

		/** 
		 * @copy IUndoManager#undo()
		 */
		public function undo():void
		{
			if (canUndo())
			{
				var undoOp:IOperation = popUndo();
				undoOp.undo();
				pushRedo(undoOp);
				if(undoOp.doNext)
					undo();
			}
		}
		
		/** 
		 * @copy IUndoManager#redo()
		 */
		public function redo():void
		{
			if (canRedo())
			{
				var redoOp:IOperation = popRedo();
				redoOp.redo();
				pushUndo(redoOp);
				if(redoOp.doNext)
					redo();
			}
		}									
		
		/**
		 * 根据最大次数精简撤销和重做列表
		 */		
		private function trimUndoRedoStacks():void
		{
			var numItems:int = undoStack.length + redoStack.length;
			if (numItems > _undoAndRedoItemLimit)
			{
				var numToSplice:int = Math.min(numItems-_undoAndRedoItemLimit,redoStack.length);
				if (numToSplice)
				{
					redoStack.splice(0,numToSplice);
					numItems = undoStack.length+redoStack.length;
				} 
				if (numItems > _undoAndRedoItemLimit)
				{
					numToSplice = Math.min(numItems-_undoAndRedoItemLimit,undoStack.length);
					undoStack.splice(0,numToSplice);
				}
			}
		}
		
	}
}
