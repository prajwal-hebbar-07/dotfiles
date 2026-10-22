// Run: node --test omp/hooks/tests omp/extensions/tests
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, realpathSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, test } from "node:test";
import stageGuard from "../factory-stage-guard.ts";

type Ctx = { cwd: string; sessionManager?: { getSessionFile(): string }; agent?: { kind: string; id: string } };
type Handler = (event: unknown, ctx: Ctx) => Promise<Record<string, unknown> | undefined>;

function load(): Record<string, Handler> {
	const handlers: Record<string, Handler> = {};
	const pi = {
		logger: { warn() {}, error() {} },
		on(ev: string, fn: Handler) {
			handlers[ev] = fn;
		},
	};
	stageGuard(pi as never);
	return handlers;
}
const h = load();

function repo(state?: Record<string, unknown> | string): string {
	const dir = realpathSync(mkdtempSync(join(tmpdir(), "sguard-")));
	mkdirSync(join(dir, ".git"));
	if (state !== undefined) {
		mkdirSync(join(dir, ".factory"));
		writeFileSync(join(dir, ".factory/state.json"), typeof state === "string" ? state : JSON.stringify(state));
	}
	return dir;
}
const st = (extra: Record<string, unknown> = {}) => ({
	version: 1,
	guard: true,
	stage: "requirements",
	stop: null,
	blockedOnUser: false,
	unattended: true,
	guardStage: { exitMet: false, reason: "REQUIREMENTS.md not stamped" },
	...extra,
});

let sessions = 0;
// A fresh session in `cwd` (as a new chat would be).
function session(cwd: string, kind = "main"): Ctx {
	const file = `/sessions/s${++sessions}.jsonl`;
	return { cwd, sessionManager: { getSessionFile: () => file }, agent: { kind, id: file } };
}
const bash = (command: string) => ({ toolName: "bash", input: { command } });
// A session that ran `factory-state unattended on` itself.
async function armed(cwd: string): Promise<Ctx> {
	const ctx = session(cwd);
	await h.tool_call(bash(`~/.omp/agent/skills/factory/scripts/factory-state unattended on "PR not open"`), ctx);
	return ctx;
}

describe("session_stop", () => {
	test("registers its handlers", () => {
		assert.equal(typeof h.session_stop, "function");
		assert.equal(typeof h.tool_call, "function");
		assert.equal(typeof h["session.compacting"], "function");
	});
	test("blocks the arming session when exit unmet, no stop, not blocked on user", async () => {
		const r = await h.session_stop({}, await armed(repo(st())));
		assert.equal(r?.decision, "block");
		assert.equal(
			r?.reason,
			"Factory stage 'requirements' has not met its exit predicate (REQUIREMENTS.md not stamped). Continue the stage, or park at a stop (factory-state stop S<n>), or mark blocked on the user (factory-state blocked-on-user on).",
		);
	});
	test("never traps a session that did not arm the run (new chat after Ctrl+C / Ctrl+D)", async () => {
		const dir = repo(st());
		await armed(dir); // the killed session
		assert.equal(await h.session_stop({}, session(dir)), undefined);
	});
	test("a resumed run re-arms in its own session", async () => {
		const dir = repo(st());
		assert.equal((await h.session_stop({}, await armed(dir)))?.decision, "block");
	});
	test("unattended off disarms; a subagent cannot arm", async () => {
		const dir = repo(st());
		const ctx = await armed(dir);
		await h.tool_call(bash("factory-state unattended off"), ctx);
		assert.equal(await h.session_stop({}, ctx), undefined);
		const sub = session(dir, "sub");
		await h.tool_call(bash("factory-state unattended on x"), sub);
		assert.equal(await h.session_stop({}, sub), undefined);
	});
	test("works from a subdirectory", async () => {
		const dir = repo(st());
		mkdirSync(join(dir, "src/deep"), { recursive: true });
		assert.equal((await h.session_stop({}, await armed(join(dir, "src/deep"))))?.decision, "block");
	});
	test("allows when exit met", async () => {
		assert.equal(await h.session_stop({}, await armed(repo(st({ guardStage: { exitMet: true, reason: "" } })))), undefined);
	});
	test("allows when parked at a stop", async () => {
		assert.equal(await h.session_stop({}, await armed(repo(st({ stop: "S2" })))), undefined);
	});
	test("allows when blocked on user", async () => {
		assert.equal(await h.session_stop({}, await armed(repo(st({ blockedOnUser: true })))), undefined);
	});
	test("allows interactive stages (unattended not set)", async () => {
		assert.equal(await h.session_stop({}, await armed(repo(st({ unattended: false })))), undefined);
		assert.equal(await h.session_stop({}, await armed(repo(st({ unattended: undefined })))), undefined);
	});
	test("allows when guard false, no state, no repo, corrupt state", async () => {
		assert.equal(await h.session_stop({}, await armed(repo(st({ guard: false })))), undefined);
		assert.equal(await h.session_stop({}, await armed(repo())), undefined);
		assert.equal(await h.session_stop({}, await armed(realpathSync(mkdtempSync(join(tmpdir(), "sguard-norepo-"))))), undefined);
		assert.equal(await h.session_stop({}, await armed(repo("{bad"))), undefined);
	});
});

describe("session.compacting", () => {
	test("adds context in a guarded repo", async () => {
		const r = await h["session.compacting"]({}, { cwd: repo(st()) });
		assert.deepEqual(r, {
			context: ["Read .factory/state.json and .factory/ledger.tsv before continuing; resume per skill://factory/state.md."],
		});
	});
	test("nothing when unguarded or no state", async () => {
		assert.equal(await h["session.compacting"]({}, { cwd: repo(st({ guard: false })) }), undefined);
		assert.equal(await h["session.compacting"]({}, { cwd: repo() }), undefined);
	});
});
