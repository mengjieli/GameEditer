package flower.ui
{
	import flower.data.member.ArrayValue;

	public class DataGroup extends Group
	{
		private var _data:ArrayValue;
		private var _itemRender:*;
		private var items:Array = [];
		
		public function DataGroup()
		{
		}
		
		///////////////////////////////////set & get/////////////////////////////
		public function get dataProvider():ArrayValue {
			return _data;
		}
		
		public function set dataProvider(val:ArrayValue):void {
			_data = val;
		}
		
		public function get itemRender():* {
			return _itemRender;
		}
		
		public function set itemRender(val:*):void {
			_itemRender = val;
		}
		
		public function get numElements():int {
			return items.length;
		}
		
	}
}