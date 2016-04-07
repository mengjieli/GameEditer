package flower.debug
{
	import flower.Engine;
	import flower.debug.toolBar.DebugToolBar;
	import flower.display.Stage;
	import flower.events.Event;
	
	public class DebugStage extends Stage
	{
		private var initFlag:Boolean;
		private var toolBar:DebugToolBar;
		
		public function DebugStage()
		{
		}
		
		public function show():void {
			if(!this.initFlag) {
				if(Engine.getInstance().isReady) {
					this.init();
				} else {
					Engine.getInstance().addListener(Event.READY,init,this);
				}
			}
			this.visible = true;
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		private function init(e:Event=null):void {
			if(!this.visible) {
				return;
			}
			this.initFlag = true;
			toolBar = new DebugToolBar();
			Engine.getInstance().addChild(toolBar);
		}
	}
}