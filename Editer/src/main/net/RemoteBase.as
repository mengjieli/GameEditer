package main.net
{
	import main.data.ToolData;

	public class RemoteBase
	{
		private static var id:Number = 1;
		
		private var _id:Number;
		private var back:Function;
		
		public var data:*;
		
		public function RemoteBase(back:Function)
		{
			this.back = back;
			this._id = RemoteBase.id++;
			ToolData.getInstance().server.registerRemote(this);
		}
		
		public function set backFunction(val:Function):void {
			this.back = val;
		}
		
		public function get id():Number {
			return this._id;
		}
		
		public function doNext(cmd:Number,msg:MyByteArray):void {
			this.back(cmd,msg,this);
		}
		
		public function dispose():void {
			ToolData.getInstance().server.removeRemote(this);
		}
	}
}