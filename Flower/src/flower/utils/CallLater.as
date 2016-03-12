package flower.utils
{
	public class CallLater
	{
		private var _func:Function;
		private var _thisObj:*;
		private var _data:Array;
		
		public function CallLater(func:Function,thisObj:*,args:Array=null)
		{
			_func = func;
			_thisObj = thisObj;
			_data = args||[];
			_next.push(this);
		}
		
		private function $call():void {
			_func.apply(_thisObj,_data);
			_func = null;
			_thisObj = null;
			_data = null;
		}
		
		private static var _next:Vector.<CallLater> = new Vector.<CallLater>();
		private static var _list:Vector.<CallLater> = new Vector.<CallLater>();
		
		public static function $run():void {
			_list = _next;
			_next = new Vector.<CallLater>();
			var list:Vector.<CallLater> = _list;
			while(list.length) {
				list.pop().$call();
			}
		}
	}
}