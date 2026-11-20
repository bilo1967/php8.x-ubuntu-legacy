# PHP 8.4 packages for Ubuntu 20.04 (Focal)

Unofficial PHP 8.4 Debian packages for **Ubuntu 20.04 LTS (Focal), amd64**, built using the PHP packaging published by [Ondřej Surý](https://packages.sury.org/php/) and adapted to run on Focal.

This repository is a fork of [Niek/php7](https://github.com/Niek/php7), whose GitHub Actions / Docker build approach was used as the starting point. Thanks to both projects and their maintainers.

> **Unofficial, experimental build.** Not affiliated with or supported by Ondřej Surý, Ubuntu, or PHP. Ubuntu 20.04 is outside standard support. Building a newer PHP does **not** update or secure the underlying operating system or its libraries. Prefer a supported Ubuntu release for production systems.

See also the [main branch](https://github.com/bilo1967/php8.x-ubuntu-legacy/tree/main) for PHP 8.3.x.

## Build status and scope

- PHP: **8.4.28**, packaged as `.deb` files for **Ubuntu 20.04 amd64**.
- PECL extensions: APCu **5.1.28**, igbinary **3.2.16**, msgpack **3.0.0**, Redis **6.3.0**, Imagick **3.8.1**, memcached **3.4.0**, MongoDB **2.5.5**. IMAP **1.0.3** and Pspell **1.0.1** are also packaged separately for PHP 8.4.
- The normal Debian/Sury package names and layouts are preserved where possible: `php8.4-cli`, `php8.4-fpm`, `php8.4-common`, `php8.4-mysql`, etc.
- Paths include `/usr/bin/php8.4`, `/usr/sbin/php-fpm8.4`, `/etc/php/8.4/`, and `/usr/lib/php/20240924/`.
- PHP-FPM and PECL packages were installed and exercised on two existing Ubuntu 20.04 servers: one running Nextcloud, the other Moodle 5. These are **limited real-world checks**, not an automated test suite or a guarantee for other deployments.
- Only **Ubuntu 20.04 / amd64** is currently targeted. The original fork's other Ubuntu and Debian targets are not supported here.

## Repository files

| File | Purpose |
| --- | --- |
| `.github/workflows/build.yml` | Manually build PHP Debian packages inside an Ubuntu 20.04 container. |
| `build.sh` | PHP source extraction, Debian packaging and package build. |
| `sources.sha256` | Explains the generated source manifest; the exact `.dsc` is selected in `build.yml`. |
| `.github/workflows/build-pecl.yml` | Manually build the nine PECL extensions using packages from a previous PHP workflow run. |
| `build-pecl.sh` | Fetch and adapt PECL Debian packaging and compile extension packages. |

## Build PHP packages

1. Open **Actions → Build PHP 8.4 Legacy → Run workflow**.
2. Download the `php8.4-ubuntu20.04-amd64` artifact after the build finishes.
3. Save the resulting `.deb` files and `SHA256SUMS` in durable storage: GitHub Actions artifacts expire. Check the retention period in the workflow.

The build uses the Sury PHP 8.4 upstream source and Debian packaging selected by `SOURCE_DSC` in `.github/workflows/build.yml`, building against Ubuntu 20.04 system libraries. A local `+legacy…ubuntu20.04` suffix distinguishes these packages from upstream distribution packages.

## Build PECL packages

1. Complete a PHP build first; note its **GitHub Actions run ID**.
2. Open **Actions → Build PHP 8.4 PECL (Ubuntu 20.04) → Run workflow** and supply that PHP build run ID.
3. Download the `php8.4-pecl-ubuntu20.04-amd64` artifact.
4. Retain the PHP and PECL artifacts together, including checksum files.

The PECL build uses the newly built `php8.4-dev` package, targets PHP 8.4 only, and builds igbinary/msgpack before Redis and memcached. Redis is configured with both igbinary and msgpack serializer support. These extensions are packaged as Debian `.deb` files, not copied manually into the PHP extension directory.

**PECL compatibility:** the existing [PHP 8.4 PECL release](https://github.com/bilo1967/php8.x-ubuntu-legacy/releases/tag/v8.4.27-pecl-focal.1) remains usable with PHP 8.4.28. Rebuild only when updating extensions or changing PHP API/ABI or build configuration. PHP 8.4 uses API `20240924`; PHP 8.3 and 8.4 extension binaries are not interchangeable. The PECL workflow accepts patch versions within this series and checks the PHP API before compiling.

**Source integrity:** core builds pin the `.dsc` filename, check source sizes and SHA-256 values from that descriptor, recheck the generated manifest inside Docker, and preserve it as `source-files.sha256`. The `.dsc` hash is recorded at download time; it is not an independently pinned checksum or an explicit trusted-key signature check. PECL source discovery selects the available Sury Ubuntu 22.04 descriptor and checks its listed sizes and hashes, so extension source versions are not yet reproducibly pinned.

## Security update: 8.4.28

PHP 8.4.28 is an upstream security release dated 19 November 2026. These packages rebuild the Sury source package for Focal; the security fixes come from that PHP/Sury source, rather than separately maintained local backports.

References: [PHP release announcement](https://www.php.net/releases/8_4_28.php) and [official changelog](https://www.php.net/ChangeLog-8.php#8.4.28).

| Component | Fixed CVE / upstream advisory |
| --- | --- |
| CGI | [CVE-2026-129538](https://github.com/php/php-src/security/advisories/GHSA-5j3f-64r7-f564) |
| Date | [CVE-2026-129496](https://github.com/php/php-src/security/advisories/GHSA-gr4f-wgx5-jpfv) |
| DOM | [CVE-2026-129501](https://github.com/php/php-src/security/advisories/GHSA-x8r7-mg3g-74hg) |
| FPM | [CVE-2026-129289](https://github.com/php/php-src/security/advisories/GHSA-qc49-hpvq-g2w6) |
| FPM | [CVE-2026-129292](https://github.com/php/php-src/security/advisories/GHSA-3mg3-cr28-46gc) |
| FPM | [CVE-2026-129291](https://github.com/php/php-src/security/advisories/GHSA-jm4m-qfqx-967m) |
| Phar | [CVE-2026-128090](https://github.com/php/php-src/security/advisories/GHSA-68fq-fh7h-f8gr) |
| Session | [CVE-2026-126714](https://github.com/php/php-src/security/advisories/GHSA-fm2m-fjf5-v3cp) |
| Session | [CVE-2026-115560](https://github.com/php/php-src/security/advisories/GHSA-658j-r8rw-q6mx) |
| Session | [CVE-2026-129481](https://github.com/php/php-src/security/advisories/GHSA-g3vh-838c-65v7) |
| SOAP | [CVE-2026-15353](https://github.com/php/php-src/security/advisories/GHSA-q23r-hr55-xmpg) |
| SOAP | [CVE-2026-129506](https://github.com/php/php-src/security/advisories/GHSA-4646-p932-gw34) |
| Standard | [CVE-2026-128064](https://github.com/php/php-src/security/advisories/GHSA-f6gg-rchx-xw8j) |
| Standard | [CVE-2026-127960](https://github.com/php/php-src/security/advisories/GHSA-mmf9-xm3v-hg2x) |


## Installing packages

**Back up existing PHP configurations and record installed packages before upgrading.** The packages are intended to follow Sury's normal file layout, but installation behavior depends on the existing dpkg state and configuration.

Download the two artifact archives, extract them into separate folders, and install **only the packages actually required**. For an Apache + PHP-FPM deployment, a typical selection includes:

```text
php8.4-common php8.4-cli php8.4-fpm php8.4-opcache
php8.4-mysql php8.4-mbstring php8.4-xml php8.4-curl
php8.4-zip php8.4-gd php8.4-intl php8.4-ldap
php8.4-bcmath php8.4-soap php8.4-sqlite3
php8.4-apcu php8.4-redis php8.4-igbinary php8.4-msgpack
php8.4-imagick
```

Other modules (e.g. `php8.4-imap`, `php8.4-bz2`, `php8.4-gmp`, `php8.4-pspell`, `php8.4-memcached`) may be required by specific applications. Inspect local dependencies before installation.

**Do not install every `.deb` indiscriminately.** `libapache2-mod-php8.4`, `php8.4-cgi`, `php8.4-litespeed`, `php8.4-phpdbg`, `libphp8.4-embed`, and `php8.4-dev` serve different use cases and are not required for a normal Apache + PHP-FPM runtime. In particular, `php8.4-litespeed` caused service-management/removal problems during an initial test and is not recommended unless specifically needed and tested.

For locally extracted packages, first simulate the selected transaction (`apt-get -s install ./path/to/package.deb ...`), verify **removals and new dependencies**, then run the same command without `-s`. Avoid `--only-upgrade` if some selected modules are not installed yet. Do not run `apt autoremove` blindly on production systems.

For upgrades, dpkg ordinarily preserves locally modified conffiles. Nevertheless, inspect `/etc/php/8.4` and the generated `conf.d` symlinks: historical installations may have missing or disabled modules.

## PHP-FPM and module checks

```bash
php8.4 -v
php8.4 --ini
php8.4 -m
php-fpm8.4 -t
systemctl status php8.4-fpm
```

If `mysqli` or `pdo_mysql` reports missing `mysqlnd_*` symbols, check that `mysqlnd.so` is enabled **before** those extensions. With the Sury-style MySQL package, the template is in:

```text
/usr/share/php8.4-mysql/mysql/mysqlnd.ini
```

The expected installed configuration is `/etc/php/8.4/mods-available/mysqlnd.ini`, with links such as `10-mysqlnd.ini` for CLI and FPM. Confirm the `.so` exists in `/usr/lib/php/20240924/`, inspect module priorities, then use `phpenmod -v 8.4 -s cli mysqlnd` and the equivalent command for `fpm` as appropriate. One upgrade retained an incomplete older configuration; this was a host configuration issue, not evidence that a clean install necessarily behaves the same way.

When replacing a manually installed PHP-FPM in `/opt`, preserve its configuration and systemd unit for rollback, and ensure that the old and new FPM services do **not** bind the same socket simultaneously. Check application-specific pool, cron, OPcache and `php.ini` settings before switching traffic.

## Creating a release

Core and PECL have independent releases. A core security update reuses the compatible PECL release; it does not rebuild or republish extensions.

1. Select a successful **Build PHP 8.4 Legacy** run on `php84`. The current run is [44752301566](https://github.com/bilo1967/php8.x-ubuntu-legacy/actions/runs/44752301566). Core artifacts expire after seven days.
2. Ensure `releases/v8.4.28-focal.1.md` contains the intended release notes.
3. Run **Prepare PHP core release files** on `php84` with that run ID and tag `v8.4.28-focal.1`. It verifies the run, package metadata, exact patch version and original checksums, stages a downloadable artifact containing the release files and `RELEASE-NOTES.md` for 30 days. It does not create or publish a release.
4. Create an empty draft release in the GitHub UI with the intended tag and target commit; use `RELEASE-NOTES.md` for the description. Run **Attach PHP core packages to draft release** with the original core build run ID to populate it. Review the draft, then publish it. Uploads never overwrite assets. Creating the draft through the UI avoids the Actions token restriction when target workflows differ from the default branch ([GitHub documentation](https://docs.github.com/en/rest/releases/releases#create-a-release)).

The release files include `.deb` packages, `SHA256SUMS`, `source-files.sha256` `BUILD-ORIGIN.txt` and `RELEASE-NOTES.md`. GitHub strips `~` from asset filenames, so the workflow normalizes filenames before generating release checksums; package contents are unchanged.

Older core releases may be removed after the replacement assets are verified. Keep the linked PECL release while reusing its packages. The shared `php-common` dependency is retained under `vendor/php-common/` with a fixed checksum, so builds do not depend on an older core release. GitHub releases are not an APT repository.

## Acknowledgements and licensing

- [Niek/php7](https://github.com/Niek/php7): original workflow/build approach.
- [Ondřej Surý's PHP packages](https://packages.sury.org/php/): upstream PHP/extension Debian packaging.
- [PHP](https://www.php.net/): PHP upstream sources.

The original source code and packaging retain their respective licenses and copyright notices. This repository makes no claim of upstream endorsement.
