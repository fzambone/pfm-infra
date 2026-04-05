# security.tf — Zone-level security settings for zambone.dev
#
# Each cloudflare_zone_setting resource manages one individual setting.
# These settings apply zone-wide — they affect all DNS records in the zone,
# not just pfm-go-api. That's fine because zambone.dev is dedicated to PFM.
#
# Settings that match Cloudflare's defaults are still declared explicitly
# so Terraform owns them — this prevents drift if someone changes them
# in the dashboard, because `terraform plan` would detect the difference.

# SSL/TLS mode: "strict" encrypts AND validates the full path:
#   visitor → Cloudflare (edge cert) → Fly.io (Let's Encrypt cert)
# Cloudflare verifies the origin cert is valid and matches the hostname.
# This prevents MITM attacks between Cloudflare and the origin.
#
# Upgraded from "full" to "strict" in issue #4 after confirming the
# Fly.io Let's Encrypt cert for pfm-go-api.zambone.dev is active.
resource "cloudflare_zone_setting" "ssl_mode" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "strict"
}

# Always Use HTTPS: redirects all HTTP requests to HTTPS via a 301 redirect.
# This happens at Cloudflare's edge before the request reaches the origin,
# so the origin never sees plain HTTP traffic.
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "always_use_https"
  value      = "on"
}

# Minimum TLS version: rejects connections from clients using TLS < 1.2.
# TLS 1.0 and 1.1 have known vulnerabilities (BEAST, POODLE). Modern
# browsers all support TLS 1.2+, so this only blocks very old clients
# and automated scanners — which is exactly what we want for an API.
resource "cloudflare_zone_setting" "min_tls_version" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "min_tls_version"
  value      = "1.2"
}

# Browser Integrity Check: evaluates HTTP headers for common patterns used
# by abusive bots and crawlers. When a request looks suspicious (e.g. missing
# or spoofed User-Agent), Cloudflare blocks it before it reaches the origin.
# This is a lightweight, free-tier check — different from Bot Fight Mode,
# which uses JavaScript challenges.
resource "cloudflare_zone_setting" "browser_check" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "browser_check"
  value      = "on"
}

# HSTS (HTTP Strict Transport Security): instructs browsers to always use
# HTTPS for this domain. Once a browser sees this header, it will refuse to
# connect over plain HTTP for max_age seconds — even if the user types
# http://. This prevents SSL stripping attacks.
#
# max_age = 15768000 (6 months) is the minimum recommended by Cloudflare.
# include_subdomains = true applies HSTS to all subdomains of zambone.dev.
# nosniff = true adds X-Content-Type-Options: nosniff to prevent MIME sniffing.
resource "cloudflare_zone_setting" "security_header" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "security_header"
  value = {
    strict_transport_security = {
      enabled            = true
      max_age            = 15768000
      include_subdomains = true
      preload            = false
      nosniff            = true
    }
  }
}
