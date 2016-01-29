package egret.text.operations
{
	import egret.text.edit.SelectionState;
	
	
	/**
	 * 删除文本操作
	 * @author dom
	 */
	public class DeleteTextOperation extends TextOperation
	{
		public function DeleteTextOperation(originalSelection:SelectionState,allowMerge:Boolean=false)
		{
			super(originalSelection,allowMerge);
			oldText = textFlow.getText(originalSelection.absoluteStart,originalSelection.absoluteEnd);
		}
		
		private var oldText:String;
		
		override public function doOperation():void
		{
			textFlow.replaceText(originalSelection.absoluteStart,originalSelection.absoluteEnd,"");
			if(oldText&&textFlow.interactionManager)
			{
				textFlow.interactionManager.internalSelectRange(originalSelection.absoluteStart,originalSelection.absoluteStart);
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,originalSelection.absoluteStart);
			}
		}
		
		override public function redo():void
		{
			doOperation();
			if(oldText&&textFlow.interactionManager)
			{
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,originalSelection.absoluteStart);
			}
		}
		
		override public function undo():void
		{
			textFlow.replaceText(originalSelection.absoluteStart,originalSelection.absoluteStart,oldText);
			if(textFlow.interactionManager)
			{
				textFlow.interactionManager.internalSelectRange(originalSelection.absoluteStart,originalSelection.absoluteEnd);
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,originalSelection.absoluteEnd);
			}
		}
		
		override public function merge(operation:TextOperation):TextOperation
		{
			if(!allowMerge||!operation||!operation.allowMerge||
				!(operation is DeleteTextOperation))
				return null;
			var selection:SelectionState;
			var mergedText:String;
			var absoluteStart:int = originalSelection.absoluteStart;
			var targetSelection:SelectionState = operation.originalSelection;
			if(!targetSelection)
				return null;
			if(targetSelection.absoluteEnd==absoluteStart)
			{
				selection = originalSelection.clone();
				selection.absoluteStart = targetSelection.absoluteStart;
				mergedText = DeleteTextOperation(operation).oldText+oldText;
			}
			else if(targetSelection.absoluteStart==absoluteStart)
			{
				selection = originalSelection.clone();
				selection.absoluteEnd += targetSelection.absoluteEnd-targetSelection.absoluteStart;
				mergedText = oldText + DeleteTextOperation(operation).oldText;
			}
			if(selection)
			{
				var mergedOp:DeleteTextOperation = new DeleteTextOperation(selection,true);
				mergedOp.oldText = mergedText;
				return mergedOp;
			}
			return null;
		}
	}
}