local function call_with_file(f, path, mode)
  local ____id = {io.open(path, mode)}
  local __h = ____id[1]
  local __e = ____id[2]
  if not __h then
    error(__e)
  end
  local __x1 = f(__h)
  __h.close(__h)
  return __x1
end
local function read_file(path)
  return call_with_file(function (f)
    return f.read(f, "*a")
  end, path)
end
local function write_file(path, data)
  return call_with_file(function (f)
    return f.write(f, data)
  end, path, "w")
end
local function file_exists63(path)
  local __f = io.open(path)
  local __id2 = is63(__f)
  local __e1 = nil
  if __id2 then
    local __r6 = is63(__f.read(__f, 0)) or 0 == __f.seek(__f, "end")
    __f.close(__f)
    __e1 = __r6
  else
    __e1 = __id2
  end
  return __e1
end
local function directory_exists63(path)
  local __f1 = io.open(path)
  local __id3 = is63(__f1)
  local __e2 = nil
  if __id3 then
    local __r8 = not __f1.read(__f1, 0) and not( 0 == __f1.seek(__f1, "end"))
    __f1.close(__f1)
    __e2 = __r8
  else
    __e2 = __id3
  end
  return __e2
end
local path_separator = char(_G.package.config, 0)
local function path_join(...)
  local __parts = unstash({...})
  return reduce(function (x, y)
    return x .. path_separator .. y
  end, __parts) or ""
end
local function get_environment_variable(name)
  return os.getenv(name)
end
local function stdout()
  return io.stdout
end
local function stderr()
  return io.stderr
end
local function write(x, out)
  local __out = out or stdout()
  __out.write(__out, x)
  return nil
end
local function exit(code)
  return os.exit(code)
end
local argv = nil
function set_argv(l)
  argv = l
  return argv
end
function get_argv()
  if nil63(argv) then
    set_argv(_G.arg or _G.args or {})
  end
  return argv
end
function opt63(x)
  return string63(x) and char(x, 0) == "-"
end
function parse_positional(args, pos)
  return cut(args, either(pos, 0), first(opt63, args, pos))
end
function parse_option(args)
  if opt63(hd(args)) then
    return {hd(args), parse_positional(args, 1)}
  end
end
function parse_arguments(aliases, argv)
  local __l = argv or get_argv()
  local __a = aliases or {}
  local __r21 = parse_positional(__l)
  __l = cut(__l, _35(__r21))
  while true do
    local __p = parse_option(__l)
    if not __p then
      break
    end
    local ____y = __p
    if yes(____y) then
      local ____id1 = ____y
      local __o = ____id1[1]
      local __args = ____id1[2]
      if __o == "--" then
        __l = cut(__l, 1)
        break
      end
      __l = cut(__l, 1 + _35(__args))
      local __e3 = nil
      if clip(__o, 0, 2) == "--" then
        __e3 = clip(__o, 2)
      else
        __e3 = clip(__o, 1)
      end
      local __k = __e3
      local __k1 = __a[__k] or __k
      local __e4 = nil
      if none63(__args) then
        __e4 = true
      else
        __e4 = __args
      end
      local __v = __e4
      __r21[__k1] = __v
      add(__r21, {__k1, __v})
    end
  end
  __r21.rest = __l
  set_argv(__r21.rest)
  return __r21
end
function arguments(aliases, argv)
  local __argv = argv or get_argv()
  local __r23 = parse_arguments(__argv, aliases)
  set_argv(__r23.rest)
  __r23.rest = nil
  if not empty63(__r23) then
    return __r23
  end
end
local function reload(module)
  package.loaded[module] = nil
  return require(module)
end
local function run(command)
  local __f2 = io.popen(command)
  local __x5 = __f2.read(__f2, "*all")
  __f2.close(__f2)
  return __x5
end
return {["read-file"] = read_file, ["write-file"] = write_file, ["file-exists?"] = file_exists63, ["directory-exists?"] = directory_exists63, ["path-separator"] = path_separator, ["path-join"] = path_join, ["get-environment-variable"] = get_environment_variable, stdout = stdout, stderr = stderr, write = write, exit = exit, ["get-argv"] = get_argv, ["set-argv"] = set_argv, arguments = arguments, reload = reload, run = run}
