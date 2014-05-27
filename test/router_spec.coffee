describe "Router", ->
	describe "#on and #dispatch", ->
		it "allows you to define a route and dispatch an url", ->
			r = new Router()
			promise = ""
			r.on "/users/:id", (id) -> promise += id
			r.dispatch("/users/1")
			r.dispatch("/users/2")
			expect(promise).toBe("12")

	describe "#start", ->
		it "starts listening to defined routes", ->
			r = new Router()
			promise = ""
			r.on "/users/:id", (id) -> promise += id

