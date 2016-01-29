package main.net
{
	import flash.utils.ByteArray;

	public class MyByteArray
	{
		public var bytes:Array;
		private var big:Boolean;
		public var position:int;
		public var length:int;
		
		public function MyByteArray(big:Boolean=true)
		{
			this.bytes = [];
			this.big = big;
			this.position = 0;
			this.length = 0;
		}
		
		public function initFromArray(list:Array):void {
			this.bytes = list;
			this.position = 0;
			this.length = list.length;
		}
		
		public function writeIntV(val:Number):void
		{
			if(val >= 0)
			{
				val *= 2;
			}
			else
			{
				val = ~val;
				val *= 2;
				val ++;
			}
			this.writeUIntV(val);
		}
		
		public function getArrayString():String {
			var str:String = "[";
			for(var i:Number = 0; i < this.bytes.length; i++) {
				str += this.bytes[i] + (i < this.bytes.length-1?",":"");
			}
			str += "]";
			return str;
		}
		
		public function writeUIntV(val:Number):void
		{
			var flag:Boolean = false;
			val = val<0?-val:val;
			var val2:Number = 0;
			if(val >= 0x10000000)
			{
				val2 = val/0x10000000;
				val = val&0xFFFFFFF;
				flag = true;
			}
			
			if(flag || val>>7) //第一位
			{
				this.bytes.splice(this.position,0,0x80|val&0x7F);
				this.position++;
				this.length++;
			}
			else
			{
				this.bytes.splice(this.position,0,val&0x7F);
				this.position++;
				this.length++;
			}
			
			if(flag || val>>14) //第二位
			{
				this.bytes.splice(this.position,0,0x80|(val>>7)&0x7F);
				this.position++;
				this.length++;
			}
			else if(val>>7)
			{
				this.bytes.splice(this.position,0,(val>>7)&0x7F);
				this.position++;
				this.length++;
			}
			
			if(flag || val>>21) //第三位
			{
				this.bytes.splice(this.position,0,0x80|(val>>14)&0x7F);
				this.position++;
				this.length++;
			}
			else if(val>>14)
			{
				this.bytes.splice(this.position,0,(val>>14)&0x7F);
				this.position++;
				this.length++;
			}
			
			if(flag || val>>28) //第四位
			{
				this.bytes.splice(this.position,0,0x80|(val>>21)&0x7F);
				this.position++;
				this.length++;
			}
			else if(val>>21)
			{
				this.bytes.splice(this.position,0,(val>>21)&0x7F);
				this.position++;
				this.length++;
			}
			
			if(flag)
			{
				this.writeUIntV(Math.floor(val2));
			};
		}
		
		public function writeInt(val:Number):void
		{
			var flag:Boolean = val>=0?true:false;
			val = val>=0?val:(2147483648+val);
			val = val&0xFFFFFFFF;
			if(big)
			{
				bytes.splice(this.position,0,(!flag?128:0) + (val>>24));
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val&0xFF);
			}
			else
			{
				bytes.splice(this.position,0,val&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,(!flag?128:0) + (val>>24));
			}
			this.length += 4;
			position += 4;
		}
		
		public function writeInt64(val:Number):void
		{
			var flag:Boolean = val>=0?true:false;
			val = val>=0?val:(9223372036854776001+val);
			val = val&0xFFFFFFFF;
			if(big)
			{
				bytes.splice(this.position,0,(!flag?128:0) + (val>>56));
				bytes.splice(this.position,0,val>>48&0xFF);
				bytes.splice(this.position,0,val>>40&0xFF);
				bytes.splice(this.position,0,val>>32&0xFF);
				bytes.splice(this.position,0,val>>24&0xFF);
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val&0xFF);
			}
			else
			{
				bytes.splice(this.position,0,val&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,val>>24&0xFF);
				bytes.splice(this.position,0,val>>32&0xFF);
				bytes.splice(this.position,0,val>>40&0xFF);
				bytes.splice(this.position,0,val>>48&0xFF);
				bytes.splice(this.position,0,(!flag?128:0) + (val>>56));
			}
			this.length += 8;
			position += 8;
		}
		
		public function writeByte(val:int):void
		{
			bytes.splice(this.position,0,val);
			this.length += 1;
			position += 1;
		}
		
		public function writeBoolean(val:Boolean):void
		{
			bytes.splice(this.position,0,val==true?1:0);
			this.length += 1;
			position += 1;
		}
		
		public function writeUnsignedInt(val:uint):void
		{
			if(big)
			{
				bytes.splice(this.position,0,val>>24);
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val&0xFF);
			}
			else
			{
				bytes.splice(this.position,0,val&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val>>16&0xFF);
				bytes.splice(this.position,0,val>>24);
			}
			this.length += 4;
			position += 4;
		}
		
		public function writeShort(val:int):void
		{
			val = val&0xFFFF;
			if(big)
			{
				bytes.splice(this.position,0,val>>8&0xFF);
				bytes.splice(this.position,0,val&0xFF);
			}
			else
			{
				bytes.splice(this.position,0,val&0xFF);
				bytes.splice(this.position,0,val>>8&0xFF);
			}
			this.length += 2;
			position += 2;
		}
		
		public function writeUnsignedShort(val:Number):void
		{
			val = val&0xFFFF;
			if(this.big)
			{
				this.bytes.splice(this.position,0,val>>8&0xFF);
				this.bytes.splice(this.position,0,val&0xFF);
			}
			else
			{
				this.bytes.splice(this.position,0,val&0xFF);
				this.bytes.splice(this.position,0,val>>8&0xFF);
			}
			this.length += 2;
			this.position += 2;
		}
		
		public function writeUTF(val:String):void
		{
			var arr:Array = this.stringToBytes(val);
			writeShort(arr.length);
			for(var i:int = 0; i < arr.length; i++)
			{
				bytes.splice(this.position,0,arr[i]);
				position ++;
			}
			this.length += arr.length;
		}
		
		public function writeUTFV(val:String):void
		{
			var arr:Array = this.stringToBytes(val);
			this.writeUIntV(arr.length);
			for(var i:int = 0; i < arr.length; i++)
			{
				this.bytes.splice(this.position,0,arr[i]);
				this.position ++;
			}
			this.length += arr.length;
		}
		
		public function writeUTFBytes(val:String,len:int):void
		{
			var arr:Array = this.stringToBytes(val);
			for(var i:int = 0; i < len; i++)
			{
				if(i < arr.length) bytes.splice(this.position,0,arr[i]);
				else bytes.splice(this.position,0,0);
				position ++;
			}
			this.length += len;
		}
		
		public function writeBytes(b:MyByteArray,start:int=0,len:int=0):void
		{
			var copy:Array = b.getData();
			for(var i:int = start; i < copy.length && i < start + len; i++)
			{
				bytes.splice(this.position,0,copy[i]);
				this.position++;
			}
			this.length += len;
		}
		
		public function readBoolean():Boolean
		{
			var val:Boolean = this.bytes[this.position]==0?false:true;
			this.position += 1;
			return val;
		}
		
		public function readIntV():Number
		{
			var val:Number = this.readUIntV();
			if(val%2 == 1)
			{
				val = Math.floor(val/2);
				val = ~val;
			}
			else
			{
				val = Math.floor(val/2);
			}
			return val;
		}
		
		public function readUIntV():Number
		{
			var val:Number = 0;
			val += this.bytes[this.position]&0x7F;
			if(this.bytes[this.position]>>7)
			{
				this.position ++;
				val += (this.bytes[this.position]&0x7F)<<7;
				if(this.bytes[this.position]>>7)
				{
					this.position ++;
					val += (this.bytes[this.position]&0x7F)<<14;
					if(this.bytes[this.position]>>7)
					{
						this.position ++;
						val += (this.bytes[this.position]&0x7F)<<21;
						if(this.bytes[this.position]>>7)
						{
							this.position ++;
							val += ((this.bytes[this.position]&0x7F)<<24)*16;
							if(this.bytes[this.position]>>7)
							{
								this.position ++;
								val += ((this.bytes[this.position]&0x7F)<<24)*0x800;
								if(this.bytes[this.position]>>7)
								{
									this.position ++;
									val += (this.bytes[this.position]<<24)*0x40000;
								}
							}
						}
					}
				}
			}
			this.position ++;
			return val;
		}
		
		public function readInt():int
		{
			var val:int = 0;
			if(big)
			{
				val = bytes[this.position]|bytes[this.position+1]<<8|bytes[this.position+2]<<16|bytes[this.position+3]<<24;
			}
			else
			{
				val = bytes[this.position+3]|bytes[this.position+2]<<8|bytes[this.position+1]<<16|bytes[this.position]<<24;
			}
			//if(val > (1<<31)) val = val - (1<<32);
			this.position += 4;
			return val;
		}
		
		public function readInt64():int
		{
			var val:int = 0;
			if(big)
			{
				val = bytes[this.position]|bytes[this.position+1]<<8|bytes[this.position+2]<<16|bytes[this.position+3]<<24|bytes[this.position+4]<<32|bytes[this.position+5]<<40|bytes[this.position+6]<<48|bytes[this.position+7]<<56;
			}
			else
			{
				val = bytes[this.position+7]|bytes[this.position+6]<<8|bytes[this.position+5]<<16|bytes[this.position+4]<<24|bytes[this.position+3]<<32|bytes[this.position+2]<<40|bytes[this.position+1]<<48|bytes[this.position]<<56;
			}
			//if(val > (1<<31)) val = val - (1<<32);
			this.position += 8;
			return val;
		}
		
		public function readUnsignedInt():uint
		{
			var val:uint = 0;
			if(big)
			{
				val = bytes[this.position]|bytes[this.position+1]<<8|bytes[this.position+2]<<16|bytes[this.position+3]<<24;
			}
			else
			{
				val = bytes[this.position+3]|bytes[this.position+2]<<8|bytes[this.position+1]<<16|bytes[this.position]<<24;
			}
			this.position += 4;
			return val;
		}
		
		public function readByte():int
		{
			var val:int = this.bytes[this.position];
			this.position += 1;
			return val;
		}
		
		public function readShort():int
		{
			var val:int;
			if(big)
			{
				val = bytes[this.position]|bytes[this.position+1]<<8;
			}
			else
			{
				val = bytes[this.position]<<8|bytes[this.position+1];
			}
			
			if(val > (1<<15)) val = val - (1<<16);
			this.position += 2;
			return val;
		}
		
		public function readUnsignedShort():int
		{
			var val:int;
			if(this.big)
			{
				val = this.bytes[this.position]|this.bytes[this.position+1]<<8;
			}
			else
			{
				val = this.bytes[this.position]<<8|this.bytes[this.position+1];
			}
			
			if(val > (1<<15)) val = val - (1<<16);
			this.position += 2;
			return val;
		}
		
		public function readUTF():String
		{
			var len:int = readShort();
			var val:String = this.numberToString(this.bytes.slice(this.position,this.position+len));
			this.position += len;
			return val;
		}
		
		public function readUTFV():String
		{
			var len:Number = this.readUIntV();
			var val:String = this.numberToString(this.bytes.slice(this.position,this.position+len));
			this.position += len;
			return val;
		}
		
		public function readUTFBytes(len:int):String
		{
			var val:String = this.numberToString(this.bytes.slice(this.position,this.position+len));
			this.position += len;
			return val;
		}
		
		public function bytesAvailable():int
		{
			return this.length - this.position;
		}
		
		public function getData():Array
		{
			return bytes;
		}
		
		public function print():void
		{
			var str:String = "MyByteArray = ";
			for(var i:int = 0; i < bytes.length; i++)
			{
				str += bytes[i] + " ";
			}
//			CCLog.log(str);
		}
		
		public function numberToString(arr:Array):String {
			var bytes:ByteArray = new ByteArray();
			for(var i:Number = 0; i < arr.length; i++) {
				bytes.writeByte(arr[i]);
			}
			bytes.position = 0;
			return bytes.readUTFBytes(bytes.bytesAvailable);
		}
		
		public function stringToBytes(str:String):Array {
			var arr:Array = [];
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(str);
			bytes.position = 0;
			for(var i:Number = 0; i < bytes.length; i++) {
				arr.push(bytes.readUnsignedByte());
			}
			return arr;
		}
	}
}