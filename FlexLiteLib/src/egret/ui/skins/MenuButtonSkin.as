package egret.ui.skins
{
	import egret.components.Group;
	import egret.components.Skin;
	import egret.components.UIAsset;
	import egret.core.BitmapSource;
	
	/**
	 * 菜单按钮
	 * @author 雷羽佳
	 */
	public class MenuButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/menuBtn/btnBgNormal.png")]
		private var uiNormalRes:Class;
		[Embed(source="/egret/ui/skins/assets/menuBtn/btnBgHover.png")]
		private var uiHoverRes:Class;
		[Embed(source="/egret/ui/skins/assets/menuBtn/btnBgDown.png")]
		private var uiDownRes:Class;
		[Embed(source="/egret/ui/skins/assets/menuBtn/iconMenu.png")]
		private var iconRes:Class;
		[Embed(source="/egret/ui/skins/assets/menuBtn/iconMenu_r.png")]
		private var iconRes_r:Class;
	
		public function MenuButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
			this.minHeight = 17;
			this.minWidth =17;
		}
		
		private var group:Group;
		private var uiAsset:UIAsset;
		private var icon:UIAsset;
		override protected function createChildren():void
		{
			super.createChildren();
			group = new Group();
			group.percentHeight = 100;
			group.percentWidth = 100;
			group.alpha = 1;
			this.addElement(group);
			
			uiAsset = new UIAsset();
			uiAsset.top = uiAsset.left = uiAsset.right = uiAsset.bottom = 0;
			uiAsset.source = uiNormalRes;
			group.addElement(uiAsset);
			
			icon = new UIAsset();
			icon.verticalCenter = 0;
			icon.horizontalCenter = 0;
			icon.source = new BitmapSource(iconRes,iconRes_r);
			group.addElement(icon);
			
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "disabled")
			{
				group.alpha = 0.5;
			}else
			{
				group.alpha = 1;
			}
			
			if(currentState == "disabled" || currentState == "up")
			{
				uiAsset.source = uiNormalRes;
			}else if(currentState == "over")
			{
				uiAsset.source = uiHoverRes;
			}else if(currentState == "down")
			{
				uiAsset.source = uiDownRes;
			}
		}
	}
}