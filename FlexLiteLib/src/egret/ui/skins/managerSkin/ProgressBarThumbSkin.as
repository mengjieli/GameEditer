package egret.ui.skins.managerSkin
{
	import egret.components.Skin;
	import egret.components.UIAsset;

	public class ProgressBarThumbSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/manager/progressbar_thumb.png")]
		private var uiRes:Class;
		
		public function ProgressBarThumbSkin()
		{
			super();
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			var back:UIAsset = new UIAsset();
			back.source = uiRes;
			back.percentHeight = back.percentWidth=100;
			this.addElement(back);
		}
	}
}