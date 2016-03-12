package com.flower.cocos2dx.event
{
	import com.flower.cocos2dx.display.DisplayObject;

	public class MouseEvent extends Event
	{
		public static const MOUSE_DOWN:String = "mouse_down";
		public static const MOUSE_MOVE:String = "mouse_move";
		public static const MOUSE_OVER:String = "mouse_over";
		public static const MOUSE_OUT:String = "mouse_out";
		public static const CLICK:String = "click";
		
		public var currentTarget:DisplayObject;
		
		public var stageX:int;
		public var stageY:int;
		
		public var mouseX:int;
		public var mouseY:int;
		
		public function MouseEvent(type:String):void
		{
			super(type);
		}
	}
}