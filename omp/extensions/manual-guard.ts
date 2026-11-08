import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

// Blocks every OMP tool call that names a file called manual.md, in the main
// session and in every subagent. It sees only what a call names: a shell glob
// or a recursive search that reaches the file without naming it gets through,
// which the `manual-md` rule forbids and the `.gitignore` entry hides from
// OMP's own searches.

// manual.md as a whole path component, any case (macOS paths are
// case-insensitive), with an optional :selector or #tag after it.
const NAME = /(?:^|[^\w.-])manual\.md(?![\w-])/i;

// Tools whose arguments are only prose, never a file they open.
const PROSE_TOOLS: Record<string, true> = { ask: true, task: true, todo: true, wait: true, web_search: true };

// Prose arguments of other tools: the intent line, search patterns and
// queries, and file bodies, which may mention the file without touching it.
const PROSE_KEYS: Record<string, true> = { i: true, pattern: true, query: true, content: true, input: true };

// An `edit` patch names its targets in `[PATH#TAG]` headers and `MV DEST`.
const EDIT_TARGET = /^\s*(?:\[(.+)#[0-9A-Fa-f]{4}\]|MV\s+(.+?))\s*$/;

const REASON =
	"manual.md is the user's private file. OMP's manual-guard extension blocks every tool call that names it. " +
	"Do not retry, work around it, or reach it another way; carry on without it.";

function mentions(value: unknown): boolean {
	if (typeof value === "string") return NAME.test(value);
	if (Array.isArray(value)) return value.some(mentions);
	if (value && typeof value === "object") return Object.values(value).some(mentions);
	return false;
}

function editTargetsIt(patch: string): boolean {
	return patch.split("\n").some(line => {
		const match = EDIT_TARGET.exec(line);
		return match !== null && NAME.test(match[1] ?? match[2]);
	});
}

function namesManual(tool: string, input: Record<string, unknown>): boolean {
	if (PROSE_TOOLS[tool] === true) return false;
	return Object.entries(input).some(([key, value]) => {
		if (key === "input" && tool === "edit" && typeof value === "string") return editTargetsIt(value);
		// A write to an xd:// device carries the device's arguments, paths
		// included, as JSON in `content`.
		if (key === "content" && tool === "write" && String(input.path ?? "").startsWith("xd://")) return mentions(value);
		if (PROSE_KEYS[key] === true) return false;
		return mentions(value);
	});
}

export default function manualGuard(pi: ExtensionAPI) {
	pi.on("tool_call", async event => {
		const input = (event.input ?? {}) as Record<string, unknown>;
		if (namesManual(event.toolName, input)) return { block: true, reason: REASON };
	});
}
