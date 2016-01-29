package egret.text
{
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	
	import egret.core.IViewport;
	import egret.core.NavigationUnit;
	import egret.core.UIComponent;
	import egret.core.ns_egret;
	import egret.text.edit.EditManager;
	import egret.text.edit.SelectionManager;
	import egret.text.events.SelectionEvent;
	import egret.text.events.TextFlowEvent;
	import egret.text.utils.TextLineUtil;
	
	use namespace ns_egret;
	
	/**
	 * 文本编辑器
	 * @author dom
	 */
	public class TextGroup extends UIComponent implements IViewport,ITextContainer
	{
		public function TextGroup()
		{
			super();
			focusEnabled = true;
			init();
		}
		
		protected var backGround:Sprite;
		protected var forwardGround:Sprite;
		protected function init():void
		{
			backGround = new Sprite();
			this.addToDisplayListAt(backGround,0);
			forwardGround = new Sprite();
			this.addToDisplayListAt(forwardGround,1);
			
			currentLineLayer = new Shape();
			backGround.addChild(currentLineLayer);
			selectionLayer = new Shape();
			backGround.addChild(selectionLayer);
			
			createInteractionManager();
			
			textFlow.defaultFormat = getElementFormat();
			textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE,onSelectionChange);
			textFlow.addEventListener(TextFlowEvent.TEXT_CHANGED,onTextLineUpdate);
		}
		
		/**
		 * 得到选择绘制层 
		 */		
		protected function getSelectionLayer():Graphics
		{
			return selectionLayer.graphics;
		}
		/**
		 * 得到当前行的绘制层 
		 */		
		protected function getCurrentLineLayer():Graphics
		{
			return currentLineLayer.graphics;
		}
		
		protected function createInteractionManager():void
		{
			interactionManager = new EditManager(this,textFlow);
		}
		
		protected function onSelectionChange(event:SelectionEvent):void
		{
			_selectionAnchorPosition = event.anchorPosition;
			_selectionActivePosition = event.activePosition;
			invalidateDisplayListExceptLayout();
		}
		/**
		 * 刷新指定的文本行
		 */		
		private function onTextLineUpdate(event:TextFlowEvent):void
		{
			invalidateDisplayList()
		}
		
		protected var interactionManager:SelectionManager;
		private var _contentWidth:Number = 0;
		/**
		 * @inheritDoc
		 */
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
		/**
		 * @inheritDoc
		 */
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
			if(_horizontalScrollPosition==value)
				return;
			var oldValue:Number = _horizontalScrollPosition;
			_horizontalScrollPosition = value;
			dispatchPropertyChangeEvent("horizontalScrollPosition", oldValue, value);
			invalidateDisplayList();
		}
		
		private var _verticalScrollPosition:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number):void
		{
			if(_verticalScrollPosition==value)
				return;
			var oldValue:Number = _verticalScrollPosition;
			_verticalScrollPosition = value;
			dispatchPropertyChangeEvent("verticalScrollPosition", oldValue, value);
			invalidateDisplayList();
		}
		/**
		 * @inheritDoc
		 */
		public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number
		{
			if (!_clipAndEnableScrolling)
				return 0;
			
			if (_horizontalScrollPosition == 0 && width >= _contentWidth)
				return 0;  
			
			var maxDelta:Number = _contentWidth - _horizontalScrollPosition - width;
			var minDelta:Number = -_horizontalScrollPosition;
			var delta:Number = 0;
			switch(navigationUnit)
			{
				case NavigationUnit.LEFT:
					delta = -_lineHeight;
					break;    
				case NavigationUnit.RIGHT:
					delta = _lineHeight;
					break;    
				case NavigationUnit.PAGE_LEFT:
					delta = -width;
					break;
				case NavigationUnit.PAGE_RIGHT:
					delta = width;
					break;
				case NavigationUnit.HOME: 
					return minDelta;
				case NavigationUnit.END: 
					return maxDelta;
				default:
					return 0;
			}
			return Math.min(maxDelta, Math.max(minDelta, delta));
		}
		/**
		 * @inheritDoc
		 */
		public function getVerticalScrollPositionDelta(navigationUnit:uint):Number
		{
			if (!_clipAndEnableScrolling)
				return 0;
			
			if (_verticalScrollPosition == 0 && height >= _contentHeight)
				return 0;  
			
			var maxDelta:Number = _contentHeight - _verticalScrollPosition - height;
			var minDelta:Number = -_verticalScrollPosition;
			var delta:Number = 0;
			switch(navigationUnit)
			{
				case NavigationUnit.UP:
					delta = -_lineHeight;
					break;    
				case NavigationUnit.DOWN:
					delta = _lineHeight;
					break;    
				case NavigationUnit.PAGE_UP:
					delta = -height;
					break;
				case NavigationUnit.PAGE_DOWN:
					delta = height;
					break;
				case NavigationUnit.HOME: 
					return minDelta;
				case NavigationUnit.END: 
					return maxDelta;
				default:
					return 0;
			}
			return Math.min(maxDelta, Math.max(minDelta, delta));
		}
		
		private var _clipAndEnableScrolling:Boolean = true;
		
		public function get clipAndEnableScrolling():Boolean
		{
			return _clipAndEnableScrolling;
		}
		
		public function set clipAndEnableScrolling(value:Boolean):void
		{
			if(_clipAndEnableScrolling==value)
				return;
			_clipAndEnableScrolling = value;
			invalidateDisplayList();
		}
		
		protected var textFlow:TextFlow = new TextFlow();
		
		private var textChanged:Boolean = false;
		/**
		 * 正在编辑的文本内容
		 */
		public function get text():String
		{
			return textFlow.text;
		}
		
		public function set text(value:String):void
		{
			if(!value)
				value = "";
			if(text==value)
				return;
			textFlow.text = value;
			textChanged = true;
			invalidateSize();
			invalidateDisplayList();
		}
		/**
		 * 文本样式发生改变
		 */		
		private var formatChanged:Boolean = false;
		
		private var _fontFamily:String="Arial";
		/**
		 * 字体名称。默认值：Arial
		 */	
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		public function set fontFamily(value:String):void
		{
			if(_fontFamily==value)
				return;
			_fontFamily = value;
			formatChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var _color:uint = 0;
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			if(_color==value)
				return;
			_color = value;
			formatChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		private var _size:int = 14;
		/**
		 * 字号大小，默认值：12。
		 */		
		public function get size():int
		{
			return _size;
		}
		public function set size(value:int):void
		{
			if(_size==value)
				return;
			_size = value;
			formatChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var _tabStop:int = 4;
		/**
		 * 设置一个tab表示多少个空格的长途。默认是4
		 */
		public function get tabStop():int
		{
			return _tabStop;
		}
		
		public function set tabStop(value:int):void
		{
			if(_tabStop==value) return;
			_tabStop = value;
			formatChanged = true;
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		
		private var _selectionActivePosition:int;
		/**
		 * 相对于 text 字符串开头的字符位置，用于指定用箭头键扩展选区时该选区的终点。活动位置可以是选区的起点或终点。
		 * 例如，如果拖动选择位置 12 到位置 8 之间的区域，则 selectionAnchorPosition 将为 12，
		 * selectionActivePosition 将为 8，按向左箭头后 selectionActivePosition 将变为 7。
		 * 值为 -1 时，表示“未设置”。
		 */	
		public function get selectionActivePosition():int
		{
			return _selectionActivePosition;
		}
		
		private var _selectionAnchorPosition:int;
		/**
		 * 相对于 text 字符串开头的字符位置，用于指定用箭头键扩展选区时该选区的终点。活动位置可以是选区的起点或终点。
		 * 例如，如果拖动选择位置 12 到位置 8 之间的区域，则 selectionAnchorPosition 将为 12，
		 * selectionActivePosition 将为 8，按向左箭头后 selectionActivePosition 将变为 7。
		 * 值为 -1 时，表示“未设置”。
		 */		
		public function get selectionAnchorPosition():int
		{
			return _selectionAnchorPosition;
		}
		/**
		 * 选择指定范围的字符。如果任一位置为负，则它将取消选择该文本范围。
		 * @param anchorPosition 字符位置，用于指定扩展选区时保持固定的选区的未端。
		 * @param activePosition 字符位置，用于指定扩展选区时移动的选区的未端。
		 */		
		public function selectRange(anchorPosition:int,activePosition:int):void
		{
			interactionManager.selectRange(anchorPosition,activePosition);
		}
		
		
		private var iBeamShape:Shape = new Shape();
		/**
		 * 是否显示光标
		 */
		public function get showIBeam():Boolean
		{
			return iBeamShape.visible;
		}
		public function set showIBeam(value:Boolean):void
		{
			iBeamShape.visible = value;
		}
		
		/**
		 * 更新文本光标的位置。
		 */		
		public function updateIBeamPosition(x:Number,y:Number):void
		{
			iBeamShape.x = x;
			iBeamShape.y = y;
			drawCurrentLineHightlight();
		}
		
		private var overwriteMode:Boolean = false;
		/**
		 * 更新光标的显示状态，是否是覆盖模式
		 * @param overwriteMode
		 */		
		public function updateIBeamState(overwriteMode:Boolean):void
		{
			this.overwriteMode = overwriteMode;
			updateIBeamStyle();
		}
		
		private function updateIBeamStyle():void
		{
			iBeamShape.blendMode = BlendMode.INVERT;
			var g:Graphics = iBeamShape.graphics;
			g.clear();
			g.beginFill(0x9a8c97,0.95);
			if(!overwriteMode)
			{
				g.drawRect(0,0,2,_lineHeight);
			}else
			{
				g.drawRect(0,0,_lineHeight/2,_lineHeight);
			}
			g.endFill();
			if(!iBeamShape.parent)
				addToDisplayList(iBeamShape);
		}
		
		
		
		private var _lineHeight:Number = 14;
		/**
		 * @inheritDoc
		 */
		public function get lineHeight():Number
		{
			return _lineHeight;
		}
		
		private var elementFormat:ElementFormat;
		/**
		 * 获取文本格式对象
		 */		
		private function getElementFormat():ElementFormat
		{
			if(!elementFormat||formatChanged)
			{
				formatChanged = false;
				elementFormat = new ElementFormat();
				elementFormat.fontDescription = new FontDescription(_fontFamily);
				elementFormat.fontSize = _size;
				elementFormat.color = color;
				_lineHeight = Math.ceil(_size*1.4);
				updateIBeamStyle();
			}
			return elementFormat;
		}
		
		
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(textChanged||formatChanged)
			{
				textChanged = false;
				releaseAllTextLines();
			}
			if(formatChanged)
			{
				textFlow.defaultFormat = getElementFormat();
				textFlow.tabStop = tabStop;
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			super.measure();
			if(invalidatePropertiesFlag)
				validateProperties();
			
			this.measuredWidth = Math.ceil(textFlow.textWidth);
			this.measuredHeight = Math.ceil(_lineHeight*textFlow.numLines);
		}
		
		/**
		 * 在更新显示列表时是否需要更新布局标志 
		 */
		ns_egret var layoutInvalidateDisplayListFlag:Boolean = false;
		
		/**
		 * 标记需要更新显示列表但不需要更新布局
		 */		
		ns_egret function invalidateDisplayListExceptLayout():void
		{
			super.invalidateDisplayList();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function invalidateDisplayList():void
		{
			super.invalidateDisplayList();
			layoutInvalidateDisplayListFlag = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(invalidateSizeFlag)
				validateSize();
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			if(layoutInvalidateDisplayListFlag)
			{
				layoutInvalidateDisplayListFlag = false;
				if (_clipAndEnableScrolling)
				{
					this.scrollRect = new Rectangle(_horizontalScrollPosition, _verticalScrollPosition, unscaledWidth,unscaledHeight);
				}
				else
				{
					this.scrollRect = null;
				}
				drawBackground();
				lastStartIndex = _verticalScrollPosition/_lineHeight;
				lastEndIndex = Math.ceil((unscaledHeight+_verticalScrollPosition)/_lineHeight);
				lastStartIndex = clampToRange(lastStartIndex,textFlow.numLines);
				lastEndIndex = clampToRange(lastEndIndex,textFlow.numLines);
				var oldMaxLineWidth:Number = textFlow.textWidth;
				var t:Number = getTimer();
				textFlow.updateTextLinesInView(lastStartIndex,lastEndIndex);
				updateTextLines(lastStartIndex,lastEndIndex);
				t = getTimer()-t;
				if(t>1)
				{
					//					trace("updateTextLines():"+t+"ms");
				}
				var maxLineWidth:Number = textFlow.textWidth;
				setContentWidth(maxLineWidth);
				setContentHeight(_lineHeight*textFlow.numLines);
				if(oldMaxLineWidth!=maxLineWidth)
				{
					invalidateSize();
				}
			}
			if(getSelectionLayer())
			{
				getSelectionLayer().clear();
				drawSelection(_selectionActivePosition,_selectionAnchorPosition,getSelectionLayer(),0x3399ff);
			}
			drawCurrentLineHightlight();
		}
		
		protected function clampToRange(index:int,length:int):int
		{
			if(index>=length)
				index = length-1;
			if (index < 0)
				index = 0;
			return index;
		}
		
		private var lastStartIndex:int = 0;
		private var lastEndIndex:int = 0;
		private var maxLineWidthChanged:Boolean = false;
		/**
		 * 清理所有TextLines对象
		 */		
		private function releaseAllTextLines():void
		{
			textFlow.releaseAllTextLines();
			lastStartIndex = 0;
			lastEndIndex = 0;
		}
		
		/**
		 * 更新指定范围文本对应的TextLine显示对象
		 * @param startIndex 起始行号(包括)
		 * @param endIndex 结束行号(不包括)
		 */		
		private function updateTextLines(startIndex:int,endIndex:int):void
		{
			for(var index:int=startIndex;index<=endIndex;index++)
			{
				var textLine:TextLine = textFlow.getTextLineAt(index);
				if(!textLine)
				{
					continue;
				}
				if(textLine.parent!=this)
				{
					addToDisplayListAt(textLine,1);
				}
				var textWidth:Number = TextLineUtil.getTextWidth(textLine);
				textLine.y = _lineHeight*(index+0.5)+(textLine.ascent-textLine.descent)*0.5;
			}
		}
		
		
		/**
		 * 绘制鼠标点击区域
		 */		
		private function drawBackground():void
		{
			graphics.clear();
			if (width==0 || height==0)
				return;
			graphics.beginFill(0xFFFFFF, 0);
			if (_clipAndEnableScrolling)
			{
				graphics.drawRect(_horizontalScrollPosition, _verticalScrollPosition, width, height);
			}
			else
			{
				const tileSize:int = 4096;
				for (var x:int = 0; x < width; x += tileSize)
					for (var y:int = 0; y < height; y += tileSize)
					{
						var tileWidth:int = Math.min(width - x, tileSize);
						var tileHeight:int = Math.min(height - y, tileSize);
						graphics.drawRect(x, y, tileWidth, tileHeight); 
					}
			}
			
			graphics.endFill();
		}	
		
		private var selectionLayer:Shape;
		/**
		 * 绘制背景层样式。
		 */		
		protected function drawSelection(activeIndex:int,anchorIndex:int,g:Graphics,fillColor:uint,fillAlpha:Number = 1,strokeColor:uint = 0xf,strokeAlpha:Number = 0):void
		{
			var rects:Vector.<Rectangle> = getLineRects(activeIndex,anchorIndex);
			g.lineStyle(1,strokeColor,strokeAlpha);
			g.beginFill(fillColor,fillAlpha);
			for(var i:int = 0;i<rects.length;i++)
			{
				g.drawRect(rects[i].x,rects[i].y,rects[i].width,rects[i].height);
			}
			g.endFill();
		}
		
		
		/**
		 * 得到指定索引之间的行的矩形数据 
		 * @param activeIndex
		 * @param anchorIndex
		 * @return 
		 */		
		public function getLineRects(activeIndex:int,anchorIndex:int):Vector.<Rectangle>
		{
			var rects:Vector.<Rectangle> = new Vector.<Rectangle>();
			if(activeIndex==anchorIndex)
				return rects;
			var selectedStartIndex:int = Math.min(activeIndex,anchorIndex);
			var selectedEndIndex:int = Math.max(activeIndex,anchorIndex);
			var startLineIndex:int = textFlow.findLineIndexAtPosition(selectedStartIndex);
			var endLineIndex:int = textFlow.findLineIndexAtPosition(selectedEndIndex);
			if(lastStartIndex>endLineIndex||lastEndIndex<startLineIndex)
			{
				return rects;
			}
			var startIndex:int = Math.max(lastStartIndex,startLineIndex);
			var endIndex:int = Math.min(lastEndIndex,endLineIndex);
			var unscaleWidth:Number = Math.max(this.layoutBoundsWidth,this.contentWidth)
			var unscaleHeight:Number = this.contentHeight;
			if(startIndex==endIndex)
			{
				var textLine:TextLine = textFlow.getTextLineAt(startIndex,false);
				var index:int = textLine?textLine.getAtomIndexAtCharIndex(
					selectedStartIndex-textFlow.findStartOfLine(startIndex)):-1;
				if(index!=-1)
				{
					var textLineWidth:Number = TextLineUtil.getTextWidth(textLine);
					var bounds:Rectangle = textLine.getAtomBounds(index);
					index = textLine.getAtomIndexAtCharIndex(selectedEndIndex-textFlow.findStartOfLine(endIndex));
					if(index!=-1)
					{
						var endBounds:Rectangle = textLine.getAtomBounds(index);
						rects.push(new Rectangle(bounds.x,endIndex*_lineHeight,endBounds.x-bounds.x,_lineHeight));
					}
					else
					{
						rects.push(new Rectangle(bounds.x,startIndex*_lineHeight,textLineWidth-bounds.x,_lineHeight));
					}
				}
				return rects;
			}
			//绘制第一行
			if(startIndex==startLineIndex)
			{
				textLine = textFlow.getTextLineAt(startIndex,false);
				if(textLine)
				{
					textLineWidth = TextLineUtil.getTextWidth(textLine);
					index = textLine.getAtomIndexAtCharIndex(selectedStartIndex-textFlow.findStartOfLine(startIndex));
					if(index!=-1)
					{
						bounds = textLine.getAtomBounds(index);
						rects.push(new Rectangle(bounds.x,startIndex*_lineHeight,unscaleWidth-bounds.x,_lineHeight));
					}
					else
					{
						rects.push(new Rectangle(textLineWidth,startIndex*_lineHeight,unscaleWidth-textLine.width,_lineHeight));
					}
				}
				else
				{
					startIndex--;
				}
			}
			else
			{
				startIndex--;
			}
			//绘制最后一行
			if(endIndex==endLineIndex)
			{
				textLine = textFlow.getTextLineAt(endIndex,false);
				if(textLine)
				{
					textLineWidth = TextLineUtil.getTextWidth(textLine);
					index = textLine.getAtomIndexAtCharIndex(selectedEndIndex-textFlow.findStartOfLine(endIndex));
					if(index!=-1)
					{
						bounds = textLine.getAtomBounds(index);
						rects.push(new Rectangle(0,endIndex*_lineHeight,bounds.x,_lineHeight));
					}
					else
					{
						rects.push(new Rectangle(0,endIndex*_lineHeight,textLineWidth,_lineHeight));
					}
				}
			}
			else
			{
				endIndex++;
			}
			for(var i:int=startIndex+1;i<endIndex;i++)
			{
				rects.push(new Rectangle(0,i*_lineHeight,unscaleWidth,_lineHeight));
			}
			return rects;
		}
		
		
		
		private var currentLineLayer:Shape;
		/**
		 * 绘制当前行突出显示颜色
		 * 
		 */		
		private function drawCurrentLineHightlight():void
		{
			var selectedStartIndex:int = Math.min(_selectionActivePosition,_selectionAnchorPosition);
			var selectedEndIndex:int = Math.max(_selectionActivePosition,_selectionAnchorPosition);
			var startLineIndex:int = textFlow.findLineIndexAtPosition(selectedStartIndex);
			var endLineIndex:int = textFlow.findLineIndexAtPosition(selectedEndIndex);
			var startIndex:int = Math.max(lastStartIndex,startLineIndex);
			var endIndex:int = Math.min(lastEndIndex,endLineIndex);
			var g:Graphics = getCurrentLineLayer();
			if(g)
			{
				g.clear();
				if(startIndex == endIndex)
				{
					g.beginFill(0x3a503f);
					var unscaleWidth:Number = Math.max(this.layoutBoundsWidth,this.contentWidth)
					g.drawRect(0,startIndex*_lineHeight,unscaleWidth,_lineHeight);
					g.endFill();
				}
			}
		}
		
		/**
		 * 得到指定位置字符的尺寸，有可能返回的是null 
		 * @param index
		 * @return 
		 * 
		 */		
		public function getCharStageBoundaries(index:int):Rectangle
		{
			var textLineIndex:int = textFlow.findLineIndexAtPosition(index);
			var textLine:TextLine = textFlow.getTextLineAt(textLineIndex,false);
			var index:int = textLine?textLine.getAtomIndexAtCharIndex(
				index-textFlow.findStartOfLine(textLineIndex)):-1;
			if(index!=-1)
			{
				var textLineWidth:Number = TextLineUtil.getTextWidth(textLine);
				var bounds:Rectangle = textLine.getAtomBounds(index);
				bounds = new Rectangle(bounds.x,textLineIndex*_lineHeight,bounds.width,_lineHeight);
				var pos1:Point = new Point(bounds.x,bounds.y);
				var pos2:Point = new Point(bounds.x+bounds.width,bounds.y+bounds.height);
				pos1 = this.localToGlobal(pos1);
				pos2 = this.localToGlobal(pos2);
				bounds = new Rectangle(pos1.x,pos1.y,pos2.x-pos1.x,pos2.y-pos1.y);
				return bounds;
			}
			return null;
		}
	}
}