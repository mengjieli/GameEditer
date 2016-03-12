package net.protocl
{
	
	public class MessageBase
	{
		public var MsgID:uint;
		public var extendInfo:Object;
		
		public function MessageBase(id:uint)
		{
			MsgID = id;
		}
		
		public function getString(func,p:String="")
		{
			return "";
		}
		
		public function encodeBool(bytes:MyByteArray,value:Boolean):void
		{
			bytes.writeBoolean(value);
		}
		
		public function encodeIntV(bytes:MyByteArray,value:Number):void
		{
			bytes.writeIntV(value);
		}
		
		public function encodeUIntV(bytes:MyByteArray,value:Number):void
		{
			bytes.writeUIntV(value);
		}
		
		public function encodeInt32(bytes:MyByteArray,value:int):void
		{
			bytes.writeInt(value);
		}
		
		public function encodeInt64(bytes:MyByteArray,value:Number):void
		{
			bytes.writeInt64(value);
			//bytes.writeInt(0);
			//bytes.writeInt(value);
		}
		
		public function encodeUInt32(bytes:MyByteArray,value:Number):void
		{
			bytes.writeUnsignedInt(value);
		}
		
		public function encodeByte(bytes:MyByteArray,value:Number):void
		{
			bytes.writeByte(value);
		}
		
		public function encodeShort(bytes:MyByteArray,value:Number):void
		{
			bytes.writeShort(value);
		}
		
		public function encodeString(bytes:MyByteArray,value:String):void
		{
			bytes.writeUTF(value);
		}
		
		public function encodeStringV(bytes:MyByteArray,value:String):void
		{
			bytes.writeUTFV(value);
		}
		
		public function encodeStringLength(bytes:MyByteArray,value:String,length:int):void
		{
			bytes.writeUTFBytes(value,length);
		}
		
		public function encodeMessage(bytes:MyByteArray,message:IMessage):void
		{
			var bts:MyByteArray = message.encode();
			bytes.writeBytes(bts,0,bts.length);
		}
		
		public function encodeRepeatBool(bytes:MyByteArray,values:Vector.<Boolean>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeBool(bytes,values[i]);
			}
		}
		
		public function encodeRepeatIntV(bytes:MyByteArray,values:Vector.<Number>):void
		{
			bytes.writeUIntV(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				this.encodeIntV(bytes,values[i]);
			}
		}
		
		public function encodeRepeatUIntV(bytes:MyByteArray,values:Vector.<Number>):void
		{
			bytes.writeUIntV(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				this.encodeUIntV(bytes,values[i]);
			}
		}
		
		public function encodeRepeatInt32(bytes:MyByteArray,values:Vector.<int>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeInt32(bytes,values[i]);
			}
		}
		
		public function encodeRepeatInt64(bytes:MyByteArray,values:Vector.<Number>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeInt64(bytes,values[i]);
			}
		}
		
		public function encodeRepeatUInt32(bytes:MyByteArray,values:Vector.<uint>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeUInt32(bytes,values[i]);
			}
		}
		
		public function encodeRepeatByte(bytes:MyByteArray,values:Vector.<int>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeByte(bytes,values[i]);
			}
		}
		
		
		public function encodeRepeatShort(bytes:MyByteArray,values:Vector.<int>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeShort(bytes,values[i]);
			}
		}
		
		public function encodeRepeatString(bytes:MyByteArray,values:Vector.<String>):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeString(bytes,values[i]);
			}
		}
		
		public function encodeRepeatStringV(bytes:MyByteArray,values:Vector.<String>):void
		{
			bytes.writeUIntV(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				this.encodeStringV(bytes,values[i]);
			}
		}
		
		public function encodeRepeatStringLength(bytes:MyByteArray,values:Vector.<String>,length:int):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeStringLength(bytes,values[i],length);
			}
		}
		
		public function encodeRepeatMessage(bytes:MyByteArray,values:*):void
		{
			bytes.writeShort(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				encodeMessage(bytes,values[i]);
			}
		}
		
		public function encodeRepeatMessageV(bytes:MyByteArray,values:*):void
		{
			bytes.writeUIntV(values.length);
			for(var i:int = 0; i < values.length; i++)
			{
				this.encodeMessage(bytes,values[i]);
			}
		}
		
		public function decodeBool(bytes:MyByteArray):Boolean
		{
			return bytes.readBoolean();
		}
		
		public function decodeIntV(bytes):Number
		{
			return bytes.readIntV();
		}
		
		public function decodeUIntV(bytes):Number
		{
			return bytes.readUIntV();
		}
		
		public function decodeInt32(bytes:MyByteArray):int
		{
			return bytes.readInt();
		}
		
		public function decodeInt64(bytes:MyByteArray):Number
		{
			//var n1:Number = bytes.readUnsignedInt();
			//var n2:Number = bytes.readUnsignedInt();
			return bytes.readInt64();//n1*2147483647 + n2;
		}
		
		public function decodeUInt32(bytes:MyByteArray):uint
		{
			return bytes.readUnsignedInt();
		}
		
		public function decodeByte(bytes:MyByteArray):int
		{
			return bytes.readByte();
		}
		
		public function decodeShort(bytes:MyByteArray):int
		{
			return bytes.readShort();
		}
		
		public function decodeStringV(bytes:MyByteArray):String
		{
			return bytes.readUTFV();
		}
		
		public function decodeString(bytes:MyByteArray):String
		{
			return bytes.readUTF();
		}
		
		public function decodeStringLength(bytes:MyByteArray,length:int):String
		{
			return bytes.readUTFBytes(length);
		}
		
		public function decodeMessage(bytes:MyByteArray,msg:*):*
		{
			msg.decode(bytes);
			return msg;
		}
		
		public function decodeRepeatBool(bytes:MyByteArray,value:Vector.<Boolean>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeBool(bytes));
			}
		}
		
		public function decodeRepeatIntV(bytes:MyByteArray,value:Vector.<Number>):void
		{
			var len:int = bytes.readUIntV();
			for(var i:int = 0; i < len; i++)
			{
				value.push(this.decodeIntV(bytes));
			}
		}
		
		public function decodeRepeatUIntV(bytes:MyByteArray,value:Vector.<Number>):void
		{
			var len:int = bytes.readUIntV();
			for(var i:int = 0; i < len; i++)
			{
				value.push(this.decodeUIntV(bytes));
			}
		}
		
		public function decodeRepeatInt32(bytes:MyByteArray,value:Vector.<int>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeInt32(bytes));
			}
		}
		
		public function decodeRepeatInt64(bytes:MyByteArray,value:Vector.<Number>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeInt64(bytes));
			}
		}
		
		public function decodeRepeatUInt32(bytes:MyByteArray,value:Vector.<uint>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeUInt32(bytes));
			}
		}
		
		public function decodeRepeatByte(bytes:MyByteArray,value:Vector.<int>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeByte(bytes));
			}
		}
		
		public function decodeRepeatShort(bytes:MyByteArray,value:Vector.<int>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeShort(bytes));
			}
		}
		
		public function decodeRepeatStringV(bytes:MyByteArray,value:Vector.<String>):void
		{
			var len:int = bytes.readUIntV();
			for(var i:int = 0; i < len; i++)
			{
				value.push(this.decodeStringV(bytes));
			}
		}
		
		public function decodeRepeatString(bytes:MyByteArray,value:Vector.<String>):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeString(bytes));
			}
		}
		
		public function decodeRepeatStringLength(bytes:MyByteArray,value:Vector.<String>,length:int):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				value.push(decodeStringLength(bytes,length));
			}
		}
		
		public function decodeRepeatMessage(bytes:MyByteArray,cls:Class,vect:*):void
		{
			var len:int = bytes.readShort();
			for(var i:int = 0; i < len; i++)
			{
				vect.push(decodeMessage(bytes,new cls()));
			}
		}
		
		public function decodeRepeatMessageV(bytes:MyByteArray,cls:Class,vect:*):void
		{
			var len:int = bytes.readUIntV();
			for(var i:int = 0; i < len; i++)
			{
				vect.push(this.decodeMessage(bytes,new cls()));
			}
		}
	}
}

