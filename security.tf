# security.tf — Zone-level security settings for zambone.dev
#
# Each cloudflare_zone_setting resource manages one individual setting.
# These settings apply zone-wide — they affect all DNS records in the zone,
# not just pfm-go-api. That's fine because zambone.dev is dedicated to PFM.
#
# Settings that match Cloudflare's defaults are still declared explicitly
# so Terraform owns them — this prevents drift if someone changes them
# in the dashboard, because `terraform plan` would detect the difference.

# SSL/TLS mode: "full" encrypts traffic between the visitor and Cloudflare AND
# between Cloudflare and the origin (Fly.io). "full" does NOT validate the
# origin cert — that's "strict", which requires a valid cert on Fly.io.
# We start with "full" and upgrade to "strict" in issue #4 after the Fly.io
# cert is provisioned.
resource "cloudflare_zone_setting" "ssl_mode" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "full"
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
