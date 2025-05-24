require! {
  fs, path, mkdirp
  pegjs: PEG
  'pegjs-livescript-plugin'
}

export parseFile, parseString, writeParser, parseFileWith

grammarPath = path.resolve __dirname, '../src/peg-html-parser.pegls'
grammar     = fs.readFileSync grammarPath, 'utf-8'
defPlugins  = [pegjs-livescript-plugin]

function parseFile contentFilePath, plugins
  content = fs.readFileSync contentFilePath, 'utf-8'
  parseString content, plugins

function parseString content, plugins=[]
  parser = wrapPegError -> PEG.generate grammar, cache: true, plugins: defPlugins ++ plugins
  parser.parse content

!function writeParser savePath, plugins=[]
  genParserSource = wrapPegError -> PEG.generate grammar, cache: true, plugins: defPlugins ++ plugins, output: 'source'
  absPath = path.resolve savePath
  mkdirp.sync <| path.dirname absPath
  fs.writeFileSync absPath, "module.exports = #genParserSource;", 'utf-8'

function parseFileWith grammarFilePath, contentFilePath, plugins
  content = fs.readFileSync contentFilePath, 'utf-8'
  grammar = fs.readFileSync grammarFilePath, 'utf-8'
  parser = wrapPegError -> PEG.generate grammar, cache: true, plugins: defPlugins ++ plugins
  parser.parse content

function wrapPegError f
  try
    f!
  catch ex
    ex.message = "Line #{that.line}, Column #{that.column} (#{that.offset}) #{ex.message}" if ex.location?start?
    throw ex
