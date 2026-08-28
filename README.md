# pawelniszczota.github.io

Personal academic website for Paweł Niszczota, published with GitHub Pages from the `docs/` directory.

## Editing the site

The published site is intentionally dependency-free: its canonical files are the HTML pages in `docs/`, with shared styles and behavior in `docs/assets/`. This keeps the site fast and makes GitHub Pages deployment deterministic.

The legacy R Markdown files in the repository are retained for reference, but they are not synchronized with every published page. Do not run `rmarkdown::render_site()` against the main checkout until the missing R Markdown sources have been reconstructed and the content has been reconciled; a render would overwrite the current site.

For a local preview, serve the `docs/` directory with any static web server and open its root URL.
