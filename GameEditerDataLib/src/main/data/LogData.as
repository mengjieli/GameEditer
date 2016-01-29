package main.data
{
	import flash.events.EventDispatcher;
	
	import main.data.events.LogEvent;

	public class LogData extends EventDispatcher
	{
		public static var MAX:uint = 500;
		
		public var logs:Vector.<String> = new Vector.<String>();
		public var colors:Vector.<uint> = new Vector.<uint>();
		
		public function LogData()
		{
		}
		
		public function addLog(color:uint,content:String):void {
			logs.push(content);
			colors.push(color);
			this.dispatchEvent(new LogEvent(LogEvent.ADD,content,color));
		}
		
		public function shiftLog():void {
			this.dispatchEvent(new LogEvent(LogEvent.SHIFT,logs.shift(),colors.shift()));
		}
		
		public function clearAll():void {
			logs = new Vector.<String>();
			colors = new Vector.<uint>();
			this.dispatchEvent(new LogEvent(LogEvent.CLEAR));
		}
	}
}