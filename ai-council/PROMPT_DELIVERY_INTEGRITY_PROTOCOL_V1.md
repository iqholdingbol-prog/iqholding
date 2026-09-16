# AI Council — Prompt Delivery Integrity Protocol V1

Date: 2026-09-16
Status: `ACTIVE`

## Purpose
Prevent an AI collaborator from being evaluated against instructions it never actually received.

## Pre-dispatch gate
Before sending any repository prompt to Claude, DeepSeek, Gemini, Codex or another collaborator, the coordinator must verify:

1. the prompt path is reachable on the intended current branch/ref;
2. the retrieved content matches the intended mission;
3. the exact commit/ref is recorded;
4. if the collaborator cannot access the repository, the prompt is pasted inline or attached in full;
5. required source documents are either accessible or their relevant contents are supplied;
6. expected deliverables and final gate line are included in the delivered prompt.

## Evidence states

- `PROMPT_REACHABLE_VERIFIED`
- `PROMPT_INLINE_DELIVERED`
- `PROMPT_ATTACHMENT_DELIVERED`
- `PROMPT_ACCESS_LIMITATION`
- `PROMPT_DELIVERY_UNVERIFIED`

Only the first three states may be used for strict compliance scoring.

## Post-response audit
Every AI response must be audited against:

- exact prompt actually delivered;
- sources actually available to that collaborator;
- required minimums;
- unsupported assumptions;
- contradictions with canonical business facts;
- provenance/evidence quality;
- semantic correctness;
- omissions;
- residual risks.

If prompt delivery was incomplete, classify the response for usefulness but do not attribute missing prompt-specific requirements solely to the collaborator.

## Repository-write safety
After creating or updating an AI Council prompt, verify the file again from the target branch. A commit SHA alone is not sufficient evidence that the file is reachable from the current branch head.

If the file is not reachable:

- do not dispatch by path;
- repair branch continuity or paste the prompt inline;
- preserve the orphaned commit as historical evidence;
- do not rewrite history destructively.

## Anti-loop rule
Do not request V2/V3 merely to increase volume. Reopen only when there is:

- new evidence;
- a material contradiction;
- a corrected prompt-delivery defect;
- a new exact artifact to attack;
- or a critical unmet requirement.

## Canonical principle

`DELIVERED INSTRUCTION + AVAILABLE EVIDENCE -> RESPONSE -> AUDIT`

Never:

`INTENDED INSTRUCTION -> assume collaborator saw it -> punish response`
