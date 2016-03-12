package com.flower.cocos2dx.managers.plist
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.managers.TextureManager;
	import com.flower.cocos2dx.managers.texture.Texture2D;
	import com.flower.cocos2dx.utils.FileUtils;
	import com.jc.utils.XMLElement;
	
	import cocos2dx.manager.CCSpriteFrameCache;

	/**
	 *PlistInfo 
	 * @author MengJie.Li
	 * 
	 */	
	public class PlistInfo
	{
		
		/**路径*/
		public var url:String;
		/**引用计数器*/
		public var count:int;
		/**纹理路径*/
		public var textureUrl:String;
		/**frame列表*/
		public var frames:Vector.<PlistFrameInfo>;
		/**纹理对象*/
		public var texture:Texture2D;
		/**宽*/
		public var width:int;
		/**高*/
		public var height:int;
		
		public function PlistInfo()
		{
		}
		
		/**
		 *初始化 ，给BufferPool调用，外部对象最好不要使用
		 * 
		 */		
		public function initBuffer():void
		{
			count = 0;
			if(!frames)
			{
				frames = new Vector.<PlistFrameInfo>();
			}
		}
		
		/**
		 *回收内存，给BufferPool调用 ，外部对象最好不要使用
		 * 
		 */		
		public function cycleBuffer():void
		{
			while(frames.length)
			{
				frames.pop().cycle();
			}
			//如果贴图还未被使用，则删除贴图，回收资源
			if(texture.getCount() == 0)
			{
				TextureManager.getInstance().delTexture(texture);
			}
			texture = null;
		}
		
		/**
		 *回收内存，给外部对象调用
		 * 
		 */	
		public function cycle():void
		{
			BufferPool.cycle(ClassName.PlistInfo,this,maxBuffer);
		}
		
		/**
		 *获取单个图片信息 
		 * @param name 图片名称
		 * @return PlistFrameInfo
		 * 
		 */		
		public function getFrame(name:String):PlistFrameInfo
		{
			var len:int = this.frames.length;
			for(var i:int = 0; i < len; i++)
			{
				if(this.frames[i].name == name) return this.frames[i];
			}
			return null;
		}
		
		/**
		 *解析plist资源 
		 * @param url
		 * 
		 */		
		public function decode(url:String):void
		{
			this.url = url;
			var content:String = FileUtils.readFile(url);
			var xml:XMLElement = new XMLElement();
			xml.decode(content);
			xml = xml.list[0];
			var reslist:XMLElement;
			var attributes:XMLElement;
			for(var i:int = 0; i < xml.list.length; i++)
			{
				if(xml.list[i].name == "key")
				{
					if(xml.list[i].value == "frames")
					{
						reslist = xml.list[i+1];
					}
					else if(xml.list[i].value == "metadata")
					{
						attributes = xml.list[i+1];
					}
					i++
				}
			}
			var frame:PlistFrameInfo;
			for(i = 0; i < reslist.list.length; i++)
			{
				if(reslist.list[i].name == "key")
				{
					frame = PlistFrameInfo.create();
					frame.name = reslist.list[i].value;
					frame.decode(reslist.list[i+1]);
					this.frames.push(frame);
					i++;
				}
			}
			for(i = 0; i < attributes.list.length; i++)
			{
				if(attributes.list[i].name == "key")
				{
					if(attributes.list[i].value == "realTextureFileName")
					{
						var end:int = -1;
						for(var c:int = 0; c < this.url.length; c++)
						{
							if(this.url.charAt(c) == "/")
							{
								end = c;
							}
						}
						if(end == -1) this.textureUrl = attributes.list[i+1].value;
						else this.textureUrl = this.url.slice(0,end+1) + attributes.list[i+1].value;
					}
					else if(attributes.list[i].value == "size")
					{
						var size:String = attributes.list[i+1].value;
						size = size.slice(1,size.length-1);
						width = Math.floor(size.split(",")[0]);
						height = Math.floor(size.split(",")[1]);
					}
					i++;
				}
			}
		}
		
		/**
		 *加载资源文件，在cocos2dx底层中加载texture2d
		 * 以及不必要的plist解析 
		 * 
		 */		
		public function loadResource():void
		{
			texture = TextureManager.getInstance().loadTexture(this.textureUrl,width,height);
			for(var i:int = 0; i < this.frames.length; i++)
			{
				this.frames[i].texture = texture;
			}
			CCSpriteFrameCache.getInstance().addSpriteFrames(this.url);
		}
		
		public static function create():PlistInfo
		{
			return BufferPool.create(ClassName.PlistInfo,PlistInfo);
		}
		
		public static const maxBuffer:int = 100;
	}
}