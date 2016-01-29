package egret.ui.skins
{
	import egret.components.Button;
	import egret.components.Skin;

	
	/**
	 * 色相滑块儿组件整体的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class HueSliderSkin extends Skin
	{
		
		public var thumb:Button;
		public var track:Button;
		public function HueSliderSkin()
		{
			super();
			states = ["normal","disabled"];
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			thumb = new Button();
			thumb.horizontalCenter = 0;
			thumb.height = 1;
			thumb.tabEnabled = false;
			thumb.skinName = HueThumbButtonSkin;
			this.addElement(thumb);
			
			track = new Button();
			track.width = 20;
			track.horizontalCenter = 0;
			track.top = 0;
			track.bottom = 0;
			track.height = 256;
			track.tabEnabled = false;
			track.alpha = 1;
			track.skinName = VSliderTrackSkin;
			this.addElement(track);
		}
	}
}