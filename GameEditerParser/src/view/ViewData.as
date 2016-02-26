package view
{
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.events.EventMgr;
	import main.events.PanelEvent;

	public class ViewData extends DirectionDataBase
	{
		/**
		 * 尺寸方案
		 * 0. 固定尺寸
		 * 1. 固定尺寸全屏缩放
		 * 2. 全屏尺寸
		 * 3. 全屏固定宽
		 * 4. 全屏固定高
		 */
		private var _sizeType:int = 0;
		private var _width:int = 0;
		private var _height:int = 0;
		
		public function ViewData()
		{
			this.fileIcon = "assets/directionView/fileIcon/exml.png";
		}
		
		public function set sizeType(val:int):void {
			this._sizeType = val;
		}
		
		public function get sizeType():int {
			return this._sizeType;
		}
		
		public function set width(val:int):void {
			this._width = val;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function set height(val:int):void {
			_height = val;
		}
		
		public function get height():int {
			return _height;
		}
		
		public function decode():Boolean
		{
			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				if(cfg.parser != "View") {
					var ev:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，不匹配的解析器名称 \"" + cfg.parser + "\""});
					EventMgr.ist.dispatchEvent(ev);
					return false;
				}
				this.desc = cfg.desc;
				var d:Object = cfg.data;
			} catch(err:Error) {
				var e:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 View 出错] " + this.url + "，" + err.message});
				EventMgr.ist.dispatchEvent(e);
				return false;
			}
			
			return true;
		}
		
		override public function save():void {
			var cfg:Object = {
				"parser":"View",
				"version":"1.0",
				"desc":this.desc,
					"data":{
					}
			}
			var content:String = JSON.stringify(cfg);
			FileUtil.save(ToolData.getInstance().project.getResURL(this.url),content);
		}
	}
}