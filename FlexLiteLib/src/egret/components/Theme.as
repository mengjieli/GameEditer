package egret.components
{
	import flash.utils.getDefinitionByName;
	
	import avmplus.getQualifiedClassName;
	import avmplus.getQualifiedSuperclassName;
	
	
	/**
	 * 主题基类，继承此类以配置默认皮肤。在程序初始化处调用Injector.mapClass(Theme,YourTheme)启用自定义的主题。
	 * @author dom
	 */
	public class Theme
	{
		public function Theme()
		{
			mapSkin();
		}
		
		protected var skinMap:Object = {};
		/**
		 * 子类覆盖此方法初始化默认皮肤的映射关系。
		 */		
		protected function mapSkin():void
		{
			
		}
		
		public function getDefaultSkin(client:SkinnableComponent):Object
		{
			var skinMap:Object = this.skinMap;
			var skinClass:Class;
			var hostKey: String = client.hostComponentKey;
			if(hostKey)
			{
				skinClass = skinMap[hostKey];
			}
			else
			{
				var superClass:Object = client;
				while (superClass) 
				{
					hostKey = getQualifiedClassName(superClass);
					skinClass = skinMap[hostKey];
					if(skinClass)
					{
						break;
					}
					var superclassName:String = getQualifiedSuperclassName(superClass);
					if(superclassName)
					{
						superClass = getDefinitionByName(superclassName);
					}else
					{
						break;
					}
				}
			}
			
			if(!skinClass)
			{
				return null;
			}
			return new skinClass();
		}
	}
}