package egret.ui.skins.macAppButton
{
	import egret.core.BitmapSource;
	
	/**
	 * mac最小化按钮
	 * @author 雷羽佳
	 */
	public class MacCloseButtonSkin extends MacAppButtonBase
	{
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButton.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButton_r.png")]
		private var uiNormalRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonOver.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonOver_r.png")]
		private var uiHoverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacCloseButtonDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function MacCloseButtonSkin()
		{
			super();
			upSource = new BitmapSource(uiNormalRes,uiNormalRes_r);
			overSource = new BitmapSource(uiHoverRes,uiHoverRes_r);
			downSource = new BitmapSource(uiDownRes,uiDownRes_r);
		}
		
	}
}