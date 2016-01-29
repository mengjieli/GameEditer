package egret.text.utils
{
	import flash.geom.Point;
	
	import egret.text.ITextContainer;
	import egret.text.TextFlow;
	import egret.text.edit.SelectionState;
	
	/**
	 * 调整文本选中区域的相关工具方法
	 * @author dom
	 */	
	public final class NavigationUtil 
	{
		private static function validateTextRange(range:SelectionState):Boolean
		{ 
			return range.textFlow != null && range.anchorPosition != -1 && range.activePosition != -1; 
		}
		
		/** 
		 * 返回之前一个原子字符的绝对索引。
		 */
		public static function previousAtomPosition(textFlow:TextFlow, absolutePos:int):int
		{
			return textFlow.findPreviousAtomBoundary(absolutePos); 
		}
		
		
		/** 
		 * 返回下一个原子字符的绝对索引。 
		 */
		public static function nextAtomPosition(textFlow:TextFlow, absolutePos:int):int
		{
			return textFlow.findNextAtomBoundary(absolutePos);
		}
		
		/** 
		 * 返回之前一个单词的绝对索引
		 */
		public static function previousWordPosition(textFlow:TextFlow, absolutePos:int):int
		{
			return textFlow.findPreviousWordBoundary(absolutePos);
		}
		
		/** 
		 * 返回之后一个单词的绝对索引
		 */
		public static function nextWordPosition(textFlow:TextFlow, absolutePos:int):int
		{
			return textFlow.findNextWordBoundary(absolutePos);
		}
		
		private static function moveForwardHelper(range:SelectionState, extendSelection:Boolean, incrementor:Function):Boolean
		{
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			
			if (extendSelection) 
				endIndex = incrementor(textFlow, endIndex);
			else {
				if (startIndex == endIndex) 
				{
					startIndex = incrementor(textFlow, startIndex);
					endIndex = startIndex;
				}
				else if (endIndex > startIndex) 
					startIndex = endIndex;
				else
					endIndex = startIndex;
			}
			
			if (!extendSelection && (range.anchorPosition == startIndex) && (range.activePosition == endIndex))
			{
				if (startIndex < endIndex)
				{
					startIndex = Math.min(endIndex + 1, textFlow.textLength - 1);
					endIndex = startIndex;
				}else {
					endIndex = Math.min(startIndex + 1, textFlow.textLength);
					startIndex = endIndex;
				}	
			}
			return range.updateRange(startIndex,endIndex);							 	
		}
		
		private static function moveBackwardHelper(range:SelectionState, extendSelection:Boolean, incrementor:Function):Boolean
		{
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			
			if (extendSelection)	
				endIndex = incrementor(textFlow, endIndex);
			else {
				if (startIndex == endIndex) 
				{
					startIndex = incrementor(textFlow, startIndex);
					endIndex = startIndex;
				}
				else if (endIndex > startIndex) 
					endIndex = startIndex;
				else
					startIndex = endIndex;
			}
			
			if (!extendSelection && (range.anchorPosition == startIndex) && (range.activePosition == endIndex))
			{
				if (startIndex < endIndex)
				{
					endIndex = Math.max(startIndex - 1, 0);
					startIndex = endIndex;
				}else {
					startIndex = Math.max(endIndex - 1, 0);
					endIndex = startIndex;
				}	
			}
			return range.updateRange(startIndex,endIndex);
		}
		
		/**
		 * 将选中范围从当前位置设置到之后的一个字符
		 */		 
		public static function nextCharacter(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (validateTextRange(range))
			{
				moveForwardHelper(range, extendSelection, nextAtomPosition);
				return true;
			}
			return false;
		}
		
		/**
		 * 将选中范围从当前位置设置到之前的一个字符
		 */		 		 
		public static function previousCharacter(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (validateTextRange(range))
			{
				moveBackwardHelper(range, extendSelection, previousAtomPosition);
				return true;
			} 
			return false;
		} 
		/**
		 * 将选中范围从当前位置设置到之后的一个单词
		 */		 		 		 
		public static function nextWord(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (validateTextRange(range))
			{
				moveForwardHelper(range, extendSelection, nextWordPosition);
				return true;
			}
			return false;
		}
		
		/**
		 * 将选中范围从当前位置设置到之前的一个单词。
		 */				 		 		 
		public static function previousWord(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (validateTextRange(range))
			{
				moveBackwardHelper(range, extendSelection, previousWordPosition);
				return true;
			}
			return false;
		} 
		/**
		 * 将选择范围扩展到当前索引下的整个单词。
		 */		
		public static function currentWord(range:SelectionState):Boolean
		{
			if (!validateTextRange(range))
				return false;
			var textFlow:TextFlow = range.textFlow;
			var activeIndex:int = range.activePosition;
			var startIndex:int = textFlow.findWordBoundaryBeginIndex(activeIndex);
			var endIndex:int = textFlow.findWordBoundaryEndIndex(activeIndex);
			range.updateRange(startIndex,endIndex);
			return true;
		}
		
		/**
		 * 将选择范围扩到连续字母或汉字等, 该方法不同于<code>currentWord</code>方法，不会因为大小写等因素而断开选择区域。
		 * 如果双击的是双引号或单引号的索引位置，则会选择引号之内的全部文本呢。
		 * @param range
		 * @return 
		 * 
		 */		
		public static function currentContinuousCharacter(range:SelectionState):Boolean
		{
			if (!validateTextRange(range))
				return false;
			var textFlow:TextFlow = range.textFlow;
			var activeIndex:int = range.activePosition;
			var rangePoint:Point = textFlow.findContinuousRange(activeIndex);
			if(rangePoint.x == -1 || rangePoint.y == -1)
				return false;
			range.updateRange(rangePoint.x,rangePoint.y);
			return true;
		}
		
		
		/**
		 * 将选中范围从当前位置向下移动一行。
		 */		 		 		 		 		 
		public static function nextLine(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			
			endIndex = textFlow.findNextLine(endIndex);
			
			if (!extendSelection)
				startIndex = endIndex;
			
			return range.updateRange(startIndex,endIndex);			
		}
		
		/**
		 * 将选中范围从当前位置向上移动一行
		 */			 		 		 		 		 		 
		public static function previousLine(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			
			endIndex = textFlow.findPreviousLine(endIndex);
			
			if (!extendSelection)
				startIndex = endIndex;
			
			return range.updateRange(startIndex,endIndex);			
		}
		
		/**
		 * 将选中范围从当前位置向下移动一页
		 */		
		public static function nextPage(range:SelectionState,container:ITextContainer,extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			var lineIndex:int = textFlow.findLineIndexAtPosition(endIndex);
			if(lineIndex==textFlow.numLines)
			{
				endIndex = textFlow.textLength;
			}
			else
			{
				var pageLines:int = container.height/container.lineHeight;
				lineIndex += pageLines;
				if(lineIndex >= textFlow.numLines)
					lineIndex = Math.max(0,textFlow.numLines - 1);
				endIndex = textFlow.findTargetLine(endIndex,lineIndex);
			}
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);			
		}
		
		/**
		 * 将选中范围从当前位置向上移动一页
		 */		 		 		 		 		 		 		 		 
		public static function previousPage(range:SelectionState,container:ITextContainer,extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			var lineIndex:int = textFlow.findLineIndexAtPosition(endIndex);
			if(lineIndex==0)
			{
				endIndex = 0;
			}
			else
			{
				var pageLines:int = container.height / container.lineHeight;
				lineIndex -= pageLines;
				if(lineIndex<0)
					lineIndex = 0;
				endIndex = textFlow.findTargetLine(endIndex,lineIndex);
			}
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);						
		} 
		/**
		 * 将选中范围从当前位置设置到行末。
		 */			 		 		 		 		 		 		 		 		 
		public static function endOfLine(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			var curLine:int = textFlow.findLineIndexAtPosition(endIndex);
			var lineStart:int = textFlow.findStartOfLine(curLine);
			var lineText:String = textFlow.getTextOfLine(curLine);
			endIndex = lineStart + lineText.length;
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);
		}
		
		/**
		 * 将选中范围从当前位置设置到行首。
		 */			 		 		 		 		 		 		 		 		 		 
		public static function startOfLine(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			
			var curLine:int = textFlow.findLineIndexAtPosition(endIndex);
			var lineStart:int = textFlow.findStartOfLine(curLine);
			endIndex = lineStart;
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);
		} 
		/**
		 * 将选中范围从当前位置设置到文档结束。
		 */			 		 		 		 		 		 		 		 		 		 		 
		public static function endOfDocument(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var textFlow:TextFlow = range.textFlow
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			endIndex = textFlow.textLength;
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);				
		}
		
		/**
		 * 将选中范围从当前位置设置到文档的开头
		 */			 		 		 		 		 		 		 		 		 		 		 		 
		public static function startOfDocument(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			var startIndex:int = range.anchorPosition;
			var endIndex:int = 0;
			
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);				
		}
		
		/**
		 * 将选中范围从当前位置设置到段落的开始处。
		 */		 		 		 		 		 		 		 		 		 		 		 		 		 
		public static function startOfParagraph(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			var textFlow:TextFlow = range.textFlow;
			endIndex = textFlow.findStartOfParagraph(endIndex);
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);
		}
		
		/**
		 * 将选中范围从当前位置设置到段落结尾
		 */		 		 		 		 		 		 		 		 		 		 		 		 		 		 
		public static function endOfParagraph(range:SelectionState, extendSelection:Boolean = false):Boolean
		{
			if (!validateTextRange(range))
				return false;
			
			var startIndex:int = range.anchorPosition;
			var endIndex:int = range.activePosition;
			var textFlow:TextFlow = range.textFlow;
			endIndex = textFlow.findEndOfParagraph(endIndex);
			if (!extendSelection)
				startIndex = endIndex;							
			return range.updateRange(startIndex,endIndex);
		}
		/**
		 * 将选择范围扩展到当前索引下的整个段落。
		 */		
		public static function currentParagraph(range:SelectionState):Boolean
		{
			if (!validateTextRange(range))
				return false;
			var textFlow:TextFlow = range.textFlow;
			var activeIndex:int = range.absoluteStart;
			var startIndex:int = textFlow.findStartOfParagraph(activeIndex);
			var endIndex:int = textFlow.findEndOfParagraph(activeIndex);
			range.updateRange(startIndex,endIndex);
			return true;

		}
		
		private static function clampToFit(range:SelectionState, endPos:int):void
		{
			if (endPos < 0)
				endPos = 0;
			range.anchorPosition = Math.min(range.anchorPosition, endPos);
			range.activePosition = Math.min(range.activePosition, endPos); 
		}
		
	}
}
