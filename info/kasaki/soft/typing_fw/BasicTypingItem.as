package info.kasaki.soft.typing_fw
{
	/**
	 * ...
	 * @author j2420
	 */
	public class BasicTypingItem implements TypingItem 
	{
		private var _title: String = null;
		private var _content: String = null;
		
		public function BasicTypingItem(itemTitle: String, itemContent:String) 
		{
			_title = itemTitle;
			_content = itemContent;
		}
		
		public function getItemTitle():String 
		{
			return _title;
		}
		
		public function getItemContent():String 
		{
			return _content;
		}
		
	}

}