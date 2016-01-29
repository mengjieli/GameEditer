package egret.skins.vector
{
	import egret.components.Group;
	import egret.components.Skin;

	/**
	 * Application的皮肤 
	 * @author 雷羽佳 2014.6.23 12:13
	 * 
	 */	
	public class ApplicationSkin extends Skin
	{
		public var contentGroup:Group;
		public function ApplicationSkin()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			contentGroup = new Group();
			contentGroup.left = 0;
			contentGroup.right = 0;
			contentGroup.top = 0;
			contentGroup.bottom = 0;
			this.addElement(contentGroup);
		}
	}
}