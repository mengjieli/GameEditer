package egret.ui.components.boxClasses
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.components.Button;
	import egret.managers.Translator;
	import egret.ui.events.CloseTabEvent;
	
	/**
	 * 选项卡关闭按钮
	 * @author dom
	 */
	public class CloseTabButton extends FocusTabBarButton
	{
		public function CloseTabButton()
		{
			super();
			mouseChildren = true;
			this.addEventListener(MouseEvent.RIGHT_CLICK,rightClickHandler);
			this.addEventListener(MouseEvent.MIDDLE_CLICK,middleClickHandler);
		}
		
		protected function middleClickHandler(event:MouseEvent):void
		{
			dispatchEvent(new CloseTabEvent(CloseTabEvent.CLOSE,true));
		}
		
		private var tabMenu:NativeMenu;
		protected function rightClickHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			if(!tabMenu)
			{
				tabMenu = createMenu([
					Translator.getText("CloseTabButton.Close"),
					Translator.getText("CloseTabButton.CloseOther"),
					Translator.getText("CloseTabButton.CloseAll")]);
			}
			var pos:Point = this.localToGlobal(new Point(this.mouseX,this.mouseY));
			tabMenu.display(stage,pos.x,pos.y);
		}
		
		private function createMenu(labelList:Array):NativeMenu
		{
			var menu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			var index:int = 0;
			for each(var label:String in labelList)
			{
				item = new NativeMenuItem(label,!label);
				if(label)
					item.addEventListener(Event.SELECT,onMenuSelect);
				menu.addItem(item);
				index++;
			}
			return menu;
		}
		
		/**
		 * 菜单被点击
		 */		
		private function onMenuSelect(event:Event):void
		{
			switch(event.target.label)
			{
				case Translator.getText("CloseTabButton.Close"):
					dispatchEvent(new CloseTabEvent(CloseTabEvent.CLOSE,true));
					break;
				case Translator.getText("CloseTabButton.CloseOther"):
					dispatchEvent(new CloseTabEvent(CloseTabEvent.CLOSE_OTHER,true));
					break;
				case Translator.getText("CloseTabButton.CloseAll"):
					dispatchEvent(new CloseTabEvent(CloseTabEvent.CLOSE_ALL,true));
					break;
			}
		}
		
		/**
		 * 关闭按钮
		 */		
		public var closeButton:Button;
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName,instance);
			if(instance==closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK,onCloseButtonClick);
			}
		}

		/**
		 * 点击了关闭按钮
		 */		
		private function onCloseButtonClick(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			dispatchEvent(new CloseTabEvent(CloseTabEvent.CLOSE,true));
		}
	}
}