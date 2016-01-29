package egret.ui.core.FTEText.core
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.IME;
	import flash.text.TextFormatAlign;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.ime.CompositionAttributeRange;
	import flash.text.ime.IIMEClient;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.utils.StringUtil;
	
	import egret.managers.Translator;
	import egret.ui.core.FTEText.history.HistoryBehavior;
	import egret.ui.core.FTEText.info.TextDataInfo;
	import egret.ui.core.FTEText.info.TextLineInfo;
	import egret.ui.core.FTEText.view.Ibeam;
	import egret.ui.events.FTETextEvent;
	import egret.ui.events.FTETextSelectionEvent;
	import egret.utils.ObjectUtil;
	import egret.utils.callLater;
	
	/**
	 * 文本改变 
	 */	
	[Event(name="fteTextChanged", type="egret.ui.events.FTETextEvent")]
	/**
	 * 文本选择内容改变 
	 */	
	[Event(name="textSelectionChanged", type="egret.ui.events.FTETextSelectionEvent")]
	/**
	 * 外界控制文本内容改变 
	 */	
	[Event(name="change", type="flash.events.Event")]
	/**
	 * 文本滚动
	 */	
	[Event(name="scroll", type="flash.events.Event")]
	/**
	 * 可编辑文本域基类 
	 * @author featherJ
	 * 
	 */	
	public class FTETextField extends FTETextBase implements IFTEText,IIMEClient
	{
		private var backGroundShape:Shape;
		private var selectionShape:Shape;
		private var currentLineShape:Shape;
		private var ibeam:Ibeam;
		private var historyBehavior:HistoryBehavior;
		private var container:Sprite;
		public function FTETextField()
		{
			updateFontStyle(false);
			backGroundShape = new Shape();
			backGroundShape.graphics.beginFill(_backgroupColor,_backgroupAlpha);
			backGroundShape.graphics.drawRect(0,0,100,100);
			backGroundShape.graphics.endFill();
			this.addChild(backGroundShape);
			
			container = new Sprite();
			this.addChild(container);
			
			currentLineShape = new Shape();
			container.addChild(currentLineShape);
			
			
			selectionShape = new Shape();
			container.addChild(selectionShape);
			
			ibeam = new Ibeam();
			ibeam.color = 0x000000;
			ibeam.visible = false;
			container.addChild(ibeam);
			
			historyBehavior = new HistoryBehavior();
			historyBehavior.init(this);
			
			selectable = true;
			
			this.text = "";
			initRightMenu();
		}
		
		protected function rightMouseDownHandler(event:MouseEvent):void
		{
			if(this.stage)
				this.stage.focus = this;
		}
		
		private var customMenu:NativeMenu;
		override public function set contextMenu(cm:NativeMenu):void
		{
			super.contextMenu = cm;
			customMenu = cm;
			if(selectable)
			{
				enabledRightMenu();
			}else
			{
				disabledRightMenu();
			}
		}
		
		private var defaultMenu:NativeMenu;
		private function initRightMenu():void
		{
			defaultMenu = new NativeMenu();
			defaultMenu.addEventListener(Event.DISPLAYING,rightMenudiplayingHandler);
			addRightMenuItem(Translator.getText("RightMenu.cut"),"cut","default");
			addRightMenuItem(Translator.getText("RightMenu.copy"),"copy","default");
			addRightMenuItem(Translator.getText("RightMenu.paste"),"paste","default");
			addRightMenuItem(Translator.getText("RightMenu.clear"),"delete","default");
			addRightMenuItem(Translator.getText("RightMenu.selectAll"),"selectAll","default");
		}
		
		protected function rightMenudiplayingHandler(event:Event):void
		{
			setRightMenuEnable("cut",true);
			setRightMenuEnable("copy",true);
			setRightMenuEnable("paste",true);
			setRightMenuEnable("delete",true);
			setRightMenuEnable("selectAll",true);
			
			if(displayAsPassword)
			{
				setRightMenuEnable("cut",false);
				setRightMenuEnable("copy",false);
			}
			if(!selectable)
			{
				setRightMenuEnable("cut",false);
				setRightMenuEnable("copy",false);
				setRightMenuEnable("paste",false);
				setRightMenuEnable("delete",false);
			}
			if(!editable)
			{
				setRightMenuEnable("cut",false);
				setRightMenuEnable("paste",false);
				setRightMenuEnable("delete",false);
			}
		}
		
		private function enabledRightMenu():void
		{
			if(super.contextMenu == null)
				super.contextMenu = defaultMenu;
		}
		
		private function disabledRightMenu():void
		{
			if(!checkIsDefaultMenu() && customMenu == null)
				super.contextMenu = null;
		}
		
		private function checkIsDefaultMenu():Boolean
		{
			if(super.contextMenu == null) return true;
			if(super.contextMenu == defaultMenu) return true;
			if(super.contextMenu.numItems == 5)
			{
				if(super.contextMenu.getItemAt(0).data && contextMenu.getItemAt(0).data.id == "cut" && 
					super.contextMenu.getItemAt(1).data && contextMenu.getItemAt(1).data.id == "copy" && 
					super.contextMenu.getItemAt(2).data && contextMenu.getItemAt(2).data.id == "paste" && 
					super.contextMenu.getItemAt(3).data && contextMenu.getItemAt(3).data.id == "delete" && 
					super.contextMenu.getItemAt(4).data && contextMenu.getItemAt(4).data.id == "selectAll" 
				)
				{
					return true;
				}
			}
			return false;
		}
		
		private function addRightMenuItem(label:String,id:String = null,type:String = ""):void
		{
			var item:NativeMenuItem;
			if(label == "")
			{
				item = new NativeMenuItem(label,true);
				item.data = {type:type}
			}else
			{
				item = new NativeMenuItem(label);
				item.data = {id:id,type:type};
				item.addEventListener(Event.SELECT, rightMenuItemSelectHandler); 
			}
			defaultMenu.addItem(item);
		}
		
		private function rightMenuItemSelectHandler(event:Event):void
		{
			switch(event.target.data.id)
			{
				case "cut":
					cut();
					break;
				case "copy":
					copy();
					break;	
				case "paste":
					paste();
					break;
				case "delete":
					clear();
					break;
				case "selectAll":
					selectAll();
					break;
				default:
					break;
			}
		}
		
		private function setRightMenuEnable(id:String,enabled:Boolean):void
		{
			for(var i:int = 0;i<defaultMenu.items.length;i++)
			{
				var item:NativeMenuItem = defaultMenu.getItemAt(i);
				if(item.data && item.data.id == id)
				{
					item.enabled = enabled;
				}
			}
		}
		
		private var _leading:int = 0;
		/**
		 * @copy flash.text.TextFormat.leading
		 */
		public function get leading():int
		{
			return _leading;
		}
		public function set leading(value:int):void
		{
			_leading = value;
			updateTextShow();
		}
		
		private var _maxChars:int = 0;
		/**
		 * @copy flash.text.TextField.maxChars
		 */
		public function get maxChars():int
		{
			return _maxChars;
		}
		public function set maxChars(value:int):void
		{
			_maxChars = value;
		}
		
		private var _restrict:String = null;
		/**
		 * @copy flash.text.TextField.restrict
		 */
		public function get restrict():String
		{
			return _restrict;
		}
		
		public function set restrict(value:String):void
		{
			_restrict = value;
		}
		/**
		 * @copy flash.text.TextField.caretIndex
		 */		
		public function get caretIndex():int
		{
			if(_selectionEndIndex>=_selectionBeginIndex) return _selectionEndIndex;
			return _selectionBeginIndex;
		}
		
		
		private var _multiline:Boolean = false;
		/**
		 * @copy flash.text.TextField.multiline
		 */
		public function get multiline():Boolean
		{
			return _multiline;
		}
		
		public function set multiline(value:Boolean):void
		{
			_multiline = value;
		}
		
		
		private var _displayAsPassword:Boolean = false;
		/**
		 * @copy flash.text.TextField.displayAsPassword
		 */
		public function get displayAsPassword():Boolean
		{
			return _displayAsPassword;
		}
		
		public function set displayAsPassword(value:Boolean):void
		{
			_displayAsPassword = value;
			updateTextShow();
		}
		
		
		private var _ibeamColor:uint = 0x000000;
		
		public function get ibeamColor():uint
		{
			return _ibeamColor;
		}
		
		public function set ibeamColor(value:uint):void
		{
			_ibeamColor = value;
			ibeam.color = _ibeamColor;
		}
		
		/**
		 * 光标宽度 
		 */
		public function get ibeamWidth():int
		{
			return ibeam.width;
		}
		
		public function set ibeamWidth(value:int):void
		{
			ibeam.width = value
		}
		
		
		private var _currentLineBackgroundColor:uint = 0xcccccc;
		/**
		 * 当前行的颜色 
		 */
		public function get currentLineBackgroundColor():uint
		{
			return _currentLineBackgroundColor;
		}
		public function set currentLineBackgroundColor(value:uint):void
		{
			_currentLineBackgroundColor = value;
			updateTextSelection();
		}
		
		private var _currentLineBackgroundAlpha:Number = 0;
		/**
		 * 当前行的颜色 
		 */
		public function get currentLineBackgroundAlpha():Number
		{
			return _currentLineBackgroundAlpha;
		}
		public function set currentLineBackgroundAlpha(value:Number):void
		{
			_currentLineBackgroundAlpha = value;
			if(_currentLineBackgroundAlpha < 0) _currentLineBackgroundAlpha = 0;
			if(_currentLineBackgroundAlpha > 1) _currentLineBackgroundAlpha = 1;
			updateTextSelection();
		}
		
		
		private var _backgroupColor:uint = 0xeeeeee;
		/**
		 * 背景色 
		 */		
		public function get backgroupColor():uint
		{
			return _backgroupColor;
		}
		
		public function set backgroupColor(value:uint):void
		{
			_backgroupColor = value;
			backGroundShape.graphics.clear()
			backGroundShape.graphics.beginFill(_backgroupColor,_backgroupAlpha);
			backGroundShape.graphics.drawRect(0,0,100,100);
			backGroundShape.graphics.endFill();
			updateBackGroundShape();
		}
		
		private var _backgroupAlpha:Number = 0;
		
		public function get backgroupAlpha():Number
		{
			return _backgroupAlpha;
		}
		
		public function set backgroupAlpha(value:Number):void
		{
			_backgroupAlpha = value;
			if(_backgroupAlpha<0) _backgroupAlpha = 0;
			if(_backgroupAlpha>1) _backgroupAlpha = 1;
			backGroundShape.graphics.clear()
			backGroundShape.graphics.beginFill(_backgroupColor,_backgroupAlpha);
			backGroundShape.graphics.drawRect(0,0,100,100);
			backGroundShape.graphics.endFill();
			updateBackGroundShape();
		}
		
		
		private var _fontSize:int = 14;
		/**
		 * 字号大小 
		 */
		public function get fontSize():int
		{
			return _fontSize;
		}
		public function set fontSize(value:int):void
		{
			_fontSize = value;
			updateFontStyle();
		}
		
		private var _bold:Boolean = false;
		/**
		 * 是否为粗体,默认false。
		 */
		public function get bold():Boolean
		{
			return _bold;
		}
		
		public function set bold(value:Boolean):void
		{
			_bold = value;
			updateFontStyle();
		}
		
		private var _italic:Boolean = false;
		/**
		 * 是否为斜体,默认false。
		 */
		public function get italic():Boolean
		{
			return _italic;
		}
		
		public function set italic(value:Boolean):void
		{
			_italic = value;
			updateFontStyle();
		}
		
		
		
		/**
		 * 得到真实行高,不包含leading
		 */		
		public function get actualLineHeight():int
		{
			return _fontSize*1.4;
		}
		
		private var _selectionHighlighting:uint = 0xb5d5ff;
		/**
		 * 选择框的颜色 
		 */		
		public function get selectionHighlighting():uint
		{
			return _selectionHighlighting;
		}
		
		public function set selectionHighlighting(value:uint):void
		{
			_selectionHighlighting = value;
		}
		
		private var _fontFamily:String = "SimSun";
		/**
		 * 字体名称 。默认值：SimSun
		 */
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		
		public function set fontFamily(value:String):void
		{
			_fontFamily = value;
			updateFontStyle();
		}
		
		private var _fontColor:uint = 0x000000;
		/**
		 * 字体颜色 
		 */
		public function get fontColor():uint
		{
			return _fontColor;
		}
		
		public function set fontColor(value:uint):void
		{
			_fontColor = value;
			updateFontStyle();
		}
		
		private var _selectionFontColor:uint = 0x000000;
		/**
		 * 选择部分字体颜色 
		 */
		public function get selectionFontColor():uint
		{
			return _selectionFontColor;
		}
		
		public function set selectionFontColor(value:uint):void
		{
			_selectionFontColor = value;
			updateFontStyle();
		}
		
		
		private var _letterSpacing:int = 0;
		/**
		 * 字符间距,默认值为NaN。
		 */
		public function get letterSpacing():int
		{
			return _letterSpacing;
		}
		
		public function set letterSpacing(value:int):void
		{
			_letterSpacing = value;
			updateFontStyle();
		}
		
		
		private var _textCache:String = "";
		public function replaceText(beginIndex:int, endIndex:int, newText:String, format:Boolean=true, createHistory:Boolean=true):Boolean
		{
			_selectionBeginIndex = beginIndex;
			_selectionEndIndex = endIndex;
			var beforeStr:String = "";
			beforeStr = text.slice(beginIndex,endIndex);
			if(_selectionEndIndex > _text.length)
			{
				_selectionEndIndex = _text.length;
			}
			if(_selectionBeginIndex > _text.length)
			{
				_selectionBeginIndex = _text.length;
			}
			if(_selectionBeginIndex < 0) _selectionBeginIndex = 0;
			if(_selectionEndIndex < 0) _selectionEndIndex = 0;
			
			if(_selectionEndIndex == _selectionBeginIndex && newText.length == 0) return false;
			
			var beginCache:int = _selectionBeginIndex;
			var endCache:int = _selectionEndIndex;
			
			var result:Boolean = false;
			if(_selectionBeginIndex != _selectionEndIndex) result = true;
			
			
			
			var str1:String = _text.slice(0,selectionBeginIndex);
			var str2:String = newText;
			var str3:String = _text.slice(selectionEndIndex);
			
			_selectionBeginIndex = beginIndex + newText.length;
			_selectionEndIndex = _selectionBeginIndex;
			
			_text = str1+str2+str3;
			updateTextShow();
			updateNow();
			
			if(_textCache != text)
			{
				var event:FTETextEvent = new FTETextEvent(FTETextEvent.FTE_TEXT_CHANGED);
				event.beforeStart = Math.max(beginCache,0);
				event.beforeEnd = Math.max(endCache,0);
				event.beforeStr = beforeStr;
				event.afterStart = Math.max(beginIndex,0);
				event.afterEnd = Math.max(beginIndex+newText.length,0);
				event.afterStr = newText;
				event.createHistory = createHistory;
				this.dispatchEvent(event);
			}
			_textCache = text;
			return result;
		}
		
		private var _text:String = "";
		/**
		 * 文本 
		 */
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			var event:FTETextEvent = new FTETextEvent(FTETextEvent.FTE_TEXT_CHANGED);
			event.beforeStr = _text;
			var fromEnd:int = _text.length;
			_text = value;
			event.afterStr = _text;
			event.beforeStart = 0;
			event.beforeEnd = Math.max(fromEnd,0);
			event.afterStart = 0;
			event.afterEnd = Math.max(_text.length,0);
			cleanHistory();
			updateTextShow();
			
			if(_textCache != text)
				dispatchEvent(event);
			_textCache = text;
			textCache = text;
		}
		
		
		
		private var isUpdatingShow:Boolean = false;
		public function updateTextShow():void
		{
			if(!isUpdatingShow)
			{
				isUpdatingShow = true;
				callLater(function():void{
					updateNow();
				});
			}
		}
		/**
		 * 立即更新 
		 */		
		private function updateNow():void
		{
			if(isUpdatingShow)
			{
				updateTextShowHandler();
				updateTextSelection();
			}
		}
		
		/**
		 * 更新当前视角的文本显示  
		 */		
		private function updateTextShowHandler(forced:Boolean = false):void
		{
			if(!isUpdatingShow && !forced) return;
			isUpdatingShow = false;
			releaseTextLines();
			textLineDatas.length = 0;
			var textLine:TextLine; 
			var nextTextLine:TextLine;
			var currentText:String = "";
			var nextY:Number = 0;
			
			var showText:String = "";
			if(!_displayAsPassword)
				showText = _text;
			else
			{
				showText = "";
				for(var i:int = 0;i<_text.length;i++)
				{
					if(_text.charAt(i) != "\n" && _text.charAt(i) != "\r")
					{
						showText += "*";
					}else
					{
						showText += _text.charAt(i);
					}
				}
				showText = showText;
			}
			textBlock.content = defaultTextColoring(showText);
			var n:int = 0;
			var charIndex:int = 0;
			var needRelease:Array = [];
			if(_scrollV < 0) _scrollV = 0;
			
			while(true)
			{
				var recycleLine:TextLine = getRecycleLine();
				if(recycleLine && recreateTextLine != null)
				{
					nextTextLine = recreateTextLine(recycleLine, textLine, !isNaN(_showWidth) && _wordWrap ? _showWidth : 1000000);
				}else
				{
					nextTextLine = textBlock.createTextLine(textLine,!isNaN(_showWidth) && _wordWrap ? _showWidth : 1000000);
				}
				if(!nextTextLine)
				{
					break;
				}else
				{
					nextY += (n == 0 ? (nextTextLine.ascent+(actualLineHeight/2-nextTextLine.ascent/2)) : actualLineHeight);
					nextY += (n == 0)?0:_leading;
					if(n >= _scrollV && (isNaN(_showHeight) || n*(actualLineHeight+_leading) <= _scrollV*(actualLineHeight+_leading)+_showHeight))//显示
					{
						nextTextLine.y = nextY;
						textLine = nextTextLine;
						
						container.addChild(nextTextLine);
						var textLineInfo:TextLineInfo = new TextLineInfo();
						textLineInfo.textDataIndex = n;
						textLineInfo.content = textLine;
						textLineViews.push(textLineInfo);
						
					}else//不显示
					{
						nextTextLine.y = nextY;
						textLine = nextTextLine;
						if(!isNaN(_showHeight))
						{
							needRelease.push(nextTextLine);
						}else //如果没有设置高度。则显示全部
						{
							container.addChild(nextTextLine);
							textLineInfo = new TextLineInfo();
							textLineInfo.textDataIndex = n;
							textLineInfo.content = textLine;
							textLineViews.push(textLineInfo);
						}
					}
					
					var textDataInfo:TextDataInfo = new TextDataInfo();
					textDataInfo.textLineIndex = n;
					//由于\r\n在真正显示上算做一个字符，所以这里做了一个判断，如果是\r\n连载一起的，索引就+1
					var newCharIndex:int = charIndex+textLine.atomCount;
					if(newCharIndex < text.length)
					{
						if(text.charAt(newCharIndex) == "\n" && text.charAt(newCharIndex-1) == "\r")
						{
							newCharIndex++;
						}
					}
					textDataInfo.content = _text.slice(charIndex,newCharIndex);
					
					var tempStr:String = textDataInfo.content;
					tempStr = tempStr.replace(/\r/g,"\\r");
					tempStr = tempStr.replace(/\n/g,"\\n");
					
					textLineDatas.push(textDataInfo);
					charIndex = newCharIndex;
					n++;
				}
			}
			if(_text.charAt(_text.length-1) == "\n" || _text.charAt(_text.length-1) == "\r" || _text.length == 0)
			{
				var textElement:TextElement = new TextElement();
				textElement.elementFormat = _elementFormat;
				textElement.text = "\r";
				textBlock.content = textElement;
				recycleLine = getRecycleLine();
				if(recycleLine && recreateTextLine != null)
				{
					nextTextLine = recreateTextLine(recycleLine, null);
				}else
				{
					nextTextLine = textBlock.createTextLine(null);
				}
				if(nextTextLine)
				{
					nextY += (n == 0 ? (nextTextLine.ascent+(actualLineHeight/2-nextTextLine.ascent/2)) : actualLineHeight);
					nextY += _leading;
					if(n >= _scrollV && (isNaN(_showHeight) || n*(actualLineHeight+_leading) <= _scrollV*(actualLineHeight+_leading)+_showHeight))//显示
					{
						nextTextLine.y = nextY;
						textLine = nextTextLine;
						
						container.addChild(nextTextLine);
						textLineInfo = new TextLineInfo();
						textLineInfo.textDataIndex = n;
						textLineInfo.content = textLine;
						textLineViews.push(textLineInfo);
						
					}else//不显示
					{
						nextTextLine.y = nextY;
						textLine = nextTextLine;
						if(!isNaN(_showHeight))
						{
							needRelease.push(nextTextLine);
						}else //如果没有设置高度。则显示全部
						{
							container.addChild(nextTextLine);
							textLineInfo = new TextLineInfo();
							textLineInfo.textDataIndex = n;
							textLineInfo.content = textLine;
							textLineViews.push(textLineInfo);
						}
					}
					textDataInfo = new TextDataInfo();
					textDataInfo.textLineIndex = n;
					textDataInfo.content = "";
					textLineDatas.push(textDataInfo);
					charIndex = charIndex+textLine.atomCount
					n++;
				}
				
			}
			
			if(!isNaN(_showHeight))//如果设置了高度，则根据scrollV调整当前显示的部分
			{
				var canShowNum:int = (_showHeight+_leading)/(actualLineHeight+_leading);
				_maxScrollV = n-canShowNum;
				if(_maxScrollV<0) _maxScrollV = 0;
				
				var rect:Rectangle = container.scrollRect;
				if(!rect) rect = new Rectangle(0,_scrollV*(actualLineHeight+_leading),isNaN(_showWidth)?backGroundShape.width:_showWidth,_showHeight);
				rect.y = _scrollV*(actualLineHeight+_leading);
				rect.height = _showHeight;
				rect.width = isNaN(_showWidth)?backGroundShape.width:_showWidth;
				container.scrollRect = rect;
				
				if(!(n-_scrollV >= canShowNum) && _scrollV > 0)
				{
					_scrollV = n-canShowNum;
					releaseTextLines(needRelease);
					updateTextShowHandler(true);
					return;
				}
			}
			releaseTextLines(needRelease);
			calculateLines();
			updateBackGroundShape();
			updateAlign();
			updateScrollRect();
		}
		
		/**
		 * 默认的语法着色函数 
		 * @param allText 全部文本
		 * @param viewText 视区文本
		 * @param startIndex 视区文本在全部文本中的起始索引
		 * @return 
		 * 
		 */		
		private function defaultTextColoring(viewText:String):ContentElement
		{
			if(this.stage && this.stage.focus == this)
			{
				var elements:Vector.<ContentElement> = new Vector.<ContentElement>();
				
				var str1:String = viewText.slice(0,selectionBeginIndex);
				var textElement:TextElement = new TextElement()
				textElement.text = str1;
				textElement.elementFormat = _elementFormat;
				elements.push(textElement);
				
				var str2:String = viewText.slice(selectionBeginIndex,selectionEndIndex);
				textElement = new TextElement()
				textElement.text = str2;
				textElement.elementFormat = _selectionElementFormat;
				elements.push(textElement);
				
				var str3:String = viewText.slice(selectionEndIndex);
				textElement = new TextElement()
				textElement.text = str3;
				textElement.elementFormat = _elementFormat;
				elements.push(textElement);
				
				var groupElement:GroupElement = new GroupElement(elements);
				return groupElement;
			}
			var format:ElementFormat = _elementFormat;
//			for(var i:Number = 0; i < viewText.length; i++) {
			/*if(viewText.charAt(0) == "#" && viewText.charAt(1) == "(" && viewText.search(")#") > 1) {
				format = ObjectUtil.clone(format) as ElementFormat;
				format.color = Number(viewText.slice(2,viewText.search(")#")));
				viewText = viewText.slice(viewText.search(")#") + 2,viewText.length);
			}*/
			textElement = new TextElement()
			textElement.text = viewText;
			textElement.elementFormat = _elementFormat;
			return textElement;
		}
		
		
		/**
		 * 更新对齐 
		 */		
		private function updateAlign():void
		{
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				if(align == TextFormatAlign.CENTER)
				{
					textLineViews[i].content.x = int(backGroundShape.width/2-textLineViews[i].content.width/2);
				}else if(align == TextFormatAlign.RIGHT)
				{
					textLineViews[i].content.x = int(backGroundShape.width-textLineViews[i].content.width);
				}else
				{
					textLineViews[i].content.x = 0;
				}
			}
		}
		
		/**更新背景*/
		private function updateBackGroundShape():void
		{
			var maxW:Number = 10;
			if(textLineViews.length > 0)
			{
				for(var i:int = 0;i<textLineViews.length;i++)
				{
					if(TextLine(textLineViews[i].content).atomCount>0)
					{
						var bounds:Rectangle = TextLine(textLineViews[i].content).getAtomBounds(TextLine(textLineViews[i].content).atomCount-1);
						if(bounds.x+bounds.width > maxW)
						{
							maxW = bounds.x+bounds.width;
						}
					}
				}
				maxW += 2;
			}
			backGroundShape.x = 0;
			backGroundShape.y = 0;
			backGroundShape.height = isNaN(_showHeight) ?  numLines * (actualLineHeight+_leading): _showHeight;
			backGroundShape.width = isNaN(_showWidth) ? maxW : _showWidth;
		}
		/**
		 * 计算行数据 
		 */		
		private function calculateLines():void
		{
			if(textLineDatas.length > 0) 
				textLineDatas[0].firstAtomIndex = 0;
			for(var i:int = 0;i<textLineDatas.length-1;i++) 
			{
				textLineDatas[i+1].firstAtomIndex = textLineDatas[i].firstAtomIndex + textLineDatas[i].length;	
			}
			for(i = 0;i<textLineViews.length;i++)
			{
				textLineViews[i].firstAtomIndex = textLineDatas[textLineViews[i].textDataIndex].firstAtomIndex;
			}
		}
		
		private var _maxScrollV:int = 0;
		/**
		 * @copy flash.text.TextField.maxScrollV 
		 */
		public function get maxScrollV():int
		{
			return _maxScrollV;
		}
		
		
		private var _scrollV:int = 0;
		/**
		 * @copy flash.text.TextField.scrollV 
		 */		
		public function get scrollV():int
		{
			return _scrollV;
		}
		public function set scrollV(value:int):void
		{
			_scrollV = value;
			updateTextShow();
		}
		private var _scrollH:int = 0;
		/**
		 * @copy flash.text.TextField.scrollH
		 */
		public function get scrollH():int
		{
			return _scrollH;
		}
		
		public function set scrollH(value:int):void
		{
			_scrollH = value;
		}
		
		
		private var _width:Number = NaN;
		private var _showWidth:Number = NaN;
		override public function get width():Number
		{
			return isNaN(_width) ? super.width : _width;
		}
		override public function set width(value:Number):void
		{
			if(_width != value)
			{
				_width = (value >= 0) ? value : 0
				_showWidth = (value >= 0) ? value : 0
				updateTextShow();
			}
			updateNow();
		}
		
		private var _height:Number = NaN;
		private var _showHeight:Number = NaN;
		override public function get height():Number
		{
			return isNaN(_height) ? super.height : _height;
		}
		override public function set height(value:Number):void
		{
			if(_height != value)
			{
				_height = (value >= 0) ? value : 0;
				_showHeight = (value >= 0) ? value : 0;
				updateTextShow();
			}
			updateNow();
		}
		
		
		private var _editable:Boolean = false;
		/**
		 * 是否可编辑 
		 */
		public function get editable():Boolean
		{
			return _editable;
		}
		public function set editable(value:Boolean):void
		{
			_editable = value;
			if(_editable)
			{
				if(selectable == false) selectable = true;
				this.addEventListener(TextEvent.TEXT_INPUT,textInputHandler);
			}else
			{
				this.removeEventListener(TextEvent.TEXT_INPUT,textInputHandler);
			}
		}
		
		/**
		 * 当输入文本的时候 
		 * @param event
		 */		
		protected function textInputHandler(event:TextEvent):void
		{
			if(_text.length >= _maxChars && _maxChars != 0 && selectionBeginIndex == selectionEndIndex) return;
			if(_restrict == "") return;
			
			if(canTypeIn)
			{
				var char:String = event.text;
				if(_restrict)
					char = StringUtil.restrict(char,_restrict);
				if(!char) return;
				
				if(char == "\r")
				{
					if(_multiline)
					{
						replaceText(selectionBeginIndex,selectionEndIndex,"\n");
						callLater(adjustViewPortToLine,[getDataLineIndex(_selectionEndIndex)+1]);
					}
				}else
				{
					replaceText(selectionBeginIndex,selectionEndIndex,char);
					callLater(adjustViewPortToLine,[getDataLineIndex(_selectionEndIndex)+1]);
				}
				dispatchChange();
			}
		}
		
		private var _selectable:Boolean = false;
		/**
		 * 是否可选 
		 */
		public function get selectable():Boolean
		{
			return _selectable;
		}
		public function set selectable(value:Boolean):void
		{
			_selectable = value;
			if(_selectable)
			{
				this.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
				this.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); 
				this.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
				this.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
				this.addEventListener(Event.SELECT_ALL,systemInteractiveHandler);
				this.addEventListener(Event.CLEAR,systemInteractiveHandler);
				this.addEventListener(Event.COPY,systemInteractiveHandler);
				this.addEventListener(Event.CUT,systemInteractiveHandler);
				this.addEventListener(Event.PASTE,systemInteractiveHandler);
				this.addEventListener(FocusEvent.FOCUS_IN,focusInHandler);
				this.addEventListener(FocusEvent.FOCUS_OUT,focusOutHandler);
				this.addEventListener(IMEEvent.IME_START_COMPOSITION,imeStartCompositionHandler);
				currentLineShape.visible = true;
				ibeam.visible = true;
				enabledRightMenu();
				this.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,rightMouseDownHandler);
			}else
			{
				this.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
				this.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); 
				this.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
				this.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
				this.removeEventListener(Event.SELECT_ALL,systemInteractiveHandler);
				this.removeEventListener(Event.CLEAR,systemInteractiveHandler);
				this.removeEventListener(Event.COPY,systemInteractiveHandler);
				this.removeEventListener(Event.CUT,systemInteractiveHandler);
				this.removeEventListener(Event.PASTE,systemInteractiveHandler);
				this.removeEventListener(FocusEvent.FOCUS_IN,focusInHandler);
				this.removeEventListener(FocusEvent.FOCUS_OUT,focusOutHandler);
				this.removeEventListener(IMEEvent.IME_START_COMPOSITION,imeStartCompositionHandler);
				currentLineShape.visible = false;
				ibeam.visible = false;
				initRightMenu();
				disabledRightMenu();
				this.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,rightMouseDownHandler);
			}
		}
		
		protected function imeStartCompositionHandler(event:IMEEvent):void
		{
			event.imeClient = this;
		}
		
		protected function focusOutHandler(event:FocusEvent):void
		{
			updateTextSelection();
		}
		
		
		protected function focusInHandler(event:FocusEvent):void
		{
			textCache = text;
			updateTextSelection();
		}
		
		protected function systemInteractiveHandler(event:Event):void
		{
			if(event.type == Event.SELECT_ALL)
			{
				selectAll();
			}else if(event.type == Event.CLEAR)
			{
				clear();
			}else if(event.type == Event.COPY)
			{
				copy();
			}else if(event.type == Event.CUT && !_displayAsPassword)
			{
				cut();
			}else if(event.type == Event.PASTE)
			{
				paste();
			}
		}
		
		private function selectAll():void
		{
			this.setSelection(0,text.length);
		}
		private function clear():void
		{
			this.replaceText(selectionBeginIndex,selectionEndIndex,"");
		}
		private function copy():void
		{
			if(!_displayAsPassword)
			{
				var value:String = text.slice(selectionBeginIndex,selectionEndIndex);
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,value);
			}
		}
		private function cut():void
		{
			if(!_displayAsPassword)
			{
				var value:String = text.slice(selectionBeginIndex,selectionEndIndex);
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,value);
				this.replaceText(selectionBeginIndex,selectionEndIndex,"");
				dispatchChange();
			}
		}
		private function paste():void
		{
			var value:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			if(!_multiline&&value)
			{
				value = value.replace(/\r/g,"");
				value = value.replace(/\n/g,"");
			}
			if(value)
			{
				this.replaceText(selectionBeginIndex,selectionEndIndex,value);
				if(_maxChars != 0 && this.text.length > _maxChars)
				{
					this.replaceText(_maxChars,this.text.length,"");
				}
				dispatchChange();
			}
		}
		
		
		protected function keyUpHandler(event:KeyboardEvent):void
		{
			if(event.ctrlKey == true) canTypeIn = false;
			if(event.ctrlKey == false) canTypeIn = true;
		}
		
		private var selectionDataLineAtomCache:int = 0;
		private var canTypeIn:Boolean = true;
		//当键盘按下的时候
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(event.ctrlKey == true) canTypeIn = false;
			if(event.ctrlKey == false) canTypeIn = true;
			var done:Boolean = false;
			var tempText:String = text;
			var index:int;
			
			if(event.keyCode == Keyboard.Z && event.ctrlKey)
			{
				undo();
			}
			if(event.keyCode == Keyboard.Y && event.ctrlKey)
			{
				redo();
			}
			
			//删除前一个
			if(event.keyCode == Keyboard.BACKSPACE && editable)
			{
				if(!replaceText(selectionBeginIndex,selectionEndIndex,""))
				{
					done = false;
					if(selectionBeginIndex >= 2)
					{
						tempText = text;
						if(tempText.charAt(selectionBeginIndex-1) == "\n" && tempText.charAt(selectionBeginIndex-2) == "\r")
						{
							replaceText(selectionBeginIndex-2,selectionEndIndex,"");	
							done = true;
						}
					}
					if(!done)
					{
						if(event.ctrlKey)
						{
							index = getWordIndexBackward(selectionBeginIndex,getDataLineIndex(_selectionBeginIndex));
							replaceText(index,selectionEndIndex,"");
						}else
						{
							replaceText(selectionBeginIndex-1,selectionEndIndex,"");
						}
					}
				}
				dispatchChange();
			}
			//删除后一个
			if(event.keyCode == Keyboard.DELETE && editable)
			{
				if(!replaceText(selectionBeginIndex,selectionEndIndex,""))
				{
					done = false;
					tempText = text;
					if(selectionBeginIndex < tempText.length-2)
					{
						if(tempText.charAt(selectionBeginIndex) == "\r" && tempText.charAt(selectionBeginIndex+1) == "\n")
						{
							replaceText(selectionBeginIndex,selectionEndIndex+2,"");	
							done = true;
						}
					}
					if(!done)
					{
						if(event.ctrlKey)
						{
							index = getWordIndexForward(selectionBeginIndex,getDataLineIndex(_selectionBeginIndex));
							replaceText(selectionBeginIndex,index,"");
						}else
						{
							replaceText(selectionBeginIndex,selectionEndIndex+1,"");
						}
					}
				}
				dispatchChange();
			}
			if(event.keyCode == Keyboard.LEFT)
			{
				if(event.shiftKey)
				{
					if(_selectionEndIndex >= 2 && text.charAt(_selectionEndIndex-1) == "\n" && text.charAt(_selectionEndIndex-2) == "\r")
					{
						_selectionEndIndex -= 2;
					}else
					{
						if(event.ctrlKey)
						{
							_selectionEndIndex = getWordIndexBackward(_selectionEndIndex,getDataLineIndex(_selectionEndIndex));
							_selectionEndIndex = Math.max(0,_selectionEndIndex)
						}else
						{
							_selectionEndIndex--;
						}
					}
					_selectionEndIndex = Math.max(0,_selectionEndIndex)
					updateTextSelection();
					adjustViewPortToLine(getDataLineIndex(_selectionEndIndex));
				}else
				{
					if(selectionBeginIndex == selectionEndIndex)
					{
						done = false;
						if(selectionBeginIndex >= 2)
						{
							tempText = text;
							if(tempText.charAt(selectionBeginIndex-1) == "\n" && tempText.charAt(selectionBeginIndex-2) == "\r")
							{
								setSelection(selectionBeginIndex-2,selectionBeginIndex-2);	
								done = true;
							}
						}
						if(!done)
						{
							if(event.ctrlKey)
							{
								index = getWordIndexBackward(selectionBeginIndex,getDataLineIndex(_selectionBeginIndex));
								setSelection(index,index);
							}else
							{
								setSelection(selectionBeginIndex-1,selectionBeginIndex-1);
							}
						}
					}else
					{
						setSelection(selectionBeginIndex,selectionBeginIndex);
					}
					adjustViewPortToLine(getDataLineIndex(_selectionBeginIndex));
				}
				selectionDataLineAtomCache = _selectionEndIndex-textLineDatas[getDataLineIndex(_selectionEndIndex)].firstAtomIndex;
			}
			if(event.keyCode == Keyboard.RIGHT)
			{
				if(event.shiftKey)
				{
					if(_selectionEndIndex < text.length-1 && text.charAt(_selectionEndIndex) == "\r" && text.charAt(_selectionEndIndex+1) == "\n")
					{
						_selectionEndIndex += 2;
					}else
					{
						if(event.ctrlKey)
						{
							_selectionEndIndex = getWordIndexForward(_selectionEndIndex,getDataLineIndex(_selectionEndIndex));
							_selectionEndIndex = Math.max(0,_selectionEndIndex)
						}else
						{
							_selectionEndIndex ++;
						}
					}
					_selectionEndIndex = Math.min(text.length,_selectionEndIndex)
					updateTextSelection();
					adjustViewPortToLine(getDataLineIndex(_selectionEndIndex));
				}else
				{
					if(selectionBeginIndex == selectionEndIndex)
					{
						done = false;
						tempText = text;
						if(selectionBeginIndex < tempText.length-2)
						{
							if(tempText.charAt(selectionBeginIndex) == "\r" && tempText.charAt(selectionBeginIndex+1) == "\n")
							{
								setSelection(selectionEndIndex+2,selectionEndIndex+2);
								done = true;
							}
						}
						if(!done)
						{
							if(event.ctrlKey)
							{
								index = getWordIndexForward(selectionBeginIndex,getDataLineIndex(_selectionBeginIndex));
								setSelection(index,index);
							}else
							{
								setSelection(selectionEndIndex+1,selectionEndIndex+1);
							}
						}
					}else
					{
						setSelection(selectionEndIndex,selectionEndIndex);
					}
					adjustViewPortToLine(getDataLineIndex(_selectionBeginIndex));
				}
				selectionDataLineAtomCache = _selectionEndIndex-textLineDatas[getDataLineIndex(_selectionEndIndex)].firstAtomIndex;
			}
			if(event.keyCode == Keyboard.UP)
			{
				if(event.shiftKey && !event.ctrlKey)
				{
					var tempSelectionEndDataLine:int = getDataLineIndex(_selectionEndIndex);
					var tempIndex:int = -1;
					if(tempSelectionEndDataLine > 0)
					{
						if(selectionDataLineAtomCache < textLineDatas[tempSelectionEndDataLine-1].content.length)
						{
							tempIndex = textLineDatas[tempSelectionEndDataLine-1].firstAtomIndex+selectionDataLineAtomCache;
						}else
						{
							tempIndex = textLineDatas[tempSelectionEndDataLine-1].firstAtomIndex+textLineDatas[tempSelectionEndDataLine-1].content.length-1
						}
						if(tempIndex >= 1 && text.charAt(tempIndex) == "\n" && text.charAt(tempIndex-1) == "\r")
						{
							tempIndex -= 1;
						}
						_selectionEndIndex = Math.max(tempIndex,0)
						updateTextSelection();
						adjustViewPortToLine(tempSelectionEndDataLine-1);
					}
				}else if(!event.shiftKey && !event.ctrlKey)
				{
					var tempSelectionBeginDataLine:int = getDataLineIndex(_selectionBeginIndex);
					tempIndex = -1;
					if(selectionBeginIndex == selectionEndIndex && getDataLineIndex(_selectionBeginIndex) > 0)
					{
						if(selectionDataLineAtomCache < textLineDatas[getDataLineIndex(_selectionBeginIndex)-1].content.length)
						{
							tempIndex = textLineDatas[getDataLineIndex(_selectionBeginIndex)-1].firstAtomIndex+selectionDataLineAtomCache;
						}else
						{
							tempIndex = textLineDatas[getDataLineIndex(_selectionBeginIndex)-1].firstAtomIndex+textLineDatas[getDataLineIndex(_selectionBeginIndex)-1].content.length-1
						}
						if(tempIndex >= 1 && text.charAt(tempIndex) == "\n" && text.charAt(tempIndex-1) == "\r")
						{
							tempIndex -= 1;
						}
						setSelection(tempIndex,tempIndex);
					}else
					{
						setSelection(selectionBeginIndex,selectionBeginIndex);
					}
					adjustViewPortToLine(tempSelectionBeginDataLine-1);
				}else if(event.ctrlKey && !event.shiftKey)
				{
					adjustViewPort(_scrollV-1);
				}
			}
			
			if(event.keyCode == Keyboard.DOWN)
			{
				if(event.shiftKey && !event.ctrlKey)
				{
					tempSelectionEndDataLine = getDataLineIndex(_selectionEndIndex);
					tempIndex = -1
					if(tempSelectionEndDataLine < textLineDatas.length-1)
					{
						if(selectionDataLineAtomCache < textLineDatas[tempSelectionEndDataLine+1].content.length)
						{
							tempIndex = textLineDatas[tempSelectionEndDataLine+1].firstAtomIndex+selectionDataLineAtomCache;
						}else
						{
							tempIndex = textLineDatas[tempSelectionEndDataLine+1].firstAtomIndex+textLineDatas[tempSelectionEndDataLine+1].content.length-1
						}
						if(textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].length == 0)
						{
							tempIndex = text.length;
						}
						if(tempIndex >= 1 && text.charAt(tempIndex) == "\n" && text.charAt(tempIndex-1) == "\r")
						{
							tempIndex -= 1;
						}
						_selectionEndIndex = Math.min(tempIndex,text.length)
						updateTextSelection();
						adjustViewPortToLine(tempSelectionEndDataLine+1);
					}
				}else if(!event.shiftKey && !event.ctrlKey)
				{
					tempSelectionEndDataLine = getDataLineIndex(_selectionBeginIndex);
					tempIndex = -1;
					if(selectionBeginIndex == selectionEndIndex && getDataLineIndex(_selectionBeginIndex) < textLineDatas.length-1)
					{
						if(selectionDataLineAtomCache < textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].content.length)
						{
							tempIndex = textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].firstAtomIndex+selectionDataLineAtomCache;
						}else
						{
							tempIndex = textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].firstAtomIndex+textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].content.length-1
						}
						if(textLineDatas[getDataLineIndex(_selectionBeginIndex)+1].length == 0)
						{
							tempIndex = text.length;
						}
						if(tempIndex >= 1 && text.charAt(tempIndex) == "\n" && text.charAt(tempIndex-1) == "\r")
						{
							tempIndex -= 1;
						}
						setSelection(tempIndex,tempIndex);
					}else
					{
						setSelection(selectionEndIndex,selectionEndIndex);
					}
					adjustViewPortToLine(tempSelectionEndDataLine+1);
				}else if(event.ctrlKey && !event.shiftKey)
				{
					adjustViewPort(_scrollV+1);
				}
			}
		}
		
		private var _wordWrap:Boolean = false;
		/**
		 * @copy flash.text.TextField.wordWrap 
		 */
		public function get wordWrap():Boolean
		{
			return _wordWrap;
		}
		public function set wordWrap(value:Boolean):void
		{
			_wordWrap = value;
			updateTextShow();
		}
		
		private var _align:String = TextFormatAlign.LEFT;
		public function get align():String
		{
			return _align;
		}
		public function set align(value:String):void
		{
			_align = value;
			updateTextShow();
		}
		
		/**
		 * 行数 
		 */		
		public function get numLines():int
		{
			return textLineDatas.length
		}
		
		protected function mouseOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.ARROW;
		}
		protected function mouseOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		private var _stage:Stage;
		private var _selectionBeginIndex:int;
		private var _selectionEndIndex:int;
		private var _mouseDownTimes:int = 0;
		private var _mouseDownTimeStamp:int = 0;
		private var _settimeIndex:int = -1;
		private var _selectionBeginCache:int = -1;
		private var _selectionEndCache:int = -1;
		
		/**鼠标按下的时候*/
		protected function mouseDownHandler(event:MouseEvent):void 
		{ 
			var tmpIndex:int = getAtomIndexByMousePos();
			if(tmpIndex != -1)
			{
				var str:String = text.charAt(tmpIndex);
				_selectionBeginIndex = tmpIndex;
				_selectionEndIndex = _selectionBeginIndex;
				ibeam.visible = true;
				this.stage.focus = this;
				IME.enabled = true;
				updateTextSelection();
				_stage = this.stage;
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
				this.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			}
			
			
			_mouseDownTimes++;
			if(_mouseDownTimes >= 3)
			{
				if(selectionBeginIndex == _selectionBeginCache &&
					selectionEndIndex == _selectionEndCache)
					setSelection(0,text.length);
			}else if(_mouseDownTimes == 2)
			{
				if(selectionBeginIndex == _selectionBeginCache &&
					selectionEndIndex == _selectionEndCache)
					onDoubleMouseDown();
			}else if(_mouseDownTimes == 1)
			{
				_mouseDownTimeStamp = getTimer();
				_settimeIndex = setTimeout(function():void{
					_mouseDownTimes = 0;
				},400);
				_selectionBeginCache = selectionBeginIndex;
				_selectionEndCache = selectionEndIndex;
			}
		}
		
		
		
		/**
		 * 双击选中单词
		 */
		private function onDoubleMouseDown():void
		{
			if(textLineViews.length == 0) return;
			var start:int = selectionBeginIndex;
			var end:int = selectionEndIndex+1;
			
			var selectedStr:Boolean = false;
			//选中引号内的
			if(text.charAt(selectionBeginIndex) == "\"" || text.charAt(selectionBeginIndex) == "\'")
			{
				var numDouble:int = 0;
				var numSingle:int = 0;
				var indexDouble:int = selectionBeginIndex;
				var indexSingle:int = selectionBeginIndex;
				for(var i:int = 0;i<=selectionBeginIndex;i++)
				{
					if(text.charAt(i) == "\"")
					{
						numDouble++;
						if(i!= selectionBeginIndex)
						{
							indexDouble = i;
						}
					}
					if(text.charAt(i) == "'")
					{
						numSingle++;
						if(i!= selectionBeginIndex)
						{
							indexSingle = i;
						}
					}
				}
				end = selectionBeginIndex;
				if(text.charAt(selectionBeginIndex) == "\"" && numDouble%2 == 0)
				{
					start = indexDouble+1;
					if(start != end)
						selectedStr = true;
				}
				if(text.charAt(selectionBeginIndex) == "'" && numSingle%2 == 0)
				{
					start = indexSingle+1;
					if(start != end)
						selectedStr = true;
				}
				if(selectedStr)
				{
					setSelection(start,end);
				}
			}
			if(!selectedStr) //如果没有选择上字符串
			{
				if(checkIsWord(text.charAt(selectionBeginIndex)))
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
					setSelection(start,end);
				}else if(text.charAt(selectionBeginIndex) == " " || text.charAt(selectionBeginIndex) == "\r" || text.charAt(selectionBeginIndex) == "\n"
					|| text.charAt(i) == "\t" || selectionBeginIndex == text.length)
				{
					start--;
					end--;
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
					if(start == end && start == text.length)
						setSelection(start-1,end);
					else
						setSelection(start,end);
				}else if(text.charAt(selectionBeginIndex) != "\r" && text.charAt(selectionBeginIndex) != "\n")
				{
					setSelection(start,start+1);
				}
			}
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
		
		
		private var scrollingTimeStamp:int = 0;
		private var scrollingDist:Number = 0;
		
		/**当鼠标开始移动的时候*/
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			scrollingTimeStamp = getTimer();
			scrollingDist = 0;
			this.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		protected function enterFrameHandler(event:Event):void
		{
			var tmpIndex:int = getAtomIndexByMousePos();
			if(tmpIndex != -1)
			{
				_selectionEndIndex = tmpIndex;
				if(!isNaN(_showHeight))
				{
					if(this.mouseY-_showHeight > 0)
					{
						scrolling(this.mouseY-_showHeight,getTimer()-scrollingTimeStamp)
					}else if(this.mouseY < 0)
					{
						scrolling(this.mouseY,getTimer()-scrollingTimeStamp)
					}
				}
				updateTextSelection();
			}
			scrollingTimeStamp = getTimer();
		}	
		
		/**
		 * 鼠标选中移动的时候，会根据鼠标位置滚动文本内容
		 * @param speed 速度,正数往下，负数往上
		 * @param deltaTime 时间间隔
		 */		
		private function scrolling(speed:int,deltaTime:int):void
		{
			if(isNaN(_showHeight))return;
			var tempDist:int = 0;
			if(deltaTime < 15) deltaTime = 15;
			scrollingDist += speed*((deltaTime)/800);
			if(scrollingDist >= 1 || scrollingDist<=-1)
			{
				tempDist = int(scrollingDist);
				adjustViewPort(textLineViews[0].textDataIndex+tempDist);
				scrollingDist -= tempDist;
				var tmpIndex:int = getAtomIndexByMousePos();
				if(tmpIndex != -1)
				{
					_selectionEndIndex = tmpIndex;
				}
			}
		}
		
		/**鼠标在舞台上松起的时候*/
		protected function mouseUpHandler(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			_stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			this.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			ibeam.startFlicker();
			updateTextSelection();
			adjustViewPortToLine(getDataLineIndex(_selectionEndIndex));
			selectionDataLineAtomCache = _selectionEndIndex-textLineDatas[getDataLineIndex(_selectionEndIndex)].firstAtomIndex;
		}
		
		/**
		 * 调整视角到某行
		 * 
		 */		
		private function adjustViewPortToLine(targetLineIndex:int):void
		{
			if(isNaN(_showHeight))return;
			if(textLineViews.length == 0) return;
			if(targetLineIndex < textLineViews[0].textDataIndex)
			{
				adjustViewPort(targetLineIndex);
			}else if(targetLineIndex >= textLineViews[0].textDataIndex+int(_showHeight/(actualLineHeight+_leading))-1)
			{
				adjustViewPort(targetLineIndex-int(_showHeight/(actualLineHeight+_leading))+1);
			}else
			{
				adjustViewPort(textLineViews[0].textDataIndex);
			}
		}
		
		/**
		 * 调整观看视角 
		 * @param startLine
		 * @param viewHeight
		 * 
		 */		
		public function adjustViewPort($startLine:int):void
		{
			if(isNaN(_showHeight))return;
			_scrollV = $startLine;
			updateTextShow()
			dispatchEvent(new Event(Event.SCROLL));
		}
		
		/**通过鼠标位置得到下面的字符在全文中的索引*/
		protected function getAtomIndexByMousePos(targetPos:Point = null):int
		{
			if(!targetPos) targetPos = new Point(mouseX,mouseY);
			targetPos = this.localToGlobal(targetPos);
			targetPos = container.globalToLocal(targetPos);
			
			var selectionIndex:int = -1;
			var textLineInfo:TextLineInfo;
			var firstAtomIndex:int = -1;
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				if(targetPos.y <= textLineViews[i].content.y-getTextLineOffsetY(textLineViews[i].content)+actualLineHeight &&
					targetPos.y >= textLineViews[i].content.y-getTextLineOffsetY(textLineViews[i].content)-_leading)
				{
					textLineInfo = textLineViews[i];
					break;
				}
			}
			var lastViewLineIndex:int = textLineViews.length-1;
			if(!isNaN(_showHeight))
			{
				var canShowNum:int = Math.ceil(_showHeight/(actualLineHeight+_leading));
				lastViewLineIndex = Math.min(canShowNum-1,textLineViews.length-1)
			}
			if(textLineViews.length>0)
			{
				if(targetPos.y < textLineViews[0].content.y-getTextLineOffsetY(textLineViews[0].content))
				{
					textLineInfo = textLineViews[0];
				}
				else if(targetPos.y > textLineViews[lastViewLineIndex].content.y-getTextLineOffsetY(textLineViews[lastViewLineIndex].content)+actualLineHeight)
				{
					textLineInfo = textLineViews[lastViewLineIndex];
				}
			}
			var index:int = -1;
			
			
			if(textLineInfo)
			{
				targetPos = container.localToGlobal(targetPos);
				targetPos = textLineInfo.content.globalToLocal(targetPos);
				firstAtomIndex = textLineInfo.firstAtomIndex;
				var atomBounds:Rectangle;
				var textData:String = textLineDatas[textLineInfo.textDataIndex].content;
				if(textData.length == 1)
				{
					if(textData.charAt(0) == "\n" || textData.charAt(0) == "\r")
					{
						index = 0;
					}else
					{
						atomBounds = textLineInfo.content.getAtomBounds(0);
						var newPoint:Point = new Point(targetPos.x,targetPos.y);
						newPoint = this.localToGlobal(newPoint);
						newPoint = textLineInfo.content.localToGlobal(newPoint);
						if(newPoint.x < atomBounds.width/2)
						{
							index = 0;
						}else
						{
							index = 1;
						}
					}
				}
				if(textData.length == 2 && index == -1)
				{
					if(textData.charAt(0) == "\r" && textData.charAt(1) == "\n")
					{
						index = 0
					}
				}
				if(textLineDatas[textLineInfo.textDataIndex].content == "" && index == -1)
				{
					index = 0;
				}
				if(index == -1)
				{
					for(i = 0;i<textLineInfo.length-1;i++)
					{
						atomBounds = textLineInfo.content.getAtomBounds(i);
						var nextAtomBounds:Rectangle = textLineInfo.content.getAtomBounds(i+1);
						if(i == 0 && targetPos.x <= atomBounds.x+atomBounds.width/2)
						{
							index = 0;
							break;
						}
						if(i == textLineInfo.content.atomCount-2 && targetPos.x > nextAtomBounds.x+nextAtomBounds.width/2)
						{
							if(textData.charAt(textData.length-1) == "\n" || textData.charAt(textData.length-1) == "\r" ||
								(textData.length>1 && textData.charAt(textData.length-1) == "\n" && textData.charAt(textData.length-2) == "\r" )
							)
							{
								index = textLineInfo.content.atomCount-1;	
							}else
							{
								index = textLineInfo.content.atomCount
							}
							break;
						}
						if(targetPos.x>atomBounds.x+atomBounds.width/2 && targetPos.x <= nextAtomBounds.x+nextAtomBounds.width/2)
						{
							index = i+1;
							break;
						}
					}
				}
			}
			if(firstAtomIndex != -1 && index != -1)
			{
				selectionIndex = firstAtomIndex + index;
			}
			return selectionIndex;
		}
		
		private function updateTextSelection():void
		{
			updateTextSelectionHandler();
			updateTextShowHandler(true);
		}
		
		
		/**更新文字的选择*/
		private function updateTextSelectionHandler():void
		{
			selectionShape.graphics.clear();
			currentLineShape.graphics.clear();
			ibeam.visible = false;
			
			if(!this.stage || this.stage.focus != this) return;
			
			var startX:int = 0;
			var startY:int = 0;
			var endX:int = 0;
			var endY:int = 0;
			
			var startLine:int = -1;
			var startLineIndex:int = -1;
			var endLine:int = -1;
			var endLineIndex:int = -1;
			var ibeamLine:int = -1;
			var ibeamIndex:int = -1;
			var bounds:Rectangle;
			if(textLineViews.length == 0) return;
			var viewPortStartLineIndex:int = textLineViews[0].textDataIndex;
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				var len:int = textLineViews[i].length;
				if(selectionBeginIndex >= textLineViews[i].firstAtomIndex && selectionBeginIndex <= textLineViews[i].firstAtomIndex + len)
				{
					startLine = i;
					startLineIndex = selectionBeginIndex-textLineViews[i].firstAtomIndex;
				}
				if(selectionEndIndex >= textLineViews[i].firstAtomIndex && selectionEndIndex <= textLineViews[i].firstAtomIndex + len)
				{
					endLine = i;
					endLineIndex = selectionEndIndex-textLineViews[i].firstAtomIndex;
				}
				if(_selectionEndIndex >= textLineViews[i].firstAtomIndex && _selectionEndIndex <= textLineViews[i].firstAtomIndex + len)
				{
					ibeamLine = i;
					ibeamIndex = _selectionEndIndex-textLineViews[i].firstAtomIndex;
				}
			}
			if(startLine < 0 && endLine < 0 && 
				(textLineDatas[viewPortStartLineIndex].firstAtomIndex > selectionEndIndex || 
					textLineDatas[viewPortStartLineIndex].firstAtomIndex < selectionBeginIndex
				))
				return;
			ibeam.visible = true;
			if(startLine < 0)
			{
				startLine = 0;
				startLineIndex = 0;
			}
			if(endLine < 0)
			{
				endLine = textLineViews.length-1;
				if(endLine >= 0)
					endLineIndex = textLineViews[endLine].length;
				ibeam.visible = false;
			}
			if(ibeamIndex != -1 && ibeamLine != -1)
			{
				ibeam.visible = true;
				startY = TextLine(textLineViews[ibeamLine].content).y-getTextLineOffsetY(textLineViews[ibeamLine].content);
				if(ibeamIndex == 0)
				{
					endX = textLineViews[ibeamLine].content.x;
				}else
				{
					bounds = TextLine(textLineViews[ibeamLine].content).getAtomBounds(ibeamIndex-1);
					endX = textLineViews[ibeamLine].content.x+bounds.x+bounds.width;
				}
				if(ibeam.height != actualLineHeight || ibeam.x != endX || ibeam.y != startY)
				{
					ibeam.height = actualLineHeight;
					ibeam.x = endX;
					ibeam.y = startY;
					ibeam.startFlicker();
				}
			}
			
			if(ibeam.visible && getDataLineIndex(selectionBeginIndex) == getDataLineIndex(selectionEndIndex))
			{
				currentLineShape.graphics.beginFill(_currentLineBackgroundColor,_currentLineBackgroundAlpha);
				currentLineShape.graphics.drawRect(0,ibeam.y,backGroundShape.width,ibeam.height);
				currentLineShape.graphics.endFill();
			}
			
			if(startLine == -1 || endLine == -1 || startLineIndex == -1 || endLineIndex == -1) return;
			if(textLineViews[startLine].length == startLineIndex) return;
			if(endLineIndex == 0 && endLine == 0) return;
			
			if(startLine == endLine && selectionBeginIndex != selectionEndIndex)
			{
				bounds = TextLine(textLineViews[startLine].content).getAtomBounds(startLineIndex);
				startX = 0+bounds.x;
				startY = TextLine(textLineViews[startLine].content).y-getTextLineOffsetY(textLineViews[startLine].content);
				bounds = TextLine(textLineViews[startLine].content).getAtomBounds(endLineIndex-1);
				endX = 0+bounds.x+bounds.width;
				endY = startY+actualLineHeight;
				selectionShape.graphics.beginFill(_selectionHighlighting);
				selectionShape.graphics.drawRect(textLineViews[startLine].content.x+startX,startY,endX-startX,endY-startY);
				selectionShape.graphics.endFill();
			}else if(endLine>startLine && selectionBeginIndex != selectionEndIndex)
			{
				bounds = TextLine(textLineViews[startLine].content).getAtomBounds(startLineIndex);
				startX =0+ bounds.x;
				startY = TextLine(textLineViews[startLine].content).y-getTextLineOffsetY(textLineViews[startLine].content);
				bounds = TextLine(textLineViews[startLine].content).getAtomBounds(TextLine(textLineViews[startLine].content).atomCount-1);
				endX = 0+bounds.x+bounds.width;
				endY = startY+actualLineHeight;
				selectionShape.graphics.beginFill(_selectionHighlighting);
				selectionShape.graphics.drawRect(textLineViews[startLine].content.x+startX,startY,endX-startX,endY-startY);
				selectionShape.graphics.endFill();
				startX = 0;
				startY = TextLine(textLineViews[endLine].content).y-getTextLineOffsetY(textLineViews[endLine].content);
				if(endLineIndex == 0)
				{
					endX = 0;
				}else
				{
					bounds = TextLine(textLineViews[endLine].content).getAtomBounds(endLineIndex-1);
					endX = 0+bounds.x+bounds.width;
				}
				endY = startY+actualLineHeight;
				selectionShape.graphics.beginFill(_selectionHighlighting);
				selectionShape.graphics.drawRect(textLineViews[endLine].content.x+startX,startY,endX-startX,endY-startY);
				selectionShape.graphics.endFill();
				
				for(i = startLine+1;i<endLine;i++)
				{
					startX = 0;
					startY = TextLine(textLineViews[i].content).y-getTextLineOffsetY(textLineViews[i].content);
					bounds = TextLine(textLineViews[i].content).getAtomBounds(TextLine(textLineViews[i].content).atomCount-1);
					endX = 0+bounds.x+bounds.width;
					endY = startY+actualLineHeight;
					selectionShape.graphics.beginFill(_selectionHighlighting);
					selectionShape.graphics.drawRect(textLineViews[i].content.x+startX,startY,endX-startX,endY-startY);
					selectionShape.graphics.endFill();
				}
			}
			dispatchSelectionChanged();
			updateScrollRect();
		}
		
		
		
		private function updateScrollRect():void
		{
			if(isNaN(_showWidth)) return;
			
			if(!container.scrollRect)
				container.scrollRect = new Rectangle(0,0,backGroundShape.width,backGroundShape.height);
			else
			{
				var rect:Rectangle = container.scrollRect;
				rect.width = isNaN(_showWidth)?backGroundShape.width:_showWidth;
				rect.height = isNaN(_showHeight)?backGroundShape.height:_showHeight;
				container.scrollRect = rect;
			}
			
			if(_showWidth > 0 && ibeam.visible)
			{
				if(ibeam.x < container.scrollRect.x)
				{
					rect = container.scrollRect;
					rect.x = 0;
					container.scrollRect = rect;
				}
				
				var containerW:Number = textWidth;
				while(ibeam.x > container.scrollRect.x+_showWidth)
				{
					rect = container.scrollRect;
					rect.x += 200;
					if(containerW-rect.x < _showWidth)
					{
						rect.x = containerW-_showWidth;
						container.scrollRect = rect;
						break;
					}
					if(rect.x<0) rect.x = 0;
					container.scrollRect = rect;
				}
			}
		}
		/**
		 * @copy flash.text.TextField.textWidth 
		 */		
		public function get textWidth():Number
		{
			var w:Number = 0;
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				if(textLineViews[i].content.width>w)
				{
					w = textLineViews[i].content.width
				}
			}
			return w+ibeamWidth;
		}
		/**
		 * @copy flash.text.TextField.textHeight 
		 */	
		public function get textHeight():Number
		{
			return numLines*(actualLineHeight+_leading)-_leading;
		}
		
		
		/**得到文本行最终显示结果与文本行实例的纵向坐标差*/
		private function getTextLineOffsetY(textLine:TextLine):Number
		{
			return (textLine.ascent+(actualLineHeight/2-textLine.ascent/2));
		}
		
		/**
		 * @copy flash.text.TextField.selectionBeginIndex
		 * @return 
		 * 
		 */		
		public function get selectionEndIndex():int
		{
			return Math.max(_selectionEndIndex,_selectionBeginIndex);
		}
		/**
		 * @copy flash.text.TextField.selectionBeginIndex
		 * @return 
		 * 
		 */	
		public function get selectionBeginIndex():int
		{
			return Math.min(_selectionEndIndex,_selectionBeginIndex);
		}
		/**
		 * @copy flash.text.TextField.getLineIndexAtPoint()
		 */	
		public function getLineIndexAtPoint(x:Number, y:Number):int
		{
			var charIndex:int = getAtomIndexByMousePos(new Point(x,y));
			return getLineIndexOfChar(charIndex);
		}
		
		/**
		 * @copy flash.text.TextField.getLineIndexOfChar()
		 */		
		public function getLineIndexOfChar(charIndex:int):int
		{
			return getDataLineIndex(charIndex);
		}
		
		/**
		 * 通过字符索引得到数据行 
		 * @param atomIndex
		 * @return 
		 * 
		 */		
		public function getDataLineIndex(atomIndex:int):int
		{
			if(atomIndex == text.length) 
				return textLineDatas.length-1; 
			for(var i:int = 0;i<textLineDatas.length;i++)
			{
				if(atomIndex >= textLineDatas[i].firstAtomIndex && atomIndex < textLineDatas[i].firstAtomIndex+textLineDatas[i].length)
				{
					return i;
				}
			}
			return -1;
		}
		/**
		 * 通过字符索引得到显示行 
		 * @param atomIndex
		 * @return 
		 * 
		 */		
		public function getViewLineIndex(atomIndex:int):int
		{
			var dataLine:TextDataInfo = textLineDatas[textLineViews[textLineViews.length-1].textDataIndex];
			if(atomIndex == dataLine.firstAtomIndex && dataLine.length == 0) 
				return textLineViews.length-1;
			
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				dataLine = textLineDatas[textLineViews[i].textDataIndex];
				if(atomIndex >= dataLine.firstAtomIndex && atomIndex < dataLine.firstAtomIndex+dataLine.length)
				{
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * @copy flash.text.TextField.setSelection()
		 */	
		public function setSelection(beginIndex:int, endIndex:int):void
		{
			_selectionBeginIndex = beginIndex;
			_selectionEndIndex = endIndex;
			if(_selectionEndIndex > _text.length)
			{
				_selectionEndIndex = _text.length;
			}
			if(_selectionBeginIndex > _text.length)
			{
				_selectionBeginIndex = _text.length;
			}
			if(_selectionBeginIndex < 0) _selectionBeginIndex = 0;
			if(_selectionEndIndex < 0) _selectionEndIndex = 0;
			updateTextShowHandler(true);
			updateTextSelection();
		}
		
		
		/**
		 * 向前查找一个次的索引，如果没有则向前移动一个字符 
		 * @param index
		 * @return 
		 * 
		 */		
		protected function getWordIndexBackward(atomIndex:int,lineIndex:int):int
		{
			var lineText:String = textLineDatas[lineIndex].content;
			var indexCache:int = atomIndex;
			atomIndex = atomIndex-textLineDatas[lineIndex].firstAtomIndex;
			for(var i:int = atomIndex-1;i>=0;i--)
			{
				if(!checkIsSpace(lineText.charAt(i)))
				{
					if(checkIsSign(lineText.charAt(i)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
					if(i > 0 && checkIsSign(lineText.charAt(i-1)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
					if(checkIsBigLetter(lineText.charAt(i)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
				}
			}
			if(indexCache == textLineDatas[lineIndex].firstAtomIndex) return indexCache-1;
			return textLineDatas[lineIndex].firstAtomIndex;
		}
		
		/**
		 * 向后查找一个词的索引，如果没有则向后移动一个字符 
		 * @param index
		 * @return 
		 * 
		 */		
		protected function getWordIndexForward(atomIndex:int,lineIndex:int):int
		{
			var lineText:String = textLineDatas[lineIndex].content;
			var indexCache:int = atomIndex;
			atomIndex = atomIndex-textLineDatas[lineIndex].firstAtomIndex;
			for(var i:int = atomIndex+1;i<lineText.length;i++)
			{
				if(!checkIsSpace(lineText.charAt(i)))
				{
					if(checkIsSign(lineText.charAt(i)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
					if(i > 0 && checkIsSign(lineText.charAt(i-1)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
					if(checkIsBigLetter(lineText.charAt(i)))
					{
						return textLineDatas[lineIndex].firstAtomIndex+i;
					}
				}
			}
			if(textLineDatas[lineIndex].firstAtomIndex+lineText.length == indexCache) return indexCache+1;
			return textLineDatas[lineIndex].firstAtomIndex+lineText.length;
		}
		
		private function checkIsSpace(char:String):Boolean
		{
			var charCode:int = char.charCodeAt(0);
			//英文字母数字和下划线
			if(charCode == 9 || charCode == 32)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 检查是否是字母(目前只支持英文的检测)
		 * @param char
		 * @return 
		 * 
		 */		
		private function checkIsSign(char:String):Boolean
		{
			var charCode:int = char.charCodeAt(0);
			//英文字母数字和下划线
			if((charCode >= 65 && charCode<=90) || 
				(charCode >= 97 && charCode <= 122) ||
				(charCode >= 48 && charCode <= 57) ||
				charCode == 95
			)
			{
				return false;
			}
			return true;
		}
		
		/**
		 * 检查是否是字母(目前只支持英文的检测)
		 * @param char
		 * @return 
		 * 
		 */		
		private function checkIsBigLetter(char:String):Boolean
		{
			var charCode:int = char.charCodeAt(0);
			//英文字母数字和下划线
			if(charCode >= 65 && charCode<=90)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 撤销 
		 */		
		public function undo():void
		{
			historyBehavior.undo();
			dispatchChange();
		}
		
		/**
		 * 恢复 
		 */		
		public function redo():void
		{
			historyBehavior.redo();
			dispatchChange();
		}
		
		/**
		 * 是否可以撤销 
		 * @return 
		 * 
		 */		
		public function canUndo():Boolean
		{
			return historyBehavior.canUndo();
		}
		
		/**
		 * 是否可以恢复 
		 * @return 
		 * 
		 */		
		public function canRedo():Boolean
		{
			return historyBehavior.canRedo();
		}
		/**
		 * 清空历史记录 
		 * 
		 */		
		public function cleanHistory():void
		{
			historyBehavior.clean();
		}
		
		private var selectionBeginIndexCache:int = 0;
		private var selectionEndIndexCache:int = 0;
		/**
		 * 派发文本选择改变事件
		 */		
		private function dispatchSelectionChanged():void
		{
			if(selectionBeginIndexCache != selectionBeginIndex || selectionEndIndexCache != selectionEndIndex)
			{
				selectionBeginIndexCache = selectionBeginIndex;
				selectionEndIndexCache = selectionEndIndex;
				dispatchEvent(new FTETextSelectionEvent(FTETextSelectionEvent.TEXT_SELECTION_CHANGED));
			}
		}
		
		public function get length():int
		{
			return _text.length;
		}
		
		private var _selectionElementFormat:ElementFormat;
		private var _elementFormat:ElementFormat;
		private function updateFontStyle(updateShow:Boolean = true):void
		{
			_elementFormat = new ElementFormat(
				new FontDescription(_fontFamily,_bold?FontWeight.BOLD:FontWeight.NORMAL,_italic?FontPosture.ITALIC:FontPosture.NORMAL),
				_fontSize,_fontColor,1,"auto","roman","useDominantBaseline",0,"on",_letterSpacing/2,_letterSpacing/2);
			
			_selectionElementFormat = new ElementFormat(
				new FontDescription(_fontFamily,_bold?FontWeight.BOLD:FontWeight.NORMAL,_italic?FontPosture.ITALIC:FontPosture.NORMAL),
				_fontSize,_selectionFontColor,1,"auto","roman","useDominantBaseline",0,"on",_letterSpacing/2,_letterSpacing/2);
			
			if(updateShow)
				updateTextShow();
			dispatchEvent(new Event("textFormatChanged"));
		}
		
		
		private var textCache:String = "";
		private function dispatchChange():void
		{
			if(text != textCache)
			{
				this.dispatchEvent(new Event(Event.CHANGE));
			}
			textCache = text;
		}
		
		private var imeLength:int = 0;
		public function get compositionEndIndex():int
		{
			return selectionBeginIndex+imeLength;
		}
		
		public function get compositionStartIndex():int
		{
			return selectionBeginIndex;
		}
		
		public function confirmComposition(text:String=null, preserveSelection:Boolean=false):void
		{
			imeLength = 0;
		}
		
		/**
		 *  得到一个字符在舞台上的位置和尺寸得到的可能是空，因为有可能该字符所在行不显示。 
		 * @param charIndex索引
		 * @param adjustToLineHeight 调整到行的高度，如果为false则精确到字符尺寸
		 * @return 
		 * 
		 */		
		public function getCharStageBoundaries(charIndex:int,adjustToLineHeight:Boolean = false):Rectangle
		{
			var targetBounds:Rectangle;
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				var textDataLine:TextDataInfo = textLineDatas[textLineViews[i].textDataIndex];
				if(charIndex >= textDataLine.firstAtomIndex && charIndex < textDataLine.firstAtomIndex+textDataLine.length)
				{
					var textLineInfo:TextLineInfo = textLineViews[i];
					
					if(charIndex-textDataLine.firstAtomIndex<textLineInfo.length)
					{
						targetBounds = textLineInfo.content.getAtomBounds(charIndex-textDataLine.firstAtomIndex);
					}else
					{
						targetBounds = textLineInfo.content.getAtomBounds(textLineInfo.length-1);
					}
					break;
				}
			}
			if(targetBounds)
			{
				var minPoint:Point = new Point(targetBounds.x,targetBounds.y);
				var maxPoint:Point = new Point(targetBounds.x+targetBounds.width,targetBounds.y+targetBounds.height);
				minPoint = textLineInfo.content.localToGlobal(minPoint);
				maxPoint = textLineInfo.content.localToGlobal(maxPoint);
				if(adjustToLineHeight)
				{
					var minY:int = textLineInfo.content.y-getTextLineOffsetY(textLineInfo.content);
					var maxY:int = textLineInfo.content.y-getTextLineOffsetY(textLineInfo.content)+actualLineHeight;
					minPoint = this.globalToLocal(minPoint);
					maxPoint = this.globalToLocal(maxPoint);
					minPoint.y = minY;
					maxPoint.y = maxY;
					minPoint = this.localToGlobal(minPoint);
					maxPoint = this.localToGlobal(maxPoint);
				}
				var globalRect:Rectangle = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
				return globalRect;
			}
			return null;
		}
		
		public function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			var pointA1:Point = new Point(0,0);
			var pointA2:Point = new Point(0,0);
			var pointB1:Point = new Point(this.width,this.height);
			var pointB2:Point = new Point(this.width,this.height);
			
			var startBounds:Rectangle;
			var startGlobalBounds:Rectangle;
			var endBounds:Rectangle;
			var endGlobalBounds:Rectangle;
			for(var i:int = 0;i<textLineViews.length;i++)
			{
				var textDataLine:TextDataInfo = textLineDatas[textLineViews[i].textDataIndex];
			
				if(startIndex >= textDataLine.firstAtomIndex && startIndex < textDataLine.firstAtomIndex+textDataLine.length)
				{
					var startLineInfo:TextLineInfo = textLineViews[i];
					if(startIndex-textDataLine.firstAtomIndex<startLineInfo.length)
					{
						startBounds = startLineInfo.content.getAtomBounds(startIndex-textDataLine.firstAtomIndex);
					}else
					{
						startBounds = startLineInfo.content.getAtomBounds(startLineInfo.length-1);
					}
				}
				if(endIndex >= textDataLine.firstAtomIndex && endIndex < textDataLine.firstAtomIndex+textDataLine.length)
				{
					var endLineInfo:TextLineInfo = textLineViews[i];
					if(endIndex-textDataLine.firstAtomIndex<endLineInfo.length)
					{
						endBounds = endLineInfo.content.getAtomBounds(endIndex-textDataLine.firstAtomIndex);
					}else
					{
						endBounds = endLineInfo.content.getAtomBounds(endLineInfo.length-1);
					}
				}
			}
			
			
			if(startBounds)
			{
				var minPoint:Point = new Point(startBounds.x,startBounds.y);
				var maxPoint:Point = new Point(startBounds.x+startBounds.width,startBounds.y+startBounds.height);
				minPoint = startLineInfo.content.localToGlobal(minPoint);
				maxPoint = startLineInfo.content.localToGlobal(maxPoint);
				var minY:int = startLineInfo.content.y-getTextLineOffsetY(startLineInfo.content);
				var maxY:int = startLineInfo.content.y-getTextLineOffsetY(startLineInfo.content)+actualLineHeight;
				minPoint = this.globalToLocal(minPoint);
				maxPoint = this.globalToLocal(maxPoint);
				minPoint.y = minY;
				maxPoint.y = maxY;
				minPoint = this.localToGlobal(minPoint);
				maxPoint = this.localToGlobal(maxPoint);
				startGlobalBounds = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
			}else
			{
				minPoint = new Point(0,0);
				maxPoint = new Point(this.width,this.height);
				minPoint = this.localToGlobal(minPoint);
				maxPoint = this.localToGlobal(maxPoint);
				startGlobalBounds = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
			}
			
			if(endBounds)
			{
				minPoint = new Point(endBounds.x,endBounds.y);
				maxPoint = new Point(endBounds.x+endBounds.width,endBounds.y+endBounds.height);
				minPoint = endLineInfo.content.localToGlobal(minPoint);
				maxPoint = endLineInfo.content.localToGlobal(maxPoint);
				minY = endLineInfo.content.y-getTextLineOffsetY(endLineInfo.content);
				maxY = endLineInfo.content.y-getTextLineOffsetY(endLineInfo.content)+actualLineHeight;
				minPoint = this.globalToLocal(minPoint);
				maxPoint = this.globalToLocal(maxPoint);
				minPoint.y = minY;
				maxPoint.y = maxY;
				minPoint = this.localToGlobal(minPoint);
				maxPoint = this.localToGlobal(maxPoint);
				endGlobalBounds = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
			}else
			{
				minPoint = new Point(0,0);
				maxPoint = new Point(this.width,this.height);
				minPoint = this.localToGlobal(minPoint);
				maxPoint = this.localToGlobal(maxPoint);
				endGlobalBounds = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
			}

			minPoint.x = Math.min(startGlobalBounds.x,endGlobalBounds.x);
			minPoint.y = Math.min(startGlobalBounds.y,endGlobalBounds.y);
			maxPoint.x = Math.max(startGlobalBounds.x+startGlobalBounds.width,endGlobalBounds.x+endGlobalBounds.width)
			maxPoint.y = Math.max(startGlobalBounds.y+startGlobalBounds.height,endGlobalBounds.y+endGlobalBounds.height);
			
			minPoint = this.globalToLocal(minPoint);
			maxPoint = this.globalToLocal(maxPoint);
			var finalGlobalBounds:Rectangle = new Rectangle(minPoint.x,minPoint.y,maxPoint.x-minPoint.x,maxPoint.y-minPoint.y);
			
			var tempRect:Rectangle = getCharStageBoundaries(this.selectionEndIndex,true);
			if(tempRect)
			{
				minPoint.x = tempRect.x;
				minPoint.y = tempRect.y;
				minPoint = this.globalToLocal(minPoint);
				tempRect.x = minPoint.x;
				tempRect.y = minPoint.y;
				return tempRect;
			}
			
			return finalGlobalBounds;
		}
		
		public function getTextInRange(startIndex:int, endIndex:int):String
		{
			return text.slice(startIndex,endIndex);
		}
		
		public function selectRange(anchorIndex:int, activeIndex:int):void
		{
			this.setSelection(anchorIndex,activeIndex);
		}
		
		public function get selectionActiveIndex():int
		{
			return selectionEndIndex;
		}
		
		public function get selectionAnchorIndex():int
		{
			return selectionBeginIndex;
		}
		
		public function updateComposition(text:String, attributes:Vector.<CompositionAttributeRange>, compositionStartIndex:int, compositionEndIndex:int):void
		{
			imeLength = text.length;
		}
		
		public function get verticalTextLayout():Boolean
		{
			return false;
		}
		
	}
}