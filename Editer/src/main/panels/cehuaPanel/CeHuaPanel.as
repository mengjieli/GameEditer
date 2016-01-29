package main.panels.cehuaPanel
{
	import egret.ui.components.TabGroup;
	
	import main.panels.mobileView.MobileLoadJS;
	import main.panels.mobileView.MobileLogPanel;

	public class CeHuaPanel extends TabGroup
	{
		public function CeHuaPanel()
		{
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			this.addElement(new MobileLogPanel());
			this.addElement(new CeHuaGM());
			this.addElement(new CehuaTool());
			this.addElement(new MobileLoadJS());
		}
	}
}