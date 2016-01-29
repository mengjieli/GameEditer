package egret.ui.components
{
	import flash.desktop.NativeApplication;
	
	import egret.components.Group;
	import egret.components.Label;
	import egret.components.UIAsset;
	import egret.layouts.HorizontalAlign;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;
	import egret.managers.Translator;
	import egret.ui.utils.EgretCopyRight;
	import egret.utils.AppVersion;

	/**
	 * 关于窗体 
	 * @author featherJ
	 * 
	 */	
	public class AboutWindow extends Window
	{
		public function AboutWindow()
		{
			super();
			this.title = Translator.getText("AboutWindow.Title");
			this.resizable = false;
		}
		
		private var _icon:String = "";
		public function get icon():String
		{
			return _icon;
		}
		public function set icon(value:String):void
		{
			_icon = value;
			if(iconDisplay)
			{
				iconDisplay.source = _icon;
			}
		}
		private var _version:String = "";
		/**
		 * 版本标签，如 “版本：{0} beta”
		 */		
		public function get version():String
		{
			return _version;
		}
		
		public function set version(value:String):void
		{
			_version = value;
			if(versionDisplay && _version)
			{
				versionDisplay.text = Translator.getText(_version,[AppVersion.currentVersion]);
			}
		}
		
		/**
		 * 程序图标
		 */
		public var iconDisplay:UIAsset;
		
		/**
		 * 版本号文本显示对象
		 */
		private var versionDisplay:Label;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var hGroup:Group = new Group();
			var hL:HorizontalLayout = new HorizontalLayout();
			hL.gap = 30;
			hL.verticalAlign = VerticalAlign.TOP;
			hL.horizontalAlign = HorizontalAlign.JUSTIFY;
			hGroup.layout = hL;
			hGroup.left = hGroup.right = 20;
			hGroup.top = hGroup.bottom = 40;
			
			this.addElement(hGroup);
			
			iconDisplay = new UIAsset();
			iconDisplay.source = _icon;
			hGroup.addElement(iconDisplay);
			
			var group:Group = new Group();
			hGroup.addElement(group);
			
			var appTitle:Label = new Label();
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;  
			var ns:Namespace = appXml.namespace();  
			appTitle.text = appXml.ns::filename[0].toString();  
			group.addElement(appTitle);
			appTitle.size = 26;
			
			versionDisplay = new Label();
			versionDisplay.top = 75;
			versionDisplay.text = Translator.getText("AboutWindow.Version",[AppVersion.currentVersion]);
			if(version)
			{
				versionDisplay.text = Translator.getText(_version,[AppVersion.currentVersion]);
			}
			group.addElement(versionDisplay);
			
			var copyright:Label = new Label();
			copyright.top = 100;
			copyright.text = EgretCopyRight.copyRight;
			group.addElement(copyright);
		}
	}
}