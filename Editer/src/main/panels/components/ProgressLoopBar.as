package main.panels.components
{
	import egret.components.Group;
	import egret.components.Rect;
	import egret.effects.animation.Animation;
	import egret.effects.animation.MotionPath;
	import egret.effects.animation.SimpleMotionPath;
	import egret.effects.easing.Linear;
	import egret.events.UIEvent;
	import egret.utils.callLater;
	
	/**
	 * 循环滚动条控件 
	 * @author 雷羽佳
	 */
	public class ProgressLoopBar extends Group
	{
		public function ProgressLoopBar()
		{
			this.addEventListener(UIEvent.UPDATE_COMPLETE,updateCompleteHandler);
		}
		
//		public var track:Rect;
//		public var thumb:Rect;
		
		
		private var track:Rect = new Rect();
		private var _bar:Rect = new Rect();
		override protected function createChildren():void
		{
			super.createChildren();
			track.strokeColor = 0x191e23; 
			track.strokeAlpha = 1;
			track.strokeWeight = 1;
			track.fillColor = 0x2f3943;
			track.left = 0;
			track.right = 0;
			track.top = 0;
			track.bottom = 0;
			this.addElement(track);
			
			_bar.fillColor = 0x335e87;
			_bar.includeInLayout = false;
			_bar.alpha = 0;
			this.addElement(_bar);
			
			var barMask:Rect = new Rect();
			barMask.fillColor = 0xff0000;
			barMask.left = barMask.right = barMask.top = barMask.bottom = 1;
			this.addElement(barMask);
			_bar.mask = barMask;
		}
		
		private var _animation:Animation;
		private function get animation():Animation
		{
			if(!_animation)
			{
				_animation = new Animation(barMotionUpdate);
				_animation.duration = 5000;
				_animation.easer = new Linear(0,1);
				_animation.repeatCount = 100000000;
				_animation.endFunction = playHandler;
			}
			return _animation;
		}
		
		
		private var barPrecentW:Number = 0.3;
		protected function updateCompleteHandler(event:UIEvent):void
		{
			if(_bar)
			{
				_bar.height = this.height-2;
				_bar.y = 1;
				_bar.width = this.width * barPrecentW;
				if(_isPlay)
				{
//					TweenLite.killTweensOf(_bar);
//					TweenLite.to(_bar,5,{x:_bg.width,onComplete:playHandler});
					animation.stop();
					animation.motionPaths =  new <MotionPath>[new SimpleMotionPath("x",_bar.x,track.width)];;
					animation.play();
				}
			}
		}
		
		private function barMotionUpdate(animation:Animation):void
		{
			_bar.x = animation.currentValue["x"];
		}
		
		public function play():void
		{
			_isPlay = true;
			this.alpha = 1;
			barPrecentW = 0.3;
			_bar.width = this.width * barPrecentW;
			_bar.alpha = 1;
			callLater(playHandler);
		}
		
		private var _isPlay:Boolean = false;
		private function playHandler(currentAnimation:Animation = null):void
		{
//			_bar.x = -_bar.width;
			animation.motionPaths = new <MotionPath>[new SimpleMotionPath("x",-_bar.width,track.width)];;
//			TweenLite.to(_bar,5,{x:_bg.width,onComplete:playHandler});
			animation.play();
		}
		
		public function stop():void
		{
			_isPlay = false;
			this.alpha = 1;
			barPrecentW = 0.3;
			_bar.width = this.width * barPrecentW;
			_bar.x = -_bar.width;
			_bar.alpha = 0;
//			TweenLite.killTweensOf(_bar);
			animation.stop();
		}
		
		public function complete():void
		{
			_isPlay = false;
			this.alpha = 1;
			animation.stop();
//			TweenLite.killTweensOf(_bar);
			barPrecentW = 1;
			_bar.width = this.width;
			_bar.x = 0;
			_bar.top = _bar.bottom = barPrecentW; 
			_bar.alpha = 1;
		}
		
		public function disabled():void
		{
			stop();
			this.alpha = 0.5;
		}
	}
}