
/**		
 * 
 *	GlitchmapDemo
 *	
 *	@version 1.00 | Feb 2, 2010
 *	@author Justin Windle
 *	@see http://blog.soulwire.co.uk
 *  
 **/
 
package  
{
	import uk.co.soulwire.display.Glitchmap;
	import uk.co.soulwire.utils.display.Alignment;
	import uk.co.soulwire.utils.display.DisplayUtils;

	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	import com.pfp.events.JPEGAsyncCompleteEvent;
	import com.pfp.utils.JPEGAsyncVectorEncoder;

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * GlitchmapDemo
	 */

	[SWF(width="900", height="650", backgroundColor="#FFFFFF", frameRate="31")]

	public class GlitchmapDemo extends Sprite 
	{

		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------

		private static const EXTENDED_FILETYPES : FileFilter = new FileFilter("Images", "*.png;*.gif;");

		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------

		private var _seedLabel : Label = new Label();		private var _seedSlider : Slider = new Slider();
		private var _iterationsLabel : Label = new Label();
		private var _iterationsSlider : Slider = new Slider();
		private var _glitchinessLabel : Label = new Label();
		private var _glitchinessSlider : Slider = new Slider();
		private var _loadButton : PushButton = new PushButton();		private var _saveButton : PushButton = new PushButton();		private var _downloadButton : PushButton = new PushButton();		private var _cancelButton : PushButton = new PushButton();		private var _downloadLabel : Label = new Label();
		private var _progressBar : ProgressBar = new ProgressBar();
		private var _progressLabel : Label = new Label();
		private var _animateCB : CheckBox = new CheckBox();

		private var _fileReference : FileReference = new FileReference();
		private var _glitchmap : Glitchmap = new Glitchmap();
		private var _byteLoader : Loader = new Loader();
		private var _interface : Sprite = new Sprite();		private var _progressOverlay : Sprite = new Sprite();		private var _downloadOverlay : Sprite = new Sprite();

		private var _imageName : String = "code-image.jpg";
		private var _encodedBytes : ByteArray;
		private var _encoder : JPEGAsyncVectorEncoder = new JPEGAsyncVectorEncoder(100);
		private var _bounds : Rectangle = new Rectangle(20, 20, 860, 570);		private var _limit : Rectangle = new Rectangle(0, 0, 800, 800);

		private var _animGlitchCounter : Number = 0.0;
		private var _animGlitchStep : Number = 0.08;
		private var _animGlitchiness : Number = 0.0;

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------

		public function GlitchmapDemo()
		{
			_encoder.PixelsPerIteration = 256;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------

		private function init() : void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			_glitchmap.addEventListener(Event.CHANGE, onInitialImageReady);
			_glitchmap.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);			_glitchmap.addEventListener(Event.COMPLETE, onLoadComplete);
			_glitchmap.loadImage("http://blog.soulwire.co.uk/wp-content/uploads/2010/02/code.jpg");
			addChild(_glitchmap);
			
			configureUI();
			//addChild(new Stats());
		}

		private function onLoadComplete(event : Event) : void
		{
			_glitchmap.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_glitchmap.removeEventListener(Event.COMPLETE, onLoadComplete);
		}

		private function onLoadProgress(event : ProgressEvent) : void
		{
			_progressBar.value = event.bytesLoaded / event.bytesTotal;
			_progressOverlay.visible = _progressBar.value < 1;
			_progressLabel.text = "[" + int(_progressBar.value * 100) + "%] LOADING IMAGE...";
		}

		private function configureUI() : void
		{
			// Glitchiness

			_glitchinessLabel.text = "GLITCH AMOUNT › 0.0";
			_glitchinessLabel.x = 10;			_glitchinessLabel.y = 2;
			
			_glitchinessSlider.minimum = 0.0;			_glitchinessSlider.maximum = 1.0;
			
			_glitchinessSlider.x = 10;
			_glitchinessSlider.y = 20;
			_glitchinessSlider.width = 200;
			
			// Iterations

			_iterationsLabel.text = "ITERATIONS › 128";
			_iterationsLabel.x = 220;
			_iterationsLabel.y = 2;

			_iterationsSlider.minimum = 128;
			_iterationsSlider.maximum = 1024;
			
			_iterationsSlider.x = 220;
			_iterationsSlider.y = 20;
			_iterationsSlider.width = 120;
			
			// Seed

			_seedLabel.text = "SEED › 1.0";
			_seedLabel.x = 350;
			_seedLabel.y = 2;

			_seedSlider.minimum = 1.0;
			_seedSlider.maximum = 1000.0;
			
			_seedSlider.x = 350;
			_seedSlider.y = 20;
			_seedSlider.width = 120;
			
			// Animate

			_animateCB.label = "START ANIMATION";
			_animateCB.x = 480;
			_animateCB.y = 20;
			
			// Load

			_loadButton.label = "LOAD IMAGE";
			_loadButton.x = 680;
			_loadButton.y = 10;
			
			// Save

			_saveButton.label = "SAVE IMAGE!";
			_saveButton.x = 790;
			_saveButton.y = 10;
			
			// Interface

			_interface.y = stage.stageHeight - 40;
			_interface.graphics.beginFill(0x222222);
			_interface.graphics.drawRect(0, 0, stage.stageWidth, 40);
			
			// Progress Overlay

			_progressLabel.text = "PROCESSING...";
			
			_progressLabel.x = _bounds.x + (_bounds.width >> 1) - 100;			_progressLabel.y = _bounds.y + (_bounds.height >> 1) - 20;
			
			_progressBar.x = _progressLabel.x;			_progressBar.y = _progressLabel.y + 20;
			_progressBar.width = 200;
			
			var pattern : BitmapData = new BitmapData(5, 5, true, 215 << 24);
			var col : uint = 230 << 24;
			
			pattern.setPixel32(2, 2, col);
			pattern.setPixel32(4, 2, col);
			pattern.setPixel32(3, 3, col);
			pattern.setPixel32(2, 4, col);
			pattern.setPixel32(4, 4, col);
			
			_progressOverlay.graphics.beginBitmapFill(pattern);
			_progressOverlay.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_progressOverlay.graphics.endFill();

			_progressOverlay.addChild(_progressBar);			_progressOverlay.addChild(_progressLabel);
			_progressOverlay.visible = false;
			
			// Download overlay

			_downloadLabel.text = "PROCESSING COMPLETE!";
			
			_downloadLabel.x = _bounds.x + (_bounds.width >> 1) - 100;
			_downloadLabel.y = _bounds.y + (_bounds.height >> 1) - 30;
			
			_downloadButton.label = "DOWNLOAD IMAGE";
			
			_downloadButton.x = _downloadLabel.x;
			_downloadButton.y = _downloadLabel.y + 20;
			_downloadButton.width = 200;
			
			_cancelButton.label = "CANCEL";
			
			_cancelButton.x = _downloadButton.x;
			_cancelButton.y = _downloadButton.y + 25;
			_cancelButton.width = 200;
			
			_downloadOverlay.graphics.beginBitmapFill(pattern);
			_downloadOverlay.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_downloadOverlay.graphics.endFill();
			
			_downloadOverlay.addChild(_downloadLabel);			_downloadOverlay.addChild(_downloadButton);			_downloadOverlay.addChild(_cancelButton);
			_downloadOverlay.visible = false;
			
			// Listeners

			_glitchinessSlider.addEventListener(Event.CHANGE, onComponentChanged);			_iterationsSlider.addEventListener(Event.CHANGE, onComponentChanged);			_seedSlider.addEventListener(Event.CHANGE, onComponentChanged);
			_animateCB.addEventListener(MouseEvent.CLICK, onAnimateClicked);
			_loadButton.addEventListener(MouseEvent.CLICK, onButtonClicked);			_saveButton.addEventListener(MouseEvent.CLICK, onButtonClicked);
			_downloadButton.addEventListener(MouseEvent.CLICK, onButtonClicked);
			_cancelButton.addEventListener(MouseEvent.CLICK, onButtonClicked);

			_interface.addChild(_glitchinessSlider);
			_interface.addChild(_glitchinessLabel);			_interface.addChild(_iterationsLabel);			_interface.addChild(_iterationsSlider);
			_interface.addChild(_seedSlider);
			_interface.addChild(_seedLabel);			_interface.addChild(_animateCB);
			_interface.addChild(_loadButton);			_interface.addChild(_saveButton);
			
			addChild(_interface);			addChild(_progressOverlay);			addChild(_downloadOverlay);
		}

		private function drawBorder() : void
		{
			var size : int = 5;
			
			graphics.clear();
			
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			graphics.beginFill(0xE5E5E5);
			graphics.drawRect(_glitchmap.x - size, _glitchmap.y - size, _glitchmap.width + (size * 2), _glitchmap.height + (size * 2));
			graphics.endFill();
		}

		private function loadImage() : void
		{
			_fileReference.addEventListener(Event.SELECT, onFileSelected);
			_fileReference.browse([Glitchmap.FILE_FILTER, EXTENDED_FILETYPES]);
		}

		private function saveImage() : void
		{
			_encoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onAsyncEncodeForSaveComplete);
			_encoder.addEventListener(ProgressEvent.PROGRESS, onAsyncEncodeForSaveProgress);
			_encoder.encode(_glitchmap.bitmapData);
		}

		private function downloadImage() : void
		{
			var filename : String = _imageName.substr(0, _imageName.lastIndexOf(".")) + "_GL1TCH3D.jpg";
			
			_fileReference = new FileReference();
			_fileReference.addEventListener(Event.SELECT, onDownloadLocationSelected);
			_fileReference.save(_encodedBytes, filename);
		}

		private function randomise() : void
		{
			_animGlitchCounter += _animGlitchStep;
			_animGlitchiness = (Math.sin(_animGlitchCounter) * 0.5) + 0.5;
			_glitchmap.glitchiness = _glitchinessSlider.value = 0.05 + (_animGlitchiness * 0.75);
			
			if(Math.random() < 0.1) _glitchmap.maxIterations = _iterationsSlider.value = 128 + (Math.random() * (512 - 128));
			if(Math.random() < 0.1) _glitchmap.seed = _seedSlider.value = Math.random() * 1000;
			if(Math.random() < 0.1) _animGlitchCounter += Math.random();
			if(Math.random() < 0.1) _animGlitchStep *= -1;
			
			_glitchinessLabel.text = "GLITCH AMOUNT › " + _glitchinessSlider.value.toFixed(2);
			_iterationsLabel.text = "ITERATIONS › " + int(_iterationsSlider.value);
			_seedLabel.text = "SEED › " + int(_seedSlider.value);
		}

		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}

		private function onInitialImageReady(event : Event) : void
		{
			DisplayUtils.fitIntoRect(_glitchmap, _bounds, false, Alignment.MIDDLE, true);
			
			_glitchmap.removeEventListener(Event.CHANGE, onInitialImageReady);
			_animateCB.selected = true;
			
			onAnimateClicked(null);
			drawBorder();
			randomise();
		}

		private function onFileSelected(event : Event) : void
		{
			_imageName = _fileReference.name;
			
			_fileReference.removeEventListener(Event.SELECT, onFileSelected);
			_fileReference.addEventListener(Event.COMPLETE, onFileLoadComplete);
			_fileReference.load();
		}

		private function onFileLoadComplete(event : Event) : void
		{
			_fileReference.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			
			_byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageBytesLoaded);
			_byteLoader.loadBytes(_fileReference.data);		}

		private function onImageBytesLoaded(event : Event) : void
		{
			_byteLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageBytesLoaded);
			_glitchmap.addEventListener(Event.CHANGE, onGlitchmapChanged);
			
			var filetype : String = _imageName.match(/\.([^\.]+)$/)[1].replace(/\?.*/, '').toLowerCase();
			var isJPG : Boolean = Glitchmap.FILE_FILTER.extension.indexOf(filetype) != -1;
			var isBig : Boolean = _byteLoader.width > _limit.width || _byteLoader.height > _limit.height;
			
			if(!isJPG || isBig)
			{
				var matrix : Matrix = DisplayUtils.fitIntoRect(_byteLoader.content, _limit, false, Alignment.TOP_LEFT, true);
				var copy : BitmapData = new BitmapData(_byteLoader.content.width, _byteLoader.content.height);
				copy.draw(_byteLoader.content, matrix, null, null, null, true);
				
				_encoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onAysncEncodeForLoadComplete);
				_encoder.addEventListener(ProgressEvent.PROGRESS, onAsyncEncodingProgress);
				_encoder.encode(copy);
			}
			else
			{
				_glitchmap.bytesSource = _fileReference.data;
			}
		}

		private function onAsyncEncodingProgress(event : ProgressEvent) : void
		{
			_progressBar.value = event.bytesLoaded / event.bytesTotal;
			_progressOverlay.visible = _progressBar.value < 1;
			_progressLabel.text = "[" + int(_progressBar.value * 100) + "%] PROCESSING...";
		}

		private function onAysncEncodeForLoadComplete(event : JPEGAsyncCompleteEvent) : void
		{
			_encoder.removeEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onAysncEncodeForLoadComplete);
			_encoder.removeEventListener(ProgressEvent.PROGRESS, onAsyncEncodingProgress);
				
			_glitchmap.bytesSource = event.ImageData;
		}

		private function onGlitchmapChanged(event : Event) : void
		{
			_glitchmap.removeEventListener(Event.CHANGE, onGlitchmapChanged);
			
			DisplayUtils.fitIntoRect(_glitchmap, _bounds, false, Alignment.MIDDLE, true);
			drawBorder();
		}

		private function onAsyncEncodeForSaveProgress(event : ProgressEvent) : void
		{
			_progressBar.value = event.bytesLoaded / event.bytesTotal;
			_progressOverlay.visible = _progressBar.value < 1;
			_downloadOverlay.visible = !_progressOverlay.visible;
			_progressLabel.text = "[" + int(_progressBar.value * 100) + "%] PROCESSING...";
		}

		private function onAsyncEncodeForSaveComplete(event : JPEGAsyncCompleteEvent) : void
		{
			_encoder.removeEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onAsyncEncodeForSaveComplete);
			_encoder.removeEventListener(ProgressEvent.PROGRESS, onAsyncEncodeForSaveProgress);
			_encodedBytes = event.ImageData;
			
			_downloadOverlay.visible = true;
		}

		private function onDownloadLocationSelected(event : Event) : void
		{
			_fileReference.removeEventListener(Event.SELECT, onDownloadLocationSelected);
			_downloadOverlay.visible = false;
		}

		private function onAnimateClicked(event : MouseEvent) : void
		{
			if(_animateCB.selected) addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			else removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			
			_animateCB.label = (_animateCB.selected ? "STOP" : "START") + " ANIMATION";
			
			for (var i : int = 0;i < _interface.numChildren;i++)
			{
				if(_interface.getChildAt(i) == _animateCB) continue;
				_interface.getChildAt(i).alpha = _animateCB.selected ? 0.25 : 1.0;
			}
		}

		private function onStageClicked(event : MouseEvent) : void
		{
			stage.removeEventListener(MouseEvent.CLICK, onStageClicked);
			_animateCB.selected = false;
			onAnimateClicked(null);
		}

		private function onEnterFrameHandler(event : Event) : void
		{
			randomise();
			if(!stage.hasEventListener(MouseEvent.CLICK)) stage.addEventListener(MouseEvent.CLICK, onStageClicked);
		}

		private function onComponentChanged(event : Event) : void
		{
			if(_animateCB.selected)
			{
				_animateCB.selected = false;
				onAnimateClicked(null);
			}
			
			switch(event.target)
			{
				case _glitchinessSlider : 
				
					_glitchmap.glitchiness = _glitchinessSlider.value;
					_glitchinessLabel.text = "GLITCH AMOUNT › " + _glitchinessSlider.value.toFixed(2);
					
					break;
					
				case _iterationsSlider : 
				
					_glitchmap.maxIterations = int(_iterationsSlider.value);
					_iterationsLabel.text = "ITERATIONS › " + int(_iterationsSlider.value);
				
					break;
					
				case _seedSlider : 
				
					_glitchmap.seed = int(_seedSlider.value);
					_seedLabel.text = "SEED › " + int(_seedSlider.value);
				
					break;
			}
		}

		private function onButtonClicked(event : MouseEvent) : void
		{
			if(_animateCB.selected)
			{
				_animateCB.selected = false;
				onAnimateClicked(null);
			}
			
			switch(event.target)
			{
				case _loadButton :
				
					loadImage();
				 
					break;
					
				case _saveButton :
				
					saveImage();
				 
					break;
					
				case _downloadButton :
				
					downloadImage();
				 
					break;
					
				case _cancelButton :
				
					_downloadOverlay.visible = false;
					
					break;
			}
		}
	}
}
