_G.environment = {{}}
_G.target = "lua"
local __v = nil
function values(...)
  return ...
end
function results(x, ...)
  return {x, ...}
end
function nil63(x)
  return x == nil
end
function is63(x)
  return not nil63(x)
end
function no(x)
  return nil63(x) or x == false
end
function yes(x)
  return not no(x)
end
function either(x, y)
  if is63(x) then
    return x
  else
    return y
  end
end
function has63(l, k)
  return is63(l[k])
end
function _35(x)
  return #x
end
function none63(x)
  return _35(x) == 0
end
function some63(x)
  return _35(x) > 0
end
function one63(x)
  return _35(x) == 1
end
function two63(x)
  return _35(x) == 2
end
function hd(l)
  return l[1]
end
function string63(x)
  return type(x) == "string"
end
function number63(x)
  return type(x) == "number"
end
function boolean63(x)
  return type(x) == "boolean"
end
function function63(x)
  return type(x) == "function"
end
function obj63(x)
  return is63(x) and type(x) == "table"
end
function atom63(x)
  return nil63(x) or string63(x) or number63(x) or boolean63(x)
end
function hd63(l, x)
  local __id1 = obj63(l)
  local __e1 = nil
  if __id1 then
    local __e2 = nil
    if function63(x) then
      __e2 = x(hd(l))
    else
      __e2 = hd(l) == x
    end
    __e1 = __e2
  else
    __e1 = __id1
  end
  return __e1
end
nan = 0 / 0
inf = 1 / 0
_inf = - inf
function nan63(n)
  return not( n == n)
end
function inf63(n)
  return n == inf or n == _inf
end
function clip(s, from, upto)
  return string.sub(s, from + 1, upto)
end
function natural63(i)
  return number63(i) and i > 0 and i % 1 == 0
end
function index63(i)
  return natural63(i)
end
function reduce(f, l, r)
  local __from = inf
  local __upto = _inf
  local ____o = l
  local __k = nil
  for __k in pairs(____o) do
    local __v1 = ____o[__k]
    if index63(__k) then
      if __k < __from then
        __from = __k
      end
      if __k > __upto then
        __upto = __k
      end
    else
      r = f(r, __v1, __k, nil)
    end
  end
  __from = __from - 1
  local __i1 = __from
  while __i1 < __upto do
    local __v2 = l[__i1 + 1]
    r = f(r, __v2, nil, __i1)
    __i1 = __i1 + 1
  end
  return values(r, __from, __upto)
end
function cut(x, from, upto)
  local __l = {}
  local __j = 0
  local __e3 = nil
  if nil63(from) or from < 0 then
    __e3 = 0
  else
    __e3 = from
  end
  local __i2 = __e3
  local __n1 = _35(x)
  local __e4 = nil
  if nil63(upto) or upto > __n1 then
    __e4 = __n1
  else
    __e4 = upto
  end
  local __upto1 = __e4
  while __i2 < __upto1 do
    __l[__j + 1] = x[__i2 + 1]
    __i2 = __i2 + 1
    __j = __j + 1
  end
  local ____o1 = x
  local __k1 = nil
  for __k1 in pairs(____o1) do
    local __v3 = ____o1[__k1]
    if not number63(__k1) then
      __l[__k1] = __v3
    end
  end
  return __l
end
function keys(x)
  local __t = {}
  local ____o2 = x
  local __k2 = nil
  for __k2 in pairs(____o2) do
    local __v4 = ____o2[__k2]
    if not number63(__k2) then
      __t[__k2] = __v4
    end
  end
  return __t
end
function edge(x)
  return _35(x) - 1
end
function inner(x)
  return clip(x, 1, edge(x))
end
function tl(l)
  return cut(l, 1)
end
function char(s, n)
  return clip(s, n, n + 1)
end
function code(s, n)
  local __e5 = nil
  if n then
    __e5 = n + 1
  end
  return string.byte(s, __e5)
end
function from_code(n)
  return string.char(n)
end
function string_literal63(x)
  return string63(x) and char(x, 0) == "\""
end
function id_literal63(x)
  return string63(x) and char(x, 0) == "|"
end
function add(l, x)
  return table.insert(l, x)
end
function drop(l)
  return table.remove(l)
end
function last(l)
  return l[edge(l) + 1]
end
function almost(l)
  return cut(l, 0, edge(l))
end
function reverse(l)
  local __l1 = keys(l)
  local __i5 = edge(l)
  while __i5 >= 0 do
    add(__l1, l[__i5 + 1])
    __i5 = __i5 - 1
  end
  return __l1
end
function join(...)
  local __ls = unstash({...})
  local __r42 = {}
  local ____x3 = __ls
  local ____i6 = 0
  while ____i6 < _35(____x3) do
    local __l11 = ____x3[____i6 + 1]
    if __l11 then
      local __n4 = _35(__r42)
      local ____o3 = __l11
      local __k3 = nil
      for __k3 in pairs(____o3) do
        local __v5 = ____o3[__k3]
        if number63(__k3) then
          __k3 = __k3 + __n4
        end
        __r42[__k3] = __v5
      end
    end
    ____i6 = ____i6 + 1
  end
  return __r42
end
function testify(x, test)
  if function63(x) then
    return x
  else
    if test then
      return function (y)
        return test(y, x)
      end
    else
      return function (y)
        return x == y
      end
    end
  end
