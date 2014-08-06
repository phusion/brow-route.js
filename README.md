Brow Route
==========
A simple hash based router for modern web applications
------------------------------------------------------

Usage example:

```
var router = new BrowRoute.Router()
router.on("books/:book_id/chapters/:chapter_id(/:action)", function(book_id, chapter_id, action, options) {
    Application.Run(BookChapterController, book_id, chapter_id, action, options);
})
router.start()
```

You can then visit this route by going to:

    http://your-url.nl/your-brow-route-app#/books/1/chapters/12/show-summary?language=dutch

And the parameters passed into the handler would be: `1,12,’show-summary’,{language: “dutch”}`

Contributing
-------

You can develop on this project by first installing it like:

    npm install

Then you can compile and watch the project by running:

    gulp watch

And then you can run the test environment like:

    karma start

And you’re ready to rock! Let me know if you’ve got some nice features or fixes. I want to keep the project
nice and clean but perhaps there’s some room for improvements or handy features. I’ll respond to PR’s quickly.

Credits
-------

A bunch of the routing logic was inspired on the codebase of director.js
