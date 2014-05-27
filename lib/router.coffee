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
class Router
	routes: {}
	###
	# Constructs a BrowRouter that will listen to browser navigations
	# and trigger registered routes. Won't start listening until the
	# start method has been invoked.
	###
	constructor: ->

	start: (runCurrent)->
		# register navigation listener
		@browser = new Browser(true, (url) => @dispatch(url))
		if runCurrent
			@dispatch(document.location.hash)

	###
	# Register a route
	###
	on: (route, callback) ->
		# populate route registration
		@routes[route] ||= new RouteListener(route)
		@routes[route].callbacks.push(callback)
	
	# stop listening to a route
	stop: (route,callback) ->
		listener = @routes[route]
		index = -1
		for cb,i in listener.callbacks
			index = i if cb == callback

		if index > -1
			listener.callbacks.splice(index,1)

		if listener.callbacks.length == 0
			delete @routes[route]
		
	###
	# Trigger on an url
	###
	dispatch: (url) ->
		for r,v of @routes
			v.trigger(url)