package egret.ui.skins.winWindowSkin
{

	/**
	 * 颜色选择器的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinColorWindowSkin extends WinWindowSkin
	{
		[Embed(source="/egret/ui/skins/assets/circle_white.png")] 
		public var ICON_CIRCLE_WHITE:Class;
		
		[Embed(source="/egret/ui/skins/assets/circle_black.png")] 
		public var ICON_CIRCLE_BLACK:Class;
		
		public function WinColorWindowSkin()
		{
			super();
		}
	}
}