package main.panels.components
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import egret.components.Button;
	import egret.components.Group;
	/**
	 *横向分割容器
	 * </p>由左右两个显示项组成，以左项宽度为基准，右项填满剩余空间
	 * @author Grayness
	 */
	public class ClipItemPanel extends Group
	{
		public function ClipItemPanel()
		{
		}
		private var cliperW:Number = 4;//分割条宽度
		private var leftItem:ClipItem;
		private var rightItem:ClipItem;
		private var cliper:Button=new Button();
		/**
		 * 添加显示项
		 */		
		public function addClipItem(leftItem:ClipItem,rightItem:ClipItem):void
		{
			this.leftItem=leftItem;
			this.addElement(leftItem);
			this.addElement(cliper);
			cliper.addEventListener(MouseEvent.MOUSE_DOWN,cliperMouseEvent);
			this.rightItem=rightItem;
			this.addElement(rightItem);
		}
		/**
		 *重置容器 
		 */		
		public function reSet():void
		{
			this.leftItem=this.rightItem=null;
			this.removeAllElements();
		}
		protected override function measure():void
		{
			measuredMinWidth=measuredMinHeight=0;
		}
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			drawBackGround();
			leftItem.height=height;
			rightItem.height=height;
			cliper.height=height;
			cliper.width=cliperW;
			leftItem.x=0;
			cliper.x=leftItem.width;
			rightItem.x=cliper.x+cliper.width;
			rightItem.width=width-leftItem.width-cliper.width;
		}
		private var oldw:Number;
		private var oldx:Number;
		private function cliperMouseEvent(e:MouseEvent):void
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					oldw=leftItem.width;
					oldx=cliper.x;
					stage.addEventListener(MouseEvent.MOUSE_MOVE,cliperMouseEvent);
					stage.addEventListener(MouseEvent.MOUSE_UP,cliperMouseEvent);
					break;
				case MouseEvent.MOUSE_MOVE:
					var vx:Number=this.globalToLocal(new Point(e.stageX,0)).x-oldx;
					leftItem.width=oldw+vx;
					if(leftItem.width<10)
						leftItem.width=10;
					if(leftItem.width>width-10)
						leftItem.width=width-10;
					this.invalidateDisplayList();
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,cliperMouseEvent);
					stage.removeEventListener(MouseEvent.MOUSE_UP,cliperMouseEvent);
					break;
			}
		}
		private function drawBackGround():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1,0x222222);
			this.graphics.drawRect(0,0,width,height);
		}
	}
}
