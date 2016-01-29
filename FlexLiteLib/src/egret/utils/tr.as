package egret.utils
{
	import egret.managers.Translator;
	
	/**
	 * 多语言翻译函数
	 * @author dom
	 */
	public function tr(key:String,...args):String
	{
		return Translator.getText(key,args);
	}
}