end
function find(x, t)
  local __f = testify(x)
  local ____o4 = t
  local ____i8 = nil
  for ____i8 in pairs(____o4) do
    local __x4 = ____o4[____i8]
    local __y = __f(__x4)
    if __y then
      return __y
    end
  end
end
function first(x, l, pos)
  local __f1 = testify(x)
  local __i9 = either(pos, 0)
  local __n7 = -1
  local ____o5 = l
  local __k4 = nil
  for __k4 in pairs(____o5) do
    local __v6 = ____o5[__k4]
    if number63(__k4) then
      __k4 = __k4 - 1
      __n7 = max(__n7, __k4)
    end
  end
  __n7 = __n7 + 1
  while __i9 < __n7 do
    local __v7 = l[__i9 + 1]
    local ____y1 = __f1(__v7)
    if yes(____y1) then
      local __y2 = ____y1
      return __i9
    end
    __i9 = __i9 + 1
  end
end
function in63(x, t)
  return find(testify(x), t)
end
function pair(l)
  local __l12 = {}
  local __i11 = 0
  while __i11 < _35(l) do
    add(__l12, {l[__i11 + 1], l[__i11 + 1 + 1]})
    __i11 = __i11 + 1
    __i11 = __i11 + 1
  end
  return __l12
end
function sort(l, f)
  table.sort(l, f)
  return l
end
function map(f, x)
  local __t1 = {}
  local ____x6 = x
  local ____i12 = 0
  while ____i12 < _35(____x6) do
    local __v8 = ____x6[____i12 + 1]
    local __y3 = f(__v8)
    if is63(__y3) then
      add(__t1, __y3)
    end
    ____i12 = ____i12 + 1
  end
  local ____o6 = x
  local __k5 = nil
  for __k5 in pairs(____o6) do
    local __v9 = ____o6[__k5]
    if not number63(__k5) then
      local __y4 = f(__v9)
      if is63(__y4) then
        __t1[__k5] = __y4
      end
    end
  end
  return __t1
end
function keep(v, x)
  local __f2 = testify(v)
  return map(function (v)
    if yes(__f2(v)) then
      return v
    end
  end, x)
end
function keys63(t)
  local ____o7 = t
  local __k6 = nil
  for __k6 in pairs(____o7) do
    local __v10 = ____o7[__k6]
    if not number63(__k6) then
      return true
    end
  end
  return false
end
function empty63(t)
  local ____o8 = t
  local ____i15 = nil
  for ____i15 in pairs(____o8) do
    local __x7 = ____o8[____i15]
    return false
  end
  return true
end
function stash(args)
  if keys63(args) then
    local __p = {}
    local ____o9 = args
    local __k7 = nil
    for __k7 in pairs(____o9) do
      local __v11 = ____o9[__k7]
      if not number63(__k7) then
        __p[__k7] = __v11
      end
    end
    __p._stash = true
    add(args, __p)
  end
  return args
end
function unstash(args)
  if none63(args) then
    return {}
  else
    local __l2 = last(args)
    if obj63(__l2) and __l2._stash then
      local __args1 = almost(args)
      local ____o10 = __l2
      local __k8 = nil
      for __k8 in pairs(____o10) do
        local __v12 = ____o10[__k8]
        if not( __k8 == "_stash") then
          __args1[__k8] = __v12
        end
      end
      return __args1
    else
      return args
    end
  end
end
function destash33(l, args1)
  if obj63(l) and l._stash then
    local ____o11 = l
    local __k9 = nil
    for __k9 in pairs(____o11) do
      local __v13 = ____o11[__k9]
      if not( __k9 == "_stash") then
        args1[__k9] = __v13
      end
    end
  else
    return l
  end
end
function search(s, pattern, start)
  local __e6 = nil
  if start then
    __e6 = start + 1
  end
  local __start = __e6
  local __i19 = string.find(s, pattern, __start, true)
  return __i19 and __i19 - 1
end
function split(s, sep)
  if s == "" or sep == "" then
    return {}
  else
    local __l3 = {}
    local __n15 = _35(sep)
    while true do
      local __i20 = search(s, sep)
      if nil63(__i20) then
        break
      else
        add(__l3, clip(s, 0, __i20))
        s = clip(s, __i20 + __n15)
      end
    end
    add(__l3, s)
    return __l3
  end
end
function cat(s, ...)
  return reduce(function (a, b)
    return a .. b
  end, {...}, s or "")
end
function _43(n, ...)
  return reduce(function (a, b)
    return a + b
  end, {...}, n or 0)
end
function _45(n, ...)
  return reduce(function (a, b)
    return a - b
  end, {...}, n or 0)
end
function _42(n, ...)
  return reduce(function (a, b)
    return a * b
  end, {...}, either(n, 1))
end
function _47(n, ...)
  return reduce(function (a, b)
    return a / b
  end, {...}, either(n, 1))
end
function _37(n, ...)
  return reduce(function (a, b)
    return a % b
  end, {...}, either(n, 1))
end
local function pairwise(f, xs)
  local __i21 = 0
  while __i21 < edge(xs) do
    local __a = xs[__i21 + 1]
    local __b = xs[__i21 + 1 + 1]
    if not f(__a, __b) then
      return false
    end
    __i21 = __i21 + 1
  end
  return true
end
function _60(...)
  local __xs = unstash({...})
  return pairwise(function (a, b)
    return a < b
  end, __xs)
