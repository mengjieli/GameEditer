package main.panels.cehuaPanel
{
	import egret.components.Label;
	import egret.ui.components.TabPanel;
	
	import main.panels.mobileView.ConnectMobileBase;

	public class CeHuaGM extends ConnectMobileBase
	{
		public function CeHuaGM()
		{
			this.title = "GM 命令";
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			var label:Label = new Label();
			label.text = "111111";
			this.addElement(label);
		}
	}
}