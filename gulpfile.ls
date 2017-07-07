/**
 * @package   supercop.wasm
 * @author    Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @copyright Copyright (c) 2017, Nazar Mokrynskyi
 * @license   MIT License, see license.txt
 */
browserify	= require('browserify')
del			= require('del')
exec		= require('child_process').exec
fs			= require('fs')
glob		= require('glob')
gulp		= require('gulp')
rename		= require('gulp-rename')
tap			= require('gulp-tap')
uglify		= require('gulp-uglify')
DESTINATION	= 'dist'

gulp
	.task('build', ['clean', 'wasm', 'browserify', 'minify'], !->
		gulp.src('supercop.wasm')
			.pipe(gulp.dest(DESTINATION))
	)
	.task('wasm', (callback) !->
		files	= glob.sync('vendor/src/*.c').join(' ')
		command	= "emcc supercop.c #files -o supercop.js -O2 --closure 1 -s WASM=1"
		exec(command, (error, stdout, stderr) !->
			if stdout
				console.log(stdout)
			if stderr
				console.error(stderr)
			callback(error)
		)
	)
	.task('browserify', ['clean', 'wasm'], ->
		gulp.src('index.js', {read: false})
			.pipe(tap(
				(file) !->
					file.contents	=
						browserify(
							entries		: file.path
							standalone	: 'supercop_wasm'
						)
							.bundle()
			))
			.pipe(rename(
				basename: 'supercop.wasm.browser'
			))
			.pipe(gulp.dest(DESTINATION))
	)
	.task('clean', ->
		del(DESTINATION)
	)
	.task('minify', ['browserify'], ->
		gulp.src("#DESTINATION/*.js")
			.pipe(uglify())
			.pipe(rename(
				suffix: '.min'
			))
			.pipe(gulp.dest(DESTINATION))
	)
