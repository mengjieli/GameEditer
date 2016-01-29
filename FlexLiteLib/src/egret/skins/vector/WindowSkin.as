package egret.skins.vector
{
	import egret.components.Group;
	import egret.components.Skin;

	/**
	 * window的皮肤 
	 * @author gerry_000
	 * 
	 */	
	public class WindowSkin extends Skin
	{
		public var contentGroup:Group;
		
		public function WindowSkin()
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