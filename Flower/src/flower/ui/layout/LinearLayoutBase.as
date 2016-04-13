package flower.ui.layout
{
	public class LinearLayoutBase extends Layout
	{
		private var _fixElementSize:Boolean = false;
		private var _gap:int = 0;
		private var _horizontalAlign:String = "";
		private var _verticalAlign:String = "";
		
		public function LinearLayoutBase()
		{
		}
		
		override public function updateList(widt:int,height:int):void {
			if(!this.flag) {
				return;
			}
			var list:Array = this.elements;
			var len:int = list.length;
			if(!len) {
				return;
			}
			var i:int;
			if(_verticalAlign == Layout.VerticalAlign) {
				if(_fixElementSize) {
					var eh:int = list[0].height;
					for(i = 0; i < len; i++) {
						list[i].y = i*(eh + _gap);
					}
				} else {
					var y:int = 0;
					for(i = 0; i < len; i++) {
						list[i].y = y;
						y += list[i].height + _gap;
					}
				}
			}
			if(_horizontalAlign == Layout.HorizontalAlign){
				if(_fixElementSize) {
					var ew:int = list[0].width;
					for(i = 0; i < len; i++) {
						list[i].x = i*(ew + _gap);
					}
				} else {
					var x:int = 0;
					for(i = 0; i < len; i++) {
						list[i].x = x;
						x += list[i].width + _gap;
					}
				}
			}
		}
		
		public function get fixElementSize():Boolean {
			return _fixElementSize;
		}
		
		public function set fixElementSize(val:Boolean):void {
			_fixElementSize = !!val;
		}
		
		public function get gap():int {
			return _gap;
		}
		
		public function set gap(val:int):void {
			val = +val||0;
			_gap = val;
		}
		
		public function get horizontalAlign():String {
			return _horizontalAlign;
		}
		
		public function set horizontalAlign(val:String):void {
			_horizontalAlign = val;
		}
		
		public function get verticalAlign():String {
			return _verticalAlign;
		}
		
		public function set verticalAlign(val:String):void {
			_verticalAlign = val;
		}
	}
}