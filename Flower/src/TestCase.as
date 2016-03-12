package
{
	import flower.events.Event;
	import flower.events.EventDispatcher;

	public class TestCase
	{
		public function TestCase()
		{
			this.testEventDispatcher();
		}
		
		private var name:String = "123sasss";
		
		public function testEventDispatcher():void {
			trace("[Test Case] EventDispatcher ---------------------");
			
			var e:Event = new Event("a");
			e.data = 123;
			var ed:EventDispatcher = new EventDispatcher();
			
			var func:Function = function(event:Event):void {
				if(event.type != "a") {
					trace("  type --",false);
				}
				if(event.data != 123) {
					trace("  data --",false);
				}
			}
			ed.addListener("a",func,null);
			ed.dispatch(e);
			if(ed.hasListener("a") == false) {
				trace("  addListener --",false);
			}
			ed.removeListener("a",func,null);
			if(ed.hasListener("a") == true) {
				trace("  removeListener --",false);
			}
			
			e = new Event("b");
			e.data = name;
			ed.once("b",this.eventBack,this);
			ed.dispatch(e);
			if(ed.hasListener("b")) {
				trace("  once --",false);
			}
			
			trace("-------------------------------------------------\n");
		}
		
		private function eventBack(event:Event):void {
			if(event.data != name) {
				trace("  data --",false);
			}
		}
	}
}