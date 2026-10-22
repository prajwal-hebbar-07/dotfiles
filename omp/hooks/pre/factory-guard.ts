// Factory guard (SOFTWARE-FACTORY.md §7, contract "Guard behaviour").
//
// While `<repo>/.factory/state.json` has `guard: true`, blocks:
//   - `gh pr merge` / any github-tool merge op
//   - `gh pr create` / github `pr_create` unless prApprovals[branch] === HEAD sha
//   - `git push` / github `pr_push` to a branch outside factory/* and feature/*,
//     and any --force / -f without --force-with-lease
//   - edit / write / ast_edit of a file that is a stamped gate's `file`
// Independently of `guard`: any tool input mentioning `.omp/factory/` from a
// subagent other than factory-qa / factory-qa-author (holdout scenarios).
//
// Never throws (a throw blocks every call). Internal errors allow the call.
// No network. No runtime imports from omp packages.
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, isAbsolute, join, resolve } from "node:path";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const HOLDOUT_FRAGMENT = ".omp/factory/";
const HOLDOUT_FRAGMENT_BARE = ".omp/factory";
const HOLDOUT_ALLOWED = new Set(["factory-qa", "factory-qa-author"]);
const ALLOWED_PUSH = /^(factory|feature)\/./;
const EDIT_TOOLS = new Set(["edit", "write", "ast_edit"]);
const PATH_KEYS = new Set(["path", "paths", "file", "files", "file_path", "filePath", "filepath"]);

type Block = { block: true; reason: string };
type Logger = { warn?: (...a: unknown[]) => void; error?: (...a: unknown[]) => void };
type State = {
	guard?: boolean;
	gates?: Record<string, { file?: string } | undefined>;
	prApprovals?: Record<string, string>;
};
type StateRead = { root: string; state: State } | undefined;

function findRoot(dir: string): string | undefined {
	let cur = resolve(dir);
	for (;;) {
		if (existsSync(join(cur, ".git"))) return cur;
		const up = dirname(cur);
		if (up === cur) return undefined;
		cur = up;
	}
}

function readState(dir: string, log: Logger | undefined): StateRead {
	const root = findRoot(dir);
	if (!root) return undefined;
	const file = join(root, ".factory", "state.json");
	if (!existsSync(file)) return undefined;
	try {
		const state = JSON.parse(readFileSync(file, "utf8")) as State;
		if (!state || typeof state !== "object") return undefined;
		return { root, state };
	} catch (err) {
		log?.warn?.(`factory-guard: cannot parse ${file}: ${String(err)}`);
		return undefined;
	}
}

function git(root: string, args: string[]): string | undefined {
	try {
		return execFileSync("git", ["-C", root, ...args], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
			timeout: 5000,
		}).trim();
	} catch {
		return undefined;
	}
}

function currentBranch(root: string): string {
	return git(root, ["rev-parse", "--abbrev-ref", "HEAD"]) ?? "HEAD";
}

function realish(p: string): string {
	try {
		return realpathSync(p);
	} catch {
		return resolve(p);
	}
}

function expandHome(p: string): string {
	if (p === "~") return homedir();
	if (p.startsWith("~/")) return join(homedir(), p.slice(2));
	return p;
}

// Minimal shell tokenizer: honours single/double quotes and backslash escapes.
function tokenize(segment: string): string[] {
	const out: string[] = [];
	let cur = "";
	let has = false;
	let quote: string | null = null;
	for (let i = 0; i < segment.length; i++) {
		const c = segment[i];
		if (quote) {
			if (c === quote) quote = null;
			else if (c === "\\" && quote === '"' && i + 1 < segment.length) cur += segment[++i];
			else cur += c;
		} else if (c === "'" || c === '"') {
			quote = c;
			has = true;
		} else if (c === "\\" && i + 1 < segment.length) {
			cur += segment[++i];
			has = true;
		} else if (/\s/.test(c)) {
			if (has || cur) out.push(cur);
			cur = "";
			has = false;
		} else {
			cur += c;
			has = true;
		}
	}
	if (has || cur) out.push(cur);
	return out;
}

