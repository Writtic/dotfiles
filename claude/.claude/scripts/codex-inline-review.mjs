#!/usr/bin/env node
// Codex adversarial review with the full diff inlined into the prompt.
// The companion's adversarial-review inlines the diff only for <= 2 changed files; above that Codex
// re-collects it with git/sed/rg, and each extra tool call costs ~8s of model reasoning.
// Usage: codex-inline-review.mjs [--base <ref>] [--scope working-tree|branch] [--model <id>] [--effort <level>] [--dry-run]
import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const MAX_INLINE_BYTES = 256 * 1024; // same cap the companion uses; larger diffs fall back to adversarial-review

const args = process.argv.slice(2);
const opt = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : fallback;
};
const dryRun = args.includes("--dry-run");
const model = opt("model", "gpt-6-astra");
const effort = opt("effort", "high");
const scope = opt("scope", "working-tree");

const git = (...a) => execFileSync("git", a, { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
const repoRoot = git("rev-parse", "--show-toplevel").trim();
process.chdir(repoRoot);

const defaultBase = () => {
  try {
    return git("symbolic-ref", "--short", "refs/remotes/origin/HEAD").trim();
  } catch {
    return "main";
  }
};
const base = opt("base", defaultBase());

const companionDir = (() => {
  const root = path.join(os.homedir(), ".claude/plugins/cache/openai-codex/codex");
  const versions = fs.readdirSync(root).sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
  return path.join(root, versions.at(-1));
})();
const companion = path.join(companionDir, "scripts/codex-companion.mjs");

const untracked = git("ls-files", "--others", "--exclude-standard").split("\n").filter(Boolean);
if (!["working-tree", "branch"].includes(scope)) {
  console.error(`Unknown scope "${scope}". Use working-tree or branch.`);
  process.exit(2);
}

let label;
let context;
if (scope === "working-tree") {
  label = "working tree (staged, unstaged, untracked)";
  // /dev/null diffs show untracked files as additions; exit code 1 means "differences found".
  const untrackedDiff = untracked
    .map((f) => spawnSync("git", ["diff", "--no-index", "-U10", "--", "/dev/null", f], { encoding: "utf8" }).stdout)
    .join("");
  context =
    `## Status\n${git("status", "--short", "--untracked-files=all")}\n` +
    `## Diff\n\`\`\`diff\n${git("diff", "HEAD", "-U10")}${untrackedDiff}\`\`\`\n`;
} else {
  label = `branch diff against ${base}`;
  context =
    `## Commits\n${git("log", "--oneline", `${base}..HEAD`)}\n` +
    `## Changed files\n${git("diff", "--stat", `${base}...HEAD`)}\n` +
    `## Diff\n\`\`\`diff\n${git("diff", "-U10", `${base}...HEAD`)}\`\`\`\n`;
}

if (!context.includes("\n+") && !context.includes("\n-")) {
  console.log(`Nothing to review for scope ${scope}.`);
  process.exit(0);
}

const run = (cmdArgs) => {
  if (dryRun) {
    console.log(`would run: node ${companion} ${cmdArgs.join(" ")}`);
    process.exit(0);
  }
  process.exit(spawnSync("node", [companion, ...cmdArgs], { stdio: "inherit" }).status ?? 1);
};

if (Buffer.byteLength(context) > MAX_INLINE_BYTES) {
  console.log(`[inline-review] diff over ${MAX_INLINE_BYTES} bytes, falling back to adversarial-review.`);
  run(["adversarial-review", "--wait", "--base", base, "--scope", scope, "--model", model]);
}

const template = fs.readFileSync(path.join(companionDir, "prompts/adversarial-review.md"), "utf8");
const schema = fs.readFileSync(path.join(companionDir, "schemas/review-output.schema.json"), "utf8");
const prompt =
  template
    .replaceAll("{{REVIEW_KIND}}", "Adversarial Review")
    .replaceAll("{{TARGET_LABEL}}", label)
    .replaceAll("{{USER_FOCUS}}", "No extra focus provided.")
    .replaceAll(
      "{{REVIEW_COLLECTION_GUIDANCE}}",
      "The full diff is inlined below; treat it as primary evidence. Read surrounding code only to confirm or reject a specific suspicion. Do not search the web, spawn sub-agents, or load skills."
    )
    .replaceAll("{{REVIEW_INPUT}}", context) +
  `\n<output_schema>\nReturn only one JSON object matching this schema, with no prose around it.\n${schema}\n</output_schema>\n`;

const promptFile = path.join(os.tmpdir(), `codex-inline-review-${process.pid}.md`);
fs.writeFileSync(promptFile, prompt);
console.log(`[inline-review] scope=${scope} base=${base} prompt=${Buffer.byteLength(prompt)} bytes file=${promptFile}`);
run(["task", "--model", model, "--effort", effort, "--prompt-file", promptFile]);
