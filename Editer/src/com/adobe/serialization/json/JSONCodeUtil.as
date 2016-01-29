package com.adobe.serialization.json
{
	/**
	 * JSON工具 
	 * @author 雷羽佳
	 * 
	 */	
	internal class JSONCodeUtil
	{
		public static var space:String = ""+
			"	";
		public function JSONCodeUtil()
		{
			
		}
		/**
		 * 得到空格 
		 * @param num
		 * @return 
		 * 
		 */		
		public static function getSpace(num:int = 1):String
		{
			var str:String = "";
			for(var i:int = 0;i<num;i++)
			{
				str+=space;
			}
			return str;
		}
	}
}