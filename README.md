# TrendAI Vision One — Code Security Showcase

> A hands-on, didactic demonstration of every scanning capability in
> [Trend Vision One Artifact Scanner (TMAS)](https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-integrating-tmas-ci-cd-pipeline)
> — from finding CVEs in your dependencies to catching malware inside container images.

---

## What You'll See

This repository contains an **intentionally vulnerable** application and container image.
When the GitHub Actions workflow runs, it produces **5 independent scan jobs**, each
demonstrating a different TMAS capability:

| # | Job | What It Finds | Scan Type |
|---|-----|--------------|-----------|
| 1 | **Vulnerability Scan — Source Code** | CVEs in npm, pip, and Go dependencies | `tmas scan -V dir:.` |
| 2 | **Secrets Detection — Source Code** | Hardcoded API keys, passwords, private keys | `tmas scan -S dir:.` |
| 3 | **Vulnerability Scan — Container Image** | OS package CVEs + app dependency CVEs in built image | `tmas scan -V -S docker:image` |
| 4 | **Malware Detection — Container Image** | EICAR test malware embedded in image layers | `tmas scan -M docker:image` |
| 5 | **Policy Evaluation — Security Gate** | Evaluates all findings against your Vision One policy | `tmas scan -V -S --evaluatePolicy dir:.` |

Each job writes a detailed **summary card** to the GitHub Actions UI explaining what it
does, why it matters, and how to interpret the results.

---

## Quick Start (5 minutes)

### Prerequisites

