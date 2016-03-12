package com.flower.cocos2dx
{
	import com.flower.ClassName;

	public class ClassBase
	{
		/**
		 * className用以区别是哪个类
		 */
		public var className:int = 0;
		
		public function ClassBase()
		{
			className = ClassName.ClassBase;
		}
	}
}