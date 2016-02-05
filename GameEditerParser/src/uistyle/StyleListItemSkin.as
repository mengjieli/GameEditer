package uistyle
{
	import egret.components.Label;
	import egret.components.Skin;

	public class StyleListItemSkin extends Skin
	{
		public function StyleListItemSkin()
		{
		}
		
		public var nameTxt:Label;
		public var image:AcceptImage;
		
		override protected function createChildren():void {
			super.createChildren();
			
			nameTxt = new Label();
			nameTxt.verticalCenter = 0;
			this.addElement(nameTxt);
			
			image = new AcceptImage();
			image.verticalCenter = 0;
			image.x = 80;
			this.addElement(image);
		}
	}
}