package egret.ui.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import avmplus.getQualifiedClassName;
	
	import egret.core.BitmapSource;
	import egret.core.IAssetAdapter;
	import egret.core.ITexture;
	import egret.utils.FileUtil;
	import egret.utils.SharedMap;
	
	/**
	 * 
	 * @author dom
	 */
	public class RetinaAssetAdapter implements IAssetAdapter
	{
		public function RetinaAssetAdapter()
		{
		}
		
		
		private var sharedMap:SharedMap = new SharedMap();
		/**
		 * @inheritDoc
		 */	
		public function getAsset(source:Object, compFunc:Function, oldContent:Object):void
		{
			var content:Object = source;
			var data:Object;
			var className:String;
			if(source is Class)
			{
				className = getQualifiedClassName(source);
				data = sharedMap.get(className) as BitmapData;
				if(data)
				{
					compFunc(data,source);
					return;
				}
				content = new source();
			}
			if(content is Bitmap)
			{
				content = Bitmap(content).bitmapData;
				if(className)
				{
					sharedMap.set(className,content);
				}
			}
			if(content is BitmapSource||content is DisplayObject||content is BitmapData||content is ITexture)
			{
				compFunc(content,source);
			}
			else if(source is String||source is ByteArray)
			{
				if(source is String)
					data = sharedMap.get(String(source));
				if(data)
					compFunc(data,source);
				else
				{
					var url:String = source as String;
					if(url&&(url.charAt(0)=="/"||url.charAt(0)=="\\"))
					{
						url = url.substring(1);
					}
					var bytes:ByteArray = url?FileUtil.openAsByteArray(url):null;
					if(bytes)
					{
						var index:int = url.lastIndexOf(".");
						var retinaUrl:String = url.substring(0,index)+"_r"+url.substring(index);
						var retinaBytes:ByteArray = FileUtil.openAsByteArray(retinaUrl);
						data = new BitmapSource(bytes,retinaBytes);
						sharedMap.set(String(source),data);
						compFunc(data,source);
					}
					else
					{ 
						var loader:Loader = new Loader;
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function(event:Event):void{
							compFunc(source,source);
						});
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(event:Event):void{
							if(loader.content is Bitmap)
							{
								var bitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
								if(source is String)
								{
									sharedMap.set(String(source),bitmapData);
								}
								compFunc(bitmapData,source);
							}
							else
							{
								compFunc(loader.content,source);
							}
						});
						if(source is String)
							loader.load(new URLRequest(source as String));
						else
							loader.loadBytes(source as ByteArray);
					}
				}
			}
			else
			{
				compFunc(content,source);
			}
		}
	}
}