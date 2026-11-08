# Reachline

macOS menu bar app that monitors ICMP, DNS, and HTTPS probe latency to a set of targets.

- Menu bar icon: green when all probes pass, orange when some fail, red when all fail.
- Popover with per-target latency and sparklines; dashboard window with a live latency graph.
- Each target probes on its own interval, so a slow one never delays the others.
- Editable target list, opens at login (asked once), updates itself from GitHub releases.

## Install

Download `Reachline.zip` from the [latest release](https://github.com/aca2328/Reachline/releases/latest), unzip, and move `Reachline.app` to Applications. Requires macOS 13+ (Apple silicon or Intel).

The app is ad-hoc signed, not notarized. On first launch choose **Open Anyway** in System Settings › Privacy & Security, or run:

```sh
xattr -dr com.apple.quarantine /Applications/Reachline.app
```

## Build

```sh
swift run Reachline        # run from source
./bundle.sh                # universal .app in .build/Reachline.app
swift test                 # needs full Xcode
./dashboard.sh             # legacy terminal version
```

## Targets

Edit them from **Targets…** in the popover. **Test** runs one probe without saving. The list lives in `~/Library/Application Support/Reachline/targets.json`; delete it to restore the defaults.

| Type | Measures |
| --- | --- |
| `ICMP_ECHO` | ping round-trip time |
| `DNS_RECURSOR` | recursive DNS query time (IPv4 host) |
| `DNS_AUTH` | authoritative DNS query time (IPv4 host) |
| `HTTPS_CONNECT` | TCP + TLS setup time |
| `HTTPS_GET` | full request time and HTTP status |

Probes use `/sbin/ping`, `/usr/bin/dig`, and `/usr/bin/curl`.

## License

MIT, see [LICENSE](LICENSE).
