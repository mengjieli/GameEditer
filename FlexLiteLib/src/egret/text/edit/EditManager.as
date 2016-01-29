package egret.text.edit
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.IMEEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	import egret.core.ns_egret;
	import egret.text.ITextContainer;
	import egret.text.TextFlow;
	import egret.text.events.TextOperationEvent;
	import egret.text.operations.DeleteTextOperation;
	import egret.text.operations.InsertTabOperation;
	import egret.text.operations.InsertTextOperation;
	import egret.text.operations.MoveTextOperation;
	import egret.text.operations.TextOperation;
	import egret.text.undo.IUndoManager;
	import egret.text.undo.UndoManager;
	import egret.text.utils.CharacterUtil;
	import egret.text.utils.TextLineUtil;
	import egret.utils.callLater;
	
	use namespace ns_egret;
	
	/**
	 * 正要执行某个操作 ,该操作可以取消
	 */	
	[Event(name="operationDoing", type="egret.text.events.TextOperationEvent")]
	/**
	 * 执行完毕某个操作  
	 */	
	[Event(name="operationDone", type="egret.text.events.TextOperationEvent")]
	
	
	/**
	 * 文本编辑管理器
	 * @author dom
	 */
	public class EditManager extends SelectionManager implements IEditManager
	{
		/**
		 * 键盘输入的文本是否启用覆盖模式的标志。 
		 */		
		public static var overwriteMode:Boolean = false;
		
		/**
		 * 构造函数
		 * @param textContainer 文本容器
		 * @param textFlow 文本流
		 * 
		 */		
		public function EditManager(textContainer:ITextContainer, textFlow:TextFlow,undoManager:IUndoManager=null)
		{
			super(textContainer, textFlow);
			DisplayObject(textContainer).addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,dragEnterHandler);
			DisplayObject(textContainer).addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,dragDropHandler);
			DisplayObject(textContainer).addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE,dragCompleteHandler);
			DisplayObject(textContainer).addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,dragExitHandler);
			if(!undoManager)
				undoManager = new UndoManager();
			this._undoManager = undoManager;
		}
		
		//是拖入还是拖出
		private var exited:Boolean = false;
		/**
		 * 拖拽进入 
		 */		
		private function dragEnterHandler(event:NativeDragEvent):void
		{
			exited = false;
			if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))
			{
				var dropText:String = event.clipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				if(dropText)
				{
					if(container.stage)
						container.stage.focus = container;
					
					NativeDragManager.dropAction = NativeDragActions.MOVE; 
					NativeDragManager.acceptDragDrop(container);
					var pos:Point = new Point(event.stageX,event.stageY);
					pos = container.globalToLocal(pos);
					
					if(pos.y < ITextContainer(container).verticalScrollPosition+20)
						pos.y = ITextContainer(container).verticalScrollPosition-20;
					else if(pos.y > ITextContainer(container).verticalScrollPosition + container.height-20)
						pos.y = ITextContainer(container).verticalScrollPosition + container.height+20
					if(pos.x < ITextContainer(container).horizontalScrollPosition+20)
						pos.x = ITextContainer(container).horizontalScrollPosition-20;
					else if(pos.x > ITextContainer(container).horizontalScrollPosition + container.width-20)
						pos.x = ITextContainer(container).horizontalScrollPosition + container.width+20
					
					autoScrollIfNecessary(pos,false);
					
					var index:int = computeSelectionIndex(event.stageX,event.stageY);
					if(overwriteMode)
						textContainer.updateIBeamState(false);
					updateIBeamState(index);
				}
			}
		}
		
		private var dropInIndex:int = 0;
		private var dropInBegin:int = 0;
		private var dropInEnd:int = 0;
		/**
		 * 拖入释放
		 */		
		private function dragDropHandler(event:NativeDragEvent):void
		{
			exited = false;
			if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))
			{ 
				var dropText:String = event.clipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				if(dropText)
				{
					var index:int = computeSelectionIndex(event.stageX,event.stageY);
					dropInIndex = index;
					if(index < beginCache || index > endCache || beginCache == endCache)
					{
						selectRange(index,index);
						doDragAction("insert",getSelectionState(),dropText);
					}
					dropInBegin = index;
					dropInEnd = index+dropText.length;
				}
			}
		}
		
		/**
		 * 拖拽完成 
		 */		
		private function dragCompleteHandler(event:NativeDragEvent):void
		{
			if(exited == true)
			{
				var selectionState:SelectionState = getSelectionState();
				var index:int = Math.min(selectionState.activePosition,selectionState.anchorPosition);
				if(event.dropAction != NativeDragActions.NONE)
				{
					doDragAction("delete",selectionState);
				}else
				{
					doDragAction("none",selectionState);
				}
			}else
			{
				selectRange(beginCache,endCache);
				if(dropInIndex < beginCache || dropInIndex > endCache)
				{
					doDragAction("delete",getSelectionState());
				}else
				{
					doDragAction("none",getSelectionState());
				}
				
			}
		}
		
		/**
		 * 拖出 
		 */		
		private function dragExitHandler(event:NativeDragEvent):void
		{
			exited = true;
		}
		
		private var dragActionList:Array = [];
		private var doingAction:Boolean = false;
		private function doDragAction(type:String,selection:SelectionState,data:String = ""):void
		{
			super.mouseUpHandler(null);
			dragActionList.push({
				"type":type,
				"selection":selection,
				"data":data
			});
			if(!doingAction)
			{
				doingAction = true;
				callLater(doDragAction_handler);
			}
		}
		
		private function doDragAction_handler():void
		{
			var finalType:String = "";
			var selection:SelectionState;
			var data:String = "";
			if(dragActionList.length == 2)
			{
				finalType = "move";
			}else if(dragActionList.length == 1)
			{
				finalType = dragActionList[0]["type"];
				selection = dragActionList[0]["selection"];
				data = dragActionList[0]["data"];
			}
			
			var opertion:TextOperation;
			switch(finalType)
			{
				case "move":
					var selectionFrom:SelectionState;
					var selectionTo:SelectionState
					if(dragActionList[0]["type"] == "delete")
					{
						selectionFrom = dragActionList[0]["selection"];
						selectionTo = dragActionList[1]["selection"];
					}else
					{
						selectionFrom = dragActionList[1]["selection"];
						selectionTo = dragActionList[0]["selection"];
					}
					opertion = new MoveTextOperation(selectionFrom,selectionTo.absoluteStart);
					doOperation(opertion);
					break;
				case "insert":
					opertion = new InsertTextOperation(selection,data);
					doOperation(opertion);
					selectRange(selection.absoluteStart,selection.absoluteStart+data.length);
					break;
				case "delete":
					opertion = new DeleteTextOperation(selection);
					doOperation(opertion);
					break;
				case "none":
					selectRange(selection.anchorPosition,selection.activePosition);
					break;
				default:
					break;
			}
			dragActionList.length = 0;
			doingAction = false;
			textContainer.updateIBeamState(overwriteMode);
		}
		
		private var prepareToDrag:Boolean = false;
		private var beginCache:int = 0;
		private var endCache:int = 0;
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			prepareToDrag = false;
			var selectionState:SelectionState = this.getSelectionState();
			var index:int = computeSelectionIndex(event.stageX,event.stageY);
			var selectedStartIndex:int = Math.min(selectionState.activePosition,selectionState.anchorPosition);
			var selectedEndIndex:int = Math.max(selectionState.activePosition,selectionState.anchorPosition);
			
			if(index >= 0)
			{
				if(index>selectedStartIndex && index<selectedEndIndex && checkHasAtomUnderPos(event.stageX,event.stageY))
				{
					prepareToDrag = true;
					beginCache = selectedStartIndex;
					endCache = selectedEndIndex;
				}
			}
			if(prepareToDrag)
			{
				container.stage.addEventListener(MouseEvent.MOUSE_MOVE,rootMouseMoveHandler);
				return;
			}
			super.mouseDownHandler(event);
		}
		
		protected function rootMouseMoveHandler(event:MouseEvent):void
		{
			var transfer:Clipboard = new Clipboard();
			var selectionState:SelectionState = this.getSelectionState();
			var index:int = computeSelectionIndex(event.stageX,event.stageY);
			var selectedStartIndex:int = Math.min(selectionState.activePosition,selectionState.anchorPosition);
			var selectedEndIndex:int = Math.max(selectionState.activePosition,selectionState.anchorPosition);
			var transText:String = selectionState.textFlow.text.substring(selectedStartIndex,selectedEndIndex);
			transfer.setData(ClipboardFormats.TEXT_FORMAT, transText, true);
			NativeDragManager.doDrag(container, transfer,null);
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE,rootMouseMoveHandler);
			prepareToDrag = false;
		}
		
		override protected function mouseMoveHandler(event:MouseEvent):void
		{
			if(!prepareToDrag)
			{
				super.mouseMoveHandler(event);
			}
		}
		
		override protected function mouseUpHandler(event:Event):void
		{
			if(prepareToDrag && event is MouseEvent)
			{
				super.mouseDownHandler(MouseEvent(event));
				if(container.stage)
				{
					container.stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
				}
			}
			super.mouseUpHandler(event);
		}
		
		
		
		/**检测目标点下方是否有字符*/
		protected function checkHasAtomUnderPos(stageX:Number, stageY:Number):Boolean
		{
			var pos:Point = container.globalToLocal(new Point(stageX,stageY));
			var lineIndex:int = pos.y/textContainer.lineHeight;
			var textLine:TextLine = textFlow.getTextLineAt(lineIndex);
			if(textLine)
			{
				pos = textLine.globalToLocal(new Point(stageX,stageY));
				if(pos.x>=0 && pos.x<=textLine.width)
				{
					return true;
				}
			}
			return false;
		}
		
		private var _editingMode:String = EditingMode.READ_WRITE;
		public override function set editingMode(value:String):void
		{
			_editingMode = value;
		}
		/**
		 * 编辑模式 
		 * @see egret.text.edit.EditingMode 
		 */
		public override function get editingMode():String
		{
			return _editingMode;
		}	
		/**
		 * 是否处理Enter键按下事件。
		 */		
		public var manageEnterKey:Boolean = true;
		/**
		 * 按下Enter键应该输入的文本，通常是"\n"或"\r\n"。注意：当managerEnterKey为false时此属性无效。
		 */		
		public var enterKeyText:String = "\n";
		/**
		 * 是否处理Tab键按下事件。
		 */		
		public var manageTabKey:Boolean = true;
		/**
		 * 按下Tab键应该输入的文本，通常是Tab字符或者四个空格。注意：当manageTabKey为false时此属性无效。
		 */		
		public static var tabKeyText:String = "\t";
		
		private var _imeSession:IMEClient;
		private var _imeOperationInProgress:Boolean;
		private var _undoManager:IUndoManager;
		/**
		 * 撤销管理器实例。
		 */
		public function get undoManager():IUndoManager
		{
			return _undoManager;
		}
		
		private var pendingInsert:InsertTextOperation;
		
		override protected function flushPendingOperations():void
		{
			super.flushPendingOperations();
			if (pendingInsert)
			{
				var operation:InsertTextOperation = pendingInsert;
				pendingInsert = null;
				if (container)
				{
					container.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				}
				doOperation(operation);
			}
		}
		/**
		 * 执行一个文本操作
		 */		
		public function doOperation(operation:TextOperation):void
		{
			if(editingMode != EditingMode.READ_WRITE)
				return;
			var event:TextOperationEvent = new TextOperationEvent(TextOperationEvent.OPERATION_DOING);
			event.relateOperation = operation;
			if(dispatchEvent(event))
			{
				if (_imeSession && !_imeOperationInProgress)
					_imeSession.compositionAbandoned();
				operation.doOperation();
				if (_undoManager)
				{
					if (_undoManager.canUndo() && allowOperationMerge)
					{
						var lastOp:TextOperation = _undoManager.peekUndo() as TextOperation;
						if (lastOp)
						{
							var combinedOp:TextOperation = lastOp.merge(operation);
							if (combinedOp)
							{
								_undoManager.popUndo();
								operation = combinedOp;
							}
						}
					}
					_undoManager.pushUndo(operation);
					allowOperationMerge = true;
					_undoManager.clearRedo();
				}
				event = new TextOperationEvent(TextOperationEvent.OPERATION_DONE);
				dispatchEvent(event);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function editHandler(event:Event):void
		{
			if (event.isDefaultPrevented())
				return;
			
			super.editHandler(event);
			switch (event.type)
			{
				case Event.CUT: 
				case Event.CLEAR:
					if (activePosition != anchorPosition)
					{
						if (event.type == Event.CUT)
							cut();
						else
							deleteSelectedText();
						event.preventDefault();
					}
					break;
				case Event.PASTE:
					paste();
					event.preventDefault();
					break;
			}
		}
		/**
		 * 获取系统剪贴板的文本内容。
		 */		
		public function getTextFromClipboard():String
		{
			var systemClipboard:Clipboard = Clipboard.generalClipboard;
			
			var text:String = "";
			if(systemClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))
			{
				text = String(systemClipboard.getData(ClipboardFormats.TEXT_FORMAT))
			}
			return text;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (!hasSelection() || event.isDefaultPrevented())
				return;
			
			super.keyDownHandler(event);
			
			if (event.ctrlKey)
			{
				if (!event.altKey)
				{
					if (_imeSession != null && ((event.charCode == 122) || (event.charCode == 121)))
						_imeSession.compositionAbandoned();	
					
					switch(event.charCode)
					{
						case 90://Z
							if ((Capabilities.os.search("Mac OS") > -1)) 
							{
								ignoreNextTextEvent = true;
								if(event.shiftKey)
									redo();
							}
							event.preventDefault();
							break;
						case 122://z
							if ((Capabilities.os.search("Mac OS") > -1)) 
							{
								ignoreNextTextEvent = true;
							}
							undo();
							event.preventDefault();
							break;
						case 121://z
							ignoreNextTextEvent = true;
							redo();
							event.preventDefault();
							break;
						case Keyboard.BACKSPACE:
							if (_imeSession)
								_imeSession.compositionAbandoned();
							deletePreviousWord();
							event.preventDefault();
							break;
					}
					if (event.keyCode == Keyboard.DELETE)
					{
						if (_imeSession)
							_imeSession.compositionAbandoned();
						deleteNextWord();
						event.preventDefault();
					}
					
					if (event.shiftKey)
					{
						if (event.charCode == 95)
						{
							if (_imeSession)
								_imeSession.compositionAbandoned();
							
							var discretionaryHyphenString:String = String.fromCharCode(0x000000AD);
							overwriteMode ? overwriteText(discretionaryHyphenString) : insertText(discretionaryHyphenString);
							event.preventDefault();
						}
					}
				}
			} 
			else if (event.altKey)
			{
				if (event.charCode == Keyboard.BACKSPACE)
				{
					deletePreviousWord();
					event.preventDefault();
				}
				else if (event.keyCode == Keyboard.DELETE)
				{
					deleteNextWord();
					event.preventDefault();
				}
			}
			else if (event.keyCode == Keyboard.DELETE) 
			{
				deleteNextCharacter();
				event.preventDefault();
			}
			else if (event.keyCode == Keyboard.INSERT) 
			{
				overwriteMode = !overwriteMode;		
				textContainer.updateIBeamState(overwriteMode);
				event.preventDefault();
			}
			else switch(event.charCode) {
				case Keyboard.BACKSPACE:
					deletePreviousCharacter();
					event.preventDefault();
					break;
				case Keyboard.ENTER:
					if (manageEnterKey) 
					{
						handleEnterKey();
						event.preventDefault();
						event.stopImmediatePropagation();
					}
					break;
				case Keyboard.TAB:
					if (manageTabKey) 
					{
						handleTabKey();
						event.preventDefault();
					}
					break;
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			if (!hasSelection() || event.isDefaultPrevented())
				return;
			
			super.keyUpHandler(event);
			
			if ((manageEnterKey && event.charCode == Keyboard.ENTER) || (manageTabKey && event.charCode == Keyboard.TAB)) {
				event.stopImmediatePropagation();
			}
		}
		/**
		 * @inheritDoc
		 */
		override protected function keyFocusChangeHandler(event:FocusEvent):void
		{
			if (manageTabKey) 
				event.preventDefault();
		}
		/**
		 * @inheritDoc
		 */
		override protected function textInputHandler(event:TextEvent):void
		{
			if(activePosition<0||anchorPosition<0)
				return;
			if (!ignoreNextTextEvent)
			{
				var charCode:int = event.text.charCodeAt(0);
				if (charCode >=  32)
					overwriteMode ? overwriteText(event.text) : insertText(event.text);
			}
			ignoreNextTextEvent = false;
		}
		/**
		 * @inheritDoc
		 */
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			if (_imeSession)
				_imeSession.compositionAbandoned();
		}
		/**
		 * @inheritDoc
		 */
		override protected function deactivateHandler(event:Event):void
		{
			super.deactivateHandler(event);
			if (_imeSession)
				_imeSession.compositionAbandoned();
		}
		/**
		 * @inheritDoc
		 */
		override protected function imeStartCompositionHandler(event:IMEEvent):void
		{
			flushPendingOperations();
			
			if (!event.imeClient)
			{
				_imeSession = new IMEClient(this);
				_imeOperationInProgress = false;
				event.imeClient = _imeSession;
			}
		}
		
		public function cut():void
		{
			setTextToClipboard(cutTextScrap());
		}
		
		public function paste():void
		{
			pasteTextScrap(getTextFromClipboard());
		}
		
		/**
		 * 剪切文本
		 */		
		protected function cutTextScrap():String
		{
			if(activePosition == anchorPosition)
			{
				return "";
			}	
			
			var text:String = textFlow.getText(absoluteStart,absoluteEnd);
			var operation:DeleteTextOperation = new DeleteTextOperation(getSelectionState());
			doOperation(operation);
			return text;
		}
		/**
		 * 粘贴文本
		 */		
		protected function pasteTextScrap(text:String):void
		{
			var text:String = getTextFromClipboard();
			var operation:InsertTextOperation = new InsertTextOperation(getSelectionState(),text);
			doOperation(operation);
		}
		
		/**
		 * 处理Tab键按下事件。
		 */		
		protected function handleTabKey():void
		{
			if(absoluteStart==absoluteEnd)
			{
				insertText(tabKeyText);
				return;
			}
			var operation:InsertTabOperation = new InsertTabOperation(getSelectionState(),tabKeyText);
			doOperation(operation);
		}
		/**
		 * 处理Enter键按下事件
		 */		
		protected function handleEnterKey():void
		{
			var operation:InsertTextOperation = new InsertTextOperation(getSelectionState(),enterKeyText,true);
			doOperation(operation);
		}
		
		/**
		 * 删除选中的文本
		 */		
		public function deleteSelectedText():void
		{
			if(activePosition == anchorPosition)
			{
				return;
			}	
			var operation:DeleteTextOperation = new DeleteTextOperation(getSelectionState());
			doOperation(operation);
		}		
		/**
		 * 删除光标之后的一个字符
		 */		
		public function deleteNextCharacter():void
		{
			if(anchorPosition!=activePosition)
			{
				deleteSelectedText();
				return;
			}
			var charIndex:int = textFlow.findNextAtomBoundary(activePosition);
			if(charIndex!=activePosition)
			{
				var selection:SelectionState = getSelectionState();
				selection.updateRange(charIndex,activePosition);
				var operation:DeleteTextOperation = new DeleteTextOperation(selection,true);
				doOperation(operation);
			}
		}
		/**
		 * 删除光标之前的一个字符
		 */		
		public function deleteNextWord():void
		{
			if(anchorPosition!=activePosition)
			{
				deleteSelectedText();
				return;
			}
			var startOfParagraph:int = textFlow.findStartOfParagraph(absoluteStart);
			var endOfParagraph:int = textFlow.findEndOfParagraph(absoluteStart);
			var nextPosition:int = -1;
			
			if (absoluteStart >= endOfParagraph)
			{
				nextPosition = textFlow.findNextAtomBoundary(absoluteStart);
			}
			else
			{
				var curPos:int = absoluteStart;			
				var curPosCharCode:int = textFlow.getCharCodeAtPosition(curPos);
				var prevPosCharCode:int = -1;
				if (curPos > startOfParagraph) 
					prevPosCharCode = textFlow.getCharCodeAtPosition(curPos - 1);
				var nextPosCharCode:int = textFlow.getCharCodeAtPosition(curPos + 1);
				if (!CharacterUtil.isWhitespace(curPosCharCode) && ((curPos == startOfParagraph) ||
					((curPos > startOfParagraph) && CharacterUtil.isWhitespace(prevPosCharCode)))) 
				{
					nextPosition = textFlow.findNextAtomBoundary(absoluteStart);
				} 
				else 
				{
					if (CharacterUtil.isWhitespace(curPosCharCode) && ((curPos > startOfParagraph) && 
						!CharacterUtil.isWhitespace(prevPosCharCode))) 
					{
						curPos = textFlow.findNextWordBoundary(curPos,true);
					}
					nextPosition = textFlow.findNextWordBoundary(curPos,true);
				}
			}
			var selection:SelectionState = getSelectionState();
			selection.updateRange(absoluteStart,nextPosition);
			var operation:DeleteTextOperation = new DeleteTextOperation(selection,true);
			doOperation(operation);
		}
		
		/**
		 * 删除当前光标位置下的前一个字符
		 */		
		public function deletePreviousCharacter():void
		{
			if(anchorPosition!=activePosition)
			{
				deleteSelectedText();
				return;
			}
			var charIndex:int = textFlow.findPreviousAtomBoundary(activePosition);
			if(charIndex!=activePosition)
			{
				var selection:SelectionState = getSelectionState();
				selection.updateRange(charIndex,activePosition);
				var operation:DeleteTextOperation = new DeleteTextOperation(selection,true);
				doOperation(operation);
			}
		}
		/**
		 * 删除当前光标位置下的前一段字符，注意删除跟移动光标时的单词范围并不相同。
		 */		
		public function deletePreviousWord():void
		{
			if(anchorPosition!=activePosition)
			{
				deleteSelectedText();
				return;
			}
			var startOfParagraph:int = textFlow.findStartOfParagraph(absoluteStart);
			var selection:SelectionState = getSelectionState();
			if (absoluteStart == startOfParagraph)
			{
				var beginPrevious:int = textFlow.findPreviousAtomBoundary(absoluteStart);
				selection.updateRange(beginPrevious,activePosition);
				var operation:DeleteTextOperation = new DeleteTextOperation(selection,true);
				doOperation(operation);
				return;
			}
			
			var curPosition:int = absoluteStart;
			var curPosCharCode:int = textFlow.getCharCodeAtPosition(absoluteStart);
			var prevPosCharCode:int = textFlow.getCharCodeAtPosition(absoluteStart - 1);
			var endOfParagraph:int = textFlow.findEndOfParagraph(absoluteStart);
			var curAbsoluteStart:int = absoluteStart;
			
			if (CharacterUtil.isWhitespace(curPosCharCode) && (curPosition != (endOfParagraph - 1)))
			{
				if (CharacterUtil.isWhitespace(prevPosCharCode))
				{
					curPosition = textFlow.findPreviousWordBoundary(curPosition,true);
				}
				if (curPosition > startOfParagraph) 
				{
					curPosition = textFlow.findPreviousWordBoundary(curPosition,true); 
					if (curPosition > startOfParagraph) 
					{
						prevPosCharCode = textFlow.getCharCodeAtPosition(curPosition - 1);
						if (CharacterUtil.isWhitespace(prevPosCharCode))
						{
							curPosition = textFlow.findPreviousWordBoundary(curPosition,true);
						}
					}
				}
			}
			else 
			{ 
				if (CharacterUtil.isWhitespace(prevPosCharCode))
				{
					curPosition = textFlow.findPreviousWordBoundary(curPosition,true); 
					if (curPosition > startOfParagraph) 
					{
						curPosition = textFlow.findPreviousWordBoundary(curPosition,true);
						if (curPosition > startOfParagraph) 
						{
							prevPosCharCode = textFlow.getCharCodeAtPosition(curPosition - 1);
							if (!CharacterUtil.isWhitespace(prevPosCharCode)) 
							{
								curAbsoluteStart--; 
							}
						}
					}
				} 
				else 
				{ 
					curPosition = textFlow.findPreviousWordBoundary(curPosition,true);
				}
			}
			selection.updateRange(curPosition,curAbsoluteStart);
			operation = new DeleteTextOperation(selection,true);
			doOperation(operation);
		}	
		/**
		 * 在光标位置插入一段文本 
		 * @param text
		 */		
		public function insertText(text:String):void
		{
			if (pendingInsert)
			{
				pendingInsert.text += text;
			}
			else 
			{
				pendingInsert = new InsertTextOperation(getSelectionState(),text,true);
				container.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 1.0, true);
			}
		}
		/**
		 * 从光标位置开始覆盖一段文本 
		 * @param text
		 */		
		public function overwriteText(text:String):void
		{
			if(!text)
				text = "";
			var endIndex:int = absoluteEnd;
			if(absoluteStart==absoluteEnd)
			{
				var length:int = text.length;
				while(length>0)
				{
					endIndex = textFlow.findNextAtomBoundary(endIndex);
					length--;
				}
			}
			var selection:SelectionState = getSelectionState();
			selection.updateRange(absoluteStart,endIndex);
			var operation:InsertTextOperation = new InsertTextOperation(selection,text,true);
			doOperation(operation);
		}
		
		ns_egret function getTextBounds(startIndex:int, endIndex:int):Rectangle
		{
			var rect:Rectangle = new Rectangle();
			var lineStartIndex:int = textFlow.findLineIndexAtPosition(startIndex);
			var lineEndIndex:int = textFlow.findLineIndexAtPosition(endIndex);
			if(lineStartIndex==lineEndIndex)
			{//同一行
				rect.height = textContainer.lineHeight;
				var textLine:TextLine = textFlow.getTextLineAt(lineStartIndex);
				var startPos:int = textFlow.findStartOfLine(lineStartIndex);
				if(textLine)
				{
					var atomIndex:int = textLine.getAtomIndexAtCharIndex(startIndex-startPos);
					if(atomIndex==-1)
					{
						atomIndex = textLine.atomCount-1;
					}
					var bounds:Rectangle = textLine.getAtomBounds(atomIndex);
					rect.x = bounds.x;
					atomIndex = textLine.getAtomIndexAtCharIndex(endIndex-startPos);
					if(atomIndex==-1)
					{
						rect.right = TextLineUtil.getTextWidth(textLine);
					}
					else
					{
						bounds = textLine.getAtomBounds(atomIndex);
						rect.right = bounds.right;
					}
					rect.x += textLine.x;
				}
				rect.y = textContainer.lineHeight*lineStartIndex;
			}
			else
			{
				rect.y = textContainer.lineHeight*lineStartIndex;
				rect.bottom = textContainer.lineHeight*(lineEndIndex+1);
				rect.width = textContainer.width;
			}
			return rect;
		}
		
		ns_egret function endIMESession():void
		{
			_imeSession = null;
			setFocus();
		}
		
		ns_egret function beginIMEOperation():void
		{
			_imeOperationInProgress = true;
			beginCompositeOperation();
		}
		
		private function beginCompositeOperation():void
		{
			flushPendingOperations();
			
		}
		
		ns_egret function endIMEOperation():void
		{
			endCompositeOperation();
			_imeOperationInProgress = false;
		}
		
		private function endCompositeOperation():void
		{
			
		}
		
		override public function selectRange(anchorPosition:int, activePosition:int):Boolean
		{	
			var change:Boolean = super.selectRange(anchorPosition,activePosition);
			if(change)
			{
				if (_imeSession)
					_imeSession.selectionChanged();
			}
			return change;
		}
		
		public function undo():void
		{
			if (_imeSession)
				_imeSession.compositionAbandoned();
			
			if (_undoManager)
				_undoManager.undo();
		}
		
		public function redo():void
		{
			if (_imeSession)
				_imeSession.compositionAbandoned();
			
			if (_undoManager)
				_undoManager.redo();
		}
		
		/**
		 * 当前是否可以执行撤销 
		 */		
		public function canUndo():Boolean
		{
			return _undoManager ? _undoManager.canUndo() : false;
		}
		
		/**
		 * 当前是否可以执行重做 
		 */		
		public function canRedo():Boolean
		{
			return _undoManager ? _undoManager.canRedo() : false;
		}
	}
}