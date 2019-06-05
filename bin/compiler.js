getenv = function(k, p) {
  if (string63(k)) {
    var __i = edge(_G.environment);
    while (__i >= 0) {
      var __b = _G.environment[__i][k];
      if (is63(__b)) {
        var __e7 = undefined;
        if (p) {
          __e7 = __b[p];
        } else {
          __e7 = __b;
        }
        return __e7;
      } else {
        __i = __i - 1;
      }
    }
  }
};
var transformer_function = function(k) {
  return getenv(k, "transformer");
};
var transformer63 = function(k) {
  return is63(transformer_function(k));
};
var macro_function = function(k) {
  return getenv(k, "macro");
};
var macro63 = function(k) {
  return is63(macro_function(k));
};
var special63 = function(k) {
  return is63(getenv(k, "special"));
};
var special_form63 = function(form) {
  return !atom63(form) && special63(hd(form));
};
var statement63 = function(k) {
  return special63(k) && getenv(k, "stmt");
};
var symbol_expansion = function(k) {
  return getenv(k, "symbol");
};
var symbol63 = function(k) {
  return is63(symbol_expansion(k));
};
var variable63 = function(k) {
  return is63(getenv(k, "variable"));
};
bound63 = function(x) {
  return macro63(x) || special63(x) || symbol63(x) || variable63(x);
};
quoted = function(form) {
  if (string63(form)) {
    return escape(form);
  } else {
    if (atom63(form)) {
      return form;
    } else {
      return join(["list"], map(quoted, form));
    }
  }
};
unquoted = function(form) {
  if (nil63(form)) {
    return form;
  } else {
    if (string_literal63(form)) {
      if (read_string(form) === form) {
        return _eval(form);
      } else {
        return error("unquoted: bad string-literal");
      }
    } else {
      if (hd63(form, "quote")) {
        return form[1];
      } else {
        return compile(form, {_stash: true, ["escape-reserved"]: false});
      }
    }
  }
};
dequoted = function(x) {
  if (nil63(x)) {
    return x;
  } else {
    if (string_literal63(x)) {
      return unquoted(x);
    } else {
      if (!string63(x)) {
        return compile(x);
      } else {
        return x;
      }
    }
  }
};
var literal = function(s) {
  if (string_literal63(s)) {
    return s;
  } else {
    return quoted(s);
  }
};
stash_function = function(args) {
  if (keys63(args)) {
    var __l = ["%object", "\"_stash\"", true];
    var ____o = args;
    var __k = undefined;
    for (__k of pairs(____o)) {
      var __v = ____o[__k];
      if (!number63(__k)) {
        add(__l, literal(__k));
        add(__l, __v);
      }
    }
    return join(args, [__l]);
  } else {
    return args;
  }
};
var bias = function(k) {
  if (number63(k) && !(_G.target === "js")) {
    if (!(_G.target === "lua")) {
      k = k - 1;
    } else {
      k = k + 1;
    }
  }
  return k;
};
bind_atom = function(lh, rh) {
  if (atom63(lh)) {
    return [lh, rh];
  }
};
bind_optional = function(lh, rh) {
  if (hd63(lh, "o") || hd63(lh, "or") || hd63(lh, "&optional")) {
    var ____id = lh;
    var ___ = ____id[0];
    var ___var = ____id[1];
    var __val = ____id[2];
    return bind(___var, ["%if", ["=", rh, "nil"], __val || "nil", rh]);
  }
};
bind_destructuring = function(lh, rh) {
  var __id1 = unique("id");
  var __bs = [__id1, rh];
  var ____o1 = lh;
  var __k1 = undefined;
  for (__k1 of pairs(____o1)) {
    var __v1 = ____o1[__k1];
    var __e8 = undefined;
    if (__k1 === "rest") {
      __e8 = ["cut", __id1, _35(lh)];
    } else {
      __e8 = ["get", __id1, ["quote", bias(__k1)]];
    }
    var __x7 = __e8;
    __bs = join(__bs, bind(__v1, __x7));
  }
  return __bs;
};
brackets63 = function(x) {
  return hd63(x, "%brackets");
};
bind_brackets = function(lh, rh) {
  if (brackets63(lh)) {
    return bind(tl(lh), rh);
  }
};
dotted63 = function(l) {
  return {["&"]: true, ["."]: true}[l[_35(l) - 2]];
};
dotted = function(l) {
  if (dotted63(l)) {
    return join(cut(l, 0, _35(l) - 2), {rest: last(l)});
  }
};
bind_dotted = function(lh, rh) {
  if (dotted63(lh)) {
    return bind(dotted(lh), rh);
  }
};
bind = function(lh, rh) {
  return bind_atom(lh, rh) || bind_brackets(lh, rh) || bind_dotted(lh, rh) || bind_optional(lh, rh) || bind_destructuring(lh, rh);
};
bind_function = function(args, body) {
  var __args1 = [];
  var __e9 = undefined;
  if (brackets63(args)) {
    __e9 = tl(args);
  } else {
    __e9 = args;
  }
  var __args = __e9;
  var __e10 = undefined;
  if (dotted63(__args)) {
    __e10 = dotted(__args);
  } else {
    __e10 = __args;
  }
  var __args11 = __e10;
  var rest = function() {
    __args1.rest = true;
    return ["unstash", ["list", "..."]];
  };
  if (atom63(__args11)) {
    return [__args1, join(["let", [__args11, rest()]], body)];
  } else {
    var __bs1 = [];
    var __ks = {};
    var __r29 = unique("r");
    var ____o2 = __args11;
    var __k2 = undefined;
    for (__k2 of pairs(____o2)) {
      var __v2 = ____o2[__k2];
      if (number63(__k2)) {
        if (atom63(__v2)) {
          add(__args1, __v2);
        } else {
          var __x16 = unique("x");
          add(__args1, __x16);
          __bs1 = join(__bs1, [__v2, __x16]);
        }
      } else {
        __ks[__k2] = __v2;
      }
    }
    if (keys63(__args11)) {
      __bs1 = join(__bs1, [__r29, rest()]);
      var __n3 = _35(__args1);
      var __i4 = 0;
      while (__i4 < __n3) {
        var __v3 = __args1[__i4];
        __bs1 = join(__bs1, [__v3, ["destash!", __v3, __r29]]);
        __i4 = __i4 + 1;
      }
      __bs1 = join(__bs1, [__ks, __r29]);
    }
    return [__args1, join(["let", __bs1], body)];
  }
};
var quoting63 = function(depth) {
  return number63(depth);
};
var quasiquoting63 = function(depth) {
  return quoting63(depth) && depth > 0;
};
var can_unquote63 = function(depth) {
  return quoting63(depth) && depth === 1;
};
var quasisplice63 = function(x, depth) {
  return can_unquote63(depth) && !atom63(x) && hd(x) === "unquote-splicing";
};
auto_type = function() {
  return getenv("%%type", "type");
};
auto_value = function() {
  if (_G.target === "js" || _G.target === "lua") {
    return "nil";
  }
};
auto_local = function(name, value) {
  var __e11 = undefined;
  if (is63(value)) {
    __e11 = value;
  } else {
    __e11 = auto_value();
  }
  var __v4 = __e11;
  var __t = auto_type();
  if (is63(__t)) {
    var ____x24 = ["%local", name, __v4];
    ____x24.type = __t;
    return ____x24;
  } else {
    return ["%local", name, __v4];
  }
};
var expand_local = function(__x26) {
  var ____id2 = __x26;
  var __x27 = ____id2[0];
  var __name = ____id2[1];
  var __value = ____id2[2];
  var __type = ____id2.type;
  var __args2 = cut(____id2, 3);
  var __name1 = macroexpand(__name);
  var __type1 = macroexpand(__type);
  setenv(__name1, {_stash: true, variable: true, type: __type1});
  var __prev = __type1;
  add(_G.environment, {});
  var __e12 = undefined;
  if (is63(__type1)) {
    __e12 = setenv("%%type", {_stash: true, type: __type1});
  }
  var ____x28 = macroexpand(__value);
  drop(_G.environment);
  var __value1 = ____x28;
  var __args3 = map(macroexpand, __args2);
  return join([__x27, __name1, __value1], __args3);
};
var expand_block = function(__x30) {
  var ____id3 = __x30;
  var __x31 = ____id3[0];
  var __body = cut(____id3, 1);
  add(_G.environment, {});
  var ____x32 = join([__x31], map(macroexpand, __body));
  drop(_G.environment);
  return ____x32;
};
var expand_function = function(__x34) {
  var ____id4 = __x34;
  var __x35 = ____id4[0];
  var __args4 = ____id4[1];
  var __body1 = cut(____id4, 2);
  add(_G.environment, {});
  var ____o3 = __args4;
  var ____i5 = undefined;
  for (____i5 of pairs(____o3)) {
    var ____x36 = ____o3[____i5];
    setenv(____x36, {_stash: true, variable: true});
  }
  var ____x37 = join([__x35, __args4], map(macroexpand, __body1));
  drop(_G.environment);
  return ____x37;
};
var expand_definition = function(__x39) {
  var ____id5 = __x39;
  var __x40 = ____id5[0];
  var __name2 = ____id5[1];
  var __args5 = ____id5[2];
  var __body2 = cut(____id5, 3);
  add(_G.environment, {});
  var ____o4 = __args5;
  var ____i6 = undefined;
  for (____i6 of pairs(____o4)) {
    var ____x41 = ____o4[____i6];
    setenv(____x41, {_stash: true, variable: true});
  }
  var ____x42 = join([__x40, macroexpand(__name2), __args5], map(macroexpand, __body2));
  drop(_G.environment);
  return ____x42;
};
var expand_macro = function(form) {
  return macroexpand(expand1(form));
};
expand1 = function(__x44) {
  var ____id6 = __x44;
  var __name3 = ____id6[0];
  var __body3 = cut(____id6, 1);
  return apply(macro_function(__name3), __body3);
};
var expand_transformer = function(form) {
  return transformer_function(hd(hd(form)))(form);
};
macroexpand = function(form) {
  if (symbol63(form)) {
    return macroexpand(symbol_expansion(form));
  } else {
    if (atom63(form)) {
      return form;
    } else {
      var __x45 = hd(form);
      if (__x45 === "%local") {
        return expand_local(form);
      } else {
        if (__x45 === "%block") {
          return expand_block(form);
        } else {
          if (__x45 === "%function") {
            return expand_function(form);
          } else {
            if (__x45 === "%global-function") {
              return expand_definition(form);
            } else {
              if (__x45 === "%local-function") {
                return expand_definition(form);
              } else {
                if (macro63(__x45)) {
                  return expand_macro(form);
                } else {
                  if (hd63(__x45, transformer63)) {
                    return expand_transformer(form);
                  } else {
                    return map(macroexpand, form);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
};
var quasiquote_list = function(form, depth) {
  var __xs = [["list"]];
  var ____o5 = form;
  var __k3 = undefined;
  for (__k3 of pairs(____o5)) {
    var __v5 = ____o5[__k3];
    if (!number63(__k3)) {
      var __e13 = undefined;
      if (quasisplice63(__v5, depth)) {
        __e13 = quasiexpand(__v5[1]);
      } else {
        __e13 = quasiexpand(__v5, depth);
      }
      var __v6 = __e13;
      last(__xs)[__k3] = __v6;
    }
  }
  var ____x48 = form;
  var ____i8 = 0;
  while (____i8 < _35(____x48)) {
    var __x49 = ____x48[____i8];
    if (quasisplice63(__x49, depth)) {
      var __x50 = quasiexpand(__x49[1]);
      add(__xs, __x50);
      add(__xs, ["list"]);
    } else {
      add(last(__xs), quasiexpand(__x49, depth));
    }
    ____i8 = ____i8 + 1;
  }
  var __pruned = keep(function(x) {
  return _35(x) > 1 || !(hd(x) === "list") || keys63(x);
}, __xs);
  if (one63(__pruned)) {
    return hd(__pruned);
  } else {
    return join(["join"], __pruned);
  }
};
quasiexpand = function(form, depth) {
  if (quasiquoting63(depth)) {
    if (atom63(form)) {
      return ["quote", form];
    } else {
      if (can_unquote63(depth) && hd(form) === "unquote") {
        return quasiexpand(form[1]);
      } else {
        if (hd(form) === "unquote" || hd(form) === "unquote-splicing") {
          return quasiquote_list(form, depth - 1);
        } else {
          if (hd(form) === "quasiquote") {
            return quasiquote_list(form, depth + 1);
          } else {
            return quasiquote_list(form, depth);
          }
        }
      }
    }
  } else {
    if (atom63(form)) {
      return form;
    } else {
      if (hd(form) === "quote") {
        return form;
      } else {
        if (hd(form) === "quasiquote") {
          return quasiexpand(form[1], 1);
        } else {
          return map(function(x) {
  return quasiexpand(x, depth);
}, form);
        }
      }
    }
  }
};
expand_if = function(__x54) {
  var ____id7 = __x54;
  var __a = ____id7[0];
  var __b1 = ____id7[1];
  var __c = cut(____id7, 2);
  if (is63(__b1)) {
    return [join(["%if", __a, __b1], expand_if(__c))];
  } else {
    if (is63(__a)) {
      return [__a];
    }
  }
};
_G.indent_level = 0;
indentation = function() {
  var __s = "";
  var __i9 = 0;
  while (__i9 < _G.indent_level) {
    __s = __s + "  ";
    __i9 = __i9 + 1;
  }
  return __s;
};
_G.reserved = {js: {["="]: true, ["=="]: true, ["+"]: true, ["-"]: true, ["%"]: true, ["*"]: true, ["/"]: true, ["<"]: true, [">"]: true, ["<="]: true, [">="]: true, ["break"]: true, ["case"]: true, ["catch"]: true, ["class"]: true, ["const"]: true, ["continue"]: true, ["debugger"]: true, ["default"]: true, ["delete"]: true, ["do"]: true, ["else"]: true, ["eval"]: true, ["finally"]: true, ["for"]: true, ["function"]: true, ["if"]: true, ["import"]: true, ["in"]: true, ["instanceof"]: true, ["let"]: true, ["new"]: true, ["return"]: true, ["switch"]: true, ["throw"]: true, ["try"]: true, ["typeof"]: true, ["var"]: true, ["void"]: true, ["with"]: true}, lua: {["="]: true, ["=="]: true, ["+"]: true, ["-"]: true, ["%"]: true, ["*"]: true, ["/"]: true, ["<"]: true, [">"]: true, ["<="]: true, [">="]: true, and: true, end: true, ["in"]: true, load: true, repeat: true, while: true, ["break"]: true, false: true, local: true, ["return"]: true, ["do"]: true, ["for"]: true, nil: true, then: true, ["else"]: true, ["function"]: true, not: true, true: true, elseif: true, ["if"]: true, or: true, until: true}, c: {auto: true, ["break"]: true, ["case"]: true, ["const"]: true, ["continue"]: true, ["default"]: true, ["do"]: true, ["else"]: true, enum: true, extern: true, ["for"]: true, goto: true, ["if"]: true, inline: true, register: true, restrict: true, ["return"]: true, signed: true, sizeof: true, static: true, struct: true, ["switch"]: true, typedef: true, union: true, unsigned: true, ["void"]: true, volatile: true, while: true, _Alignas: true, _Alignof: true, _Atomic: true, _Bool: true, _Complex: true, _Generic: true, _Imaginary: true, _Noreturn: true, _Static_assert: true, _Thread_local: true}};
reserved63 = function(x) {
  return has63(_G.reserved[_G.target] || _G.reserved.js, x);
};
valid_code63 = function(n) {
  return number_code63(n) || uppercase_code63(n) || lowercase_code63(n) || n === 95 || _G.target === "c" && (n === 60 || n === 62 || n === 42 || n === 32) || _G.target === "js" && n === 36;
};
global_id63 = function(id) {
  var __n7 = _35(id);
  return __n7 > 1 && char(id, __n7 - 1) === "*" && valid_code63(code(id, __n7 - 2));
};
compile_id = function(id, escape_reserved63) {
  if (global_id63(id)) {
    var __e19 = undefined;
    if (_G.target === "c") {
      __e19 = "";
    } else {
      __e19 = "_G.";
    }
    return __e19 + compile_id(clip(id, 0, edge(id)), escape_reserved63);
  } else {
    if (char(id, 0) === ":" && _35(id) > 1) {
      if (_G.target === "c") {
        return camel_case(clip(id, 1)) + ":";
      } else {
        return "\"" + clip(id, 1) + "\"";
      }
    } else {
      var __e14 = undefined;
      if (number_code63(code(id, 0))) {
        __e14 = "_";
      } else {
        __e14 = "";
      }
      var __id11 = __e14;
      var __i10 = 0;
      while (__i10 < _35(id)) {
        var __c1 = char(id, __i10);
        var __n8 = code(__c1);
        var __e15 = undefined;
        if (__c1 === "-" && !(id === "-")) {
          __e15 = "_";
        } else {
          var __e16 = undefined;
          if (__c1 === "/" && !(__i10 === 0) && !(__i10 === edge(id))) {
            __e16 = "___";
          } else {
            var __e17 = undefined;
            if (valid_code63(__n8)) {
              __e17 = __c1;
            } else {
              var __e18 = undefined;
              if (__i10 === 0) {
                __e18 = "_" + __n8;
              } else {
                __e18 = __n8;
              }
              __e17 = __e18;
            }
            __e16 = __e17;
          }
          __e15 = __e16;
        }
        var __c11 = __e15;
        __id11 = __id11 + __c11;
        __i10 = __i10 + 1;
      }
      if (either(escape_reserved63, true) && reserved63(__id11)) {
        return "_" + __id11;
      } else {
        return __id11;
      }
    }
  }
};
valid_id63 = function(x, escape_reserved63) {
  return some63(x) && x === compile_id(x, escape_reserved63);
};
var __names = {};
unique = function(x) {
  var __x58 = compile_id(x, true);
  if (has63(__names, __x58)) {
    var __i11 = __names[__x58];
    __names[__x58] = __names[__x58] + 1;
    return unique(__x58 + __i11);
  } else {
    __names[__x58] = 1;
    return "__" + __x58;
  }
};
key = function(k) {
  if (string_literal63(k)) {
    var __i12 = inner(k);
    if (valid_id63(__i12)) {
      return __i12;
    } else {
      return "[" + k + "]";
    }
  } else {
    return "[" + compile(k) + "]";
  }
};
mapo = function(f, t) {
  var __o6 = [];
  var ____o7 = t;
  var __k4 = undefined;
  for (__k4 of pairs(____o7)) {
    var __v7 = ____o7[__k4];
    var __x59 = f(__v7);
    if (is63(__x59)) {
      add(__o6, literal(__k4));
      add(__o6, __x59);
    }
  }
  return __o6;
};
var ____x61 = [];
var ____x63 = [];
____x63.value = "!";
____x63.space = "";
var ____x62 = [____x63];
____x62.lua = "not";
____x61.not = ____x62;
var ____x64 = [];
var ____x66 = [];
____x66.value = ".";
____x66.space = "";
____x64["."] = [____x66];
var ____x68 = [];
____x68.value = "->";
____x68.space = "";
____x64["->"] = [____x68];
var ____x69 = [];
____x69["*"] = "*";
____x69["/"] = "/";
____x69["%"] = "%";
var ____x70 = [];
var ____x71 = ["+"];
____x71.lua = "..";
____x70.cat = ____x71;
var ____x72 = [];
____x72["+"] = "+";
____x72["-"] = "-";
var ____x73 = [];
____x73["<"] = "<";
____x73[">"] = ">";
____x73["<="] = "<=";
____x73[">="] = ">=";
var ____x74 = [];
var ____x75 = ["=="];
____x75.js = "===";
____x74["="] = ____x75;
var ____x76 = [];
var ____x77 = ["&&"];
____x77.lua = "and";
____x76.and = ____x77;
var ____x78 = [];
var ____x79 = ["||"];
____x79.lua = "or";
____x78.or = ____x79;
_G.infix = [____x61, ____x64, ____x69, ____x70, ____x72, ____x73, ____x74, ____x76, ____x78];
var ____x81 = [];
var ____x83 = [];
____x83.value = "-";
____x83.space = " ";
____x81["-"] = [____x83];
var ____x84 = [];
var ____x85 = [];
____x85.lh = "(";
____x85.value = "*";
____x85.rh = ")";
____x84.c = ____x85;
____x81["*"] = ____x84;
var ____x87 = [];
____x87.value = "!";
____x87.space = "";
var ____x86 = [____x87];
var ____x88 = [];
____x88.value = "not";
____x88.space = " ";
____x86.lua = ____x88;
____x81.not = ____x86;
_G.unary = [____x81];
var index = function(k) {
  return k;
};
precedence = function(form) {
  if (!(atom63(form) || unary63(form))) {
    var ____o8 = infix;
    var __k5 = undefined;
    for (__k5 of pairs(____o8)) {
      var __v8 = ____o8[__k5];
      if (__v8[hd(form)]) {
        return index(__k5);
      }
    }
  }
  return 0;
};
levelop = function(level, op, k) {
  var __x89 = level[op];
  if (obj63(__x89)) {
    var __e20 = undefined;
    if (has63(__x89, _G.target)) {
      __e20 = __x89[_G.target];
    } else {
      __e20 = hd(__x89);
    }
    var __r62 = __e20;
    if (nil63(k)) {
      return __r62;
    } else {
      if (obj63(__r62) && has63(__r62, k)) {
        return __r62[k];
      } else {
        if (string63(__r62) && k === "value") {
          return __r62;
        }
      }
    }
  } else {
    if (string63(__x89) && k === "value") {
      return __x89;
    }
  }
};
getop = function(ops, op, k, _default) {
  return either(find(function(level) {
  return levelop(level, op, k);
}, ops), _default);
};
inop = function(op, k, _default) {
  return getop(infix, op, k, _default);
};
unop = function(op, k, _default) {
  return getop(_G.unary, op, k, _default);
};
infix63 = function(x) {
  return is63(inop(x, "value"));
};
unary63 = function(form) {
  return two63(form) && unop(hd(form), "value");
};
infix_operator63 = function(x) {
  return obj63(x) && infix63(hd(x));
};
compile_args = function(args, sep, open, close) {
  var __close = either(close, ")");
  var __open = either(open, "(");
  var __sep = either(sep, ", ");
  var __c2 = "";
  var __s1 = __open;
  var ____x90 = _G.indent_level;
  _G.indent_level = 0;
  var ____x91 = args;
  var ____i15 = 0;
  while (____i15 < _35(____x91)) {
    var __x92 = ____x91[____i15];
    __s1 = __s1 + __c2 + compile(__x92);
    __c2 = __sep;
    ____i15 = ____i15 + 1;
  }
  var ____r71;
  _G.indent_level = ____x90;
  return __s1 + __close;
};
var escape_newlines = function(s) {
  var __s11 = "";
  var __i16 = 0;
  while (__i16 < _35(s)) {
    var __c3 = char(s, __i16);
    var __e21 = undefined;
    if (__c3 === "\n") {
      __e21 = "\\n";
    } else {
      var __e22 = undefined;
      if (__c3 === "\r") {
        __e22 = "";
      } else {
        __e22 = __c3;
      }
      __e21 = __e22;
    }
    __s11 = __s11 + __e21;
    __i16 = __i16 + 1;
  }
  return __s11;
};
compile_nil = function(x) {
  if (_G.target === "lua") {
    return "nil";
  } else {
    if (_G.target === "js") {
      return "undefined";
    } else {
      return "nil";
    }
  }
};
compile_boolean = function(x) {
  if (x) {
    return "true";
  } else {
    return "false";
  }
};
compile_atom = function(x, escape_reserved63) {
  if (x === "nil") {
    return compile_nil(x);
  } else {
    if (x === "...") {
      var __e23 = undefined;
      if (_G.target === "js") {
        __e23 = compile("*args");
      } else {
        __e23 = "";
      }
      return "..." + __e23;
    } else {
      if (id_literal63(x)) {
        return inner(x);
      } else {
        if (string_literal63(x)) {
          return escape_newlines(x);
        } else {
          if (string63(x)) {
            return compile_id(x, either(escape_reserved63, true));
          } else {
            if (boolean63(x)) {
              return compile_boolean(x);
            } else {
              if (nan63(x)) {
                return "nan";
              } else {
                if (x === inf) {
                  return "inf";
                } else {
                  if (x === _inf) {
                    return "-inf";
                  } else {
                    if (number63(x)) {
                      return x + "";
                    } else {
                      return error("Cannot compile atom: " + str(x));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
};
var terminator = function(stmt63) {
  if (!stmt63) {
    return "";
  } else {
    if (!(_G.target === "lua")) {
      return ";\n";
    } else {
      return "\n";
    }
  }
};
var compile_special = function(form, stmt63) {
  var ____id8 = form;
  var __x93 = ____id8[0];
  var __args6 = cut(____id8, 1);
  var ____id9 = getenv(__x93);
  var __special = ____id9.special;
  var __stmt = ____id9.stmt;
  var __self_tr63 = ____id9.tr;
  var __tr = terminator(stmt63 && !__self_tr63);
  var __e24 = undefined;
  if (stmt63 && !__self_tr63) {
    __e24 = indentation();
  } else {
    __e24 = "";
  }
  var __ind = __e24;
  if (form.ephemeral) {
    return "";
  } else {
    return __ind + apply(__special, __args6) + __tr;
  }
};
accessor_literal63 = function(x) {
  return string63(x) && (char(x, 0) === "." && !(char(x, 1) === ".") && some63(char(x, 1)) || char(x, 0) === "-" && char(x, 1) === ">" && some63(char(x, 2)));
};
accessor_form63 = function(x) {
  return obj63(x) && accessor_literal63(last(x));
};
accessor_prefix = function(x, dot) {
  if (_G.target === "c" && char(x, 0) === "-") {
    return "->";
  } else {
    return dot;
  }
};
accessor_suffix = function(x) {
  var __e25 = undefined;
  if (char(x, 0) === ".") {
    __e25 = 1;
  } else {
    __e25 = 2;
  }
  return clip(x, __e25);
};
accessor_literal = function(x) {
  return compile(camel_case(accessor_suffix(x)), {_stash: true, ["escape-reserved"]: false});
};
compile_method = function(f, args, chain63) {
  if (chain63 && none63(args)) {
    return f;
  } else {
    var __x94 = hd(args);
    if (accessor_literal63(__x94)) {
      return compile_method(f + accessor_prefix(__x94, ".") + accessor_literal(__x94), tl(args), true);
    } else {
      if (hd63(__x94, accessor_literal63)) {
        var __e26 = undefined;
        if (_G.target === "lua") {
          __e26 = ":";
        } else {
          __e26 = ".";
        }
        return compile_method(f + accessor_prefix(hd(__x94), __e26) + accessor_literal(hd(__x94)) + compile_args(tl(__x94)), tl(args), true);
      } else {
        return f + compile_args(args);
      }
    }
  }
};
var parenthesize_call63 = function(x) {
  return !atom63(x) && hd(x) === "%function" || precedence(x) > 0;
};
compile_call = function(form, ..._42args) {
  var ____r85 = unstash([..._42args]);
  var __form = destash33(form, ____r85);
  var ____id10 = ____r85;
  var __no_stash63 = ____id10["no-stash"];
  var __f = hd(__form);
  var __f1 = compile(__f);
  var __args7 = tl(__form);
  var __e27 = undefined;
  if (__no_stash63) {
    __e27 = __args7;
  } else {
    __e27 = stash_function(__args7);
  }
  var __args12 = compile_method("", __e27);
  if (parenthesize_call63(__f)) {
    return "(" + __f1 + ")" + __args12;
  } else {
    return __f1 + __args12;
  }
};
var op_delims = function(parent, child, right63) {
  var __e28 = undefined;
  if (right63) {
    __e28 = _6261;
  } else {
    __e28 = _62;
  }
  if (__e28(precedence(child), precedence(parent))) {
    return ["(", ")"];
  } else {
    return ["", ""];
  }
};
var compile_infix = function(form) {
  var ____id111 = form;
  var __op = ____id111[0];
  var ____id12 = cut(____id111, 1);
  var __a1 = ____id12[0];
  var __b2 = ____id12[1];
  var ____id13 = op_delims(form, __a1, false);
  var __ao = ____id13[0];
  var __ac = ____id13[1];
  var ____id14 = op_delims(form, __b2, true);
  var __bo = ____id14[0];
  var __bc = ____id14[1];
  var __a2 = compile(__a1);
  var __b3 = compile(__b2);
  var __e29 = undefined;
  if (unary63(form)) {
    __e29 = _G.unary;
  } else {
    __e29 = infix;
  }
  var __ops = __e29;
  var __x98 = hd(form);
  var __op1 = getop(__ops, __x98, "value");
  var __lh = getop(__ops, __x98, "lh", "");
  var __rh = getop(__ops, __x98, "rh", "");
  var __e30 = undefined;
  if (__ops === _G.unary) {
    __e30 = "";
  } else {
    __e30 = " ";
  }
  var __sp = getop(__ops, __x98, "space", __e30);
  if (__ops === _G.unary) {
    return __lh + __op1 + __ao + __sp + __a2 + __ac + __rh;
  } else {
    return __lh + __ao + __a2 + __ac + __sp + __op1 + __sp + __bo + __b3 + __bc + __rh;
  }
};
compile_function = function(args, body, ..._42args) {
  var ____r88 = unstash([..._42args]);
  var __args8 = destash33(args, ____r88);
  var __body4 = destash33(body, ____r88);
  var ____id15 = ____r88;
  var __name4 = ____id15.name;
  var __prefix = ____id15.prefix;
  var __infix = ____id15.infix;
  var __global63 = ____id15.global;
  var __async63 = ____id15.async;
  var __keyword = ____id15.keyword;
  var __generator63 = ____id15.generator;
  var __e31 = undefined;
  if (__name4) {
    __e31 = compile(__name4);
  } else {
    __e31 = "";
  }
  var __id16 = __e31;
  var __e32 = undefined;
  if (__global63 && !(_G.target === "c")) {
    __e32 = "_G." + __id16;
  } else {
    __e32 = __id16;
  }
  var __id17 = __e32;
  var __e33 = undefined;
  if (__args8.rest) {
    __e33 = join(__args8, ["..."]);
  } else {
    __e33 = __args8;
  }
  var __args13 = __e33;
  var __args9 = compile_args(__args13);
  _G.indent_level = _G.indent_level + 1;
  var ____x101 = compile(__body4, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __body5 = ____x101;
  var __ind1 = indentation();
  var __e34 = undefined;
  if (__prefix) {
    __e34 = __prefix + " ";
  } else {
    __e34 = "";
  }
  var __p = __e34;
  var __e35 = undefined;
  if (__generator63) {
    __e35 = "";
  } else {
    var __e36 = undefined;
    if (__infix) {
      __e36 = " " + __infix;
    } else {
      __e36 = "";
    }
    __e35 = __e36;
  }
  var __m = __e35;
  var __e37 = undefined;
  if (!(_G.target === "lua")) {
    __e37 = "";
  } else {
    __e37 = "end";
  }
  var __tr1 = __e37;
  var __e38 = undefined;
  if (__async63) {
    __e38 = "async ";
  } else {
    __e38 = "";
  }
  var __async1 = __e38;
  var __e39 = undefined;
  if (__generator63 && _G.target === "js") {
    __e39 = "function*";
  } else {
    __e39 = "function";
  }
  var __func = either(unquoted(__keyword), __e39);
  var __e40 = undefined;
  if (some63(__id17)) {
    __e40 = " ";
  } else {
    __e40 = "";
  }
  var __c4 = __e40;
  if (__name4) {
    __tr1 = __tr1 + "\n";
  }
  if (!(_G.target === "lua")) {
    return __async1 + __func + __c4 + __id17 + __args9 + __m + " {\n" + __body5 + __ind1 + "}" + __tr1;
  } else {
    return __p + __func + __c4 + __id17 + __args9 + __m + "\n" + __body5 + __ind1 + __tr1;
  }
};
var can_return63 = function(form) {
  return is63(form) && (atom63(form) || !(hd(form) === "return") && !statement63(hd(form)));
};
compile = function(form, ..._42args) {
  var ____r90 = unstash([..._42args]);
  var __form1 = destash33(form, ____r90);
  var ____id18 = ____r90;
  var __stmt1 = ____id18.stmt;
  var __esc63 = ____id18["escape-reserved"];
  if (nil63(__form1)) {
    return "";
  } else {
    if (special_form63(__form1)) {
      return compile_special(__form1, __stmt1);
    } else {
      var __tr2 = terminator(__stmt1);
      var __e41 = undefined;
      if (__stmt1) {
        __e41 = indentation();
      } else {
        __e41 = "";
      }
      var __ind2 = __e41;
      var __e42 = undefined;
      if (atom63(__form1)) {
        __e42 = compile_atom(__form1, either(__esc63, true));
      } else {
        var __e43 = undefined;
        if (infix63(hd(__form1))) {
          __e43 = compile_infix(__form1);
        } else {
          __e43 = compile_call(__form1);
        }
        __e42 = __e43;
      }
      var __form2 = __e42;
      return __ind2 + __form2 + __tr2;
    }
  }
};
lower_statement = function(form, tail63) {
  var __hoist = [];
  var __e = lower(form, __hoist, true, tail63);
  var __e44 = undefined;
  if (some63(__hoist) && is63(__e)) {
    __e44 = join(["%do"], __hoist, [__e]);
  } else {
    var __e45 = undefined;
    if (is63(__e)) {
      __e45 = __e;
    } else {
      var __e46 = undefined;
      if (_35(__hoist) > 1) {
        __e46 = join(["%do"], __hoist);
      } else {
        __e46 = hd(__hoist);
      }
      __e45 = __e46;
    }
    __e44 = __e45;
  }
  return either(__e44, ["%do"]);
};
lower_body = function(body, tail63) {
  add(_G.environment, {});
  var ____x107 = lower_statement(join(["%do"], body), tail63);
  drop(_G.environment);
  return ____x107;
};
lower_block = function(body, tail63) {
  return join(["%block", lower_body(body)], props(body));
};
var literal63 = function(form) {
  return atom63(form) || hd(form) === "%array" || hd(form) === "%object";
};
var standalone63 = function(form) {
  return !atom63(form) && !infix63(hd(form)) && !literal63(form) && !("get" === hd(form)) && !accessor_form63(form) || id_literal63(form);
};
var lower_do = function(args, hoist, stmt63, tail63) {
  var ____x110 = almost(args);
  var ____i17 = 0;
  while (____i17 < _35(____x110)) {
    var __x111 = ____x110[____i17];
    var ____y = lower(__x111, hoist, stmt63);
    if (yes(____y)) {
      var __e1 = ____y;
      if (standalone63(__e1)) {
        add(hoist, __e1);
      }
    }
    ____i17 = ____i17 + 1;
  }
  var __e2 = lower(last(args), hoist, stmt63, tail63);
  if (tail63 && can_return63(__e2)) {
    return ["return", __e2];
  } else {
    return __e2;
  }
};
var lower_set = function(args, hoist, stmt63, tail63) {
  var ____id19 = args;
  var __lh1 = ____id19[0];
  var __rh1 = ____id19[1];
  var __lh11 = lower(__lh1, hoist);
  var __rh11 = lower(__rh1, hoist);
  add(hoist, ["%set", __lh11, __rh11]);
  if (!(stmt63 && !tail63)) {
    return __lh11;
  }
};
var lower_if = function(args, hoist, stmt63, tail63) {
  var ____id20 = args;
  var __cond = ____id20[0];
  var __then = ____id20[1];
  var ___else = ____id20[2];
  if (stmt63) {
    var __e48 = undefined;
    if (is63(___else)) {
      __e48 = [lower_body([___else], tail63)];
    }
    return add(hoist, join(["%if", lower(__cond, hoist), lower_body([__then], tail63)], __e48));
  } else {
    var __e3 = unique("e");
    add(hoist, auto_local(__e3, "nil"));
    var __e47 = undefined;
    if (is63(___else)) {
      __e47 = [lower(["%set", __e3, ___else])];
    }
    add(hoist, join(["%if", lower(__cond, hoist), lower(["%set", __e3, __then])], __e47));
    return __e3;
  }
};
var lower_short = function(x, args, hoist, stmt63, tail63) {
  if (none63(args)) {
    if (x === "and") {
      return true;
    } else {
      return false;
    }
  } else {
    if (one63(args)) {
      return hd(args);
    } else {
      var ____id21 = args;
      var __a3 = ____id21[0];
      var __b4 = ____id21[1];
      var __hoist1 = [];
      var __b11 = lower(__b4, __hoist1);
      if (some63(__hoist1)) {
        var __id22 = unique("id");
        var __e49 = undefined;
        if (x === "and") {
          __e49 = ["%if", __id22, __b4, __id22];
        } else {
          __e49 = ["%if", __id22, __id22, __b4];
        }
        return lower(["%do", auto_local(__id22, __a3), __e49], hoist);
      } else {
        return [x, lower(__a3, hoist), __b11];
      }
    }
  }
};
var lower_try = function(args, hoist, tail63) {
  return add(hoist, ["%try", lower_body(args, tail63)]);
};
var lower_while = function(args, hoist) {
  var ____id23 = args;
  var __c5 = ____id23[0];
  var __body6 = cut(____id23, 1);
  var __pre = [];
  var __c6 = lower(__c5, __pre);
  var __e50 = undefined;
  if (none63(__pre)) {
    __e50 = ["%while", __c6, lower_body(__body6)];
  } else {
    __e50 = ["%while", true, join(["%do"], __pre, [["%if", ["not", __c6], ["break"]], lower_body(__body6)])];
  }
  return add(hoist, __e50);
};
var lower_for = function(args, hoist) {
  var ____id24 = args;
  var __t1 = ____id24[0];
  var __k6 = ____id24[1];
  var __body7 = cut(____id24, 2);
  return add(hoist, join(["%for", lower(__t1, hoist), __k6, lower_body(__body7)], props(__body7)));
};
var lower_function = function(args) {
  var ____id25 = args;
  var __a4 = ____id25[0];
  var __body8 = cut(____id25, 1);
  return join(["%function", __a4, lower_body(__body8, true)], props(__body8));
};
var lower_definition = function(kind, args, hoist, stmt63, tail63) {
  var ____id26 = args;
  var __name5 = ____id26[0];
  var __args10 = ____id26[1];
  var __body9 = cut(____id26, 2);
  var __name11 = lower(__name5, hoist);
  add(hoist, join([kind, __name11, __args10, lower_body(__body9, true)], props(__body9)));
  if (!(stmt63 && !tail63)) {
    return __name11;
  }
};
lower_local = function(form, hoist, stmt63, tail63) {
  var ____id27 = form;
  var __kind = ____id27[0];
  var __name6 = ____id27[1];
  var __value2 = ____id27[2];
  var __ephemeral63 = ____id27.ephemeral;
  var __type2 = ____id27.type;
  var __args111 = cut(____id27, 3);
  var __name12 = lower(__name6, hoist);
  var __type11 = lower(__type2, hoist);
  var __form11 = join([__kind, __name12, __value2], __args111);
  add(_G.environment, {});
  var __e51 = undefined;
  if (is63(__type11)) {
    __form11.type = __type11;
    __e51 = setenv("%%type", {_stash: true, type: __type11});
  }
  var __e52 = undefined;
  if (__ephemeral63) {
    __e52 = lower(__value2, hoist, stmt63, tail63);
  } else {
    lower_special(__form11, hoist, stmt63, tail63);
    var __e53 = undefined;
    if (!(stmt63 && !tail63)) {
      __e53 = __name12;
    }
    __e52 = __e53;
  }
  var ____x138 = __e52;
  drop(_G.environment);
  var __r106 = ____x138;
  if (!__ephemeral63) {
    setenv(__name12, {_stash: true, variable: true, type: __type11});
  }
  return __r106;
};
lower_call = function(form, hoist) {
  var __form3 = map(function(x) {
  return lower(x, hoist);
}, form);
  if (some63(__form3)) {
    return __form3;
  }
};
var lower_infix63 = function(form) {
  return _35(form) > 3 && infix63(hd(form));
};
var infix_form = function(__x139) {
  var ____id28 = __x139;
  var __x140 = ____id28[0];
  var __a5 = ____id28[1];
  var __bs2 = cut(____id28, 2);
  var ____x141 = __bs2;
  var ____i18 = 0;
  while (____i18 < _35(____x141)) {
    var __b5 = ____x141[____i18];
    __a5 = [__x140, __a5, __b5];
    ____i18 = ____i18 + 1;
  }
  return __a5;
};
var lower_pairwise63 = function(form) {
  return _35(form) > 3 && in63(hd(form), ["<", "<=", "=", ">=", ">"]);
};
var pairwise_form = function(__x144) {
  var ____id29 = __x144;
  var __x145 = ____id29[0];
  var __a6 = ____id29[1];
  var __bs3 = cut(____id29, 2);
  var __e4 = ["and"];
  var ____x147 = __bs3;
  var ____i19 = 0;
  while (____i19 < _35(____x147)) {
    var __b6 = ____x147[____i19];
    add(__e4, [__x145, __a6, __b6]);
    __a6 = __b6;
    ____i19 = ____i19 + 1;
  }
  return __e4;
};
lower_special = function(form, hoist, stmt63, tail63) {
  var __e5 = lower_call(form, hoist);
  if (__e5) {
    return add(hoist, __e5);
  }
};
lower = function(form, hoist, stmt63, tail63) {
  if (atom63(form)) {
    return form;
  } else {
    if (empty63(form)) {
      return ["%array"];
    } else {
      if (nil63(hoist)) {
        return lower_statement(form);
      } else {
        if (lower_pairwise63(form)) {
          return lower(pairwise_form(form), hoist, stmt63, tail63);
        } else {
          if (lower_infix63(form)) {
            return lower(infix_form(form), hoist, stmt63, tail63);
          } else {
            var ____id30 = form;
            var __x150 = ____id30[0];
            var __args121 = cut(____id30, 1);
            if (__x150 === "%do") {
              return lower_do(__args121, hoist, stmt63, tail63);
            } else {
              if (__x150 === "%block") {
                return lower_block(__args121, tail63);
              } else {
                if (__x150 === "%call") {
                  return lower(__args121, hoist, stmt63, tail63);
                } else {
                  if (__x150 === "%set") {
                    return lower_set(__args121, hoist, stmt63, tail63);
                  } else {
                    if (__x150 === "%if") {
                      return lower_if(__args121, hoist, stmt63, tail63);
                    } else {
                      if (__x150 === "%try") {
                        return lower_try(__args121, hoist, tail63);
                      } else {
                        if (__x150 === "%while") {
                          return lower_while(__args121, hoist);
                        } else {
                          if (__x150 === "%for") {
                            return lower_for(__args121, hoist);
                          } else {
                            if (__x150 === "%function") {
                              return lower_function(__args121);
                            } else {
                              if (__x150 === "%local-function" || __x150 === "%global-function") {
                                return lower_definition(__x150, __args121, hoist, stmt63, tail63);
                              } else {
                                if (__x150 === "%local") {
                                  return lower_local(form, hoist, stmt63, tail63);
                                } else {
                                  if (in63(__x150, ["and", "or"])) {
                                    return lower_short(__x150, __args121, hoist, stmt63, tail63);
                                  } else {
                                    if (statement63(__x150)) {
                                      return lower_special(form, hoist, stmt63, tail63);
                                    } else {
                                      return lower_call(form, hoist);
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
};
expand = function(form) {
  return lower(macroexpand(form));
};
var run = eval;
_G._37result = undefined;
_eval = function(form) {
  var __previous = _G.target;
  _G.target = "js";
  var __code = compile(expand(["set", "%result", form]));
  _G.target = __previous;
  run(__code);
  return _37result;
};
immediate_call63 = function(x) {
  return obj63(x) && obj63(hd(x)) && hd(hd(x)) === "%function";
};
setenv("%do", {_stash: true, special: function(..._42args) {
  var __forms = unstash([..._42args]);
  var __s2 = "";
  var ____x154 = __forms;
  var ____i20 = 0;
  while (____i20 < _35(____x154)) {
    var __x155 = ____x154[____i20];
    if (_G.target === "lua" && immediate_call63(__x155) && "\n" === char(__s2, edge(__s2))) {
      __s2 = clip(__s2, 0, edge(__s2)) + ";\n";
    }
    __s2 = __s2 + compile(__x155, {_stash: true, stmt: true});
    if (!atom63(__x155)) {
      if (hd(__x155) === "return" || hd(__x155) === "break") {
        break;
      }
    }
    ____i20 = ____i20 + 1;
  }
  return __s2;
}, stmt: true, tr: true});
setenv("%brackets", {_stash: true, special: function(..._42args) {
  var __forms1 = unstash([..._42args]);
  if (_G.target === "c") {
    return compile_args(__forms1, " ", "[", "]");
  } else {
    return compile(join(["%array"], __forms1));
  }
}});
setenv("%braces", {_stash: true, special: function(..._42args) {
  var __forms2 = unstash([..._42args]);
  return compile(join(["%object"], __forms2));
}});
setenv("%block", {_stash: true, special: function(..._42args) {
  var ____r118 = unstash([..._42args]);
  var ____id31 = ____r118;
  var __prefix1 = ____id31.prefix;
  var __forms3 = cut(____id31, 0);
  var __e54 = undefined;
  if (is63(__prefix1)) {
    __e54 = trim(compile(__prefix1, {_stash: true, stmt: true}), testify_of({[";"]: true, [" "]: true, ["\n"]: true})) + " ";
  } else {
    __e54 = "";
  }
  var __p1 = __e54;
  var __s3 = indentation() + __p1 + "{\n";
  _G.indent_level = _G.indent_level + 1;
  var ____x162 = __forms3;
  var ____i21 = 0;
  while (____i21 < _35(____x162)) {
    var __x163 = ____x162[____i21];
    __s3 = __s3 + compile(__x163, {_stash: true, stmt: true});
    ____i21 = ____i21 + 1;
  }
  var ____x161;
  _G.indent_level = _G.indent_level - 1;
  __s3 = __s3 + indentation() + "}\n";
  return __s3;
}, stmt: true, tr: true});
setenv("%if", {_stash: true, special: function(cond, cons, alt) {
  var __cond1 = compile(cond);
  _G.indent_level = _G.indent_level + 1;
  var ____x164 = compile(cons, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __cons = ____x164;
  var __e55 = undefined;
  if (alt) {
    _G.indent_level = _G.indent_level + 1;
    var ____x165 = compile(alt, {_stash: true, stmt: true});
    _G.indent_level = _G.indent_level - 1;
    __e55 = ____x165;
  }
  var __alt = __e55;
  var __ind3 = indentation();
  var __s4 = "";
  if (!(_G.target === "lua")) {
    __s4 = __s4 + __ind3 + "if (" + __cond1 + ") {\n" + __cons + __ind3 + "}";
  } else {
    __s4 = __s4 + __ind3 + "if " + __cond1 + " then\n" + __cons;
  }
  if (__alt && !(_G.target === "lua")) {
    __s4 = __s4 + " else {\n" + __alt + __ind3 + "}";
  } else {
    if (__alt) {
      __s4 = __s4 + __ind3 + "else\n" + __alt;
    }
  }
  if (_G.target === "lua") {
    return __s4 + __ind3 + "end\n";
  } else {
    return __s4 + "\n";
  }
}, stmt: true, tr: true});
setenv("%while", {_stash: true, special: function(cond, form) {
  var __cond2 = compile(cond);
  _G.indent_level = _G.indent_level + 1;
  var ____x166 = compile(form, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __body10 = ____x166;
  var __ind4 = indentation();
  if (!(_G.target === "lua")) {
    return __ind4 + "while (" + __cond2 + ") {\n" + __body10 + __ind4 + "}\n";
  } else {
    return __ind4 + "while " + __cond2 + " do\n" + __body10 + __ind4 + "end\n";
  }
}, stmt: true, tr: true});
setenv("%names", {_stash: true, special: function(..._42args) {
  var __args131 = unstash([..._42args]);
  if (one63(__args131)) {
    return compile(hd(__args131));
  } else {
    var __e56 = undefined;
    if (!(_G.target === "lua")) {
      __e56 = "[";
    } else {
      __e56 = "";
    }
    var __s5 = __e56;
    var __c7 = "";
    var ____x168 = __args131;
    var ____i22 = 0;
    while (____i22 < _35(____x168)) {
      var __x169 = ____x168[____i22];
      __s5 = __s5 + __c7 + compile(__x169);
      __c7 = ", ";
      ____i22 = ____i22 + 1;
    }
    var __e57 = undefined;
    if (!(_G.target === "lua")) {
      __e57 = "]";
    } else {
      __e57 = "";
    }
    return __s5 + __e57;
  }
}});
setenv("%for", {_stash: true, special: function(t, k, form, ..._42args) {
  var ____r121 = unstash([..._42args]);
  var __t2 = destash33(t, ____r121);
  var __k7 = destash33(k, ____r121);
  var __form4 = destash33(form, ____r121);
  var ____id32 = ____r121;
  var __await63 = ____id32.await;
  var __t3 = compile(__t2);
  var __k8 = compile(__k7);
  var __ind5 = indentation();
  _G.indent_level = _G.indent_level + 1;
  var ____x171 = compile(__form4, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __body11 = ____x171;
  var __e58 = undefined;
  if (__await63) {
    __e58 = "await ";
  } else {
    __e58 = "";
  }
  var __a7 = __e58;
  if (_G.target === "lua") {
    return __ind5 + "for " + __k8 + " in " + __t3 + " do\n" + __body11 + __ind5 + "end\n";
  } else {
    return __ind5 + "for " + __a7 + "(" + __k8 + " of " + __t3 + ") {\n" + __body11 + __ind5 + "}\n";
  }
}, stmt: true, tr: true});
setenv("%try", {_stash: true, special: function(form) {
  var __e6 = unique("e");
  var __ind6 = indentation();
  _G.indent_level = _G.indent_level + 1;
  var ____x172 = compile(form, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __body12 = ____x172;
  var __hf = ["return", ["%array", false, __e6]];
  _G.indent_level = _G.indent_level + 1;
  var ____x175 = compile(__hf, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  var __h = ____x175;
  return __ind6 + "try {\n" + __body12 + __ind6 + "}\n" + __ind6 + "catch (" + __e6 + ") {\n" + __h + __ind6 + "}\n";
}, stmt: true, tr: true});
setenv("%delete", {_stash: true, special: function(place) {
  return "delete " + compile(place);
}, stmt: true});
setenv("break", {_stash: true, special: function() {
  return "break";
}, stmt: true});
setenv("%function", {_stash: true, special: function(args, ..._42args) {
  var ____r125 = unstash([..._42args]);
  var __args14 = destash33(args, ____r125);
  var ____id33 = ____r125;
  var __arrow63 = ____id33.arrow;
  var __type3 = ____id33.type;
  var __body13 = cut(____id33, 0);
  if (_G.target === "js" && __arrow63) {
    var ____x177 = [__args14];
    ____x177.keyword = "";
    ____x177.infix = "=>";
    return apply(compile_function, join(____x177, __body13));
  } else {
    if (_G.target === "c") {
      var ____x178 = [__args14];
      ____x178.keyword = __type3;
      return apply(compile_function, join(____x178, __body13));
    } else {
      return apply(compile_function, join([__args14], __body13));
    }
  }
}});
setenv("%global-function", {_stash: true, special: function(name, args, ..._42args) {
  var ____r126 = unstash([..._42args]);
  var __name7 = destash33(name, ____r126);
  var __args15 = destash33(args, ____r126);
  var ____id34 = ____r126;
  var __type4 = ____id34.type;
  var __body14 = cut(____id34, 0);
  if (!(_G.target === "js")) {
    var ____x182 = [__args15];
    ____x182.name = __name7;
    var __e59 = undefined;
    if (_G.target === "c") {
      __e59 = __type4;
    }
    ____x182.keyword = __e59;
    ____x182.global = true;
    var __x181 = apply(compile_function, join(____x182, __body14));
    return indentation() + __x181;
  } else {
    return compile(["%set", __name7, join(["%function", __args15], __body14)], {_stash: true, stmt: true});
  }
}, stmt: true, tr: true});
setenv("%local-function", {_stash: true, special: function(name, args, ..._42args) {
  var ____r127 = unstash([..._42args]);
  var __name8 = destash33(name, ____r127);
  var __args16 = destash33(args, ____r127);
  var ____id35 = ____r127;
  var __type5 = ____id35.type;
  var __body15 = cut(____id35, 0);
  if (!(_G.target === "js")) {
    var ____x187 = [__args16];
    ____x187.name = __name8;
    var __e60 = undefined;
    if (_G.target === "c") {
      __e60 = __type5;
    }
    ____x187.keyword = __e60;
    var __e61 = undefined;
    if (_G.target === "lua") {
      __e61 = "local";
    }
    ____x187.prefix = __e61;
    var __x186 = apply(compile_function, join(____x187, __body15));
    return indentation() + __x186;
  } else {
    return compile(["%local", __name8, join(["%function", __args16], __body15)], {_stash: true, stmt: true});
  }
}, stmt: true, tr: true});
setenv("return", {_stash: true, special: function(x) {
  if (nil63(x)) {
    return "return";
  } else {
    return "return " + compile(x);
  }
}, stmt: true});
setenv("new", {_stash: true, special: function(x, count) {
  var __e62 = undefined;
  if (obj63(x)) {
    __e62 = x;
  } else {
    __e62 = [x];
  }
  var ____id36 = __e62;
  var __type6 = ____id36[0];
  var __args17 = cut(____id36, 1);
  var __t4 = dequoted(__type6);
  if (nil63(count)) {
    return "new " + __t4 + compile_args(__args17);
  } else {
    return "new " + __t4 + "[" + compile(count) + "]";
  }
}});
setenv("typeof", {_stash: true, special: function(x) {
  return "typeof(" + compile(x) + ")";
}});
setenv("throw", {_stash: true, special: function(x) {
  if (_G.target === "js") {
    return "throw " + compile(x);
  } else {
    return "error(" + compile(x) + ")";
  }
}, stmt: true});
default_value63 = function(value, type) {
  return _G.target === "c" && value === "nil";
};
setenv("%local", {_stash: true, special: function(name, value, ..._42args) {
  var ____r133 = unstash([..._42args]);
  var __name9 = destash33(name, ____r133);
  var __value3 = destash33(value, ____r133);
  var ____id37 = ____r133;
  var __type7 = ____id37.type;
  var __id38 = compile(__name9);
  var __type12 = dequoted(__type7);
  var __e63 = undefined;
  if (default_value63(__value3, __type12)) {
    __e63 = undefined;
  } else {
    __e63 = __value3;
  }
  var __value4 = __e63;
  var __value11 = compile(__value4);
  var __e64 = undefined;
  if (is63(__value4)) {
    __e64 = " = " + __value11;
  } else {
    __e64 = "";
  }
  var __rh2 = __e64;
  var __e65 = undefined;
  if (_G.target === "c") {
    __e65 = either(__type12, "auto");
  } else {
    var __e66 = undefined;
    if (_G.target === "lua") {
      __e66 = "local";
    } else {
      __e66 = "var";
    }
    __e65 = __e66;
  }
  var __keyword1 = __e65;
  return __keyword1 + " " + __id38 + __rh2;
}, stmt: true});
setenv("%set", {_stash: true, special: function(lh, rh) {
  var __lh2 = compile(lh);
  var __e67 = undefined;
  if (nil63(rh)) {
    __e67 = "nil";
  } else {
    __e67 = rh;
  }
  var __rh3 = compile(__e67);
  return __lh2 + " = " + __rh3;
}, stmt: true});
setenv("get", {_stash: true, special: function(t, k) {
  var __t11 = compile(t);
  var __k11 = compile(k, {_stash: true, ["escape-reserved"]: false});
  if (_G.target === "lua" && char(__t11, 0) === "{" || infix_operator63(t)) {
    __t11 = "(" + __t11 + ")";
  }
  if (string_literal63(k) && valid_id63(inner(k))) {
    return __t11 + "." + inner(k);
  } else {
    return __t11 + "[" + __k11 + "]";
  }
}});
setenv("%array", {_stash: true, special: function(..._42args) {
  var __forms4 = unstash([..._42args]);
  var __e68 = undefined;
  if (_G.target === "lua") {
    __e68 = "{";
  } else {
    __e68 = "[";
  }
  var __open1 = __e68;
  var __e69 = undefined;
  if (_G.target === "lua") {
    __e69 = "}";
  } else {
    __e69 = "]";
  }
  var __close1 = __e69;
  var __s6 = "";
  var __c8 = "";
  var ____o9 = __forms4;
  var __k9 = undefined;
  for (__k9 of pairs(____o9)) {
    var __v9 = ____o9[__k9];
    if (number63(__k9)) {
      __s6 = __s6 + __c8 + compile(__v9);
      __c8 = ", ";
    }
  }
  return __open1 + __s6 + __close1;
}});
setenv("%object", {_stash: true, special: function(..._42args) {
  var __forms5 = unstash([..._42args]);
  var __s7 = "{";
  var __c9 = "";
  var __e70 = undefined;
  if (_G.target === "lua") {
    __e70 = " = ";
  } else {
    __e70 = ": ";
  }
  var __sep1 = __e70;
  var ____o10 = pair(__forms5);
  var __k10 = undefined;
  for (__k10 of pairs(____o10)) {
    var __v10 = ____o10[__k10];
    if (number63(__k10)) {
      var ____id39 = __v10;
      var __k111 = ____id39[0];
      var __v11 = ____id39[1];
      __s7 = __s7 + __c9 + key(__k111) + __sep1 + compile(__v11);
      __c9 = ", ";
    }
  }
  return __s7 + "}";
}});
setenv("%literal", {_stash: true, special: function(..._42args) {
  var __args18 = unstash([..._42args]);
  return apply(cat, map(unquoted, __args18));
}});
setenv("%stmt", {_stash: true, special: function(..._42args) {
  var __args19 = unstash([..._42args]);
  var __s8 = indentation();
  var ____x196 = __args19;
  var ____i25 = 0;
  while (____i25 < _35(____x196)) {
    var __x197 = ____x196[____i25];
    __s8 = __s8 + unquoted(__x197);
    ____i25 = ____i25 + 1;
  }
  __s8 = __s8 + "\n";
  return __s8;
}, stmt: true, tr: true});
setenv("unpack", {_stash: true, special: function(x) {
  if (_G.target === "lua") {
    return "(unpack or table.unpack)(" + compile(x) + ")";
  } else {
    return "..." + compile(x);
  }
}});
setenv("%@", {_stash: true, special: function(x) {
  return "@" + compile(x);
}});
setenv("%newline", {_stash: true, special: function() {
  return "\n";
}, stmt: true, tr: true});
setenv("%indent", {_stash: true, special: function(x) {
  _G.indent_level = _G.indent_level + 1;
  var ____x198 = compile(x, {_stash: true, stmt: true});
  _G.indent_level = _G.indent_level - 1;
  return ____x198;
}, stmt: true, tr: true});
var __e71 = undefined;
if (typeof(exports) === "undefined") {
  __e71 = {};
} else {
  __e71 = exports;
}
var __exports = __e71;
__exports.run = run;
__exports.eval = _eval;
__exports.expand = expand;
__exports.compile = compile;
__exports;
