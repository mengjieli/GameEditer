package egret.text.operations
{
	import egret.text.edit.SelectionState;
	
	
	/**
	 * 插入文本操作
	 * @author dom
	 */
	public class InsertTextOperation extends TextOperation
	{
		public function InsertTextOperation(originalSelection:SelectionState,text:String,allowMerge:Boolean=false)
		{
			super(originalSelection,allowMerge);
			if(!text)
				text = "";
			this.text = text;
			oldText = textFlow.getText(originalSelection.absoluteStart,originalSelection.absoluteEnd);
		}
		
		public var text:String;
		
		private var oldText:String;
		
		override public function doOperation():void
		{
			textFlow.replaceText(originalSelection.absoluteStart,originalSelection.absoluteEnd,text);
			if(textFlow.interactionManager)
			{
				var index:int = originalSelection.absoluteStart + text.length;
				textFlow.interactionManager.internalSelectRange(index,index);
				textFlow.interactionManager.scrollToRange(index,index);
			}
		}
		
		override public function redo():void
		{
			textFlow.replaceText(originalSelection.absoluteStart,originalSelection.absoluteEnd,text);
			if(textFlow.interactionManager)
			{
				var index:int = originalSelection.absoluteStart + text.length;
				textFlow.interactionManager.internalSelectRange(originalSelection.absoluteStart,index);
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,index);
			}
		}
		
		override public function undo():void
		{
			textFlow.replaceText(originalSelection.absoluteStart,originalSelection.absoluteStart+text.length,oldText);
			if(textFlow.interactionManager)
			{
				textFlow.interactionManager.internalSelectRange(originalSelection.absoluteStart,originalSelection.absoluteStart+oldText.length);
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,originalSelection.absoluteStart+oldText.length);
			}
		}
		
		
		override public function merge(operation:TextOperation):TextOperation
		{
			if(!allowMerge||!operation||!operation.allowMerge||
				!(operation is InsertTextOperation))
				return null;
			var selection:SelectionState;
			var mergedText:String;
			var mergedOldText:String;
			var absoluteStart:int = originalSelection.absoluteStart;
			var targetSelection:SelectionState = operation.originalSelection;
			if(!targetSelection)
				return null;
			if(targetSelection.absoluteEnd==absoluteStart)
			{
				selection = originalSelection.clone();
				selection.absoluteStart = targetSelection.absoluteStart;
				mergedOldText = InsertTextOperation(operation).oldText+oldText;
				mergedText = InsertTextOperation(operation).text+text;
			}
			else if(targetSelection.absoluteStart==absoluteStart+text.length)
			{
				selection = originalSelection.clone();
				selection.absoluteEnd += targetSelection.absoluteEnd-targetSelection.absoluteStart;
				mergedOldText = oldText + InsertTextOperation(operation).oldText;
				mergedText = text+InsertTextOperation(operation).text;
			}
			if(selection)
			{
				var mergedOp:InsertTextOperation = new InsertTextOperation(selection,mergedText,true);
				mergedOp.oldText = mergedOldText;
				return mergedOp;
			}
			return null;
		}
	}
}