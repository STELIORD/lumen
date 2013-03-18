var current_target="js";var current_language="js";function error(msg){throw(msg);}function type(x){return(typeof(x));}function array_length(arr){return(arr.length);}function array_sub(arr,from,upto){return(arr.slice(from,upto));}function array_push(arr,x){arr[array_length(arr)]=x;}function string_length(str){return(str.length);}function string_start(){return(0);}function string_end(str){return((string_length(str)-1));}function string_ref(str,n){return(str.charAt(n));}function string_sub(str,from,upto){return(str.substring(from,upto));}function string_find(str,pattern,start){{var i=str.indexOf(pattern,start);if((i>0)){return(i);}else{return(undefined);}}}fs=require("fs");function read_file(filename){return(fs.readFileSync(filename,"utf8"));}function write_file(filename,data){fs.writeFileSync(filename,data,"utf8");}function print(x){console.log(x);}function exit(code){process.exit(code);}function parse_number(str){{var n=parseFloat(str);if(!(isNaN(n))){return(n);}}}var delimiters={};delimiters["("]=true;delimiters[")"]=true;delimiters[";"]=true;delimiters["\n"]=true;var whitespace={};whitespace[" "]=true;whitespace["\t"]=true;whitespace["\n"]=true;function make_stream(str){var s={};s.pos=string_start();s.string=str;s.last=string_end(str);return(s);}function peek_char(s){if((s.pos<=s.last)){return(string_ref(s.string,s.pos));}}function read_char(s){var c=peek_char(s);if(c){s.pos=(s.pos+1);return(c);}}function skip_non_code(s){var c;while(true){c=peek_char(s);if(!(c)){break;}else if(whitespace[c]){read_char(s);}else if((c==";")){while((c&&!((c=="\n")))){c=read_char(s);}skip_non_code(s);}else{break;}}}function read_atom(s){var c;var str="";while(true){c=peek_char(s);if((c&&(!(whitespace[c])&&!(delimiters[c])))){str=(str+c);read_char(s);}else{break;}}var n=parse_number(str);if((n==undefined)){return(str);}else{return(n);}}function read_list(s){read_char(s);var c;var l=[];while(true){skip_non_code(s);c=peek_char(s);if((c&&!((c==")")))){array_push(l,read(s));}else if(c){read_char(s);break;}else{error(("Expected ) at "+s.pos));}}return(l);}function read_string(s){read_char(s);var c;var str="\"";while(true){c=peek_char(s);if((c&&!((c=="\"")))){if((c=="\\")){str=(str+read_char(s));}str=(str+read_char(s));}else if(c){read_char(s);break;}else{error(("Expected \" at "+s.pos));}}return((str+"\""));}function read_quote(s){read_char(s);return(["quote",read(s)]);}function read_unquote(s){read_char(s);return(["unquote",read(s)]);}function read(s){skip_non_code(s);var c=peek_char(s);if((c=="(")){return(read_list(s));}else if((c==")")){error(("Unexpected ) at "+s.pos));}else if((c=="\"")){return(read_string(s));}else if((c=="'")){return(read_quote(s));}else if((c==",")){return(read_unquote(s));}else{return(read_atom(s));}}var operators={};function define_operators(){operators["+"]="+";operators["-"]="-";operators["<"]="<";operators[">"]=">";operators["<="]="<=";operators[">="]=">=";operators["="]="==";if((current_target=="js")){operators["and"]="&&";}else{operators["and"]=" and ";}if((current_target=="js")){operators["or"]="||";}else{operators["or"]=" or ";}if((current_target=="js")){operators["cat"]="+";}else{operators["cat"]="..";}}var special={};special["do"]=compile_do;special["set"]=compile_set;special["get"]=compile_get;special["dot"]=compile_dot;special["not"]=compile_not;special["if"]=compile_if;special["function"]=compile_function;special["declare"]=compile_declare;special["while"]=compile_while;special["list"]=compile_list;special["quote"]=compile_quote;var macros={};function is_atom(form){return(((type(form)=="string")||(type(form)=="number")));}function is_call(form){return((type(form[0])=="string"));}function is_operator(form){return(!((operators[form[0]]==undefined)));}function is_special(form){return(!((special[form[0]]==undefined)));}function is_macro_call(form){return(!((macros[form[0]]==undefined)));}function is_macro_definition(form){return((is_call(form)&&(form[0]=="macro")));}function terminator(is_stmt){if(is_stmt){return(";");}else{return("");}}function compile_args(forms){var i=0;var str="(";while((i<array_length(forms))){str=(str+compile(forms[i],false));if((i<(array_length(forms)-1))){str=(str+",");}i=(i+1);}return((str+")"));}function compile_body(forms){var i=0;var str="";if((current_target=="js")){str="{";}while((i<array_length(forms))){str=(str+compile(forms[i],true));i=(i+1);}if((current_target=="js")){return((str+"}"));}else{return(str);}}function compile_atom(form,is_stmt){var atom=form;if((form=="[]")){if((current_target=="lua")){return("{}");}else{return(form);}}else if((form=="nil")){if((current_target=="js")){return("undefined");}else{return(form);}}else if(((type(form)=="string")&&!((string_ref(form,string_start())=="\"")))){atom=string_ref(form,string_start());var i=(string_start()+1);while((i<=string_end(form))){var c=string_ref(form,i);if((c=="-")){c="_";}atom=(atom+c);i=(i+1);}var last=string_end(form);if((string_ref(form,last)=="?")){var name=string_sub(atom,string_start(),last);atom=("is_"+name);}}return((atom+terminator(is_stmt)));}function compile_call(form,is_stmt){var fn=compile(form[0],false);var args=compile_args(array_sub(form,1));return((fn+args+terminator(is_stmt)));}function compile_operator(form){var i=1;var str="(";var op=operators[form[0]];while((i<array_length(form))){str=(str+compile(form[i],false));if((i<(array_length(form)-1))){str=(str+op);}i=(i+1);}return((str+")"));}function compile_do(forms,is_stmt){if(!(is_stmt)){error("Cannot compile DO as an expression");}var body=compile_body(forms);if((current_target=="js")){return(body);}else{return(("do "+body+" end "));}}function compile_set(form,is_stmt){if(!(is_stmt)){error("Cannot compile assignment as an expression");}if((array_length(form)<2)){error("Missing right-hand side in assignment");}var lh=compile(form[0],false);var rh=compile(form[1],false);return((lh+"="+rh+terminator(true)));}function compile_branch(branch,is_first,is_last){var condition=compile(branch[0],false);var body=compile_body(array_sub(branch,1));var tr="";if((is_last&&(current_target=="lua"))){tr=" end ";}if(is_first){if((current_target=="js")){return(("if("+condition+")"+body));}else{return(("if "+condition+" then "+body+tr));}}else if((is_last&&(condition=="true"))){if((current_target=="js")){return(("else"+body));}else{return((" else "+body+" end "));}}else{if((current_target=="js")){return(("else if("+condition+")"+body));}else{return((" elseif "+condition+" then "+body+tr));}}}function compile_if(form,is_stmt){if(!(is_stmt)){error("Cannot compile if as an expression");}var i=0;var str="";while((i<array_length(form))){var is_last=(i==(array_length(form)-1));var is_first=(i==0);var branch=compile_branch(form[i],is_first,is_last);str=(str+branch);i=(i+1);}return(str);}function compile_function(form,is_stmt){var name=compile(form[0]);var args=compile_args(form[1]);var body=compile_body(array_sub(form,2));var tr="";if((current_target=="lua")){tr=" end ";}return(("function "+name+args+body+tr));}function compile_get(form,is_stmt){var object=compile(form[0],false);var key=compile(form[1],false);return((object+"["+key+"]"+terminator(is_stmt)));}function compile_dot(form,is_stmt){var object=compile(form[0],false);var key=form[1];return((object+"."+key+terminator(is_stmt)));}function compile_not(form,is_stmt){var expr=compile(form[0],false);if((current_target=="js")){return(("!("+expr+")"+terminator(is_stmt)));}else{return(("(not "+expr+")"+terminator(is_stmt)));}}function compile_declare(form,is_stmt){if(!(is_stmt)){error("Cannot compile declaration as an expression");}var lh=compile(form[0]);var tr=terminator(true);var keyword="local ";if((current_target=="js")){keyword="var ";}if((form[1]==undefined)){return((keyword+lh+tr));}else{var rh=compile(form[1],false);return((keyword+lh+"="+rh+tr));}}function compile_while(form,is_stmt){if(!(is_stmt)){error("Cannot compile WHILE as an expression");}var condition=compile(form[0],false);var body=compile_body(array_sub(form,1));if((current_target=="js")){return(("while("+condition+")"+body));}else{return(("while "+condition+" do "+body+" end "));}}function compile_list(forms,is_stmt,is_quoted){if(is_stmt){error("Cannot compile LIST as a statement");}var i=0;var str="[";if((current_target=="lua")){str="{";}while((i<array_length(forms))){var x=forms[i];var x1;if(is_quoted){x1=quote_form(x);}else{x1=compile(x,false);}str=(str+x1);if((i<(array_length(forms)-1))){str=(str+",");}i=(i+1);}if((current_target=="lua")){return((str+"}"));}else{return((str+"]"));}}function compile_to_string(form){if((type(form)=="string")){return(("\""+form+"\""));}else{return((form+""));}}function quote_form(form){if(((type(form)=="string")&&(string_ref(form,string_start())=="\""))){return(form);}else if(is_atom(form)){return(compile_to_string(form));}else if((form[0]=="unquote")){return(compile(form[1],false));}else{return(compile_list(form,false,true));}}function compile_quote(forms,is_stmt){if(is_stmt){error("Cannot compile quoted form as a statement");}if((array_length(forms)<1)){error("Must supply at least one argument to QUOTE");}return(quote_form(forms[0]));}function compile_macro(form,is_stmt){if(!(is_stmt)){error("Cannot compile macro definition as an expression");}var tmp=current_target;current_target=current_language;eval(compile_function(form,true));var name=form[0];var register=["set",["get","macros",compile_to_string(name)],name];eval(compile(register,true));current_target=tmp;}function compile(form,is_stmt){if((form==undefined)){return("");}else if(is_atom(form)){return(compile_atom(form,is_stmt));}else if(is_call(form)){if((is_operator(form)&&is_stmt)){error(("Cannot compile operator application as a statement"));}else if(is_operator(form)){return(compile_operator(form));}else if(is_macro_definition(form)){compile_macro(array_sub(form,1),is_stmt);return("");}else if(is_special(form)){var fn=special[form[0]];return(fn(array_sub(form,1),is_stmt));}else if(is_macro_call(form)){var fn=macros[form[0]];var form=fn(array_sub(form,1));return(compile(form,is_stmt));}else{return(compile_call(form,is_stmt));}}else{error(("Unexpected form: "+form));}}function compile_file(filename){var form;var output="";var s=make_stream(read_file(filename));while(true){form=read(s);if(form){output=(output+compile(form,true));}else{break;}}return(output);}function usage(){print("usage: x input [-o output] [-t target]");exit();}var args=array_sub(process.argv,2);if((array_length(args)<1)){usage();}var input=args[0];var output=(string_sub(input,string_start(),string_find(input,"."))+".js");var i=1;while((i<array_length(args))){var arg=args[i];if(((arg=="-o")||(arg=="-t"))){if((array_length(args)>(i+1))){i=(i+1);var arg2=args[i];if((arg=="-o")){output=arg2;}else{current_target=arg2;}}else{print("missing argument for",arg);usage();}}else{print("unrecognized option:",arg);usage();}i=(i+1);}define_operators();write_file(output,compile_file(input));