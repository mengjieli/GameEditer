package main.data.parsers.command
{
	public class AttributeEXE extends Execute
	{
		private var thisObj:*;
		private var property:String;
		private var value:*;
		
		public function AttributeEXE(thisObj:*,property:String,value:*)
		{
			this.thisObj = thisObj;
			this.property = property;
			this.value = value;
		}
		
		override public function excute():void {
			thisObj[property] = value;
		}
	}
}