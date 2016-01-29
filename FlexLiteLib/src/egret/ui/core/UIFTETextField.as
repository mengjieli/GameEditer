package egret.ui.core
{
	import flash.events.Event;
	
	import egret.ui.core.FTEText.core.FTETextField;

	public class UIFTETextField extends FTETextField
	{
		public function UIFTETextField()
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set height(value:Number):void
		{
			var changed:Boolean = height != value;
			super.height = value+leading;
			if(changed)
				dispatchEvent(new Event("heightChanged"));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void  
		{
			var changed:Boolean = super.width != value;
			super.width = value;
			if(changed)
				dispatchEvent(new Event("widthChanged"));
		}
		
		/**
		 * @inheritDoc
		 */
		override public function replaceText(beginIndex:int, endIndex:int, newText:String, format:Boolean=true, createHistory:Boolean=true):Boolean
		{
			var result:Boolean = super.replaceText(beginIndex, endIndex, newText,format,createHistory);
			dispatchEvent(new Event("textChanged"));
			return result;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set text(value:String):void
		{
			if (!value)
				value = "";
			var changed:Boolean = super.text != value;
			
			super.text = value;
			
			if(changed)
				dispatchEvent(new Event("textChanged"));
		}
	}
}