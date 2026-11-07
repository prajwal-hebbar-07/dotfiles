// tmux-style prefix, mirroring dotfiles/tmux/tmux.conf. keys.json binds
// ctrl-s to `mod.open:prefix`; this popup takes the next key, closes, and runs
// what that key is bound to. Esc or any unbound key just closes it.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, theme, focused, exec } from "herdr";

// Tools start through a login + interactive zsh so PATH matches the shell
// (Homebrew, ~/.local/bin for pk-preview / pk-mdopen).
const tool = (name, cmd) => ({ name: "terminal.open", args: { argv: ["zsh", "-lic", cmd], name } });

const MARKDOWN =
  'f=$(fd -t f -e md -e markdown | fzf --select-1 --exit-0 --preview "pk-preview {}" --preview-window=right,60%,border-left) && pk-mdopen "$f"';

// [keys, label, action]; the first key is the one shown.
const GROUPS = [
  ["Tabs", [
    [["c"], "new tab", { name: "tab.new" }],
    [["1-9"], "select tab", null],
    [["r"], "rename tab", { name: "tab.rename" }],
    [["S"], "rename space", { name: "space.rename" }],
    [["s"], "spaces list", { name: "spaces-keys.focus" }],
    [["a"], "agents list", { name: "agents-keys.focus" }],
    [["X"], "close tab", { name: "tab.close" }],
  ]],
  ["Panes", [
    [["\\", "|"], "split right", { name: "pane.split", args: { direction: "right" } }],
    [["-"], "split down", { name: "pane.split", args: { direction: "down" } }],
    [["h"], "go left", { name: "pane.go", args: { direction: "left" } }],
    [["j"], "go down", { name: "pane.go", args: { direction: "down" } }],
    [["k"], "go up", { name: "pane.go", args: { direction: "up" } }],
    [["l"], "go right", { name: "pane.go", args: { direction: "right" } }],
    [["m"], "zoom", { name: "pane.zoom" }],
    [["x"], "close pane", { name: "pane.close" }],
  ]],
  ["Tools", [
    [["e"], "nvim", tool("nvim", "nvim .")],
    [["g"], "lazygit", tool("lazygit", "lazygit")],
    [["v"], "markdown", tool("markdown", MARKDOWN)],
    [["ctrl-s"], "send ctrl-s", { send: "ctrl+s" }],
  ]],
];

const ACTIONS = {};
for (const [, binds] of GROUPS) for (const [keys, , action] of binds) if (action) for (const k of keys) ACTIONS[k] = action;
for (let i = 1; i <= 9; i++) ACTIONS[String(i)] = { name: "tab.select", args: { index: i } };

const MODIFIER_KEYS = new Set(["shift", "control", "ctrl", "alt", "platform", "cmd", "function", "fn"]);

// Printable keys compare by the character typed ("X", "|"); chords with
// ctrl/alt/cmd by their keystroke spelling ("ctrl-s").
const chord = (e) => {
  const m = e.modifiers;
  return m.control || m.alt || m.platform ? e.keystroke : (e.key_char ?? e.key);
};

export default class Prefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  fire(action) {
    closeOverlay(props().overlay);
    if (!action) return;
    if (action.send) {
      const terminal = focused()?.terminal;
      if (terminal) exec("hc", ["keys", terminal, action.send]);
      return;
    }
    run(action.name, action.args ?? {});
  }

  render(cx) {
    const t = theme();
    const key = (label) =>
      div().min_w(22).px(5).rounded(4).bg(t.raised).text_color(t.accent).font_semibold().child(label);
    const row = ([keys, label]) =>
      h_flex().gap(8).items_center().child(key(keys[0])).child(div().text_color(t.muted).child(label));
    return v_flex()
      .id("prefix")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (MODIFIER_KEYS.has(e.key)) return;
        cx.stop_propagation();
        this.fire(ACTIONS[chord(e)]);
      })
      .size_full()
      .p(14)
      .gap(10)
      .bg(t.popover)
      .text_size(12)
      .child(
        h_flex().items_center()
          .child(div().flex_1().text_size(13).font_semibold().text_color(t.foreground).child("ctrl-s"))
          .child(div().text_size(11).text_color(t.dim).child("Esc")),
      )
      .child(
        h_flex().gap(24).items_start().children(
          GROUPS.map(([title, binds]) =>
            v_flex().gap(5)
              .child(div().text_size(11).text_color(t.dim).child(title))
              .children(binds.map(row)),
          ),
        ),
      );
  }
}
