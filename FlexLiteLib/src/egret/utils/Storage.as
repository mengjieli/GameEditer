package egret.utils
{
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	/**
	 * 数据本地持久化，实例化以后可以使用，
	 * @author featherJ
	 */
	public class Storage
	{
		private var cacheObject:Object = {};
		private var initialized:Boolean = false;
		
		private var _isDebug:Boolean = true;
		private var _path:String = "";
		private var _debugPath:String = "";
		private var _decrypt:Function;
		private var _encrypt:Function;
		
		/**
		 * 得到一个实例，如果已存在相同的path，则直接返回。否则将按照后续的参数进行创建并初始化之后返回。
		 * @param path 路径
		 * @param isDebug 是否为调试模式
		 * @param decrypt 解密方法 function(bytes:ByteArray):ByteArray
		 * @param encrypt 加密方法 function(bytes:ByteArray):ByteArray
		 * @return 
		 * 
		 */		
		public static function get(path:String = "data.dat", 
								   isDebug:Boolean = true, decrypt:Function = null, encrypt:Function = null):Storage
		{
			if(pathCache[path])
			{
				return pathCache[path];
			}else
			{
				var storage:Storage = new Storage(path,isDebug,decrypt,encrypt);
				return storage;
			}
		}
		
		private static var pathCache:Dictionary = new Dictionary();
		/**
		 * 构造函数
		 * @param path 路径
		 * @param isDebug 是否为调试模式
		 * @param decrypt 解密方法 function(bytes:ByteArray):ByteArray
		 * @param encrypt 加密方法 function(bytes:ByteArray):ByteArray
		 * 
		 */		
		public function Storage(path:String = "data.dat", 
								isDebug:Boolean = true, decrypt:Function = null, encrypt:Function = null):void
		{
			initialize(path,isDebug,decrypt,encrypt);
			
		}
		/**
		 * 初始化 
		 * @param path 路径
		 * @param isDebug 是否为调试模式
		 * @param decrypt 解密方法 function(bytes:ByteArray):ByteArray
		 * @param encrypt 加密方法 function(bytes:ByteArray):ByteArray
		 * 
		 */	
		private function initialize(path:String = "data.dat", 
										   isDebug:Boolean = true, decrypt:Function = null, encrypt:Function = null):void
		{
			if(initialized)
				return;
			
			if(pathCache[path])
			{
				throw new Error("路径为"+path+"的数据本地持久化已被使用，请更换存储路径。或直接用静态方法get获得");
			}else
			{
				pathCache[path] = this;
			}
			
			_isDebug = isDebug;
			_path = path;
			_decrypt = decrypt;
			_encrypt = encrypt;
			
			
			var cacheFile:File;
			var ext:String = FileUtil.getExtension(_path);
			if(ext)
			{
				var extIndex:int = _path.lastIndexOf(ext);
				_debugPath = _path.slice(0,extIndex-1) + "_debug."+ext;
			}else
			{
				_debugPath = _path+"_debug";
			}
			
			if(_isDebug)
			{
				cacheFile = new File(File.applicationStorageDirectory.nativePath).resolvePath(_debugPath);	
			}else
			{
				cacheFile = new File(File.applicationStorageDirectory.nativePath).resolvePath(_path);
			}
			if(cacheFile.exists)
			{
				var bytes:ByteArray = FileUtil.openAsByteArray(cacheFile.nativePath);
				if(bytes)
				{
					try
					{
						if(!_isDebug)
						{
							bytes.position = 0;
							bytes.uncompress();
							bytes.position = 0;
							if(_decrypt != null)
							{
								bytes = _decrypt(bytes);
							}
						}
						bytes.position = 0
						cacheObject = bytes.readObject();
					} 
					catch(error:Error) 
					{
						
					}
				}
			}
			if(!cacheObject) cacheObject = {};
			initialized = true;
		}
		
		/**
		 * 是否含有指定的键 
		 * @param key
		 * @return 
		 * 
		 */		
		public function has(key:String):Boolean
		{
			return cacheObject.hasOwnProperty(key);
		}
		
	
		/**
		 * 读取指定键的值
		 */		
		public function get(key:String):*
		{
			return cacheObject[key];
		}
		/**
		 * 为指定键写入值
		 */		
		public function set(key:String,value:*):void
		{
			cacheObject[key] = value;
			save();
		}
		
		/**
		 * 保存配置
		 */		
		private function save():void
		{
			if(!isSaving)
			{
				isSaving = true;
				setTimeout(saveHandler,100);
			}
		}
		
		private var isSaving:Boolean = false;
		private function saveHandler():void
		{
			isSaving = false;
			var cacheFile:File;
			var bytes:ByteArray = new ByteArray();
			var jsonStr:String;
			if(_isDebug)
			{
				cacheFile = new File(File.applicationStorageDirectory.nativePath).resolvePath(_debugPath);
				bytes.writeObject(cacheObject);
			}else
			{
				cacheFile = new File(File.applicationStorageDirectory.nativePath).resolvePath(_path);
				bytes.writeObject(cacheObject);
				bytes.position = 0;
				if(_encrypt != null)
				{
					bytes = _encrypt(bytes);
				}
				bytes.position = 0;
				bytes.compress();
			}
			FileUtil.save(cacheFile.nativePath,bytes);
		}
	}
}