package com.jc.utils
{
	/**
	 *颜色转换 
	 * @author MengJie.Li
	 * 
	 */	
	public class ColorTransform
	{
		private var _save:Array = [];
		public var alphaMultiplier:Number;
		
		public function ColorTransform()
		{
		}
		
		public function save():void
		{
			_save.push(alphaMultiplier);
		}
		
		public function restore():void
		{
			alphaMultiplier = _save.pop();
		}
	}
}