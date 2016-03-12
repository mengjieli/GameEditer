package com.flower.cocos2dx.managers
{
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.managers.plist.PlistFrameInfo;
	import com.flower.cocos2dx.managers.plist.PlistInfo;

	/**
	 *plist资源管理器
	 * @author MengJie.Li
	 * 
	 */	
	public class PlistManager
	{
		private var plist:Vector.<PlistInfo> = new Vector.<PlistInfo>();
		
		public function PlistManager()
		{
			if(classLock == true)
			{
				DebugInfo.debug("无法创建对象ResourceManager，此类为单例模式，请访问ResourceManager.getInstance()",DebugInfo.WARN);
				return;
			}
		}
		
		/**
		 *获取Plist图片信息 
		 * @param name
		 * @return 
		 * 
		 */		
		public function getPlistFrame(name:String):PlistFrameInfo
		{
			var len1:int = this.plist.length;
			var len2:int;
			for(var i:int = 0; i < len1; i++)
			{
				len2 = this.plist[i].frames.length;
				for(var j:int = 0; j < len2; j++)
				{
					if(this.plist[i].frames[j].name == name)
					{
						return this.plist[i].frames[j];
					}
				}
			}
			return null;
		}
		
		/**
		 *获取Plist信息 
		 * @param url plist地址
		 * @return 
		 * 
		 */		
		public function getPlist(url:String):PlistInfo
		{
			var len1:int = this.plist.length;
			for(var i:int = 0; i < len1; i++)
			{
				if(this.plist[i].url == url)
				{
					return this.plist[i];
				}
			}
			return null;
		}
		
		/**
		 *添加Plist文件，读取解析Plist内容，同时会上传贴图，贴图计数器为0，但不会被删除，
		 * 只有贴图使用过后并减少计数器到0才会删除，或则垃圾回收机制会自动删除
		 * @param url String plist地址
		 * @return 返回对应的plist文件
		 */		
		public function addPlist(url:String):PlistInfo
		{
			for(var i:int = 0; i < plist.length; i++)
			{
				if(plist[i].url == url)
				{
					return plist[i];
				}
			}
			var info:PlistInfo = PlistInfo.create();
			info.decode(url);
			info.loadResource();
			DebugInfo.debug("|加载plist| " + url,DebugInfo.TIP); 
			plist.push(info);
			return info;
		}
		
		/**
		 *删除plist文件，只会删除plist信息的解析部分，如果贴图的计数器为0则会删除贴图，否则不会影响贴图
		 * @param url
		 * 
		 */		
		public function delPlist(url:String):void
		{
			var info:PlistInfo;
			for(var i:int = 0; i < plist.length; i++)
			{
				if(plist[i].url == url)
				{
					info = plist.splice(i,1)[0];
					break;
				}
			}
			if(!info)
			{
				DebugInfo.debug("|删除plist文件| 没有找到对应的plist信息 ",DebugInfo.WARN);
				return;
			}
			info.cycle();
			DebugInfo.debug("|删除plist| " + url,DebugInfo.TIP); 
		}
		///////////////////////////////////////////////////////////////////////////////////////static//////////////////////////////////////////////////////////////////////////////////////
		private static var ist:PlistManager;
		private static var classLock:Boolean = true;
		public static function getInstance():PlistManager
		{
			if(!ist)
			{
				classLock = false;
				ist = new PlistManager();
				classLock = true;
			}
			return ist;
		}
	}
}