end
function _62(...)
  local __xs1 = unstash({...})
  return pairwise(function (a, b)
    return a > b
  end, __xs1)
end
function _61(...)
  local __xs2 = unstash({...})
  return pairwise(function (a, b)
    return a == b
  end, __xs2)
end
function _6061(...)
  local __xs3 = unstash({...})
  return pairwise(function (a, b)
    return a <= b
  end, __xs3)
end
function _6261(...)
  local __xs4 = unstash({...})
  return pairwise(function (a, b)
    return a >= b
  end, __xs4)
end
function number(s)
  return tonumber(s)
end
function number_code63(n)
  return n > 47 and n < 58
end
function numeric63(s)
  local __n16 = _35(s)
  local __i22 = 0
  while __i22 < __n16 do
    if not number_code63(code(s, __i22)) then
      return false
    end
    __i22 = __i22 + 1
  end
  return some63(s)
end
function lowercase_code63(n)
  return n > 96 and n < 123
end
function camel_case(str)
  local __s = ""
  local __n17 = _35(str)
  local __i23 = 0
  while __i23 < __n17 do
    local __c = code(str, __i23)
    if __c == 45 and lowercase_code63(code(str, __i23 - 1) or 0) and lowercase_code63(code(str, __i23 + 1) or 0) then
      __i23 = __i23 + 1
      __c = code(str, __i23) - 32
    end
    __s = __s .. from_code(__c)
    __i23 = __i23 + 1
  end
  return __s
end
function escape(s)
  local __s1 = "\""
  local __i24 = 0
  while __i24 < _35(s) do
    local __c1 = char(s, __i24)
    local __e7 = nil
    if __c1 == "\n" then
      __e7 = "\\n"
    else
      local __e8 = nil
      if __c1 == "\r" then
        __e8 = "\\r"
      else
        local __e9 = nil
        if __c1 == "\"" then
          __e9 = "\\\""
        else
          local __e10 = nil
          if __c1 == "\\" then
            __e10 = "\\\\"
          else
            __e10 = __c1
          end
          __e9 = __e10
        end
        __e8 = __e9
      end
      __e7 = __e8
    end
    local __c11 = __e7
    __s1 = __s1 .. __c11
    __i24 = __i24 + 1
  end
  return __s1 .. "\""
end
function str(x, stack)
  if string63(x) then
    return escape(x)
  else
    if atom63(x) then
      return tostring(x)
    else
      if function63(x) then
        return "function"
      else
        if stack and in63(x, stack) then
          return "circular"
        else
          if not( type(x) == "table") then
            return escape(tostring(x))
          else
            local __s11 = "("
            local __sp = ""
            local __xs5 = {}
            local __ks = {}
            local __l4 = stack or {}
            add(__l4, x)
            local ____o12 = x
            local __k10 = nil
            for __k10 in pairs(____o12) do
              local __v14 = ____o12[__k10]
              if number63(__k10) then
                __xs5[__k10] = str(__v14, __l4)
              else
                if not string63(__k10) then
                  __k10 = str(__k10, __l4)
                end
                add(__ks, __k10 .. ":")
                add(__ks, str(__v14, __l4))
              end
            end
            drop(__l4)
            local ____o13 = join(__xs5, __ks)
            local ____i26 = nil
            for ____i26 in pairs(____o13) do
              local __v15 = ____o13[____i26]
              __s11 = __s11 .. __sp .. __v15
              __sp = " "
            end
            return __s11 .. ")"
          end
        end
      end
    end
  end
end
function apply(f, args)
  return f((unpack or table.unpack)(stash(args)))
end
function call(f, ...)
  return f(...)
end
function setenv(k, ...)
  local ____r88 = unstash({...})
  local __k11 = destash33(k, ____r88)
  local ____id = ____r88
  local __keys = cut(____id, 0)
  if string63(__k11) then
    local __e11 = nil
    if __keys.toplevel then
      __e11 = hd(_G.environment)
    else
      __e11 = last(_G.environment)
    end
    local __frame = __e11
    local __entry = __frame[__k11] or {}
    local ____o14 = __keys
    local __k12 = nil
    for __k12 in pairs(____o14) do
      local __v16 = ____o14[__k12]
      __entry[__k12] = __v16
    end
    __frame[__k11] = __entry
    return __frame[__k11]
  end
end
local math = math
abs = math.abs
acos = math.acos
asin = math.asin
atan = math.atan
atan2 = math.atan2
ceil = math.ceil
cos = math.cos
floor = math.floor
log = math.log
log10 = math.log10
max = math.max
min = math.min
pow = math.pow
random = math.random
sin = math.sin
sinh = math.sinh
sqrt = math.sqrt
tan = math.tan
tanh = math.tanh
trunc = math.floor
setenv("quote", {_stash = true, macro = function (form)
  return quoted(form)
end})
setenv("quasiquote", {_stash = true, macro = function (form)
  return quasiexpand(form, 1)
end})
function get_place(place, setfn)
  local __place = macroexpand(place)
  if atom63(__place) or hd(__place) == "get" and nil63(getenv("get", "expander")) or accessor_literal63(hd(tl(__place))) then
    return setfn(__place, function (v)
      return {"%set", __place, v}
    end)
  else
    local __head = hd(__place)
    local __gf = getenv(__head, "expander")
    if __gf then
      return apply(__gf, join({setfn}, tl(__place)))
    else
      return error(str(__place) .. " is not a valid place expression")
    end
  end
