package com.flower.cocos2dx.display
{
	import com.flower.ClassName;
	import com.flower.bufferPool.BufferPool;
	import com.flower.cocos2dx.DebugInfo;
	import com.flower.cocos2dx.EngineLock;
	import com.flower.cocos2dx.managers.PlistManager;
	import com.flower.cocos2dx.managers.TextureManager;
	import com.flower.cocos2dx.managers.plist.PlistFrameInfo;
	import com.flower.cocos2dx.managers.texture.Texture2D;
	
	import cocos2dx.cc;
	import cocos2dx.display.CCSprite;
	import cocos2dx.utils.CCRect;
	import cocos2dx.utils.CCSize;

	/**
	 *图片对象,创建图片可以使用Bitmap.create() 创建单张图片   和使用Bitmap.createPlistFrame()创建某个Plist文件中的图片
	 * @author MengJie.Li
	 * 
	 */	
	public class Bitmap extends DisplayObject
	{
		private var _texture:Texture2D;
		
		public function Bitmap()
		{
			super(true);
			this.className = ClassName.Bitmap;
			if(EngineLock.Bitmap == true)
			{
				DebugInfo.debug("|创建Bitmap| 创建失败，请访问Bitmap.create()方法创建");
				return;
			}
		}
		
		/**
		 *初始化属性，外部不可调用，BufferPool自动调用
		 * 
		 */		
		override public function initBuffer():void
		{
			super.initBuffer();
			_show = BufferPool.createCCNode(ClassName.CCSprite);
		}
		
		/**
		 *回收属性，外部不可调用，BufferPool自动调用
		 * 
		 */		
		override public function cycleBuffer():void
		{
			super.cycleBuffer();
			TextureManager.getInstance().disposeTexure(_texture);
			_texture = null;
			_show.cycle();
			BufferPool.cycyleCCNode(_show,ClassName.CCSprite);
			_show = null;
		}
		/**
		 *从单个文件初始化此对象，即此图片显示的是整个纹理 
		 * @param txt
		 * 
		 */		
		public function initWidthTexture(txt:Texture2D):void
		{
			_texture = txt;
			(this._show as CCSprite).initWithTexture(_texture.getTexture());
		}
		
		/**
		 *从子纹理初始化此对象，显示的是纹理的一部分 
		 * @param txt 纹理对象
		 * @param rect 纹理的起始位置和大小
		 * @param rot 纹理是否旋转过
		 * @param size 此对象的大小
		 * 
		 */			
		public function initTextureFrame(txt:Texture2D,rect:CCRect,rot:Boolean,size:CCSize):void
		{
			_texture = txt;
			this._width = txt.width;
			this._height = txt.width;
			(this._show as  CCSprite).setTexture(_texture.getTexture());
			(this._show as  CCSprite).setTextureRect(rect,rot,size);
			initSize(rect.width,rect.height);
		}
		
		private function getShow():CCSprite
		{
			return _show as CCSprite;
		}
		
		private function initSize(w:int,h:int):void
		{
			_width = w;
			_height = h;
		}
		
		private function setOff(offx:int,offy:int,sx:int,sy:int):void
		{
			(_show as CCSprite).setTextureOffset(cc.p(offx,offy));
			_moveX = sx;
			_moveY = sy;
		}
		
		/**
		 *从父类传来的透明度，外部对象无需调用，调用会导致错误
		 * @param val
		 * 
		 */		
		override public function setParentAlpha(val:Number):void
		{
			_parentAlpha = val;
			(_show as CCSprite).setOpacity(_alpha*_parentAlpha*255);
		}
		
		/**
		 *设置透明度 
		 * @param val 透明度为0~1
		 * 
		 */		
		override public function setAlpha(val:Number):void 
		{
			_alpha = val;
			(_show as CCSprite).setOpacity(_alpha*_parentAlpha*255);
		}
		
		/**
		 *设置父对象,外部类无需调用,否则会导致出错,如果需要添加对象请用addChild()
		 * @param val
		 * 
		 */	
		override public function setParent(val:DisplayObjectContainer):void
		{
			super.setParent(val);
			if(val == null)
			{
				BufferPool.cycle(ClassName.Bitmap,this,BufferPool.BitmapMax);
			}
		}
		
		/**
		 *创建Bitmap对象
		 * @param url 可选参数，如果不设表示一个空的Bitmap，否则表示是某个单独图片文件对象，
		 * 如果要创建Plist文件的某个图片请用createPlist
		 * @return 
		 * 
		 */		
		public static function create(url:String=""):Bitmap
		{
			EngineLock.Bitmap = false;
			var bm:Bitmap = BufferPool.create(ClassName.Bitmap,Bitmap);
			EngineLock.Bitmap = true;
			if(url != "")
			{
				var flag:Boolean = false;
				if(TextureManager.getInstance().loadTexture(url,0,0) != null) flag = true;
				bm.initWidthTexture(TextureManager.getInstance().getNewTexture(url));
				if(flag)
				{
					bm._texture.width = bm.getShow().getContentSize().width;
					bm._texture.height = bm.getShow().getContentSize().height;
					bm.initSize(bm._texture.width,bm._texture.height);
				}
			}
			return bm;
		}
		
		/**
		 *创建Plist文件中的某个图片
		 * @param url 图片名称
		 * @param plistName plist文件名，也可不穿，如果不穿而此Plist文件没解析过会导致出错
		 * @return 
		 * 
		 */		
		public static function createPlistFrame(name:String,plistUrl:String=""):Bitmap
		{
			var bm:Bitmap = create();
			var frame:PlistFrameInfo;
			if(plistUrl != "")
			{
				frame = PlistManager.getInstance().addPlist(plistUrl).getFrame(name);
			}
			else
			{
				frame = PlistManager.getInstance().getPlistFrame(name);
			}
			bm.setOff(frame.offx,frame.offy,frame.moveX,frame.moveY);
			bm.initTextureFrame(frame.texture,cc.rect(frame.x,frame.y,frame.width,frame.height),frame.rot,cc.size(frame.sourceWidth,frame.sourceHeight));
			return bm;
		}
	}
}