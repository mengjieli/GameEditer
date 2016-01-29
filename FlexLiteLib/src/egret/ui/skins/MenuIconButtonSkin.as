package egret.ui.skins
{
	import flash.events.MouseEvent;
	
	import egret.components.Group;
	import egret.components.Skin;
	import egret.layouts.HorizontalLayout;
	import egret.layouts.VerticalAlign;

	/**
	 * 有下拉菜单的图标按钮的皮肤 
	 * @author 雷羽佳
	 * 
	 */	
	public class MenuIconButtonSkin extends Skin
	{
		[Embed(source="/egret/ui/skins/assets/dropDownListBtn/bg.png")]
		private var uiRes:Class;
		
		public function MenuIconButtonSkin()
		{
			super();
			this.states = ["up","over","down","disabled"];
		}
		public var iconButton:RollOverButton
		public var menuButton:RollOverButton;
		override protected function createChildren():void
		{
			super.createChildren();
			var group:Group = new Group();
			var hL:HorizontalLayout = new HorizontalLayout();
			hL.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
			hL.gap = 0;
			group.layout = hL;
			this.addElement(group);
			
			iconButton = new RollOverButton();
			iconButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			iconButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			group.addElement(iconButton);
			
			menuButton = new RollOverButton();
			menuButton.skinName = MenuButtonSkin;
			menuButton.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			menuButton.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			menuButton.addEventListener(MouseEvent.CLICK,menuButtonClickHandler);
			group.addElement(menuButton);
			
		}
		
		protected function menuButtonClickHandler(event:MouseEvent):void
		{
			event.stopPropagation();
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			iconButton.keepOver = false;
			menuButton.keepOver = false;
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			iconButton.keepOver = true;
			menuButton.keepOver = true;
		}
		
		override protected function commitCurrentState():void
		{
			super.commitCurrentState();
			if(currentState == "disabled")
			{
				iconButton.enabled = false;
			}else
			{
				iconButton.enabled = true;
			}
		}
	}
}
import egret.ui.components.IconButton;

class RollOverButton extends IconButton
{
	public function RollOverButton()
	{
		super();
	}
	
	private var _keepOver:Boolean = false;
	/**
	 * 强制显示over状态
	 */		
	public function get keepOver():Boolean
	{
		return _keepOver;
	}
	
	public function set keepOver(value:Boolean):void
	{
		if(_keepOver==value)
			return;
		_keepOver = value;
		invalidateSkinState();
	}
	
	override protected function getCurrentSkinState():String
	{
		if(enabled&&_keepOver && super.getCurrentSkinState() != "down")
		{
			return "over";
		}
		return super.getCurrentSkinState();
	}
}