package main.ui
{
	import egret.ui.components.TabPanel;
	
	import main.events.EventMgr;
	import main.events.PanelEvent;

	public class DefinePanel extends TabPanel
	{
		public function DefinePanel()
		{
			
			EventMgr.ist.addEventListener(PanelEvent.PANEL,onPanel);
		}
		
		public function get panelName():String {
			return "";
		}
		
		private function onPanel(e:PanelEvent):void {
			if(e.panelName != this.panelName) return;
			this.receiveMessage(e);
		}
		
		public function receiveMessage(e:PanelEvent):void {
			
		}
	}
}