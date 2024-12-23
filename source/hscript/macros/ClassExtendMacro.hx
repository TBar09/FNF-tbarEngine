package hscript.macros;

#if macro
import haxe.macro.Type.ClassType;
import Type.ValueType;
import haxe.macro.Expr.Function;
import haxe.macro.Expr;
import haxe.macro.Type.MetaAccess;
import haxe.macro.Type.FieldKind;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.VarAccess;
import haxe.macro.*;
import Sys;

using StringTools;

class ClassExtendMacro {
	public static inline final FUNC_PREFIX = "_HX_SUPER__";
	public static inline final CLASS_SUFFIX = "_HSX";

	public static var unallowedMetas:Array<String> = [":bitmap", ":noCustomClass", ":generic"];

	public static var modifiedClasses:Array<String> = [];

	public static function init() {
		#if !display
		#if CUSTOM_CLASSES
		if(Context.defined("display")) return;
		for(apply in Config.ALLOWED_CUSTOM_CLASSES) {
			Compiler.addGlobalMetadata(apply, "@:build(hscript.macros.ClassExtendMacro.build())");
		}
		#end
		#end
	}

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null) return fields;
		var cl = clRef.get();

		if (cl.isAbstract || cl.isExtern || cl.isFinal || cl.isInterface) return fields;
		if (!cl.name.endsWith("_Impl_") && !cl.name.endsWith(CLASS_SUFFIX) && !cl.name.endsWith("_HSC")) {
			var metas = cl.meta.get();

			for(m in metas)
				if (unallowedMetas.contains(m.name))
					return fields;

			if(cl.params.length > 0)
				return fields;

			var key = cl.module;
			var fkey = cl.module + "." + cl.name;
			if(key == "sys.thread.FixedThreadPool") return fields; // Error: Type name sys.thread.Worker_HSX is redefined from module sys.thread.FixedThreadPool
			if(key == "StdTypes") return fields; // Error: Cant extend basic class
			if(key == "Xml") return fields; // Error: Cant extend basic class
			if(key == "Date") return fields; // Error: Cant extend basic class
			if(key == "away3d.tools.commands.Mirror") return fields; // Error: Unknown identifier
			if(key == "away3d.tools.commands.SphereMaker") return fields; // Error: Unknown identifier
			if(key == "away3d.tools.commands.Weld") return fields; // Error: Unknown identifier
			if(fkey == "hscript.CustomClassHandler.TemplateClass") return fields; // Error: Redefined
			if(key == "sys.thread.EventLoop") return fields; // Error: cant override force inlined
			if(Config.DISALLOW_CUSTOM_CLASSES.contains(cl.module) || Config.DISALLOW_CUSTOM_CLASSES.contains(fkey)) return fields;
			if(cl.module.contains("_")) return fields; // Weird issue, sorry

			var superFields = [];
			if(cl.superClass != null) {
				var _superFields = cl.superClass.t.get().fields.get();
				_superFields = []; // Comment to enable super support, (broken)
				for(field in _superFields) {
					if(!field.kind.match(FMethod(_))) // only catch methods
						continue;

					try {
						var nfield = @:privateAccess TypeTools.toField(field);
						switch ([field.kind, field.type]) {
							case [FMethod(kind), TFun(args, ret)]:
								if(kind == MethInline)
									nfield.access.push(AInline);
								if(kind == MethDynamic)
									nfield.access.push(ADynamic);
							default:
						}

						switch(nfield.kind) {
							case FFun(fun):
								if (fun.params != null && fun.params.length > 0)
									continue;

								fun.ret = Utils.fixStdTypes(fun.ret);

								var metas = nfield.meta;
								var defaultValues:Map<String, Dynamic> = [];
								var defaultEntry = null;
								var isGeneric = false;
								for(m in metas) {
									if(m.name == ":value") {
										defaultEntry = m;
										switch(m.params[0].expr) {
											case EObjectDecl(fields):
												for(fil in fields)
													defaultValues[fil.field] = fil.expr;
											default:
										}
									}
									if(m.name == ":generic")
										isGeneric = true;
								}
								if(isGeneric) continue;

								if(defaultEntry != null)
									metas.remove(defaultEntry);

								for(arg in fun.args) {
									var opt = false;
									if(defaultValues.exists(arg.name)) {
										arg.value = defaultValues[arg.name];
										arg.opt = false;
									}

									arg.type = Utils.fixStdTypes(arg.type);

									if(arg.opt) {
										if(arg.type.getParameters()[0].name != "Null")
											arg.type = TPath({name: "Null", params: [TPType(arg.type)], pack: []});//macro {Null<Dynamic>};
									}
								}
							default:
						}
						superFields.push(nfield);
					} catch(e) {

					}
				}
				//superFields = [];
			}

			var shadowClass = macro class {

			};

			var definedFields:Array<String> = [];

			//trace(getModuleName(cl));

			for(_field in [fields.copy(), superFields.copy()])
			for(f in _field) {
				if (f == null)
					continue;
				if (f.name == "new")
					continue;
				if (f.name.startsWith(FUNC_PREFIX))
					continue;
				if (f.access.contains(ADynamic) || f.access.contains(AStatic) || f.access.contains(AExtern) || f.access.contains(AInline))
					continue;

				if(f.name == "hget" || f.name == "hset") continue; // sorry, no overwriting the hget and hset in custom classes, yet
				if(definedFields.contains(f.name)) continue; // no duplicate fields

				for(m in f.meta)
					if (unallowedMetas.contains(m.name))
						continue;

				switch(f.kind) {
					case FFun(fun):
						if (fun == null)
							continue;
						if (fun.params != null && fun.params.length > 0) // TODO: Support for this maybe?
							continue;

						if(fun.params == null)
							fun.params = [];

						var overrideExpr:Expr;
						var returns:Bool = !fun.ret.match(TPath({name: "Void"}));

						var name = f.name;

						var arguments = fun.args == null ? [] : [for(a in fun.args) macro $i{a.name}];

						if (returns) {
							overrideExpr = macro {
								var name:String = $v{name};

								if (__interp != null) {
									var v:Dynamic = null;
									if (__interp.variables.exists(name) && Reflect.isFunction(v = __interp.variables.get(name))) {
										return v($a{arguments});
									}
								}
								return super.$name($a{arguments});
							};
						} else {
							overrideExpr = macro {
								var name:String = $v{name};

								if (__interp != null) {
									var v:Dynamic = null;
									if (__interp != null && __interp.variables.exists(name) && Reflect.isFunction(v = __interp.variables.get(name))) {
										v($a{arguments});
										return;
									}
								}
								super.$name($a{arguments});
							};
						}

						var superFuncExpr:Expr = returns ? {
							macro return super.$name($a{arguments});
						} : {
							macro super.$name($a{arguments});
						};

						var func:Function = {
							ret: fun.ret,
							params: fun.params.copy(),
							expr: overrideExpr,
							args: fun.args.copy()
						};

						var overrideField:Field = {
							name: f.name,
							access: f.access.copy(),
							kind: FFun(func),
							pos: Context.currentPos(),
							doc: f.doc,
							meta: f.meta.copy()
						};

						if (!overrideField.access.contains(AOverride))
							overrideField.access.push(AOverride);

						var superField:Field = {
							name: '$FUNC_PREFIX${f.name}',
							pos: Context.currentPos(),
							kind: FFun({
								ret: fun.ret,
								params: fun.params.copy(),
								expr: superFuncExpr,
								args: fun.args.copy()
							}),
							access: f.access.copy()
						};
						if (superField.access.contains(AOverride))
							superField.access.remove(AOverride);
						shadowClass.fields.push(overrideField);
						shadowClass.fields.push(superField);
						definedFields.push(f.name);
					default:
						// fuck off >:(

				}
			}

			shadowClass.kind = TDClass({
				pack: cl.pack.copy(),
				name: cl.name
			}, [
				{name: "IHScriptCustomBehaviour", pack: ["hscript"]}
			], false, true, false);
			shadowClass.name = '${cl.name}$CLASS_SUFFIX';
			var imports = Context.getLocalImports().copy();
			Utils.setupMetas(shadowClass, imports);

			// Adding hscript getters and setters

			shadowClass.fields.push({
				name: "__interp",
				pos: Context.currentPos(),
				kind: FVar(TPath({
					pack: ['hscript'],
					name: 'Interp'
				}))
			});

			// Todo: make it possible to override
			if(cl.name == "FunkinShader" || cl.name == "CustomShader" || cl.name == "MultiThreadedScript") {
				Context.defineModule(cl.module, [shadowClass], imports);
				return fields;
			}

			var hasHgetInSuper = false;
			var hasHsetInSuper = false;

			if(cl.name == "CustomShader") {
				hasHgetInSuper = hasHsetInSuper = true;
			}

			// TODO: somehow check the super super class
			for(_field in [fields.copy(), superFields.copy()])
			for(f in _field) {
				if (f.name == "new")
					continue;
				if (f.name.startsWith(FUNC_PREFIX))
					continue;
				if (f.access.contains(ADynamic) || f.access.contains(AStatic) || f.access.contains(AExtern))
					continue;

				switch(f.kind) {
					case FFun(fun):
						if (fun.params != null && fun.params.length > 0)
							continue;

						if(!hasHgetInSuper)
							hasHgetInSuper = f.name == "hget";
						if(!hasHsetInSuper)
							hasHsetInSuper = f.name == "hset";

						if(hasHgetInSuper && hasHsetInSuper)
							break;
					default:

				}
			}

			var hgetField = if(hasHgetInSuper) {
				macro {
					if(this.__interp.variables.exists("get_" + name))
						return this.__interp.variables.get("get_" + name)();
					if (this.__interp.variables.exists(name))
						return this.__interp.variables.get(name);
					return super.hget(name);
				}
			} else {
				macro {
					if(this.__interp.variables.exists("get_" + name))
						return this.__interp.variables.get("get_" + name)();
					if (this.__interp.variables.exists(name))
						return this.__interp.variables.get(name);
					return Reflect.getProperty(this, name);
				}
			}

			var hsetField = if(hasHsetInSuper) {
				macro {
					if(this.__interp.variables.exists("set_" + name)) {
						return this.__interp.variables.get("set_" + name)(val); // TODO: Prevent recursion from setting it in the function
					}
					if (this.__interp.variables.exists(name)) {
						this.__interp.variables.set(name, val);
						return val;
					}
					return super.hset(this, name);
				}
			} else {
				macro {
					if(this.__interp.variables.exists("set_" + name)) {
						return this.__interp.variables.get("set_" + name)(val); // TODO: Prevent recursion from setting it in the function
					}
					if (this.__interp.variables.exists(name)) {
						this.__interp.variables.set(name, val);
						return val;
					}
					Reflect.setProperty(this, name, val);
					return Reflect.field(this, name);
				}
			}

			//if(hasHsetInSuper || hasHgetInSuper) return fields;

			//trace(cl.name);

			shadowClass.fields.push({
				name: "hset",
				pos: Context.currentPos(),
				access: hasHsetInSuper ? [AOverride, APublic] : [APublic],
				kind: FFun({
					ret: TPath({name: 'Dynamic', pack: []}),
					params: [],
					expr: hsetField,
					args: [
						{
							name: "name",
							opt: false,
							meta: [],
							type: TPath({name: "String", pack: []})
						},
						{
							name: "val",
							opt: false,
							meta: [],
							type: TPath({name: "Dynamic", pack: []})
						}
					]
				})
			});

			shadowClass.fields.push({
				name: "hget",
				pos: Context.currentPos(),
				access: hasHgetInSuper ? [AOverride, APublic] : [APublic],
				kind: FFun({
					ret: TPath({name: 'Dynamic', pack: []}),
					params: [],
					expr: hgetField,
					args: [
						{
							name: "name",
							opt: false,
							meta: [],
							type: TPath({name: "String", pack: []})
						}
					]
				})
			});

			/*var p = new Printer();
			var aa = p.printTypeDefinition(shadowClass);
			if(aa.length < 5024)
			trace(aa);
			if(aa.indexOf("pack") >= 0)
			if(cl.name == "FunkinShader")*/

			Context.defineModule(cl.module, [shadowClass], imports);
		}

		return fields;
	}
}
#else
class ClassExtendMacro {
	public var usedClass:Class<Dynamic>;
	public var className:String;
}
#end