// Split a command line on && || ; | & and newlines, outside quotes.
function splitSegments(cmd: string): string[] {
	const segs: string[] = [];
	let cur = "";
	let quote: string | null = null;
	for (let i = 0; i < cmd.length; i++) {
		const c = cmd[i];
		if (quote) {
			cur += c;
			if (c === quote) quote = null;
			else if (c === "\\" && quote === '"' && i + 1 < cmd.length) cur += cmd[++i];
			continue;
		}
		if (c === "'" || c === '"') {
			quote = c;
			cur += c;
		} else if (c === "\\" && i + 1 < cmd.length) {
			cur += c + cmd[++i];
		} else if (c === "&" || c === "|" || c === ";" || c === "\n") {
			segs.push(cur);
			cur = "";
			while (i + 1 < cmd.length && (cmd[i + 1] === "&" || cmd[i + 1] === "|")) i++;
		} else {
			cur += c;
		}
	}
	segs.push(cur);
	return segs.map(s => s.trim()).filter(Boolean);
}

function stripPrefix(tokens: string[]): string[] {
	let i = 0;
	while (i < tokens.length && /^[A-Za-z_][A-Za-z0-9_]*=/.test(tokens[i])) i++;
	while (i < tokens.length && ["sudo", "command", "exec", "env", "time", "nohup"].includes(tokens[i])) i++;
	while (i < tokens.length && /^[A-Za-z_][A-Za-z0-9_]*=/.test(tokens[i])) i++;
	return tokens.slice(i);
}

type GitPush = { dir?: string; force: boolean; lease: boolean; targets: string[]; unknownTarget: boolean; bare: boolean };

const PUSH_VALUE_FLAGS = new Set(["--repo", "-o", "--push-option", "--receive-pack", "--exec", "--signed"]);

function parseGitPush(tokens: string[]): GitPush | undefined {
	if (tokens[0] !== "git") return undefined;
	let i = 1;
	let dir: string | undefined;
	while (i < tokens.length && tokens[i] !== "push") {
		const t = tokens[i];
		if (t === "-C" && i + 1 < tokens.length) {
			dir = tokens[i + 1];
			i += 2;
		} else if ((t === "-c" || t === "--git-dir" || t === "--work-tree" || t === "--namespace") && i + 1 < tokens.length) {
			i += 2;
		} else if (t.startsWith("-")) {
			i += 1;
		} else {
			return undefined; // another git subcommand
		}
	}
	if (tokens[i] !== "push") return undefined;
	const res: GitPush = { dir, force: false, lease: false, targets: [], unknownTarget: false, bare: false };
	const positionals: string[] = [];
	for (i += 1; i < tokens.length; i++) {
		const t = tokens[i];
		if (t === "--") {
			positionals.push(...tokens.slice(i + 1));
			break;
		}
		if (t.startsWith("--")) {
			if (t === "--force") res.force = true;
			else if (t.startsWith("--force-with-lease")) res.lease = true;
			else if (t === "--all" || t === "--mirror" || t === "--branches") res.unknownTarget = true;
			else if (PUSH_VALUE_FLAGS.has(t)) i++;
			continue;
		}
		if (t.startsWith("-") && t.length > 1) {
			const cluster = t.slice(1);
			if (cluster.includes("f")) res.force = true;
			if (cluster === "o") i++;
			continue;
		}
		positionals.push(t);
	}
	const refspecs = positionals.slice(1);
	if (refspecs.length === 0) res.bare = true;
	res.targets = refspecs;
	return res;
}

