package main.panels.mainlayout
{
	import main.panels.components.ClipItem;
	import main.panels.components.ClipItemPanelH;
	import main.panels.contenView.ContentView;

	public class RightPanel extends ClipItem
	{	
		public function RightPanel()
		{
			
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			
			var contentView:ContentView = new ContentView();
			contentView.percentWidth = contentView.percentHeight = 100;
			this.addElement(contentView);
//			var clip:ClipItemPanelH = new ClipItemPanelH();
//			clip.addClipItem(new RightUpPanel(),new RightDownPanel());
//			clip.percentWidth = clip.percentHeight = 100;
//			this.addElement(clip);
		}
	}
}