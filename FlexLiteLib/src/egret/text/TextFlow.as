package egret.text
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TabAlignment;
	import flash.text.engine.TabStop;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import egret.text.edit.ISelectionManager;
	import egret.text.events.TextFlowEvent;
	import egret.text.utils.CharacterUtil;
	import egret.text.utils.TextLineUtil;
	import egret.utils.Recycler;
	
	/**
	 * 文本内容发生改变，外部容器应监听此事件触发重新布局。
	 */		
	[Event(name="textChangd", type="egret.text.events.TextFlowEvent")]
	/**
	 * 文本行数据内容更新，外部通过监听此事件改变渲染风格。
	 */		
	[Event(name="textChanging", type="egret.text.events.TextFlowEvent")]
	/**
	 * 设置text的时候会抛出此事件
	 */		
	[Event(name="textInited", type="egret.text.events.TextFlowEvent")]
	/**
	 * 设置text的且更新文本内容之前时候会抛出此事件
	 */		
	[Event(name="textIniting", type="egret.text.events.TextFlowEvent")]
	/**
	 * 文本行对象销毁事件，外部容器应监听此事件从而从显示列表移除关联的TextLine对象。
	 */	
	[Event(name="textLineRelease", type="egret.text.events.TextFlowEvent")]
	/**
	 * 文本选中区域改变事件
	 */	
	[Event(name="selectionChange", type="egret.text.events.SelectionEvent")]
	
	/**
	 * 文本流。封装FTE的各种操作，解析大数据文本。
	 * @author dom
	 */
	public class TextFlow extends EventDispatcher
	{
		public function TextFlow()
		{
			super();
		}
		
		private var _interactionManager:ISelectionManager;
		/**
		 * 与此文本流对象关联的交互管理器
		 */
		public function get interactionManager():ISelectionManager
		{
			return _interactionManager;
		}
		public function set interactionManager(value:ISelectionManager):void
		{
			_interactionManager = value;
		}
		
		private var _defaultFormat:ElementFormat;
		/**
		 * 默认文本样式
		 */
		public function get defaultFormat():ElementFormat
		{
			return _defaultFormat;
		}
		
		public function set defaultFormat(value:ElementFormat):void
		{
			if(_defaultFormat==value)
				return;
			_defaultFormat = value;
			textElement.elementFormat = value;
		}
		
		private var tabWidth:Number = -1;
		private var _tabStop:int = 8;
		/**
		 * 设置一个tab表示多少个空格的长途。默认是8 
		 */
		public function get tabStop():int
		{
			return _tabStop;
		}
		
		public function set tabStop(value:int):void
		{
			if(value == 0)
				value = 1;
			if(_tabStop == value) return;
			_tabStop = value;
			var tabSpace:String = "";
			for(var i:int = 0;i<_tabStop;i++)
			{
				tabSpace += " ";
			}
			textElement.text = tabSpace;
			textBlock.content = textElement;
			var textLine:TextLine = freeTextLines.pop();
			if(!textLine)
			{
				textLine = textLineRecycler.get();
			}
			if(textLine)
			{
				textLine = textBlock.recreateTextLine(textLine);
			}
			else
			{
				textLine = textBlock.createTextLine();
			}
			var tempBounds:Rectangle = textLine.getAtomBounds(textLine.atomCount-1);
			tabWidth = tempBounds.x+tempBounds.width;
		}
		
		private var _text:String = "";
		
		private var textChanged:Boolean = false;
		
		public function get text():String
		{
			if(textChanged)
			{
				textChanged = false;
				_text = joinLineBreaks();
			}
			return _text;
		}
		
		public function set text(value:String):void
		{
			if(!value)
				value = "";
			if(_text==value)
				return;
			var event:TextFlowEvent = new TextFlowEvent(TextFlowEvent.TEXT_INITING);
			event.newText = value;
			dispatchEvent(event);
			
			releaseAllTextLines();
			textChanged = false;
			_textLength = value.length;
			_text = value;
			var result:Array = parseLineBreak(_text);
			paragraphStartList = [];
			lastEndLineIndex = 0;
			lastStartLineIndex = 0;
			paragraphTextList = result[0];
			paragraphBreakList = result[1];
			event = new TextFlowEvent(TextFlowEvent.TEXT_INITED);
			dispatchEvent(event);
		}
		
		private var _textLength:int = 0;
		/**
		 * 文本长度
		 */		
		public function get textLength():int
		{
			return _textLength;
		}
		
		private var lineWidthTable:Array = [];
		
		private var lineWidthChanged:Boolean = false;
		
		private var _textWidth:Number = 0;
		/**
		 * 文本宽度
		 */		
		public function get textWidth():Number
		{
			if(lineWidthChanged)
			{
				_textWidth = getTextWidth();
			}
			return _textWidth;
		}
		
		private function getTextWidth():Number
		{
			lineWidthChanged = false;
			var width:Number = 0;
			for each(var lineWidth:Number in lineWidthTable)
			{
				if(lineWidth>width)
					width = lineWidth;
			}
			return width;
		}
		
		/**
		 * 段落文本内容列表，内容不包含换行符。
		 */		
		private var paragraphTextList:Vector.<String> = new Vector.<String>();
		/**
		 * 每段结尾的换行符。
		 */		
		private var paragraphBreakList:Vector.<String> = new Vector.<String>();
		/**
		 * 每个段落在完整文本中的起始索引。
		 */		
		private var paragraphStartList:Array = [];
		
		/**
		 * 解析换行符
		 */		
		private function parseLineBreak(text:String):Array
		{
			var lineList:Vector.<String> = new Vector.<String>();
			var lineBreaks:Vector.<String> = new Vector.<String>();
			var index:int = 0;
			var t:Number = getTimer();
			var rnLines:Array = text.split("\r\n");
			for each(var rnLine:String in rnLines)
			{
				var rLines:Array = rnLine.split("\r");
				for each(var rLine:String in rLines)
				{
					var nLines:Array = rLine.split("\n");
					for each(var line:String in nLines)
					{
						lineList.push(line);
						lineBreaks.push("\n");
					}
					lineBreaks[lineBreaks.length-1] = "\r";
				}
				lineBreaks[lineBreaks.length-1] = "\r\n";
			}
			if(lineBreaks.length>0)
				lineBreaks[lineBreaks.length-1] = "";
			//			trace("parseLineBreak:"+(getTimer()-t)+"ms");
			return [lineList,lineBreaks];
		}
		
		private function joinLineBreaks():String
		{
			var lineList:Vector.<String> = paragraphTextList;
			var breakList:Vector.<String> = paragraphBreakList;
			var length:int = lineList.length;
			var text:String = "";
			for(var i:int=0;i<length;i++)
			{
				text += lineList[i]+breakList[i];
			}
			return text;
		}
		/**
		 * 获取指定范围的文本内容
		 */		
		public function getText(startIndex:int,endIndex:int):String
		{
			if(paragraphTextList.length==0)
				return ""
			var beginIndex:int = Math.min(startIndex,endIndex);
			endIndex = Math.max(startIndex,endIndex);
			if(textChanged)
			{
				var startLineIndex:int = findLineIndexAtPosition(beginIndex);
				var endLineIndex:int = findLineIndexAtPosition(endIndex);
				var text:String = "";
				for(var i:int=startLineIndex;i<=endLineIndex;i++)
				{
					text += paragraphTextList[i]+paragraphBreakList[i];
				}
				var startPos:int = findStartOfLine(startLineIndex);
				var subText:String = text.substring(beginIndex-startPos,endIndex-startPos);
			}
			else
			{
				subText = _text.substring(beginIndex,endIndex);
			}
			
			return subText;
		}
		/**
		 * 替换指定范围的文本内容，并返回被替换的文本。
		 */		
		public function replaceText(startIndex:int,endIndex:int,newText:String):String
		{
			var t:Number = getTimer();
			var beginIndex:int = Math.min(startIndex,endIndex);
			endIndex = Math.max(startIndex,endIndex);
			
			var tempStr:String = newText.replace(/\n/g,"\\n");
			tempStr = tempStr.replace(/\r/g,"\\r");
			if(!newText)
				newText = "";
			var newTextCache:String = newText;
			var evt:TextFlowEvent = new TextFlowEvent(TextFlowEvent.TEXT_CHANGING);
			evt.startIndex = startIndex;
			evt.endIndex = endIndex;
			evt.newText = newTextCache;
			dispatchEvent(evt);
			var startLineIndex:int = findLineIndexAtPosition(beginIndex);
			var endLineIndex:int = findLineIndexAtPosition(endIndex);
			//清理失效的TextLine对象
			var maxIndex:int = 0;
			var freeList:Array = [];
			for(var textLineIndex:* in textLines)
			{
				if(textLineIndex>=startLineIndex&&textLineIndex<=endLineIndex)
					freeList.push(textLineIndex);
				else
					maxIndex = Math.max(maxIndex,textLineIndex);
			}
			for each(textLineIndex in freeList)
			{
				freeTextLineForReuseAt(textLineIndex);
			}
			textLines.length = maxIndex+1;//把length调整到实际位置，否则下一行的splice方法将会创建无数个undefined数组元素，导致性能急剧下降。
			
			var t1:Number = getTimer();
			
			//解析插入的文本为新的行列表
			var startLineInViewPos:int = findStartOfLine(lastStartLineIndex);
			var startPos:int = findStartOfLine(startLineIndex);
			var endPos:int = findStartOfLine(endLineIndex+1);
			var oldText:String = getText(startPos,endPos);
			
			
			
			newText = oldText.substring(0,beginIndex-startPos)+newText+oldText.substring(endIndex-startPos);
			
			var result:Array = parseLineBreak(newText);
			var lineList:Vector.<String> = result[0];
			var breakList:Vector.<String> = result[1];
			
			/*
			如果在不是最后一行的行尾按回车。那本行的新文本应该是 text\n\n，拆分之后的行数据应该是 [text,空,空]，拆分之后的断行数据应该是[\n,\n,空]
			lineList[lineList.length-1]==""组合的话，就应该把最后一个空字符行删掉。然后再拼合之后的行。
			endLineIndex != numLines-1但是如果在最后一行的行尾按回车。那本行的新文本应该是text\n，拆分之后的数据航应该是[text,空]，拆分之后的断行数据应该是[\n,空]
			此时就不应该删掉最后一行。因为要创建一个新的显示行。
			*/
			if(lineList.length>0 && (lineList[lineList.length-1]=="" && endLineIndex != numLines-1))
			{
				lineList.pop();
				breakList.pop();
			}
			
			var t2:Number = getTimer();
			
			//将新行列表与旧行合并
			var newNumLines:int = lineList.length;
			
			var lineOffset:int = newNumLines-(endLineIndex+1-startLineIndex);
			var maxLineIndex:int = paragraphTextList.length+lineOffset-1;
			if(maxLineIndex<0)
				maxLineIndex=0;
			lastStartLineIndex = Math.min(maxLineIndex,lastStartLineIndex);
			lastEndLineIndex = Math.min(maxLineIndex,lastEndLineIndex);
			//之前的可视区域索引全部失效
			var allPositionInvalid:Boolean = (startLineIndex<=lastStartLineIndex)&&(endLineIndex>=lastEndLineIndex);
			if(allPositionInvalid)
			{
				startLineInViewPos = startPos;
			}
			var deleteLength:int = endLineIndex-startLineIndex+1-newNumLines;
			if(deleteLength>0)
			{
				paragraphTextList.splice(startLineIndex+newNumLines,deleteLength);
				paragraphBreakList.splice(startLineIndex+newNumLines,deleteLength);
				lineWidthTable.splice(startLineIndex+newNumLines,deleteLength);
				textLines.splice(startLineIndex+newNumLines,deleteLength);
			}
			paragraphStartList.length = startLineIndex;
			var lineIndex:int = startLineIndex;
			for(var i:int=0;i<newNumLines;i++)
			{
				var line:String = lineList[i];
				var breakStr:String = breakList[i];
				if(lineIndex<=endLineIndex)
				{
					paragraphTextList[lineIndex] = line;
					paragraphBreakList[lineIndex] = breakStr;
					delete lineWidthTable[lineIndex];
				}
				else
				{
					paragraphTextList.splice(lineIndex,0,line);
					paragraphBreakList.splice(lineIndex,0,breakStr);
					textLines.splice(lineIndex,0,null);
					delete textLines[lineIndex];
					lineWidthTable.splice(lineIndex,0,null);
					delete lineWidthTable[lineIndex];
				}
				if(allPositionInvalid&&lineIndex<lastStartLineIndex)
				{
					startLineInViewPos += line.length+breakStr.length;
				}
				lineIndex++;
			}
			
			var offset:int = newText.length-oldText.length;
			_textLength += offset;
			textChanged = true;
			_text = "";
			
			var t3:Number = getTimer();
			if(paragraphTextList.length>0)
			{
				if(allPositionInvalid||startLineIndex>lastStartLineIndex)
				{
					var pos:int = startLineInViewPos;
					for(lineIndex = lastStartLineIndex;lineIndex<=lastEndLineIndex;lineIndex++)
					{
						paragraphStartList[lineIndex] = pos;
						pos += paragraphTextList[lineIndex].length+paragraphBreakList[lineIndex].length;
					}
				}
				else
				{
					var targetLineIndex:int = newNumLines+startLineIndex;
					var targetLinePos:int = endPos+offset;
					paragraphStartList[targetLineIndex] = targetLinePos;
					pos = targetLinePos;
					for(lineIndex=targetLineIndex-1;lineIndex>=lastStartLineIndex;lineIndex--)
					{
						pos -= paragraphTextList[lineIndex].length+paragraphBreakList[lineIndex].length;
						paragraphStartList[lineIndex] = pos;
					}
					pos = targetLinePos;
					for(lineIndex=targetLineIndex+1;lineIndex<=lastEndLineIndex;lineIndex++)
					{
						pos += paragraphTextList[lineIndex-1].length+paragraphBreakList[lineIndex-1].length;
						paragraphStartList[lineIndex] = pos;
					}
				}
			}
			
			var t4:Number = getTimer();
			
			lineWidthChanged = true;
			evt = new TextFlowEvent(TextFlowEvent.TEXT_CHANGED);
			evt.startIndex = startIndex;
			evt.endIndex = endIndex;
			evt.newText = newTextCache;
			dispatchEvent(evt);
			//			trace("replaceText.t1-t0:"+(t1-t)+"ms");
			//			trace("replaceText.t2-t1:"+(t2-t1)+"ms");
			//			trace("replaceText.t3-t2:"+(t3-t2)+"ms");
			//			trace("replaceText.t4-t3:"+(t4-t3)+"ms");
			//			trace("replaceText.all:"+(getTimer()-t)+"ms");
			
			return oldText.substring(beginIndex-startPos,endIndex-startPos);
		}
		
		/**
		 * 实际创建的TextLine对象列表,索引为行号。
		 */		
		private var textLines:Array = [];
		private var textLineRecycler:Recycler = new Recycler();
		private var textElement:TextElement = new TextElement();
		private var textBlock:TextBlock = new TextBlock();
		private var tabStops:Vector.<TabStop> = new Vector.<TabStop>();
		
		/**
		 * 获取指定行对应的一个TextLine对象。注意：空行始终会返回null。
		 * @param lineIndex 行号索引。从0开始。
		 * @param autoCreate 若不存在，就创建一个新的TextLine对象，默认值true。
		 */		
		public function getTextLineAt(lineIndex:int,autoCreate:Boolean=true):TextLine
		{
			var textLine:TextLine = textLines[lineIndex];
			if(textLine||!autoCreate)
			{
				return textLine;
			}
			if(lineIndex<0||lineIndex>=paragraphTextList.length)
				return null;
			var text:String = paragraphTextList[lineIndex];
			if(!text)
			{
				return null;
			}
			if(contentElementFunction == null)
			{
				contentElementFunction = createContentElement;
			}
			textBlock.content = contentElementFunction(text,lineIndex);
			//制表符的数量
			if(tabWidth != -1)
			{
				var tabCount:int = 0;
				for(var i:int = 0;i<text.length;i++)
				{
					if(text.charAt(i) == "\t")
						tabCount++;
				}
				updateTabStops(tabCount);
				textBlock.tabStops = tabStops;
			}else
			{
				textBlock.tabStops = null;
			}
			textLine = freeTextLines.pop();
			if(!textLine)
			{
				textLine = textLineRecycler.get();
			}
			if(textLine)
			{
				textLine.visible = true;
				textLine = textBlock.recreateTextLine(textLine);
			}
			else
			{
				textLine = textBlock.createTextLine();
			}
			if(textLine)
			{
				textLines[lineIndex] = textLine;
				var width:Number = TextLineUtil.getTextWidth(textLine);
				if(width>_textWidth)
					_textWidth = width;
				lineWidthTable[lineIndex] = width;
			}
			return textLine;
		}
		
		/**
		 * 创建内容元素的回调，如createContentElement(text:String,lineIndex:int):ContentElement
		 * 其中text是要创建的行或段落，lineIndex是行所在的索引。
		 */		
		public var contentElementFunction:Function;
		
		private function createContentElement(text:String,lineIndex:int):ContentElement
		{
			textElement.text = text;
			return textElement;
		}
		
		private function updateTabStops(tabCount:int):void
		{
			if(tabCount+1>tabStops.length)
			{
				var delta:int = tabCount+1-tabStops.length;
				for(var i:int = 0;i<delta;i++)
				{
					tabStops.push(new TabStop());
				}
			}
			for(i = 0;i<tabStops.length;i++)
			{
				tabStops[i].alignment = TabAlignment.START;
				tabStops[i].position = i*tabWidth;
			}
		}
		/**
		 * 彻底释放所有已经创建的TextLine对象。
		 */		
		public function releaseAllTextLines():void
		{
			var list:Array = [];
			for each(var textLine:TextLine in textLines)
			{
				if(textLine)
				{
					textLineRecycler.push(textLine);
					list.push(textLine);
					if(textLine.parent)
						textLine.parent.removeChild(textLine);
				}
			}
			textLines = [];
			list = list.concat(cleanAllFreeTextLines());
			var evt:TextFlowEvent = new TextFlowEvent(TextFlowEvent.TEXT_LINE_RELEASE);
			evt.textLines = list;
			dispatchEvent(evt);
		}
		/**
		 * 彻底释放指定行对应的TextLine对象并返回。若该行还未创建TextLine对象，将返回null。
		 */		
		public function releaseTextLineAt(lineIndex:int):TextLine
		{
			var textLine:TextLine = textLines[lineIndex];
			delete textLines[lineIndex];
			if(textLine)
			{
				textLineRecycler.push(textLine);
				if(textLine.parent)
					textLine.parent.removeChild(textLine);
			}
			return textLine;
		}
		/**
		 * 被标记为可以复用的TextLine对象列表。
		 */		
		private var freeTextLines:Array = [];
		
		/**
		 * 标记某行的TextLine对象可以用于循环复用。
		 */		
		private function freeTextLineForReuseAt(lineIndex:int):TextLine
		{
			var textLine:TextLine = textLines[lineIndex];
			delete textLines[lineIndex];
			if(textLine)
			{
				freeTextLines.push(textLine);
				textLine.visible = false;
			}
			return textLine;
		}
		/**
		 * 清理所有不在使用的TextLine对象
		 */		
		private function cleanAllFreeTextLines(event:TimerEvent=null):Array
		{
			var list:Array = freeTextLines;
			freeTextLines = [];
			for each(var textLine:TextLine in list)
			{
				textLineRecycler.push(textLine);
			}
			if(event)
			{
				var evt:TextFlowEvent = new TextFlowEvent(TextFlowEvent.TEXT_LINE_RELEASE);
				evt.textLines = list;
				dispatchEvent(evt);
			}
			return list;
		}
		/**
		 * 上一次的文本可见行索引范围
		 */		
		private var lastStartLineIndex:int = 0;
		private var lastEndLineIndex:int = 0;
		private var cleanTimer:Timer;
		/**
		 * 更新处于视图中的文本行索引范围
		 * @param startLineIndex 可见文本行起始索引
		 * @param endLineIndex 可见文本行的结束索引(包括)
		 */		
		public function updateTextLinesInView(startLineIndex:int,endLineIndex:int):void
		{
			var virtualLineIndices:Vector.<int> = new Vector.<int>();
			for(var i:int=startLineIndex;i<endLineIndex;i++)
			{
				virtualLineIndices.push(i);
			}
			var textLine:TextLine;
			for(var lineIndex:* in textLines)
			{
				if(virtualLineIndices.indexOf(lineIndex)==-1)
				{
					textLine = freeTextLineForReuseAt(lineIndex);
				}
			}
			for(var index:int=startLineIndex;index<endLineIndex;index++)
			{
				textLine = getTextLineAt(index);
			}
			if(freeTextLines.length>0)
			{
				if(!cleanTimer)
				{
					cleanTimer = new Timer(3000,1);
					cleanTimer.addEventListener(TimerEvent.TIMER,cleanAllFreeTextLines);
				}
				//为了提高持续滚动过程中的性能，防止反复地添加移除子项，这里不直接清理而是延迟后在滚动停止时清理一次。
				cleanTimer.reset();
				cleanTimer.start();
			}
			
			var pos:int = findStartOfLine(lastStartLineIndex);
			for(var j:int = lastStartLineIndex-1;j>=startLineIndex;j--)
			{
				pos -= paragraphTextList[j].length+paragraphBreakList[j].length;
				paragraphStartList[j] = pos;
			}
			pos = findStartOfLine(lastEndLineIndex);
			for(j=lastEndLineIndex+1;j<=endLineIndex;j++)
			{
				pos += paragraphTextList[j-1].length+paragraphBreakList[j-1].length;
				paragraphStartList[j] = pos;
			}
			lastStartLineIndex = startLineIndex;
			lastEndLineIndex = endLineIndex;
		}
		
		/**
		 * 文本行数
		 */		
		public function get numLines():int
		{
			return paragraphTextList.length;
		}
		/**
		 * 获取指定行的文本内容，不包含换行符。
		 */		
		public function getTextOfLine(lineIndex:int):String
		{
			if(lineIndex<0||lineIndex>=paragraphTextList.length)
				return "";
			return paragraphTextList[lineIndex];
		}
		/**
		 * 获取指定索引字符的字符代码
		 */		
		public function getCharCodeAtPosition(charIndex:int):Number
		{
			var lineIndex:int = findLineIndexAtPosition(charIndex);
			var text:String = getTextOfLine(lineIndex);
			if(!text)
				return -1;
			var startPosition:int = findStartOfLine(lineIndex);
			return text.charCodeAt(charIndex-startPosition);
		}
		/**
		 * 获取指定行号的起始字符串索引
		 */		
		public function findStartOfLine(lineIndex:int):int
		{
			if(lineIndex<=0)
				return 0;
			if(lineIndex>=paragraphTextList.length)
				return _textLength;
			if(paragraphStartList[lineIndex]===undefined)
				updateParagraphStartList(lineIndex);
			return paragraphStartList[lineIndex];
		}
		/**
		 * 更新段落起始索引列表数据到指定索引行处。
		 */		
		private function updateParagraphStartList(lineIndex:int):void
		{
			var t:Number = getTimer();
			var startList:Array = paragraphStartList;
			if(lineIndex<lastStartLineIndex)
			{
				var startLineIndex:int = lastStartLineIndex;
				for(var i:int=lineIndex;i<startLineIndex;i++)
				{
					if(startList[i]!==undefined)
					{
						startLineIndex = i;
						break;
					}
				}
				var pos:int = startLineIndex==0?0:startList[startLineIndex];
				for(var j:int = startLineIndex-1;j>=lineIndex;j--)
				{
					pos -= paragraphTextList[j].length+paragraphBreakList[j].length;
					startList[j] = pos;
				}
			}
			else
			{
				var startEndIndex:int = lastEndLineIndex;
				for(i=lineIndex;i>startEndIndex;i--)
				{
					if(startList[i]!==undefined)
					{
						startEndIndex = i;
						break;
					}
				}
				pos = startEndIndex==0?0:startList[startEndIndex];
				for(j=startEndIndex+1;j<=lineIndex;j++)
				{
					pos += paragraphTextList[j-1].length+paragraphBreakList[j-1].length;
					startList[j] = pos;
				}
			}
			t = getTimer()-t;
		}
		/**
		 * 获取指定索引处的文本所在的行号。
		 */		
		public function findLineIndexAtPosition(charIndex:int):int
		{
			if(charIndex<=0)
				return 0;
			if(charIndex>=_textLength)
				return paragraphTextList.length-1;
//			var t:int = getTimer();
			var lineIndex:int = findIndexByPage(charIndex,lastStartLineIndex,lastEndLineIndex);
//			t = getTimer()-t;
//			if(t>1)
//			{
				//				trace("findLineIndexAtPosition():"+t+"ms");
//			}
			return lineIndex;
		}
		
		private function findIndexByPage(charIndex:int,startLineIndex:int,endLineIndex:int):int
		{
			var startPos:int = findStartOfLine(startLineIndex);
			var endPos:int = findStartOfLine(endLineIndex+1);
			if(charIndex>=startPos&&charIndex<endPos)
			{
				return findIndexAt(charIndex,startLineIndex,endLineIndex);
			}
			var numLines:int = Math.max(50,endLineIndex-startLineIndex+1);
			if(charIndex<startPos)
			{
				if(startLineIndex>0)
				{
					endLineIndex = startLineIndex;
					startLineIndex = Math.max(0,startLineIndex-numLines);
					return findIndexByPage(charIndex,startLineIndex,endLineIndex);
				}
			}
			else
			{
				var maxLength:int = paragraphTextList.length-1;
				if(endLineIndex<maxLength)
				{
					startLineIndex = endLineIndex;
					endLineIndex = Math.min(maxLength,endLineIndex+numLines);
					return findIndexByPage(charIndex,startLineIndex,endLineIndex);
				}
			}
			return -1;
		}
		
		/**
		 * 折半查找法寻找指定位置的行号
		 */		
		private function findIndexAt(charIndex:int, i0:int, i1:int):int
		{
			var index:int = (i0 + i1) / 2;
			var lineStart:int = findStartOfLine(index);
			var lineEnd:int = findStartOfLine(index+1);
			if ((charIndex >= lineStart) && (charIndex < lineEnd))
				return index;
			else if (i0 == i1)
				return -1;
			else if (charIndex < lineStart)
				return findIndexAt(charIndex, i0, Math.max(i0, index-1));
			else 
				return findIndexAt(charIndex, Math.min(index+1, i1), i1);
		} 
		
		/**
		 * @copy flash.text.engine.TextBlock#findPreviousAtomBoundary()
		 */
		public function findPreviousAtomBoundary(beforeCharIndex:int):int
		{
			return findPreviousBoundary(beforeCharIndex,false);
		}
		/**
		 * @copy flash.text.engine.TextBlock#findPreviousWordBoundary()
		 */
		public function findPreviousWordBoundary(beforeCharIndex:int,forDelete:Boolean=false):int
		{
			return findPreviousBoundary(beforeCharIndex,true,forDelete);
		}
		
		private function findPreviousBoundary(beforeCharIndex:int,findWord:Boolean,forDelete:Boolean=false):int
		{
			if(beforeCharIndex==0)
				return 0;
			var lineIndex:int = findLineIndexAtPosition(beforeCharIndex);
			var startIndex:int = findStartOfLine(lineIndex);
			var text:String = getTextOfLine(lineIndex);
			if(startIndex==beforeCharIndex)
			{
				lineIndex--;
				text = getTextOfLine(lineIndex);
				startIndex = findStartOfLine(lineIndex);
				return startIndex+text.length;
			}
			var textLine:TextLine = getTextLineAt(lineIndex);
			var atomIndex:int = textLine.getAtomIndexAtCharIndex(beforeCharIndex-startIndex);
			if(atomIndex==-1)
				atomIndex = textLine.atomCount-1;
			else
				atomIndex--;
			if(findWord)
			{
				
				while(atomIndex>=0)
				{
					if(getAtomWordBoundaryOnLeft(atomIndex,textLine,text,forDelete))
					{
						break;
					}
					atomIndex--;
				}
			}
			return startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);
		}
		/**
		 * @copy flash.text.engine.TextBlock#findNextAtomBoundary()
		 */
		public function findNextAtomBoundary(afterCharIndex:int):int
		{
			var index:int = findNextBoundary(afterCharIndex,false);
			//			trace(afterCharIndex,index);
			return index;
		}
		/**
		 * @copy flash.text.engine.TextBlock#findNextWordBoundary()
		 */
		public function findNextWordBoundary(afterCharIndex:int,forDelete:Boolean=false):int
		{
			return findNextBoundary(afterCharIndex,true,forDelete);
		}
		
		private function findNextBoundary(afterCharIndex:int,word:Boolean,forDelete:Boolean=false):int
		{
			if(afterCharIndex>=textLength)
				return textLength;
			var lineIndex:int = findLineIndexAtPosition(afterCharIndex);
			var startIndex:int = findStartOfLine(lineIndex);
			var text:String = getTextOfLine(lineIndex);
			if(startIndex+text.length<=afterCharIndex)
			{
				lineIndex++;
				return findStartOfLine(lineIndex);
			}
			var textLine:TextLine = getTextLineAt(lineIndex);
			var atomIndex:int = textLine.getAtomIndexAtCharIndex(afterCharIndex-startIndex);
			if(atomIndex==textLine.atomCount-1)
			{
				return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
			}
			atomIndex++;
			if(word)
			{
				var maxIndex:int = textLine.atomCount-1;
				while(atomIndex<=maxIndex)
				{
					if(getAtomWordBoundaryOnLeft(atomIndex,textLine,text,forDelete))
					{
						break;
					}
					if(atomIndex==maxIndex)
					{//最后一个字符的左边也不是单词分割处，直接返回最后一个字符的结尾。
						return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
					}
					atomIndex++;
				}
			}
			return startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);
		}
		
		/**
		 * 得到当前索引处的连续范围。
		 * @param charIndex
		 * @return 
		 * 
		 */		
		public function findContinuousRange(charIndex:int):Point
		{
			var point:Point = new Point(-1,-1);
			if(charIndex == -1) return point;
			var start:int = charIndex;
			var end:int = charIndex+1;
			var selectedStr:Boolean = false;
			//选中引号内的
			if(text.charAt(charIndex) == "\"" || text.charAt(charIndex) == "\'")
			{
				var numDouble:int = 0;
				var numSingle:int = 0;
				var indexDouble:int = charIndex;
				var indexSingle:int = charIndex;
				for(var i:int = 0;i<=charIndex;i++)
				{
					if(text.charAt(i) == "\"")
					{
						numDouble++;
						if(i!= charIndex)
						{
							indexDouble = i;
						}
					}
					if(text.charAt(i) == "'")
					{
						numSingle++;
						if(i!= charIndex)
						{
							indexSingle = i;
						}
					}
				}
				end = charIndex;
				if(text.charAt(charIndex) == "\"" && numDouble%2 == 0)
				{
					start = indexDouble+1;
					if(start != end)
						selectedStr = true;
				}
				if(text.charAt(charIndex) == "'" && numSingle%2 == 0)
				{
					start = indexSingle+1;
					if(start != end)
						selectedStr = true;
				}
			}
			if(!selectedStr) //如果没有选择上字符串
			{
				if(checkIsWord(text.charAt(charIndex)))
				{
					
					//找到起始字母
					for(i = start;i>=0;i--)
					{
						if(!checkIsWord(text.charAt(i)))
						{
							start = i+1;
							break;
						}else
						{
							start = i;
						}
					}
					//找结束字母
					for(i = end;i<=text.length;i++)
					{
						if(i<text.length && !checkIsWord(text.charAt(i)))
						{
							end = i;
							break;
						}else
						{
							end = i;
						}
					}
				}else if(text.charAt(charIndex) != "\r" && text.charAt(charIndex) != "\n")
				{
					start = charIndex;
					end = charIndex+1;
				}
			}
			point.x = start;
			point.y = end;
			return point;
		}
		
		/**
		 * 检查是否是字母(目前只支持英文的检测)
		 * @param char
		 * @return 
		 * 
		 */		
		private function checkIsWord(char:String):Boolean
		{
			var charCode:int = char.charCodeAt(0);
			//英文字母数字和下划线
			if((charCode >= 65 && charCode<=90) || 
				(charCode >= 97 && charCode <= 122) ||
				(charCode >= 48 && charCode <= 57) ||
				charCode == 95
			)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 获取当前索引处单词的起始索引。
		 */	
		public function findWordBoundaryBeginIndex(charIndex:int):int
		{
			if(charIndex==0)
				return 0;
			var lineIndex:int = findLineIndexAtPosition(charIndex);
			var startIndex:int = findStartOfLine(lineIndex);
			var text:String = getTextOfLine(lineIndex);
			if(startIndex==charIndex)
			{
				return startIndex;
			}
			var textLine:TextLine = getTextLineAt(lineIndex);
			var atomIndex:int = textLine.getAtomIndexAtCharIndex(charIndex-startIndex);
			if(atomIndex==-1)
			{
				return startIndex+text.length;
			}
			while(atomIndex>=0)
			{
				if(getAtomWordBoundaryOnLeft(atomIndex,textLine,text))
				{
					break;
				}
				atomIndex--;
			}
			return startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);			
		}
		/**
		 * 获取当前索引处单词的结束索引(不包括)。
		 */		
		public function findWordBoundaryEndIndex(charIndex:int):int
		{
			if(charIndex>=textLength)
				return textLength;
			var lineIndex:int = findLineIndexAtPosition(charIndex);
			var startIndex:int = findStartOfLine(lineIndex);
			var text:String = getTextOfLine(lineIndex);
			if(startIndex+text.length<=charIndex)
			{
				lineIndex++;
				return findStartOfLine(lineIndex);
			}
			var textLine:TextLine = getTextLineAt(lineIndex);
			var atomIndex:int = textLine.getAtomIndexAtCharIndex(charIndex-startIndex);
			if(atomIndex==textLine.atomCount-1)
			{
				return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
			}
			atomIndex++;
			var maxIndex:int = textLine.atomCount-1;
			while(atomIndex<=maxIndex)
			{
				if(getAtomWordBoundaryOnLeft(atomIndex,textLine,text))
				{
					break;
				}
				if(atomIndex==maxIndex)
				{//最后一个字符的左边也不是单词分割处，直接返回最后一个字符的结尾。
					return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
				}
				atomIndex++;
			}
			return startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);
		}
		/**
		 * 覆盖原生的getAtomWordBoundaryOnLef()方法，将“.”也作为一个分隔符。
		 */		
		private function getAtomWordBoundaryOnLeft(atomIndex:int,textLine:TextLine,text:String,forDelete:Boolean=false):Boolean
		{
			var result:Boolean = textLine.getAtomWordBoundaryOnLeft(atomIndex);
			var charIndex:int = textLine.getAtomTextBlockBeginIndex(atomIndex);
			var charCode:int = text.charCodeAt(charIndex);
			if(result)
			{
				if(CharacterUtil.isWhitespace(charCode))
				{
					if(atomIndex>0)
					{
						charIndex = textLine.getAtomTextBlockBeginIndex(atomIndex-1);
						var prevCharCode:int = text.charCodeAt(charIndex);
						if(CharacterUtil.isWhitespace(prevCharCode))
							return false;
					}
				}
			}
			else if(!forDelete)
			{
				if(charCode==46)//是“.”字符
					return true;
				if(atomIndex>0)
				{
					charIndex = textLine.getAtomTextBlockBeginIndex(atomIndex-1);
					prevCharCode = text.charCodeAt(charIndex);
					if(prevCharCode==46)
						return true;
				}
				if(CharacterUtil.isUpperCaseLetter(charCode)&&atomIndex<textLine.atomCount-1)
				{
					charIndex = textLine.getAtomTextBlockBeginIndex(atomIndex+1);
					var nextCharCode:int = text.charCodeAt(charIndex);
					if(CharacterUtil.isLowerCaseLetter(nextCharCode))
						return true;
				}
			}
			return result;
		}
		/**
		 * 获取索引所在段落的起始索引。
		 */		
		public function findStartOfParagraph(charIndex:int):int
		{
			var lineIndex:int = findLineIndexAtPosition(charIndex);
			return findStartOfLine(lineIndex);
		}
		/**
		 * 获取索引所在段落的结束索引。
		 */		
		public function findEndOfParagraph(charIndex:int):int
		{
			var lineIndex:int = findLineIndexAtPosition(charIndex);
			if(lineIndex>=numLines-1)
				return textLength;
			return findStartOfLine(lineIndex+1);
		}
		
		/**
		 * 获取索引所在行的下一行在当前x轴位置上的字符索引。
		 */		
		public function findNextLine(charIndex:int):int
		{
			var lineIndex:int = findLineIndexAtPosition(charIndex)+1;
			if(lineIndex>=numLines)
			{
				return textLength;
			}
			
			return findTargetLine(charIndex,lineIndex);
		}
		/**
		 * 获取索引所在行的下一行在当前x轴位置上的字符索引。
		 */		
		public function findPreviousLine(charIndex:int):int
		{
			var lineIndex:int = findLineIndexAtPosition(charIndex)-1;
			if(lineIndex<0)
			{
				return 0;
			}
			return findTargetLine(charIndex,lineIndex);
		}
		/**
		 * 获取从索引所在行跳转到指定行的字符串索引。
		 */		
		public function findTargetLine(charIndex:int,lineIndex:int):int
		{
			var x:Number = caculateXPosition(charIndex);
			var startIndex:int = findStartOfLine(lineIndex);
			var textLine:TextLine = getTextLineAt(lineIndex);
			if(!textLine)
			{
				return startIndex;
			}
			var pos:Point = textLine.localToGlobal(new Point(x,0));
			var atomIndex:int = textLine.getAtomIndexAtPoint(pos.x,pos.y);
			if(atomIndex==-1)
			{
				if(x<textLine.x)
				{
					atomIndex = 0;
					return startIndex;
				}
				else
				{
					atomIndex = textLine.atomCount-1;
					return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
				}
			}
			var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
			if(x<bounds.x+bounds.width*0.5)
			{
				return startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);
			}
			else
			{
				return startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
			}
		}
		
		private var selectionChanged:Boolean = true;
		/**
		 * 标记文本选中区域发生改变。当调用findNextLine()或findPreviousLine()时会根据当前选中索引重新计算x坐标用于移动光标。否则将一直记忆上次的光标水平位置。
		 */		
		public function markSelectionChange():void
		{
			selectionChanged = true;
		}
		
		private var lastSelectionX:Number = 0;
		
		/**
		 * 获取当前索引所在的x位置。
		 */		
		private function caculateXPosition(charIndex:int):int
		{
			var x:Number = 0;
			if(selectionChanged)
			{
				selectionChanged = false;
				var lineIndex:int = findLineIndexAtPosition(charIndex);
				var textLine:TextLine = getTextLineAt(lineIndex);
				if(textLine)
				{
					var startIndex:int = findStartOfLine(lineIndex);
					var atomIndex:int = textLine.getAtomIndexAtCharIndex(charIndex-startIndex);
					if(atomIndex==-1)
						atomIndex = textLine.atomCount-1;
					var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
					x = bounds.x;
				}
				lastSelectionX = x;
			}
			else
			{
				x = lastSelectionX;
			}
			return x;
		}
	}
}