end
setenv("let-place", {_stash = true, macro = function (vars, place, ...)
  local ____r4 = unstash({...})
  local __vars = destash33(vars, ____r4)
  local __place1 = destash33(place, ____r4)
  local ____id = ____r4
  local __body = cut(____id, 0)
  return {"get-place", __place1, join({"fn", __vars}, __body)}
end})
setenv("define-expander", {_stash = true, macro = function (name, handler)
  local ____x5 = {"setenv", {"quote", name}}
  ____x5.expander = handler
  local __form = ____x5
  eval(__form)
  return __form
end})
function define_setter(name, setter, setfn, args, vars)
  if none63(args) then
    local __vars1 = reverse(vars)
    return setfn(join({name}, __vars1), function (v)
      return apply(setter, join({v}, __vars1))
    end)
  else
    local __v = hd(args)
    return define_setter(name, setter, setfn, tl(args), join({__v}, vars))
  end
end
setenv("define-setter", {_stash = true, macro = function (name, arglist, ...)
  local ____r8 = unstash({...})
  local __name = destash33(name, ____r8)
  local __arglist = destash33(arglist, ____r8)
  local ____id1 = ____r8
  local __body1 = cut(____id1, 0)
  local ____x13 = {"setfn"}
  ____x13.rest = "args"
  return {"define-expander", __name, {"fn", ____x13, {"%call", "define-setter", {"quote", __name}, join({"fn", __arglist}, __body1), "setfn", "args"}}}
end})
setenv("set", {_stash = true, macro = function (...)
  local __args = unstash({...})
  return join({"do"}, map(function (__x19)
    local ____id2 = __x19
    local __lh = ____id2[1]
    local __rh = ____id2[2]
    return get_place(__lh, function (getter, setter)
      return setter(__rh)
    end)
  end, pair(__args)))
end})
setenv("at", {_stash = true, macro = function (l, i)
  if _G.target == "lua" and number63(i) then
    i = i + 1
  else
    if _G.target == "lua" then
      i = {"+", i, 1}
    end
  end
  return {"get", l, i}
end})
setenv("wipe", {_stash = true, macro = function (place)
  if _G.target == "lua" then
    return {"set", place, "nil"}
  else
    return {"%delete", place}
  end
end})
setenv("list", {_stash = true, macro = function (...)
  local __body2 = unstash({...})
  local __x25 = unique("x")
  local __l = {}
  local __forms = {}
  local ____o = __body2
  local __k = nil
  for __k in pairs(____o) do
    local __v1 = ____o[__k]
    if number63(__k) then
      __l[__k] = __v1
    else
      add(__forms, {"set", {"get", __x25, {"quote", __k}}, __v1})
    end
  end
  if some63(__forms) then
    return join({"let", __x25, join({"%array"}, __l)}, __forms, {__x25})
  else
    return join({"%array"}, __l)
  end
end})
setenv("if", {_stash = true, macro = function (...)
  local __branches = unstash({...})
  return hd(expand_if(__branches))
end})
setenv("case", {_stash = true, macro = function (expr, ...)
  local ____r13 = unstash({...})
  local __expr = destash33(expr, ____r13)
  local ____id3 = ____r13
  local __clauses = cut(____id3, 0)
  local __x35 = unique("x")
  local __eq = function (_)
    return {"=", {"quote", _}, __x35}
  end
  local __cl = function (__x38)
    local ____id4 = __x38
    local __a = ____id4[1]
    local __b = ____id4[2]
    if nil63(__b) then
      return {__a}
    else
      if string63(__a) or number63(__a) then
        return {__eq(__a), __b}
      else
        if one63(__a) then
          return {__eq(hd(__a)), __b}
        else
          if _35(__a) > 1 then
            return {join({"or"}, map(__eq, __a)), __b}
          end
        end
      end
    end
  end
  return {"let", __x35, __expr, join({"if"}, apply(join, map(__cl, pair(__clauses))))}
end})
setenv("when", {_stash = true, macro = function (cond, ...)
  local ____r16 = unstash({...})
  local __cond = destash33(cond, ____r16)
  local ____id5 = ____r16
  local __body3 = cut(____id5, 0)
  return {"if", __cond, join({"do"}, __body3)}
end})
setenv("unless", {_stash = true, macro = function (cond, ...)
  local ____r17 = unstash({...})
  local __cond1 = destash33(cond, ____r17)
  local ____id6 = ____r17
  local __body4 = cut(____id6, 0)
  return {"if", {"not", __cond1}, join({"do"}, __body4)}
end})
setenv("obj", {_stash = true, macro = function (...)
  local __body5 = unstash({...})
  return join({"%object"}, mapo(function (x)
    return x
  end, __body5))
end})
setenv("let", {_stash = true, macro = function (bs, ...)
  local ____r19 = unstash({...})
  local __bs = destash33(bs, ____r19)
  local ____id7 = ____r19
  local __body6 = cut(____id7, 0)
  if atom63(__bs) then
    return join({"let", {__bs, hd(__body6)}}, tl(__body6))
  else
    if none63(__bs) then
      return join({"do"}, __body6)
    else
      local ____id8 = __bs
      local __lh1 = ____id8[1]
      local __rh1 = ____id8[2]
      local __bs2 = cut(____id8, 2)
      local ____id9 = bind(__lh1, __rh1)
      local __id10 = ____id9[1]
      local __val = ____id9[2]
      local __bs1 = cut(____id9, 2)
      local __id11 = unique(__id10)
      return {"do", {"%local", __id11, __val}, {"let-symbol", {__id10, __id11}, join({"let", join(__bs1, __bs2)}, __body6)}}
    end
  end
end})
setenv("with", {_stash = true, macro = function (x, v, ...)
  local ____r20 = unstash({...})
  local __x65 = destash33(x, ____r20)
  local __v2 = destash33(v, ____r20)
  local ____id111 = ____r20
  local __body7 = cut(____id111, 0)
  return join({"let", {__x65, __v2}}, __body7, {__x65})
end})
setenv("let-when", {_stash = true, macro = function (x, v, ...)
  local ____r21 = unstash({...})
  local __x70 = destash33(x, ____r21)
  local __v3 = destash33(v, ____r21)
  local ____id12 = ____r21
  local __body8 = cut(____id12, 0)
  local __y = unique("y")
  return {"let", __y, __v3, {"when", {"yes", __y}, join({"let", {__x70, __y}}, __body8)}}
end})
setenv("define-macro", {_stash = true, macro = function (name, args, ...)
  local ____r22 = unstash({...})
  local __name1 = destash33(name, ____r22)
  local __args1 = destash33(args, ____r22)
  local ____id13 = ____r22
  local __body9 = cut(____id13, 0)
  local ____x77 = {"setenv", {"quote", __name1}}
  ____x77.macro = join({"fn", __args1}, __body9)
  return join(____x77, keys(__body9))
end})
setenv("define-special", {_stash = true, macro = function (name, args, ...)
  local ____r23 = unstash({...})
  local __name2 = destash33(name, ____r23)
  local __args2 = destash33(args, ____r23)
  local ____id14 = ____r23
  local __body10 = cut(____id14, 0)
  local ____x81 = {"setenv", {"quote", __name2}}
  ____x81.special = join({"fn", __args2}, __body10)
  return join(____x81, keys(__body10))
end})
setenv("define-symbol", {_stash = true, macro = function (name, expansion)
  local ____x84 = {"setenv", {"quote", name}}
  ____x84.symbol = {"quote", expansion}
  return ____x84
end})
setenv("define-reader", {_stash = true, macro = function (__x87, ...)
  local ____id15 = __x87
  local __char = ____id15[1]
  local __s = ____id15[2]
  local ____r25 = unstash({...})
  local ____x87 = destash33(__x87, ____r25)
  local ____id16 = ____r25
  local __body11 = cut(____id16, 0)
  return {"set", {"get", "read-table", __char}, join({"fn", {__s}}, __body11)}
end})
setenv("define", {_stash = true, macro = function (name, x, ...)
  local ____r26 = unstash({...})
  local __name3 = destash33(name, ____r26)
  local __x94 = destash33(x, ____r26)
  local ____id17 = ____r26
  local __body12 = cut(____id17, 0)
  if some63(__body12) then
    return join({"%local-function", __name3}, bind_function(__x94, __body12))
  else
    return {"%local", __name3, __x94}
  end
end})
setenv("define-global", {_stash = true, macro = function (name, x, ...)
  local ____r27 = unstash({...})
  local __name4 = destash33(name, ____r27)
  local __x98 = destash33(x, ____r27)
  local ____id18 = ____r27
  local __body13 = cut(____id18, 0)
  if some63(__body13) then
    return join({"%global-function", __name4}, bind_function(__x98, __body13))
  else
    return {"set", __name4, __x98}
  end
end})
setenv("with-frame", {_stash = true, macro = function (...)
  local __body14 = unstash({...})
  local __x102 = unique("x")
  return {"do", {"add", "environment*", {"obj"}}, {"with", __x102, join({"do"}, __body14), {"drop", "environment*"}}}
end})
setenv("with-bindings", {_stash = true, macro = function (__x109, ...)
  local ____id19 = __x109
  local __names = ____id19[1]
  local ____r28 = unstash({...})
  local ____x109 = destash33(__x109, ____r28)
  local ____id20 = ____r28
  local __body15 = cut(____id20, 0)
  local __x111 = unique("x")
  local ____x114 = {"setenv", __x111}
  ____x114.variable = true
  return join({"with-frame", {"each", __x111, __names, ____x114}}, __body15)
end})
setenv("let-macro", {_stash = true, macro = function (definitions, ...)
  local ____r29 = unstash({...})
  local __definitions = destash33(definitions, ____r29)
  local ____id21 = ____r29
  local __body16 = cut(____id21, 0)
  add(_G.environment, {})
  local ____x117 = __definitions
  local ____i1 = 0
  while ____i1 < _35(____x117) do
    local __m = ____x117[____i1 + 1]
    eval(join({"define-macro"}, __m))
    ____i1 = ____i1 + 1
  end
  local ____x116 = join({"do"}, macroexpand(__body16))
  drop(_G.environment)
  return ____x116
end})
setenv("let-symbol", {_stash = true, macro = function (expansions, ...)
  local ____r30 = unstash({...})
  local __expansions = destash33(expansions, ____r30)
  local ____id22 = ____r30
  local __body17 = cut(____id22, 0)
  add(_G.environment, {})
  local ____x122 = pair(__expansions)
  local ____i2 = 0
  while ____i2 < _35(____x122) do
    local ____id23 = ____x122[____i2 + 1]
    local __name5 = ____id23[1]
    local __exp = ____id23[2]
    eval({"define-symbol", __name5, __exp})
    ____i2 = ____i2 + 1
  end
  local ____x121 = join({"do"}, macroexpand(__body17))
  drop(_G.environment)
  return ____x121
end})
setenv("let-unique", {_stash = true, macro = function (names, ...)
  local ____r31 = unstash({...})
  local __names1 = destash33(names, ____r31)
  local ____id24 = ____r31
  local __body18 = cut(____id24, 0)
  local __bs11 = map(function (n)
    return {n, {"unique", {"quote", n}}}
  end, __names1)
  return join({"let", apply(join, __bs11)}, __body18)
end})
setenv("fn", {_stash = true, macro = function (args, ...)
  local ____r33 = unstash({...})
  local __args3 = destash33(args, ____r33)
  local ____id25 = ____r33
  local __body19 = cut(____id25, 0)
  return join({"%function"}, bind_function(__args3, __body19))
end})
setenv("apply", {_stash = true, macro = function (f, ...)
  local ____r34 = unstash({...})
  local __f = destash33(f, ____r34)
  local ____id26 = ____r34
  local __args4 = cut(____id26, 0)
  if _35(__args4) > 1 then
    return {"%call", "apply", __f, {"join", join({"list"}, almost(__args4)), last(__args4)}}
  else
    return join({"%call", "apply", __f}, __args4)
  end
end})
setenv("guard", {_stash = true, macro = function (expr)
  if _G.target == "js" then
    return {{"fn", join(), {"%try", {"list", true, expr}}}}
  else
    local ____x148 = {"obj"}
    ____x148.stack = {{"get", "debug", {"quote", "traceback"}}}
    ____x148.message = {"if", {"string?", "m"}, {"clip", "m", {"+", {"or", {"search", "m", "\": \""}, -2}, 2}}, {"nil?", "m"}, "\"\"", {"str", "m"}}
    return {"list", {"xpcall", {"fn", join(), expr}, {"fn", {"m"}, {"if", {"obj?", "m"}, "m", ____x148}}}}
  end
end})
setenv("each", {_stash = true, macro = function (x, t, ...)
  local ____r36 = unstash({...})
  local __x161 = destash33(x, ____r36)
  local __t = destash33(t, ____r36)
  local ____id27 = ____r36
  local __body20 = cut(____id27, 0)
  local __o1 = unique("o")
  local __n1 = unique("n")
  local __i3 = unique("i")
  local __e = nil
  if atom63(__x161) then
    __e = {__i3, __x161}
  else
    local __e1 = nil
    if _35(__x161) > 1 then
      __e1 = __x161
    else
      __e1 = {__i3, hd(__x161)}
    end
    __e = __e1
  end
  local ____id28 = __e
  local __k1 = ____id28[1]
  local __v4 = ____id28[2]
  return {"let", {__o1, __t}, {"for", {__k1}, {"pairs", __o1}, join({"let", {__v4, {"get", __o1, __k1}}}, __body20)}}
end})
setenv("for", {_stash = true, macro = function (i, to, ...)
  local ____r37 = unstash({...})
  local __i4 = destash33(i, ____r37)
  local __to = destash33(to, ____r37)
  local ____id29 = ____r37
  local __body21 = cut(____id29, 0)
  if obj63(__i4) then
    return {"let", apply(join, map(function (x)
      return {x, "nil"}
    end, __i4)), {"%for", __to, join({"%names"}, __i4), join({"do"}, __body21)}}
  else
    return {"let", __i4, 0, join({"while", {"<", __i4, __to}}, __body21, {{"inc", __i4}})}
  end
end})
setenv("step", {_stash = true, macro = function (v, t, ...)
  local ____r39 = unstash({...})
  local __v5 = destash33(v, ____r39)
  local __t1 = destash33(t, ____r39)
  local ____id30 = ____r39
  local __body22 = cut(____id30, 0)
  local __x184 = unique("x")
  local __i5 = unique("i")
  return {"let", {__x184, __t1}, {"for", __i5, {"#", __x184}, join({"let", {__v5, {"at", __x184, __i5}}}, __body22)}}
end})
setenv("set-of", {_stash = true, macro = function (...)
  local __xs = unstash({...})
  local __l1 = {}
  local ____o2 = __xs
  local ____i6 = nil
  for ____i6 in pairs(____o2) do
    local __x193 = ____o2[____i6]
    __l1[__x193] = true
  end
  return join({"obj"}, __l1)
end})
setenv("language", {_stash = true, macro = function ()
  return {"quote", _G.target}
end})
setenv("target", {_stash = true, macro = function (...)
  local __clauses1 = unstash({...})
  return __clauses1[_G.target]
end})
setenv("join!", {_stash = true, macro = function (a, ...)
  local ____r41 = unstash({...})
  local __a1 = destash33(a, ____r41)
  local ____id31 = ____r41
  local __bs21 = cut(____id31, 0)
  return {"set", __a1, join({"join", __a1}, __bs21)}
end})
setenv("cat!", {_stash = true, macro = function (a, ...)
  local ____r42 = unstash({...})
  local __a2 = destash33(a, ____r42)
  local ____id32 = ____r42
  local __bs3 = cut(____id32, 0)
  return {"set", __a2, join({"cat", __a2}, __bs3)}
end})
setenv("inc", {_stash = true, macro = function (n, by)
  local __e2 = nil
  if nil63(by) then
    __e2 = 1
  else
    __e2 = by
  end
  return {"set", n, {"+", n, __e2}}
end})
setenv("dec", {_stash = true, macro = function (n, by)
  local __e3 = nil
  if nil63(by) then
    __e3 = 1
  else
    __e3 = by
  end
  return {"set", n, {"-", n, __e3}}
end})
setenv("with-indent", {_stash = true, macro = function (form)
  local __x207 = unique("x")
  return {"do", {"inc", "indent-level*"}, {"with", __x207, form, {"dec", "indent-level*"}}}
end})
setenv("undefined?", {_stash = true, macro = function (x)
  local ____x212 = {"target"}
  ____x212.lua = {"=", x, "nil"}
  ____x212.js = {"=", {"typeof", x}, "\"undefined\""}
  return ____x212
end})
setenv("export", {_stash = true, macro = function (...)
  local __names2 = unstash({...})
  local ____x224 = {"target"}
  ____x224.lua = {"return", "exports"}
  return join({"with", "exports", {"if", {"undefined?", "exports"}, {"obj"}, "exports"}}, map(function (k)
    return {"set", {"exports", "." .. k}, k}
  end, __names2), {____x224})
end})
setenv("when-compiling", {_stash = true, macro = function (...)
  local __body23 = unstash({...})
  return eval(join({"do"}, __body23))
end})
setenv("during-compilation", {_stash = true, macro = function (...)
  local __body24 = unstash({...})
  local __form1 = join({"do"}, __body24, {{"do"}})
  eval(__form1)
  return __form1
end})
setenv("hd", {_stash = true, expander = function (setfn, ...)
  local ____r50 = unstash({...})
  local __setfn1 = destash33(setfn, ____r50)
  local ____id34 = ____r50
  local __args6 = cut(____id34, 0)
  return define_setter("hd", function (v, l)
    return {"set", {"at", l, 0}, v}
  end, __setfn1, __args6)
end})
local reader = require("./reader")
local compiler = require("./compiler")
local system = require("./system")
local function eval_print(form)
  local ____id = {xpcall(function ()
    return compiler.eval({"results", form})
  end, function (m)
    if obj63(m) then
      return m
    else
      local __e = nil
      if string63(m) then
        __e = clip(m, (search(m, ": ") or -2) + 2)
      else
        local __e1 = nil
        if nil63(m) then
          __e1 = ""
        else
          __e1 = str(m)
        end
        __e = __e1
      end
      return {stack = debug.traceback(), message = __e}
    end
  end)}
  local __ok = ____id[1]
  local __v = ____id[2]
  if not __ok then
    return print("error: " .. __v.message .. "\n" .. __v.stack)
  else
    local ____x2 = __v
    local ____i = 0
    while ____i < _35(____x2) do
      local __x3 = ____x2[____i + 1]
      if is63(__x3) or _35(__v) > 1 then
        print(str(__x3))
      end
      ____i = ____i + 1
    end
  end
