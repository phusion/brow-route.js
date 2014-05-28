if !@BrowRoute? then @BrowRoute = {}

@BrowRoute.RouteListener = class RouteListener
	constructor: (@route) ->
		@compile()
		@callbacks = new Array()

	matches: (url) ->
		parts = url.split("?",2)
		results = @regex.exec(parts[0])
		results.push(@parseOptions(parts[1])) if parts[1]?
		if results?
			results.slice(1) 
		else
			false

	trigger: (url) ->
		if matches = @matches(url)
			cb(matches...) for cb in @callbacks

	variableRegex: "([a-zA-Z0-9-]+)"
	variableNameRegex: /^([a-zA-Z0-9-_]+)/
	globbingVariableRegex: "([a-zA-Z0-9-]+)"
	optionalScopeBeginRegex: "(?:"
	optionalScopeEndRegex: ")?"
	escapeCharacter: (next) ->
		# is just prepending '\' enough for all special chars?
		'\\' + next

	readVariableName: (string,i) ->
		result = @variableNameRegex.exec(string)
		if !result?[0]
			throw "Expected variable name consisting of letters and numbers at position " + i +
				  " in route: " + @route
		result[0]

	compile: ->
		# we need to build a regex here that matches on the urls
		# we support named variables like :variable, optional
		# named variables like (:variable), globbing named variables
		# like *variable and nested optional variables like 
		# (:variable1(:variable2))
		#
		# -> : - read variable name, emit variable regex
		# -> * - read variable name, emit globbing variable regex
		# -> ( - push optional scope, emit optional regex block begin
		# -> ) - pop optional scope, emit optional regex block end
		result_array = []
		optional_scope = 0
		i = 0
		while i < @route.length
			c = @route[i]
			switch c
				when ':'
					#read variable name
					variable_name = @readVariableName(@route.substr(i+1),i)
					i += variable_name.length
					#emit variable regex
					result_array.push(@variableRegex)
				when '*'
					#read variable name
					variable_name = @readVariableName(@route.substr(i+1),i)
					i += variable_name.length
					#emit globbing variable regex
					result_array.push(@globbingVariableRegex)
				when '('
				    #increase optional scope
					optional_scope += 1
					#emit optional scope begin regex
					result_array.push(@optionalScopeBeginRegex)
				when ')'
					optional_scope -= 1
					if optional_scope < 0
						throw "Unexpected ')' while parsing route: " + @route
					result_array.push(@optionalScopeEndRegex)
				when '\\'
					# read next character
					next = @route[i+1]
					i+=1
					# emit next character escaped
					result_array.push(@escapeCharacter(next))
				else
					# emit character
					result_array.push(c)
			i+=1 # next character
		result = "^" + result_array.join("") + "$"
		@regex = new RegExp(result)


	# Parses the options hash
	# Transcribed from http://medialize.github.io/URI.js
	parseOptions: (string) ->
		return {} if !string
		# throw out the funky business - "?"[name"="value"&"]+
		string = string.replace(/&+/g, '&').replace(/^\?*&*|&+$/g, '')
		return {} if !string

		items = {}
		splits = string.split('&')
		length = splits.length

		for pair in splits
			v = pair.split('=')
			name = @decodeQuery(v.shift())
			# no "=" is null according to http://dvcs.w3.org/hg/url/raw-file/tip/Overview.html#collect-url-parameters
			value = if v.length then @decodeQuery(v.join("=")) else null

			if items[name]
				if typeof items[name] is 'string'
					items[name] = [items[name]]
				items[name].push(value);
			else
				items[name] = value
			
		items

	decodeQuery: (string) ->
		try
			decodeURIComponent(string.replace(/\+/g, '%20'));
		catch e
			string