package egret.ui.skins.managerSkin
{
	public class MinButtonSkin extends IconButtonSkinBase
	{
		[Embed(source="/egret/ui/skins/assets/manager/min_normal.png")]
		public var upSkinName:Class;
		[Embed(source="/egret/ui/skins/assets/manager/min_over.png")]
		public var overSkinName:Class;
		[Embed(source="/egret/ui/skins/assets/manager/min_down.png")]
		public var downSkinName:Class;
		[Embed(source="/egret/ui/skins/assets/manager/min_disabled.png")]
		public var disabledSkinName:Class;
		
		public function MinButtonSkin()
		{
			super();
			this.minWidth = 30;
			this.minHeight = 24;
		}
	}
}
