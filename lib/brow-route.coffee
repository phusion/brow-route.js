###
# A simple complete hash routing solution for JS driven web applications.
#
# It will allow users to define routes like:
#
# articles/:article_id/comments/:comment_id
#
# That will trigger when a user visits the application with an url like:
#
# http://blog.myapp.com/#/articles/4/comments/2?hilight=towels
#
###

###
# Example usage:
#
# var router = new BrowRouter()
#
# router.on("articles/:article_id/comments/:comment_id",
#    function(article_id, comment_id, options) {
#        // silly example using JQuery
#        $('.view.active').removeClass('active');
#        $('.views.CommentView').addClass('active');
#        var comment = Comments[article_id][comment_id];
#        $('.views.CommentView').render(comment, options);
#    });
#
###

class BrowRouter
	routes: {}
	###
	# Constructs a BrowRouter that will listen to browser navigations
	# and trigger registered routes. Won't start listening until the
	# start method has been invoked.
	###
	constructor: ->
		# Prepare for route registrations
	start: (runCurrent)->
		# register navigation listeners
	###
	# Register a route
	###
	on: (route, callback) ->
		# populate route registration
		@routes[route] ||= new RouteListener(route)
		@routes[route].callbacks.push(callback)
	
	# stop listening to a route
	stop: (route,callback) ->
		#
	###
	# Trigger on an url
	###
	dispatch: (url) ->
		for r,v of routes
			v.trigger(url)

class RouteListener
	callbacks: []
	constructor: (@route) ->
		@compile()

	matches: (url) ->
		results = @route.exec()

	variableRegex: /([a-zA-Z0-9-]+)/
	globbingVariableRegex: /([a-zA-Z0-9-]+)/
	optionalScopeBeginRegex: /(?:/
	optionalScopeEndRegex: /)?/
	escapeCharacter: (next) ->
		# is just prepending '\' enough for all special chars?
		'\\' + next

	readVariableName: (string,i) ->
		result = /^([a-zA-Z0-9-]+)/.exec(string)
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
		result = result_array.join()
		@regex = new RegExp(result)
