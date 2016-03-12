package com.flower.cocos2dx.core.camera
{
	import com.flower.cocos2dx.event.CameraEvent;
	import com.flower.cocos2dx.event.EventDispatcher;
	import com.jc.utils.ColorTransform;
	import com.jc.utils.Matrix;
	
	public class CameraBase extends EventDispatcher
	{
		protected var _x:int = 0;
		protected var _y:int = 0;
		protected var _width:int = 0;
		protected var _height:int = 0;
		protected var _scaleX:Number = 1;
		protected var _scaleY:Number = 1;
		protected var _rotation:Number = 0;
		protected var _matrix:Matrix;
		protected var _colorTransform:ColorTransform;
		
		public function CameraBase(w:int,h:int)
		{
			_matrix = new Matrix();
			_colorTransform = new ColorTransform();
		}
		
		public function loadMatrix():void
		{
			_matrix.identity();
			_matrix.prependTranslation(_x,_y);
			_matrix.prependRotation(_rotation);
			_matrix.prependScale(_scaleX,_scaleY);
		}
		
		public function loadMouseMatrix(mouseX:Number,mouseY:Number):void
		{
			_matrix.identity();
			_matrix.translate(mouseX-_x,mouseY-_y);
			_matrix.rotate(-_rotation);
			_matrix.scale(1/_scaleX,1/_scaleY);
		}
		
		public function setX(val:int):void
		{
			_x = val;
			this.dispatchEvent(new CameraEvent(CameraEvent.MOVE));
		}
		public function getX():int {return _x;}
		
		public function setY(val:int):void
		{
			_y = val;
			this.dispatchEvent(new CameraEvent(CameraEvent.MOVE));
		}
		public function getY():int {return _y;}
		
		public function setWidth(val:int):void {_width = val;}
		public function getWidth():int {return _width}
		
		public function setHeight(val:int):void {_height = val;}
		public function getHeight():int {return _height}
		
		public function setScaleX(val:Number):void {_scaleX = val;}
		public function getScaleX():Number {return _scaleX}
		
		public function setScaleY(val:Number):void {_scaleY = val;}
		public function getScaleY():Number {return _scaleY;}
		
		public function setRotation(val:Number):void {_rotation = val;}
		public function getRotation():Number {return _rotation;}
		
		public function getMatrix():Matrix {return _matrix;}
		
		public function getColorTransform():ColorTransform {return _colorTransform;}
	}
}