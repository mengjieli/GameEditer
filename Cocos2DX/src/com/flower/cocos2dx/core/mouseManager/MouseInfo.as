package com.flower.cocos2dx.core.mouseManager
{
	import com.flower.cocos2dx.display.DisplayObject;

	public class MouseInfo
	{
		public var id:int;
		
		public var mutiply:Boolean;
		
		public var startX:int;
		public var startY:int;
		
		public var moveX:int = -100000;
		public var moveY:int = -100000;
		
		public var target:DisplayObject;
		
		public function MouseInfo()
		{
		}
		
		public function initBuffer():void
		{
			moveX = -100000;
			moveY = -100000;
		}
	}
}