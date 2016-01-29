package egret.ui.skins.scrollBarSkin
{
	import flash.geom.Rectangle;
	
	import egret.components.Skin;
	import egret.components.UIAsset;
	
	/**
	 * 水平滚动条的底
	 * @author 雷羽佳
	 */
	public class HScrollBarTrackSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/scroll/bg.png")]
		private var bgRes:Class;
		
		
		public function HScrollBarTrackSkin()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			var image:UIAsset = new UIAsset(bgRes);
			image.left = image.right = 0;
			image.top = image.bottom = 0;
			image.minWidth = image.minHeight = 13;
			image.scale9Grid = new Rectangle(1,1,1,1);
			this.addElement(image);
		}
	}
}