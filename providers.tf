# providers.tf — Provider configuration
#
# Notice there are NO credentials here. The Cloudflare provider automatically
# reads CLOUDFLARE_API_TOKEN from the environment. In our setup, that env var
# is set as a sensitive variable in Terraform Cloud — so the token never
# appears in code, logs, or plan output.

provider "cloudflare" {
  # Authentication is handled via the CLOUDFLARE_API_TOKEN environment variable
  # configured in Terraform Cloud. No explicit token argument needed.
}
