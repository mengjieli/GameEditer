package egret.ui.components
{
	import egret.components.Button;
	
	
	/**
	 * 具有强制显示over状态功能的按钮
	 * @author dom
	 */
	public class RollOverButton extends Button
	{
		public function RollOverButton()
		{
			super();
		}
		
		private var _keepOver:Boolean = false;
		/**
		 * 强制显示over状态
		 */		
		public function get keepOver():Boolean
		{
			return _keepOver;
		}
		
		public function set keepOver(value:Boolean):void
		{
			if(_keepOver==value)
				return;
			_keepOver = value;
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			if(enabled&&_keepOver && super.getCurrentSkinState() != "down")
			{
				return "over";
			}
			return super.getCurrentSkinState();
		}
	}
}