package flower.net
{
	public class Remote
	{
		private static var id:Number = 1;
		
		private var _id:Number;
		private var back:Function;
		private var thisObj:*;
		
		public var data:*;
		
		public function Remote(func:Function,thisObj:*)
		{
			this.back = func;
			this.thisObj = thisObj;
			this._id = Remote.id++;
//			ToolData.getInstance().server.registerRemote(this);
		}
		
		public function set backFunction(val:Function):void {
			this.back = val;
		}
		
		public function get id():Number {
			return this._id;
		}
		
		public function doNext(cmd:Number,msg:*):void {
			this.back(cmd,msg,this);
		}
		
		public function dispose():void {
//			ToolData.getInstance().server.removeRemote(this);
		}
	}
}

