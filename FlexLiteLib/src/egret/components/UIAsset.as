package egret.components
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import egret.components.supportClasses.DefaultAssetAdapter;
	import egret.core.BitmapFillMode;
	import egret.core.BitmapSource;
	import egret.core.IAsset;
	import egret.core.IAssetAdapter;
	import egret.core.IBitmapAsset;
	import egret.core.ILayoutElement;
	import egret.core.ITexture;
	import egret.core.Injector;
	import egret.core.UIComponent;
	import egret.core.ns_egret;
	import egret.events.UIEvent;
	import egret.utils.GraphicsUtil;
	
	use namespace ns_egret;
	
	/**
	 * 皮肤发生改变事件。当给source赋值之后，皮肤有可能是异步获取的，在赋值之前监听此事件，可以确保在皮肤解析完成时回调。
	 */	
	[Event(name="skinChanged", type="egret.events.UIEvent")]
	
	[EXML(show="true")]
	
	/**
	 * 素材包装器。<p/>
	 * 注意：UIAsset仅在添skin时测量一次初始尺寸， 请不要在外部直接修改skin尺寸，
	 * 若做了引起skin尺寸发生变化的操作, 需手动调用UIAsset的invalidateSize()进行重新测量。
	 * @author dom
	 */
	public class UIAsset extends UIComponent implements IAsset
	{
		public function UIAsset(source:Object=null,autoScale:Boolean=true)
		{
			super();
			mouseChildren = false;
			if(source)
			{
				this.source = source;
			}
			this.autoScale = autoScale;
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoveFromStage);
			this.addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			stage.removeEventListener(UIEvent.SCREEN_DPI_CHANGED,onScreenDPIChanged);
		}
		
		private var _contentsScaleFactor:Number = 1;
		/**
		 * @inheritDoc
		 */
		public function get contentsScaleFactor():Number
		{
			return _contentsScaleFactor;
		}
		
		
		private function onAddedToStage(event:Event):void
		{
			if(_contentsScaleFactor!=stage.contentsScaleFactor)
			{
				_contentsScaleFactor = stage.contentsScaleFactor;
				if(content is BitmapSource)
				{
					BitmapSource(content).invalidateAsset(this);
				}
			}
			stage.addEventListener(UIEvent.SCREEN_DPI_CHANGED,onScreenDPIChanged);
		}
		/**
		 * 屏幕的DPI发生改变
		 */		
		private function onScreenDPIChanged(event:Event):void
		{
			_contentsScaleFactor = stage.contentsScaleFactor;
			if(content is BitmapSource)
			{
				BitmapSource(content).invalidateAsset(this);
			}
		}
		
		private var _fillMode:String = BitmapFillMode.SCALE;
		/**
		 * 确定位图填充尺寸的方式。默认值：BitmapFillMode.SCALE。
		 * 设置为 BitmapFillMode.REPEAT时，位图将重复以填充区域。
		 * 设置为 BitmapFillMode.SCALE时，位图将拉伸以填充区域。
		 * 注意:此属性仅在source的解析结果为BitmapData时有效
		 */		
		public function get fillMode():String
		{
			return _fillMode;
		}
		
		public function set fillMode(value:String):void
		{
			if(_fillMode==value)
				return;
			_fillMode = value;
			if(_content is BitmapData)
			{
				invalidateDisplayList();
			}
		}
		
		private var _scale9Grid:Rectangle;
		/**
		 * 矩形区域，它定义素材对象的九个缩放区域。
		 * 注意:此属性仅在source的解析结果为BitmapData并且fileMode为BitmapFillMode.SCALE时有效。
		 */
		override public function get scale9Grid():Rectangle
		{
			return this._scale9Grid;
		}
		
		override public function set scale9Grid(innerRectangle:Rectangle):void
		{
			if(_scale9Grid==innerRectangle)
				return;
			_scale9Grid = innerRectangle;
			if(_content is BitmapData)
			{
				cachedSourceGrid.length = 0;
				invalidateDisplayList();
			}
		}
		
		private var sourceChanged:Boolean = false;
		
		ns_egret var _source:Object;
		/**
		 * 素材标识符。可以为Class,String,或DisplayObject实例等任意类型，具体规则由项目注入的素材适配器决定，
		 * 适配器根据此属性值解析获取对应的显示对象，并赋值给content属性。
		 */	
		public function get source():Object
		{
			return _source;
		}
		
		public function set source(value:Object):void
		{
			if(_source==value)
				return;
			_source = value;
			if(createChildrenCalled)
			{
				parseSource();
			}
			else
			{
				sourceChanged = true;
			}
		}
		
		ns_egret var _content:Object;
		/**
		 * 显示对象皮肤。
		 */
		public function get content():Object
		{
			return _content;
		}
		
		private var createChildrenCalled:Boolean = false;
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			if(sourceChanged)
			{
				parseSource();
			}
			createChildrenCalled = true;
		}
		
		private var contentReused:Boolean = false;
		/**
		 * 解析source
		 */		
		private function parseSource():void
		{
			sourceChanged = false;
			var adapter:IAssetAdapter = getAdapter();
			if(!_source)
			{
				contentChnaged(null,_source);
			}
			else
			{
				var reuseSkin:Object = contentReused?null:_content;
				contentReused = true;
				adapter.getAsset(_source,contentChnaged,reuseSkin);
			}
		}
		
		/**
		 * 皮肤解析适配器
		 */		
		private static var assetAdapter:IAssetAdapter;
		/**
		 * 获取资源适配器
		 */
		ns_egret function getAdapter():IAssetAdapter
		{
			if(assetAdapter)
				return assetAdapter;
			var adapter:IAssetAdapter;
			try{
				adapter = Injector.getInstance(IAssetAdapter);
			}
			catch(e:Error){
				adapter = new DefaultAssetAdapter();
			}
			assetAdapter = adapter;
			return adapter;
		}
		
		/**
		 * 皮肤发生改变
		 */		
		private function contentChnaged(content:Object,source:Object):void
		{
			if(source!==this._source)
				return;
			onGetContent(content,source);
			this.contentReused = false;
			if(hasEventListener(UIEvent.CONTENT_CHANGED))
			{
				var event:UIEvent = new UIEvent(UIEvent.CONTENT_CHANGED);
				dispatchEvent(event);
			}
		}
		
		/**
		 * 附加实体显示数据
		 */		
		protected function onGetContent(content:Object,source:Object):void{
			
			var oldContent:Object = _content;
			_content = content;
			if(oldContent!==content) {
				if(oldContent is DisplayObject)
				{
					if(DisplayObject(oldContent).parent==this)
					{
						removeFromDisplayList(DisplayObject(oldContent));
					}
				}
				else if(oldContent is BitmapData||oldContent is ITexture||oldContent is BitmapSource)
				{
					var isDrawable:Boolean = (_content is BitmapData||_content is ITexture||_content is BitmapSource);
					if(!isDrawable)
					{
						graphics.clear();
					}
				}
				if(content is  DisplayObject)
				{
					addToDisplayListAt(DisplayObject(content),0);
				}
				else if(content is BitmapSource)
				{
					BitmapSource(content).invalidateAsset(this);
				}
			}
			cachedSourceGrid.length = 0;
			
			invalidateSize();
			invalidateDisplayList();
		}
		
		private var oldMeasuredWidth:Number = 0;
		private var oldMeasuredHeight:Number = 0;
		
		/**
		 * @inheritDoc
		 */
		override protected function measure():void
		{
			super.measure();
			if(!_content)
				return;
			if(_content is ILayoutElement&&!(_content as ILayoutElement).includeInLayout)
				return;
			var rect:Rectangle = getMeasuredSize();
			this.measuredWidth = rect.width;
			this.measuredHeight = rect.height;
			oldMeasuredWidth = this.measuredWidth;
			oldMeasuredHeight = this.measuredHeight;
		}
		
		private static var rect:Rectangle = new Rectangle();
		/**
		 * 获取测量大小
		 */		
		private function getMeasuredSize():Rectangle
		{
			cacheBitmapData = null;
			if(_content is ILayoutElement)
			{
				rect.width = (_content as ILayoutElement).preferredWidth;
				rect.height = (_content as ILayoutElement).preferredHeight;
			}
			else if(_content is IBitmapAsset)
			{
				rect.width = (_content as IBitmapAsset).measuredWidth;
				rect.height = (_content as IBitmapAsset).measuredHeight;
			}
			else if(_content is BitmapSource)
			{
				var bs:BitmapSource = _content as BitmapSource;
				var bd:BitmapData = bs.bitmapData;
				if(bd)
				{
					rect.width = bd.width;
					rect.height = bd.height;
				}
				else
				{
					bd = bs.retinaBitmapData;
					if(bd)
					{
						rect.width = bd.width/2;
						rect.height = bd.height/2;
					}
					else
					{
						//如果BitmapSource的位图还没解码完成。暂时使用旧的测量值。
						rect.width = oldMeasuredWidth;
						rect.height = oldMeasuredHeight;
					}
				}
				cacheBitmapData = bd;
			}
			else if(_content is BitmapData)
			{
				rect.width = BitmapData(_content).width;
				rect.height = BitmapData(_content).height;
			}
			else if(_content is ITexture)
			{
				rect.width = ITexture(_content).textureWidth;
				rect.height = ITexture(_content).textureHeight;
			}
			else if(_content is DisplayObject)
			{
				var oldScaleX:Number = _content.scaleX;
				var oldScaleY:Number = _content.scaleY;
				_content.scaleX = 1;
				_content.scaleY = 1;
				rect.width = _content.width;
				rect.height = _content.height;
				_content.scaleX = oldScaleX;
				_content.scaleY = oldScaleY;
			}
			if(rect.width==0||rect.height==0)
				aspectRatio = 0;
			else
				aspectRatio = rect.width/rect.height;
			return rect;
		}
		
		private var _maintainAspectRatio:Boolean = false;
		/**
		 * 是否保持素材的宽高比,默认为false。
		 */
		public function get maintainAspectRatio():Boolean
		{
			return _maintainAspectRatio;
		}
		
		public function set maintainAspectRatio(value:Boolean):void
		{
			if(_maintainAspectRatio==value)
				return;
			_maintainAspectRatio = value;
			invalidateDisplayList();
		}
		
		/**
		 * 缓存的源九宫格网格坐标数据
		 */		
		private var cachedSourceGrid:Array = [];
		
		private static var matrix:Matrix = new Matrix();
		/**
		 * 素材宽高比
		 */		
		ns_egret var aspectRatio:Number = NaN;
		
		/**
		 * 是自动否缩放content对象，以符合UIAsset的尺寸。默认值true。
		 */		
		public var autoScale:Boolean = true;
		/**
		 * 这个变量用于缓存BitmapSource.bitmapData。防止它在使用期间就被回收。
		 */		
		private var cacheBitmapData:BitmapData;
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			cacheBitmapData = null;
			if(_content)
			{
				var layoutBoundsX:Number = 0;
				var layoutBoundsY:Number = 0;
				if(autoScale&&_maintainAspectRatio&&(_content is DisplayObject||
					_fillMode==BitmapFillMode.SCALE&&!_scale9Grid))
				{
					if(isNaN(aspectRatio))
					{
						getMeasuredSize();
					}
					if(aspectRatio>0&&unscaledHeight>0&&unscaledWidth>0)
					{
						var ratio:Number = unscaledWidth/unscaledHeight;
						if(ratio>aspectRatio)
						{
							var newWidth:Number = unscaledHeight*aspectRatio;
							layoutBoundsX = Math.round((unscaledWidth-newWidth)*0.5);
							unscaledWidth = newWidth;
						}
						else
						{
							var newHeight:Number = unscaledWidth/aspectRatio;
							layoutBoundsY = Math.round((unscaledHeight-newHeight)*0.5);
							unscaledHeight = newHeight;
						}
						
						if(_content is ILayoutElement)
						{
							if((_content as ILayoutElement).includeInLayout)
							{
								(_content as ILayoutElement).setLayoutBoundsPosition(layoutBoundsX,layoutBoundsY);
							}
						}
						else if(_content is DisplayObject)
						{
							_content.x = layoutBoundsX;
							_content.y = layoutBoundsY;
						}
					}
				}
				if(_content is DisplayObject)
				{
					if(autoScale)
					{
						_content.width = unscaledWidth;
						_content.height = unscaledHeight;
					}
				}
				else if(_content is BitmapData||_content is BitmapSource||_content is ITexture)
				{
					var bitmapSource:BitmapSource = _content as BitmapSource;
					if(bitmapSource&&!bitmapSource.bitmapData&&!bitmapSource.retinaBitmapData)
					{
						return;
					}
					var g:Graphics = graphics;
					g.clear();
					
					var contentScale:Number = 1;
					var bitmapData:BitmapData;
					if(bitmapSource)
					{
						if(_contentsScaleFactor==1)
						{

							bitmapData = bitmapSource.bitmapData||bitmapSource.retinaBitmapData;
						}
						else
						{
							bitmapData = bitmapSource.retinaBitmapData||bitmapSource.bitmapData;
						}
						if(!bitmapData)
						{
							return;
						}
						cacheBitmapData = bitmapData;
						if(bitmapData==bitmapSource.retinaBitmapData)
							contentScale = 1/2;
					}
					if(autoScale&&fillMode==BitmapFillMode.REPEAT)
					{
						drawRepeatBitmap(unscaledWidth,unscaledHeight,bitmapSource?bitmapData:_content,contentScale);
					}
					else
					{
						var scale9Grid:Rectangle = _scale9Grid;
						if(!scale9Grid&&_content is ITexture)
						{
							scale9Grid = ITexture(_content).scale9Grid;
						}
						if(autoScale&&scale9Grid)
						{
							GraphicsUtil.drawScale9GridBitmap(g,cachedSourceGrid,
								scale9Grid,bitmapSource?bitmapData:_content,unscaledWidth,unscaledHeight,false,contentScale);
						}
						else
						{
							var scaleX:Number;
							var scaleY:Number;
							var destWidth:int;
							var destHeight:int;
							var destX:int = 0;
							var destY:int = 0;
							var sourceX:int = 0;
							var sourceY:int = 0;
							var texture:ITexture = _content as ITexture;
							
							if(texture)
							{
								if(!autoScale)
								{
									unscaledWidth = texture.textureWidth;
									unscaledHeight = texture.textureHeight;
								}
								bitmapData = texture.bitmapData;
								scaleX = unscaledWidth/texture.textureWidth;
								scaleY = unscaledHeight/texture.textureHeight;
								destWidth = texture.bitmapWidth*scaleX;
								destHeight = texture.bitmapHeight*scaleY;
								destX = texture.offsetX*scaleX;
								destY = texture.offsetY*scaleY;
								sourceX = texture.bitmapX;
								sourceY = texture.bitmapY;
							}
							else
							{
								if(!bitmapSource)
								{
									bitmapData = _content as BitmapData;
								}
								if(!autoScale)
								{
									unscaledWidth = bitmapData.width*contentScale;
									unscaledHeight = bitmapData.height*contentScale;
								}
								scaleX = unscaledWidth/bitmapData.width;
								scaleY = unscaledHeight/bitmapData.height;
								destWidth = unscaledWidth;
								destHeight = unscaledHeight;
							}
							
							matrix.identity();
							matrix.translate(-sourceX,-sourceY);
							matrix.scale(scaleX,scaleY);
							matrix.translate(layoutBoundsX+destX,layoutBoundsY+destY);
							
							g.beginBitmapFill(bitmapData,matrix,false,false);
							g.drawRect(layoutBoundsX+destX,layoutBoundsY+destY,destWidth,destHeight);
							g.endFill();
						}
					}
				}
				else if(_content is ILayoutElement)
				{
					if(autoScale&&(_content as ILayoutElement).includeInLayout)
					{
						(_content as ILayoutElement).setLayoutBoundsSize(unscaledWidth,unscaledHeight);
					}
				}
			}
		}
		
		private function drawRepeatBitmap(unscaledWidth:Number, unscaledHeight:Number,content:Object,contentScale:Number=1):void
		{
			var g:Graphics = graphics;
			if(content is BitmapData)
			{
				if(contentScale!=1)
				{
					matrix.identity();
					matrix.scale(contentScale,contentScale);
					g.beginBitmapFill(content as BitmapData,matrix,true);
				}
				else
				{
					g.beginBitmapFill(content as BitmapData,null,true);
				}
				g.drawRect(0,0,unscaledWidth,unscaledHeight);
				g.endFill();
			}
			else if(content is ITexture)
			{
				var texture:ITexture = content as ITexture;
				var bitmapData:BitmapData = texture.bitmapData;
				var destX:int = texture.offsetX;
				var destY:int = texture.offsetY;
				var textureWidth:int = texture.textureWidth;
				var textureHeight:int = texture.textureHeight;
				var bitmapWidth:int = texture.bitmapWidth;
				var bitmapHeight:int = texture.bitmapHeight;
				for (var x:int = destX; x < unscaledWidth; x += textureWidth) {
					for (var y:int = destY; y < unscaledHeight; y += textureHeight) {
						var destW:int = Math.min(bitmapWidth, unscaledWidth - x);
						var destH:int = Math.min(bitmapHeight, unscaledHeight - y);
						matrix.identity();
						matrix.translate(x-texture.bitmapX,y-texture.bitmapY);
						g.beginBitmapFill(bitmapData,matrix,false,false);
						g.drawRect(x,y,destW,destH);
						g.endFill();
					}
				}
			}
			
		}
		
		
		private static const errorStr:String = "在此组件中不可用，若此组件为容器类，请使用";
		[Deprecated] 
		/**
		 * @copy egret.components.Group#addChild()
		 */		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("addChild()"+errorStr+"addElement()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#addChildAt()
		 */		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			throw(new Error("addChildAt()"+errorStr+"addElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#removeChild()
		 */		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			throw(new Error("removeChild()"+errorStr+"removeElement()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#removeChildAt()
		 */		
		override public function removeChildAt(index:int):DisplayObject
		{
			throw(new Error("removeChildAt()"+errorStr+"removeElementAt()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#setChildIndex()
		 */		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			throw(new Error("setChildIndex()"+errorStr+"setElementIndex()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#swapChildren()
		 */		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			throw(new Error("swapChildren()"+errorStr+"swapElements()代替"));
		}
		[Deprecated] 
		/**
		 * @copy egret.components.Group#swapChildrenAt()
		 */		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			throw(new Error("swapChildrenAt()"+errorStr+"swapElementsAt()代替"));
		}
	}
}