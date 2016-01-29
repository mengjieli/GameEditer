package main.panels.directionView
{
	import flash.events.MouseEvent;
	
	import egret.ui.components.IconButton;
	
	import main.menu.MenuID;
	import main.menu.NativeMenuExtend;
	import main.menu.NativeMenuItemExtend;
	import main.panels.components.DirectionTreeItem;

	public class DirectionViewItem extends DirectionTreeItem
	{
		public function DirectionViewItem()
		{
			super();
			this.skinName = DirectionViewItemSkin;
		}
		
		public var button0:IconButton;
		public var button1:IconButton;
		public var button2:IconButton;
		public var button3:IconButton;
		public var button4:IconButton;
		//		public var button5:IconButton;
		//		public var button6:IconButton;
		//		public var button7:IconButton;
		
		override public function set data(value:Object):void {
			super.data = value;
			
			//为日志面板创建右键菜单
			var menu:main.menu.NativeMenuExtend = new NativeMenuExtend([new NativeMenuItemExtend(data.url,MenuID.CLEARLOG,false,null,null)]);
			button1.visible = button0.visible = true;
			button0.icon = "assets/ui/button/folder_add.png";
			button1.icon = "assets/ui/button/add.png";
			button0.removeEventListener(MouseEvent.CLICK,clickButton);
			button0.addEventListener(MouseEvent.CLICK,clickButton);
			
//			button1.toolTip = "添加文件";
//			button0.toolTip = "添加文件夹";
			
			this.contextMenu = menu;
		}
		
		private function clickButton(e:MouseEvent):void {
			(new LoaderPanel("panels/AddModelPanel.swf")).open(true);
		}
	}
}