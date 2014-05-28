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
```


