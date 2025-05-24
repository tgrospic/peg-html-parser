require! {
  child_process: {spawn}
  chalk: {blue, white, red, green}, chokidar, del
  './lib/parser': {writeParser}
}

export build, watch, clean, clean-all

if process.argv.3 then
  console.log green 'Starting task', white that
  module.exports[that]!
    .then -> console.log green 'Done task', white that
    .catch (.stack) >> red >> console.log

function build
  clean! .then -> writeParser './dist/peg-html-parser.js'

function watch
  suffix = if /^win/.test(process.platform) then '.cmd' else ''
  clean-watch! .then ->
    var p
    chokidar.watch ['src/**/*.pegls'] .on 'change', (file) ->
      p?.kill!
      p := spawn "lsc#suffix", ['lib/runner.ls', file], cwd: process.cwd!, stdio: ['inherit', 'inherit', 'pipe']
      p.stderr.on 'data', red >> console.log

function clean
  clean-watch! .then clean-dist

function clean-watch
  del ['.watch']

function clean-dist
  del ['dist']

function clean-all
  clean! .then -> del ['node_modules']
