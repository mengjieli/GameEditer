package egret.ui.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.components.Rect;
	import egret.components.SkinnableComponent;
	import egret.events.UIEvent;
	
	/**
	 * 选中的颜色发生改变
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * 取消
	 */
	[Event(name="cancel", type="flash.events.Event")]

	/**
	 * 确定
	 */
	[Event(name="confirm", type="egret.events.UIEvent")]
	
	/**
	 * 拾色器	
	 * @author dom
	 */
	public class ColorPicker extends SkinnableComponent
	{
		public function ColorPicker()
		{
			super();
			mouseChildren = false;
			addEventListener(MouseEvent.CLICK,onClick);
		}
		
		
		private var _liveChange:Boolean = false;
		/**
		 * 如果为 true，则将在用户交互，而不是在点击确定时，提交颜色值。设置会在下一次打开选择窗口时生效
		 */
		public function get liveChange():Boolean
		{
			return _liveChange;
		}
		
		public function set liveChange(value:Boolean):void
		{
			_liveChange = value;
		}
		
		/**
		 * 单击开始选取颜色
		 */		
		private function onClick(event:MouseEvent):void
		{
			var colorWindow:ColorWindow = new ColorWindow();
			colorWindow.liveChange = liveChange;
			colorWindow.currentColor = _currentColor;
			colorWindow.lastColor = _currentColor;
			colorWindow.defaultColor = _defaultColor;
			colorWindow.addEventListener(Event.CHANGE,onColorPicked);
			colorWindow.addEventListener(UIEvent.CONFIRM,onConfirm);
			colorWindow.addEventListener(Event.CANCEL,onCancel);
			colorWindow.addEventListener(Event.CLEAR,onClear);
			colorWindow.open();
		}
		
		protected function onClear(event:Event):void
		{
			dispatchEvent(new Event(Event.CLEAR));
		}
		
		protected function onCancel(event:Event):void
		{
			this.currentColor = event.currentTarget.lastColor;
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		protected function onConfirm(event:Event):void
		{
			this.currentColor = event.currentTarget.currentColor;
			dispatchEvent(new UIEvent(UIEvent.CONFIRM));
		}
		
		private function onColorPicked(event:Event):void
		{
			var changed:Boolean = (_currentColor!=event.currentTarget.currentColor);
			this.currentColor = event.currentTarget.currentColor;
			validateNow();
			if(changed)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * [SkinPart]文本内容显示对象
		 */		
		public var colorDisplay:Rect;
		
		private var _currentColor:uint = 0x009Aff;
		/**
		 * 当前选中的颜色
		 */
		public function get currentColor():uint
		{
			return _currentColor;
		}
		
		public function set currentColor(value:uint):void
		{
			if(_currentColor==value)
				return;
			_currentColor = value;
			if(colorDisplay)
			{
				colorDisplay.fillColor = _currentColor;
			}
		}
		
		private var _defaultColor:uint = 0x009aff;
		/**
		 * 默认的颜色
		 */
		public function get defaultColor():uint
		{
			return _defaultColor;
		}
		public function set defaultColor(value:uint):void
		{
			_defaultColor = value;
		} 
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==colorDisplay)
			{
				colorDisplay.fillColor = _currentColor;
			}
		}
	}
}