/**
 * @package supercop.wasm
 * @author  Nazar Mokrynskyi <nazar@mokrynskyi.com>
 * @license 0BSD
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
	.task('build', ['clean', 'wasm', 'browserify', 'fix_current_script', 'minify'], !->
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
		command		= "emcc src/supercop.c #files --post-js src/bytes_allocation.js -o supercop.js -s MODULARIZE=1 -s EXPORTED_FUNCTIONS='#functions' -s WASM=1 #optimize"
		exec(command, (error, stdout, stderr) !->
			if stdout
				console.log(stdout)
			if stderr
				console.error(stderr)
			callback(error)
		)
	)
	.task('browserify', ['clean', 'wasm'], ->
		gulp.src('src/index.js', {read: false})
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
	.task('fix_current_script', ['browserify'] !->
		contents	= fs.readFileSync('dist/supercop.wasm.browser.js', 'utf8')
		contents	=
			'(function () {var currentScriptReal = document.currentScript;' +
				contents.replace(/document\.currentScript/g, 'currentScriptReal') +
			'})();'
		fs.writeFileSync('dist/supercop.wasm.browser.js', contents)
	)
	.task('clean', ->
		del(DESTINATION)
	)
	.task('minify', ['browserify', 'fix_current_script'], ->
		gulp.src("#DESTINATION/*.js")
			.pipe(uglify())
			.pipe(rename(
				suffix: '.min'
			))
			.pipe(gulp.dest(DESTINATION))
	)
