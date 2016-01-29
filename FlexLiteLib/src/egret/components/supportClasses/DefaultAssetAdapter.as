package egret.components.supportClasses
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
	
	import egret.core.IAssetAdapter;
	import egret.core.ITexture;
	import egret.utils.SharedMap;
	
	
	/**
	 * 默认的IAssetAdapter接口实现
	 * @author dom
	 */
	public class DefaultAssetAdapter implements IAssetAdapter
	{
		/**
		 * 构造函数
		 */		
		public function DefaultAssetAdapter()
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
			if(content is DisplayObject||content is BitmapData||content is ITexture)
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
			else
			{
				compFunc(content,source);
			}
		}
	}
}