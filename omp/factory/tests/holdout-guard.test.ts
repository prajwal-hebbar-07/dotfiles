// Run: node --test omp/factory/tests/
import assert from "node:assert/strict";
import { describe, test } from "node:test";
import holdoutGuard from "../extensions/holdout-guard.ts";

type Agent = { kind: "main" | "sub"; id: string; name: string; depth: number };
type ToolCall = { toolName: string; input: Record<string, unknown> };
type Handler = (event: ToolCall, ctx: { agent?: Agent }) => Promise<{ block: boolean; reason: string } | undefined>;

function loadHandler(): Handler {
	let handler: Handler | undefined;
	const pi = {
		on(event: string, fn: Handler) {
			if (event === "tool_call") handler = fn;
		},
	};
	holdoutGuard(pi as never);
	assert.ok(handler, "holdout guard registers a tool_call handler");
	return handler;
}

const handler = loadHandler();
const sub = (name: string): Agent => ({ kind: "sub", id: `${name}-1`, name, depth: 1 });
const main: Agent = { kind: "main", id: "main", name: "main", depth: 0 };

const SCENARIOS = "eval-repo/eval-001/scenarios.md";
const PROTECTED_CALLS: [string, ToolCall][] = [
	["read with ~", { toolName: "read", input: { path: `~/.omp/factory/${SCENARIOS}` } }],
	["bash cat with ~", { toolName: "bash", input: { command: `cat ~/.omp/factory/${SCENARIOS}` } }],
	["bash cat with $HOME", { toolName: "bash", input: { command: `cat $HOME/.omp/factory/${SCENARIOS}` } }],
	["read with absolute path", { toolName: "read", input: { path: `/Users/someone/.omp/factory/${SCENARIOS}` } }],
	["grep under the tree", { toolName: "grep", input: { pattern: "S1", path: "~/.omp/factory" } }],
];

const NON_QA_AGENTS = [
	"factory-builder",
	"factory-features",
	"factory-review-arch",
	"factory-review-code",
	"factory-review-gpt",
	"factory-review-security",
	"factory-review-slice",
	"factory-review-standin",
	"factory-review-standin-alt",
	"factory-review-tests",
	"factory-review-ui",
	"factory-review-ux",
	"task",
	"sub",
];

describe("non-QA subagents are blocked from the holdout tree", () => {
	for (const name of NON_QA_AGENTS) {
		for (const [label, call] of PROTECTED_CALLS) {
			test(`${name}: ${label}`, async () => {
				const result = await handler(call, { agent: sub(name) });
				assert.equal(result?.block, true);
				assert.ok(result.reason.startsWith("factory holdout guard:"), result.reason);
				assert.ok(result.reason.includes(`"${name}"`), result.reason);
			});
		}
	}
});

describe("allowed callers reach the holdout tree", () => {
	for (const [label, call] of PROTECTED_CALLS) {
		test(`factory-qa: ${label}`, async () => {
			assert.equal(await handler(call, { agent: sub("factory-qa") }), undefined);
		});
		test(`main session: ${label}`, async () => {
			assert.equal(await handler(call, { agent: main }), undefined);
		});
		test(`no agent context: ${label}`, async () => {
			assert.equal(await handler(call, {}), undefined);
		});
	}

	test("factory-qa match ignores case", async () => {
		assert.equal(await handler(PROTECTED_CALLS[0][1], { agent: sub("Factory-QA") }), undefined);
	});
});

describe("calls outside the holdout tree are not blocked", () => {
	const unrelated: [string, ToolCall][] = [
		["repo file", { toolName: "read", input: { path: "src/index.ts" } }],
		["other ~/.omp path", { toolName: "read", input: { path: "~/.omp/agent/config.yml" } }],
		["repo .factory state", { toolName: "read", input: { path: ".factory/eval-001/state.json" } }],
	];
	for (const [label, call] of unrelated) {
		test(`factory-builder: ${label}`, async () => {
			assert.equal(await handler(call, { agent: sub("factory-builder") }), undefined);
		});
	}
});
