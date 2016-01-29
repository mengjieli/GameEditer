package main.panels.mobileView
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.ui.components.TabPanel;
	
	import main.data.ToolData;

	public class ConnectMobileBase extends TabPanel
	{
		private var bg:Group;
		
		public function ConnectMobileBase()
		{
//			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onDownThis);
			ToolData.getInstance().mobile.addEventListener(Event.CHANGE,onStateChange);
		}
		
		private function onStateChange(e:Event):void {
			this.onDownThis();
		}
		
		protected var tip:String = "还没有链接游戏客户端，无法进行相关操作，点击链接";
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			bg = new Group();
			bg.percentHeight = 100;
			bg.percentWidth = 100;
			var maskBg:UIAsset;
			maskBg = new UIAsset("assets/alpha.png");
			maskBg.percentWidth = 100;
			maskBg.percentHeight = 100;
			bg.addElement(maskBg);
			var label:Label = new Label();
			label.size = 16;
			label.text = tip;
			label.verticalCenter = 0;
			label.horizontalCenter = 0;
			bg.addElement(label);
			bg.addEventListener(MouseEvent.CLICK,onClickBg);
		}
		
		protected function checkConnect():void {
			onDownThis();
		}
		
		private function onDownThis(e:MouseEvent=null):void {
			if(ToolData.getInstance().mobile.connected == true){ 
				if(bg && bg.parent) this.removeElement(bg);
			} else {
				if(bg && !bg.parent) this.addElement(bg);
			}
		}
		
		private function addToStage(e:Event):void {
			if(ToolData.getInstance().mobile.connected == true){ 
				if(bg.parent) bg.parent.removeChild(bg);
			} else {
				if(!bg.parent) this.addElement(bg);
			}
		}
		
		private function onClickBg(e:MouseEvent):void {
			(new ConnectMobilePanel()).open(false);
		}
	}
}