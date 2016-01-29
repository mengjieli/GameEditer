package egret.components.gridClasses
{
	import egret.core.IEditableText;
	import egret.skins.vector.TextAreaSkin;
	
	/**
	 * 默认的单元格编辑器
	 * @author dom
	 */
	public class DefaultGridItemEditor extends GridItemEditor
	{
		/**
		 * 构造函数
		 */		
		public function DefaultGridItemEditor()
		{
			super();
			this.skinName = TextAreaSkin;
		}
		/**
		 * 文本编辑组件
		 */		
		public var textDisplay:IEditableText;
		/**
		 * @inheritDoc
		 */
		override public function get value():Object
		{
			return textDisplay.text;            
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set value(newValue:Object):void
		{
			textDisplay.text = newValue != null ? newValue.toString() : "";
			textDisplay.setFocus();
			textDisplay.selectAll();
		}
	}
}