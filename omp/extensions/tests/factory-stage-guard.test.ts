// Run: node --test omp/hooks/tests omp/extensions/tests
import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, realpathSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, test } from "node:test";
import stageGuard from "../factory-stage-guard.ts";

type Handler = (event: unknown, ctx: { cwd: string }) => Promise<Record<string, unknown> | undefined>;

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

describe("session_stop", () => {
	test("registers both handlers", () => {
		assert.equal(typeof h.session_stop, "function");
		assert.equal(typeof h["session.compacting"], "function");
	});
	test("blocks when exit unmet, no stop, not blocked on user", async () => {
		const r = await h.session_stop({}, { cwd: repo(st()) });
		assert.equal(r?.decision, "block");
		assert.equal(
			r?.reason,
			"Factory stage 'requirements' has not met its exit predicate (REQUIREMENTS.md not stamped). Continue the stage, or park at a stop (factory-state stop S<n>), or mark blocked on the user (factory-state blocked-on-user on).",
		);
	});
	test("works from a subdirectory", async () => {
		const dir = repo(st());
		mkdirSync(join(dir, "src/deep"), { recursive: true });
		assert.equal((await h.session_stop({}, { cwd: join(dir, "src/deep") }))?.decision, "block");
	});
	test("allows when exit met", async () => {
		assert.equal(await h.session_stop({}, { cwd: repo(st({ guardStage: { exitMet: true, reason: "" } })) }), undefined);
	});
	test("allows when parked at a stop", async () => {
		assert.equal(await h.session_stop({}, { cwd: repo(st({ stop: "S2" })) }), undefined);
	});
	test("allows when blocked on user", async () => {
		assert.equal(await h.session_stop({}, { cwd: repo(st({ blockedOnUser: true })) }), undefined);
	});
	test("allows interactive stages (unattended not set)", async () => {
		assert.equal(await h.session_stop({}, { cwd: repo(st({ unattended: false })) }), undefined);
		assert.equal(await h.session_stop({}, { cwd: repo(st({ unattended: undefined })) }), undefined);
	});
	test("allows when guard false, no state, no repo, corrupt state", async () => {
		assert.equal(await h.session_stop({}, { cwd: repo(st({ guard: false })) }), undefined);
		assert.equal(await h.session_stop({}, { cwd: repo() }), undefined);
		assert.equal(await h.session_stop({}, { cwd: realpathSync(mkdtempSync(join(tmpdir(), "sguard-norepo-"))) }), undefined);
		assert.equal(await h.session_stop({}, { cwd: repo("{bad") }), undefined);
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
