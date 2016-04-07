package dataParser
{
	import egret.utils.FileUtil;
	
	import main.data.ToolData;
	import main.data.directionData.DirectionDataBase;
	import main.events.EventMgr;
	import main.events.PanelEvent;

	public class DataData extends DirectionDataBase
	{
		private var _name:String;
		private var _desc:String;
		private var _members:Vector.<DataItem> = new Vector.<DataItem>();
		private var _root:Boolean = false;
		
		public function DataData()
		{
			this.dataType = "Data";
		}
		
		public function get dataName():String {
			return _name;
		}
		
		public function set dataName(val:String):void {
			_name = val;
		}
		
		public function get root():Boolean {
			return _root;
		}
		
		public function get dataDesc():String {
			return _desc;
		}
		
		public function set dataDesc(val:String):void {
			_desc = val;
		}
		
		public function get members():Vector.<DataItem> {
			return _members;
		}
		
		public function decode():Boolean
		{
			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				this._name = cfg.name;
				this._desc = cfg.desc;
				this._root = cfg.root==null?false:cfg.root;
				this.desc = this._desc;
				_members = new Vector.<DataItem>();
				var mebs:Object = cfg.members;
				for(var key:String in mebs) {
					var item:DataItem = new DataItem();
					item.name = key;
					item.desc = mebs[key].desc;
					item.type = mebs[key].type;
					if(mebs[key].typeValue) {
						item.typeValue = mebs[key].typeValue;
					}
					this._members.push(item);
				}
			} catch(err:Error) {
				var e:PanelEvent = new PanelEvent("Log","add",{"text":"[解析 Data 出错] " + this.url + "，" + err.message});
				EventMgr.ist.dispatchEvent(e);
				return false;
			}
			
			return true;
		}
	}
}