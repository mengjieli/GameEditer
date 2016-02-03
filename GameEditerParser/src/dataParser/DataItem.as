package dataParser
{
	public class DataItem
	{
		private var _name:String;
		private var _desc:String;
		private var _type:String;
		private var _typeValue:String;
		
		public function DataItem()
		{
		}
		
		public function set name(val:String):void {
			_name = val;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function set desc(val:String):void {
			_desc = val;
		}
		
		public function get desc():String {
			return _desc;
		}
		
		public function set type(val:String):void {
			_type = val;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function set typeValue(val:String):void {
			_typeValue = val;
		}
		
		public function get typeValue():String {
			return _typeValue;
		}
	}
}