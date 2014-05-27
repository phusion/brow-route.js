# Transcribed from https://github.com/flatiron/director
# Copyright Nodejitsu Inc.: https://github.com/flatiron/director/blob/master/LICENSE
dloc = document.location

dlocHashEmpty = ->  
	# Non-IE browsers return '' when the address bar shows '#'
	dloc.hash == "" or dloc.hash == "#"

class Browser
	onHashChanged: (onChangeEvent) ->
		@handler(dloc.hash, e)

	constructor: (history, handler) ->
		@hash = dloc.hash
		@history = history
		@handler = handler
		#note IE8 is being counted as 'modern' because it has the hashchange event
		if window.onhashchange? and (!document.documentMode? or document.documentMode > 7)
			# At least for now HTML5 history is available for 'modern' browsers only
			window.onhashchange = (e) => @onHashChanged(e)
			@mode = "modern"
		else
			@installIEHack()
			@mode = "legacy"
		@mode

	stop: -> @handler = ->

	fire: ->
		if @mode is "modern"
			if @history
				window.onpopstate()
			else
				window.onhashchange()
		else
			@onHashChanged()

	setHash: (s) ->
		# Mozilla always adds an entry to the history
		@writeFrame(s) if @mode == "legacy"

		if @history
			window.history.pushState({}, document.title, s)
			# Fire an onpopstate event manually since pushing does not obviously
			# trigger the pop event.
			@fire()
		else
			if s[0] == "/"
				dloc.hash = s
			else
				dloc.hash = "/" + s

	##
	# Functions below implement IE support, based on a concept by Erik Arvidson
	##
	installIEHack: ->
		throw "IE support is untested, remove this line and carefully test. Please send results to author."
		window._IERouteListener = @

		frame = document.createElement("iframe")
		frame.id = "state-frame"
		frame.style.display = "none"
		document.body.appendChild(frame)

		if document.onpropertychange? and document.attachEvent?
			document.attachEvent "onpropertychange", =>
				if event.propertyName == "location"
					@check()
		else
			window.setInterval((=> @check()), 50)

	writeFrame: (s) ->
		f = document.getElementById("state-frame")
		d = f.contentDocument or f.contentWindow.document
		d.open()
		d.write "<script>_hash = '" + s + "'; onload = parent._IERouteListener.syncHash;<script>"
		d.close()

	syncHash: ->
		s = @_hash
		dloc.hash = s unless s == dloc.hash

	check: ->
		h = dloc.hash
		unless h is @hash
			@hash = h
			@onHashChanged()
