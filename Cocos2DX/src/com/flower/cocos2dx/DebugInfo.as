package com.flower.cocos2dx
{
	import com.flower.Flower;
	
	import cocos2dx.ErrorDispatch;
	import cocos2dx.cc;

	public class DebugInfo
	{
		public static var NONE:int = 0;
		public static var WARN:int = 1;
		public static var ERROR:int = 2;
		public static var TIP:int = 3;
		
		public static function debug(str:String,type:int=0):void
		{
			if(type == 1 && Flower.warnInfo == false) return;
			if(type == 2 && Flower.errorInfo == false) return;
			if(type == 3 && Flower.tipInfo == false) return;
			if(type == 1) str = "[警告]  " + str;
			if(type == 2) str = "[错误] " + str;
			if(type == 3) str = "[提示] " + str;
			cc.log(str);
			if(type == 2)
			{
				ErrorDispatch.dispatch(str);
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