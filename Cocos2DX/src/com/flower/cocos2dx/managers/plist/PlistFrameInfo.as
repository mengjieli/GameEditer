package com.flower.cocos2dx.managers.plist
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.managers.texture.Texture2D;
	import com.jc.utils.XMLElement;

	/**
	 *plist单个资源信息 
	 * @author MengJie.Li
	 * 
	 */	
	public class PlistFrameInfo
	{
		/**名称*/
		public var name:String;
		public var x:int; //资源在纹理中的位置
		public var y:int;
		public var width:int; //资源在纹理中的宽高，即有像素点的宽高
		public var height:int;
		public var offx:int; //偏移量，白边的偏移，由于TexturePacker打包自动去掉了白边
		public var offy:int;
		public var rot:Boolean;
		public var moveX:int; //有像素点的起始点
		public var moveY:int;
		public var sourceWidth:int;
		public var sourceHeight:int;
		public var texture:Texture2D;
		/**引用计数器*/
		public var count:int;
		
		public function PlistFrameInfo()
		{
		}
		
		public function initBuffer():void
		{
			count = 0;
		}
		
		public function cycle():void
		{
			texture = null;
			BufferPool.cycle(ClassName.PlistFrameInfo,this,maxBuffer);
		}
		
		/**
		 *解析单个资源的内容 
		 * @param xml
		 * 
		 */		
		public function decode(xml:XMLElement):void
		{
			var content:String;
			for(var i:int = 0; i < xml.list.length; i++)
			{
				if(xml.list[i].name == "key")
				{
					content = xml.list[i+1].value;
					while(content.indexOf("{") != -1)
					{
						content = content.slice(0,content.indexOf("{")) + content.slice(content.indexOf("{") + 1,content.length);
					}
					while(content.indexOf("}") != -1)
					{
						content = content.slice(0,content.indexOf("}")) + content.slice(content.indexOf("}") + 1,content.length);
					}
					if(xml.list[i].value == "frame")
					{
						x = int(content.split(",")[0]);
						y = int(content.split(",")[1]);
						width = int(content.split(",")[2]);
						height = int(content.split(",")[3]);
					}
					else if(xml.list[i].value == "rotated")
					{
						if(xml.list[i+1].name == "true")
							this.rot = true;
						else
							this.rot = false;
					}
					else if(xml.list[i].value == "offset")
					{
						offx = int(content.split(",")[0]);
						offy = int(content.split(",")[1]);
					}
					else if(xml.list[i].value == "sourceColorRect")
					{
						moveX = int(content.split(",")[0]);
						moveY = int(content.split(",")[1]);
					}
					else if(xml.list[i].value == "sourceSize")
					{
						sourceWidth = int(content.split(",")[0]);
						sourceHeight = int(content.split(",")[1]);
					}
					i++;
				}
			}
		}
		
		public static function create():PlistFrameInfo
		{
			return BufferPool.create(ClassName.PlistFrameInfo,PlistFrameInfo);
		}
		
		public static const maxBuffer:int = 100;
	}
}