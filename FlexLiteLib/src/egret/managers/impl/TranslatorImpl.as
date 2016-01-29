package egret.managers.impl
{
	import flash.utils.ByteArray;
	
	import egret.managers.ITranslator;
	
	[ExcludeClass]
	/**
	 * 
	 * @author dom
	 */
	public class TranslatorImpl implements ITranslator
	{
		public function TranslatorImpl()
		{
		}
		
		private var textMap:Object = {};
		
		/**
		 * 取得一个文本
		 * @param key 文本索引，如果库中找不到这个索引则直接返回key
		 * @param params 替换的参数，用于替换{}中的内容
		 */	
		public function getText(key:String,params:Array=null):String
		{
			var text:String;
			if(textMap[key] != undefined)
				text = textMap[key];
			else
				text = key;
			if(params)
			{
				var len:int=params.length;
				for(var i:int=0;i<len;i++)
				{
					text = text.replace("{"+i+"}",params[i]);
				}
			}
			text = text.split("\\n").join("\n");
			return text;
		}
		/**
		 * 附加一个语言配置文件
		 */	
		public function addLocaleConfig(config:*):void
		{
			if(!config)
			{
				return;
			}
			
			if(config is Class)
			{
				try
				{
					var byteDataTxt:ByteArray = new config();  
					var languageStr:String = byteDataTxt.readUTFBytes(byteDataTxt.bytesAvailable);
					config = new XML(languageStr);
				}
				catch(error:Error) 
				{
					return;
				}
			}
			
			if(config is XML)
			{
				for each(var item:XML in config.item)
				{
					var key:String = String(item.@key);
					var value:String = String(item.@value);
					textMap[key] = value;
				}
			}
		}
	}
}