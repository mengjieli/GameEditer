package egret.ui.skins
{
	import egret.components.Rect;
	import egret.components.Skin;

	/**
	 * 色相滑块儿的底条的
	 * @author 雷羽佳
	 * 
	 */		
	public class VSliderTrackSkin extends Skin
	{
		public function VSliderTrackSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}
		
		override protected function createChildren():void
		{
			var rect:Rect = new Rect();
			rect.fillAlpha = 0;
			rect.fillColor = 0;
			rect.left = 0;
			rect.right = 0;
			rect.top = 0;
			rect.bottom = 0;
			this.addElement(rect);
		}
	}
}