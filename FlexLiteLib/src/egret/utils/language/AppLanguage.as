package egret.utils.language
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import mx.utils.StringUtil;
	
	import egret.managers.Translator;

	/**
	 *程序语言工具，支持手动、自动选择语言
	 * @author 杨宁
	 */	
	public class AppLanguage
	{
		public function AppLanguage()
		{
		}
		/**
		 *根据系统语言自动加载语言包
		 */		
		public static const LANGUAGE_AUTO:uint=0;
		/**
		 *根据配置文件中设置的语言加载语言包,如果语言配置未匹配成功则根据系统语言自动选择
		 */		
		public static const LANGUAGE_CONFIG:uint=1;
		
		private static var currentLanguage:String;
		/**
		 *程序启动时初始化 
		 * @param loadType 语言包加载方式，包含的值：LANGUAGE_CONFIG、LANGUAGE_AUTO
		 */		
		public static function init(loadType:uint):void
		{
			var configPath:String="locales/language.xml";
			LanguageConfig.getInstance().loadConfig(configPath);
			if(loadType==LANGUAGE_AUTO)
			{
				var l:String=Capabilities.languages[0];
				switch(Capabilities.language)
				{
					case "zh-CN":
					case "zh-TW":
						currentLanguage=AppLanguageDefine.zh_CN;
						break;
					default:
						currentLanguage=AppLanguageDefine.en_US;
						break;
				}
			}
			else if(loadType==LANGUAGE_CONFIG)
			{
				currentLanguage=LanguageConfig.getInstance().language;
				if(StringUtil.trim(currentLanguage)=="")
				{
					init(LANGUAGE_AUTO);
					return ;
				}
			}
			var packageContent:XML=LanguageConfig.getInstance().getLanguagePackage(currentLanguage);
			Translator.addLocaleConfig(packageContent);
			Translator.locale = currentLanguage;
		}
		/**
		 *获取或设置程序语言，如果初始化时设置为自动加载语言包，则设置的语言不起作用 
		 */		
		public static function get language():String
		{
			return currentLanguage;
		}
		public static function set language(v:String):void
		{
			LanguageConfig.getInstance().language=v;
		}
	}
}
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

class LanguageConfig
{
	private static var instance:LanguageConfig;
	public static function getInstance():LanguageConfig
	{
		if(!instance)
			instance=new LanguageConfig();
		return instance;
	}
	private var relativePath:String;
	private var config:XML;
	public function LanguageConfig()
	{
	}
	private var configLoaded:Boolean=false;
	public function loadConfig(path:String):void
	{
		if(configLoaded)
			return;
		relativePath=path;
		var file:File=File.applicationDirectory.resolvePath(relativePath);
		if(file.exists)
		{
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.READ);
			config=new XML(fs.readUTFBytes(fs.bytesAvailable));
			fs.close();
			configLoaded=true;
		}
		else
		{
			throw new Error("语言配置文件加载失败");
		}
	}
	
	public function get language():String
	{
		return config.child("language")[0].toString();
	}
	public function set language(v:String):void
	{
		var child:XML=config.child("language")[0];
		child.setChildren(new XML(v));
		var fs:FileStream=new FileStream();
		fs.open(new File(File.applicationDirectory.resolvePath(relativePath).nativePath),FileMode.WRITE);
		fs.writeUTFBytes(config.toXMLString());
		fs.close();
	}
	public function getAllLanguage():Array
	{
		var xml:XMLList=config.child("package");
		var arr:Array=[];
		for each(var item:XML in xml.children())
		{
			arr.push(item.@name.toString());
		}
		return arr;
	}
	public function getLanguagePackage(v:String):XML
	{
		var xml:XMLList=config.child("package");
		for each(var item:XML in xml.children())
		{
			if(item.@name.toString()==v)
			{
				var file:File=File.applicationDirectory.resolvePath(item.@path.toString());
				if(file.exists)
				{
					var fs:FileStream=new FileStream();
					fs.open(file,FileMode.READ);
					var content:String=fs.readUTFBytes(fs.bytesAvailable);
					fs.close();
					return new XML(content);
				}
				break ;
			}
		}
		return null;
	}
}