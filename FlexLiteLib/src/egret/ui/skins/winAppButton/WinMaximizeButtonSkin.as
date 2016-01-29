package egret.ui.skins.winAppButton
{
	import egret.core.BitmapSource;

	/**
	 * win的最大化按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinMaximizeButtonSkin extends WinAppButtonBase
	{
		[Embed(source="/egret/ui/skins/assets/windowBtn/maximize_icon.png")]
		private var iconRes:Class;
		[Embed(source="/egret/ui/skins/assets/windowBtn/maximize_icon_r.png")]
		private var iconRes_r:Class;
		
		public function WinMaximizeButtonSkin()
		{
			super();
			iconSource = new BitmapSource(iconRes,iconRes_r);
		}
	}
}


