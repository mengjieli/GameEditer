package flower.ui
{
	public class ItemRender extends Group
	{
		private var _data:*;
		private var _itemIndex:*;
		private var _selected:Boolean = false;
		
		public function ItemRender()
		{
		}
		
		
		///////////////////////////////////set & get/////////////////////////////
		public function get data():* {
			return _data;
		}
		
		public function set data(val:*):void {
			_data = val;
		}
		
		public function get itemIndex():int {
			return _itemIndex;
		}
		
		public function $setItemIndex(val:int):void {
			_itemIndex = val;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
	}
}