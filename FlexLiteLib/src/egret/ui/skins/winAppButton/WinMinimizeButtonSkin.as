package egret.ui.skins.winAppButton
{
	import egret.core.BitmapSource;

	/**
	 * win的最小化按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinMinimizeButtonSkin extends WinAppButtonBase
	{	
		
		[Embed(source="/egret/ui/skins/assets/windowBtn/minimize_icon.png")]
		private var iconRes:Class;
		[Embed(source="/egret/ui/skins/assets/windowBtn/minimize_icon_r.png")]
		private var iconRes_r:Class;

		public function WinMinimizeButtonSkin()
		{
			super();
			iconSource = new BitmapSource(iconRes,iconRes_r);
		}
	}
}