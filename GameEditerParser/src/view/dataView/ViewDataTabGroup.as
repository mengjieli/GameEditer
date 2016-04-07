package view.dataView
{
	import egret.ui.components.TabGroup;
	
	import view.ViewData;

	public class ViewDataTabGroup extends TabGroup
	{
		private var dataView:ViewDataPanel;
		
		public function ViewDataTabGroup()
		{
			this.addElement(dataView = new ViewDataPanel());
		}
		
		public function showView(d:ViewData):void {
			dataView.showView(d);
		}
	}
}