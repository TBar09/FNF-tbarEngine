package hscript;

import hscript.utils.UnsafeReflect;

// TODO: EnumTools for scripted enums
/**
 * Wrapper class for enums, both for real and scripted.
 */
@:structInit
class HEnum implements IHScriptCustomBehaviour {
	private var enumValues(default, null) = {};

	public function setEnum(name:String, enumValue:Dynamic):Void {
		UnsafeReflect.setField(enumValues, name, enumValue);
	}

	public function getEnum(name:String):Null<Dynamic> {
		if (UnsafeReflect.hasField(enumValues, name))
			return UnsafeReflect.field(enumValues, name);
		return null;
	}

	public function hget(name:String):Dynamic {
		return getEnum(name);
	}

	public function hset(name:String, val:Dynamic):Dynamic {
		return null;
	}
}

@:nullSafety
@:structInit
class HEnumValue {
	public var enumName:String;
	public var fieldName:String;
	public var index:Int;
	public var args:Array<Dynamic>;

	public function toString():String {
		return '$enumName.$fieldName${args.length > 0 ? '(${[for (a in args) a].join(", ")})' : ''}';
	}

	public inline function getEnumName():String
		return this.enumName;

	public inline function getConstructorArgs():Array<Dynamic>
		return this.args;

	public function compare(other:HEnumValue):Bool {
		if (enumName != other.enumName || fieldName != other.fieldName)
			return false;
		if (args.length == 0 && other.args.length == 0)
			return true;
		if (args.length == 0 || other.args.length == 0)
			return false;
		if (args.length != other.args.length)
			return false;

		for (i in 0...args.length) // TODO: allow deep comparison, like arrays
			if (args[i] != other.args[i])
				return false;

		return true;
	}

	// functions from base enums
	public function equals(otherEnum:HEnumValue):Bool
		return this.compare(otherEnum);

	public function getIndex():Int
		return this.index;

	public function getName():String
		return this.fieldName;

	public function getParameters():Array<Dynamic>
		return this.getConstructorArgs();
}
