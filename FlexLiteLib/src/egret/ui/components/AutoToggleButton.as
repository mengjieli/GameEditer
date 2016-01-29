package egret.ui.components
{
	import egret.components.ToggleButton;
	
	/**
	 *
	 * @author 雷羽佳
	 */
	public class AutoToggleButton extends ToggleButton
	{
		public function AutoToggleButton()
		{
			super();
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
		}
		
		public var autoSelected:Boolean = true;
		
		override protected function buttonReleased():void
		{
			if(!autoSelected)
				return;
			super.buttonReleased();
		}
	}
}