package egret.text.edit
{
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.text.ime.CompositionAttributeRange;
	import flash.text.ime.IIMEClient;
	
	import egret.core.ns_egret;
	import egret.text.TextFlow;
	import egret.text.operations.InsertTextOperation;
	
	use namespace ns_egret;

	internal class IMEClient implements IIMEClient
	{
		private var _editManager:EditManager;

		private var _imeAnchorPosition:int;	
		private var _imeLength:int;	
		private var _closing:Boolean;
		
		public function IMEClient(editManager:EditManager)
		{
			_editManager = editManager;
			_imeAnchorPosition = _editManager.absoluteStart;
			_closing = false;
		}
		
		
		public function selectionChanged():void
		{	
			if (_editManager.absoluteStart > _imeAnchorPosition + _imeLength || _editManager.absoluteEnd < _imeAnchorPosition)
			{
				compositionAbandoned();
			}
			else 
			{
				IME.compositionSelectionChanged(_editManager.absoluteStart - _imeAnchorPosition, _editManager.absoluteEnd - (_imeAnchorPosition + _imeLength));
			}
		}

		public function updateComposition(text:String, attributes:Vector.<CompositionAttributeRange>, compositionStartIndex:int, compositionEndIndex:int):void
	    {
			if (_imeLength > 0)
				rollBackIMEChanges();
			_imeLength = text.length;
			var absoluteStart:int = _editManager.absoluteStart;
			var insertTextOp:InsertTextOperation = new InsertTextOperation(_editManager.getSelectionState(),text);
			_editManager.doOperation(insertTextOp);
			_editManager.internalSelectRange(absoluteStart,absoluteStart+text.length);
	    }
		/**
		 * 清除输入法临时插入的字符串
		 */		
		private function rollBackIMEChanges():void
		{
			if(_imeLength>0)
			{
				_editManager.undoManager.undo();
				_editManager.undoManager.popRedo();
				_imeLength = 0;
			}
			
		}
		
	    public function confirmComposition(text:String = null, preserveSelection:Boolean = false):void
		{
			endIMESession();
		}
		
		public function compositionAbandoned():void
		{
			IME.compositionAbandoned();
		}
		
		private function endIMESession():void
		{
			if (!_editManager || _closing)
				return;
			
			_closing = true;
			if (_imeLength > 0)
				rollBackIMEChanges();
			_editManager.endIMESession();
			_editManager = null;
			_imeLength = 0;
		}
		
		public function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			try
			{
				var rect:Rectangle = _editManager.getTextBounds(startIndex,endIndex);
			} 
			catch(error:Error) 
			{
				trace(error.getStackTrace());
			}
			return rect;
		}
		
		public function get compositionStartIndex():int
		{
			return _imeAnchorPosition;
		}
		
		public function get compositionEndIndex():int
		{
			return _imeAnchorPosition + _imeLength;
		}
		

		public function get selectionActiveIndex():int
		{
			return _editManager.activePosition;
		}
		
		public function get selectionAnchorIndex():int
		{
			return _editManager.activePosition;
		}
		
		public function get verticalTextLayout():Boolean
		{
			return false;
		}

		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
			_editManager.selectRange(anchorIndex, activeIndex);
		}
		
		public function getTextInRange(startIndex:int, endIndex:int):String
		{
			var textFlow:TextFlow = _editManager.textFlow;
			if (startIndex < -1 || endIndex < -1 || startIndex > (textFlow.textLength - 1) || endIndex > (textFlow.textLength - 1))
				return null;
			
			if (startIndex == -1)
				startIndex = 0;
			
			return textFlow.getText(startIndex, endIndex);
		} 
	}
}