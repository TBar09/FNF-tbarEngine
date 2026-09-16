package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;

enum WiggleEffectType
{
	DREAMY;
	WAVY;
	HEAT_WAVE_HORIZONTAL;
	HEAT_WAVE_VERTICAL;
	FLAG;
}

class WiggleEffect extends FlxShader
{
	public var effectType(default, set):WiggleEffectType = DREAMY;

	public var waveSpeed(default, set):Float = 0;

	public var waveFrequency(default, set):Float = 0;

	public var waveAmplitude(default, set):Float = 0;

	public var isPixel(default, set):Bool = false;

	@:glFragmentSource('
		#pragma header

		const int EFFECT_TYPE_DREAMY = 0;
		const int EFFECT_TYPE_WAVY = 1;
		const int EFFECT_TYPE_HEAT_WAVE_HORIZONTAL = 2;
		const int EFFECT_TYPE_HEAT_WAVE_VERTICAL = 3;
		const int EFFECT_TYPE_FLAG = 4;

		//uniform float tx,ty; // x, y waves phase
		uniform float uTime;

		/**
		 * The wiggle effect type
		 */
		uniform int uEffectType;

		/**
		 * Whether the wave effect should be antialiased. This only works on EFFECT_TYPE_DREAMY
		 */
		uniform bool uIsPixel;

		/**
		 * How fast the waves move over time
		 */
		uniform float uSpeed;

		/**
		 * Number of waves over time
		 */
		uniform float uFrequency;

		/**
		 * How much the pixels are going to stretch over the waves
		 */
		uniform float uWaveAmplitude;

		vec2 sineWave(vec2 pt)
		{
			float x = 0.0;
			float y = 0.0;

			if (uEffectType == EFFECT_TYPE_DREAMY) 
			{
				if(uIsPixel == true) {
					float w = 1.0 / openfl_TextureSize.y;
					float h = 1.0 / openfl_TextureSize.x;

					pt.x = floor(pt.x / h) * h;

					float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
					
					pt.y += floor(offsetX / w) * w; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
					pt.y = floor(pt.y / w) * w;

					float offsetY = sin(pt.y * (uFrequency / 2.0) + uTime * (uSpeed / 2.0)) * (uWaveAmplitude / 2.0);
				} else {
					float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
					pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
				}
			}
			else if (uEffectType == EFFECT_TYPE_WAVY) 
			{
				float offsetY = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
				pt.y += offsetY; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
			}
			else if (uEffectType == EFFECT_TYPE_HEAT_WAVE_HORIZONTAL)
			{
				x = sin(pt.x * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if (uEffectType == EFFECT_TYPE_HEAT_WAVE_VERTICAL)
			{
				y = sin(pt.y * uFrequency + uTime * uSpeed) * uWaveAmplitude;
			}
			else if (uEffectType == EFFECT_TYPE_FLAG)
			{
				y = sin(pt.y * uFrequency + 10.0 * pt.x + uTime * uSpeed) * uWaveAmplitude;
				x = sin(pt.x * uFrequency + 5.0 * pt.y + uTime * uSpeed) * uWaveAmplitude;
			}

			return vec2(pt.x + x, pt.y + y);
		}

		void main()
		{
			vec2 uv = sineWave(openfl_TextureCoordv);
			gl_FragColor = texture2D(bitmap, uv);
		}
	')
	public function new() {
		super();

		this.uTime.value = [0];
	}

	public function update(elapsed:Float):Void {
		this.uTime.value[0] += elapsed;
	}

	public function setValue(value:Float):Void {
		this.uTime.value[0] = value;
	}

	function set_effectType(v:WiggleEffectType):WiggleEffectType {
		effectType = v;
		this.uEffectType.value = [WiggleEffectType.getConstructors().indexOf(Std.string(v))];
		return v;
	}

	function set_waveSpeed(v:Float):Float {
		waveSpeed = v;
		this.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float {
		waveFrequency = v;
		this.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float {
		waveAmplitude = v;
		this.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}

	function set_isPixel(v:Bool):Bool {
		isPixel = v;
		this.uIsPixel.value = [isPixel];
		return isPixel;
	}
}

typedef WiggleShader = WiggleEffect;