package egret.managers
{
	import egret.core.Injector;
	import egret.core.ns_egret;
	import egret.managers.impl.TranslatorImpl;
	
	use namespace ns_egret;
	
	/**
	 * 多语言文本翻译工具
	 * @author dom
	 */
	public class Translator
	{
		private static var _impl:ITranslator;
		/**
		 * 获取单例
		 */		
		private static function get impl():ITranslator
		{
			if (!_impl)
			{
				try
				{
					_impl = Injector.getInstance(ITranslator);
				}
				catch(e:Error)
				{
					_impl = new TranslatorImpl();
				}
			}
			return _impl;
		}
		
		private static var localesMap:Object = {};
		
		ns_egret static function addLocale(clazz:Class,key:String):void
		{
			if(initialized)
			{
				if(key==locale)
				{
					impl.addLocaleConfig(clazz);
				}
				return;
			}
			var list:Array = localesMap[key];
			if(!list)
			{
				list = localesMap[key] = [clazz];
			}
			else
			{
				list.push(clazz);
			}
		}
		/**
		 * 语言版本字符串必须在第一次调用Translator.getText()或tr()方法前就设置，例如：zh_CN,en_US等
		 */		
		public static var locale:String = "zh_CN";

		private static var initialized:Boolean = false;
		/**
		 * 初始化库的语言配置
		 */		
		private static function initialize():void
		{
			initialized = true;
			var list:Array = localesMap[locale];
			if(!list)
				return;
			for each(var clazz:Class in list)
			{
				impl.addLocaleConfig(clazz);
			}
		}
		
		/**
		 * 取得一个文本
		 * @param key 文本索引，如果库中找不到这个索引则直接返回key
		 * @param params 替换的参数，用于替换{}中的内容
		 */	
		public static function getText(key:String,params:Array=null):String
		{
			if(!initialized)
			{
				initialize();
			}
			return impl.getText(key,params);
		}
		
		/**
		 * 附加一个语言配置文件
		 */	
		public static function addLocaleConfig(config:*):void
		{
			impl.addLocaleConfig(config);
		}
	}
}