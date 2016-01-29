package main.panels.components
{
	import egret.ui.components.TabGroup;
	import egret.ui.components.TabPanel;

	public class ClipTableItem extends ClipItem
	{
		private var tabGroup:TabGroup;
		
		public function ClipTableItem()
		{
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			tabGroup = new TabGroup();
			tabGroup.percentWidth = 100;
			tabGroup.percentHeight = 100;
			this.addElement(tabGroup);
		}
		
		public function addPanel(panel:TabPanel):void {
			this.tabGroup.addElement(panel);
		}
		
		public function removePanel(panel:TabPanel):void {
			this.tabGroup.removeElement(panel);
		}
	}
}