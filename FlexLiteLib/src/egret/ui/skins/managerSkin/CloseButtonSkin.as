package egret.ui.skins.managerSkin
{
	import egret.core.BitmapSource;

	public class CloseButtonSkin extends IconButtonSkinBase
	{
		[Embed(source="/egret/ui/skins/assets/manager/close_normal.png")]
		public var upSkinRes:Class;
		[Embed(source="/egret/ui/skins/assets/manager/close_normal_r.png")]
		public var upSkinRes_r:Class;
		
		public var upSkinName:BitmapSource = new BitmapSource(upSkinRes,upSkinRes_r);
		
		[Embed(source="/egret/ui/skins/assets/manager/close_over.png")]
		public var overSkinRes:Class;
		[Embed(source="/egret/ui/skins/assets/manager/close_over_r.png")]
		public var overSkinRes_r:Class;
		
		public var overSkinName:BitmapSource = new BitmapSource(overSkinRes,overSkinRes_r);
		
		[Embed(source="/egret/ui/skins/assets/manager/close_down.png")]
		public var downSkinRes:Class;
		[Embed(source="/egret/ui/skins/assets/manager/close_down_r.png")]
		public var downSkinRes_r:Class;
		
		public var downSkinName:BitmapSource = new BitmapSource(downSkinRes,downSkinRes_r);
		
		[Embed(source="/egret/ui/skins/assets/manager/close_disabled.png")]
		public var disabledSkinRes:Class;
		[Embed(source="/egret/ui/skins/assets/manager/close_disabled_r.png")]
		public var disabledSkinRes_r:Class;
		
		public var disabledSkinName:BitmapSource = new BitmapSource(disabledSkinRes,disabledSkinRes_r);
		
		public function CloseButtonSkin()
		{
			super();
			this.minWidth = 30;
			this.minHeight = 24;
		}
	}
}
