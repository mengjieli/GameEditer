package flower.core
{
	import flower.Engine;
	import flower.texture.TextureManager;
	import flower.utils.EnterFrame;

	public class Time
	{
		public static var currentTime:Number = 0;
		public static var lastTimeGap:Number = 0;
		
		public static function $run(gap:int):void {
			lastTimeGap = gap;
			currentTime += gap;
			EnterFrame.$update(currentTime,gap);
			Engine.getInstance().$onFrameEnd();
			TextureManager.getInstance().$check();
		}
		
		public static function getTime():Number {
			return Time.getTime();
		}
	}
}