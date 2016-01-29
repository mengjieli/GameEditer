package egret.core
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	use namespace ns_egret;
	
	/**
	 * 支持Retina显示屏的位图数据源,它内部包含两个版本的位图资源。仅当使用到时才会被解压为BitmapData。
	 * 若窗口被从retina屏幕和普通屏幕间来回切换。它也会自动切换对应版本的数据源。
	 * @author dom
	 */
	public class BitmapSource
	{
		private static var helper:BitmapSourceHelper;
		/**
		 * 构造函数
		 * @param bitmapBytes 普通版本的位图数据，可以是字节流或嵌入的类定义。
		 * @param retinaBytes retina版本的位图数据，可以是字节流或嵌入的类定义。
		 * 
		 */			
		public function BitmapSource(bitmapBytes:Object,retinaBytes:Object)
		{
			if(!helper)
				helper = new BitmapSourceHelper();
			this.bitmapBytes = bitmapBytes;
			this.retinaBitmapBytes = retinaBytes;
		}
		
		private var bitmapBytes:Object;
		/**
		 * 这个变量用于保存位图数据的强引用，防止在外部读取数据前就被自动回收。
		 */	
		private var _bitmapData:BitmapData;
		private var bitmapDataMap:Dictionary = new Dictionary(true);
		/**
		 * 普通清晰度的位图数据
		 */
		public function get bitmapData():BitmapData
		{
			if(_bitmapData)
			{
				var bd:BitmapData = _bitmapData;
				_bitmapData = null;
				return bd;
			}
			return getBitmapData(bitmapDataMap);
		}
		
		private function getBitmapData(map:Dictionary):BitmapData
		{
			for(var key:* in map)
			{
				return key;
			}
			return null;
		}
		
		private var retinaBitmapBytes:Object;
		/**
		 * 这个变量用于保存位图数据的强引用，防止在外部读取数据前就被自动回收。
		 */		
		private var _retinaBitmapData:BitmapData;
		private var retinaBitmapDataMap:Dictionary = new Dictionary(true);
		
		/**
		 * retina高清位图数据
		 */
		public function get retinaBitmapData():BitmapData
		{
			if(_retinaBitmapData)
			{
				var bd:BitmapData = _retinaBitmapData;
				_retinaBitmapData = null
				return bd;
			}
			return getBitmapData(retinaBitmapDataMap);
		}
		
		/**
		 * 标记一个素材组件需要重绘，当位图加载完成后会自动调用asset的invalidateDisplayList()方法。
		 */		
		public function invalidateAsset(asset:IAsset):void
		{
			var bytes:Object;
			if(asset.contentsScaleFactor==1)
			{
				bytes = bitmapBytes||retinaBitmapBytes;
			}
			else
			{
				bytes = retinaBitmapBytes||bitmapBytes;
			}
			if(!bytes)
				return;
			if(bytes===retinaBitmapBytes)
			{
				if(getBitmapData(retinaBitmapDataMap))
				{
					asset.invalidateSize();
					asset.invalidateDisplayList();
				}
				else if(retinaAssetList)
				{
					if(retinaAssetList.indexOf(asset))
						retinaAssetList.push(asset);
				}
				else
				{
					retinaAssetList = [asset];
					helper.decodeBiampData(retinaBitmapBytes,onRetinaBitmapDataComp);
				}
			}
			else
			{
				if(getBitmapData(bitmapDataMap))
				{
					asset.invalidateSize();
					asset.invalidateDisplayList();
				}
				else if(assetList)
				{
					if(assetList.indexOf(asset)==-1)
						assetList.push(asset);
				}
				else
				{
					assetList = [asset];
					helper.decodeBiampData(bitmapBytes,onBitmapDataComp);
				}
			}
		}
		
		private var assetList:Array;
		
		private function onBitmapDataComp(bd:BitmapData):void
		{
			if(bd)
			{
				bitmapDataMap[bd] = true;
				_bitmapData = bd;
				for each(var asset:UIComponent in assetList)
				{
					asset.invalidateSize();
					asset.invalidateDisplayList();
				}
			}
			assetList = null;
		}
		
		private var retinaAssetList:Array;
		private function onRetinaBitmapDataComp(bd:BitmapData):void
		{
			if(bd)
			{
				retinaBitmapDataMap[bd] = true;
				_retinaBitmapData = bd;
				for each(var asset:UIComponent in retinaAssetList)
				{
					asset.invalidateSize();
					asset.invalidateDisplayList();
				}
			}
			
			retinaAssetList = null;
		}
	}
}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.ImageDecodingPolicy;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

class BitmapSourceHelper
{
	
	public function BitmapSourceHelper()
	{
	}
	
	/**
	 * 读取字节流
	 */	
	public function openAsByteArray(path:String):ByteArray
	{
		var file:File = new File(File.applicationDirectory.resolvePath(path).nativePath);
		var fs:FileStream = new FileStream;
		try
		{
			fs.open(file,FileMode.READ);
		}
		catch(e:Error)
		{
			return null;
		}
		fs.position = 0;
		var bytes:ByteArray = new ByteArray();
		fs.readBytes(bytes);
		fs.close();
		return bytes;
	}
	
	private var callBackMap:Dictionary = new Dictionary();
	/**
	 * 解码位图数据
	 */	
	public function decodeBiampData(data:Object,callBack:Function):void
	{
		var bytes:ByteArray = data as ByteArray;
		if(bytes)
		{
			var loader:Loader = new Loader();
			callBackMap[loader] = callBack;
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComp);
			loader.loadBytes(bytes,loaderContext);
		}
		else if(data is Class)
		{
			var bd:BitmapData = Bitmap(new data()).bitmapData;
			callBack(bd);
		}
		else
		{
			callBack(null);
		}
	}
	/**
	 * 解码完成
	 */		
	private function onLoadComp(event:Event):void
	{
		var loader:Loader = (event.target as LoaderInfo).loader;
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComp);
		var bitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
		var callBack:Function = callBackMap[loader];
		delete callBackMap[loader];
		callBack(bitmapData);
	}
	
	
}