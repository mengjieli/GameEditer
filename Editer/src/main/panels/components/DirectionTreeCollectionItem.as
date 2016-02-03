package main.panels.components
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import egret.events.CollectionEventKind;
	
	import main.data.directionData.DirectionDataBase;

	public class DirectionTreeCollectionItem extends EventDispatcher
	{	
		public var isSort:Boolean = true;
		private var _state:String = CollectionEventKind.CLOSE;
		private var pathData:DirectionDataBase;
		
		public var children:Vector.<DirectionTreeCollectionItem> = new Vector.<DirectionTreeCollectionItem>();
		
		public function DirectionTreeCollectionItem(data:DirectionDataBase)
		{
			this.pathData = data;
		}
		
		public function get directionData():DirectionDataBase {
			return this.pathData;
		}
		
		public function get url():String {
			return pathData.url
		}
		
		public function set state(val:String):void {
			_state = val;
		}
		
		public function get state():String {
			return _state;
		}
		
		public function get fileIcon():String {
			if(pathData.isDirection) {
				if(this._state == CollectionEventKind.CLOSE) {
					return pathData.directionCloseIcon;
				}
				return pathData.directionOpenIcon;
			}
			return pathData.fileIcon;
		}
		
		public function get isDirection():Boolean {
			return pathData.isDirection;
		}
		
		/**
		 * 指定的节点是否打开
		 */		
		public function get isOpen():Boolean {
			return this.state==CollectionEventKind.OPEN?true:false;
		}
		
		public function changeState(state:String):void {
			_state = state;
			this.dispatchEvent(new Event(_state));
		}
		
		public function get icon():Object {
			var icon:String;
			if(_state == CollectionEventKind.OPEN) icon = "Open";
			else if(_state == CollectionEventKind.CLOSE) icon = "Close";
			return "assets/directionView/floder" + icon + ".png";
		}
		
		override public function toString():String {
			return this.pathData.nameDesc;
		}
	}
}