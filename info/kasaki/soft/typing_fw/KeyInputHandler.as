
package info.kasaki.soft.typing_fw {
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	public class KeyInputHandler {
		public static const INPUT_TYPE_ABC : int= 0; 
		public static const INPUT_TYPE_KANA : int = 1;
		
		public static const KEYTYPE_CORRECT : int= 0;
		public static const KEYTYPE_WRONG : int = 1;
		public static const KEYTYPE_BS : int = 2;
		
		private var _targetObject : DisplayObjectContainer;
		
		private var _targetStringPlain : String = null;
		private var _targetStringABC : String = null;
		private var _targetStringEachArray : /*String*/Array = null;
		private var _targetStringSplitedPlain : /*String*/Array = null;
		private var _typedStringPlain: String = "";
		private var _inputMode: int = 0;
		
		public function KeyInputHandler() {
			//コンストラクタ
		}
		
		private function _funcForCorrectKey_delegate(a: String, b: int, c: String, d:String): void{
			_funcWhenKeyTyped(KEYTYPE_CORRECT, a, b, c, d);
		}
		
		private function _funcForWrongKey_delegate(a: String, b: int, c: String, d:String): void{
			_funcWhenKeyTyped(KEYTYPE_WRONG, a, b, c, d);
		}
		
		private function _funcForBackSpaceKey_delegate(a: String, b: int, c: String, d:String): void{
			_funcWhenKeyTyped(KEYTYPE_BS, a, b, c, d);
		}
		
		private var _funcWhenStringUpdated : Function = function():void{
			//引数から設定
		}
		
		private var _funcWhenKeyTyped : Function = function():void{
			//引数から設定
		}
		
		private var _funcWhenTypingCompleted : Function = function():void{
			//引数から設定
		}
		
		private var _totalCount : int = 0;
		private var _cursor : int = 0;
		private var _innerCursor : int = 0;
		private var _wrongCount : int = 0;
		private var _wrongCountWithPlace:Object;
		private var _plainTextChangeHistory:/*String*/Array;
		
		private var isWorking:Boolean = true;
		
		private const ABC_CHARS : Array = "abcdefghijklmnopqrstuvwxyz".split("");
		private const KANA_TABLE : Array = ["ぁぃぅぇぉ", "あいうえお", "かきくけこ", "さしすせそ", "たちつてと", "なにぬねの", "はひふへほ", "まみむめも", "や　ゆ　よ", "らりるれろ", "わ　　　を", "がぎぐげご", "ざじずぜぞ", "だぢづでど", "ばびぶべぼ", "ぱぴぷぺぽ", "ゃ　ゅ　ょ"];
		private const KANA_TO_ABC_ORDER_TABLE_S : Array = ["x", "", "k", "s", "t", "n", "h", "m", "y", "r", "w", "g", "z", "d", "b", "p", "xy"];
		private const KANA_TO_ABC_ORDER_TABLE_B : Array = ["a", "i", "u", "e", "o"];
		
		private const KANA_TO_KEYCORD_TABLE: Array = [
		["あ", Keyboard.NUMBER_3], ["い", Keyboard.E], ["う", Keyboard.NUMBER_4], ["え", Keyboard.NUMBER_5], ["お", Keyboard.NUMBER_6],
		["か", Keyboard.T], ["き", Keyboard.G], ["く", Keyboard.H], ["け", Keyboard.EQUAL], ["こ", Keyboard.B], 
		["さ", Keyboard.X], ["し", Keyboard.D], ["す", Keyboard.R], ["せ", Keyboard.P], ["そ", Keyboard.C], 
		["た", Keyboard.Q], ["ち", Keyboard.A], ["つ", Keyboard.Z], ["て", Keyboard.W], ["と", Keyboard.S], 
		["な", Keyboard.U], ["に", Keyboard.I], ["ぬ", Keyboard.NUMBER_1], ["ね", Keyboard.COMMA], ["の", Keyboard.K],
		["は", Keyboard.F], ["ひ", Keyboard.V], ["ふ", Keyboard.NUMBER_2], ["へ", Keyboard.QUOTE], ["ほ", Keyboard.MINUS],
		["ま", Keyboard.J], ["み", Keyboard.N], ["む", Keyboard.RIGHTBRACKET], ["め", Keyboard.SLASH], ["も", Keyboard.M],
		["や", Keyboard.NUMBER_7], ["ゆ", Keyboard.NUMBER_8], ["よ", Keyboard.NUMBER_9], 
		["ら", Keyboard.O], ["り", Keyboard.L], ["る", Keyboard.PERIOD], ["れ", Keyboard.EQUAL], ["ろ", Keyboard.BACKSLASH], 
		["わ", Keyboard.NUMBER_0], ["を", Keyboard.NUMBER_0, true], ["ん", Keyboard.Y], 
		["ぁ", Keyboard.NUMBER_3, true], ["ぃ", Keyboard.E, true], ["ぅ", Keyboard.NUMBER_4, true], ["ぇ", Keyboard.NUMBER_5, true], ["ぉ", Keyboard.NUMBER_6, true], 
		["ゃ", Keyboard.NUMBER_7, true], ["ゅ", Keyboard.NUMBER_8, true], ["ょ", Keyboard.NUMBER_9, true], ["っ", Keyboard.Z, true],
		["゛", Keyboard.BACKQUOTE], ["゜", Keyboard.LEFTBRACKET], ["、", Keyboard.COMMA, true], ["。", Keyboard.PERIOD, true], ["「", Keyboard.LEFTBRACKET, true], ["」", Keyboard.RIGHTBRACKET, true], ["ー", Keyboard.BACKSLASH]];
		
		private const KANA_TO_KEYCHAR_TABLE: Array = [
		["あ", "3"], ["い", "e"], ["う", "4"], ["え", "5"], ["お", "6"],
		["か", "t"], ["き", "g"], ["く", "h"], ["け", ":"], ["こ", "b"], 
		["さ", "x"], ["し", "d"], ["す", "r"], ["せ", "p"], ["そ", "c"], 
		["た", "q"], ["ち", "a"], ["つ", "z"], ["て", "w"], ["と", "s"], 
		["な", "u"], ["に", "i"], ["ぬ", "1"], ["ね", ","], ["の", "k"],
		["は", "f"], ["ひ", "v"], ["ふ", "2"], ["へ", "^"], ["ほ", "-"],
		["ま", "j"], ["み", "n"], ["む", "]"], ["め", "/"], ["も", "m"],
		["や", "7"], ["ゆ", "8"], ["よ", "9"], 
		["ら", "o"], ["り", "l"], ["る", "."], ["れ", ";"], ["ろ", "\\"], 
		["わ", "0"], ["を", "0", true], ["ん", "y"]];
			
		private const ABC_CONVERT_TO_HEPBURN_TABLE : Array = [
			["si", 1, "h", "shi"], 
			["ti", 0, "c", "chi"], 
			["tu", 1, "s", "tsu"], 
			["hu", 0, "f", "fu"], 
			["zi", 0, "j", "ji"], 
			["di", 0, "z", "zi"], 
			["di", 0, "j", "ji"], 
			["zya", 0, "j", "ja"], 
			["zyu", 0, "j", "ju"], 
			["zyi", 0, "j", "jyi"],
			["zyo", 0, "j", "jo"],
			["zye", 0, "j", "je"],
			["je", 1, "y", "jye"],
			["sya", 1, "h", "sha"],
			["syu", 1, "h", "shu"],
			["sye", 1, "h", "she"],
			["syo", 1, "h", "sho"],
			["tya", 0, "c", "cha"],
			["tyu", 0, "c", "chu"],
			["tyo", 0, "c", "cho"]
		];
		
		//バックスペース押下時にヘボン等に変換したものも戻すため
		private function _setCurrentChangeToStore(index:int, value:String):void {
			var store:/*ChangedHistoryItem*/Array = _plainTextChangeHistory[_totalCount] || [];
			store.push(new ChangedHistoryItem(index, value));
			_plainTextChangeHistory[_totalCount] = store;
		}
		
		private function _getChangeHistoryFromStore():Array {
			return _plainTextChangeHistory[_totalCount] || [];
		}
		
		private function _resetChangeHistory():void {
			_plainTextChangeHistory[_totalCount] = [];
		}
		
		private function _restoreChangeHistory():void {
			var store:/*ChangedHistoryItem*/Array = _getChangeHistoryFromStore();
			var l:int;
			for (l = store.length-1; l >= 0; l--) {
				_targetStringEachArray[store[l].index]= store[l].content;
				_funcWhenStringUpdated(_targetStringPlain, _targetStringEachArray.join(""), _totalCount);
			}
			_resetChangeHistory();
		}
		
		private function _addWrongCount(charToType:String): void {
			if (typeof _wrongCountWithPlace[charToType] != "number") _wrongCountWithPlace[charToType] = 0;
			_wrongCountWithPlace[charToType] ++;
			_wrongCount ++;
		}
				
		private function _updateTargetStringArray(index:int, value:String):void {
			_setCurrentChangeToStore(index, _targetStringEachArray[index]);
			_targetStringEachArray[index] = value;
			_funcWhenStringUpdated(_targetStringPlain, _targetStringEachArray.join(""), _totalCount);			
		}
		
		private function _getKeyCharInfoFromKanaChar(char: String): KeyCharInfo {
			var i: int;
			for (i = 0; i < KANA_TO_KEYCHAR_TABLE.length; i++) {
				if (KANA_TO_KEYCHAR_TABLE[i][0] == char) {
					var info:KeyCharInfo = new KeyCharInfo();
					info.charStr = KANA_TO_KEYCHAR_TABLE[i][1];
					info.charCode = info.charStr.charCodeAt(0);
					info.isShifted = KANA_TO_KEYCHAR_TABLE[i][2] || false;
					return info;
				}
			}
			return null;
		}
		
		private function _getKeyCodeInfoFromKanaChar(char: String): KeyCodeInfo {
			var i: int;
			for (i = 0; i < KANA_TO_KEYCORD_TABLE.length; i++) {
				if (KANA_TO_KEYCORD_TABLE[i][0] == char) {
					var info:KeyCodeInfo = new KeyCodeInfo();
					info.keyCode = KANA_TO_KEYCORD_TABLE[i][1];
					info.isShifted = KANA_TO_KEYCORD_TABLE[i][2] || false;
					return info;
				}
			}
			return null;
		}
		
		private function _getKanaCharFromKeyChar(char: String): KeyCharInfo {
			var i: int;
			for (i = 0; i < KANA_TO_KEYCHAR_TABLE.length; i++) {
				if (KANA_TO_KEYCHAR_TABLE[i][1] == char) {
					var info:KeyCharInfo = new KeyCharInfo();
					info.kanaChar = KANA_TO_KEYCHAR_TABLE[i][0];
					info.charStr = KANA_TO_KEYCHAR_TABLE[i][1];
					info.charCode = info.charStr.charCodeAt(0);
					info.isShifted = KANA_TO_KEYCHAR_TABLE[i][2] || false;
					return info;
				}
			}
			return null;
		}
		
		private function _getKanaCharFromKeyCode(keycode: int): /*KeyCodeInfo*/Array {
			var i: int;
			var result:/*KeyCodeInfo*/Array = [];
			for (i = 0; i < KANA_TO_KEYCORD_TABLE.length; i++) {
				if (KANA_TO_KEYCORD_TABLE[i][1] == keycode) {
					var info:KeyCodeInfo = new KeyCodeInfo();
					info.keyCode = KANA_TO_KEYCORD_TABLE[i][1];
					info.kanaChar = KANA_TO_KEYCORD_TABLE[i][0];
					info.isShifted = KANA_TO_KEYCORD_TABLE[i][2] || false;
					result.push(info);
				}
			}
			return result;
		}
		
		private function _keyTypeWatcher(e : KeyboardEvent): Boolean{
			if (isWorking == false) return false;
			
			if (_cursor === _targetStringEachArray.length) return false;
			if (e.charCode == 0) return false;
			
			var inputedChar : String = String.fromCharCode(e.charCode);
			
			var targetPointString:String;
			var targetPointArray: /*String*/Array;
				
			if (e.keyCode == Keyboard.BACKSPACE) {
				//バックスペース入力時の処理
				if (_innerCursor == 0 && _cursor >= 1) {
					_cursor --;
					_innerCursor = _targetStringEachArray[_cursor].length;
				}
				if (_innerCursor >= 1) {
					_innerCursor --;
					_totalCount --;
					_restoreChangeHistory();
					
					//nnがnに戻ったときの処理など
					if (_innerCursor == _targetStringEachArray[_cursor].length) {
						_innerCursor = 0;
						_cursor ++;
						_checkPosition();
					}
					
					_updateTypedString();
					
					
				targetPointString = _targetStringEachArray[_cursor];
				targetPointArray = targetPointString.split("");
					_funcForBackSpaceKey_delegate(_targetStringEachArray.join(""), _totalCount, inputedChar, targetPointArray[_innerCursor]);
				}
				return false;
			}
			
			var isMatched: Boolean = false;//入力OK or ミス
			var charL:String;
			
			if (_inputMode === INPUT_TYPE_KANA) {
				//かな入力
				var charInfo:KeyCharInfo = _getKanaCharFromKeyChar(inputedChar) || new KeyCharInfo();
				var codeInfo:/*KeyCodeInfo*/Array = _getKanaCharFromKeyCode(e.keyCode);
					
				targetPointString = _targetStringEachArray[_cursor];
				targetPointArray = targetPointString.split("");
				
				var currentChar:String = targetPointArray[_innerCursor];
				
				var o: int, p: int;
				var isShifted: Boolean = charInfo.isShifted;
				if (charInfo.kanaChar == currentChar) {
					isMatched = true;
				} else {
					for (o = 0; o < codeInfo.length; o++ ) {
						if (codeInfo[o].kanaChar == currentChar) {
							if (codeInfo[o].isShifted == e.shiftKey) {
								isMatched = true;
								break;
							}
						}
					}
					if (!isMatched) {
						var kanaKeyCodeInfo:KeyCodeInfo = _getKeyCodeInfoFromKanaChar(currentChar) || new KeyCodeInfo();
						if (e.keyCode == kanaKeyCodeInfo.keyCode) {
							if (kanaKeyCodeInfo.isShifted == e.shiftKey){
								isMatched = true;
							}
						}
					}
				}
				
				//アルファベット時の処理
				charL = targetPointArray[_innerCursor].toLowerCase();
				if (charL.length == 1 && charL.charCodeAt(0) >= "a".charCodeAt(0) && charL.charCodeAt(0) <= "z".charCodeAt(0)) {
					inputedChar = String.fromCharCode((e.keyCode - Keyboard.A) + "a".charCodeAt(0));
					if (inputedChar == charL) isMatched = true;
				}
				
			} else if (_inputMode === INPUT_TYPE_ABC) {
				//ローマ字入力
				
				// nnのところをnで入力した場合
				if (_cursor - 1 >= 0 && _targetStringEachArray[_cursor - 1].match(/^n$/) && _innerCursor == 0 && inputedChar == "n") {
					if (!_targetStringEachArray[_cursor].match(/^n/)) {
						_updateTargetStringArray(_cursor - 1, "nn");
						_totalCount ++;
						
						
				targetPointString = _targetStringEachArray[_cursor];
				targetPointArray = targetPointString.split("");
				
						_funcForCorrectKey_delegate(_targetStringEachArray.join(""), _totalCount, inputedChar, targetPointArray[_innerCursor]);
					}
					return false;
				}

				//ヘボン式入力・その他例外の入力の処理
				var i: int;
				for(i=0; i<ABC_CONVERT_TO_HEPBURN_TABLE.length; i++){
					var t : Array = ABC_CONVERT_TO_HEPBURN_TABLE[i];
					if (_targetStringEachArray[_cursor] === t[0] && _innerCursor === t[1] && inputedChar === t[2] ) {
						_updateTargetStringArray(_cursor, t[3]);
					}
				}
				
				targetPointString = _targetStringEachArray[_cursor];
				targetPointArray = targetPointString.split("");
				
				//XTU入力時の処理
				if (targetPointString.length == 1 && _targetStringSplitedPlain[_cursor] === "っ" && inputedChar == "x") {
					_updateTargetStringArray(_cursor, "xtu");
				}
				
				// xから始まるものにlを入力した場合
				if (_targetStringEachArray[_cursor].match(/x/) && inputedChar == "l") {
					var tmp:/*String*/Array = _targetStringEachArray[_cursor].split("");
					if (tmp[_innerCursor] == "x") tmp[_innerCursor] = "l";
					_updateTargetStringArray(_cursor, tmp.join(""));
				}
				
				var charAll: String;
				var char1st:String;
				var char2nd:String;
				var s: String;
				
				//「ふぁふぃふぇふぉ」を「ふ」「ぁ」などと打った場合
				if (_innerCursor == 0 && _targetStringSplitedPlain[_cursor].match(/^[ふじし][ぁぃぇぉ]$/) && _targetStringSplitedPlain[_cursor].length >= 2) {
					charAll = "";
					char1st = _targetStringSplitedPlain[_cursor].split("")[0];
					char2nd = _targetStringSplitedPlain[_cursor].split("")[1];
					if (inputedChar == "h") {
						_updateTargetStringArray(_cursor, "hu" + _convertKanaToABC(char2nd));
					} 
				} else if (_innerCursor == 0 && _targetStringSplitedPlain[_cursor].match(/^う[ぃぇ]$/) && _targetStringSplitedPlain[_cursor].length >= 2) {
					charAll = "";
					char1st = _targetStringSplitedPlain[_cursor].split("")[0];
					char2nd = _targetStringSplitedPlain[_cursor].split("")[1];
					if (inputedChar == "u") {
						_updateTargetStringArray(_cursor, "u" + _convertKanaToABC(char2nd));
					} 
				} else 
				//「ちゃ」などを「ち」「ゃ」と入力された場合の処理　＆　「ちぃ」などを「ち」「ぃ」と入力された場合の処理
				if (_innerCursor >= 1 && _targetStringSplitedPlain[_cursor].match(/[ゃゅょぃぇ]/) && _targetStringSplitedPlain[_cursor].length >= 2) {
					charAll = "";
					char1st = _targetStringSplitedPlain[_cursor].split("")[0];
					char2nd = _targetStringSplitedPlain[_cursor].split("")[1];
					s = _convertKanaToABC(char1st);
					if (s.length >= 2 && s.split("")[1] == inputedChar && ! targetPointString.match(/xy/)) {
						//if (!s.match(/thi|the/)) {
						
						//入力内容が違う
						if (targetPointArray[_innerCursor] != inputedChar){
							var tmpE: String = _targetStringEachArray[_cursor];
							if (tmpE.match(/ch|sh|f|j/)) {
								charAll = tmpE.substring(0, tmpE.length - 1) + s.substring(1, 2)
							} else {
								charAll = s;
							}
							charAll += _convertKanaToABC(char2nd);
							_updateTargetStringArray(_cursor, charAll);
						}
					}
				}

				//変更されているかもしれないのでもう一度代入
				targetPointString = _targetStringEachArray[_cursor];
				targetPointArray = targetPointString.split("");
				
				//アルファベット時にシフトを押すと正常に認識されない
				
				charL = targetPointArray[_innerCursor].toLowerCase();
				if (charL.length == 1 && charL.charCodeAt(0) >= "a".charCodeAt(0) && charL.charCodeAt(0) <= "z".charCodeAt(0)) {
					if (e.shiftKey) {
						inputedChar = String.fromCharCode((e.keyCode - Keyboard.A) + "a".charCodeAt(0));
					}
				}
				
				isMatched = targetPointArray[_innerCursor] == inputedChar;
				
			}
			
			//あとはふつうに入力結果と比較
			if (isMatched) {
				_nextChar();
				
				_funcForCorrectKey_delegate(_targetStringEachArray.join(""), _totalCount, inputedChar, targetPointArray[_innerCursor]);
			} else {
				//誤入力
				_addWrongCount(targetPointArray[_innerCursor]);
				_funcForWrongKey_delegate(_targetStringEachArray.join(""), _totalCount, inputedChar, targetPointArray[_innerCursor]);
			}
			
			
			return false;
		}
		
		private function _checkPosition():void {
			var targetPointString:String = _targetStringEachArray[_cursor];
			var targetPointArray: /*String*/Array = targetPointString.split("");
				
			if (_innerCursor === targetPointArray.length) {
				_innerCursor = 0;
				_cursor ++;
				_updateTypedString();
			
				if (_cursor === _targetStringEachArray.length) {
					
					//入力完了
					_funcWhenTypingCompleted(_totalCount, _wrongCount, _wrongCountWithPlace);
				}
			} 
		}
		
		private function _nextChar():void {
			_innerCursor++;
			_totalCount++;
			
			_updateTypedString();
			_checkPosition();
		}
		
		public function getTypedPlainString():String {
			return _typedStringPlain;
		}
		
		private function _updateTypedString():void {		
			var typedStrTmp: String = "";
			var typedStrTmpABC: String = "";
			for (var k:int = 0; k < _cursor; k++ ) {
				typedStrTmp += _targetStringSplitedPlain[k];
			}
			if (_innerCursor > 0) {
				var tmp:/*String*/Array = _targetStringEachArray[_cursor].split("");
				var kana:String = "";
				for (var l:int = 0; l < _innerCursor; l++ ) {
					typedStrTmpABC += tmp[l];
					if (typedStrTmpABC.match(/[aiueo]/)) {
						kana = _convertABCToKana(typedStrTmpABC);
						if (kana != null) {
							typedStrTmpABC = kana;
						}
					}
				}
			}
			typedStrTmp += typedStrTmpABC;
			_typedStringPlain = typedStrTmp;
		}
		
		private function _removeKeyEventListener(): void{
			try{
				_targetObject.removeEventListener(KeyboardEvent.KEY_DOWN, _keyTypeWatcher, false);
			}catch(e: Error) {};
		}
		
		private function _setKeyEventListener() : void{
			_removeKeyEventListener();
			_targetObject.addEventListener(KeyboardEvent.KEY_DOWN, _keyTypeWatcher, false);
		}
		
		public function goodbye():void {
			isWorking = false;
			_removeKeyEventListener();
		}
		
		private function _getShiin(char: String):String {
			for(var i:int=0; i<KANA_TABLE.length; i++) {
				var str:String = KANA_TABLE[i];
				if (str.indexOf(char) != -1 ) {
					return KANA_TO_ABC_ORDER_TABLE_S[i]; //子音を確定
				}
			}
			return "";
		}
		
		private function _getBoin(char: String):String {
			for (var i:int= 0; i < KANA_TABLE.length; i++) {
				var str:String = KANA_TABLE[i];
				if (str.indexOf(char) != -1 ) {
					var strArray:Array = str.split("");
					var b : String = KANA_TO_ABC_ORDER_TABLE_S[i]; //子音を確定
					for(var j:int=0; j<strArray.length; j++){
						if (strArray[j] === char) return (KANA_TO_ABC_ORDER_TABLE_B[j]);
						//母音を確定
					}
				}
			}
			return "";
		}
		
		private function _getGyouNumFromShiin(shiin:String):int {
			var i:int;
			for (i = 0; i < KANA_TO_ABC_ORDER_TABLE_S.length; i++ ) {
				if (KANA_TO_ABC_ORDER_TABLE_S[i] == shiin) {
					return i;
				}
			}
			return -1;
		}
		private function _getDanNumFromBoin(boin:String):int {
			var i:int;
			for (i = 0; i < KANA_TO_ABC_ORDER_TABLE_B.length; i++ ) {
				if (KANA_TO_ABC_ORDER_TABLE_B[i] == boin) {
					return i;
				}
			}
			return -1;
		}
		
		private const _HEPBURN_TO_NORMAL_CONVERT_TABLE:Object = {
			"sh" : "s",
			"ch" : "t",
			"fu" : "hu",
			"tsu" : "tu",
			"ji" : "zi"
		};
		
		private function _convertABCToKana(char: String): String {
			var o:Object;
			for (o in _HEPBURN_TO_NORMAL_CONVERT_TABLE) {
				char = char.replace(o, _HEPBURN_TO_NORMAL_CONVERT_TABLE[o]);
			}
				
			var splittedChars: /*String*/Array = char.split("");
			var i:int, j:int;
			var gyou:int = -1
			var dan:int = -1;
			var targetGyou:/*String*/Array;
			if (splittedChars.length == 1) {
				dan = _getDanNumFromBoin(splittedChars[0]);
				targetGyou = KANA_TABLE[1].split("");
				return targetGyou[dan];
			}
			if (splittedChars.length == 2) {
				dan = _getDanNumFromBoin(splittedChars[1]);
				gyou = _getGyouNumFromShiin(splittedChars[0]);
				if (KANA_TABLE[gyou]) {
					targetGyou = KANA_TABLE[gyou].split("");
					return targetGyou[dan];
				}
			}
			return "";
		}
		
		private const _KANA_TO_ABC_DIRECT_CONVERT_TABLE:Object = { "てゃ": "tha", "てゅ": "thu", "てょ": "tho", 
		"ヴぃ": "vi", "う゛い": "vi", "ん": "nn", "っ": "xtu", 
		"、": ",", "。": ".", "ー": "-", "　": " ", "？": "?", "！": "!"};
		
		private function _convertKanaToABC(char : String) : String  {
			if (_KANA_TO_ABC_DIRECT_CONVERT_TABLE[char]) return _KANA_TO_ABC_DIRECT_CONVERT_TABLE[char];
			var i: int, j : int;
			var str : String;
			var strArray : Array;
			var charL : String = char.toLowerCase();
			
			//アルファベット時の処理
			if (charL.length == 1 && charL.charCodeAt(0) >= "a".charCodeAt(0) && charL.charCodeAt(0) <= "z".charCodeAt(0)) {
				return charL;
			}
			
			if (char.length === 1) {
				for(i=0; i<KANA_TABLE.length; i++) {
					str = KANA_TABLE[i];
					if (str.indexOf(char) != -1 ) {
						strArray = str.split("");
						var b : String = KANA_TO_ABC_ORDER_TABLE_S[i]; //子音を確定
						for(j=0; j<strArray.length; j++){
							if (strArray[j] === char) return (b + KANA_TO_ABC_ORDER_TABLE_B[j]);
							//母音を確定
						}
					}
				}
			} else if (char.length === 2) {
				//ちゃちゅちょ…などなど
				var char1st:String = char.split("")[0];
				var char2nd:String = char.split("")[1];
				var charAll: String = _getShiin(char1st);
				
				if (char1st == "て") {
					charAll = "t";
					switch(char2nd) {
						case "ぃ":
							return charAll + "hi";
						case "ぇ":
							return charAll + "he";
					}
				} else if (char1st == "う") { 
					charAll = "w";
					switch(char2nd) {
						case "ぃ":
							return charAll + "i";
						case "ぇ":
							return charAll + "e";
					}
				} else if (char1st.match(/[ふ]/) && char2nd.match(/[ぁぃぇぉ]/)) {
					return "f" + _getBoin(char2nd);
				} else if (char1st.match(/[きしちにひみりぎじぢびぴ]/) && char2nd.match(/[ぃぇ]/)) {
					switch(char2nd) {
						case "ぃ":
							return charAll + "yi";
						case "ぇ":
							return charAll + "ye";
					}
				} else  {
					switch(char2nd) {
						case "ゃ":
							charAll += "ya";
							break;
						case "ゅ":
							charAll += "yu";
							break;
						case "ょ":
							charAll += "yo";
							break;
					}
					return charAll;
				}
			}
			
			//それ以外
			return char;
		}
		
		private function _prepareForInput(): void {
			if (!_targetStringPlain) return;
			_cursor = 0;
			_innerCursor = 0;
			_totalCount = 0;
			_wrongCount = 0;
			_plainTextChangeHistory = [];
			_wrongCountWithPlace = {};
			_typedStringPlain = "";
			
			var splitedString :Array = _targetStringPlain.split("");
			var inputStrArray : Array = [];
			var inputStrString : String = "";
			
			var i : int, j: int;
			for (i = splitedString.length - 1; i >= 0; i-- ) {
				if (splitedString[i].match(/[ゃゅょ]/)) {
					if (i - 1 >= 0 && splitedString[i - 1].match(/[ちてきぎしじちぢにひぴびふぶぷみり]/)) {
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
					}
				}
				if (splitedString[i].match(/[ぃぇ]/)) {
					if (i - 1 >= 0 && splitedString[i - 1].match(/[きしちにひみりぎじぢびぴふうて]/)) {
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
					}
				}
				if (splitedString[i].match(/[ぁぃぇぉ]/)) {
					if (i - 1 >= 0 && splitedString[i - 1].match(/[ふ]/)) {
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
					}
				}
				if (splitedString[i].match(/ぃ/)) {
					if (i - 1 >= 0 && splitedString[i - 1].match(/ヴ/)) {
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
					} else if (i - 2 >= 0 && splitedString[i - 1].match(/゛/) && splitedString[i - 2].match(/う/)) {
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
						splitedString[i - 1] += splitedString[i];
						splitedString.splice(i, 1);
						i --;
					}
				}
			}
			var t: String;
			if (_inputMode == INPUT_TYPE_ABC) {
				for (i = 0; i < splitedString.length; i++) {
					if (splitedString[i] == "っ" && i + 1 < splitedString.length && _convertKanaToABC(splitedString[i + 1]).length >= 2) {
						var tmp:Array = _convertKanaToABC(splitedString[i + 1]).split("");
						inputStrArray.push(tmp[0]);
						inputStrString += tmp[0];
						continue;
					}
					t = _convertKanaToABC(splitedString[i]);
					if (t == "nn" && i + 1 < splitedString.length && !_convertKanaToABC(splitedString[i + 1]).match(/^n/)) {
						t = "n";
					}
					inputStrArray.push(t);
					inputStrString += t;
				}
			} else if (_inputMode == INPUT_TYPE_KANA ) {
				var ZtoS_TABLE: Object = {"z": "s", "g": "k", "d": "t", "b": "h", "p": "h"};
				for (i = 0; i < splitedString.length; i++) {
					var splittedStringEachString: /*String*/Array = splitedString[i].split("");
					var addText:String = "";
					
					var charL : String = splitedString[i].toLowerCase();
					//アルファベット時の処理
					if (charL.length == 1 && charL.charCodeAt(0) >= "a".charCodeAt(0) && charL.charCodeAt(0) <= "z".charCodeAt(0)) {
						addText = charL;
					} else {
						
						for (j = 0; j < splittedStringEachString.length; j++ ) {
							t = splittedStringEachString[j];
							var tAbcVer:String = _convertKanaToABC(t);
							if (tAbcVer.match( /[gzdbp]/)) {
								var newTmpABC:String = ZtoS_TABLE[tAbcVer.split("")[0]] + tAbcVer.substring(1, tAbcVer.length);
								t = _convertABCToKana(newTmpABC);
								if (tAbcVer.match(/[p]/)) {
									t += "゜";
								} else {
									t += "゛";
								}
							}
							addText += t;
						}
					}
					inputStrArray.push(addText);
					inputStrString += addText;
				}
			}
			
			_targetStringABC = inputStrString;
			_targetStringEachArray = inputStrArray;
			_funcWhenStringUpdated(_targetStringPlain, inputStrString, _totalCount);
			_targetStringSplitedPlain = splitedString;
			
			//_funcForBackSpaceKey_delegate(_targetStringEachArray.join(""), _totalCount, "");
			_funcWhenStringUpdated(_targetStringPlain, _targetStringEachArray.join(""), _totalCount);
		}
		
		public function setTargetObject(target : DisplayObjectContainer) :void{
			_removeKeyEventListener();
			_targetObject = target;
			_setKeyEventListener();
		}
		
		public function setStringUpdatedListener(f : Function):void{
			_funcWhenStringUpdated = f;			
		}
		
		public function setTypingCompletedListener(f : Function):void{
			_funcWhenTypingCompleted = f;			
		}
		
		public function setInputMode(inputMode : int):void {
			_inputMode = inputMode;
			_prepareForInput();
		}
		
		public function setTargetString(targetString : String):void {
			_targetStringPlain = targetString;
			_prepareForInput();
		}
				
		public function setKeyTypedListener(f: Function ): void {
			_funcWhenKeyTyped = f;
		}
	}
	
}
class ChangedHistoryItem {
	public var index: int;
	public var content: String;
	public function ChangedHistoryItem(a: int, b: String) {
		index = a;
		content = b;
	}
}
class KeyCharInfo {
	private var _charCode:int = 0;
	private var _charStr:String = "";
	private var _isShifted:Boolean = false;
	private var _kanaChar: String = "";
	
	public function get charCode():int 
	{
		return _charCode;
	}
	
	public function set charCode(value:int):void 
	{
		_charCode = value;
	}
	
	public function get charStr():String 
	{
		return _charStr;
	}
	
	public function set charStr(value:String):void 
	{
		_charStr = value;
	}
	
	public function get isShifted():Boolean 
	{
		return _isShifted;
	}
	
	public function set isShifted(value:Boolean):void 
	{
		_isShifted = value;
	}
	
	public function get kanaChar():String 
	{
		return _kanaChar;
	}
	
	public function set kanaChar(value:String):void 
	{
		_kanaChar = value;
	}
}
class KeyCodeInfo {
	private var _keyCode: int = 0;
	private var _isShifted: Boolean = false;
	private var _kanaChar:String = "";
	public function get keyCode():int 
	{
		return _keyCode;
	}
	
	public function set keyCode(value:int):void 
	{
		_keyCode = value;
	}
	
	public function get isShifted():Boolean 
	{
		return _isShifted;
	}
	
	public function set isShifted(value:Boolean):void 
	{
		_isShifted = value;
	}
	
	public function get kanaChar():String 
	{
		return _kanaChar;
	}
	
	public function set kanaChar(value:String):void 
	{
		_kanaChar = value;
	}
}