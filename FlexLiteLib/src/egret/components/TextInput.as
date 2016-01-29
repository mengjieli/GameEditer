package egret.components
{
	import flash.events.Event;
	
	import egret.components.supportClasses.SkinnableTextBase;
	import egret.core.IViewport;
	import egret.core.ns_egret;
	
	use namespace ns_egret;

	[DefaultProperty(name="text",array="false")]
	
	[EXML(show="true")]
	
	/**
	 * 可设置外观的单行文本输入控件
	 * @author dom
	 */	
	public class TextInput extends SkinnableTextBase
	{
		/**
		 * 构造函数
		 */		
		public function TextInput()
		{
			super();
		}
		
		/**
		 * 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
		 */		
		public function get widthInChars():Number
		{
			return getWidthInChars();
		}
		
		public function set widthInChars(value:Number):void
		{
			setWidthInChars(value);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set text(value:String):void
		{
			super.text = value;
			dispatchEvent(new Event("textChanged"));
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == textDisplay)
			{
				textDisplay.multiline = false;
				if(textDisplay is IViewport)
					(textDisplay as IViewport).clipAndEnableScrolling = false;
			}
		}
		
	}
	
}
