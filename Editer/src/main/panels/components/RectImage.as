package main.panels.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import egret.components.Group;
	import egret.components.UIAsset;

	public class RectImage extends Group
	{
		private var icon:UIAsset;
		private var bg:UIAsset;
		private var w:Number;
		private var h:Number;
		
		public function RectImage(w:Number=20,h:Number=20)
		{
			this.w = w;
			this.h = h;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			var bmd:BitmapData = new BitmapData(1,1);
			bmd.setPixel32(0,0,0x00ff0000);
			bg = new UIAsset(new Bitmap(bmd));
			bg.width = w;
			bg.height = h;
			this.addElement(bg);
			
			icon = new UIAsset();
			icon.verticalCenter = 0;
			icon.horizontalCenter = 0;
			this.addElement(icon);
		}
		
		public function set source(val:Object):void {
			icon.source = val;
		}
	}
}