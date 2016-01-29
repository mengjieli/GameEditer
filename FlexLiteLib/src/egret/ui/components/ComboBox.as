package egret.ui.components
{
	import flash.display.DisplayObject;
	
	import egret.components.ComboBox;
	import egret.core.IUIComponent;
	import egret.core.ns_egret;
	import egret.events.UIEvent;
	
	use namespace ns_egret;
	
	/**
	 * 关闭下拉菜单后自动重置焦点
	 * @author 雷羽佳
	 */
	public class ComboBox extends egret.components.ComboBox
	{
		public function ComboBox()
		{
			super();
		}
		
		private var _maxPopHeight:Number = 300;
		/**
		 * 弹出框的最大显示高度。-1表示不限制。
		 */
		public function get maxPopHeight():Number
		{
			return _maxPopHeight;
		}
		
		public function set maxPopHeight(value:Number):void
		{
			_maxPopHeight = value;
			if(dataGroup)
			{
				if(_maxPopHeight == -1)
				{
					dataGroup.maxHeight = 10000;
				}else
				{
					dataGroup.maxHeight= _maxPopHeight;
				}
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==dataGroup)
			{
				if(_maxPopHeight == -1)
				{
					dataGroup.maxHeight = 10000;
				}else
				{
					dataGroup.maxHeight= _maxPopHeight;
				}
			}
		}
		
		override protected function dropDownController_closeHandler(event:UIEvent):void
		{
			super.dropDownController_closeHandler(event);
			var parent:DisplayObject = this.parent;
			while(parent)
			{
				if(parent is IUIComponent && IUIComponent(parent).focusEnabled)
				{
					IUIComponent(parent).setFocus();
					return;
				}
				parent = parent.parent;
			}
			Application.topApp.setFocus();
		}
		
		/**
		 *设置焦点至输入框中的文本 
		 * 
		 */
		override public function setFocus():void
		{
			if (stage && textInput)
			{            
				textInput.textDisplay.setFocus();
			}
		}
	}
}