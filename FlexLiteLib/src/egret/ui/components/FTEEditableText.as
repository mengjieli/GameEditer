package egret.ui.components
{
	import flash.display.NativeMenu;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextFormatAlign;
	
	import egret.components.supportClasses.TextBase;
	import egret.core.GlobalStyles;
	import egret.core.IDisplayText;
	import egret.core.IEditableText;
	import egret.core.IViewport;
	import egret.core.NavigationUnit;
	import egret.core.UIComponent;
	import egret.core.ns_egret;
	import egret.layouts.VerticalAlign;
	import egret.ui.core.UIFTETextField;

	use namespace ns_egret;
	
	/**
	 * 当控件中的文本通过用户输入发生更改后分派。使用代码更改文本时不会引发此事件。 
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 当控件中的文本通过用户输入发生更改之前分派。但是当用户按 Delete 键或 Backspace 键时，不会分派任何事件。
	 * 可以调用preventDefault()方法阻止更改。  
	 */	
	[Event(name="textInput", type="flash.events.TextEvent")]
	
	public class FTEEditableText extends UIComponent implements IEditableText,IDisplayText,IViewport
	{
		public function FTEEditableText()
		{
			super();
			this.hasNoStyleChild = true;
			selectable = true;
		}
		
		/**
		 * 默认的文本测量宽度 
		 */		
		public static const DEFAULT_MEASURED_WIDTH:Number = 160;
		/**
		 * 默认的文本测量高度
		 */		
		public static const DEFAULT_MEASURED_HEIGHT:Number = 22;
		
		/**
		 * 呈示此文本的内部 TextField 
		 */		
		protected var textField:UIFTETextField;
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			if(this.defaultStyleChanged)
			{
				return;
			}
			this.defaultStyleChanged = true;
			this.invalidateProperties();
			this.invalidateSize();
			this.invalidateDisplayList();
			if(!styleProp||styleProp=="size")
			{
				heightInLinesChanged = true;
				widthInCharsChanged = true;
			}
		}
		
		/**
		 * @inheritDoc
		 */	
		override public function set enabled(value:Boolean):void
		{
			if(super.enabled==value)
				return;
			super.enabled = value;
			if(enabled)
			{
				if(_selectable != pendingSelectable)
					selectableChanged = true;
				_selectable = pendingSelectable;
				if(_editable!=pendingEditable)
					editableChanged = true;
				_editable = pendingEditable;
			}
			else
			{
				if(_selectable)
					selectableChanged = true;
				pendingSelectable = _selectable;
				_selectable = false;
				if(editable)
					editableChanged = true;
				pendingEditable = _editable;
				_editable = false;
			}
			invalidateProperties();
		}
		
		//===========================字体样式=====================start==========================
		
		ns_egret var defaultStyleChanged:Boolean = true;
		
		private var _fontFamily:String = GlobalStyles.fontFamily;
		
		/**
		 * 字体名称 。默认值：SimSun
		 */
		public function get fontFamily():String
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["fontFamily"]!==undefined){
				return chain["fontFamily"];
			}
			return this._fontFamily;
		}
		
		public function set fontFamily(value:String):void
		{
			setStyle("fontFamily",value);
		}
		
		private var _size:uint = GlobalStyles.size;
		
		/**
		 * 字号大小,默认值12 。
		 */
		public function get size():uint
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["size"]!==undefined){
				return chain["size"];
			}
			return this._size;
		}
		
		public function set size(value:uint):void
		{
			setStyle("size",value);
		}
		
		private var _bold:Boolean = false;
		
		/**
		 * 是否为粗体,默认false。
		 */
		public function get bold():Boolean
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["bold"]!==undefined){
				return chain["bold"];
			}
			return this._bold;
		}
		
		public function set bold(value:Boolean):void
		{
			setStyle("bold",value);
		}
		
		private var _italic:Boolean = false;
		
		/**
		 * 是否为斜体,默认false。
		 */
		public function get italic():Boolean
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["italic"]!==undefined){
				return chain["italic"];
			}
			return this._italic;
		}
		
		public function set italic(value:Boolean):void
		{
			setStyle("italic",value);
		}
		
		private var _textAlign:String = TextFormatAlign.LEFT;
		
		/**
		 * 文字的水平对齐方式 ,请使用TextFormatAlign中定义的常量。
		 * 默认值：TextFormatAlign.LEFT。
		 */
		public function get textAlign():String
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["textAlign"]!==undefined){
				return chain["textAlign"];
			}
			return this._textAlign;
		}
		
		public function set textAlign(value:String):void
		{
			setStyle("textAlign",value);
		}
		
		private var _leading:int = 2;
		
		/**
		 * 行距,默认值为2。
		 */
		public function get leading():int
		{
			return _leading;
		}
		
		public function set leading(value:int):void
		{
			if(_leading==value)
				return;
			_leading = value;
			if(textField)
				textField.leading = realLeading;
			defaultStyleChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			heightInLinesChanged = true;
		}
		
		ns_egret function get realLeading():int
		{
			return _leading;
		}
		
		private var _textColor:uint = GlobalStyles.textColor;
		/**
		 * @inheritDoc
		 */
		public function get textColor():uint
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["textColor"]!==undefined){
				return chain["textColor"];
			}
			return this._textColor;
		}
		
		public function set textColor(value:uint):void
		{
			setStyle("textColor",value);
		}
		
		private var _letterSpacing:Number = NaN;
		
		/**
		 * 字符间距,默认值为NaN。
		 */
		public function get letterSpacing():Number
		{
			return _letterSpacing;
		}
		
		public function set letterSpacing(value:Number):void
		{
			if(_letterSpacing==value)
				return;
			_letterSpacing = value;
			defaultStyleChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * 从另外一个文本组件复制默认文字格式信息到自身。<br/>
		 * 复制的值包含：<br/>
		 * fontFamily，size，textColor，bold，italic，underline，textAlign，<br/>
		 * leading，letterSpacing
		 */		
		public function copyDefaultFormatFrom(textBase:TextBase):void
		{
			fontFamily = textBase.fontFamily;
			size = textBase.size;
			textColor = textBase.textColor;
			bold = textBase.bold;
			italic = textBase.italic;
			textAlign = textBase.textAlign;
			leading = textBase.leading;
			letterSpacing = textBase.letterSpacing;
		}
		
		private var pendingSelectable:Boolean = false;
		
		private var _selectable:Boolean = false;
		
		private var selectableChanged:Boolean;
		
		/**
		 * 指定是否可以选择文本。允许选择文本将使您能够从控件中复制文本。 
		 */		
		public function get selectable():Boolean
		{
			if(enabled)
				return _selectable;
			return pendingSelectable;
		}
		
		public function set selectable(value:Boolean):void
		{
			if (value == selectable)
				return;
			if(enabled)
			{
				_selectable = value;
				selectableChanged = true;
				invalidateProperties();
			}
			else
			{
				pendingSelectable = value;
			}
		}
		
		ns_egret var _text:String = "";
		
		ns_egret var textChanged:Boolean = false;
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			if (value==null)
				value = "";
			
			_text = value;
			if(textField)
				textField.text = _text;
			textChanged = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		ns_egret var _textHeight:Number;
		
		/**
		 * 文本高度
		 */		
		public function get textHeight():Number
		{
			validateNowIfNeed();
			return _textHeight;
		}
		
		ns_egret var _textWidth:Number;
		
		/**
		 * 文本宽度
		 */		
		public function get textWidth():Number
		{
			validateNowIfNeed();
			return _textWidth;
		}
		
		/**
		 * 由于组件是延迟应用属性的，若需要在改变文本属性后立即获得正确的值，要先调用validateNow()方法。
		 */		
		private function validateNowIfNeed():void
		{
			if(invalidatePropertiesFlag||invalidateSizeFlag||invalidateDisplayListFlag)
				validateNow();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!textField)
			{
				checkTextField();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			
			if(!textField)
			{
				editableChanged = true;
				displayAsPasswordChanged = true;
				maxCharsChanged = true;
				multilineChanged = true;
				restrictChanged = true;
			}
			
			super.commitProperties();
			if(!textField)
			{
				checkTextField();
			}
			if (selectableChanged)
			{
				textField.selectable = _selectable;
				selectableChanged = false;
			}
			if(defaultStyleChanged)
			{
				textField.fontFamily = fontFamily;
				textField.fontSize = size;
				textField.bold = bold;
				textField.italic = italic;
				textField.align = textAlign;
				textField.leading = leading;
				textField.letterSpacing = letterSpacing;
				textField.fontColor = textColor;
				textField.ibeamColor = textColor;
			}
			if (textChanged)
			{
				textFieldChanged(true);
				textChanged = false;
			}
			
			if(editableChanged)
			{
				textField.editable = _editable;
				editableChanged = false;
			}
			
			if (displayAsPasswordChanged)
			{
				textField.displayAsPassword = _displayAsPassword;
				displayAsPasswordChanged = false;
			}
			if(maxCharsChanged)
			{
				textField.maxChars = _maxChars;
				maxCharsChanged = false;
			}
			
			if(multilineChanged)
			{
				textField.multiline = _multiline;
				textField.wordWrap = _multiline;
				multilineChanged = false;
			}
			
			if (restrictChanged)
			{
				textField.restrict = _restrict;
				
				restrictChanged = false;
			}
			
			if(heightInLinesChanged)
			{
				heightInLinesChanged = false;
				if(isNaN(_heightInLines))
				{
					defaultHeight = NaN;
				}
				else
				{
					var hInLine:int = int(heightInLines);
					var lineHeight:Number = 22;
					if(textField.length>0)
					{
						lineHeight = textField.actualLineHeight;
					}
					else
					{
						lineHeight = textField.actualLineHeight;
					}
					defaultHeight = hInLine*lineHeight+4;
				}
			}
			
			if(widthInCharsChanged)
			{
				widthInCharsChanged = false;
				if(isNaN(_widthInChars))
				{
					defaultWidth = NaN;
				}
				else
				{
					var wInChars:int = int(_widthInChars);
					defaultWidth = size*wInChars+5;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function setFocus():void
		{
			if(textField&&stage)
			{
				stage.focus = textField;
			}
		}
		/**
		 * 检查是否创建了textField对象，没有就创建一个。
		 */		
		private function checkTextField():void
		{
			if(!textField)
			{
				createTextField();
				textField.text = _text;
				textField.leading = realLeading;
				selectableChanged = true;
				textChanged = true;
				defaultStyleChanged = true;
				invalidateProperties();
			}
		}
		
		/**
		 * 创建文本显示对象
		 */		
		protected function createTextField():void
		{   
			textField = new UIFTETextField();
			if(customMenu)
				textField.contextMenu = customMenu;
			textField.selectable = selectable;
			textField.ibeamWidth = 1;
			
			textField.addEventListener("textChanged",
				textField_textModifiedHandler);
			textField.addEventListener("widthChanged",
				textField_textFieldSizeChangeHandler);
			textField.addEventListener("heightChanged",
				textField_textFieldSizeChangeHandler);
			
			addToDisplayList(textField);
			
			textField.editable = _editable;
			textField.multiline = _multiline;
			textField.wordWrap = _multiline;
			textField.addEventListener(Event.CHANGE, textField_changeHandler);
			textField.addEventListener(Event.SCROLL, textField_scrollHandler);
			textField.addEventListener(TextEvent.TEXT_INPUT,
				textField_textInputHandler);
			if(_clipAndEnableScrolling)
			{
				textField.scrollH = _horizontalScrollPosition;
				textField.scrollV = getScrollVByVertitcalPos(_verticalScrollPosition);
			}
		}
		
		private var customMenu:NativeMenu;
		override public function set contextMenu(cm:NativeMenu):void
		{
			if(textField)
				textField.contextMenu = cm;
			else
				customMenu = cm;
		}
		
		override public function get contextMenu():NativeMenu
		{
			if(textField)
				return textField.contextMenu;
			return customMenu;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			measuredWidth = isNaN(defaultWidth)? DEFAULT_MEASURED_WIDTH:defaultWidth;
			if(_maxChars!=0)
			{
				measuredWidth = Math.min(measuredWidth,textField.textWidth);
			}
			if(_multiline)
			{
				measuredHeight = isNaN(defaultHeight)?DEFAULT_MEASURED_HEIGHT*2:defaultHeight;
			}
			else
			{
				measuredHeight = textField.textHeight;
			}
		}
		
		/**
		 * 更新显示列表
		 */		
		final ns_egret function $updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			isValidating = true;
			var oldScrollH:int = textField.scrollH;
			var oldScrollV:int = textField.scrollV;
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			textField.x = 0;
			textField.y = 0;
			textField.width = unscaledWidth;
			textField.height = unscaledHeight;
			_textWidth = textField.textWidth;
			_textHeight = textField.textHeight;
			
			updateContentSize();
			
			textField.scrollH = oldScrollH;
			textField.scrollV = oldScrollV;
			textField.x = 0;
			textField.y = 0;
			if(textField.textHeight<unscaledHeight)
			{
				var valign:Number = 0;
				if(verticalAlign==VerticalAlign.MIDDLE)
					valign = 0.5;
				else if(verticalAlign==VerticalAlign.BOTTOM)
					valign = 1;
				textField.y += Math.floor((unscaledHeight-textField.textHeight)*valign);
			}
			
			isValidating = false;
		}
		
		/**
		 * 文本显示对象属性改变
		 */		
		protected function textFieldChanged(styleChangeOnly:Boolean):void
		{
			if (!styleChangeOnly)
			{
				_text = textField.text;
			}
			_textWidth = textField.textWidth;
			_textHeight = textField.textHeight;
		}
		
		/**
		 * 文字内容发生改变
		 */		
		ns_egret function textField_textModifiedHandler(event:Event):void
		{
			textFieldChanged(false);
			invalidateSize();
			invalidateDisplayList();
		}
		/**
		 * 标签尺寸发生改变
		 */		
		private function textField_textFieldSizeChangeHandler(event:Event):void
		{
			textFieldChanged(true);
			invalidateSize();
			invalidateDisplayList();
		}   
		/**
		 * 文字格式发生改变
		 */		
		private function textField_textFormatChangeHandler(event:Event):void
		{
			textFieldChanged(true);
			invalidateSize();
			invalidateDisplayList();
		}
		private var _displayAsPassword:Boolean = false;
		
		private var displayAsPasswordChanged:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get displayAsPassword():Boolean
		{
			return _displayAsPassword;
		}
		
		public function set displayAsPassword(value:Boolean):void
		{
			if(value == _displayAsPassword)
				return;
			_displayAsPassword = value;
			displayAsPasswordChanged = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var pendingEditable:Boolean = true;
		
		private var _editable:Boolean = true;
		
		private var editableChanged:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get editable():Boolean
		{
			if(enabled)
				return _editable;
			return pendingEditable;
		}
		
		public function set editable(value:Boolean):void
		{
			if(_editable==value)
				return;
			if(enabled)
			{
				_editable = value;
				editableChanged = true;
				invalidateProperties();
			}
			else
			{
				pendingEditable = value;
			}
		}
		
		private var _maxChars:int = 0;
		
		private var maxCharsChanged:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get maxChars():int
		{
			return _maxChars;
		}
		
		public function set maxChars(value:int):void
		{
			if(value==_maxChars)
				return;
			_maxChars = value;
			maxCharsChanged = true;
			invalidateProperties();
		}
		
		private var _multiline:Boolean = true;
		
		private var multilineChanged:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get multiline():Boolean
		{
			return _multiline;
		}
		
		public function set multiline(value:Boolean):void
		{
			if(value==multiline)
				return;
			_multiline = value;
			multilineChanged = true;
			invalidateProperties();
		}
		
		private var _restrict:String = null;
		
		private var restrictChanged:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get restrict():String
		{
			return _restrict;
		}
		
		public function set restrict(value:String):void
		{
			if (value == _restrict)
				return;
			
			_restrict = value;
			restrictChanged = true;
			
			invalidateProperties();
		}
		
		private var _heightInLines:Number = NaN;
		
		private var heightInLinesChanged:Boolean = false;
		
		/**
		 * 控件的默认高度（以行为单位测量）。 若设置了multiline属性为false，则忽略此属性。
		 */		
		public function get heightInLines():Number
		{
			return _heightInLines;
			
		}
		
		public function set heightInLines(value:Number):void
		{
			if(_heightInLines == value)
				return;
			_heightInLines = value;
			heightInLinesChanged = true;
			
			invalidateProperties();
		}
		
		
		private var _widthInChars:Number = NaN;
		
		private var widthInCharsChanged:Boolean = false;
		
		/**
		 * 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
		 */		
		public function get widthInChars():Number
		{
			return _widthInChars;
		}
		
		public function set widthInChars(value:Number):void
		{
			if(_widthInChars==value)
				return;
			_widthInChars = value;
			widthInCharsChanged = true;
			
			invalidateProperties();
		}
		
		private var _contentWidth:Number = 0;
		
		public function get contentWidth():Number
		{
			return _contentWidth;
		}
		
		private function setContentWidth(value:Number):void
		{
			if (value == _contentWidth)
				return;
			var oldValue:Number = _contentWidth;
			_contentWidth = value;
			dispatchPropertyChangeEvent("contentWidth", oldValue, value); 
		}
		
		private var _contentHeight:Number = 0;
		
		public function get contentHeight():Number
		{
			return _contentHeight;
		}
		
		private function setContentHeight(value:Number):void
		{
			if (value == _contentHeight)
				return;
			var oldValue:Number = _contentHeight;
			_contentHeight = value;
			dispatchPropertyChangeEvent("contentHeight", oldValue, value); 
		}
		
		private var _horizontalScrollPosition:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get horizontalScrollPosition():Number
		{
			return _horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number):void
		{
			if(_horizontalScrollPosition == value)
				return;
			value = Math.round(value);
			var oldValue:Number = _horizontalScrollPosition;
			_horizontalScrollPosition = value;
			if (_clipAndEnableScrolling)
			{
				if(textField)
					textField.scrollH = value;
				dispatchPropertyChangeEvent("horizontalScrollPosition",oldValue,value);
			}
		}
		private var _verticalScrollPosition:Number = 0
		/**
		 * @inheritDoc
		 */
		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number):void
		{
			if(_verticalScrollPosition == value)
				return;
			value = Math.round(value);
			var oldValue:Number = _verticalScrollPosition;
			_verticalScrollPosition = value;
			if (_clipAndEnableScrolling)
			{
				if (textField)
					textField.scrollV = getScrollVByVertitcalPos(value);
				dispatchPropertyChangeEvent("verticalScrollPosition",oldValue,value);
			}
		}	
		
		/**
		 * 根据垂直像素位置获取对应的垂直滚动位置
		 */		
		private function getScrollVByVertitcalPos(value:Number):int
		{
			if(textField.numLines==0)
				return 0;
			var lineHeight:Number = textField.actualLineHeight+textField.leading;
			if(textField.textHeight - height == value)
			{
				return textField.maxScrollV;
			}
			return int((value+textField.leading)/lineHeight);
		}
		/**
		 * 根据垂直滚动位置获取对应的垂直像位置
		 */		
		private function getVerticalPosByScrollV(scrollV:int):Number
		{
			if(scrollV == 0||textField.numLines == 0)
				return 0;
			var lineHeight:Number = textField.actualLineHeight+_leading;
			if(scrollV == textField.maxScrollV)
			{
				return textField.textHeight -height;
			}
			return lineHeight*(scrollV)-textField.leading;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
		{
			var delta:Number = 0;
			
			var maxDelta:Number = _contentWidth - _horizontalScrollPosition - width;
			var minDelta:Number = -_horizontalScrollPosition;
			
			switch(navigationUnit)
			{
				case NavigationUnit.LEFT:
					delta = _horizontalScrollPosition<=0?0:Math.max(minDelta,-size);
					break;
				case NavigationUnit.RIGHT:
					delta = (_horizontalScrollPosition+width >= contentWidth) ? 0 : Math.min(maxDelta, size);
					break;
				case NavigationUnit.PAGE_LEFT:
					delta = Math.max(minDelta, -width);
					break;
				case NavigationUnit.PAGE_RIGHT:
					delta = Math.min(maxDelta, width);
					break;
				case NavigationUnit.HOME:
					delta = minDelta;
					break;
				case NavigationUnit.END:
					delta = maxDelta;
					break;
			}
			return delta;
		}
		
		/**
		 * @inheritDoc
		 */
		public function scrollToRange(beginIndex:int=0,endIndex:int=int.MAX_VALUE):void
		{
			if(endIndex==int.MAX_VALUE)
			{
				endIndex = text.length;
			}
			var beginLineIndex:int = textField.getLineIndexOfChar(beginIndex);
			var endLineIndex:int = textField.getLineIndexOfChar(Math.max(endIndex,0));
			var visibleStartIndex:int = textField.scrollV;
			var visibleEndIndex:int = textField.getLineIndexAtPoint(2,textField.height-2);
			if(endLineIndex>visibleEndIndex)
			{
				visibleStartIndex += endLineIndex - visibleEndIndex;
			}
			if(beginLineIndex<visibleStartIndex)
			{
				visibleStartIndex = beginLineIndex; 
			}
			verticalScrollPosition = getVerticalPosByScrollV(visibleStartIndex);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
		{
			var delta:Number = 0;
			
			var maxDelta:Number = _contentHeight - _verticalScrollPosition - height;
			var minDelta:Number = -_verticalScrollPosition;
			
			switch(navigationUnit)
			{
				case NavigationUnit.UP:
					delta = getVScrollDelta(-1);
					break;
				case NavigationUnit.DOWN:
					delta = getVScrollDelta(1);
					break;
				case NavigationUnit.PAGE_UP:
					delta = Math.max(minDelta, -width);
					break;
				case NavigationUnit.PAGE_DOWN:
					delta = Math.min(maxDelta, width);
					break;
				case NavigationUnit.HOME:
					delta = minDelta;
					break;
				case NavigationUnit.END:
					delta = maxDelta;
					break;
			}
			return delta;
		}
		
		/**
		 * 返回指定偏移行数的滚动条偏移量
		 */		
		private function getVScrollDelta(offsetLine:int):Number
		{
			if(!textField)
				return 0;
			var currentScrollV:int = getScrollVByVertitcalPos(_verticalScrollPosition);
			var scrollV:int = currentScrollV + offsetLine;
			scrollV = Math.max(0,Math.min(textField.maxScrollV,scrollV));
			var startPos:Number = getVerticalPosByScrollV(scrollV);
			var delta:int = startPos-_verticalScrollPosition;
			return delta;
		}
		
		private var _clipAndEnableScrolling:Boolean = false;
		/**
		 * @inheritDoc
		 */
		public function get clipAndEnableScrolling():Boolean
		{
			return _clipAndEnableScrolling;
		}
		
		public function set clipAndEnableScrolling(value:Boolean):void
		{
			if(_clipAndEnableScrolling == value)
				return;
			_clipAndEnableScrolling = value;
			
			if(textField)
			{
				if(value)
				{
					textField.scrollH = _horizontalScrollPosition;
					textField.scrollV = getScrollVByVertitcalPos(_verticalScrollPosition);
					updateContentSize();
				}
				else
				{
					textField.scrollH = 0;
					textField.scrollV = 0;
				}
			}
		}
		
		private var _verticalAlign:String = VerticalAlign.TOP;
		/**
		 * 垂直对齐方式,支持VerticalAlign.TOP,VerticalAlign.BOTTOM,VerticalAlign.MIDDLE,不支持VerticalAlign.JUSTIFY;
		 * 默认值：VerticalAlign.TOP。
		 */
		public function get verticalAlign():String
		{
			var chain:Object = this.styleProtoChain;
			if(chain&&chain["verticalAlign"]!==undefined){
				return chain["verticalAlign"];
			}
			return this._verticalAlign;
		}
		public function set verticalAlign(value:String):void
		{
			setStyle("verticalAlign",value);
		}
		
		/**
		 * 更新内容尺寸大小
		 */		
		private function updateContentSize():void
		{
			if(!clipAndEnableScrolling)
				return;
			setContentWidth(textField.textWidth);
			var contentHeight:Number = 0;
			var numLines:int = textField.numLines;
			if(numLines==0)
			{
				contentHeight = textField.actualLineHeight;
			}
			else
			{
				contentHeight = textField.textHeight;
			}
			setContentHeight(contentHeight);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get selectionBeginIndex():int
		{
			validateProperties();
			if(textField)
				return textField.selectionBeginIndex;
			return 0;
		}
		/**
		 * @inheritDoc
		 */
		public function get selectionEndIndex():int
		{
			validateProperties();
			if(textField)
				return textField.selectionEndIndex;
			return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get caretIndex():int
		{
			validateProperties();
			if(textField)
				return textField.caretIndex;
			return 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setSelection(beginIndex:int,endIndex:int):void
		{
			validateProperties();
			if(textField)
			{
				textField.setSelection(beginIndex,endIndex);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function selectAll():void
		{
			validateProperties();
			if(textField)
			{
				textField.setSelection(0,textField.length);
			}
		}
		
		/**
		 * heightInLines计算出来的默认高度。 
		 */		
		private var defaultHeight:Number = NaN;
		/**
		 * widthInChars计算出来的默认宽度。
		 */		
		private var defaultWidth:Number = NaN;
		
		private function textField_changeHandler(event:Event):void
		{
			textFieldChanged(false);
			event.stopImmediatePropagation();
			dispatchEvent(new Event(Event.CHANGE));
			invalidateSize();
			invalidateDisplayList();
			updateContentSize();
		}
		
		private var isValidating:Boolean = false;
		
		/**
		 *  @private
		 */
		private function textField_scrollHandler(event:Event):void
		{
			if(isValidating)
				return;
			horizontalScrollPosition = textField.scrollH;
			verticalScrollPosition = getVerticalPosByScrollV(textField.scrollV);
		}
		
		/**
		 * 即将输入文字
		 */
		private function textField_textInputHandler(event:TextEvent):void
		{
			event.stopImmediatePropagation();
			
			var newEvent:TextEvent =
				new TextEvent(TextEvent.TEXT_INPUT, false, true);
			newEvent.text = event.text;
			dispatchEvent(newEvent);
			
			if (newEvent.isDefaultPrevented())
				event.preventDefault();
		}
	}
}