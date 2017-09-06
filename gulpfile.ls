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
		files		= glob.sync('vendor/src/*.c').join(' ')
		functions	= JSON.stringify([
			'_malloc'
			'_free'
			'_ed25519_create_keypair'
			'_ed25519_sign'
			'_ed25519_verify'
		])
		# Options that are only specified to optimize resulting file size and basically remove unused features
		optimize	= "-Oz --llvm-lto 1 --closure 1 -s NO_EXIT_RUNTIME=1 -s NO_FILESYSTEM=1 -s EXPORTED_RUNTIME_METHODS=[] -s DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=[]"
		command		= "emcc supercop.c #files -o supercop.js -s MODULARIZE=1 -s EXPORTED_FUNCTIONS='#functions' -s WASM=1 #optimize"
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
							entries			: file.path
							standalone		: 'supercop_wasm'
							builtins		: []
							detectGlobals	: false
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
