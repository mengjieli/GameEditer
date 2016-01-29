package main.model
{	
	import main.menu.MenuID;
	import main.panels.mobileView.ConnectMobilePanel;
	import main.panels.newProjectPanel.NewProjectPanel;

	public class MenuModel
	{
		public function MenuModel()
		{
			ModelMgr.getInstance().addEventListener(ModelEvent.MENU,onClickMenu);
		}
		
		private function onClickMenu(e:ModelEvent):void {
			switch(e.value) {
				case MenuID.NEW:
					(new NewProjectPanel()).open(false);
					break;
				case MenuID.CONNECT_MOBILE:
					(new ConnectMobilePanel()).open(false);
					break;
			}
		}
	}
}