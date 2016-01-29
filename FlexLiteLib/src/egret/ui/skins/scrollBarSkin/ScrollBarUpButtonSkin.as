package egret.ui.skins.scrollBarSkin
{
	import egret.core.BitmapSource;
	
	
	/**
	 * 滚动条上按钮
	 * @author 雷羽佳
	 */
	public class ScrollBarUpButtonSkin extends ScrollBarBaseButtonSkin
	{
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnNormal.png")]
		private var uiUpRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnNormal_r.png")]
		private var uiUpRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnHover.png")]
		private var uiOverRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnHover_r.png")]
		private var uiOverRes_r:Class;
		
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/scroll/upBtnDown_r.png")]
		private var uiDownRes_r:Class;
		
		public function ScrollBarUpButtonSkin()
		{
			super();
			uiUpSource = new BitmapSource(uiUpRes,uiUpRes_r);
			uiDownSource = new BitmapSource(uiDownRes,uiDownRes_r);
			uiOverSource = new BitmapSource(uiOverRes,uiOverRes_r);
		}
	}
}