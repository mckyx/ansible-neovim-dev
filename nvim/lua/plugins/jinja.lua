-- Dedicated highlighting for Jinja2 templates (*.j2, *.jinja, *.jinja2).
-- The plugin's own build.lua compiles the parser using our Tree-sitter CLI.
return {
  { 'geigerzaehler/tree-sitter-jinja2', config = true },
}
