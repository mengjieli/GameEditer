package egret.utils
{
	import flash.desktop.NativeApplication;

	public class AppRenderMode
	{
		private static var _renderMode:String;
		public static function get renderMode():String
		{
			if(_renderMode)
				return _renderMode;
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;  
			var ns:Namespace = appXml.namespace();  
			_renderMode = appXml.ns::initialWindow[0].ns::renderMode[0];
			return _renderMode;
		}
	}
}