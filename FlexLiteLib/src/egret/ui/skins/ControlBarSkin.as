package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Skin;
	
	/**
	 *
	 * @author 雷羽佳
	 */
	public class ControlBarSkin extends Skin
	{
		public function ControlBarSkin()
		{
			super();
			this.states = ["normal","disabled"];
		}
		
		public var contentGroup:Group
		
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