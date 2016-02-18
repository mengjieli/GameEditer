package view
{
	import flash.events.MouseEvent;
	
	import egret.components.Group;
	import egret.components.UIAsset;
	import egret.core.UIComponent;
	import egret.layouts.HorizontalLayout;
	import egret.ui.components.IconButton;
	import egret.ui.skins.IconButtonSkin;
	
	import extend.ui.DragManager;

	public class ViewEditerToolBar extends Group
	{
		public function ViewEditerToolBar()
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.verticalAlign = "middle";
			layout.paddingLeft = 10;
			layout.gap = 10;
			this.layout = layout;
		}
		
		private var _data:XMLList;
		/**
		 *设置数据源 
		 */		
		public  function set dataProvider(v:XMLList):void
		{
			_data=v;
			this.invalidateProperties();
		}
		
		protected override  function commitProperties():void
		{
			super.commitProperties();
			for each(var item:XML in _data)
			{
				if(item.@type&&item.@type=="spliter")
				{
					var spliter:UIComponent=new UIComponent();
					spliter.height = 20;
					spliter.width = 1;
					spliter.graphics.lineStyle(0,0,0);
					spliter.graphics.beginFill(0x222222);
					spliter.graphics.drawRect(0,0,1,20);
					spliter.graphics.endFill();
					this.addElement(spliter);
				}
				else
				{
					var button:IconButton=new IconButton();
					button.skinName=IconButtonSkin;
					button.icon=item.@icon.toString();
					button.toolTip=item.@tooltip.toString();
					button.name=item.@id.toString();
					button.addEventListener(MouseEvent.MOUSE_DOWN,itemClick);
					this.addElement(button);
				}
			}
		}
		
		private function itemClick(e:MouseEvent):void
		{
			var type:String = e.currentTarget.name.toString();
			DragManager.startDrag("Component",this,{"name":type},new UIAsset(e.currentTarget.icon));
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			graphics.clear();
			graphics.beginFill(0x29323b);
			graphics.drawRect(0,0,width,height+1);
			graphics.endFill();
		}
	}
}