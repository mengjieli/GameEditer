package main.panels.netWaitPanel
{
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.ProgressBar;
	import egret.managers.PopUpManager;

	public class NetWaitingPanel extends Group
	{
		public function NetWaitingPanel()
		{
			
		}
		
		private var label:Label;
		private var labelText:String = "";
		
		private var label2:Label;
		private var labelText2:String = "";
		
		private var progressBar:ProgressBar;
		private var progressNumber:int = -1;
		
		protected override function createChildren():void
		{
			super.createChildren();
			label = new Label();
			label.text = labelText;
			this.addElement(label);
			label.verticalCenter = -30;
			label.horizontalCenter = 0;
			
			this.addElement(progressBar = new ProgressBar());
			progressBar.minimum = 0;
			progressBar.maximum = 100;
			progressBar.width = 200;
			progressBar.height = 25;
			progressBar.verticalCenter = 0;
			progressBar.horizontalCenter = 0;
			progressBar.visible = progressNumber>=0?true:false;
			if(progressBar.visible) {
				progressBar.value = progressNumber;
			}
			
			
			label2 = new Label();
			label2.text = labelText2;
			label2.textColor = 0xaaaaaa;
			this.addElement(label2);
			label2.verticalCenter = 30;
			label2.horizontalCenter = 0;
		}
		
		public function set tip(val:String):void {
			labelText = val;
			if(label) {
				label.text = val;
			}
		}
		
		public function set tip2(val:String):void {
			labelText2 = val;
			if(label2) {
				label2.text = val;
			}
		}
		
		public function set progress(val:int):void {
			progressNumber = val;
			if(val >= 0) {
				progressBar.visible = true;
				progressBar.value = val;
			}
		}
		
		private static var ist:NetWaitingPanel;
		
		public static function show(tip:String="loading ...",tip2:String="",progress:int=-1):void {
			if(!ist) {
				ist = new NetWaitingPanel();
			}
			ist.tip = tip;
			ist.tip2 = tip2;
			ist.progress = progress;
			if(!ist.parent) {
				PopUpManager.addPopUp(ist,true);
			}
		}
		
		public static function hide():void {
			if(ist && ist.parent) {
				PopUpManager.removePopUp(ist);
			}
		}
	}
}