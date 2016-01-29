package egret.ui.core
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 单例工厂
	 * @author dom
	 */
	public class Factory
	{
		/**
		 * 储存类的映射规则
		 */		
		private static var mapClassDic:Dictionary = new Dictionary;
		
		/**
		 * 注入一个类定义为单例，只有第一次请求它的单例时才会被实例化。
		 * @param clazz 要标记为单例的类定义,构造函数必须为空。
		 */		
		public static function mapClass(clazz:Class):void
		{
			var key:String = getClassName(clazz);
			mapClassDic[key] = clazz;
		}
		
		private static var mapValueDic:Dictionary = new Dictionary(true);
		
		/**
		 * 检查指定的类定义注入是否存在
		 * @param clazz 映射的键,类定义或者类的完全限定名字符串
		 */		
		public static function hasMapRule(clazz:*):Boolean
		{
			var key:String = getClassName(clazz);
			
			if(mapClassDic[key])
			{
				return true;
			}
			return false;
		}
		/**
		 * 获取指定映射的实例,若传入的类定义之前未注入过，则会自动调用注入。
		 * @param clazz 映射的键,类定义或者类的完全限定名字符串
		 */		
		public static function getInstance(clazz:*):*
		{
			var key:String = getClassName(clazz);
			var instance:*;
			for(instance in mapValueDic)
			{
				if(mapValueDic[instance]==key)
					return instance;
			}
			var returnClass:Class = mapClassDic[key] as Class;
			if(!returnClass)
			{
				if(clazz is Class)
				{
					returnClass = mapClassDic[key] = clazz;
				}
				else
				{
					try
					{
						returnClass = getDefinitionByName(key) as Class;
					}
					catch(e:Error){}
					if(returnClass)
						mapClassDic[key] = returnClass;
				}
			}
			if(returnClass)
			{
				try
				{
					instance = new returnClass();
				}
				catch(e:Error)
				{
					return null;
				}
				mapValueDic[instance] = key;
				return instance;
			}
			return null;
		}
		/**
		 * 获取类名
		 */		
		private static function getClassName(clazz:*):String
		{
			if(clazz is Class)
			{
				var name:String = getQualifiedClassName(clazz);
			}
			else
			{
				name = clazz.toString();
			}
			name = name.split("::").join(".");
			return name;
		}
	}
}