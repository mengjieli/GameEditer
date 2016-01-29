package egret.text.operations
{
	import egret.text.edit.SelectionState;
	
	
	/**
	 * 插入段首缩进操作
	 * @author dom
	 */
	public class InsertTabOperation extends TextOperation
	{
		public function InsertTabOperation(originalSelection:SelectionState,tabKeyText:String)
		{
			super(originalSelection, allowMerge);
			if(!tabKeyText)
				tabKeyText = "";
			this.tabKeyText = tabKeyText;
			initialize();
		}
		
		private function initialize():void
		{
			var absoluteStart:int = originalSelection.absoluteStart;
			var absoluteEnd:int = originalSelection.absoluteEnd;
			var curPosition:int = textFlow.findStartOfParagraph(absoluteStart);
			insertTabList = [];
			while(curPosition<absoluteEnd)
			{
				insertTabList.push(curPosition);
				curPosition = textFlow.findEndOfParagraph(curPosition);
			}
		}
		
		private var tabKeyText:String;
		
		private var insertTabList:Array;
		
		override public function doOperation():void
		{
			var absoluteStart:int = originalSelection.absoluteStart;
			var absoluteEnd:int = originalSelection.absoluteEnd;
			var length:int = insertTabList.length;
			for(var i:int=length-1;i>=0;i--)
			{
				var insertIndex:int = insertTabList[i];
				textFlow.replaceText(insertIndex,insertIndex,tabKeyText);
			}
			if(textFlow.interactionManager)
			{
				var extraLength:int = length*tabKeyText.length;
				textFlow.interactionManager.internalSelectRange(absoluteStart+tabKeyText.length,absoluteEnd+extraLength);
				textFlow.interactionManager.scrollToRange(absoluteEnd+extraLength,absoluteEnd+extraLength);
			}
		}
		
		override public function redo():void
		{
			doOperation();
			if(textFlow.interactionManager)
			{
				var absoluteStart:int = originalSelection.absoluteStart;
				var absoluteEnd:int = originalSelection.absoluteEnd;
				var extraLength:int = length*tabKeyText.length;
				textFlow.interactionManager.scrollToRange(absoluteStart+tabKeyText.length,absoluteEnd+extraLength);
			}
		}
		
		override public function undo():void
		{
			var absoluteStart:int = originalSelection.absoluteStart;
			var absoluteEnd:int = originalSelection.absoluteEnd;
			var length:int = insertTabList.length;
			var tabLength:int = tabKeyText.length;
			for(var i:int=0;i<length;i++)
			{
				var insertIndex:int = insertTabList[i];
				textFlow.replaceText(insertIndex,insertIndex+tabLength,"");
			}
			if(textFlow.interactionManager)
			{
				textFlow.interactionManager.internalSelectRange(originalSelection.absoluteStart,originalSelection.absoluteEnd);
				textFlow.interactionManager.scrollToRange(originalSelection.absoluteStart,originalSelection.absoluteEnd);
			}
		}
	}
}