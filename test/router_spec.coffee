describe "Router", ->
	Router = BrowRoute.Router
	###
	# Set asynchronous timeout interval.
	###
	originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL
	beforeEach ->
		jasmine.DEFAULT_TIMEOUT_INTERVAL = 500
	afterEach ->
		jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout

	describe "#on and #dispatch", ->
		it "allows you to define a route and dispatch an url", ->
			r = new Router()
			promise = ""
			r.on "/users/:id", (id) -> promise += id
			r.dispatch("/users/1")
			r.dispatch("/users/2")
			r.stopAll()
			expect(promise).toBe("12")

		it "sets the #path property to the given hash", ->
			r = new Router()
			r.on "/users/:id", (id) -> id
			r.dispatch("/users/1")
			expect(r.path).toBe("/users/1")
			r.dispatch("/users/2")
			expect(r.path).toBe("/users/2")
			r.stopAll()

	describe "#constructor", ->
		it "allows you to specify you want to receive a params object", ->
			r = new Router(true)
			promise = ""
			r.on "/users/:id/:something", (params) ->
				promise += params.id + params.something
			r.dispatch("/users/1/2")
			r.dispatch("/users/3/4")
			r.stopAll()
			expect(promise).toBe("1234")

		it "with a params object still gives you decoded options", ->
			r = new Router(true)
			promise = ""
			r.on "/users/:id", (params, options) ->
				promise += params.id + options.something
			r.dispatch("/users/1?something=2")
			r.dispatch("/users/3?something=4")
			r.stopAll()
			expect(promise).toBe("1234")

	describe "#start", ->
		r = null

		beforeEach ->
			window.location.hash = ''
			r = new Router()
			r.start()

		afterEach ->
			r.stopAll()
			window.location.hash = ''

		it "starts listening to defined routes", (done)->
			r.on "/users/:id", (id) ->
				expect(id).toBe('1')
				done()
			window.location.hash = '/users/1'

		it "can be tested sequentially", (done)->
			r.on "/users/:id", (id) ->
				expect(id).toBe('2')
				done()
			window.location.hash = '/users/2'

	describe "#goTo", ->
		r = null

		beforeEach ->
			window.location.hash = ''
			r = new Router()

		afterEach ->
			r.stopAll()
			window.location.hash = ''

		it "navigates to the given route", (done) ->
			r.on "/users/:id", (id) -> done()
			r.start()
			r.goTo "/users/1"

		it "navigates to the given route when the router is started", (done) ->
			r.on "/users/:id", (id) -> done()
			r.goTo "/users/1"
			r.start()

	describe "#browser", ->
		r = null

		beforeEach ->
			window.location.hash = ''
			r = new Router()
			r.start()

		afterEach ->
			r.stopAll()
			window.location.hash = ''

		it "should have a working setHash function", (done)->
			r.on "/users/:id", (id) ->
				expect(id).toBe('1')
				done()
			r.browser.setHash '/users/1'
