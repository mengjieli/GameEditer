package view
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import egret.utils.FileUtil;
	
	import extend.ui.ExtendGlobal;
	
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
		private var _fileContent:Object = {};
		
		public function ViewData()
		{
			this.fileIcon = "assets/directionView/fileIcon/exml.png";
			this._panel = new RootPanelData();
			this._panel.addEventListener(ComponentAttributeEvent.CHILD_ATTRIBUTE_CHANGE,onChildAttributeChange);
			ExtendGlobal.stage.addEventListener(Event.ENTER_FRAME,onFrame);
		}
		
		private function onFrame(e:Event):void {
			this.panel.run();
		}
		
		public function get panel():RootPanelData {
			return _panel;
		}
		
		private var lastSaveTime:Number = 0;
		private var needSave:Boolean = false;
		public function onChildAttributeChange(e:ComponentAttributeEvent=null):void {
			if(_inDecode == true) {
				return;
			}
			if(e != null) {
				needSave = true;
			} else {
				if(!needSave) {
					return;
				}
			}
			needSave = false;
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
			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				if(cfg.parser != "View") {
					var ev:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，不匹配的解析器名称 \"" + cfg.parser + "\""});
					EventMgr.ist.dispatchEvent(ev);
					return false;
				}
				_fileContent = cfg;
				this.desc = cfg.desc;
				var d:Object = cfg.data;
				this._panel.parser(d);
			} catch(err:Error) {
				var e:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，" + err.message});
				EventMgr.ist.dispatchEvent(e);
				_fileContent = {};
				return false;
			}
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
//			if(equail(cfg,_fileContent) == true) {
//				return;
//			}
//			_fileContent = cfg;
			var content:String = JSON.stringify(cfg);
			FileUtil.save(ToolData.getInstance().project.getResURL(this.url),content);
		}
		
		public function equail(obj1:*,obj2:*):Boolean {
			if(obj1 is Number) {
				if(!obj2 is Number) {
					return false;
				}
				if(obj1 != obj2) {
					return false;
				}
			}
			if(obj1 is String) {
				if(!obj2 is String) {
					return false;
				}
				if(obj1 != obj2) {
					return false;
				}
			}
			if(obj1 is Array) {
				if(!obj2 is Array) {
					return false;
				}
				if(obj1.length != obj2.length) {
					return false;
				}
				for(var i:int = 0; i < obj1.length; i++) {
					if(equail(obj1[i],obj2[i]) == false) {
						equail(obj1[i],obj2[i]);
						return false;
					}
				}
				return true;
			}
			for(var key:* in obj1) {
				if(!equail(obj1[key],obj2[key])) {
					return false;
				}
			}
			for(key in obj2) {
				if(!equail(obj1[key],obj2[key])) {
					return false;
				}
			}
			return true;
		}
	}
}