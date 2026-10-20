# Claude Skills & Tools for Designing UI in Paper (paper.design)

Paper is a DOM-based design canvas: designs are real HTML/CSS, so Claude can read and write them with high fidelity through Paper's MCP server.

> **Requirement:** Install the Paper Desktop app. The MCP server runs locally from the desktop app (not the browser version) at `http://127.0.0.1:29979/mcp`, while a Paper file is open.
> Download: https://paper.design/downloads

---

## 1. Official setup

### Paper Desktop plugin (official, by Paper)
The official Claude Code plugin. It connects Claude to your Paper canvas for both directions:
- **Code → design:** use your repo's tokens, styles and components to generate new designs on the canvas
- **Design → code:** turn a Paper frame into components in your framework
- Can pull tokens from Figma and build a design system on the Paper canvas