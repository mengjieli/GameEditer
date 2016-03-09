package view.component.data
{
	import view.events.ComponentAttributeEvent;

	public class LabelData extends ComponentData
	{
		private var _text:String = "Label";
		private var _color:uint = 0xffffff;
		private var _size:uint = 14;
		
		public function LabelData()
		{
			super("Label");
			this.width = 100;
			this.height = 20;
		}
		
		public function get text():String {
			return _text;
		}
		
		public function set text(val:String):void {
			_text = val;
			this.dispatchEvent(new ComponentAttributeEvent("text",val));
		}
		
		public function get color():uint {
			return _color;
		}
		
		public function set color(val:uint):void {
			_color = val;
			this.dispatchEvent(new ComponentAttributeEvent("color",val));
		}
		
		public function get size():uint {
			return _size;
		}
		
		public function set size(val:uint):void {
			_size = val;
			this.dispatchEvent(new ComponentAttributeEvent("size",val));
		}
	}
}