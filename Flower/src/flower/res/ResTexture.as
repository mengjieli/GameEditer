package flower.res
{
	public class ResTexture extends ResItem
	{
		//延迟多久释放，如果是 0 则表示下一帧释放
		public var disposeTime:Number = 0;
		
		public function ResTexture()
		{
			this.type = "Texture";
		}
	}
}