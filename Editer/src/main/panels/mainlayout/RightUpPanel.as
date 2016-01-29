package main.panels.mainlayout
{
	import main.panels.components.ClipItem;
	import main.panels.contenView.ContentView;

	public class RightUpPanel extends ClipItem
	{
		public function RightUpPanel()
		{
			this.percentHeight = 100;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			var contentView:ContentView = new ContentView();
			contentView.percentWidth = contentView.percentHeight = 100;
			this.addElement(contentView);
		}
	}
}