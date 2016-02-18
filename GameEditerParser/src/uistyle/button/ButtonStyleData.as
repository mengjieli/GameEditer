package uistyle.button
{
	import flash.events.Event;
	
	import egret.utils.FileUtil;
	
	import extend.ui.ImageLoader;
	
	import main.data.DragType;
	import main.data.ToolData;
	import main.events.EventMgr;
	import main.events.PanelEvent;
	
	import uistyle.StyleDataBase;
	import uistyle.StyleImageData;

	public class ButtonStyleData extends StyleDataBase
	{
		private var _up:StyleImageData;
		private var _down:StyleImageData;
		private var _disabled:StyleImageData;
		
		public function ButtonStyleData()
		{
			_up = new StyleImageData("弹起状态");
			_down = new StyleImageData("按下状态");
			_disabled = new StyleImageData("禁用状态");
			_up.addEventListener(Event.CHANGE,onChangeURL);
			_down.addEventListener(Event.CHANGE,onChangeURL);
			_disabled.addEventListener(Event.CHANGE,onChangeURL);
			this.dragType = "buttonStyle";
		}
		
		override public function get dragShow():ImageLoader {
			if(_up.url) {
				return new ImageLoader(ToolData.getInstance().project.getResURL(_up.url));;
			}
			return null;
		}
		
		public function get up():StyleImageData {
			return _up;
		}
		
		public function get down():StyleImageData {
			return _down;
		}
		
		public function get disabled():StyleImageData {
			return _disabled;
		}
		
		private function onChangeURL(e:Event):void {
			this.save();
		}
		
		public function decode():Boolean
		{
			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				if(cfg.parser != "ButtonStyle") {
					var ev:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 ButtonStyle 出错] " + this.url + "，不匹配的解析器名称 \"" + cfg.parser + "\""});
					EventMgr.ist.dispatchEvent(ev);
					return false;
				}
				this.desc = cfg.desc;
				var d:Object = cfg.data;
				this._up.changeURL(d.up);
				this._down.changeURL(d.down);
				this._disabled.changeURL(d.disabled);
			} catch(err:Error) {
				var e:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 ButtonStyle 出错] " + this.url + "，" + err.message});
				EventMgr.ist.dispatchEvent(e);
				return false;
			}
			
			return true;
		}
		
		override public function save():void {
			var cfg:Object = {
				"parser":"ButtonStyle",
				"version":"1.0",
				"desc":this.desc,
				"data":{
					"up":up.url,
					"down":down.url,
					"disabled":disabled.url
				}
			}
			var content:String = JSON.stringify(cfg);
			FileUtil.save(ToolData.getInstance().project.getResURL(this.url),content);
		}
	}
}