package locales
{
	import egret.core.ns_egret;
	import egret.managers.Translator;
	
	use namespace ns_egret;
	
	/**
	 * 库项目的多语言配置
	 * @author dom
	 */
	public class locale_egret_desktop
	{
		public function locale_egret_desktop()
		{
		}
		
		[Embed(source="/locales/zh_CN/strings.xml", mimeType="application/octet-stream")]
		private static var zh_CN:Class;
		[Embed(source="/locales/en_US/strings.xml", mimeType="application/octet-stream")]
		private static var en_US:Class;
		
		public static function init():void
		{
			Translator.addLocale(zh_CN,"zh_CN");
			Translator.addLocale(en_US,"en_US");
		}
	}
}