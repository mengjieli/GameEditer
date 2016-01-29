package egret.ui.skins.macAppButton
{
	import egret.core.BitmapSource;
	
	/**
	 * mac最小化按钮
	 * @author 雷羽佳
	 */
	public class MacMinimizeButtonSkin extends MacAppButtonBase
	{
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButton.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButton_r.png")]
		private var uiNormalRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButtonOver.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButtonOver_r.png")]
		private var uiHoverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButtonDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMinimizeButtonDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function MacMinimizeButtonSkin()
		{
			super();
			upSource = new BitmapSource(uiNormalRes,uiNormalRes_r);
			overSource = new BitmapSource(uiHoverRes,uiHoverRes_r);
			downSource = new BitmapSource(uiDownRes,uiDownRes_r);
		}
		
	}
}