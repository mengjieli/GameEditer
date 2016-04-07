package flower.tween
{
	dynamic public class EaseFunction {
		/**
		 * @language en_US
		 * Uniform type of easing.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 匀速缓动类型。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function None(t:Number):Number {
			return t;
		}
		
		/**
		 * @language en_US
		 * sine curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * sin 曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function SineEaseIn(t:Number):Number {
			return Math.sin((t - 1) * Math.PI * .5) + 1;
		}
		
		/**
		 * @language en_US
		 * sine curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * sin 曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function SineEaseOut(t:Number):Number {
			return Math.sin(t * Math.PI * .5);
		}
		
		/**
		 * @language en_US
		 * sine curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * sin 曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,NativeEaseInOutSine
		 */
		public static function SineEaseInOut(t:Number):Number {
			return Math.sin((t - .5) * Math.PI) * .5 + .5;
		}
		
		/**
		 * @language en_US
		 * sine curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * sin 曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,NativeEaseInOutSine
		 */
		public static function SineEaseOutIn(t:Number):Number {
			if (t < 0.5) {
				return Math.sin(t * Math.PI) * .5;
			}
			return Math.sin((t - 1) * Math.PI) * .5 + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 2 power curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 2 次方曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuadEaseIn(t:Number):Number {
			return t * t;
		}
		
		/**
		 * @language en_US
		 * x to the 2 power curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 2 次方曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuadEaseOut(t:Number):Number {
			return -(t - 1) * (t - 1) + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 2 power curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 2 次方曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuadEaseInOut(t:Number):Number {
			if (t < .5) {
				return t * t * 2;
			}
			return -(t - 1) * (t - 1) * 2 + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 2 power curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 2 次方曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuadEaseOutIn(t:Number):Number {
			var s:Number = (t - .5) * (t - .5) * 2;
			if (t < .5) {
				return .5 - s;
			}
			return .5 + s;
		}
		
		/**
		 * @language en_US
		 * x to the third 3 curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CubicEaseIn(t:Number):Number {
			return t * t * t;
		}
		
		/**
		 * @language en_US
		 * x to the third 3 curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CubicEaseOut(t:Number):Number {
			return (t - 1) * (t - 1) * (t - 1) + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 3 power curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CubicEaseInOut(t:Number):Number {
			if (t < .5) {
				return t * t * t * 4;
			}
			return (t - 1) * (t - 1) * (t - 1) * 4 + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 3 power curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CubicEaseOutIn(t:Number):Number {
			return (t - .5) * (t - .5) * (t - .5) * 4 + .5;
		}
		
		/**
		 * @language en_US
		 * x to the 4 power curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 4 次方曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuartEaseIn(t:Number):Number {
			return t * t * t * t;
		}
		
		/**
		 * @language en_US
		 * x to the 4 power curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 4 次方曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuartEaseOut(t:Number):Number {
			var a:Number= (t - 1);
			return -a * a * a * a + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 4 power curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 4 次方曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuartEaseInOut(t:Number):Number {
			if (t < .5) {
				return t * t * t * t * 8;
			}
			var a:Number= (t - 1);
			return -a * a * a * a * 8 + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 4 power curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 4 次方曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuartEaseOutIn(t:Number):Number {
			var s:Number = (t - .5) * (t - .5) * (t - .5) * (t - .5) * 8;
			if (t < .5) {
				return .5 - s;
			}
			return .5 + s;
		}
		
		/**
		 * @language en_US
		 * x to the 5 power curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 5 次方曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuintEaseIn(t:Number):Number {
			return t * t * t * t * t;
		}
		
		/**
		 * @language en_US
		 * x to the 5 power curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 5 次方曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuintEaseOut(t:Number):Number {
			var a:Number= t - 1;
			return a * a * a * a * a + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 5 power curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 5 次方曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuintEaseInOut(t:Number):Number {
			if (t < .5) {
				return t * t * t * t * t * 16;
			}
			var a:Number= t - 1;
			return a * a * a * a * a * 16 + 1;
		}
		
		/**
		 * @language en_US
		 * x to the 5 power curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 5 次方曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function QuintEaseOutIn(t:Number):Number {
			var a:Number= t - .5;
			return a * a * a * a * a * 16 + 0.5;
		}
		
		/**
		 * @language en_US
		 * Exponential curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ExpoEaseIn(t:Number):Number {
			return Math.pow(2, 10 * (t - 1));
		}
		
		/**
		 * @language en_US
		 * Exponential curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ExpoEaseOut(t:Number):Number {
			return -Math.pow(2, -10 * t) + 1;
		}
		
		/**
		 * @language en_US
		 * Exponential curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ExpoEaseInOut(t:Number):Number {
			if (t < .5) {
				return Math.pow(2, 10 * (t * 2 - 1)) * .5;
			}
			return -Math.pow(2, -10 * (t - .5) * 2) * .5 + 1.00048828125;
		}
		
		/**
		 * @language en_US
		 * Exponential curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ExpoEaseOutIn(t:Number):Number {
			if (t < .5) {
				return -Math.pow(2, -20 * t) * .5 + .5;
			}
			return Math.pow(2, 10 * ((t - .5) * 2 - 1)) * .5 + .5;
		}
		
		/**
		 * @language en_US
		 * Circle curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CircEaseIn(t:Number):Number {
			return 1 - Math.sqrt(1 - t * t);
		}
		
		/**
		 * @language en_US
		 * Circle curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CircEaseOut(t:Number):Number {
			return Math.sqrt(1 - (1 - t) * (1 - t));
		}
		
		/**
		 * @language en_US
		 * Circle curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CircEaseInOut(t:Number):Number {
			if (t < .5) {
				return .5 - Math.sqrt(.25 - t * t);
			}
			return Math.sqrt(.25 - (1 - t) * (1 - t)) + .5;
		}
		
		/**
		 * @language en_US
		 * Circle curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function CircEaseOutIn(t:Number):Number {
			var s:Number = Math.sqrt(.25 - (.5 - t) * (.5 - t));
			if (t < .5) {
				return s;
			}
			return 1 - s;
		}
		
		/**
		 * @language en_US
		 * 3 power curve x of Rebound curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方回弹曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BackEaseIn(t:Number):Number {
			return 2.70158 * t * t * t - 1.70158 * t * t;
		}
		
		/**
		 * @language en_US
		 * 3 power curve x of Rebound curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方回弹曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BackEaseOut(t:Number):Number {
			var a:Number= t - 1;
			return 2.70158 * a * a * a + 1.70158 * a * a + 1;
		}
		
		/**
		 * @language en_US
		 * 3 power curve x of Rebound curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方回弹曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BackEaseInOut(t:Number):Number {
			var a:Number= t - 1;
			if (t < .5) {
				return 10.80632 * t * t * t - 3.40316 * t * t;
			}
			return 10.80632 * a * a * a + 3.40316 * a * a + 1;
		}
		
		/**
		 * @language en_US
		 * 3 power curve x of Rebound curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * x 的 3 次方回弹曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BackEaseOutIn(t:Number):Number {
			var a:Number= t - .5;
			if (t < .5) {
				return 10.80632 * a * a * a + 3.40316 * a * a + .5;
			}
			return 10.80632 * a * a * a - 3.40316 * a * a + .5;
		}
		
		/**
		 * @language en_US
		 * Exponential Decay curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数衰减曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ElasticEaseIn(t:Number):Number {
			if (t == 0 || t == 1) return t;
			return -(Math.pow(2, 10 * (t - 1)) * Math.sin((t - 1.075) * 2 * Math.PI / .3));
		}
		
		/**
		 * @language en_US
		 * Exponential Decay curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数衰减曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ElasticEaseOut(t:Number):Number {
			if (t == 0 || t == .5 || t == 1) return t;
			
			return (Math.pow(2, 10 * -t) * Math.sin((-t - .075) * 2 * Math.PI / .3)) + 1;
		}
		
		/**
		 * @language en_US
		 * Exponential Decay curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数衰减曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ElasticEaseInOut(t:Number):Number {
			if (t == 0 || t == .5 || t == 1) return t;
			if (t < .5) {
				return -(Math.pow(2, 10 * t - 10) * Math.sin((t * 2 - 2.15) * Math.PI / .3));
			}
			return (Math.pow(2, 10 - 20 * t) * Math.sin((-4 * t + 1.85) * Math.PI / .3)) * .5 + 1;
		}
		
		/**
		 * @language en_US
		 * Exponential Decay curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 指数衰减曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function ElasticEaseOutIn(t:Number):Number {
			if (t == 0 || t == .5 || t == 1) return t;
			if (t < .5) {
				return (Math.pow(2, -20 * t) * Math.sin((-t * 4 - .15) * Math.PI / .3)) * .5 + .5;
			}
			return -(Math.pow(2, 20 * (t - 1)) * Math.sin((t * 4 - 4.15) * Math.PI / .3)) * .5 + .5;
		}
		
		public static function bounceEaseIn(t:Number):Number {
			return 1 - EaseFunction.bounceEaseOut(1 - t);
		}
		
		public static function bounceEaseOut(t:Number):Number {
			var s:Number;
			var a:Number = 7.5625;
			var b:Number = 2.75;
			if (t < (1 / 2.75)) {
				s = a * t * t;
			} else if (t < (2 / b)) {
				s = (a * (t - (1.5 / b)) * (t - (1.5 / b)) + .75);
			} else if (t < (2.5 / b)) {
				s = (a * (t - (2.25 / b)) * (t - (2.25 / b)) + .9375);
			} else {
				s = (a * (t - (2.625 / b)) * (t - (2.625 / b)) + .984375);
			}
			return s;
		}
		
		/**
		 * @language en_US
		 * Circle curve fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static var BounceEaseIn:Function = EaseFunction.bounceEaseIn;
		
		/**
		 * @language en_US
		 * Circle curve fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static var BounceEaseOut:Function = EaseFunction.bounceEaseOut;
		/**
		 * @language en_US
		 * Circle curve fade in and fade out.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡入淡出。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BounceEaseInOut(t:Number):Number {
			if (t < .5) return EaseFunction.bounceEaseIn(t * 2) * .5;
			else return EaseFunction.bounceEaseOut(t * 2 - 1) * .5 + .5;
		}
		
		/**
		 * @language en_US
		 * Circle curve fade out and fade in.
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		/**
		 * @language zh_CN
		 * 圆形曲线淡出淡入。
		 * @version Lark 1.0
		 * @platform Web,Native
		 */
		public static function BounceEaseOutIn(t:Number):Number {
			if (t < .5) return EaseFunction.bounceEaseOut(t * 2) * .5;
			else return EaseFunction.bounceEaseIn(t * 2 - 1) * .5 + .5;
		}
	}
}