- A [Trend Vision One](https://www.trendmicro.com/en_us/business/products/one-platform.html) account (free trial available)
- A Vision One API key with **Artifact Scanner** permissions

### Step 1 — Fork or clone this repo

```bash
gh repo fork andresark/trendai-vision-one-code-security-showcase --clone
```

### Step 2 — Add your API key

Go to your fork's **Settings > Secrets and variables > Actions** and create a
repository secret:

| Name | Value |
|------|-------|
| `TMAS_API_KEY` | Your Vision One API key |

### Step 3 — Run the workflow

Go to **Actions > TMAS Security Scan Showcase > Run workflow** and click
**Run workflow**. You can also select your Vision One region from the dropdown.

### Step 4 — Explore the results

Once the workflow completes, you'll see 5 jobs in the sidebar. Click each one to see:
- **Step logs** — Full JSON scan reports with every finding
- **Job summaries** — Rich formatted cards explaining what was scanned and why
- **Artifacts** — Downloadable SBOMs in CycloneDX format

---

## What's Inside

```
.
├── .github/workflows/
│   └── tmas-showcase.yml        # The showcase workflow (5 scan jobs)
├── app/
│   ├── package.json             # Node.js deps with known CVEs
│   ├── requirements.txt         # Python deps with known CVEs
│   ├── go.mod                   # Go deps with known CVEs
│   └── server.js                # App with planted secrets
├── overrides/
│   └── tmas_overrides.yml       # Example: suppress specific findings
├── Dockerfile                   # Vulnerable base + EICAR malware
└── README.md                    # You are here
```

### Intentionally Vulnerable Dependencies

| Ecosystem | Package | Version | Known CVEs |
|-----------|---------|---------|------------|
| npm | `lodash` | 4.17.20 | Prototype pollution |
| npm | `axios` | 0.21.1 | SSRF via redirect |
| npm | `jsonwebtoken` | 8.5.1 | Algorithm confusion |
| npm | `node-forge` | 0.10.0 | Signature verification bypass |
| npm | `tar` | 4.4.13 | Arbitrary file overwrite |
| pip | `cryptography` | 3.3.2 | Multiple OpenSSL CVEs |
| pip | `urllib3` | 1.26.4 | CRLF injection |
| pip | `Pillow` | 8.2.0 | Buffer overflow |
| pip | `PyYAML` | 5.4 | Arbitrary code execution |
| Go | `golang.org/x/net` | 0.0.0-2022... | HTTP/2 rapid reset |
| Go | `golang.org/x/crypto` | 0.0.0-2022... | Multiple CVEs |

### Planted Secrets

| Type | Pattern | File |
|------|---------|------|
| GitHub Personal Access Token | `ghp_...` | `app/server.js` |
| AWS Access Key ID | `AKIA...` | `app/server.js` |
| AWS Secret Access Key | `wJalrX...` | `app/server.js` |
| RSA Private Key | `-----BEGIN RSA PRIVATE KEY-----` | `app/server.js` |
| Slack Webhook URL | `https://hooks.slack.com/...` | `app/server.js` |
| Database Password | `SuperSecret123!` | `app/server.js` |

### Container Image

| Layer | What | Finding Type |
|-------|------|-------------|
| Base: `alpine:3.16` | EOL Alpine with unpatched OpenSSL, busybox, zlib | Vulnerabilities |
| `RUN echo ... > /tmp/.env` | Stripe key, SendGrid key, database URL baked into layer | Secrets |
| `RUN wget ... eicar.com` | EICAR antimalware test file | Malware |

---

## TMAS Capabilities Reference

### Scan Types

| Flag | Scanner | Works With |
|------|---------|-----------|
| `-V` / `--vulnerabilities` | CVE / open-source vulnerability detection | All artifact types |
| `-M` / `--malware` | Malware detection (Trend Micro engine) | Container images only |
| `-S` / `--secrets` | Credential / secret leak detection | All artifact types |

### Supported Artifact Types

| Prefix | Description | `-V` | `-M` | `-S` |
|--------|-------------|:----:|:----:|:----:|
| `dir:` | Directory on disk | :white_check_mark: | :x: | :white_check_mark: |
| `file:` | Single file on disk | :white_check_mark: | :x: | :white_check_mark: |
| `docker:` | Image in local Docker daemon | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `registry:` | Image in a remote registry | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `docker-archive:` | Tarball from `docker save` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `oci-archive:` | OCI archive tarball | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `oci-dir:` | OCI layout directory | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `podman:` | Image in local Podman daemon | :white_check_mark: | :x: | :white_check_mark: |
| `singularity:` | Singularity `.sif` container | :white_check_mark: | :x: | :white_check_mark: |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Scan completed — no policy violations |
| `1` | Scan error |
| `2` | Scan completed — **policy violated** |

### Key Flags

| Flag | What It Does |
|------|-------------|
| `--evaluatePolicy` | Check findings against your Vision One security policy |
| `--saveSBOM` | Save the Software Bill of Materials (CycloneDX) |
| `--redacted` | Mask secret values in CLI output |
| `--override <file>` | Suppress specific findings (see `overrides/tmas_overrides.yml`) |
| `--platform <os/arch>` | Target platform for multi-arch images |
| `--region <region>` | Vision One region (default: `us-east-1`) |

---

## Suppressing Findings

Not every finding is actionable. Use an override file to document accepted risks:

```yaml
# overrides/tmas_overrides.yml
vulnerabilities:
  exceptions:
    - id: CVE-2022-37434
      reason: "Accepted risk — not exploitable in our context"

secrets:
  exceptions:
    - id: "generic-api-key"
      path: "app/server.js"
      reason: "Intentional demo credential"
```

Pass it to the scan:
```bash
tmas scan -V -S --override overrides/tmas_overrides.yml dir:.
```

---

## Blocking PRs with Policy Evaluation

Combine `--evaluatePolicy` with GitHub's branch protection rules to create a security
gate that blocks insecure code from merging:

1. **Configure a policy** in [Vision One Console](https://portal.xdr.trendmicro.com/)
   under **Code Security > Policies**
2. **Add `--evaluatePolicy`** to your TMAS scan (already done in Job 5)
3. **Require the status check** in GitHub: **Settings > Branches > Branch protection >
   Require status checks** — add the policy evaluation job

When TMAS finds violations, the job exits with code `2`, the check turns red, and the
merge button is disabled.

---

## Running Locally (CLI)

```bash
# Install TMAS
curl -sL "https://ast-cli.xdr.trendmicro.com/tmas-cli/latest/tmas-cli_$(uname -s)_$(uname -m | sed 's/x86_64/x86_64/;s/aarch64/arm64/').tar.gz" \
  | tar xz -C /usr/local/bin tmas

# Set your API key
export TMAS_API_KEY="your-vision-one-api-key"

# Scan source code
tmas scan -V -S --region us-east-1 dir:.

# Build and scan container image
docker build -t tmas-showcase:scan .
tmas scan -V -M -S --region us-east-1 docker:tmas-showcase:scan

# Generate SBOM
tmas scan -V --saveSBOM --region us-east-1 dir:.
```

---

## Resources

- [TMAS Documentation](https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-integrating-tmas-ci-cd-pipeline)
- [TMAS CLI Reference](https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-artifactscannerclire)
- [GitHub Action — `trendmicro/tmas-scan-action`](https://github.com/trendmicro/tmas-scan-action)
- [Trend Vision One — Free Trial](https://www.trendmicro.com/en_us/business/products/one-platform.html)
- [EICAR Test File](https://www.eicar.org/download-anti-malware-testfile/)

---

## License

This repository is provided as-is for educational and demonstration purposes.
The intentionally vulnerable code and container image should **never** be deployed to production.
