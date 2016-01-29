package egret.components.supportClasses
{
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	import egret.core.GlobalStyles;
	import egret.core.IDisplayText;
	import egret.core.UIComponent;
	import egret.core.UITextField;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	[EXML(show="false")]
	
	/**
	 * 文本基类,实现对文本的自动布局，样式属性设置。
	 * @author dom
	 */	
	public class TextBase extends UIComponent implements IDisplayText
	{
		public function TextBase()
		{
			super();
			this.hasNoStyleChild = true;
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
		protected var textField:UITextField;
		
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
		}
		
		private var _condenseWhite:Boolean = false;
		
		private var condenseWhiteChanged:Boolean = false;
		
		/**
		 * 一个布尔值，指定是否删除具有 HTML 文本的文本字段中的额外空白（空格、换行符等等）。
		 * 默认值为 false。condenseWhite 属性只影响使用 htmlText 属性（而非 text 属性）设置的文本。
		 * 如果使用 text 属性设置文本，则忽略 condenseWhite。 <p/>
		 * 如果 condenseWhite 设置为 true，请使用标准 HTML 命令（如 <BR> 和 <P>），将换行符放在文本字段中。<p/>
		 * 在设置 htmlText 属性之前设置 condenseWhite 属性。
		 */		
		public function get condenseWhite():Boolean
		{
			return _condenseWhite;
		}
		
		public function set condenseWhite(value:Boolean):void
		{
			if (value == _condenseWhite)
				return;
			
			_condenseWhite = value;
			condenseWhiteChanged = true;
			
			if (isHTML)
				htmlTextChanged = true;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchEvent(new Event("condenseWhiteChanged"));
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
			}
			else
			{
				if(_selectable)
					selectableChanged = true;
				pendingSelectable = _selectable;
				_selectable = false;
			}
			invalidateProperties();
		}
		
		//===========================字体样式=====================start==========================
		
		ns_egret var defaultStyleChanged:Boolean = true;
		/**
		 * 是否使用嵌入字体
		 */		
		ns_egret var embedFonts:Boolean = false;
		
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
		
		private var _underline:Boolean = false;
		
		/**
		 * 是否有下划线,默认false。
		 */
		public function get underline():Boolean
		{
			return _underline;
		}
		
		public function set underline(value:Boolean):void
		{
			if(_underline==value)
				return;
			_underline = value;
			defaultStyleChanged = true;
			invalidateProperties();
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
		
		ns_egret var _textFormat:TextFormat;
		
		/**
		 * 应用到所有文字的默认文字格式设置信息对象
		 */
		protected function get defaultTextFormat():TextFormat
		{
			if(defaultStyleChanged)
			{
				_textFormat = getDefaultTextFormat();
				defaultStyleChanged = false;
			}
			return _textFormat;
		}
		/**
		 * 由于设置了默认文本格式后，是延迟一帧才集中应用的，若需要立即应用文本样式，可以手动调用此方法。
		 */		
		ns_egret function applyTextFormatNow():void
		{
			if(defaultStyleChanged)
			{
				textField.$setTextFormat(defaultTextFormat);
				textField.defaultTextFormat = defaultTextFormat;
			}
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
			underline = textBase.underline;
			textAlign = textBase.textAlign;
			leading = textBase.leading;
			letterSpacing = textBase.letterSpacing;
		}
		
		/**
		 * 获取文字的默认格式设置信息对象。
		 */		
		public function getDefaultTextFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat(fontFamily,size, textColor, bold, italic, _underline, 
				"", "", textAlign, 0, 0, 0, _leading);
			if(!isNaN(letterSpacing))
			{
				textFormat.kerning = true;
				textFormat.letterSpacing = letterSpacing;
			}
			else
			{
				textFormat.kerning = false;
				textFormat.letterSpacing = null;
			}
			return textFormat;
		}
		
		//===========================字体样式======================end===========================
		
		
		
		
		private var _htmlText:String = "";
		
		ns_egret var htmlTextChanged:Boolean = false;
		
		ns_egret var explicitHTMLText:String = null; 
		
		/**
		 *　HTML文本
		 */		
		public function get htmlText():String
		{
			return _htmlText;
		}
		
		public function set htmlText(value:String):void
		{
			if (!value)
				value = "";
			
			if (isHTML && value == explicitHTMLText)
				return;
			
			_htmlText = value;
			if(textField)
				textField.$htmlText = _htmlText;
			htmlTextChanged = true;
			_text = null;
			
			explicitHTMLText = value;
			
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		/**
		 * 当前是否为html文本
		 */		
		ns_egret function get isHTML():Boolean
		{
			return Boolean(explicitHTMLText);
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
			
			if (!isHTML && value == _text)
				return;
			
			_text = value;
			if(textField)
				textField.$text = _text;
			textChanged = true;
			_htmlText = null;
			
			explicitHTMLText = null;
			
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
			super.commitProperties();
			
			if(!textField)
			{
				checkTextField();
			}
			
			if (condenseWhiteChanged)
			{
				textField.condenseWhite = _condenseWhite;
				
				condenseWhiteChanged = false;
			}
			
			
			if (selectableChanged)
			{
				textField.selectable = _selectable;
				
				selectableChanged = false;
			}
			
			if(defaultStyleChanged)
			{
				textField.$setTextFormat(defaultTextFormat);
				textField.defaultTextFormat = defaultTextFormat;
				textField.embedFonts = embedFonts;
				if(isHTML)
					textField.$htmlText = explicitHTMLText;
			}
			
			if (textChanged || htmlTextChanged)
			{
				textFieldChanged(true);
				textChanged = false;
				htmlTextChanged = false;
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
				if (isHTML)
					textField.$htmlText = explicitHTMLText;
				else
					textField.$text = _text;
				textField.leading = realLeading;
				condenseWhiteChanged = true;
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
			textField = new UITextField;
			textField.blendMode = BlendMode.LAYER;
			textField.selectable = selectable;
			textField.mouseWheelEnabled = false;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			
			textField.addEventListener("textChanged",
				textField_textModifiedHandler);
			textField.addEventListener("widthChanged",
				textField_textFieldSizeChangeHandler);
			textField.addEventListener("heightChanged",
				textField_textFieldSizeChangeHandler);
			textField.addEventListener("textFormatChanged",
				textField_textFormatChangeHandler);
			addToDisplayList(textField);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			super.measure();
			
			measuredWidth = DEFAULT_MEASURED_WIDTH;
			measuredHeight = DEFAULT_MEASURED_HEIGHT;
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
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			textField.x = 0;
			textField.y = 0;
			textField.$width = unscaledWidth;
			textField.$height = unscaledHeight;
			_textWidth = textField.textWidth;
			_textHeight = textField.textHeight;
		}
		
		/**
		 * 返回 TextLineMetrics 对象，其中包含控件中文本位置和文本行度量值的相关信息。
		 * @param lineIndex 要获得其度量值的行的索引（从零开始）。
		 */		
		public function getLineMetrics(lineIndex:int):TextLineMetrics
		{
			validateNowIfNeed();
			return textField ? textField.getLineMetrics(lineIndex) : null;
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
			
			_htmlText = textField.htmlText;
			
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
	}
}