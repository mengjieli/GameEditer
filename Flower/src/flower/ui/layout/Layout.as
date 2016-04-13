package flower.ui.layout
{
	import flower.display.DisplayObject;

	public class Layout
	{
		protected var elements:Array = [];
		protected var flag:Boolean = false;
		
		public function Layout() {
		}
		
		public function addElementAt(element:DisplayObject,index:int):void {
			var len:int = elements.length;
			for(var i:int = 0; i < len; i++) {
				if(elements[i] == element) {
					elements.splice(i,1);
					break;
				}
			}
			elements.splice(index,0,element);
			flag = true;
		}
		
		public function setEelementIndex(element:DisplayObject,index:int):void {
			var len:int = elements.length;
			for(var i:int = 0; i < len; i++) {
				if(elements[i] == element) {
					elements.splice(i,1);
					break;
				}
			}
			elements.splice(index,0,element);
			flag = true;
		}
		
		public function removeElement(element:DisplayObject):void {
			var len:int = elements.length;
			for(var i:int = 0; i < len; i++) {
				if(elements[i] == element) {
					elements.splice(i,1);
					break;
				}
			}
			flag = true;
		}
		
		public function removeElementAt(index:int):void {
			elements.splice(index,1);
			flag = true;
		}
		
		public function $setFlag():void {
			flag = true;
		}
		
		public function updateList(widt:int,height:int):void {
		}
		
		public function $clear():void {
			elements = [];
			flag = false;
		}
		
		public static const VerticalAlign:String = "vertical";
		public static const HorizontalAlign:String = "horizontal";
		public static const NoneAlgin:String = "";
	}
}