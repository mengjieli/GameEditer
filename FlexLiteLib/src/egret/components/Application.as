package egret.components
{
	import flash.utils.getQualifiedClassName;
	
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	/**
	 * desktop项目的文档类，定义主窗体样式用的。
	 * @author 雷羽佳
	 * 
	 */	
	public class Application extends SkinnableContainer
	{
		public function Application()
		{
			super();
			this.left = 0;
			this.right = 0;
			this.top = 0;
			this.bottom = 0;
			
		}
	
	}
}