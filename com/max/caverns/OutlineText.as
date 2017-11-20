package com.max.caverns
{
	import org.flixel.*;

	public class OutlineText extends FlxText
	{
		private var leftText:FlxText;
		private var topText:FlxText;
		private var rightText:FlxText;
		private var downText:FlxText;
		
		public function OutlineText(X:Number, Y:Number, Width:uint, Text:String)
		{
			super(X, Y, Width, Text);
			this.color = 0xFFD700;
			leftText = new FlxText(X-1, Y, Width, Text);
			rightText = new FlxText(X+1, Y, Width, Text);
			topText = new FlxText(X-1, Y, Width, Text);
			downText = new FlxText(X+1, Y, Width, Text);
		}
		
		public function addChildren():void {
			FlxG.state.add(leftText);
			FlxG.state.add(rightText);
			FlxG.state.add(topText);
			FlxG.state.add(downText);
		}

        public function set xPos(value:Number):void {
           	x = value;
			leftText.x = value-1;
			topText.x = value;
			rightText.x = value+1;
			downText.x = value;
        }

        public function set yPos(value:Number):void {
           	y = value;
			leftText.y = value;
			topText.y = value-1;
			rightText.y = value;
			downText.y = value+1;
        }
	
		public function setText(text:String):void {
			super.text = text;
			leftText.text = text;
			topText.text = text;
			rightText.text = text;
			downText.text = text;
		}
		
		public function setVisible(value:Boolean):void {
			visible = value;
			leftText.visible = value;
			topText.visible = value;
			rightText.visible = value;
			downText.visible = value;
		}
	}
}