end
local function rep(s)
  return eval_print(reader.readString(s))
end
local function repl()
  local __buf = ""
  local function rep1(s)
    __buf = __buf .. s
    local __more = {}
    local __form = reader.readString(__buf, __more)
    if not( __form == __more) then
      eval_print(__form)
      __buf = ""
      return system.write("> ")
    end
  end
  system.write("> ")
  if process then
    process.stdin:removeAllListeners()
    return process.stdin:on("data", rep1)
  else
    while true do
      local __s = io.read()
      if __s then
        rep1(__s .. "\n")
      else
        break
      end
    end
  end
end
function read_file(path)
  return system.readFile(path)
end
function write_file(path, data)
  return system.writeFile(path, data)
end
function read_from_file(path)
  local __s1 = reader.stream(system.readFile(path))
  local __body = reader.readAll(__s1)
  return join({"do"}, __body)
end
function expand_file(path)
  return compiler.expand(read_from_file(path))
end
function compile_file(path)
  local __form1 = expand_file(path)
  return compiler.compile(__form1, {_stash = true, stmt = true})
end
function _load(path)
  local __previous = _G.target
  _G.target = "lua"
  local __code = compile_file(path)
  _G.target = __previous
  return compiler.run(__code)
end
function script_file63(path)
  return string63(path) and not( "-" == char(path, 0) or ".js" == clip(path, _35(path) - 3) or ".lua" == clip(path, _35(path) - 4))
