package main.panels.contenView
{
	import flash.events.MouseEvent;
	
	import egret.ui.components.TabPanel;
	import egret.ui.components.boxClasses.FocusTabBarButton;

	public class ContentTabBar extends FocusTabBarButton
	{
		public function ContentTabBar()
		{
			this.addEventListener(MouseEvent.ROLL_OVER,onMouseEvent);
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseEvent);
		}
		
		
		public var closeButton:ContentCloseButton;
		
		private function onMouseEvent(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.ROLL_OVER:
					closeButton.visible = true;
					if(inCloseButton) {
						closeButton.onMouseEvent(new MouseEvent(MouseEvent.ROLL_OVER));
					} else {
						closeButton.onMouseEvent(new MouseEvent(MouseEvent.ROLL_OUT));
					}
					break;
				case MouseEvent.ROLL_OUT:
					closeButton.visible = false;
					break;
				case MouseEvent.MOUSE_MOVE:
					if(inCloseButton) {
						closeButton.onMouseEvent(new MouseEvent(MouseEvent.ROLL_OVER));
					} else {
						closeButton.onMouseEvent(new MouseEvent(MouseEvent.ROLL_OUT));
					}
					break;
				case MouseEvent.MOUSE_UP:
					if(inCloseButton) {
						var panel:TabPanel = data.panel;
						if(panel) {
							(panel.owner as ContentView).closePanel(panel);
						}
					}
					break;
			}
		}
		
		private function get inCloseButton():Boolean {
			if(!closeButton) return false;
			if(closeButton.mouseX < 0 || closeButton.mouseX > closeButton.width || closeButton.mouseY < 0 || closeButton.mouseY > closeButton.height) return false;
			return true;
		}
	}
}