package main.panels.directionView
{
	import egret.components.Group;
	import egret.ui.components.IconButton;
	
	import main.panels.components.DirectionTreeItemSkin;

	public class DirectionViewItemSkin extends DirectionTreeItemSkin
	{
		public function DirectionViewItemSkin()
		{
		}
		
		
		public var buttonContainer:Group;
		public var button0:IconButton;
		public var button1:IconButton;
		public var button2:IconButton;
		public var button3:IconButton;
		public var button4:IconButton;
//		public var button5:IconButton;
//		public var button6:IconButton;
//		public var button7:IconButton;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			buttonContainer = new Group();
			buttonContainer.percentWidth = 100;
			buttonContainer.percentHeight = 100;
			this.addElement(buttonContainer);
			
			for(var i:int = 0; i < 5; i++) {
				this["button"+i] = new IconButton();
				buttonContainer.addElement(this["button"+i]);
				this["button"+i].right = 5 + 25 * i;
				this["button"+i].verticalCenter = 0;
				this["button"+i].visible = false;
			}
		}
	}
}