end
function run_file(path)
  if script_file63(path) then
    return _load(path)
  else
    return compiler.run(read_file(path))
  end
end
function read_from_string(str, start, _end)
  local __s2 = reader.stream(str)
  __s2.pos = either(start, __s2.pos)
  __s2.len = either(_end, __s2.len)
  local __form2 = reader.read(__s2)
  if nil63(__form2) then
    return error("End of string during parsing")
  else
    local ____x5 = {__form2}
    ____x5.rest = __s2.pos
    return ____x5
  end
end
function readable_string63(str)
  local __id4 = string63(str)
  local __e4 = nil
  if __id4 then
    local ____id1 = {xpcall(function ()
      return read_from_string(str)
    end, function (m)
      if obj63(m) then
        return m
      else
        local __e5 = nil
        if string63(m) then
          __e5 = clip(m, (search(m, ": ") or -2) + 2)
        else
          local __e6 = nil
          if nil63(m) then
            __e6 = ""
          else
            __e6 = str(m)
          end
          __e5 = __e6
        end
        return {stack = debug.traceback(), message = __e5}
      end
    end)}
    local __ok1 = ____id1[1]
    local __v1 = ____id1[2]
    __e4 = __ok1 and hd(__v1) == str
  else
    __e4 = __id4
  end
  return __e4
