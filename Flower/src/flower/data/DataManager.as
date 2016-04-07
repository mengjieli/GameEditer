package flower.data
{
	import flower.Engine;
	import flower.data.member.ArrayValue;
	import flower.data.member.BooleanValue;
	import flower.data.member.IntValue;
	import flower.data.member.StringValue;
	import flower.data.member.UIntValue;
	import flower.debug.DebugInfo;

	dynamic public class DataManager
	{
		private var _defines:Object = {};
		private var _root:Object = {};
		
		public function DataManager()
		{
			if(ist) {
				return;
			}
		}
		
		public function addRootData(name:String,className:String):void {
			this[name] = createData(className);
			_root[name] = this[name];
		}
		
		public function addDataDeinf(config:Object):* {
			_defines[config.name] = config;
		}
		
		public function createData(className:String):Object {
			var config:Object = this._defines[className];
			if (Engine.DEBUG && !config) {
				DebugInfo.debug("没有定义的数据类型 :" + className,DebugInfo.ERROR);
				return null;
			}
			var obj:Object = {};
			if(config.members) {
				var members:Object = config.members;
				for(var key:String in members) {
					var member:Object = members[key];
					if(member.type == "int") {
						obj[key] = new IntValue(member.init);
					}
					else if(member.type == "uint") {
						obj[key] = new UIntValue(member.init);
					}
					else if(member.type == "string") {
						obj[key] = new StringValue(member.init);
					}
					else if(member.type == "boolean") {
						obj[key] = new BooleanValue(member.init);
					}
					else if(member.type == "array") {
						obj[key] = new ArrayValue(member.init);
					}
					else if(member.type == "*") {
						obj[key] = member.init;
					}
					else {
						obj[key] = createData(member.type);
					}
				}
			}
			return obj;
		}
		
		public function clear():void {
			for(var key:String in _root) {
				delete _root[key];
				delete this[key];
			}
			_defines = {};
		}
		
		public static var ist:* = new DataManager();
	}
}