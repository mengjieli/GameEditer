package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.PopUpAnchor;
	import egret.ui.components.IconList;
	
	/**
	 * 下拉文本的皮肤
	 * @author 雷羽佳
	 */
	public class DropDownTextInputSkin extends TextInputSkin
	{
		public function DropDownTextInputSkin()
		{
			super();
		}
		
		
		public var popUp:PopUpAnchor;
		public var dropDown:Group;
		public var iconList:IconList;
		override protected function createChildren():void
		{
			super.createChildren();
			popUp = new PopUpAnchor();
			popUp.left = popUp.right = popUp.top = popUp.bottom = 0;
			popUp.popUpPosition = "below";
			popUp.popUpWidthMatchesAnchorWidth = true;
			this.addElement(popUp);
			
			dropDown = new Group();
			popUp.popUp = dropDown;
			
			iconList = new IconList();
			iconList.requireSelection = true;
			iconList.maxHeight = 115;
			iconList.percentWidth = 100;
			dropDown.addElement(iconList);
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
		}
		
	}
}