end
function pp_to_string(x, stack)
  if nil63(x) then
    return "nil"
  else
    if nan63(x) then
      return "nan"
    else
      if x == inf then
        return "inf"
      else
        if x == _inf then
          return "-inf"
        else
          if boolean63(x) then
            if x then
              return "true"
            else
              return "false"
            end
          else
            if string63(x) then
              if readable_string63(x) then
                return x
              else
                return escape(x)
              end
            else
              if function63(x) then
                return "function"
              else
                if atom63(x) then
                  return tostring(x)
                else
                  if stack and in63(x, stack) then
                    return "circular"
                  else
                    if not( type(x) == "table") then
                      return escape(tostring(x))
                    else
                      local __s3 = "("
                      local __sp = ""
                      local __xs = {}
                      local __ks = {}
                      local __l = stack or {}
                      add(__l, x)
                      local ____o = x
                      local __k = nil
                      for __k in pairs(____o) do
                        local __v2 = ____o[__k]
                        if number63(__k) then
                          __xs[__k] = pp_to_string(__v2, __l)
                        else
                          if not string63(__k) then
                            __k = pp_to_string(__k, __l)
                          end
                          add(__ks, __k .. ":")
                          add(__ks, pp_to_string(__v2, __l))
                        end
                      end
                      drop(__l)
                      local ____o1 = join(__xs, __ks)
                      local ____i2 = nil
                      for ____i2 in pairs(____o1) do
                        local __v3 = ____o1[____i2]
                        __s3 = __s3 .. __sp .. __v3
                        __sp = " "
                      end
                      return __s3 .. ")"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local function usage()
  return "\nUsage:\n  lumen <file> [<args>...]\n  lumen [options] [<object-files>...]\n\n  <file>          Program read from script file\n  <object-files>  Loaded before compiling <input>\n\nOptions:\n  -c <input>...   Compile input files\n  -o <output>     Write compiler output to <output>\n  -t <target>     Set target language (default: lua)\n  -e <expr>...    Expressions to evaluate\n"
