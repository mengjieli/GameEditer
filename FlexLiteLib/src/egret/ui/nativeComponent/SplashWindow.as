package egret.ui.nativeComponent
{
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	
	import egret.utils.AppRenderMode;
	
	/**
	 * 登陆加载页悬浮窗
	 * @author 雷羽佳
	 */
	public class SplashWindow extends NativeWindow
	{
		private var bg:Bitmap;
		public function SplashWindow(bgCls:Class,bgCls_r:Class)
		{
			var option:NativeWindowInitOptions = new NativeWindowInitOptions();
			option.systemChrome = NativeWindowSystemChrome.NONE;
			option.transparent = true;
			option.type = NativeWindowType.LIGHTWEIGHT;
			if(AppRenderMode.renderMode)
				option.renderMode = AppRenderMode.renderMode;
			option.resizable = false;
			option.minimizable = false;
			option.maximizable = false;
			super(option);
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			if(stage.contentsScaleFactor==1)
			{
				bg = new bgCls() as Bitmap;
			}
			else
			{
				bg = new bgCls_r() as Bitmap;
				bg.scaleX = 0.5;
				bg.scaleY = 0.5;
			}
			this.stage.addChild(bg);
			this.width = bg.width;
			this.height = bg.height;
		}
		
		override public function activate():void
		{
			this.x = Capabilities.screenResolutionX/2-this.width/2;
			this.y = Capabilities.screenResolutionY/2-this.height/2;
			super.activate();
		}
	}
}