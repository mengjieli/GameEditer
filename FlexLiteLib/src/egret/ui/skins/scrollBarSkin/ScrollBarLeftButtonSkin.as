package egret.ui.skins.scrollBarSkin
{
	import egret.core.BitmapSource;
	
	
	/**
	 * 滚动条左按钮
	 * @author 雷羽佳
	 */
	public class ScrollBarLeftButtonSkin extends ScrollBarBaseButtonSkin
	{
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnNormal.png")]
		private var uiUpRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnNormal_r.png")]
		private var uiUpRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnHover.png")]
		private var uiOverRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnHover_r.png")]
		private var uiOverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/leftBtnDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function ScrollBarLeftButtonSkin()
		{
			super();
			uiUpSource = new BitmapSource(uiUpRes,uiUpRes_r);
			uiDownSource = new BitmapSource(uiDownRes,uiDownRes_r);
			uiOverSource = new BitmapSource(uiOverRes,uiOverRes_r);
		}
	}
}