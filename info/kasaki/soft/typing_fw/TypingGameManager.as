package info.kasaki.soft.typing_fw
{
	import flash.automation.KeyboardAutomationAction;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import info.kasaki.soft.typing_fw.TypingItem;
	import info.kasaki.soft.typing_fw.CharInfo;
	
	/**
	 * ...
	 * @author j2420
	 */
	public class TypingGameManager 
	{
		private var _keyPressArea : DisplayObjectContainer;
		private var _keyInputHandler: KeyInputHandler;
		private var _inputMode: int = 0;
		
		private var _typingItems: /*TypingItem*/Array = [];
		private var _cursor: int = 0;
		
		private var _currentItem: TypingItem;
		private var _typingGuideTextField: TextField;
		private var _typiedPlainTextField: TextField;
		
		private var _totalTotalCount: int = 0;
		private var _totalWrongCount: int = 0;
		private var _totalWrongCountWithPlace: Object = { };
		
		private var _typeGuideTextColor: String = "0000FF";
		private var _startedTime: int;
		
		
		private function _funcWhenKeyTyped_delegate(d:int, a: String, b: int, c: String, e:String): void{
			_funcWhenKeyTyped(d, a, b, c, e);
		}
				
		private var _funcWhenKeyTyped : Function = function():void{
			//引数から設定
		}
		
		private var _funcForNewItem : Function = function(): void{
			//引数から設定
		}
		
		private function _funcForNewItem_delegate(a: int, b: TypingItem): void {
			_funcForNewItem(a, b);
		}
		
		private var _funcForAllItemCompleted : Function = function(): void{
			//引数から設定
		}
		
		private function _funcForAllItemCompleted_delegate(a: int, b: int, c: int): void{
			_funcForAllItemCompleted(a, b, c);
		}
		
		public function TypingGameManager() 
		{
			//何もしない
		}
		
		/**
		 * キーイベントを捕まえるエリアを指定。通常stageでOK
		 * @param	target
		 */
		public function setAreaToPressKey(target : DisplayObjectContainer) :void{
			_keyPressArea = target;
		}
		
		public function goodbye():void {
			_keyInputHandler && _keyInputHandler.goodbye();
		}
		
		/**
		 * タイピング項目を追加する
		 * @param	item タイピングする項目
		 */
		public function addTypingItem(item: TypingItem):void {
			_typingItems.push(item);
		}
		
		/**
		 * 入力の種類を指定。
		 * @param	inputMode KeyInputHandlerの定数。ローマ字入力orかな入力（JIS）
		 */
		public function setInputMode(inputMode : int):void {
			_inputMode = inputMode;
		}
		
		private function _prepareForItem():void {
			_currentItem = _typingItems[_cursor];
			_funcForNewItem_delegate(_cursor, _currentItem);
			_keyInputHandler.setTargetString(_currentItem.getItemContent());
		}
		
		public function getWrongCountWithPlace():/*CharInfo*/Array {
			var r:/*CharInfo*/Array = [];
			var item:Object;
			for (item in _totalWrongCountWithPlace) {
				var newCharInfo:CharInfo = new CharInfo();
				newCharInfo.charName = item as String;
				newCharInfo.wrongCount = _totalWrongCountWithPlace[item];
				r.push(newCharInfo);
			}
			r.sort(function(a:CharInfo, b:CharInfo):Number {
				if (a.wrongCount > b.wrongCount) return -1;
				if (a.wrongCount < b.wrongCount) return 1;
				return 0;
			});
			return r;
		}
		
		private function _whenInputCompleted(totalCount: int, wrongCount: int, wrongCountWithPlace: Object):void{
			_cursor++;
			_totalTotalCount += totalCount;
			_totalWrongCount += wrongCount;
			var item:Object;
			for (item in wrongCountWithPlace) {
				if (typeof _totalWrongCountWithPlace[item] != "number") _totalWrongCountWithPlace[item] = 0;
				_totalWrongCountWithPlace[item] += wrongCountWithPlace[item];
			}
			if (_cursor == _typingItems.length ) {
				_funcForAllItemCompleted(_totalTotalCount, _totalWrongCount, getTimer() - _startedTime);
				
				return;
			}
			_prepareForItem();
		}
		
		/**
		 * 引数の情報をもとに入力済み文字列（アルファベット・原文）を更新する
		 * @param	guideString 入力すべき文字列
		 * @param	typedLength guideStringのうち入力された長さ
		 * @param	typedString 入力された文字列（原文）
		 */
		public function updateGuideText(guideString: String, typedLength: int, typedString: String):void {
			if (!_typingGuideTextField) return;
			var fStr: String = guideString.substring(0, typedLength);
			var lStr: String = guideString.substring(typedLength, guideString.length);
			_typingGuideTextField.htmlText = "<html><font color='#" + _typeGuideTextColor + "'>" + fStr + "</font>" + lStr + "</html>";
			if (_typiedPlainTextField) {
				_typiedPlainTextField.text = typedString;
			}
		}
		
		private function _setText(guideStr:String, typedLength:int):void { 
			updateGuideText(guideStr, typedLength, _keyInputHandler.getTypedPlainString());
		}
		
		/**
		 * 設定値をもとにゲームを開始。時間はこのメソッドの実行時からカウント開始
		 */
		public function startGame():void {
			_keyInputHandler = new KeyInputHandler();
			_keyInputHandler.setTargetObject(_keyPressArea);
			_keyInputHandler.setInputMode(_inputMode);
			_cursor = 0;
			_totalTotalCount = 0;
			_totalWrongCount = 0;
			_totalWrongCountWithPlace = { };
			
			_startedTime = getTimer();
			var str:String = "";
			_keyInputHandler.setKeyTypedListener(function(keyType: int, a: String, b: int, c: String, e:String): void {
				_setText(str, b);
				_funcWhenKeyTyped_delegate(keyType, a, b, c, e);
			} );
			
			_keyInputHandler.setStringUpdatedListener(function(a: String, b: String, c: int) : void{
				str = b.toUpperCase();
				_setText(str, c);
			} );
			
			_keyInputHandler.setTypingCompletedListener(_whenInputCompleted);
			_prepareForItem();
		}
		
		/**
		 * 新しいタイピング項目が追加されたときに呼び出される f (現在の項目番号, 現在の項目:TypingItem)
		 * @param	
		 */
		public function setNewItemSettedListener(f: Function): void {
			_funcForNewItem = f;
		}
		
		/**
		 * すべてのタイピング項目の入力が完了したときに呼びされる。(総入力文字数:int, 誤入力数:int, 経過時間ミリ秒:int)
		 * @param	f 
		 */
		public function setAllItemCompletedListener(f: Function): void {
			_funcForAllItemCompleted = f;
		}
				
		/**
		 * キーが入力されたときに呼ばれるイベント f (イベントの種類:int(KeyInputHandlerの定数), 入力する文字（アルファベット）:String, 入力済みの文字数:int, 既に入力された文字（仮名）:String)
		 * @param
		 */
		public function setKeyTypedListener(f: Function ): void {
			_funcWhenKeyTyped = f;
		}
		
		
		/**
		 * 入力済みの文字列（原文）を表示するエリアを指定
		 * @param	value
		 */
		public function setTypedPlainTextTextField(value:TextField):void {
			_typiedPlainTextField = value;
		}
		
		/**
		 * 入力済みの文字列（アルファベットのガイド）を表示するエリアを指定
		 * @param	value
		 */
		public function setTypingGuideTextField(value:TextField):void 
		{
			_typingGuideTextField = value;
		}
		
		public function get typeGuideTextColor():String 
		{
			return _typeGuideTextColor;
		}
		
		public function set typeGuideTextColor(value:String):void 
		{
			_typeGuideTextColor = value;
		}
		
	}

}