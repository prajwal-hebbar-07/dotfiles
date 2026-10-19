import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

// Holdout scenarios live under ~/.omp/factory/<repo>/<work-id>/. Only the main
// session (the factory orchestrator, which writes them) and the `factory-qa`
// subagent may touch that tree. Every other subagent is blocked from any tool
// call whose input mentions it, whatever form the path takes (~, $HOME, absolute).
const PROTECTED_FRAGMENT = ".omp/factory";
const ALLOWED_SUBAGENT = "factory-qa";

export default function holdoutGuard(pi: ExtensionAPI): void {
	pi.on("tool_call", async (event, ctx) => {
		const agent = ctx.agent;
		if (!agent || agent.kind !== "sub") return;
		if (agent.name.toLowerCase() === ALLOWED_SUBAGENT) return;

		const input = JSON.stringify(event.input ?? {});
		if (!input.includes(PROTECTED_FRAGMENT)) return;

		return {
			block: true,
			reason: `factory holdout guard: agent "${agent.name}" may not access ~/${PROTECTED_FRAGMENT} (holdout scenarios are visible only to factory-qa)`,
		};
	});
}
