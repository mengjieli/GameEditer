package egret.ui.skins
{
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;

	/**
	 * 色相滑块儿的按钮皮肤
	 * @author 雷羽佳
	 * 
	 */	
	public class HueThumbButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/colorphase_thumb.png")]
		private var iamgeRes:Class;
		[Embed(source="/egret/ui/skins/assets/colorphase_thumb_r.png")]
		private var iamgeRes_r:Class;
		
		private var _image:UIAsset;
		public function HueThumbButtonSkin()
		{
			super();
			this.width = 37;
			this.height = 1;
			this.states = ["up","over","down","disabled"];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			_image = new UIAsset();
			_image.source = new BitmapSource(iamgeRes,iamgeRes_r);
			_image.y = -6;
			this.addElement(_image);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			
			switch(currentState)
			{
				case "up":
				{
					_image.alpha = 1;
					break;
				}
				case "over":
				{
					_image.alpha = 1;
					break;
				}
				case "down":
				{
					_image.alpha = 1;
					break;
				}
				case "disabled":
				{
					_image.alpha = 0.5;
					break;
				}	
				default:
				{
					break;
				}
			}
		}
	}
}