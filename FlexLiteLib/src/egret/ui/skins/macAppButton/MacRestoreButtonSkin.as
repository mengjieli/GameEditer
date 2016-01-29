package egret.ui.skins.macAppButton
{
	import egret.core.BitmapSource;
	
	/**
	 * mac最大化按钮
	 * @author 雷羽佳
	 */
	public class MacRestoreButtonSkin extends MacAppButtonBase
	{
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButton.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButton_r.png")]
		private var uiNormalRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacNormalScreenButtonOver.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacNormalScreenButtonOver_r.png")]
		private var uiHoverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacNormalScreenButtonDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacNormalScreenButtonDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function MacRestoreButtonSkin()
		{
			super();
			upSource = new BitmapSource(uiNormalRes,uiNormalRes_r);
			overSource = new BitmapSource(uiHoverRes,uiHoverRes_r);
			downSource = new BitmapSource(uiDownRes,uiDownRes_r);
		}
		
	}
}