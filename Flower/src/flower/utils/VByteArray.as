package flower.utils
{
	public class VByteArray
	{
		private var bytes:Array;
		private var big:Boolean;
		private var _position:uint;
		private var length:uint;
		
		public function VByteArray(big:Boolean=true)
		{
			this.bytes = [];
			this.big = big;
			this.position = 0;
			this.length = 0;
		}
		
		public function readFromArray(bytes:*):void {
			this.bytes.length = 0;
			this.position = 0;
			this.length = 0;
			this.bytes = bytes;
			this.length = this.bytes.length;
		}
		
		public function writeInt(val:*):void {
			val = +val&~0;
			if (val >= 0) {
				val *= 2;
			}
			else {
				val = ~val;
				val *= 2;
				val++;
			}
			this.writeUInt(val);
		}
		
		public function writeUInt(val:*):void {
			val = val<0?0:val;
			val = +val&~0;
			var flag:Boolean = false;
			val = val < 0 ? -val : val;
			var val2:Number = 0;
			if (val >= 0x10000000) {
				val2 = val / 0x10000000;
				val = val & 0xFFFFFFF;
				flag = true;
			}
			if (flag || val >> 7) {
				this.bytes.splice(this.position, 0, 0x80 | val & 0x7F);
				this.position++;
				this.length++;
			}
			else {
				this.bytes.splice(this.position, 0, val & 0x7F);
				this.position++;
				this.length++;
			}
			if (flag || val >> 14) {
				this.bytes.splice(this.position, 0, 0x80 | (val >> 7) & 0x7F);
				this.position++;
				this.length++;
			}
			else if (val >> 7) {
				this.bytes.splice(this.position, 0, (val >> 7) & 0x7F);
				this.position++;
				this.length++;
			}
			if (flag || val >> 21) {
				this.bytes.splice(this.position, 0, 0x80 | (val >> 14) & 0x7F);
				this.position++;
				this.length++;
			}
			else if (val >> 14) {
				this.bytes.splice(this.position, 0, (val >> 14) & 0x7F);
				this.position++;
				this.length++;
			}
			if (flag || val >> 28) {
				this.bytes.splice(this.position, 0, 0x80 | (val >> 21) & 0x7F);
				this.position++;
				this.length++;
			}
			else if (val >> 21) {
				this.bytes.splice(this.position, 0, (val >> 21) & 0x7F);
				this.position++;
				this.length++;
			}
			if (flag) {
				this.writeUInt(Math.floor(val2));
			}
		}
		
		public function get position():Number {
			return _position;
		}
		
		public function set position(val:Number):void {
			_position = val;
		}
		
		public function writeByte(val:*):void {
			val = +val&~0;
			this.bytes.splice(this.position, 0, val);
			this.length += 1;
			this.position += 1;
		}
		
		
		public function writeBoolean(val:*):void {
			val = !!val;
			this.bytes.splice(this.position, 0, val == true ? 1 : 0);
			this.length += 1;
			this.position += 1;
		}
			
		public function writeUTF(val:*):void {
			val = "" + val;
			var arr:Array = System.stringToBytes(val);
			this.writeUInt(arr.length);
			for (var i:int = 0; i < arr.length; i++) {
				this.bytes.splice(this.position, 0, arr[i]);
				this.position++;
			}
			this.length += arr.length;
		}
		
		public function writeUTFBytes(val:*, len:int):void {
			val = "" + val;
			var arr:Array = System.stringToBytes(val);
			for (var i:int = 0; i < len; i++) {
				if (i < arr.length)
					this.bytes.splice(this.position, 0, arr[i]);
				else
					this.bytes.splice(this.position, 0, 0);
				this.position++;
			}
			this.length += len;
		}
		
		public function writeBytes (b:VByteArray, start:* = null, len:* = null):void {
			start = +start&~0;
			len = +len&~0;
			var copy:Array = b.data;
			for (var i:int = start; i < copy.length && i < start + len; i++) {
				this.bytes.splice(this.position, 0, copy[i]);
				this.position++;
			}
			this.length += len;
		}
		
		public function writeByteArray(byteArray:Array):void {
			this.bytes = this.bytes.concat(byteArray);
			this.length += byteArray.length;
		}
			
		public function readBoolean():Boolean {
			var val:Boolean = this.bytes[this.position] == 0 ? false : true;
			this.position += 1;
			return val;
		}
		
		public function readInt():Number {
			var val:Number = this.readUInt();
			if (val % 2 == 1) {
				val = Math.floor(val / 2);
				val = ~val;
			}
			else {
				val = Math.floor(val / 2);
			}
			return val;
		}
		
		
		public function readUInt():Number {
			var val:Number = 0;
			val += this.bytes[this.position] & 0x7F;
			if (this.bytes[this.position] >> 7) {
				this.position++;
				val += (this.bytes[this.position] & 0x7F) << 7;
				if (this.bytes[this.position] >> 7) {
					this.position++;
					val += (this.bytes[this.position] & 0x7F) << 14;
					if (this.bytes[this.position] >> 7) {
						this.position++;
						val += (this.bytes[this.position] & 0x7F) << 21;
						if (this.bytes[this.position] >> 7) {
							this.position++;
							val += ((this.bytes[this.position] & 0x7F) << 24) * 16;
							if (this.bytes[this.position] >> 7) {
								this.position++;
								val += ((this.bytes[this.position] & 0x7F) << 24) * 0x800;
								if (this.bytes[this.position] >> 7) {
									this.position++;
									val += (this.bytes[this.position] << 24) * 0x40000;
								}
							}
						}
					}
				}
			}
			this.position++;
			return val;
		}
		
		public function readByte():Number {
			var val:Number = this.bytes[this.position];
			this.position += 1;
			return val;
		}
		
		public function readShort():Number {
			var val:Number;
			var bytes:Array = this.bytes;
			if (this.big) {
				val = bytes[this.position] | bytes[this.position + 1] << 8;
			}
			else {
				val = bytes[this.position] << 8 | bytes[this.position + 1];
			}
			if (val > (1 << 15))
				val = val - (1 << 16);
			this.position += 2;
			return val;
		}
		
		public function readUTF():String {
			var len:int = this.readUInt();
			var val:String = System.numberToString(this.bytes.slice(this.position, this.position + len));
			this.position += len;
			return val;
		}
		
		public function readUTFBytes(len:*):String {
			len = +len&~0;
			var val:String = System.numberToString(this.bytes.slice(this.position, this.position + len));
			this.position += len;
			return val;
		}
		
		public function get bytesAvailable():Number {
			return this.length - this.position;
		}
		
		public function get data():Array {
			return this.bytes;
		}
		
		public function toString():String {
			var str:String = "";
			for (var i:int = 0; i < this.bytes.length; i++) {
				str += this.bytes[i] + (i < this.bytes.length - 1 ? "," : "");
			}
			return str;
		};
	}
}