package com.max.caverns
{
	import com.adamatomic.flixel.*;

	public class OutlineText extends FlxText
	{
		private var leftText:FlxText;
		private var topText:FlxText;
		private var rightText:FlxText;
		private var downText:FlxText;
		
		public function OutlineText(X:Number, Y:Number, Width:uint, Height:uint, Text:String, Color:uint=0x000000, Font:String=null, Size:uint=8, Justification:String=null, Angle:Number=0)
		{
			super(X, Y, Width, Height, Text, Color, Font, Size, Justification, Angle);
			leftText = new FlxText(X-1, Y, Width, Height, Text, 0x000000, Font, Size, Justification, Angle);
			rightText = new FlxText(X+1, Y, Width, Height, Text, 0x000000, Font, Size, Justification, Angle);
			topText = new FlxText(X-1, Y, Width, Height, Text, 0x000000, Font, Size, Justification, Angle);
			downText = new FlxText(X+1, Y, Width, Height, Text, 0x000000, Font, Size, Justification, Angle);
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
	
		override public function setText(Text:String):void {
			super.setText(Text);
			leftText.setText(Text);
			topText.setText(Text);
			rightText.setText(Text);
			downText.setText(Text);
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