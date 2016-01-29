package egret.ui.skins.winAppButton
{
	import egret.core.BitmapSource;

	/**
	 * win的窗体恢复按钮 
	 * @author 雷羽佳
	 * 
	 */	
	public class WinRestoreButtonSkin extends WinAppButtonBase
	{

		[Embed(source="/egret/ui/skins/assets/windowBtn/restore_icon.png")]
		private var iconRes:Class;
		[Embed(source="/egret/ui/skins/assets/windowBtn/restore_icon_r.png")]
		private var iconRes_r:Class;

		public function WinRestoreButtonSkin()
		{
			super();
			iconSource = new BitmapSource(iconRes,iconRes_r);
		}
	}
}