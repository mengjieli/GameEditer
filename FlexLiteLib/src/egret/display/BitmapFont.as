package egret.display
{
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	/**
	 * 
	 * @author dom
	 */
	public class BitmapFont extends SpriteSheet
	{
		public function BitmapFont(texture:*,config:Object)
		{
			super(texture);
			if(config is String)
			{
				this.charList = parseConfig(config as String);
			}
			else if(config&&config.hasOwnProperty("frames"))
			{
				this.charList = config.frames;
			}
			else
			{
				this.charList = {};
			}
		}
		
		private var charList:Object;
		
		override public function getTexture(name:String):Texture 
		{
			var texture:Texture = this.textureMap[name];
			if (!texture) 
			{
				var c:Object = this.charList[name];
				if (!c) 
				{
					return null;
				}
				texture = this.createTexture(name, c.x, c.y, c.w, c.h, c.offX, c.offY,c.sourceW,c.sourceH);
				this.textureMap[name] = texture;
			}
			return texture;
		}
		
		private var firstCharHeight:int = 0;
		
		ns_egret function getFirstCharHeight():int
		{
			if(this.firstCharHeight!=0)
			{
				return this.firstCharHeight;
			}
			for(var str:String in this.charList)
			{
				var c:Object = this.charList[str];
				if(c){
					var sourceH:int = c.sourceH;
					if(sourceH==0)
					{
						var h:int = c.h;
						var offY:int = c.offY;
						sourceH = h+offY;
					}
					if(sourceH<=0)
					{
						continue;
					}
					this.firstCharHeight = sourceH;
					break;
				}
			}
			return 0;
		}
		
		private function parseConfig(fntText:String):Object 
		{
			fntText = fntText.split("\r\n").join("\n");
			var lines:Array = fntText.split("\n");
			var charsCount:Number = this.getConfigByKey(lines[3], "count");
			
			var chars:Object = {};
			for (var i:int = 4; i < 4 + charsCount; i++) 
			{
				var charText:String = lines[i];
				var letter:String = String.fromCharCode(this.getConfigByKey(charText, "id"));
				var c:Object = {};
				chars[letter] = c;
				c["x"] = this.getConfigByKey(charText, "x");
				c["y"] = this.getConfigByKey(charText, "y");
				c["w"] = this.getConfigByKey(charText, "width");
				c["h"] = this.getConfigByKey(charText, "height");
				c["offX"] = this.getConfigByKey(charText, "xoffset");
				c["offY"] = this.getConfigByKey(charText, "yoffset");
			}
			return chars;
		}
		
		private function getConfigByKey(configText:String, key:String):Number 
		{
			var itemConfigTextList:Array = configText.split(" ");
			for (var i:int = 0 , length:int = itemConfigTextList.length; i < length; i++) 
			{
				var itemConfigText:String = itemConfigTextList[i];
				if (key == itemConfigText.substring(0, key.length)) 
				{
					var value:String = itemConfigText.substring(key.length + 1);
					return parseInt(value);
				}
			}
			return 0;
		}
	}
}