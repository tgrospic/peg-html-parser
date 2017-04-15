/**
 * PEG HTML parser test suite
 */
require! {
  '../lib/parser': {parseString, parseFile}
  '../lib/runner': {readFiles}
  tape: test
}

test 'should parse empty input', (t) ->
  t.plan 1
  result = parseString '   '
  t.deepEqual result, []

test 'should throw on invalid input', (t) ->
  t.plan 1
  t.throws -> result = parseString '<a></script>'

test 'should parse one element', (t) ->
  t.plan 1
  result = parseString '<div>Test</div>'
  t.deepEqual result, [
    node: "div"
    content: [node: "text", content: "Test"]
  ]

test 'should parse nested elements', (t) ->
  t.plan 1
  result = parseString '<div>Test <p>Nested text <b>with bold</b> part.</p></div>'
  expected =
    node: "div"
    content :
      * node: "text", content: "Test "
      * node: "p"
        content:
          * node: "text", content: "Nested text "
          * node: "b", content: [node: "text", content: "with bold"]
          * node: "text", content: "part."
    ...
  t.deepEqual result, expected

test 'should parse all fixtures', (t) ->
  readFiles '../fixtures', ["**/*.html"]
    .forEach do
      (file) ->
        # parse file
        try
          output = parseFile file.path
          console.log "✔ #{file.name}"
        catch ex
          console.log "✖ #{file.name}"
          t.fail ex
      void
      -> t.end!
