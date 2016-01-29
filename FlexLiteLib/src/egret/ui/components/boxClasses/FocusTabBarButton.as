package egret.ui.components.boxClasses
{
	import egret.ui.components.IconTabBarButton;
	

	/**
	 * 带焦点状态的选项卡按钮
	 */
	public class FocusTabBarButton extends IconTabBarButton
	{
		public function FocusTabBarButton()
		{
			super();
		}
		
		private var _isFocus:Boolean = true;
		/**
		 * 是否是焦点选项卡
		 */
		public function get isFocus():Boolean
		{
			return _isFocus;
		}
		
		public function set isFocus(value:Boolean):void
		{
			if(_isFocus == value)
				return;
			_isFocus = value;
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			if(this.isFocus && this.selected)
				return "focus";
			return super.getCurrentSkinState();
		}
	}
}