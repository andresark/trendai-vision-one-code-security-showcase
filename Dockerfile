# ──────────────────────────────────────────────────────────────────────────────
# Intentionally Vulnerable Container Image
# Demonstrates: CVE detection, malware detection, and secrets-in-layers
#
# BASE IMAGE: Alpine 3.16 (EOL, contains known CVEs in OpenSSL, busybox, zlib)
# MALWARE:    Downloads the EICAR test file (industry-standard AV test string)
# SECRETS:    Bakes credentials into image layers
# ──────────────────────────────────────────────────────────────────────────────

FROM alpine:3.16 AS base

# ── Vulnerable system packages ───────────────────────────────────────────────
# Alpine 3.16 ships with outdated openssl, busybox, zlib — all with known CVEs
RUN apk update && apk add --no-cache \
    curl \
    wget \
    openssl \
    && rm -rf /var/cache/apk/*

# ── Plant secrets into the image layer ───────────────────────────────────────
# These will be caught by the secrets scanner even though we "delete" them later
RUN echo "DATABASE_URL=postgres://admin:P@ssw0rd123@db.prod.internal:5432/myapp" > /tmp/.env \
    && echo "STRIPE_SECRET_KEY=sk_live_4eC39HqLyjWDarjtT1zdp7dc" >> /tmp/.env \
    && echo "SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxx.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy" >> /tmp/.env \
    && rm /tmp/.env

# ── Download EICAR malware test file ─────────────────────────────────────────
# EICAR is a harmless test string recognized by all antivirus/antimalware engines
# See: https://www.eicar.org/download-anti-malware-testfile/
RUN wget --no-check-certificate -q -O /eicar.com https://secure.eicar.org/eicar.com.txt || \
    echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /eicar.com

# ── Copy vulnerable application code ────────────────────────────────────────
WORKDIR /app
COPY app/ .

EXPOSE 3000
CMD ["echo", "This is an intentionally vulnerable demo image — do not run in production"]
