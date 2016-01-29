package main.panels.newProjectPanel
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import egret.components.Button;
	import egret.components.Label;
	import egret.events.CloseEvent;
	import egret.ui.components.Alert;
	import egret.ui.components.TextInput;
	import egret.utils.FileUtil;
	
	import main.data.ToolData;

	public class NewProjectPanel extends Alert
	{
		public function NewProjectPanel()
		{
			this.title = "新建游戏项目";
			this.width = 500;
			this.height = 300;
			this.firstButtonLabel = "确定";
			this.secondButtonLabel = "取消";
			this.closeHandler = onClose;
		}
		
		private var nameTxt:TextInput;
		private var projectUrl:TextInput;
		private var srcUrl:TextInput;
		private var assetsUrl:TextInput;
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			var gapY:int = 30;
			
			var label:Label = new Label();
			label.text = "名称";
			this.addElement(label);
			label.x = 20;
			label.y = 20;
			
			nameTxt = new TextInput();
			nameTxt.width = 300;
			nameTxt.height = 20;
			nameTxt.x = 80;
			nameTxt.y = 20;
			this.addElement(nameTxt);
			
			label = new Label();
			label.text = "项目路径";
			this.addElement(label);
			label.x = 20;
			label.y = 20 + gapY*1;
			
			projectUrl = new TextInput();
			projectUrl.width = 300;
			projectUrl.height = 20;
			projectUrl.x = 80;
			projectUrl.y = 20 + gapY*1;
			this.addElement(projectUrl);
			
			var btn:Button = new Button();
			btn.label = "浏览";
			btn.x = 400;
			btn.y = 20 + gapY*1;
			this.addElement(btn);
			btn.addEventListener(MouseEvent.CLICK,onBroswerProjectURL);
			
			
			label = new Label();
			label.text = "代码路径";
			this.addElement(label);
			label.x = 20;
			label.y = 20 + gapY*2;
			
			srcUrl = new TextInput();
			srcUrl.width = 300;
			srcUrl.height = 20;
			srcUrl.x = 80;
			srcUrl.y = 20 + gapY*2;
			srcUrl.text = "src";
			srcUrl.restrict = "a-z A-Z";
			this.addElement(srcUrl);
			
			
			label = new Label();
			label.text = "资源路径";
			this.addElement(label);
			label.x = 20;
			label.y = 20 + gapY*3;
			
			assetsUrl = new TextInput();
			assetsUrl.width = 300;
			assetsUrl.height = 20;
			assetsUrl.x = 80;
			assetsUrl.y = 20 + gapY*3;
			assetsUrl.text = "res";
			assetsUrl.restrict = "a-z A-Z";
			this.addElement(assetsUrl);
		}
		
		private function onBroswerProjectURL(e:MouseEvent):void {
			FileUtil.browseForOpen(onSelectProjectURL,3);
		}
		
		private function onSelectProjectURL(file:File):void {
			this.projectUrl.text = file.url;
		}
		
		private var closeFlag:Boolean = false;
		private function onClose(e:CloseEvent):void {
			if(e.detail == 1) {
				if(nameTxt.text == "") {
					Alert.show("名称不能为空","提示",null,null,"确定");
					return;
				}
				try {
					var file:File = new File(this.projectUrl.text);
					if(file.exists == false) {
						Alert.show("项目目录不存在，请重新选择","提示",null,null,"确定");
						return;
					}
				} catch(e) {
					Alert.show("项目目录不存在，请重新选择","提示",null,null,"确定");
					return;
				}
				ToolData.getInstance().createGameProject(nameTxt.text,projectUrl.text,assetsUrl.text,srcUrl.text);
			}
			closeFlag = true;
		}
		
		override public function close():void{
			if(closeFlag) {
				super.close();
			}
		}
	}
}