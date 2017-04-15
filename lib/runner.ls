require! {
  fs, path, mkdirp
  'prelude-ls': {map, partition, any, all, id}
  'js-yaml': YAML
  './parser': {parseFileWith}
  './peg-print-ast-plugin'
  chalk: {cyan, blue, gray, red, magenta, white, yellow}
  minimatch: {Minimatch}
  rx: {Observable: O}
}

export readFiles

if process.argv.2 then
  runAll that

function runAll pegSourcePath
  tmpDir      = '.watch'
  pegFileName = path.basename pegSourcePath
  # show what's running
  console.log blue 'PEG grammar', white pegFileName

  console.time cyan 'DONE'
  readFiles '../test/fixtures', ["**/*.html"]
    # .take 3
    .forEach do
      (file) ->
        try
          # parse file, log AST and output
          fileName = path.basename file.path
          output = parseFileWith pegSourcePath, file.path, [peg-print-ast-plugin "#tmpDir/#fileName.ast.yaml"]
          outputFile  = "#tmpDir/#fileName.yaml"
          mkdirp <| path.dirname outputFile
          fs.writeFileSync outputFile, stringify output, 'utf-8'
          console.log cyan " ✔ #{yellow file.path}"
        catch ex
          console.log red " ✖ #{file.path}"
          throw ex
      void
      ->
        console.timeEnd cyan 'DONE'

function stringify o
  YAML.dump o, indent: 2, flowLevel: -1

/**
 * Read files
 */
function readFiles startDir, patterns, options
  mBind = (s, th) --> O::flatMap.call th, s
  isMatch = mkPathMatcher patterns, options
  traverse = mkTraverse mBind, O.just, O.fromNodeCallback
  traverse startDir .filter isMatch

function mkTraverse mBind, mReturn, fromNodeCB
  mMap = (f) -> mBind (a) -> mReturn f a
  stat_ = fromNodeCB fs.stat
  lstat_ = fromNodeCB fs.lstat
  readdir_ = fromNodeCB fs.readdir

  readDirRec = (dir, root=__dirname) ->
    root = path.resolve __dirname, root unless path.isAbsolute root
    dir  = path.resolve root, dir       unless path.isAbsolute dir

    readdir_ dir
    |> mBind id
    |> mBind (fileName) ->
      p = new
        @name = fileName
        @path = path.resolve dir, @name
        @relPath = path.relative root, @path
      lstat_ p.path |> mMap (stat) -> p <<< {stat}
    |> mBind (p) ->
      if p.stat.isDirectory!
        then readDirRec p.relPath, root
        else mReturn p

function mkPathMatcher patterns, options
  # Minimatch matchers from patterns
  createMM = (pattern) -> new Minimatch pattern, options
  [negPatterns, posPatterns] = patterns |> map createMM |> partition (.negate)
  (file) ->
    isMatch = (mm) -> mm.match file.path
    any isMatch, posPatterns and all isMatch, negPatterns
