package egret.ui.components
{
	import egret.components.AccordionGroup;
	import egret.core.ns_egret;
	import egret.ui.skins.AccordionButtonSkin;

	use namespace ns_egret;
	
	
	/**
	 * 折叠面板  
	 * @author 雷羽佳
	 * 
	 */	
	public class AccordionGroup extends egret.components.AccordionGroup
	{
		public function AccordionGroup()
		{
			super();
			this.accordionButtonSkinClass = AccordionButtonSkin;
			this.accordionButtonClass = IconToggleButton;
		}
	}
}