end
local function main(argv)
  argv = argv or get_argv()
  local __arg = hd(argv)
  if script_file63(__arg) then
    set_argv(tl(argv))
    return _load(__arg)
  end
  local __args = parse_arguments({c = "compile", o = "output", t = "target", e = "eval", h = "help", r = "repl"}, argv)
  if script_file63(hd(__args)) then
    return _load(hd(__args))
  else
    if __args.help then
      return print(usage())
    else
      local __pre = keep(string63, __args)
      local __cmds = keep(obj63, __args)
      local __input = ""
      local __enter_repl = true
      local ____x7 = __pre
      local ____i3 = 0
      while ____i3 < _35(____x7) do
        local __file = ____x7[____i3 + 1]
        run_file(__file)
        ____i3 = ____i3 + 1
      end
      local ____x8 = __cmds
      local ____i4 = 0
      while ____i4 < _35(____x8) do
        local ____id2 = ____x8[____i4 + 1]
        local __a = ____id2[1]
        local __val = ____id2[2]
        if __a == "target" then
          _G.target = hd(__val)
          break
        end
        ____i4 = ____i4 + 1
      end
      local ____x9 = __cmds
      local ____i5 = 0
      while ____i5 < _35(____x9) do
        local ____id3 = ____x9[____i5 + 1]
        local __a1 = ____id3[1]
        local __val1 = ____id3[2]
        if __a1 == "help" then
          print(usage())
        else
          if __a1 == "repl" then
            __enter_repl = true
          else
            if boolean63(__val1) or none63(__val1) then
              print("missing argument for " .. __a1)
            else
              if __a1 == "compile" then
                local ____x10 = __val1
                local ____i6 = 0
                while ____i6 < _35(____x10) do
                  local __x11 = ____x10[____i6 + 1]
                  __input = __input .. compile_file(__x11)
                  ____i6 = ____i6 + 1
                end
                __enter_repl = false
              else
                if __a1 == "output" then
                  write_file(hd(__val1), __input)
                  __input = ""
                else
                  if __a1 == "target" then
                    _G.target = hd(__val1)
                  else
                    if __a1 == "eval" then
                      local ____x12 = __val1
                      local ____i7 = 0
                      while ____i7 < _35(____x12) do
                        local __x13 = ____x12[____i7 + 1]
                        rep(__x13)
                        ____i7 = ____i7 + 1
                      end
                      __enter_repl = false
                    end
                  end
                end
              end
            end
          end
        end
        ____i5 = ____i5 + 1
      end
      if some63(__input) then
        print(__input)
      end
      if __enter_repl or __args.repl then
        return repl()
      end
    end
  end
end
local __e7 = nil
if exports == nil then
  __e7 = {}
else
  __e7 = exports
end
local __exports = __e7
__exports.reader = reader
__exports.compiler = compiler
__exports.system = system
__exports.main = main
return __exports
