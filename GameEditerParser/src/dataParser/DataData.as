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
		
		public function DataData()
		{
		}
		
		
		
		public function decode():Boolean
		{
			try {
				var content:String = FileUtil.openAsString(ToolData.getInstance().project.getResURL(this.url));
				var cfg:Object = JSON.parse(content);
				this._name = cfg.name;
				this._desc = cfg.desc;
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
					this._members.push(
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