package com.max.caverns
{
	import com.adamatomic.flixel.*;
	import flash.geom.Point;
	
	public class CavernLevel
	{
		private var leftLevel:CavernLevel;
		private var topLevel:CavernLevel;
		private var rightLevel:CavernLevel;
		private var bottomLevel:CavernLevel;
		private var missingBlocks:Array;
		private var levelNum:uint;
		
		public function CavernLevel(levelNum:uint, previousLevel:CavernLevel=null, direction:String=null) 
		{
			this.levelNum = levelNum;
			if (previousLevel != null)
			{
				if (direction == "left")
				{
					leftLevel = previousLevel;
				}
				else if (direction == "right")
				{
					rightLevel = previousLevel;
				}
				else if (direction == "top")
				{
					topLevel = previousLevel;
				}
				else if (direction == "bottom")
				{
					bottomLevel = previousLevel;
				}
			}
		}
		
		public function get MissingBlocks():Array { return missingBlocks; }
		public function set MissingBlocks(value:Array):void 
		{
			missingBlocks = value;
		}
		
		
		public function get LeftLevel():CavernLevel { return leftLevel; }
		public function set LeftLevel(value:CavernLevel):void 
		{
			leftLevel = value;
		}
		
		public function get TopLevel():CavernLevel { return topLevel; }
		public function set TopLevel(value:CavernLevel):void 
		{
			topLevel = value;
		}
		
		public function get RightLevel():CavernLevel { return rightLevel; }
		public function set RightLevel(value:CavernLevel):void 
		{
			rightLevel = value;
		}
		
		public function get BottomLevel():CavernLevel { return bottomLevel; }
		public function set BottomLevel(value:CavernLevel):void 
		{
			bottomLevel = value;
		}
		
		public function get LevelNum():uint { return levelNum; }
		public function set LevelNum(value:uint):void 
		{
			levelNum = value;
		}
		
	}
	
}