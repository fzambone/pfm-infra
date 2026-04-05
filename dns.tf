# dns.tf — DNS record declarations for zambone.dev
#
# Each cloudflare_dns_record resource manages one DNS record in the zone.
# When proxied = true, Cloudflare returns its own proxy IPs instead of the
# origin — this is what enables WAF, DDoS protection, and caching.

# CNAME record: pfm-go-api.zambone.dev → pfm-go-api.fly.dev
#
# This routes API traffic through Cloudflare's proxy before it reaches
# the Fly.io origin. The "proxied = true" flag is critical — without it,
# DNS would resolve directly to Fly.io, bypassing all Cloudflare protections.
#
# TTL is set to 1 (automatic) because proxied records don't use traditional
# TTL — Cloudflare controls the cache behavior at the proxy layer.
resource "cloudflare_dns_record" "pfm_api_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "pfm-go-api"
  type    = "CNAME"
  content = var.fly_app_hostname
  proxied = true
  ttl     = 1
}
