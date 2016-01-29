package egret.ui.skins.macAppButton
{
	import egret.core.BitmapSource;
	
	/**
	 * mac最大化按钮
	 * @author 雷羽佳
	 */
	public class MacMaximizeButtonSkin extends MacAppButtonBase
	{
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButton.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButton_r.png")]
		private var uiNormalRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButtonOver.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButtonOver_r.png")]
		private var uiHoverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButtonDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/macBtn/MacMaximizeButtonDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function MacMaximizeButtonSkin()
		{
			super();
			upSource = new BitmapSource(uiNormalRes,uiNormalRes_r);
			overSource = new BitmapSource(uiHoverRes,uiHoverRes_r);
			downSource = new BitmapSource(uiDownRes,uiDownRes_r);
		}
		
	}
}