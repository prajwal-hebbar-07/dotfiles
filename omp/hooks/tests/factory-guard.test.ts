// Run: node --test omp/hooks/tests omp/extensions/tests
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, realpathSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, test } from "node:test";
import factoryGuard from "../pre/factory-guard.ts";

type Agent = { kind: "main" | "sub"; id: string; name: string; depth: number };
type Result = { block: boolean; reason: string } | undefined;
type Handler = (event: { toolName: string; input: Record<string, unknown> }, ctx: { cwd: string; agent?: Agent }) => Promise<Result>;

const warnings: string[] = [];
function load(): Handler {
	let h: Handler | undefined;
	const pi = {
		logger: { warn: (m: string) => warnings.push(m), error: (m: string) => warnings.push(m) },
		on(ev: string, fn: Handler) {
			if (ev === "tool_call") h = fn;
		},
	};
	factoryGuard(pi as never);
	assert.ok(h);
	return h;
}
const handler = load();
const main: Agent = { kind: "main", id: "m", name: "main", depth: 0 };
const sub = (name: string): Agent => ({ kind: "sub", id: `${name}-1`, name, depth: 1 });

function sh(cwd: string, ...args: string[]): string {
	return execFileSync("git", args, { cwd, encoding: "utf8" }).trim();
}

function repo(state?: Record<string, unknown> | string): { dir: string; head: string } {
	const dir = realpathSync(mkdtempSync(join(tmpdir(), "fguard-")));
	sh(dir, "init", "-q", "-b", "main");
	sh(dir, "config", "user.email", "t@t");
	sh(dir, "config", "user.name", "t");
	writeFileSync(join(dir, "a.txt"), "a");
	mkdirSync(join(dir, "docs/factory"), { recursive: true });
	writeFileSync(join(dir, "docs/factory/REQUIREMENTS.md"), "r");
	sh(dir, "add", ".");
	sh(dir, "commit", "-q", "-m", "init");
	const head = sh(dir, "rev-parse", "HEAD");
	if (state !== undefined) {
		mkdirSync(join(dir, ".factory"));
		writeFileSync(join(dir, ".factory/state.json"), typeof state === "string" ? state : JSON.stringify(state));
	}
	return { dir, head };
}

const guarded = (extra: Record<string, unknown> = {}) => ({ version: 1, guard: true, gates: {}, prApprovals: {}, ...extra });
const bash = (dir: string, command: string, agent: Agent = main) => handler({ toolName: "bash", input: { command } }, { cwd: dir, agent });
const blocked = (r: Result, re?: RegExp) => {
	assert.equal(r?.block, true, "expected block");
	assert.ok(r.reason.startsWith("factory"), r.reason);
	if (re) assert.match(r.reason, re);
};
const allowed = (r: Result) => assert.equal(r, undefined);

describe("merge", () => {
	test("gh pr merge blocked", async () => {
		const { dir } = repo(guarded());
		blocked(await bash(dir, "gh pr merge 12 --squash"), /never merges/);
		blocked(await bash(dir, "cd . && gh pr merge 12"), /never merges/);
	});
	test("github merge op blocked", async () => {
		const { dir } = repo(guarded());
		blocked(await handler({ toolName: "github", input: { op: "pr_merge" } }, { cwd: dir, agent: main }), /merge/);
	});
	test("gh pr view allowed", async () => {
		const { dir } = repo(guarded());
		allowed(await bash(dir, "gh pr view 12"));
	});
});

describe("not guarded", () => {
	test("no state file", async () => {
		const { dir } = repo();
		allowed(await bash(dir, "gh pr merge 1"));
		allowed(await bash(dir, "git push origin main"));
	});
	test("guard false", async () => {
		const { dir } = repo(guarded({ guard: false }));
		allowed(await bash(dir, "gh pr merge 1"));
		allowed(await bash(dir, "git push --force origin main"));
	});
	test("outside any repo", async () => {
		const dir = realpathSync(mkdtempSync(join(tmpdir(), "fguard-norepo-")));
		allowed(await bash(dir, "git push origin main"));
	});
	test("corrupt state file allows and logs", async () => {
		const { dir } = repo("{not json");
		warnings.length = 0;
		allowed(await bash(dir, "git push origin main"));
		assert.ok(warnings.some(w => w.includes("cannot parse")));
	});
	test("unrelated tools and commands", async () => {
		const { dir } = repo(guarded());
		allowed(await bash(dir, "ls -la && git status"));
		allowed(await handler({ toolName: "read", input: { path: "a.txt" } }, { cwd: dir, agent: main }));
		allowed(await bash(dir, "git commit -m 'git push origin main'"));
	});
});

