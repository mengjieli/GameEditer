package flower.core
{
	import flower.utils.CallLater;

	public class TimeLine
	{
		public static var currentTime:Number = 0;
		public static var lastTimeGap:Number = 0;
		
		public static function $run(gap:int):void {
			lastTimeGap = gap;
			currentTime += gap;
			
			CallLater.$run();
		}
	}
}