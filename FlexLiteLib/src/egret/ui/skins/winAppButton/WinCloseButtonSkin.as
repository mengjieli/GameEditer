package egret.ui.skins.winAppButton
{
	import egret.core.BitmapSource;

	/**
	 * win的关闭按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinCloseButtonSkin extends WinAppButtonBase
	{	
		[Embed(source="/egret/ui/skins/assets/windowBtn/close_icon.png")]
		private var iconRes:Class;
		[Embed(source="/egret/ui/skins/assets/windowBtn/close_icon_r.png")]
		private var iconRes_r:Class;
		
		public function WinCloseButtonSkin()
		{
			super();	
			iconSource = new BitmapSource(iconRes,iconRes_r);
		}
	}
}