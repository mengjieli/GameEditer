package egret.effects.interpolation
{
	/**
	 * @author xzper
	 */
	public class NumberInterpolator implements IInterpolator
	{
		public function NumberInterpolator()
		{
		}
		
		private static var theInstance:NumberInterpolator;

		public static function getInstance():NumberInterpolator
		{
			if (!theInstance)
				theInstance = new NumberInterpolator();
			return theInstance;
		}
		
		public function interpolate(fraction:Number, startValue:Object, endValue:Object):Object
		{
			if (fraction == 0)
				return startValue;
			else if (fraction == 1)
				return endValue;
			if ((startValue is Number && isNaN(Number(startValue))) ||
				(endValue is Number && isNaN(Number(endValue))))
				throw new Error("cannotCalculateValue");
			return Number(startValue) + (fraction * (Number(endValue) - Number(startValue)));
		}
		
		public function increment(baseValue:Object, incrementValue:Object):Object
		{
			return Number(baseValue) + Number(incrementValue);
		}
		
		public function decrement(baseValue:Object, decrementValue:Object):Object
		{
			return Number(baseValue) - Number(decrementValue);
		}
	}
}