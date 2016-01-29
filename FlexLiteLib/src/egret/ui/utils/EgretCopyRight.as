package egret.ui.utils
{
	
	/**
	 * 
	 * @author dom
	 */
	public class EgretCopyRight
	{
		private static const EGRET_DOMAIN:String = " www.egret.com";
		private static const COPY_RIGHT:String = "Copyright © ";
		/**
		 * Egret版权字符串
		 */		
		public static function get copyRight():String
		{
			var year:Number = new Date().fullYear;
			if(year>2014)
			{
				return COPY_RIGHT+"2014-"+year+EGRET_DOMAIN;
			}
			return COPY_RIGHT+"2014"+year+EGRET_DOMAIN;
		}
	}
}