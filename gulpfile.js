var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var runSequence = require('run-sequence');

var libraryName = "brow-route.coffee";

var sources = {
	coffee: "lib/**/*.coffee",
	tests: "test/**/*.coffee"
};

var destinations = {
	js: "dist/"
};

gulp.task('default', ['watch']);

gulp.task('build', function() {
	gulp.src(sources.coffee)
		.pipe(concat(libraryName))
		.pipe(coffee({bare: false}).on('error', gutil.log))
		.pipe(gulp.dest(destinations.js));
});

gulp.task('build-test', function() {
	gulp.src(sources.tests)
		.pipe(coffee({bare: true}).on('error', gutil.log))
		.pipe(gulp.dest(destinations.js));
})

gulp.task('watch', ['build', 'build-test', 'justWatch']);

gulp.task('justWatch', function() {
	gulp.watch(sources.coffee, ['build']);
	gulp.watch(sources.tests, ['build-test']);
});
