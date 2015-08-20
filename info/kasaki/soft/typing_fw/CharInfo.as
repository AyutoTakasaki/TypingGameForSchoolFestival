package info.kasaki.soft.typing_fw 
{
	/**
	 * ...
	 * @author j2420
	 */
	public class CharInfo 
	{
		private var _charName:String;
		private var _wrongCount:int;
		public function CharInfo() 
		{
		}
		
		public function get charName():String 
		{
			return _charName;
		}
		
		public function set charName(value:String):void 
		{
			_charName = value;
		}
		
		public function get wrongCount():int 
		{
			return _wrongCount;
		}
		
		public function set wrongCount(value:int):void 
		{
			_wrongCount = value;
		}
		
		public function toString():String {
			//return "'" + _charName + "'のミスタイプ数：" + _wrongCount
			return _charName + "(" + _wrongCount + "回) ";
		}
	}

}