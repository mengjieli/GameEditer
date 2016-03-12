package com.flower.cocos2dx.utils
{
	import cocos2dx.gameNet.GameNet;

	public class FileUtils
	{
		public static function readFile(url:String):String
		{
			return GameNet.readFile(url);
		}
	}
}