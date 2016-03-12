package com.flower.cocos2dx
{
	/**
	 *创建对象的锁管理器，防止外部创建对象导致出错 
	 * @author MengJie.Li
	 * 
	 */	
	public class EngineLock
	{
		public static var DisplayObjectContainer:Boolean = true;
		public static var Bitmap:Boolean = true;
		public static var TextField:Boolean = true;
	}
}