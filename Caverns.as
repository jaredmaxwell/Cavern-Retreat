package {
	import org.flixel.FlxGame;
	import com.max.caverns.*;
	import com.max.caverns.state.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class Caverns extends FlxGame
	{
		public function Caverns():void
		{
			super(320,240,PlayStateScroll,2);
		}
	}
}
