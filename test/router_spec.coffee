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
			