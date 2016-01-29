package egret.text.edit
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.ui.ContextMenu;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import egret.core.ns_egret;
	import egret.text.ITextContainer;
	import egret.text.TextFlow;
	import egret.text.events.SelectionEvent;
	import egret.text.events.TextFlowEvent;
	import egret.text.utils.NavigationUtil;
	import egret.text.utils.TextLineUtil;
	
	use namespace ns_egret;
	/**
	 * 选择管理器
	 * @author dom
	 */
	public class SelectionManager extends EventDispatcher implements ISelectionManager
	{
		/**
		 * 构造函数
		 * @param container 文本容器，除了实现ITextcontainer必须同时是Sprite的子类。
		 * @param textFlow 文本流对象
		 */		
		public function SelectionManager(textContainer:ITextContainer,textFlow:TextFlow)
		{
			super();
			this.textContainer = textContainer;
			this.container = textContainer as Sprite;
			if(!this.container)
			{
				throw new Error("实现ITextContainer接口的容器必须同时是Sprite的子类！");
			}
			this.textFlow = textFlow;
			this.textFlow.addEventListener(TextFlowEvent.TEXT_CHANGED,onTextChanged);
			textFlow.interactionManager = this;
			container.mouseChildren = false;
			attachContextMenu();
			attachInteractionHandlers();
		}
		
		private function onTextChanged(event:TextFlowEvent):void
		{
			updateIBeamState();
		}
		
		protected var container:Sprite;
		/**
		 * 文本容器
		 */		
		protected var textContainer:ITextContainer;
		
		private var _textFlow:TextFlow;
		
		public function get textFlow():TextFlow
		{
			return _textFlow;
		}
		
		public function set textFlow(value:TextFlow):void
		{
			if(_textFlow==value)
				return;
			if(_textFlow)
				flushPendingOperations();
			_textFlow = value;
			selectRange(0,0);
			allowOperationMerge = false;
		}
		/**
		 * 文本编辑模式
		 */		
		public function get editingMode():String
		{
			return EditingMode.READ_SELECT;
		} 
		public function set editingMode(value:String):void
		{
			
		}
		
		private var _anchorPosition:int = 0;
		/** 
		 * 选择部分的锚点。
		 * 锚点是选择部分的固定终点。当扩展选择部分时，锚点不会随之改变。锚点可以位于当前选择的起始或结束位置。
		 */		
		public function get anchorPosition() : int
		{
			return _anchorPosition;
		}
		
		private var _activePosition:int = 0;
		/** 
		 * 选择部分的活动点。
		 * 活动点是选择部分的不定终点。活动点随选择的修改而改变。活动点可以位于当前选择的起始或结束位置。
		 */	
		public function get activePosition() : int
		{
			return _activePosition;         
		}
		/**
		 * 选择部分开头的文本位置，是自文本流起始位置的偏移。
		 * 绝对起点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠前。
		 */	
		public function get absoluteStart() : int
		{
			return (_anchorPosition < _activePosition) ? _anchorPosition : _activePosition;
		}
		/**
		 * 选择部分末尾的文本位置，是自文本流起始位置的偏移。
		 * 绝对终点与选择部分的活动点或锚点相同，具体取决于哪一个在文本流中更靠后。
		 */	
		public function get absoluteEnd() : int
		{
			return (_anchorPosition > _activePosition) ? _anchorPosition : _activePosition;
		}
		/**
		 * 是否选择了文本
		 */		
		public function hasSelection():Boolean
		{ 
			return _anchorPosition != -1; 
		}
		
		
		protected var ignoreNextTextEvent:Boolean = false;
		
		protected var allowOperationMerge:Boolean = false;
		
		private var skipMarkSelectionChange:Boolean = false;
		/**
		 * 选择某一范围的文本。如果任一参数值为负值，则会删除任何已经选择的部分。
		 * @param anchorPosition 新选择部分的锚点，是 TextFlow 中的绝对位置
		 * @param activePosition 新选择部分的活动终点，是 TextFlow 中的绝对位置
		 * @return 选中范围是否发生改变
		 */		
		public function selectRange(anchorPosition:int, activePosition:int):Boolean
		{
			flushPendingOperations();
			
			var change:Boolean = internalSelectRange(anchorPosition,activePosition);
			if(change)
			{
				allowOperationMerge = false;
			}
			return change;
		}
		/**
		 * 滚动到指定区域
		 */		
		public function scrollToRange(anchorPosition:int,activePosition:int):void
		{
			var activeLineIndex:int = textFlow.findLineIndexAtPosition(activePosition);
			var anchorLineIndex:int = textFlow.findLineIndexAtPosition(anchorPosition);
			if(activeLineIndex==anchorLineIndex)
			{
				scrollToLineIndex(activeLineIndex);
			}
			else
			{
				scrollToLineIndex(anchorLineIndex);
				scrollToLineIndex(activeLineIndex);
			}
			var textLine:TextLine = textFlow.getTextLineAt(activeLineIndex);
			if(textLine)
			{
				var startIndex:int = textFlow.findStartOfLine(activeLineIndex);
				var atomIndex:int = textLine.getAtomIndexAtCharIndex(activePosition-startIndex);
				if(atomIndex==-1)
				{
					atomIndex = textLine.atomCount-1;
				}
				var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
				var hsp:Number = textContainer.horizontalScrollPosition;
				var maxHSP:Number = textContainer.contentWidth-textContainer.width;
				if(bounds.right>hsp+textContainer.width)
				{
					hsp = Math.min(maxHSP,bounds.right+120-textContainer.width);
				}
				if(bounds.left<hsp)
				{
					hsp = Math.max(0,bounds.left-120);
				}
				textContainer.horizontalScrollPosition = hsp;
			}
			else
			{
				textContainer.horizontalScrollPosition = 0;
			}
		}
		
		private function scrollToLineIndex(lineIndex:int):void
		{
			var yPos:Number = lineIndex*textContainer.lineHeight;
			var vsp:Number = textContainer.verticalScrollPosition;
			if(yPos>vsp+textContainer.height-textContainer.lineHeight)
			{
				vsp = yPos-textContainer.height+textContainer.lineHeight;
			}
			if(yPos<vsp)
			{
				vsp = yPos;
			}
			textContainer.verticalScrollPosition = vsp;
		}
		/**
		 * 此方法由文本编辑器内部方法，外部请勿调用。通常在TextOperation的子类中使用，以避免影响操作合并标志。
		 */		
		public function internalSelectRange(anchorPosition:int, activePosition:int):Boolean
		{
			if (anchorPosition < 0 || activePosition < 0)
			{
				anchorPosition = -1;
				activePosition = -1;
			}
			
			var lastSelectablePos:int = (_textFlow.textLength > 0) ? _textFlow.textLength : 0;
			
			if (anchorPosition != -1 && activePosition != -1)
			{
				if (anchorPosition > lastSelectablePos)
					anchorPosition = lastSelectablePos;
				
				if (activePosition > lastSelectablePos)
					activePosition = lastSelectablePos;
			}
			var change:Boolean = (_anchorPosition!=anchorPosition||_activePosition!=activePosition);
			_anchorPosition = anchorPosition;
			_activePosition = activePosition;
			if(change)
			{
				selectionChanged();
			}
			return change;
		}

		/**
		 * 选中区域发生改变
		 * @param doDispatchEvent 是否抛出事件。
		 */		
		protected function selectionChanged(doDispatchEvent:Boolean = true):void
		{
			var event:SelectionEvent = new SelectionEvent(SelectionEvent.SELECTION_CHANGE,false,false,anchorPosition,activePosition);
			if (doDispatchEvent && _textFlow)
				_textFlow.dispatchEvent(event);
			if(!skipMarkSelectionChange)
				_textFlow.markSelectionChange();
			updateIBeamState();
		}
		
		/**
		 * 获取当前的选中状态数据
		 */		
		public function getSelectionState():SelectionState
		{
			flushPendingOperations();
			return new SelectionState(_textFlow,_anchorPosition,_activePosition);
		}
		
		private var beamTimer:Timer;
		/**
		 * 更新光标显示位置和状态
		 */		
		protected function updateIBeamState(index:int = -1):void
		{
			if(!beamTimer)
			{
				beamTimer = new Timer(500);
				beamTimer.addEventListener(TimerEvent.TIMER,onBeamTick);
			}
			
			if(index == -1)
			{
				index = activePosition
			}
			var showIBeam:Boolean = (index!=-1&&hasFocus);
			textContainer.showIBeam = showIBeam;
			if(showIBeam)
			{
				var lineIndex:int = textFlow.findLineIndexAtPosition(index);
				var textLine:TextLine = textFlow.getTextLineAt(lineIndex);
				var iBeamX:Number = 0;
				var iBeamY:Number = 0;
				if(textLine)
				{
					var startIndex:int = textFlow.findStartOfLine(lineIndex);
					var atomIndex:int = textLine.getAtomIndexAtCharIndex(index-startIndex);
					if(atomIndex==-1)
					{
						iBeamX = TextLineUtil.getTextWidth(textLine);
					}
					else
					{
						var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
						iBeamX = bounds.x;
					}
				}
				iBeamY = Math.round(lineIndex*textContainer.lineHeight);
				textContainer.updateIBeamPosition(iBeamX,iBeamY);
				beamTimer.reset();
				beamTimer.start();
			}
			else
			{
				beamTimer.stop();
			}
		}
		
		private function onBeamTick(event:TimerEvent):void
		{
			textContainer.showIBeam = !textContainer.showIBeam;
		}
		
		private function attachContextMenu():void
		{ 
			container.contextMenu = createContextMenu(); 
		}
		
		protected function createContextMenu():ContextMenu
		{
			return createDefaultContextMenu();
		}
		
		ns_egret static  function createDefaultContextMenu():ContextMenu
		{
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.clipboardMenu = true;
			contextMenu.clipboardItems.clear = true;
			contextMenu.clipboardItems.copy = true;
			contextMenu.clipboardItems.cut = true;
			contextMenu.clipboardItems.paste = true;
			contextMenu.clipboardItems.selectAll = true;
			return contextMenu;
		}
		
		private function removeContextMenu():void
		{
			container.contextMenu = null; 
		}
		
		private function attachInteractionHandlers():void
		{
			container.addEventListener(MouseEvent.MOUSE_DOWN, requiredMouseDownHandler);
			container.addEventListener(FocusEvent.FOCUS_IN, requiredFocusInHandler);
			container.addEventListener(FocusEvent.FOCUS_OUT, requiredFocusOutHandler);
			container.addEventListener(Event.ACTIVATE, activateHandler);
			container.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeHandler);
			container.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
			container.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			container.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			container.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			container.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			container.addEventListener(Event.DEACTIVATE, deactivateHandler);
			container.addEventListener(IMEEvent.IME_START_COMPOSITION, imeStartCompositionHandler);
			container.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,rightMouseDownHandler);
			if (container.contextMenu)
			{
				container.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);
				container.contextMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, itemSelect);
			}
			container.addEventListener(Event.COPY, editHandler);
			container.addEventListener(Event.SELECT_ALL, editHandler);
			container.addEventListener(Event.CUT, editHandler);
			container.addEventListener(Event.PASTE, editHandler);
			container.addEventListener(Event.CLEAR, editHandler);
		}
		
		private function itemSelect(e:ContextMenuEvent):void
		{
//			trace("");
		}
		
		protected function rightMouseDownHandler(event:MouseEvent):void
		{
			var stage:Stage = container.stage;
			if(stage)
			{
				stage.focus = container;
			}
		}
		
		private var hasFocus:Boolean = false;
		
		private function requiredFocusInHandler(event:FocusEvent):void
		{
			container.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			container.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);		
			container.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,  keyFocusChangeHandler);
			hasFocus = true;
			updateIBeamState();
			focusInHandler(event);
		}
		
		private function requiredFocusOutHandler(event:FocusEvent):void
		{
			container.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			container.removeEventListener(KeyboardEvent.KEY_UP,   keyUpHandler);   			
			container.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,   keyFocusChangeHandler);
			hasFocus = false;
			updateIBeamState();
			focusOutHandler(event);
		}
		
		/**
		 * 上一次双击时按下的舞台坐标。
		 */		
		private var lastMouseDownPoint:Point = new Point();
		/**
		 * 上一次双击的时刻，毫秒。
		 */		
		private var lastMosueDownTime:Number = 0;
		/**
		 * 已经发生双击事件的标志
		 */		
		private var doubleClicked:Boolean = false;
		/**
		 * 已经发生三击事件。
		 */		
		private var tripleClicked:Boolean = false;
		/**
		 * 鼠标双击时间间隔，默认500毫秒。
		 */		
		public static const DOUBLE_CLICK_INTERVAL:Number = 500;
		
		private function requiredMouseDownHandler(event:MouseEvent):void
		{
			var stage:Stage = container.stage;
			if (stage)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, rootMouseMoveHandler, false, 0, true); 
				stage.addEventListener(MouseEvent.MOUSE_UP,   rootMouseUpHandler, false, 0, true);
				stage.addEventListener(Event.MOUSE_LEAVE,rootMouseUpHandler,false,0,true);
				stage.focus = container;
			}
			allowOperationMerge = false;
			var curTime:Number = getTimer();
			var gapTime:Number = curTime-lastMosueDownTime;
			lastMosueDownTime = curTime;
			var offsetX:Number = Math.abs(lastMouseDownPoint.x - event.stageX);
			var offsetY:Number = Math.abs(lastMouseDownPoint.y - event.stageY);
			lastMouseDownPoint.x = event.stageX;
			lastMouseDownPoint.y = event.stageY;
			if(tripleClicked)
			{
				tripleClicked = false;
				mouseDownHandler(event);
			}
			else if(doubleClicked)
			{
				doubleClicked = false;
				if(gapTime<DOUBLE_CLICK_INTERVAL&&offsetX<5&&offsetY<5)
				{
					tripleClicked = true;
					mouseTripleDownHandler(event);
				}
				else
				{
					mouseDownHandler(event);
				}
			}
			else
			{
				if(gapTime<DOUBLE_CLICK_INTERVAL&&offsetX<5&&offsetY<5)
				{
					doubleClicked = true;
					mouseDoubleDownHandler(event);
				}
				else
				{
					mouseDownHandler(event);
				}
			}
		}
		
		private function rootMouseUpHandler(event:Event):void
		{
			var stage:Stage = event.currentTarget as Stage;
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, rootMouseMoveHandler); 
				stage.removeEventListener(MouseEvent.MOUSE_UP,   rootMouseUpHandler);
				stage.removeEventListener(Event.MOUSE_LEAVE,rootMouseUpHandler);
			}
			mouseUpHandler(event);
		}
		
		private function rootMouseMoveHandler(event:MouseEvent):void
		{   
			mouseMoveHandler(event); 
		}
		
		protected function editHandler(event:Event):void
		{
			switch (event.type)
			{
				case Event.COPY:
					flushPendingOperations();
					copy();
					break;
				case Event.SELECT_ALL:
					flushPendingOperations();
					selectAll();
					break;  
			}         
		}
		/**
		 * 将文本设置到系统剪贴板
		 */		
		protected function setTextToClipboard(text:String):void
		{
			var systemClipboard:Clipboard = Clipboard.generalClipboard;
			systemClipboard.clear();
			systemClipboard.setData(ClipboardFormats.TEXT_FORMAT, text); 
		}
		/**
		 * 全选文本
		 */		
		public function selectAll():void
		{
			selectRange(0, int.MAX_VALUE);
		}
		/**
		 * 复制选中文本
		 */		
		public function copy():void
		{
			if(activePosition != anchorPosition)
			{
				var text:String = getSelectionText();
				setTextToClipboard(text);
			}
		}
		
		/**
		 * 设置文本容器获得焦点
		 */		
		public function setFocus():void
		{
			if(container&&container.stage)
				container.stage.focus = container;
		}
		
		/**
		 * 获取选中的文本。如果没有选中则返回空字符串
		 */
		public function getSelectionText():String
		{
			return textFlow.getText(absoluteStart,absoluteEnd);
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (!hasSelection() || event.isDefaultPrevented())
				return;
			
			if (event.charCode == 0)
			{   
				switch(event.keyCode)
				{
					case Keyboard.LEFT:
					case Keyboard.UP:
					case Keyboard.RIGHT:
					case Keyboard.DOWN:
					case Keyboard.HOME:
					case Keyboard.END:
					case Keyboard.PAGE_DOWN:
					case Keyboard.PAGE_UP:
					case Keyboard.ESCAPE:
						handleKeyEvent(event);
						break;
				}
			}
			else if (event.keyCode == Keyboard.ESCAPE)
			{
				handleKeyEvent(event);
			}
			
		}
		
		private function handleKeyEvent(event:KeyboardEvent):void
		{
			var selectionState:SelectionState;
			flushPendingOperations();
			
			if (event.charCode == 0)
			{   
				switch(event.keyCode)
				{
					case Keyboard.LEFT:
						selectionState = handleLeftArrow(event);
						break;
					case Keyboard.UP:
						skipMarkSelectionChange = true;
						selectionState = handleUpArrow(event);
						break;
					case Keyboard.RIGHT:
						selectionState = handleRightArrow(event);
						break;
					case Keyboard.DOWN:
						skipMarkSelectionChange = true;
						selectionState = handleDownArrow(event);
						break;
					case Keyboard.HOME:
						selectionState = handleHomeKey(event);
						break;
					case Keyboard.END:
						selectionState = handleEndKey(event);
						break;
					case Keyboard.PAGE_DOWN:
						skipMarkSelectionChange = true;
						selectionState = handlePageDownKey(event);
						break;
					case Keyboard.PAGE_UP:
						skipMarkSelectionChange = true;
						selectionState = handlePageUpKey(event);
						break;
				}
			}
			if(selectionState)
			{
				selectRange(selectionState.anchorPosition,selectionState.activePosition);
				skipMarkSelectionChange = false;
				event.preventDefault();
				scrollToRange(_anchorPosition,_activePosition);
			}
			allowOperationMerge = false;
		}                                
		
		private function handleLeftArrow(event:KeyboardEvent):SelectionState
		{           
			var selState:SelectionState = getSelectionState();
			if (event.ctrlKey || event.altKey)
				NavigationUtil.previousWord(selState,event.shiftKey);
			else
				NavigationUtil.previousCharacter(selState,event.shiftKey);
			return selState;
		}
		
		
		private function handleUpArrow(event:KeyboardEvent):SelectionState
		{           
			var selState:SelectionState = getSelectionState();
			if (event.altKey)
				NavigationUtil.startOfParagraph(selState,event.shiftKey);
			else if (event.ctrlKey)
				NavigationUtil.startOfDocument(selState,event.shiftKey);
			else
				NavigationUtil.previousLine(selState,event.shiftKey);
			return selState;
		}
		
		private function handleRightArrow(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			if (event.ctrlKey || event.altKey)
				NavigationUtil.nextWord(selState,event.shiftKey);
			else
				NavigationUtil.nextCharacter(selState,event.shiftKey);
			return selState;
		}
		
		private function handleDownArrow(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			
			if (event.altKey)
				NavigationUtil.endOfParagraph(selState,event.shiftKey);
			else if (event.ctrlKey)
				NavigationUtil.endOfDocument(selState,event.shiftKey);
			else
				NavigationUtil.nextLine(selState,event.shiftKey);
			
			return selState;
		}
		
		private function handleHomeKey(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			if (event.ctrlKey && !event.altKey)
				NavigationUtil.startOfDocument(selState,event.shiftKey);
			else
				NavigationUtil.startOfLine(selState,event.shiftKey);
			return selState;
		}
		
		private function handleEndKey(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			if (event.ctrlKey && !event.altKey)
				NavigationUtil.endOfDocument(selState,event.shiftKey);
			else
				NavigationUtil.endOfLine(selState,event.shiftKey);
			return selState;
		}
		
		private function handlePageUpKey(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			NavigationUtil.previousPage(selState,textContainer,event.shiftKey);
			return selState;
		}
		
		private function handlePageDownKey(event:KeyboardEvent):SelectionState
		{
			var selState:SelectionState = getSelectionState();
			NavigationUtil.nextPage(selState,textContainer,event.shiftKey);
			return selState;
		}      
		
		
		protected function keyUpHandler(event:KeyboardEvent):void
		{
		}
		
		protected function keyFocusChangeHandler(event:FocusEvent):void
		{
		}
		
		protected function textInputHandler(event:TextEvent):void
		{
			ignoreNextTextEvent = false;
		}
		
		protected function imeStartCompositionHandler(event:IMEEvent):void
		{
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			var index:int = computeSelectionIndex(event.stageX,event.stageY);
			selectRange(index,index);
			doubleClicked = false;
		}
		
		/**
		 * 通过鼠标坐标得到字符索引，在找不到字符的时候返回-1
		 * @param stageX
		 * @param stageY
		 * @return 
		 * 
		 */		
		public function getIndexByMouse(stageX:Number,stageY:Number):int
		{
			return computeSelectionIndex(stageX,stageY,true);
		}
		
		/**
		 * 根据舞台坐标获得对应的字符串索引值 
		 * @param stageX
		 * @param stageY
		 * @param absolute 默认为false，如果为true，则会精准检测鼠标下的字符，找不到字符返回-1
		 * @return 
		 * 
		 */		
		protected function computeSelectionIndex(stageX:Number,stageY:Number,absolute:Boolean = false):int
		{
			var pos:Point = container.globalToLocal(new Point(stageX,stageY));
			var lineIndex:int = pos.y/textContainer.lineHeight;
			var textLine:TextLine = textFlow.getTextLineAt(lineIndex);
			var startIndex:int = _textFlow.findStartOfLine(lineIndex);
			if(pos.y<0)
			{
				if(absolute)
					return -1;
				return 0;
			}
			if(textLine&&pos.x>0)
			{
				var atomIndex:int = textLine.getAtomIndexAtPoint(stageX,stageY);
				if(atomIndex==-1)
				{
					if(absolute)
						return -1;
					var pt:Point = textLine.globalToLocal(new Point(stageX,stageY));
					if(pt.y<0||pt.y>textLine.descent)
					{
						pt.y = 0;
						pt = textLine.localToGlobal(pt);
						atomIndex = textLine.getAtomIndexAtPoint(pt.x,pt.y);
					}
				}
				if(atomIndex==-1)
				{
					var index:int = startIndex+textLine.rawTextLength;
				}
				else
				{
					var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
					if(pos.x<bounds.x+bounds.width*0.5)
					{
						index = startIndex+textLine.getAtomTextBlockBeginIndex(atomIndex);
					}
					else
					{
						index = startIndex+textLine.getAtomTextBlockEndIndex(atomIndex);
					}
				}
			}
			else
			{
				if(absolute)
					return -1;
				index = startIndex;
			}
			return index;
		}
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			allowOperationMerge = false;
			var index:int = computeSelectionIndex(event.stageX,event.stageY);
			selectRange(_anchorPosition,index);
			var pos:Point = container.globalToLocal(new Point(event.stageX,event.stageY));
			autoScrollIfNecessary(pos);
		}
		
		private var scrollDragPixels:Number = 30;
		private var scrollDragDelay:Number = 35;
		private var _scrollTimer:Timer;
		/**
		 * 自动滚屏
		 */		
		protected function autoScrollIfNecessary(extreme:Point,updateRange:Boolean = true):int
		{
			var scrollDirection:int = 0;
			var verticalScrollPosition:Number = textContainer.verticalScrollPosition;
			var containerScrollRectBottom:Number = verticalScrollPosition+container.height;
			var containerScrollRectTop:Number = verticalScrollPosition;
			var horizontalScrollPosition:Number = textContainer.horizontalScrollPosition;
			var containerScrollRectRight:Number = horizontalScrollPosition+container.width;
			var containerScrollRectLeft:Number = horizontalScrollPosition;
			if (extreme.y - containerScrollRectBottom > 0) {
				verticalScrollPosition += scrollDragPixels;
				scrollDirection = 1;
			}
			else if (extreme.y - containerScrollRectTop < 0) {
				verticalScrollPosition -= scrollDragPixels;
				scrollDirection = -1;
			}
			if (extreme.x - containerScrollRectRight > 0) {
				horizontalScrollPosition += scrollDragPixels;
				scrollDirection = -1;
			}
			else if (extreme.x - containerScrollRectLeft < 0) {
				horizontalScrollPosition -= scrollDragPixels;
				scrollDirection = 1;
			}
			if (scrollDirection != 0 && !_scrollTimer && updateRange) 
			{
				_scrollTimer = new Timer(scrollDragDelay);
				_scrollTimer.addEventListener(TimerEvent.TIMER, scrollTimerHandler, false, 0, true);
				_scrollTimer.start();
			}
			if(horizontalScrollPosition<0)
				horizontalScrollPosition = 0;
			if(verticalScrollPosition<0)
				verticalScrollPosition = 0;
			textContainer.horizontalScrollPosition = horizontalScrollPosition;
			textContainer.verticalScrollPosition = verticalScrollPosition;
			return scrollDirection;
		}
		
		private function scrollTimerHandler(event:Event):void
		{
			var index:int = computeSelectionIndex(container.stage.mouseX,container.stage.mouseY);
				selectRange(_anchorPosition,index);
			var containerPoint:Point = new Point(container.stage.mouseX, container.stage.mouseY);
			containerPoint = container.globalToLocal(containerPoint);
			var scrollChange:int = autoScrollIfNecessary(containerPoint);
		}
		
		protected function mouseUpHandler(event:Event):void
		{
			if(_scrollTimer)
			{
				_scrollTimer.stop();
				_scrollTimer.removeEventListener(TimerEvent.TIMER, scrollTimerHandler);
				_scrollTimer = null;
			}
		}
		
		/**
		 * 鼠标连续两次按下事件,选中一个单词。
		 */		
		protected function mouseDoubleDownHandler(event:MouseEvent):void
		{
			var selectionState:SelectionState = getSelectionState();
			NavigationUtil.currentContinuousCharacter(selectionState);
			selectRange(selectionState.anchorPosition,selectionState.activePosition);
			scrollToRange(_anchorPosition,_activePosition);
		}
		
		/**
		 * 鼠标连续第三次按下事件,将选区扩展到整个段落
		 */		
		protected function mouseTripleDownHandler(event:MouseEvent):void
		{
			var selectionState:SelectionState = getSelectionState();
			NavigationUtil.currentParagraph(selectionState);
			selectRange(selectionState.anchorPosition,selectionState.activePosition);
			scrollToRange(_anchorPosition,_activePosition);
		}
		/**
		 * 鼠标经过编辑区
		 */		
		protected function rollOverHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.IBEAM;
		}
		/**
		 * 鼠标移出编辑区
		 */		
		protected function rollOutHandler(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		/**
		 * 焦点移入事件
		 */		
		protected function focusInHandler(event:FocusEvent):void
		{
		}
		/**
		 * 焦点移出事件
		 */		
		protected function focusOutHandler(event:FocusEvent):void
		{
		}
		/**
		 * 窗口激活事件
		 */		
		protected function activateHandler(event:Event):void
		{
		}
		/**
		 * 窗口失去激活事件
		 */		
		protected function deactivateHandler(event:Event):void
		{
		}
		/**
		 * 焦点改变事件
		 */		
		protected function focusChangeHandler(event:FocusEvent):void
		{
		}
		
		protected function menuSelectHandler(event:ContextMenuEvent):void
		{
			var menu:ContextMenu = event.target as ContextMenu;
			
			if (activePosition != anchorPosition)
			{
				menu.clipboardItems.copy = true;
				menu.clipboardItems.cut = editingMode == EditingMode.READ_WRITE;
				menu.clipboardItems.clear = editingMode == EditingMode.READ_WRITE;
			} else {
				menu.clipboardItems.copy = false;
				menu.clipboardItems.cut = false;
				menu.clipboardItems.clear = false;
			}
			
			var systemClipboard:Clipboard = Clipboard.generalClipboard;
			if (activePosition != -1 && editingMode == EditingMode.READ_WRITE && (systemClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)))
			{
				menu.clipboardItems.paste = true;
			} else {
				menu.clipboardItems.paste = false;
			}
			menu.clipboardItems.selectAll = true;      
		}
		/**
		 * 鼠标滚轮事件
		 */		
		protected function mouseWheelHandler(event:MouseEvent):void
		{
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			flushPendingOperations();
		}
		/**
		 * 清理缓存的操作对象。
		 */		
		protected function flushPendingOperations():void
		{
		}
	}
}