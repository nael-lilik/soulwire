
/**		
 * 
 *	SimpleExample
 *	
 *	@version 1.00 | May 21, 2010
 *	@author Justin Windle
 *  
 **/
 
package  
{
	import uk.co.soulwire.display.DynamicSprite;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	/**
	 * SimpleExample
	 */
	public class SimpleExample extends Sprite 
	{
		public function SimpleExample()
		{
			// Load a library SWF
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest("assets_en.swf"));
		}

		private function onLoadComplete(event : Event) : void 
		{
			// Register this library
			DynamicSprite.update("example", LoaderInfo(event.target).content);
			
			// Creating a DynamicSprite after a library is loaded still works fine
			var example : DynamicSprite = new DynamicSprite("assets.example.HelloWorld");
			addChild(example);
		}
	}
}
