class ChinstrapRenderer 
	debug: false

	templatePool: -> {}

	merge: (str, data, subtemplates = {}) ->
		# Check if str is a value in the @templatePool
		str = @templatePool[str] or str

		# If the template has already been compiled and is a function, run it. Otherwise, make it a function.
		if typeof str is "function"
			@fn = str
		else
			res = @render(str, subtemplates)
			@fn = `new Function("obj", res)`

		# Run the template with the suplied data.
		@fn(data)

	render: (str, subtemplates = {}) ->
		# Collapse newlines and tabs.
		str = str.replace(/[\r\t\n]/g, " ")

		# We are using {{ }} instead of <% %>
		str = str.split("{{").join("\t")

		# Return regular code as is
		str = str.replace( /((^|\}\})[^\t]*)'/g,            "$1\r")

		# {{ = <value> }} returns the value. The value function checks if the value is a function, and runs it, else returns.
		str = str.replace( /\t\s?=(.*?)\}\}/g,              "',value($1),'")

		# {{ # }} amounts to a template comment. Nuke.
		str = str.replace( /\t\s?\#(.*?)\}\}/g,             "")

		# {{ @= }} creates an iterator/stored value. This lets you convert obj.prop to @prop
		str = str.replace( /\t\s?\@\=(.*?)\}\}/g,           "\t iterator=$1; }}")

		# {{ WHILE <conditional> }} becomes while (<conditional>) {
		str = str.replace( /\t\s?WHILE(.*?)\}\}/g,          "\t while ($1) { }}")

		# {{ /WHILE }} becomes }
		str = str.replace( /\t\s?\/WHILE(.*?)\}\}/g,        "\t } }}")

		#{{ FOR <conditional> }} becomes for (<conditional>) {
		str = str.replace( /\t\s?FOR(.*?)\}\}/g,            "\t for ($1) { }}")

		# {{ /FOR }} 
		str = str.replace( /\t\s?\/FOR(.*?)\}\}/g,          "\t } }}")

		# {{ % <template name>, <template data> }} runs a subtemplate.
		str = str.replace( /\t\s?%(.*?)\}\}/g,              "', this.merge($1), '")

		# {{ ? <conditional }} and {{ IF <conditional> }} become if (<conditional>) {
		str = str.replace( /\t\s?(IF|\?)(.*?)\}\}/g,        "\t if (value($2)) { }}")

		# {{ /? }} and {{ /IF }} becomes }
		str = str.replace( /\t\s?\/(IF|\?)(.*?)\}\}/g,      "\t } }}")

		# {{ -? <conditional> }} and {{ /ELSEIF <conditional> }} becomes } else if (<conditional>) {
		str = str.replace( /\t\s?(\-\?|ELSEIF)(.*?)\}\}/g,  "\t } else if (value($2)) { }}")

		# {{ - }} and {{ ELSE }} becomes } else {
		str = str.replace( /\t\s?(\-|ELSE)(.*?)\}\}/g,      "\t } else { }}")

		# {{ @@ }} returns a reference to the iterator object itself.
		str = str.replace( /\@\@/g,                         "iterator")

		# {{= @title }} becomes {{= iterator.title }}
		str = str.replace( /\@/g,                           "iterator.")

		# Cleanup the template.
		str = str.split("\t").join("');")
		str = str.split("}}").join("p.push('")
		str = str.split("\r").join("\\'")

		# Note inclusion of value, which either returns a value, or runs it, if it's a function. Print is what the system uses to output values.
		str = "var p=[],iterator = {},print=function(){p.push.apply(p,arguments);}," +
		"sub=function(name){ return subtemplates[name]},value = function(val){ if (typeof val == 'function') { return val.apply(iterator); } else {return val;} };"+
		"with(obj){p.push('" + str + "');} return p.join('');";

		if this.debug
			str = str.replace(/(\;|\{|\})/g,'$1\n');
			console.log("Return: ", str);
		str

window.Chinstrap = new ChinstrapRenderer() unless window.Chinstrap
