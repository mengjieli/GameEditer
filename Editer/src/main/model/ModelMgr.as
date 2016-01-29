package main.model
{
	import flash.events.EventDispatcher;
	
	import main.model.errorTipModel.ErrorTipModel;
	import main.model.logModel.GameLogModel;
	import main.model.loginModel.LoginNotifyModel;
	import main.model.projectModel.ProjectModel;
	

	public class ModelMgr extends EventDispatcher
	{
		
		public function ModelMgr()
		{
		}
		
		public function init():void {
			new MenuModel();
			new ErrorTipModel();
			new LoginNotifyModel();
			new GameLogModel();
			new ProjectModel();
		}
		
		public function excute(type:String,value:*):void {
			this.dispatchEvent(new ModelEvent(type,value));
		}
		
		private static var ist:ModelMgr;
		public static function getInstance():ModelMgr
		{
			if(ist == null) {
				ist = new ModelMgr();
			}
			return ist;
		}
	}
}