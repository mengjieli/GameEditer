package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.MouseCursor;
	
	import egret.components.supportClasses.Range;
	import egret.core.IDisplayText;
	import egret.core.UIGlobals;
	import egret.managers.CursorManager;
	import egret.ui.core.Cursors;
	
	/**
	 * 当控件的值由于用户交互操作而发生更改时分派。 
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 数字调节器,能通过左右或者上下拖拽以及输入的形式调节指定范围内的数字
	 */
	public class NumberRegulator extends Range
	{
		public function NumberRegulator()
		{
			super();
			this.focusEnabled = false;
		}
		
		/**
		 * [SkinPart]文本输入控件
		 */
		public var editableText:TextInput;
		
		/**
		 * [SkinPart]文本显示控件
		 */
		public var labelDisplay:IDisplayText;
		
		private var promptChanged:Boolean;
		private var _promptValue:Number;
		
		/**
		 * @inheritDoc
		 */
		override public function set value(newValue:Number):void
		{
			_isPrompt = false;
			super.value = newValue;
			invalidateSkinState();
		}
		
		/**
		 * 当文本输入为空时要显示的值
		 */
		public function get promptValue():Number
		{
			if(isNaN(_promptValue))
			{
				return 0;
			}
			return _promptValue;
		}

		public function set promptValue(value:Number):void
		{
			_promptValue = value;
			promptChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(promptChanged)
			{
				promptChanged = false;
				if(getCurrentSkinState() == "prompt")
				{
					_isPrompt = false;
					setValue(nearestValidValue(promptValue,snapInterval));
					_isPrompt = true;
				}
			}
		}
		
		private var _isPrompt:Boolean;
		/**
		 * 是否是默认值状态
		 */
		public function get isPrompt():Boolean
		{
			return _isPrompt;
		}
		
		private var _openLabelWheel:Boolean;
		/**
		 * 是否开启标签滚轮改变值的功能 ， 默认不开启
		 */
		public function get openLabelWheel():Boolean
		{
			return _openLabelWheel;
		}

		public function set openLabelWheel(value:Boolean):void
		{
			if(_openLabelWheel == value)
				return;
			_openLabelWheel = value;
			if(labelDisplay)
			{
				if(value)
					this.addEventListener(MouseEvent.MOUSE_WHEEL , labelDisplay_mouseWheelHandler , true);
				else
					this.removeEventListener(MouseEvent.MOUSE_WHEEL , labelDisplay_mouseWheelHandler , true);
			}
		}

		/**
		 * 更新默认值，调用此方法会使文本标签呈现为默认值状态
		 * @param promptValue 新的默认值，不写则使用原来的默认值而不更新默认值
		 */
		public function updatePromptValue(newValue:Number = NaN):void
		{
			if(!isNaN(newValue))
			{
				_promptValue = newValue;
			}
			setValue(nearestValidValue(promptValue,snapInterval));
			_isPrompt = true;
			invalidateSkinState();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if(instance == editableText)
			{
				editableText.text = String(value);
				editableText.addEventListener(MouseEvent.MOUSE_WHEEL , editableText_mouseWheelHandler , true);
				editableText.addEventListener(KeyboardEvent.KEY_DOWN , editableText_keyDownHandler);
			}
			else if(instance == labelDisplay)
			{
				labelDisplay.text = String(value);
				if(openLabelWheel)
					this.addEventListener(MouseEvent.MOUSE_WHEEL , labelDisplay_mouseWheelHandler , true);
				this.addEventListener(MouseEvent.ROLL_OVER , labelDisplay_rollOverHandler);
				this.addEventListener(MouseEvent.ROLL_OUT , labelDisplay_rollOutHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN , labelDisplay_mouseDownHandler);
				this.addEventListener(MouseEvent.CLICK , labelDisplay_mouseClickHandler);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			if(instance == editableText)
			{
				editableText.removeEventListener(MouseEvent.MOUSE_WHEEL , editableText_mouseWheelHandler , true);
				editableText.removeEventListener(KeyboardEvent.KEY_DOWN , editableText_keyDownHandler);
			}
			else if(instance == labelDisplay)
			{
				this.removeEventListener(MouseEvent.MOUSE_WHEEL , labelDisplay_mouseWheelHandler , true);
				this.removeEventListener(MouseEvent.ROLL_OVER , labelDisplay_rollOverHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT , labelDisplay_rollOutHandler);
				this.removeEventListener(MouseEvent.MOUSE_DOWN , labelDisplay_mouseDownHandler);
				this.removeEventListener(MouseEvent.CLICK , labelDisplay_mouseClickHandler);
			}
		}
		
		private function labelDisplay_mouseWheelHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			if(_isDragging || isEditModel)
			{
				return;
			}
			CursorManager.setCursor(Cursors.DESKTOP_RESIZE_NS);
			var prevValue:Number = this.value;
			changeValueByStep(event.delta>0);
			if (value != prevValue)
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function labelDisplay_rollOutHandler(event:MouseEvent):void
		{
			if(!_isDragging && !isEditModel)
				CursorManager.setCursor(MouseCursor.ARROW);
		}
		
		private function labelDisplay_rollOverHandler(event:MouseEvent):void
		{
			if(!_isDragging && !isEditModel)
				CursorManager.setCursor(Cursors.DESKTOP_RESIZE_EW);
		}
		
		/**
		 * 可编辑文本的鼠标滚轮事件
		 */
		private function editableText_mouseWheelHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			var textValue:Number = Number(editableText.text);
			if(isNaN(textValue))
			{
				editableText.text = String(value);
				return;
			}
			var newValue:Number = (event.delta>0) ? textValue + stepSize : textValue - stepSize;
			editableText.text = String(nearestValidValue(newValue , snapInterval));
			editableText.selectAll();
		}
		
		/**
		 * 鼠标点击
		 */
		private function labelDisplay_mouseClickHandler(event:MouseEvent):void
		{
			if(!hasUpdateValue)
			{
				enterEditMode();
			}
		}
		
		/**
		 * 是否是编辑模式
		 */
		private var isEditModel:Boolean;
		/**
		 * 进入编辑模式
		 */
		protected function enterEditMode():void
		{
			isEditModel = true;
			CursorManager.setCursor(MouseCursor.AUTO);
			editableText.setFocus();
			editableText.selectAll();
			stage.addEventListener(MouseEvent.MOUSE_DOWN , stage_mouseDownHandler);
			invalidateSkinState();
		}
		
		/**
		 * 按键事件
		 */
		private function editableText_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
				exitEditMode();
			else if(event.keyCode == Keyboard.ESCAPE)
				exitEditMode(false);
		}
		
		/**
		 * 鼠标在舞台上按下时退出编辑模式
		 */
		private function stage_mouseDownHandler(event:Event):void
		{
			if(this.contains(event.target as DisplayObject))
				return;
			exitEditMode();
		}
		
		/**
		 * 退出编辑模式
		 */
		protected function exitEditMode(save:Boolean = true):void
		{
			CursorManager.setCursor(MouseCursor.AUTO);
			isEditModel = false;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN , stage_mouseDownHandler);
			if(save)
			{
				if(!editableText.text)
				{
					updatePromptValue();
					dispatchEvent(new Event(Event.CHANGE));
				}
				else
				{
					var newValue:Number = Number(editableText.text);
					if(!isNaN(newValue))
					{
						newValue = nearestValidValue(newValue , snapInterval);
						if(isPrompt || newValue != value)
						{
							setValue(newValue);
							dispatchEvent(new Event(Event.CHANGE));
						}
					}
				}
			}
			invalidateSkinState();
		}
		
		
		private var _isDragging:Boolean;
		/**
		 * 是否正在拖拽
		 */
		public function get isDragging():Boolean
		{
			return _isDragging;
		}
		
		private var lastPoint:Point = new Point();
		private var lastValue:Number;
		
		/**
		 * 文本显示组件上按钮按下
		 */
		private function labelDisplay_mouseDownHandler(event:MouseEvent):void
		{
			if(isEditModel)
				return;
			lastValue = value;
			lastPoint.x = event.stageX;
			lastPoint.y = event.stageY;
			_isDragging = true;
			hasUpdateValue = false;
			
			CursorManager.setCursor(Cursors.DESKTOP_RESIZE_EW);
			
			stage.addEventListener(MouseEvent.MOUSE_UP , stage_mouseUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE , stage_mouseMoveHandler);
		}
		
		/**
		 * 鼠标在舞台上移动
		 */
		protected function stage_mouseMoveHandler(event:MouseEvent):void
		{
			updateWhenMouseMove();
			if(UIGlobals.useUpdateAfterEvent)
				event.updateAfterEvent();
		}
		
		/**
		 * 拖拽是否改变了值
		 */
		private var hasUpdateValue:Boolean;
		/**
		 * 鼠标拖动时更新值
		 */
		private function updateWhenMouseMove():void
		{
			var changeValue:Number = this.stage.mouseX - lastPoint.x + this.stage.mouseY - lastPoint.y;

			var prevValue:Number = this.value;
			var newValue:Number = nearestValidValue(lastValue + changeValue , snapInterval)
			if(prevValue != newValue)
			{
				setValue(newValue);
			}
			lastValue = this.value;
			lastPoint.x = this.stage.mouseX;
			lastPoint.y = this.stage.mouseY;
			
			if (value != prevValue)
			{
				hasUpdateValue = true;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * 鼠标弹起
		 */
		protected function stage_mouseUpHandler(event:MouseEvent):void
		{
			_isDragging = false;
			
			CursorManager.setCursor(MouseCursor.AUTO);
			if(labelDisplay is DisplayObject)
			{
				if(DisplayObject(labelDisplay).getBounds(stage).contains(event.stageX , event.stageY))
				{
					CursorManager.setCursor(Cursors.DESKTOP_RESIZE_EW);
				}
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_UP , stage_mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE , stage_mouseMoveHandler);
			
			if(hasUpdateValue)
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			if(isEditModel && enabled)
				return "edit";
			else if(_isPrompt)
				return "prompt";
			return super.getCurrentSkinState();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function setValue(value:Number):void
		{
			super.setValue(value);
			if(this.editableText)
				this.editableText.text = String(value);
			if(this.labelDisplay)
				this.labelDisplay.text = String(value);
			if(_isPrompt && initialized)
			{
				_isPrompt = false;
				invalidateSkinState();
			}
		}
	}
}