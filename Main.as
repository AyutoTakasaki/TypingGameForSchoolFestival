package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import info.kasaki.soft.typing_fw.*;
	
	/**
	 * ...
	 * @author j2420
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var tf:TextField = new TextField();
			tf.x = 50;
			tf.y = 150;
			tf.width = 600;
			tf.height = 200;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.wordWrap = true;
			
			var textFormat: TextFormat = new TextFormat();
			textFormat.size = 30;
			
			tf.defaultTextFormat = textFormat;
			stage.addChild(tf);
			
			var tf2:TextField = new TextField();
			tf2.x = 50;
			tf2.y = 300;
			tf2.width = 600;
			tf2.height = 200;
			tf2.autoSize = TextFieldAutoSize.LEFT;
			tf2.wordWrap = true;
						
			tf2.defaultTextFormat = textFormat;
			stage.addChild(tf2);
			
			var tf3:TextField = new TextField();
			tf3.x = 50;
			tf3.y = 50;
			tf3.width = 600;
			tf3.height = 200;
			tf3.autoSize = TextFieldAutoSize.LEFT;
			tf3.wordWrap = true;
						
			tf3.defaultTextFormat = textFormat;
			stage.addChild(tf3);
			
			var manager : TypingGameManager = new TypingGameManager();
			manager.setAreaToPressKey(stage);
			manager.setTypingGuideTextField(tf);
			manager.setTypedPlainTextTextField(tf2);
			//manager.setInputMode(KeyInputHandler.INPUT_TYPE_ABC);
			manager.setInputMode(KeyInputHandler.INPUT_TYPE_KANA);

			//http://www.nisc.go.jp/security-site/month/senryu.html
			
			manager.addTypingItem(new BasicTypingItem("飲み会で　PC無くせば　職無くす", "ゃー！"));
			
			manager.typeGuideTextColor = "ff0000";
			manager.setNewItemSettedListener(function(itemIndex: int, item: BasicTypingItem):void {
				//ここでFLASHの表示内容を変更（三行に分けて俳句表示など）
				tf3.text = item.getItemTitle() + "\n" + item.getItemContent();
			});
			
			manager.setKeyTypedListener(function(a, b, c, d, e): void {
				trace("typed" + e);
			});
			
			manager.setAllItemCompletedListener(function(totalCount: int, wrongCount: int, timeCount: int):void {
				//すべての項目のタイピングが終了、以下は正答率の表示
				trace((1 - (Number(wrongCount) / Number(totalCount))) * 100);
				trace((timeCount / 1000) + "秒経過");
				trace(manager.getWrongCountWithPlace());
			});
			
			manager.startGame();
						
		}
		
	}
	
}