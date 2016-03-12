package view
{
	import flash.utils.setTimeout;
	
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.events.EventMgr;
	import main.events.PanelEvent;
	
	import view.component.data.RootPanelData;
	import view.events.ComponentAttributeEvent;

	public class ViewData extends DirectionDataBase
	{
//		private var _width:int = 0;
//		private var _height:int = 0;
		private var _panel:RootPanelData;
		
		public function ViewData()
		{
			this.fileIcon = "assets/directionView/fileIcon/exml.png";
			this._panel = new RootPanelData();
			this._panel.addEventListener(ComponentAttributeEvent.CHILD_ATTRIBUTE_CHANGE,onChildAttributeChange);
			this._panel.editerFlag = false;
		}
		
		public function get panel():RootPanelData {
			return _panel;
		}
		
		private var lastSaveTime:Number = 0;
		public function onChildAttributeChange(e:ComponentAttributeEvent=null):void {
			var time:Number = (new Date()).time;
			if(time - lastSaveTime > 2000) {
				lastSaveTime = time;
				this.save();
			} else {
				flash.utils.setTimeout(this.onChildAttributeChange,2500 - (time - lastSaveTime));
			}
		}
		
		
//		public function set width(val:int):void {
//			this._width = val;
//		}
//		
//		public function get width():int {
//			return _width;
//		}
//		
//		public function set height(val:int):void {
//			_height = val;
//		}
//		
//		public function get height():int {
//			return _height;
//		}
		
		private var _inDecode:Boolean = false;
		public function decode():Boolean
		{
			_inDecode = true;
//			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				if(cfg.parser != "View") {
					var ev:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，不匹配的解析器名称 \"" + cfg.parser + "\""});
					EventMgr.ist.dispatchEvent(ev);
					return false;
				}
				this.desc = cfg.desc;
				var d:Object = cfg.data;
				this._panel.parser(d);
//			} catch(err:Error) {
//				var e:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，" + err.message});
//				EventMgr.ist.dispatchEvent(e);
//				return false;
//			}
			_inDecode = false;
			return true;
		}
		
		override public function save():void {
			if(_inDecode) return;
			var cfg:Object = {
				"parser":"View",
				"version":"1.0",
				"desc":this.desc,
				"data":_panel.encode()
			}
			var content:String = JSON.stringify(cfg);
			FileUtil.save(ToolData.getInstance().project.getResURL(this.url),content);
		}
	}
}