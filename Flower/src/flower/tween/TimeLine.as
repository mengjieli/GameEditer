package flower.tween
{
	import flower.core.Time;
	import flower.utils.EnterFrame;

	public class TimeLine
	{
		private var tweens:Array;
		
		public function TimeLine()
		{
			this.tweens = [];
		}
		
		private var lastTime:Number = -1;
		private var _currentTime:Number = 0;
		
		//获取总时间。
		public function get totalTime():Number {
			return this.getTotalTime();
		}
		
		private function getTotalTime():Number {
			if (this.invalidTotalTime == true) {
				return this._totalTime;
			}
			this.invalidTotalTime = true;
			var tweens:Array = this.tweens;
			var endTime:Number = 0;
			var time:Number;
			for (var i:int = 0, len:int = tweens.length; i < len; i++) {
				time = tweens[i].startTime + tweens[i].time;
				if (time > endTime) {
					endTime = time;
				}
			}
			this._totalTime = endTime*1000;
			return _totalTime;
		}
		
		private var _totalTime:Number = 0;
		private var invalidTotalTime:Boolean = true;
		
		public function $invalidateTotalTime():void {
			if (this.invalidTotalTime == false) {
				return;
			}
			this.invalidTotalTime = false;
		}
		
		private var _loop:Boolean = false;
		
		//是否循环播放
		public function get loop():Boolean {
			return this._loop;
		}
		
		public function set loop(value:Boolean):void {
			this._loop = value;
		}
		
		private var _isPlaying:Boolean = false;
		
		public function get isPlaying():Boolean {
			return this._isPlaying;
		}
		
		private function update(timeStamp:Number,gap:Number):Boolean {
			var totalTime:Number = this.getTotalTime();
			var lastTime:Number = this._currentTime;
			this._currentTime += timeStamp - this.lastTime;
			var currentTime:Number = -1;
			var loopTime:Number = 0;
			if (this._currentTime >= totalTime) {
				currentTime = this._currentTime % totalTime;
				loopTime = Math.floor(this._currentTime / totalTime);
				if (!this._loop) {
					this.$setPlaying(false);
				}
			}
			while (loopTime > -1) {
				if (loopTime && currentTime != -1) {
					this._currentTime = totalTime;
				}
				var calls:Array = this.calls;
				var call:*;
				var len:int = calls.length;
				for (i = 0; i < len; i++) {
					call = calls[i];
					if (call.time > lastTime && call.time <= this._currentTime || (call.time == 0 && lastTime == 0 && this._currentTime)) {
						call.callBack.apply(call.thisObj, call.args);
					}
				}
				var tweens:Array = this.tweens;
				var tween:Tween;
				len = tweens.length;
				for (var i:int = 0; i < len; i++) {
					tween = tweens[i];
					if (tween.$startTime + tween.$time > lastTime && tween.$startTime <= this._currentTime || (tween.$startTime == 0 && lastTime == 0 && this._currentTime)) {
						tween.$update(this._currentTime);
					}
				}
				loopTime--;
				if (loopTime == 0) {
					if (currentTime != -1) {
						lastTime = 0;
						this._currentTime = currentTime;
					}
				} else {
					if (loopTime) {
						lastTime = 0;
					}
				}
				if (this._loop == false) {
					break;
				}
			}
			this.lastTime = timeStamp;
			return true;
		}
		
		//播放。时间轴默认是停止的。调用此方法可以开始播放，也可以在停止后调用此方法继续播放。
		public function play():void {
			var now:Number = Time.currentTime;
			this.$setPlaying(true, now);
		}
		
		//暂停播放。
		public function stop():void {
			this.$setPlaying(false);
		}
		
		private function $setPlaying(value:Boolean, time:Number = 0):void {
			if (value) {
				this.lastTime = time;
			}
			if (this._isPlaying == value) {
				return;
			}
			this._isPlaying = value;
			if (value) {
				EnterFrame.add(this.update, this);
			} else {
				EnterFrame.del(this.update, this);
			}
		}
		
		//跳到指定的帧并播放。
		public function gotoAndPlay(time:Number):void {
			if (!this.tweens.length) {
				return;
			}
			time = +time | 0;
			time = time < 0 ? 0 : time;
			if (time > this.totalTime) {
				time = this.totalTime;
			}
			this._currentTime = time;
			var now:Number = Time.currentTime;
			this.$setPlaying(true, now);
		}
		
		//跳到指定的帧并停止。
		public function gotoAndStop(time:Number):void {
			if (!this.tweens.length) {
				return;
			}
			time = +time | 0;
			time = time < 0 ? 0 : time;
			if (time > this.totalTime) {
				time = this.totalTime;
			}
			this._currentTime = time;
			var now:Number = Time.currentTime;
			this.$setPlaying(false);
		}
		
		//添加Tween。
		public function addTween(tween:Tween):Tween {
			this.tweens.push(tween);
			tween.$setTimeLine(this);
			this.$invalidateTotalTime();
			return tween;
		}
		
		//移除Tween。
		public function removeTween(tween:Tween):void {
			var tweens:Array = this.tweens;
			for (var i:int = 0, len:int = tweens.length; i < len; i++) {
				if (tweens[i] == tween) {
					tweens.splice(i, 1)[0].$setTimeLine(null);
					this.$invalidateTotalTime();
					break;
				}
			}
			if (tweens.length == 0) {
				this.$setPlaying(false);
			}
		}
		
		private var calls:Array = [];
		
		//添加回调函数。
		public function call(time:Number, callBack:Function, thisObj:*=null, ...args):void {
			this.calls.push({"time": time, "callBack": callBack, "thisObj": thisObj, "args": args});
		}
	}
}