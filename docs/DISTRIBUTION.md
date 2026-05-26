# Distribution and discoverability

How Torrin is published beyond GitHub, and how to finish search-engine setup that requires a Google account.

## GitHub Pages

- **Site:** https://dineshkn-dev.github.io/torrin/
- **Sitemap:** https://dineshkn-dev.github.io/torrin/sitemap.xml
- **IndexNow key:** https://dineshkn-dev.github.io/torrin/torrinindexnow2026.txt

On each Pages deploy, CI pings [IndexNow](https://www.indexnow.org/) (Bing, Yandex, and partners) with the site URL.

## Google Search Console (one-time, account required)

Google does not allow fully automated property verification without your login. After Pages has deployed `main`:

1. Open [Google Search Console](https://search.google.com/search-console/welcome).
2. Choose **URL prefix** and enter `https://dineshkn-dev.github.io/torrin/`.
3. Verify with **HTML file** upload:
   - Download the verification file Google provides (e.g. `google123….html`).
   - Add it under `docs/` in this repo (same folder as `index.html`).
   - Push to `main` and wait for the Pages workflow to finish.
   - Click **Verify** in Search Console.
4. Go to **Sitemaps** → submit `https://dineshkn-dev.github.io/torrin/sitemap.xml`.

Optional: request indexing for the homepage via **URL inspection** → **Request indexing**.

## Custom domain (optional)

To use a domain such as `torrin.app`:

1. Register the domain and add DNS records at your registrar:
   - `A` records for `@` → GitHub Pages IPs: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - Or `CNAME` for `www` → `dineshkn-dev.github.io`
2. Add `docs/CNAME` containing only the apex or `www` hostname (one line).
3. In the repo **Settings → Pages**, set the custom domain and enable **Enforce HTTPS**.
4. Update `docs/sitemap.xml`, `docs/index.html` canonical/OG URLs, and README links to match.

Do not commit `docs/CNAME` until you control the domain DNS.

## Package managers

| Channel | Status | Notes |
|---------|--------|--------|
| [Homebrew cask](https://github.com/Homebrew/homebrew-cask) | PR submitted from `packaging/homebrew/` | Uses GitHub release `.dmg`; update version/SHA when tagging |
| [Winget](https://github.com/microsoft/winget-pkgs) | Manifest in `packaging/winget/` | Submit after a Windows `.zip` is on [Releases](https://github.com/dineshkn-dev/torrin/releases) |
| [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted-data) | PR submitted | May require 4+ months since first release per their policy |

## Releases

Official binaries are attached to [GitHub Releases](https://github.com/dineshkn-dev/torrin/releases). If a tag has no assets, re-run the **Release** workflow on that tag (`Actions → Release → Run workflow` → choose the tag).
