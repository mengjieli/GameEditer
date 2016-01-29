package main.panels.mainlayout
{
	import main.panels.components.ClipTableItem;
	import main.panels.directionView.DirectionView;

	public class LeftPanel extends ClipTableItem
	{
		public function LeftPanel()
		{
			this.width = 300;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			this.addPanel(new DirectionView());
		}
	}
}