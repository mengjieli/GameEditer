package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import egret.components.supportClasses.ButtonBase;
	import egret.components.supportClasses.DropDownController;
	import egret.components.supportClasses.SliderBase;
	import egret.core.ns_egret;
	import egret.events.TrackBaseEvent;
	import egret.events.UIEvent;
	
	use namespace ns_egret;

	/**
	 * 下拉框打开事件
	 * @eventType egret.events.UIEvent.OPEN
	 */	
	[Event(name="open",type="egret.events.UIEvent")]
	/**
	 * 下拉框关闭事件
	 */	
	[Event(name="close",type="egret.events.UIEvent")]
	
	[EXML(show="false")]
	
	[SkinState("normal")]
	[SkinState("open")]
	[SkinState("disabled")]
	
	/**
	 * 弹出滑块组件
	 */
	public class PopUpSliderBase extends SliderBase
	{

		public function PopUpSliderBase()
		{
			super();
			this.slideDuration = 0;
			this.addEventListener(TrackBaseEvent.THUMB_PRESS , onPress);
			this.addEventListener(TrackBaseEvent.THUMB_RELEASE , onRelease);
			dropDownController = new DropDownController();
		}
		
		private var _isDragging:Boolean;
		/**
		 * 是否正在拖拽
		 */
		public function get isDragging():Boolean
		{
			return _isDragging;
		}

		protected function onRelease(event:TrackBaseEvent):void
		{
			_isDragging = false;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onPress(event:TrackBaseEvent):void
		{
			_isDragging = true;
		}
		
		/**
		 * [SkinPart]文本输入控件
		 */		
		public var textInput:TextInput;
		
		/**
		 * [SkinPart]下拉区域显示对象
		 */		
		public var dropDown:DisplayObject;
		/**
		 * [SkinPart]下拉触发按钮
		 */		
		public var openButton:ButtonBase;
		
		
		private var _dropDownController:DropDownController; 
		/**
		 * 下拉控制器
		 */
		protected function get dropDownController():DropDownController
		{
			return _dropDownController;
		}
		
		protected function set dropDownController(value:DropDownController):void
		{
			if (_dropDownController == value)
				return;
			
			_dropDownController = value;
			
			_dropDownController.addEventListener(UIEvent.OPEN, dropDownController_openHandler);
			_dropDownController.addEventListener(UIEvent.CLOSE, dropDownController_closeHandler);
			
			if (openButton)
				_dropDownController.openButton = openButton;
			if (dropDown)
				_dropDownController.dropDown = dropDown;    
		}
		/**
		 * 下拉列表是否已经已打开
		 */		
		public function get isDropDownOpen():Boolean
		{
			if (dropDownController)
				return dropDownController.isOpen;
			else
				return false;
		}
		
		/**
		 * 打开下拉列表并抛出UIEvent.OPEN事件。
		 */		
		public function openDropDown():void
		{
			dropDownController.openDropDown();
		}
		/**
		 * 关闭下拉列表并抛出UIEvent.CLOSE事件。
		 */		
		public function closeDropDown(commit:Boolean):void
		{
			dropDownController.closeDropDown(commit);
		}
		
		private var _labelFunction:Function;
		/**
		 * 将value转换成文本的方法
		 * 示例：function labelFunc(value:Number):String 。
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}

		public function set labelFunction(value:Function):void
		{
			_labelFunction = value;
			if(textInput)
				textInput.text = valueToText(this.value);
		}
		
		private var promptChanged:Boolean;
		private var _promptValue:Number;
		/**
		 * 当前默认值
		 */
		public function get promptValue():Number
		{
			if(isNaN(_promptValue))
				return 0;
			return _promptValue;
		}

		public function set promptValue(value:Number):void
		{
			promptChanged = true;
			_promptValue = value;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == textInput)
			{
				textInput.text = valueToText(value);
				textInput.addEventListener(FocusEvent.FOCUS_OUT , onTextInputFocusOut);
			}
			else if (instance == openButton)
			{
				if (dropDownController)
					dropDownController.openButton = openButton;
			}
			else if (instance == dropDown && dropDownController)
			{
				dropDownController.dropDown = dropDown;
			}
		}
		
		private function onTextInputFocusOut(event:FocusEvent):void
		{
			if(isNaN(Number(textInput.text)))
			{
				textInput.text = valueToText(value);
				return;
			}
			var prevValue:Number = this.value;
			if(!textInput.text)
			{
				updatePromptValue();
			}
			else
			{
				setValue(nearestValidValue(Number(textInput.text),snapInterval));
			}
			if (value != prevValue)
				dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 控制器抛出打开列表事件
		 */
		ns_egret function dropDownController_openHandler(event:UIEvent):void
		{
			addEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			invalidateSkinState();  
		}
		/**
		 * 打开列表后组件一次失效验证全部完成
		 */
		ns_egret function open_updateCompleteHandler(event:UIEvent):void
		{   
			removeEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL , stage_mouseWheelHandler , true);
			dispatchEvent(new UIEvent(UIEvent.OPEN));
		}
		/**
		 * 控制器抛出关闭列表事件
		 */		
		protected function dropDownController_closeHandler(event:UIEvent):void
		{
			addEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			invalidateSkinState();
		}
		/**
		 * 关闭列表后组件一次失效验证全部完成
		 */		
		private function close_updateCompleteHandler(event:UIEvent):void
		{   
			removeEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL , stage_mouseWheelHandler , true);
			dispatchEvent(new UIEvent(UIEvent.CLOSE));
		}
		
		/**
		 * 鼠标滚轮事件
		 */
		protected function stage_mouseWheelHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			changeValueByStep(event.delta>0);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function setValue(value:Number):void
		{
			super.setValue(value);
			if(textInput)
				textInput.text = valueToText(value);
			_isPrompt = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(promptChanged || !initialized)
			{
				promptChanged = false;
				textInput.prompt = valueToText(nearestValidValue(promptValue,snapInterval));
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
			textInput.text = "";
			_isPrompt = true;
			promptChanged = true;
			invalidateProperties();
		}
		
		/**
		 * 将值转换为文本
		 */
		public function valueToText(value:Number):String
		{
			if(_labelFunction!=null)
				return labelFunction(value);
			else
				return String(value);
		}
	}
}