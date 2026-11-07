// cmd-q (keys.json: `mod.open:quit-all`): close every space, then quit.
// A plain app.quit leaves spaces and their terminals running in herdr-core
// (`keep: true`), so they come back on the next start; closing a space ends
// its terminals. Quit from the app menu or the Dock still runs plain app.quit.

import { View, div } from "gpui-kit";
import { spaces, run, props, theme } from "herdr";

export default class QuitAll extends View {
  init(_props, cx) {
    this.ids = spaces().map((s) => s.id);
    // Act only when opened by the key (an overlay), never when loaded otherwise.
    if (!props().overlay) return;
    cx.spawn(async () => {
      for (const id of this.ids) run("space.close", { id, confirmed: true });
      // Quit waits for pending terminal changes and layout writes.
      run("app.quit");
    });
  }

  render() {
    const t = theme();
    const n = this.ids.length;
    return div()
      .size_full()
      .p(14)
      .bg(t.popover)
      .text_size(13)
      .text_color(t.foreground)
      .child(`Closing ${n} space${n === 1 ? "" : "s"} and quitting…`);
  }
}
