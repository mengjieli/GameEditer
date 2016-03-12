package com.flower.cocos2dx.event
{
	public class CameraEvent extends Event
	{
		public static const MOVE:String = "move";
		
		public function CameraEvent(type:String):void
		{
			super(type);
		}
	}
}