describe("pr create", () => {
	test("no approval blocks", async () => {
		const { dir } = repo(guarded());
		sh(dir, "checkout", "-q", "-b", "factory/1-x");
		blocked(await bash(dir, "gh pr create --fill"), /no PR approval/);
		blocked(await handler({ toolName: "github", input: { op: "pr_create", fill: true } }, { cwd: dir, agent: main }), /no PR approval/);
	});
	test("approved at HEAD allows", async () => {
		const { dir, head } = repo(guarded({ prApprovals: { "factory/1-x": "" } }));
		sh(dir, "checkout", "-q", "-b", "factory/1-x");
		writeFileSync(join(dir, ".factory/state.json"), JSON.stringify(guarded({ prApprovals: { "factory/1-x": head } })));
		allowed(await bash(dir, "gh pr create --fill"));
		allowed(await handler({ toolName: "github", input: { op: "pr_create", fill: true } }, { cwd: dir, agent: main }));
	});
	test("stale approval blocks", async () => {
		const { dir, head } = repo(guarded({ prApprovals: { "factory/1-x": "" } }));
		sh(dir, "checkout", "-q", "-b", "factory/1-x");
		writeFileSync(join(dir, ".factory/state.json"), JSON.stringify(guarded({ prApprovals: { "factory/1-x": head } })));
		writeFileSync(join(dir, "b.txt"), "b");
		sh(dir, "add", ".");
		sh(dir, "commit", "-q", "-m", "more");
		blocked(await bash(dir, "gh pr create --fill"), /approval for 'factory\/1-x' is for/);
	});
	test("approval for another branch blocks", async () => {
		const { dir, head } = repo(guarded({ prApprovals: { "factory/2-y": "x" } }));
		sh(dir, "checkout", "-q", "-b", "factory/1-x");
		writeFileSync(join(dir, ".factory/state.json"), JSON.stringify(guarded({ prApprovals: { "factory/2-y": head } })));
		blocked(await bash(dir, "gh pr create --fill"));
	});
});

describe("git push", () => {
	const cases: [string, string, boolean][] = [
		["bare push on main", "git push", true],
		["origin main", "git push origin main", true],
		["-u origin main", "git push -u origin main", true],
		["HEAD:main", "git push origin HEAD:main", true],
		["HEAD:refs/heads/main", "git push origin HEAD:refs/heads/main", true],
		["other branch", "git push origin develop", true],
		["delete main", "git push origin :main", true],
		["factory branch", "git push -u origin factory/12-slug", false],
		["feature branch", "git push origin feature/login", false],
		["HEAD:feature", "git push origin HEAD:feature/x", false],
		["refs/heads feature", "git push origin HEAD:refs/heads/feature/x", false],
		["force", "git push --force origin factory/1-x", true],
		["-f", "git push -f origin factory/1-x", true],
		["plus refspec", "git push origin +factory/1-x", true],
		["force-with-lease", "git push --force-with-lease origin factory/1-x", false],
		["force-with-lease=ref", "git push --force-with-lease=factory/1-x origin factory/1-x", false],
		["--all", "git push --all origin", true],
		["chained", "echo hi && git push origin main", true],
		["env prefix", "GIT_SSH_COMMAND=x git push origin main", true],
	];
	for (const [label, cmd, shouldBlock] of cases) {
		test(label, async () => {
			const { dir } = repo(guarded());
			const r = await bash(dir, cmd);
			if (shouldBlock) blocked(r);
			else allowed(r);
		});
	}
	test("bare push on factory branch allowed, on feature allowed, on main blocked", async () => {
		const { dir } = repo(guarded());
		blocked(await bash(dir, "git push"));
		sh(dir, "checkout", "-q", "-b", "factory/3-z");
		allowed(await bash(dir, "git push"));
		sh(dir, "checkout", "-q", "-b", "feature/q");
		allowed(await bash(dir, "git push"));
	});
	test("git -C and cd <dir> use that repo", async () => {
		const guardedRepo = repo(guarded());
		const plain = repo();
		blocked(await bash(plain.dir, `git -C ${guardedRepo.dir} push origin main`));
		blocked(await bash(plain.dir, `cd ${guardedRepo.dir} && git push origin main`));
		allowed(await bash(guardedRepo.dir, `git -C ${plain.dir} push origin main`));
	});
	test("github pr_push", async () => {
		const { dir } = repo(guarded());
		const call = (input: Record<string, unknown>) => handler({ toolName: "github", input: { op: "pr_push", ...input } }, { cwd: dir, agent: main });
		blocked(await call({}), /pr_push/); // current branch main
		blocked(await call({ branch: "main" }));
		allowed(await call({ branch: "factory/1-x" }));
		allowed(await call({ branch: "feature/x", forceWithLease: true }));
	});
});

