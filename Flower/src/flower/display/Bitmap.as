package flower.display
{
	import flower.debug.DebugInfo;
	import flower.texture.Texture2D;

	public class Bitmap extends DisplayObject
	{
		private var _texture:Texture2D;
		private static var bitmapProperty:Object = System.Bitmap;
		
		public function Bitmap(texture:Texture2D=null)
		{
			_show = System.getNativeShow("Bitmap");
			this.texture = texture;
		}
		
		protected function _setTexture(val:Texture2D):void {
			if(_texture) {
				_texture.$delCount();
			}
			_texture = val;
			var p:Object = bitmapProperty.texture;
			if(val) {
				_width = _texture.width;
				_height = _texture.height;
				_texture.$addCount();
				if(p.func) {
					_show[p.func](_texture.$nativeTexture);
					if(System.IDE == IDE.COCOS2DX) {
						_show.setAnchorPoint(0,1);
					}
				} else {
					_show[p.atr] = _texture.$nativeTexture;
				}
			} else {
				_width = 0;
				_height = 0;
				if(System.IDE == IDE.COCOS2DX) {
					if(p.func) {
						_show[p.func](Texture2D.blank.$nativeTexture);
					} else {
						_show[p.atr] = Texture2D.blank.$nativeTexture;
					}
				} else {
					if(p.func) {
						_show[p.func](null);
					} else {
						_show[p.atr] = null;
					}
				}
			}
		}
		
		override protected function _setWidth(val:Number):void {
			this.scaleX = val/this._width;
		}
		
		override protected function _setHeight(val:Number):void {
			this.scaleY = val/this._height;
		}
		/////////////////////////////////////set && get/////////////////////////////////////
		public function set texture(val:Texture2D):void {
			if(val == _texture) {
				return;
			}
//			if(val == null) {
//				//不能设置为空是因为 cocos2dx 不能支持 Sprite 设置纹理为空
//				DebugInfo.debug("Bitmap.texture 不能设置为空，详情见引擎说明",DebugInfo.WARN);
//				return;
//			}
			_setTexture(val);
		}
		
		public function get texture():Texture2D {
			return _texture;
		}
		
		override public function dispose():void {
			var show:* = _show;
			super.dispose();
			texture = null;
			System.cycleNativeShow("Bitmap",show);
		}
	}
}