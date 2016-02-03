package logPanel
{
	import egret.collections.ArrayCollection;
	import egret.components.List;
	
	import main.events.PanelEvent;
	import main.ui.DefinePanel;

	public class LogPanel extends DefinePanel
	{
		public function LogPanel()
		{
			this.title = "日志";
			data = new ArrayCollection();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			list = new List();
			list.percentWidth = 100;
			list.percentHeight = 100;
			list.dataProvider = data;
			this.addElement(list);
		}
		
		private var list:List;
		private var data:ArrayCollection;
		
		override public function get panelName():String {
			return "Log";
		}
		
		override public function receiveMessage(e:PanelEvent):void {
			switch(e.subType) {
				case "add":
					var content:String = e.data.text;
					data.addItem({"label":content});
					break;
			}
		}
	}
}