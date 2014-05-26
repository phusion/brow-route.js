describe "A suite", ->
	it "Contains a spec with an expectation", ->
		expect(true).toBe(true)

describe "RouteListener", ->
	describe "#compile", ->
		rl = new RouteListener("")
		
		it "should return a regex formed from the route", ->
			rl.route = "/users"
			rl.compile()
			expect(rl.regex.source).toBe("/users")
		
	describe "#matches", ->
		it "should return wether a given route matches a given url", ->
			rl = new RouteListener("/users")
			expect(rl.matches("/users")).toBe(true)
