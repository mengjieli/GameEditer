package egret.components.supportClasses
{
	import flash.utils.getDefinitionByName;
	
	import egret.components.SkinnableComponent;
	import egret.core.IFactory;
	import egret.core.ISkinAdapter;
	
	
	/**
	 * 默认的ISkinAdapter接口实现
	 * @author dom
	 */
	public class DefaultSkinAdapter implements ISkinAdapter
	{
		/**
		 * 构造函数
		 */		
		public function DefaultSkinAdapter()
		{
		}
		/**
		 * @inheritDoc
		 */
		public function getSkin(skinName:Object,client:SkinnableComponent):Object
		{
			if(!skinName)
				return null;
			if(skinName is Class){
				return new skinName();
			}
			else if(skinName is IFactory)
			{
				return IFactory(skinName).getInstance();
			}
			else if(skinName is String){
				var clazz:Object = getDefinitionByName(skinName as String);
				if(clazz){
					return new clazz();
				}
				else{
					return null;
				}
			}
			else{
				return skinName;
			}
		}
	}
}