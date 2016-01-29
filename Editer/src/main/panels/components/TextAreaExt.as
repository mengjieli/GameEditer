package main.panels.components
{
	import flash.display.NativeMenu;
	import flash.display.Sprite;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.Scroller;
	import egret.core.UIComponent;

	/**
	 * @author Grayness
	 */	
	public class TextAreaExt extends Scroller
	{
		private var group:Group;
		private var endY:Number = 0;
		private var _max:int = 0;
		
		public function TextAreaExt()
		{
			super();
		}
		
		public function set max(val:Number):void {
			_max = val;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			group = new Group();
			endY = 0;
			this.viewport = group;
		}
		
		public function appendText(text:String,color:uint):void {
			var label:Label = new Label();
			label.textColor = color;
			label.text = text;
			label.y = endY;
			group.addElement(label);
			endY += 20;
		}
		
		public function shift():void {
			var reduce:Number = 0;
			group.removeElementAt(0);
			reduce += 20;
			endY -= 20;
			if(reduce) {
				for(var i:Number = 0; i < group.numChildren; i++) {
					group.getElementAt(i).y -= reduce;
				}
			}
		}
		
		public function get text():String {
			var str:String = "";
			for(var i:int = 0; i < group.numChildren; i++) {
				str += (group.getChildAt(i) as Label).text + "\n";
			}
			return str;
		}
		
		public function clear():void {
			endY = 0;
			group.removeAllElements();
		}
		
		private var registCall:Boolean=false;
		public function scrollToEnd():void
		{
			this.viewport.verticalScrollPosition=this.viewport.contentHeight;
		}
	}
}