describe("stamped gate files", () => {
	const gates = { requirements: { file: "docs/factory/REQUIREMENTS.md", sha256: "x", approvedAt: "t" } };
	test("edit/write/ast_edit of stamped file blocked", async () => {
		const { dir } = repo(guarded({ gates }));
		for (const toolName of ["edit", "write", "ast_edit"]) {
			blocked(await handler({ toolName, input: { path: "docs/factory/REQUIREMENTS.md" } }, { cwd: dir, agent: main }), /read-only/);
		}
		blocked(await handler({ toolName: "write", input: { path: join(dir, "docs/factory/REQUIREMENTS.md"), content: "x" } }, { cwd: dir, agent: main }));
		blocked(await handler({ toolName: "edit", input: { path: "./docs/../docs/factory/REQUIREMENTS.md" } }, { cwd: dir, agent: main }));
	});
	test("unstamped doc and other files allowed", async () => {
		const { dir } = repo(guarded({ gates }));
		allowed(await handler({ toolName: "write", input: { path: "docs/factory/STACK.md", content: "x" } }, { cwd: dir, agent: main }));
		allowed(await handler({ toolName: "edit", input: { path: "a.txt" } }, { cwd: dir, agent: main }));
	});
	test("reopened gate (no stamp) allowed; guard off allowed", async () => {
		const a = repo(guarded());
		allowed(await handler({ toolName: "edit", input: { path: "docs/factory/REQUIREMENTS.md" } }, { cwd: a.dir, agent: main }));
		const b = repo(guarded({ gates, guard: false }));
		allowed(await handler({ toolName: "edit", input: { path: "docs/factory/REQUIREMENTS.md" } }, { cwd: b.dir, agent: main }));
	});
});

describe("holdout", () => {
	const inputs: Record<string, unknown>[] = [
		{ path: "~/.omp/factory/repo/holdout/1/scenarios.md" },
		{ command: "cat $HOME/.omp/factory/repo/holdout/1/s.md" },
		{ path: "/Users/x/.omp/factory/repo" },
	];
	test("blocked for other subagents, even unguarded", async () => {
		const { dir } = repo(); // no state file at all
		for (const name of ["factory-builder", "task", "sub", "factory-qa-review", "scout"]) {
			for (const input of inputs) {
				const r = await handler({ toolName: "read", input }, { cwd: dir, agent: sub(name) });
				blocked(r, /holdout/);
				assert.ok(r?.reason.includes(`"${name}"`));
			}
		}
	});
	test("allowed for factory-qa, factory-qa-author (any case) and main session", async () => {
		const { dir } = repo();
		for (const input of inputs) {
			allowed(await handler({ toolName: "read", input }, { cwd: dir, agent: sub("factory-qa") }));
			allowed(await handler({ toolName: "read", input }, { cwd: dir, agent: sub("Factory-QA-Author") }));
			allowed(await handler({ toolName: "read", input }, { cwd: dir, agent: main }));
			allowed(await handler({ toolName: "read", input }, { cwd: dir }));
		}
	});
	test("unrelated subagent input allowed", async () => {
		const { dir } = repo();
		allowed(await handler({ toolName: "read", input: { path: "a.txt" } }, { cwd: dir, agent: sub("factory-builder") }));
	});
});

describe("robustness", () => {
	test("odd inputs never throw", async () => {
		for (const [toolName, input] of [["bash", {}], ["bash", { command: 5 }], ["github", {}], ["edit", { path: 3 }], ["write", undefined]] as const) {
			allowed(await handler({ toolName, input: input as never }, { cwd: "/nonexistent/dir", agent: main }));
		}
	});
});
