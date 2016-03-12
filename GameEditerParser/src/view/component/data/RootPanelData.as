package view.component.data
{
	import view.events.ComponentAttributeEvent;

	public class RootPanelData extends PanelData
	{
		/**
		 * 尺寸方案
		 * 1. 固定尺寸
		 * 2. 固定尺寸全屏(等比缩放直到两边都在屏幕内，并且一边全屏)
		 * 3. 全屏尺寸
		 * 4. 全屏固定宽(宽缩放到全屏，高根据缩放比计算)
		 * 5. 全屏固定高(高缩放到全屏，高根据缩放比计算)
		 */
		private var _sizeType:int = 0;
		
		
		public function RootPanelData(type:String = "RootPanel")
		{
			super(type);
			this.width = 960;
			this.height = 640
		}
		
		public function set sizeType(val:int):void {
			this._sizeType = val;
			this.dispatchEvent(new ComponentAttributeEvent("sizeType",val));
		}
		
		public function get sizeType():int {
			return this._sizeType;
		}
		
		override public function encode():Object {
			var json:Object = super.encode();
			json.sizeType = sizeType;
			return json;
		}
		
		override public function parser(json:Object):void {
			super.parser(json);
			this.sizeType = json.sizeType;
		}
	}
}