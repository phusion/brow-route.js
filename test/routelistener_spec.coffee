describe "RouteListener", ->
	describe "#variableNameRegex", ->
		it "should match a variable name in a string", ->
			rl = new RouteListener("")
			re = new RegExp(rl.variableNameRegex)
			expect(re.exec("simple")[1]).toBe("simple")
			expect(re.exec("complex_variable")[1]).toBe("complex_variable")
			expect(re.exec("comment_id#view")[1]).toBe("comment_id")
			expect(re.exec("/")).toBe(null)

	describe "#compile", ->
		rl = new RouteListener("")
		
		it "should return a regex formed from the route", ->
			rl.route = "/users"
			rl.compile()
			expect(rl.regex.source).toBe("^/users$")

		it "should make a regex that matches a variable", ->
			rl.route = "/users/:id"
			rl.compile()
			expect(rl.regex.source).toBe("^/users/" + rl.variableRegex + "$")

		it "should make a regex that matches two variables", ->
			rl.route = "/users/:id/comments/:comment_id"
			rl.compile()
			expect(rl.regex.source).toBe("^" +
				"/users/" + rl.variableRegex +
				"/comments/" + rl.variableRegex + "$"
				)
		
	describe "#matches", ->
		it "should return wether a given route matches a given url", ->
			rl = new RouteListener("/users")
			expect(rl.matches("/users")).toBeTruthy()

		it "should support routes with a variable", ->
			rl = new RouteListener("/users/:id")
			expect(rl.matches("/users/1")).toBeTruthy()

		it "should return the value of an url with a variable", ->
			rl = new RouteListener("/users/:id")
			matches = rl.matches("/users/1")
			expect(matches[0]).toBe("1")

		it "should support routes with more variables", ->
			rl = new RouteListener("/users/:id/comments/:comment_id")
			expect(rl.matches("/users/1/comments/2")).toBeTruthy()
			expect(rl.matches("/users/1")).not.toBeTruthy()

		it "should return the value of an url with more variables", ->
			rl = new RouteListener("/users/:id/comments/:comment_id")
			matches = rl.matches("/users/1/comments/2")
			expect(matches[0]).toBe '1'
			expect(matches[1]).toBe '2'

		it "should support routes with an optional part", ->
			rl = new RouteListener("/users/:id(/comments/:comment_id)")
			matches = rl.matches("/users/1")
			expect(matches).toBeTruthy()
			matches = rl.matches("/users/1/comments/2")
			expect(matches).toBeTruthy()
			expect(matches[0]).toBe '1'
			expect(matches[1]).toBe '2'

		it "supports an options hash passed in after a '?'", ->
			rl = new RouteListener("/users")
			matches = rl.matches("/users?hilight=kamina&a=b")
			expect(matches).toBeTruthy()
			expect(matches[0].hilight).toBe('kamina')
			expect(matches[0].a).toBe('b')