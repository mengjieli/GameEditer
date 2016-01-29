package main.panels.components
{
	import flash.events.Event;
	
	import egret.components.Group;
	import egret.components.Label;
	
	import main.data.ToolData;

	/**
	 *状态栏 
	 * @author Grayness
	 */	
	public class StatusBar extends Group
	{
		public function StatusBar()
		{
		}
		private var loopbar:ProgressLoopBar;
		private var displayLabel:Label;
		private var tipLabel:Label;
		protected override function createChildren():void
		{
			super.createChildren();
			
			displayLabel = new Label();
			displayLabel.left = 5;
			displayLabel.verticalCenter = 0;
			this.addElement(displayLabel);
			loopbar = new ProgressLoopBar();
			loopbar.width=300;
			loopbar.height=20;
			loopbar.right=5;
			loopbar.verticalCenter=0;
			loopbar.visible=false;
			this.addElement(loopbar);
			
			tipLabel = new Label();
			tipLabel.textColor = 0xaaaaaa;
			tipLabel.right = 10;
			tipLabel.verticalCenter = 0;
			this.addElement(tipLabel);
			
			ToolData.getInstance().mobile.addEventListener(Event.CHANGE,onStateChange);
			this.onStateChange();
		}
		
		private function onStateChange(e:Event=null):void {
			if(ToolData.getInstance().mobile.connected) {
				tipLabel.text = "已链接 " + ToolData.getInstance().mobile.name;
			} else {
				tipLabel.text = "未链接游戏客户端";
			}
		}
		
		public function showMessage(str:String,showloopbar:Boolean=false):void
		{
			if(str==null)
			{
				displayLabel.visible=loopbar.visible=false;
				loopbar.stop();
			}
			else
			{
				displayLabel.visible=true;
				displayLabel.text=str;
				if(showloopbar)
				{
					loopbar.visible=true;
					loopbar.play();
				}
				else
				{
					loopbar.visible=false;
					loopbar.stop();
				}
			}
		}
	}
}