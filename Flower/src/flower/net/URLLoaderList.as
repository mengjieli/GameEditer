package flower.net
{
	import flower.events.Event;
	import flower.events.EventDispatcher;

	public class URLLoaderList extends EventDispatcher
	{
		private var list:Array;
		private var dataList:Array;
		private var index:int;
		
		public function URLLoaderList(list:Array)
		{
			this.list = list;
		}
		
		public function load():void {
			dataList = [];
			index = 0;
			this.loadNext();
		}
		
		private function loadNext():void {
			if(index >= list.length) {
				this.dispatchWidth(Event.COMPLETE,dataList);
				this.list = null;
				this.dataList = null;
				return;
			}
			var item:* = list[index];
			var load:URLLoader = new URLLoader(item);
			load.addListener(Event.COMPLETE,onComplete,this);
			load.load();
		}
		
		private function onComplete(e:Event):void {
			dataList[index] = e.data;
			index++;
			loadNext();
		}
	}
}