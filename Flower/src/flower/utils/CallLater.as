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
		
		/**
		 * 新加一个 CallLater 函数，但是会检查 func 和 thisObj 是否相同，如果已经有了会替换 args ，但不会生成一个新的 CallLater 函数
		 */
		public static function add(func:Function,thisObj:*,args:Array=null):void {
			for(var i:int = 0,len:int=_next.length; i < len; i++) {
				if(_next[i]._func == func && _next[i]._thisObj == thisObj) {
					_next[i]._data = args||[];
					return;
				}
			}
			new CallLater(func,thisObj,args);
		}
		
		private static var _next:Vector.<CallLater> = new Vector.<CallLater>();
		private static var _list:Vector.<CallLater> = new Vector.<CallLater>();
		
		public static function $run():void {
			if(!_next.length) {
				return;
			}
			_list = _next;
			_next = new Vector.<CallLater>();
			var list:Vector.<CallLater> = _list;
			while(list.length) {
				list.pop().$call();
			}
		}
	}
}