package egret.core
{
	
	/**
	 * 素材适配器接口。
     * 若项目需要自定义UIAsset.source的解析规则，需要实现这个接口，
     * 然后调用Injector.mapClass(IAssetAdapter,YourAssetAdapter)注入到框架即可。
	 * @author dom
	 */
	public interface IAssetAdapter
	{
		/**
		 * 解析素材
		 * @param source 待解析的新素材标识符
		 * @param compFunc 解析完成回调函数，示例：compFunc(content:any,source:any):void;
		 * @param oldContent 旧的内容对象,传入值有可能为null。
		 * 对于某些类型素材，例如MovieClip，可以重用传入的显示对象,只修改其数据再返回。
		 */		
		function getAsset(source:Object,compFunc:Function,oldContent:Object):void;
	}
}