package flower.debug
{
	import flower.core.Setting;

	public class DebugInfo
	{
		public static var NONE:int = 0;
		public static var WARN:int = 1;
		public static var ERROR:int = 2;
		public static var TIP:int = 3;
		
		public static function debug(str:String,type:int=0):void
		{
			if(type == 1 && Setting.warnInfo == false) return;
			if(type == 2 && Setting.errorInfo == false) return;
			if(type == 3 && Setting.tipInfo == false) return;
			if(type == 1) str = "[警告]  " + str;
			if(type == 2) str = "[错误] " + str;
			if(type == 3) str = "[提示] " + str;
			System.log(str);
			if(type == 2)
			{
				var a;
				a.abc + 1;
//				ErrorDispatch.dispatch(str);
			}
		}
		
		public static function debug2(type:int,...args):void
		{
			var str:String = "";
			for(var i:int = 0; i < args.length; i++)
			{
				str += args[i] + "\t";
			}
			debug(str,type);
		}
	}
}