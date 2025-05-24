require! {
  fs, path, mkdirp
  'js-yaml': YAML
}

module.exports = (logPath) ->
  peg-pass = (ast) !->
    mkdirp.sync <| path.dirname logPath
    fs.writeFileSync logPath, YAML.dump ast, 'utf-8'

  use: (config, options) -> config.passes.transform.push peg-pass
