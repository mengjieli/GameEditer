package egret.skins.vector
{
	import egret.components.Button;
	import egret.components.Group;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	/**
	 * TitleWindow默认皮肤
	 * @author dom
	 */
	public class TitleWindowSkin extends PanelSkin
	{
		/**
		 * 构造函数
		 */		
		public function TitleWindowSkin()
		{
			super();
		}
		
		public var closeButton:Button;
		
		public var moveArea:Group;
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			moveArea = new Group();
			moveArea.left = 0;
			moveArea.right = 0;
			moveArea.top = 0;
			moveArea.height = 30;
			addElement(moveArea);
			
			closeButton = new Button();
			closeButton.skinName = TitleWindowCloseButtonSkin;
			closeButton.right = 7;
			closeButton.top = 7;
			addElement(closeButton);
		}
	}
}