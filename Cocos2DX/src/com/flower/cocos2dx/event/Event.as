package com.flower.cocos2dx.event
{
	public class Event
	{
		public static const CHANGE:String = "change";
		public static const INIT_COMPLETE:String = "init_complete";
		public static const ADD:String = "add";
		public static const REMOVE:String = "remove";
		public static const DISPOSE:String = "dispose";
		
		public var type:String;
		
		//第一个抛出事件的对象
		public var target:EventDispatcher;
		
		public function Event(type:String):void
		{
			this.type = type;
		}
	}
}