// Resolve a refspec's destination branch; null = cannot determine.
function refspecDest(spec: string, current: string): { dest: string; plus: boolean } {
	let s = spec;
	let plus = false;
	if (s.startsWith("+")) {
		plus = true;
		s = s.slice(1);
	}
	const colon = s.indexOf(":");
	let dst = colon >= 0 ? s.slice(colon + 1) : s;
	if (colon >= 0 && dst === "") dst = s.slice(0, colon);
	if (dst === "HEAD") dst = current;
	dst = dst.replace(/^refs\/heads\//, "");
	return { dest: dst, plus };
}

function pushReason(branches: string[], what: string): string | undefined {
	for (const b of branches) {
		if (!ALLOWED_PUSH.test(b)) {
			return `factory guard: ${what} to '${b}' is blocked while the factory run is active. Only factory/* and feature/* branches may be pushed; main and other branches change through a reviewed PR.`;
		}
	}
	return undefined;
}

function forceReason(what: string): string {
	return `factory guard: ${what} with --force/-f is blocked while the factory run is active. Use --force-with-lease if a rewrite is really needed.`;
}

function checkPush(p: GitPush, root: string, what: string): Block | undefined {
	if (p.force && !p.lease) return { block: true, reason: forceReason(what) };
	const current = currentBranch(root);
	if (p.unknownTarget) {
		return {
			block: true,
			reason: `factory guard: ${what} with --all/--mirror is blocked while the factory run is active. Push one factory/* or feature/* branch by name.`,
		};
	}
	const branches: string[] = [];
	if (p.bare) branches.push(current);
	for (const spec of p.targets) {
		const { dest, plus } = refspecDest(spec, current);
		if (plus && !p.lease) return { block: true, reason: forceReason(what) };
		branches.push(dest);
	}
	const reason = pushReason(branches, what);
	return reason ? { block: true, reason } : undefined;
}

function prCreateReason(root: string, state: State, head: string | undefined, what: string): Block | undefined {
	const branch = head ?? currentBranch(root);
	const sha = git(root, ["rev-parse", head ?? "HEAD"]);
	const approved = state.prApprovals?.[branch];
	if (sha && approved === sha) return undefined;
	const why = !approved
		? `no PR approval is recorded for '${branch}'`
		: `the approval for '${branch}' is for ${approved.slice(0, 8)} but HEAD is ${sha ? sha.slice(0, 8) : "unknown"}`;
	return {
		block: true,
		reason: `factory guard: ${what} is blocked: ${why}. Run the PR gate (skill://factory-gate), then 'factory-state pr-approve ${branch} <head sha>'.`,
	};
}

function mergeReason(what: string): Block {
	return {
		block: true,
		reason: `factory guard: ${what} is blocked. The factory never merges; the human merges the PR.`,
	};
}

function collectPaths(v: unknown, out: string[], key = ""): void {
	if (typeof v === "string") {
		if (PATH_KEYS.has(key)) out.push(v);
	} else if (Array.isArray(v)) {
		for (const x of v) collectPaths(x, out, key);
	} else if (v && typeof v === "object") {
		for (const [k, x] of Object.entries(v)) collectPaths(x, out, k);
	}
}

function checkBash(command: string, cwd: string, log: Logger | undefined): Block | undefined {
	let dir = cwd;
	for (const seg of splitSegments(command)) {
		let tokens = stripPrefix(tokenize(seg));
		if (tokens.length === 0) continue;
		if (tokens[0] === "cd" && tokens[1]) {
			dir = resolve(dir, expandHome(tokens[1]));
			continue;
		}
		const push = parseGitPush(tokens);
		const isGh = tokens[0] === "gh";
		if (!push && !isGh) continue;
		let segDir = dir;
		if (push?.dir) segDir = resolve(dir, expandHome(push.dir));
		const st = readState(segDir, log);
		if (!st || st.state.guard !== true) continue;
		if (push) {
			const hit = checkPush(push, st.root, "git push");
			if (hit) return hit;
			continue;
		}
		// gh [global flags] pr <sub> ...
		tokens = tokens.slice(1);
		const prIdx = tokens.indexOf("pr");
		if (prIdx < 0) continue;
		const sub = tokens[prIdx + 1];
		if (sub === "merge") return mergeReason("gh pr merge");
		if (sub === "create") {
			let head: string | undefined;
			for (let i = prIdx + 2; i < tokens.length; i++) {
				if ((tokens[i] === "--head" || tokens[i] === "-H") && tokens[i + 1]) head = tokens[i + 1];
				else if (tokens[i].startsWith("--head=")) head = tokens[i].slice(7);
			}
			// `owner:branch` form: use the branch part
			if (head?.includes(":")) head = head.split(":").pop();
			const hit = prCreateReason(st.root, st.state, head, "gh pr create");
			if (hit) return hit;
		}
	}
	return undefined;
}

function checkGithub(input: Record<string, unknown>, cwd: string, log: Logger | undefined): Block | undefined {
	const st = readState(cwd, log);
	if (!st || st.state.guard !== true) return undefined;
	const op = String(input.op ?? "");
	if (/merge/i.test(op)) return mergeReason(`github ${op}`);
	if (op === "pr_create") {
		const head = typeof input.head === "string" && input.head ? input.head.split(":").pop() : undefined;
		return prCreateReason(st.root, st.state, head, "github pr_create");
	}
	if (op === "pr_push") {
		const branch = typeof input.branch === "string" && input.branch ? input.branch : currentBranch(st.root);
		const reason = pushReason([branch], "github pr_push");
		return reason ? { block: true, reason } : undefined;
	}
	return undefined;
}

function checkEdit(input: Record<string, unknown>, cwd: string, log: Logger | undefined): Block | undefined {
	const st = readState(cwd, log);
	if (!st || st.state.guard !== true) return undefined;
	const paths: string[] = [];
	collectPaths(input, paths);
	if (paths.length === 0) return undefined;
	const gates = Object.entries(st.state.gates ?? {});
	for (const p of paths) {
		const abs = realish(isAbsolute(expandHome(p)) ? expandHome(p) : resolve(cwd, p));
		for (const [name, gate] of gates) {
			if (!gate?.file) continue;
			if (abs === realish(resolve(st.root, gate.file))) {
				return {
					block: true,
					reason: `factory guard: '${gate.file}' is the approved '${name}' doc and is read-only. Reopen the gate ('factory-state reopen ${name}') and get it re-approved before changing it.`,
				};
			}
		}
	}
	return undefined;
}

function checkHoldout(input: unknown, agent: { kind?: string; name?: string } | undefined): Block | undefined {
	if (!agent || agent.kind !== "sub") return undefined;
	const name = String(agent.name ?? "");
	if (HOLDOUT_ALLOWED.has(name.toLowerCase())) return undefined;
	const text = JSON.stringify(input ?? {});
	if (!text.includes(HOLDOUT_FRAGMENT) && !text.includes(`${HOLDOUT_FRAGMENT_BARE}"`) && !text.endsWith(HOLDOUT_FRAGMENT_BARE)) {
		return undefined;
	}
	return {
		block: true,
		reason: `factory holdout guard: agent "${name}" may not access ~/${HOLDOUT_FRAGMENT} (holdout scenarios are visible only to factory-qa and factory-qa-author)`,
	};
}

export default function factoryGuard(pi: ExtensionAPI): void {
	pi.on("tool_call", async (event, ctx) => {
		const log: Logger | undefined = pi.logger;
		try {
			const input = (event.input ?? {}) as Record<string, unknown>;
			const holdout = checkHoldout(input, ctx.agent);
			if (holdout) return holdout;

			const cwd = ctx.cwd || process.cwd();
			if (event.toolName === "bash") {
				return checkBash(String(input.command ?? ""), cwd, log);
			}
			if (event.toolName === "github") return checkGithub(input, cwd, log);
			if (EDIT_TOOLS.has(event.toolName)) return checkEdit(input, cwd, log);
		} catch (err) {
			try {
				log?.error?.(`factory-guard: internal error, allowing call: ${String(err)}`);
			} catch {
				// ignore
			}
		}
		return undefined;
	});
}
