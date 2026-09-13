import type { OAuthAccountIdentity, UsageReport } from "@oh-my-pi/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const PROVIDER = "openai-codex";
const STATUS_KEY = "codex-quota";
const WINDOWS = ["5h", "7d"] as const;

export function formatCodexQuota(
	reports: readonly UsageReport[],
	identity: OAuthAccountIdentity | undefined,
	now = Date.now(),
): string | undefined {
	if (!identity?.accountId) return undefined;
	const remaining: Partial<Record<(typeof WINDOWS)[number], number>> = {};
	for (const report of reports) {
		if (report.provider !== PROVIDER) continue;
		// Match the session's account, not another account in the shared usage cache.
		if ((report.metadata?.accountId ?? report.metadata?.account_id) !== identity.accountId) continue;
		if (identity.orgId && report.metadata?.orgId !== identity.orgId) continue;
		for (const limit of report.limits) {
			// Standard subscription only: never fill a missing window with Spark's pool.
			if (limit.scope.tier || limit.scope.modelId) continue;
			const windowId = limit.scope.windowId ?? limit.window?.id;
			if (windowId !== "5h" && windowId !== "7d") continue;
			if (remaining[windowId] !== undefined) continue;
			if (limit.window?.resetsAt !== undefined && limit.window.resetsAt <= now) continue;
			const fraction =
				limit.amount.remainingFraction ??
				(limit.amount.usedFraction === undefined ? undefined : 1 - limit.amount.usedFraction);
			if (fraction === undefined || !Number.isFinite(fraction)) continue;
			remaining[windowId] = Math.round(Math.max(0, Math.min(1, fraction)) * 100);
		}
	}
	let text = "";
	for (const windowId of WINDOWS) {
		if (remaining[windowId] === undefined) continue;
		if (text) text += " · ";
		text += `${windowId} ${remaining[windowId]}% left`;
	}
	return text || undefined;
}

export default function codexQuota(pi: ExtensionAPI): void {
	let inFlight = false;
	let stopped = false;

	async function refresh(ctx: ExtensionContext): Promise<void> {
		if (stopped || !ctx.hasUI) return;
		if (ctx.models.current()?.provider !== PROVIDER) {
			ctx.ui.setStatus(STATUS_KEY, undefined);
			return;
		}
		if (inFlight) return;
		inFlight = true;
		try {
			const auth = ctx.modelRegistry.authStorage;
			const reports = await auth.fetchUsageReports({ signal: AbortSignal.timeout(10_000) });
			if (stopped) return;
			const identity = auth.getOAuthAccountIdentity(PROVIDER, ctx.sessionManager.getSessionId());
			ctx.ui.setStatus(
				STATUS_KEY,
				ctx.models.current()?.provider === PROVIDER ? formatCodexQuota(reports ?? [], identity) : undefined,
			);
		} catch {
			// Unavailable is not zero remaining; don't leave an old quota on screen.
			if (!stopped) ctx.ui.setStatus(STATUS_KEY, undefined);
		} finally {
			inFlight = false;
		}
	}

	pi.on("session_start", (_event, ctx) => {
		if (!ctx.hasUI) return;
		ctx.setTimeout(() => refresh(ctx), 0);
		ctx.setInterval(() => refresh(ctx), 60_000);
	});
	pi.on("session_switch", (_event, ctx) => {
		ctx.ui.setStatus(STATUS_KEY, undefined);
		ctx.setTimeout(() => refresh(ctx), 0);
	});
	pi.on("agent_end", (_event, ctx) => {
		if (ctx.hasUI) ctx.setTimeout(() => refresh(ctx), 0);
	});
	pi.on("session_shutdown", (_event, ctx) => {
		stopped = true;
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}
