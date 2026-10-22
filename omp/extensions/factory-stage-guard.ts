// Factory stage guard (SOFTWARE-FACTORY.md §5.6).
// session_stop: in a guarded repo, during an unattended run (state.unattended),
// refuse to end the turn while the current stage has not met its exit
// predicate, unless parked at a stop or blocked on the user. Interactive
// stages (interview, grilling, gates) never set `unattended`, so their turns
// end normally while waiting for the user. session.compacting: remind the
// model to re-read run state.
// No runtime imports from omp packages. Never throws.
import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

type State = {
	guard?: boolean;
	stage?: string;
	stop?: string | null;
	blockedOnUser?: boolean;
	unattended?: boolean;
	guardStage?: { exitMet?: boolean; reason?: string };
};

function loadState(cwd: string): State | undefined {
	let cur = resolve(cwd);
	for (;;) {
		if (existsSync(join(cur, ".git"))) break;
		const up = dirname(cur);
		if (up === cur) return undefined;
		cur = up;
	}
	const file = join(cur, ".factory", "state.json");
	if (!existsSync(file)) return undefined;
	const state = JSON.parse(readFileSync(file, "utf8")) as State;
	return state && state.guard === true ? state : undefined;
}

export default function factoryStageGuard(pi: ExtensionAPI): void {
	pi.on("session_stop", async (_event, ctx) => {
		try {
			const state = loadState(ctx.cwd || process.cwd());
			if (!state) return undefined;
			if (state.unattended !== true) return undefined;
			if (state.guardStage?.exitMet === true || state.stop || state.blockedOnUser === true) return undefined;
			return {
				decision: "block" as const,
				reason: `Factory stage '${state.stage ?? "unknown"}' has not met its exit predicate (${state.guardStage?.reason ?? ""}). Continue the stage, or park at a stop (factory-state stop S<n>), or mark blocked on the user (factory-state blocked-on-user on).`,
			};
		} catch (err) {
			pi.logger?.warn?.(`factory-stage-guard: ${String(err)}`);
			return undefined;
		}
	});

	pi.on("session.compacting", async (_event, ctx) => {
		try {
			if (!loadState(ctx.cwd || process.cwd())) return undefined;
			return {
				context: ["Read .factory/state.json and .factory/ledger.tsv before continuing; resume per skill://factory/state.md."],
			};
		} catch (err) {
			pi.logger?.warn?.(`factory-stage-guard: ${String(err)}`);
			return undefined;
		}
	});
}
