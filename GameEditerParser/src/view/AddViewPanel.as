package view
{
	import egret.events.CloseEvent;
	import egret.ui.components.Alert;
	
	import extend.ui.LabelAndInput;
	
	import main.data.directionData.DirectionDataBase;

	public class AddViewPanel extends Alert
	{
		private var url:String;
		private var nameTxt:LabelAndInput;
		private var descNameTxt:LabelAndInput;
		private var back:Function;
		private var dir:DirectionDataBase;
		
		public function AddViewPanel(d:DirectionDataBase,back:Function)
		{
			this.title = "添加视图";
			this.url = d.url;
			this.back = back;
			this.dir = d;
			this.width = 300;
			this.height = 200;
			this.firstButtonLabel = "确定";
			this.secondButtonLabel = "取消";
			this.closeHandler = onClosePanel;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			nameTxt = new LabelAndInput("名称");
			nameTxt.horizontalCenter = 0;
			nameTxt.verticalCenter = -50;
			this.addElement(nameTxt);
			
			descNameTxt = new LabelAndInput("描述");
			descNameTxt.horizontalCenter = 0;
			descNameTxt.verticalCenter = -15;
			this.addElement(descNameTxt);
		}
		
		private function onClosePanel(event:CloseEvent):void {
			if(event.detail != Alert.FIRST_BUTTON) return;
			back(dir,this.nameTxt.text,this.descNameTxt.text);
		}
	}
}