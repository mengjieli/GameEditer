package flower
{
	import flower.core.Time;
	import flower.data.DataManager;
	import flower.debug.DebugInfo;
	import flower.debug.DebugStage;
	import flower.display.DisplayObject;
	import flower.display.Stage;
	import flower.events.Event;
	import flower.net.URLLoader;
	import flower.res.Res;
	import flower.res.ResTexture;
	import flower.texture.Texture2D;
	import flower.ui.Image;
	import flower.utils.JSON;

	public class Engine extends Stage
	{
		private var debugStage:DebugStage;
		private var ready:Boolean = false;
		
		public function Engine()
		{
			super();
			if(ist) {
				return;
			}
			ist = this;
			debugStage = new DebugStage();
			System.start(this._show,debugStage.$nativeShow,this);
			global = System.global;
			flower.utils.JSON.parser = System.JSON_parser;
			flower.utils.JSON.stringify = System.JSON_stringify;
			System.runTimeLine(Time.$run);
			this._width = System.width;
			this._height = System.height;
			
			var res:ResTexture = new ResTexture();
			res.local = Res.local;
			res.localURL = Res.localURL;
			res.serverURL = Res.serverURL;
			res.url = "res/blank.png";
			var loader:URLLoader = new URLLoader(res);
			loader.load();
			loader.addListener(Event.COMPLETE,onLoadBlankComplete,this);
		}
		
		private function onLoadBlankComplete(e:Event):void {
			Texture2D.blank = e.data;
			var image:Image = new Image(e.data);
			ready = true;
			this.dispatchWidth(Event.READY);
		}
		
		public function showDebugTool():void {
			debugStage.show();
		}
		
		public function hideDebugTool():void {
			debugStage.hide();
		}
		
		override public function $onFrameEnd():void {
			super.$onFrameEnd();
			this.debugStage.$onFrameEnd();
		}
		
		override public function getMouseTarget(touchX:int,touchY:int,mutiply:Boolean):DisplayObject {
			var target:DisplayObject = debugStage.getMouseTarget(touchX,touchY,mutiply);
			if(target == debugStage) {
				target = super.getMouseTarget(touchX,touchY,mutiply);
			}
			return target;
		}
		
		override protected function _setX(val:Number):void {
			DebugInfo.debug("|类Engine| set x 不能设置其位置",DebugInfo.ERROR);
			return;
		}
		
		override protected function _setY(val:Number):void {
			DebugInfo.debug("|类Engine| set y 不能设置其位置",DebugInfo.ERROR);
			return;
		}
		
		public function get isReady():Boolean {
			return ready;
		}
		
		public function clear():void {
			while(this.numChildren) {
				this.getChildAt(0).dispose();
			}
			URLLoader.clear();
			DataManager.ist.clear();
		}
		
		public static var DEBUG:Boolean = true;
		public static var TIP:Boolean = true;
		
		public static var global:*;
		
		private static var ist:Engine;
		public static function getInstance():Engine {
			return ist;
		}
	}
}