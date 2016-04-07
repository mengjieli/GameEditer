package flower.data.member
{
	public class ArrayValue
	{
		//添加元素
		public static const ADD:String = "add";
		//删除元素
		public static const DEL:String = "del";
		//长度改变会触发 update
		public static const LENGTH:String = "length";
		//所有的更新都会触发 update
		public static const UPDATE:String = "update";
		
		private var _events:Object;
		private var _length:uint;
		private var list:Array;
		private var _key:String = "";
		private var _rangeMinKey:String = "";
		private var _rangeMaxKey:String = "";
		
		public function ArrayValue(initList:Array)
		{
			_events = {};
			list = initList||[];
			_length = list.length;
		}
		
		public function push (item:*):void {
			this.list.push(item);
			this.length = this._length + 1;
			this.dispatch("add", item);
		}
		
		public function addItemAt(item:*, index:uint):void {
			index = +index&~0;
			this.list.splice(index, 0, item);
			this.length = this._length + 1;
			this.dispatch("add", item);
		}
		
		public function shift():* {
			var item:* = this.list.shift();
			this.length = this._length - 1;
			this.dispatch("del", item);
		}
		
		public function splice(startIndex:int,delCount:*=0,...args):void {
			var i:int;
			delCount = +delCount&~0;
			if(delCount <= 0) {
				for(i = 0; i < args.length; i++) {
					this.list.splice(startIndex, 0, args[i]);
				}
				this.length = this._length + 1;
				for(i = 0; i < args.length; i++) {
					this.dispatch("add", args[i]);
				}
			} else {
				var list:Array = this.list.splice(startIndex,delCount);
				this.length = this._length - delCount;
				for(i = 0; i < list.length; i++) {
					this.dispatch("del", list[i]);
				}
			}
		}
		
		public function slice(startIndex:int,end:int):ArrayValue {
			return ArrayValue.create(this.list.slice(startIndex,end));
		}
		
		public function pop():* {
			var item:* = this.list.pop();
			this.length = this._length - 1;
			this.dispatch("del", item);
		}
		
		public function removeAll():void {
			while(this.length) {
				var item:* = this.list.pop();
				this.length = this._length - 1;
				this.dispatch("del", item);
			}
		}
		
		public function delItemAt(index:uint):void {
			index = +index&~0;
			var item:* = this.list.splice(index,1)[0];
			this.length = this._length - 1;
			this.dispatch("del", item)
		}
		
		public function delItem(key:String, value:*, key2:String="", value2:*=null):* {
			var item:*;
			var i:int;
			if (key2 != "") {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value) {
						item = this.list.splice(i, 1)[0];
						break;
					}
				}
			} else {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value && this.list[i][key2] == value2) {
						item = this.list.splice(i, 1)[0];
						break;
					}
				}
			}
			if(!item) {
				return;
			}
			this.length = this._length - 1;
			this.dispatch("del", item);
			return item;
		}
		
		public function getItem(key:String, value:*, key2:String="", value2:*=null):* {
			var i:int;
			if (key2 != "") {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value) {
						return this.list[i];
					}
				}
			} else {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value && this.list[i][key2] == value2) {
						return this.list[i];
					}
				}
			}
			return null;
		}
		
		public function getItemFunction(func,thisObj,...args):* {
			for (var i:int = 0; i < this.list.length; i++) {
				args.push(this.list[i]);
				var r:Boolean = func.apply(thisObj,args);
				args.pop();
				if (r == true) {
					return this.list[i];
				}
			}
			return null;
		}
		
		public function getItems(key:String, value:*, key2:String="", value2:*=null):Array {
			var result:Array = [];
			var i:int;
			if (key2 != "") {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value) {
						result.push(this.list[i]);
					}
				}
			} else {
				for (i = 0; i < this.list.length; i++) {
					if (this.list[i][key] == value && this.list[i][key2] == value2) {
						result.push(this.list[i]);
					}
				}
			}
			return result;
		}
		
		public function setItemsAttribute(findKey:String,findValue:*,setKey:String="",setValue:*=null):void {
			for (var i:int = 0; i < this.list.length; i++) {
				if (this.list[i][findKey] == findValue) {
					this.list[i][setKey] = setValue;
				}
			}
		}
		
		public function getItemsFunction(func:Function,thisObj:*=null):Array {
			var result:Array = [];
			var args:Array = [];
			if(arguments.length && arguments.length > 2) {
				args = [];
				for(var a:int = 2; a < arguments.length; a++) {
					args.push(arguments[a]);
				}
			}
			for (var i:int = 0; i < this.list.length; i++) {
				args.push(this.list[i]);
				var r:Boolean = func.apply(thisObj,args);
				args.pop();
				if (r == true) {
					result.push(this.list[i]);
				}
			}
			return result;
		}
		
		public function sort():void {
			this.list.sort.apply(this.list.sort, arguments);
			this.dispatch("update");
		}
		
		public function getItemAt(index):* {
			return this.list[index];
		}
		
		public function getItemByValue(value:*):* {
			if (this.key == "") {
				return null;
			}
			for (var i:int = 0; i < this.list.length; i++) {
				if (this.list[i][this.key] == value) {
					return this.list[i];
				}
			}
			return null;
		}
		
		public function getItemByRange(value:*):* {
			if (this.key == "" || this.rangeMinKey == "" || this.rangeMaxKey == "") {
				return null;
			}
			for (var i:int = 0; i < this.list.length; i++) {
				var min:Number = this.list[i][this.rangeMinKey];
				var max:Number = this.list[i][this.rangeMaxKey];
				if (value >= min && value <= max) {
					return this.list[i];
				}
			}
			return null;
		}
		
		public function getItemsByRange(value:*):Array {
			if (this.key == "" || this.rangeMinKey == "" || this.rangeMaxKey == "") {
				return null;
			}
			var list:Array = [];
			for (var i:int = 0; i < this.list.length; i++) {
				var min:Number = this.list[i][this.rangeMinKey];
				var max:Number = this.list[i][this.rangeMaxKey];
				if (value >= min && value <= max) {
					list.push(this.list[i]);
				}
			}
			return list;
		}
		///////////////////////////////////get && set///////////////////////////////////
		public function set key(val:String):void {
			this._key = val;
		}
		
		public function get key():String {
			return this._key;
		}
		
		public function set rangeMinKey(val:String):void {
			this._rangeMinKey = val;
		}
		
		public function get rangeMinKey():String {
			return _rangeMinKey;
		}
		
		public function set rangeMaxKey(val:String):void {
			this._rangeMaxKey = val;
		}
		
		public function get rangeMaxKey():String {
			return _rangeMaxKey;
		}
		
		public function get length():uint {
			return _length;
		}
		
		public function set length(val:uint):void {
			val = +val&~0;
			if(this._length == val) {
				return;
			} else {
				if(val == this.list.length) {
					this._length = val;
					this.dispatch("length");
					this.dispatch("update");
				} else {
					while(this.list.length > val) {
						this.pop();
					}
				}
			}
		}
		////////////////////////////////EventDispatcher///////////////////////////////////
		public function _addListener(type:String, listener:Function, thisObject:*):void {
			if(!_events[type]) {
				_events[type] = [];
			}
			var list:Array = _events[type];
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					return;
				}
			}
			list.push({
				"listener":listener,
				"thisObject":thisObject,
				"del":false
			});
		}
		
		public function removeListener(type:String,listener:Function,thisObject:*):void {
			var list:Array = _events[type];
			if(!list) {
				return;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					list[i].listener = null;
					list[i].thisObject = null;
					list[i].del = true;
					break;
				}
			}
		}
		
		public function removeAllListener():void {
			_events = {};
		}
		
		public function hasListener(type:String):Boolean {
			var list:Array = _events[type];
			if(!list) {
				return false;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].del == false) {
					return true;
				}
			}
			return false;
		}
		
		private function dispatch(type:String,item:*=null):void {
			var list:Array = _events[type];
			if(!list) {
				return;
			}
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].del == false) {
					var listener:Function = list[i].listener;
					var thisObj:* = list[i].thisObject;
					if(item) {
						listener.call(thisObj,item);
					} else {
						listener.call(thisObj);
					}
				}
			}
			for(i = 0; i < list.length; i++) {
				if(list[i].del == true) {
					list.splice(i,1);
					i--;
				}
			}
		}
		
		public function dispose():void {
			_events = null;
			list = null;
			_length = 0;
		}
		
		private static var pool:Vector.<ArrayValue> = new Vector.<ArrayValue>();
		public static function create(initValue:Array=null):ArrayValue {
			var value:ArrayValue;
			if(pool.length) {
				value = pool.pop();
				value._events = {};
				value.list = value.list||[];
				value._length = value.list.length;
			} else {
				value = new ArrayValue(initValue);
			}
			return value;
		}
		
		public static function release(array:ArrayValue):void {
			array.dispose();
			pool.push(array);
		}
	}
}