package main.data.parsers.command
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class EventEXE extends Execute
	{
		public var dispatcher:EventDispatcher;
		public var event:Event;
		
		public function EventEXE(dispatcher:EventDispatcher,event:Event)
		{
			this.dispatcher = dispatcher;
			this.event = event;
		}
		
		override public function excute():void {
			this.dispatcher.dispatchEvent(event);
		}
	}
}