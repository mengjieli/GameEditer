package egret.managers
{
	
	/**
	 * 多语言文本翻译接口。
	 * @author dom
	 */
	public interface ITranslator
	{
		/**
		 * 翻译一个文本
		 * @param key 文本索引，如果库中找不到这个索引则直接返回key
		 * @param params 替换的参数，用于替换{}中的内容
		 */	
		function getText(key:String,params:Array=null):String;
		/**
		 * 附加一个语言配置文件
		 */		
		function addLocaleConfig(config:*):void;
	}
}