package egret.text.operations
{
	import egret.text.edit.SelectionState;
	
	/**
	 * 移动文本操作 
	 * @author featherJ
	 * 
	 */	
	public class MoveTextOperation extends TextOperation
	{
		
		private var moveTo:int;
		public function MoveTextOperation(fromSelection:SelectionState,moveTo:int,allowMerge:Boolean = false)
		{
			super(fromSelection,allowMerge);
			this.moveTo = moveTo;
		}
		
		private var operationed:Boolean = false;
		override public function doOperation():void
		{
			var beginFrom:int = originalSelection.absoluteStart;
			var endFrom:int = originalSelection.absoluteEnd;
			var text:String = textFlow.getText(beginFrom,endFrom);
			var to:int = moveTo;
			
			if(to < beginFrom || to > endFrom)
			{
				operationed = true;
				//先加入文本
				textFlow.replaceText(to,to,text);
				
				var dropInBegin:int = to;
				var dropInEnd:int = to+text.length;
				
				//移除旧的文本
				var begin:int;
				var end:int;
				
				if(to < beginFrom) //在之前
				{
					end = endFrom+(endFrom-beginFrom);
					begin = beginFrom+(endFrom-beginFrom)
					textFlow.replaceText(begin,end,"");
				}else if(to > endFrom) //在之后
				{
					end = endFrom;
					begin = beginFrom;
					textFlow.replaceText(begin,end,"");
				}
				
				
				if(textFlow.interactionManager)
				{
					if(endFrom < dropInBegin)
					{
						begin = dropInBegin-(endFrom-beginFrom);
						end = dropInEnd-(endFrom-beginFrom);
					}else
					{
						begin = dropInBegin;
						end = dropInEnd;
					}
					if(to < beginFrom || to > endFrom)
					{
						textFlow.interactionManager.scrollToRange(begin,end);
						textFlow.interactionManager.internalSelectRange(begin,end);
					}
					else
					{
						textFlow.interactionManager.scrollToRange(beginFrom,endFrom);
						textFlow.interactionManager.internalSelectRange(beginFrom,endFrom);
					}
				}
			}
		}
		
		override public function redo():void
		{
			if(operationed)
			{
				var beginFrom:int = originalSelection.absoluteStart;
				var endFrom:int = originalSelection.absoluteEnd;
				var text:String = textFlow.getText(beginFrom,endFrom);
				var to:int = moveTo;
				
				if(to < beginFrom || to > endFrom)
				{
					//先加入文本
					textFlow.replaceText(to,to,text);
					
					var dropInBegin:int = to;
					var dropInEnd:int = to+text.length;
					
					//移除旧的文本
					var begin:int;
					var end:int;
					
					if(to < beginFrom) //在之前
					{
						end = endFrom+(endFrom-beginFrom);
						begin = beginFrom+(endFrom-beginFrom)
						textFlow.replaceText(begin,end,"");
					}else if(to > endFrom) //在之后
					{
						end = endFrom;
						begin = beginFrom;
						textFlow.replaceText(begin,end,"");
					}
					
					
					if(textFlow.interactionManager)
					{
						if(endFrom < dropInBegin)
						{
							begin = dropInBegin-(endFrom-beginFrom);
							end = dropInEnd-(endFrom-beginFrom);
						}else
						{
							begin = dropInBegin;
							end = dropInEnd;
						}
						if(to < beginFrom || to > endFrom)
						{
							textFlow.interactionManager.internalSelectRange(begin,end);
							textFlow.interactionManager.scrollToRange(begin,end);
						}
						else
						{
							textFlow.interactionManager.internalSelectRange(beginFrom,endFrom);
							textFlow.interactionManager.scrollToRange(beginFrom,endFrom);
						}
					}
				}
			}
		}
		
		override public function undo():void
		{
			if(operationed)
			{
				var beginFrom:int;
				var endFrom:int;
				var to:int;
				
				if(originalSelection.absoluteEnd < moveTo)
				{
					beginFrom = moveTo-(originalSelection.absoluteEnd-originalSelection.absoluteStart);
					endFrom = beginFrom+(originalSelection.absoluteEnd-originalSelection.absoluteStart);
					to = originalSelection.absoluteStart;
				}else if(originalSelection.absoluteStart > moveTo)
				{
					beginFrom = moveTo;
					endFrom = beginFrom+(originalSelection.absoluteEnd-originalSelection.absoluteStart);
					to = originalSelection.absoluteStart+(originalSelection.absoluteEnd-originalSelection.absoluteStart);
				}
				var text:String = textFlow.getText(beginFrom,endFrom);
				
				
				if(to < beginFrom || to > endFrom)
				{
					//先加入文本
					textFlow.replaceText(to,to,text);
					
					var dropInBegin:int = to;
					var dropInEnd:int = to+text.length;
					
					//移除旧的文本
					var begin:int;
					var end:int;
					
					if(to < beginFrom) //在之前
					{
						end = endFrom+(endFrom-beginFrom);
						begin = beginFrom+(endFrom-beginFrom)
						textFlow.replaceText(begin,end,"");
					}else if(to > endFrom) //在之后
					{
						end = endFrom;
						begin = beginFrom;
						textFlow.replaceText(begin,end,"");
					}
					
					
					if(textFlow.interactionManager)
					{
						if(endFrom < dropInBegin)
						{
							begin = dropInBegin-(endFrom-beginFrom);
							end = dropInEnd-(endFrom-beginFrom);
						}else
						{
							begin = dropInBegin;
							end = dropInEnd;
						}
						if(to < beginFrom || to > endFrom)
						{
							textFlow.interactionManager.internalSelectRange(begin,end);
							textFlow.interactionManager.scrollToRange(begin,end);
						}
						else
						{
							textFlow.interactionManager.internalSelectRange(beginFrom,endFrom);
							textFlow.interactionManager.scrollToRange(beginFrom,endFrom);
						}
					}
				}
			}
		}
		
		/**
		 * 不可合并 
		 * @param operation
		 * @return 
		 * 
		 */		
		override public function merge(operation:TextOperation):TextOperation
		{
			return null;
		}
	}
}