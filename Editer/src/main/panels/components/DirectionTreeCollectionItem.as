package main.panels.components
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import egret.events.CollectionEventKind;

	public class DirectionTreeCollectionItem extends EventDispatcher
	{	
		private var _name:String;
		private var _desc:String;
		private var _url:String;
		private var _type:String;
		private var _state:String = CollectionEventKind.CLOSE;
		private var _fileType:String;
		
		public var children:Vector.<DirectionTreeCollectionItem> = new Vector.<DirectionTreeCollectionItem>();
		
		public function DirectionTreeCollectionItem(name:String,desc:String,url:String,type:String,fileType:String="")
		{
			this._name = name;
			this._desc = desc;
			this._url = url;
			this._type = type;
			this._fileType = fileType;
		}
		
		public function set name(val:String):void {
			_name = val;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get url():String {
			return this._url;
		}
		
		public function set state(val:String):void {
			_state = val;
		}
		
		public function get state():String {
			return _state;
		}
		
		public function get fileIcon():String {
			if(_type == "direction") {
				return "assets/directionView/fileIcon/folder_" + _state + ".png";
			}
			var end:String = "";
			if(_fileType == "") {
				end = this.url.split("/")[this.url.split("/").length-1];
				end = this.url.split(".")[this.url.split(".").length-1];
			}
			return "assets/directionView/fileIcon/" + end + ".png";
		}
		
		public function get isDirection():Boolean {
			return this._type=="direction"?true:false;
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
			return this._desc!=""?this._desc:this._name;
		}
	}
}