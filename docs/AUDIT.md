# Cloud‑Resume — Optimization Audit & Roadmap

_Generated 2026‑06‑12. Full‑repository audit across UI/UX, frontend, backend, database, API,
performance, accessibility, security, testing, CI/CD, Terraform, and observability._

## Architecture Overview

Cloud Resume Challenge implementation: a single static page served from **S3 → CloudFront (OAC)**,
with a live visitor counter via **API Gateway → Lambda (Python 3.12) → DynamoDB**. Custom domain
(`www.ericchiu.page`) through Route53 + ACM. All infrastructure is modular Terraform with S3/DynamoDB
remote state. Deploys run through GitHub Actions using OIDC (no static keys).

```
Browser ──HTTPS──> CloudFront (OAC, PriceClass_100, security headers) ──> S3 (private, AES256)
   └─GET /count──> API Gateway (REGIONAL) ──AWS_PROXY──> Lambda ──atomic ADD──> DynamoDB
Route53 (apex + www A‑alias) · ACM (us-east-1)
```

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS (custom‑property tokens), vanilla JS (ES2022), Outfit + IBM Plex Mono |
| Backend | Python 3.12 Lambda (boto3) |
| Data | DynamoDB single table, PAY_PER_REQUEST |
| Cloud | S3, CloudFront, Lambda, API Gateway (REST), DynamoDB, Route53, ACM, IAM |
| IaC | Terraform AWS `~> 5.0`; modules: s3, cloudfront, lambda, api-gateway, dynamodb, acm, route53 |
| CI/CD | GitHub Actions + OIDC |
| Tests | pytest + moto (backend); ESLint configured |
| Monitoring | None beyond default CloudWatch logs |

---

## ✅ Implemented in this pass (P0 batch)

All changes verified locally: `pytest` 5/5, `terraform fmt -check`, `terraform validate`, YAML parse, `bash -n`.

| # | Change | Files |
|---|---|---|
| 1 | **Atomic counter.** Replaced read‑modify‑write (`get_item` + `SET`) with a single atomic `UpdateExpression="ADD #count :inc"` — eliminates the lost‑update race. Errors are logged server‑side and return a **generic** message (no internal leak). Added pytest+moto suite. | [handler.py](../backend/lambda/handler.py), [tests/](../tests/) |
| 2 | **CI split.** New [`deploy.yml`](../.github/workflows/deploy.yml) deploys **persistently** on push to `main` (no auto‑destroy). The old monolith became [`ephemeral-test.yml`](../.github/workflows/ephemeral-test.yml) — manual deploy→test→destroy only. Added `concurrency` group to serialize state ops. | `.github/workflows/` |
| 3 | **PR validation works.** `deploy.yml` adds a real `pull_request` trigger running `terraform fmt`/`validate` + Lambda tests (hard gates) and ESLint/ruff (advisory). The previous `if: pull_request` job was dead (no such trigger existed). | `deploy.yml` |
| 4 | **CloudFront security headers.** New `aws_cloudfront_response_headers_policy` adds **HSTS, CSP, X‑Content‑Type‑Options, X‑Frame‑Options, Referrer‑Policy, X‑XSS‑Protection** to every response. CSP is a configurable variable (allows Google Fonts + regional API). | [cloudfront/main.tf](../infrastructure/modules/cloudfront/main.tf) |
| + | **Publish fix.** Shared [`publish-frontend.sh`](../scripts/publish-frontend.sh) (used by both workflows + `deploy-web.sh`) corrects the previous bug where cache headers were applied to dead `css/`+`js/` paths the site never references, and sets explicit `text/javascript`/`text/css` MIME types — **required** now that `nosniff` is enforced. | `scripts/` |

> ⚠️ Before merging `deploy.yml`: pushing to `main` will now auto‑apply Terraform and publish.
> Confirm `role/github-OICD` trust policy allows the `main` branch ref.
> Also commit `infrastructure/environments/dev/.terraform.lock.hcl` (your `.gitignore` keeps it intentionally).

---

## Remaining Roadmap (prioritized by ROI)

### P1 — Short term
| Area | Issue | Recommendation |
|---|---|---|
| API | GET mutates state (bots/prefetch inflate count) | Split: `GET /count` reads, `POST /count` increments; update frontend `fetch` |
| Security | Lambda IAM grants unused `PutItem/DeleteItem/Scan/Query` | Scope to `GetItem`+`UpdateItem` on the table ARN — [lambda/main.tf:52](../infrastructure/modules/lambda/main.tf) |
| Security | No API throttling/WAF → unbounded DynamoDB writes | `aws_api_gateway_method_settings` throttle + usage plan |
| A11y | `--c-text-muted` ≈ 2.5:1 (light) / 4.1:1 (dark) — fails WCAG AA | Retune muted tokens to ≥4.5:1 — [styles.css:18](../frontend/styles/styles.css), [:57](../frontend/styles/styles.css) |
| CORS | Lambda hardcodes `Access-Control-Allow-Origin: *`, ignoring the `cors_origins` Terraform threads through | Drive allowed origin from an env var |

### P2 — Medium term
| Area | Issue | Recommendation |
|---|---|---|
| Observability | Lambda log group never expires; no alarms | Define `aws_cloudwatch_log_group` (retention 14–30d); Errors/Throttles/5XX alarms → SNS |
| IaC | `aws_api_gateway_deployment` lacks `triggers` → stale stage on changes | Add `triggers = { redeploy = sha1(...) }` |
| DB | No PITR / `deletion_protection` | Enable both (esp. for prod) |
| CI | No security scans | Add tfsec/checkov; promote ESLint/ruff from advisory to required (clean up `var` in `animation.js` first — violates the repo's own `no-var` rule) |
| Frontend | `showError(msg)` ignores its argument (always shows `—`); `100vh`; BEM drift (`counter__number` vs `counter-display__number--final`) | Honor message; use `100dvh`; rename class |
| UI | Base font 15px, body copy 13px | Base 16px, body ≥14px |

### P3 — Longer term
| Area | Issue | Recommendation |
|---|---|---|
| IaC | `prod` environment is an empty stub | Implement a shared root module + per‑env tfvars/backend, or remove `prod/` |
| Obs | No X‑Ray / API access logs / dashboard / SLOs | Enable X‑Ray on Lambda+API; one CloudWatch dashboard |
| Frontend | Render‑blocking Google Fonts | Self‑host or `preload`; add `defer` to scripts |
| DX | Actions pinned by tag; `package-lock.json` gitignored | Pin actions by SHA; commit the lockfile for reproducible installs |
| SEO | CloudFront 403/404 → index.html with 200 (soft‑404) | Return proper 404 for a single‑page site |

---

## Strengths (preserve)
OAC‑private S3 + AES256 · remote state with lock table · OIDC (no static keys) · semantic accessible
HTML (skip link, aria‑labels, `aria-live` counter, landmarks) · real design‑token system · dark/light
with `prefers-color-scheme` · `prefers-reduced-motion` handling · `random_string` resource suffixes ·
`PriceClass_100` cost control.

## Root‑cause theme
The repo's docs/UI advertise multi‑environment, FinOps, observability and "tfsec + flake8 in CI," while
the code had an empty `prod`, no monitoring, and no CI scans. The highest‑leverage ongoing work is
**making the repo do what it already claims** — this pass closed the most damaging gaps (correctness,
availability, security headers, real validation).
