# PC Manager — Claude Code Windows System Administration Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Claude Code skill that transforms your AI assistant into a Windows PC butler.  
No more bloated optimization tools — just clean, auditable PowerShell scripts.

## Capabilities

| # | Capability | Trigger | What it does |
|---|-----------|---------|---------------|
| 1 | System Health Check | "scan my PC" / "system health" | 7-dimension scan: integrity, security, disks, network, privacy, performance, updates |
| 2 | Safe Cleanup | "clean my PC" / "clean temp" | Cleans Windows Temp, User Temp, Recycle Bin (excludes Claude's own temp dir) |
| 3 | Startup Optimizer | "optimize system" / "startup audit" | Audits registry Run keys, scheduled tasks, and 3rd-party services |
| 4 | Windows Update Repair | "fix updates" / "wu repair" | Diagnoses UpdateOrchestrator, resets SoftwareDistribution, re-registers WU DLLs |
| 5 | Battery & Power | "battery health" / "power usage" | Generates battery-report.html, calculates health %, estimates power draw |
| 6 | File Association Protection | "file hijack" / "default apps" | Scans for known hijackers (Sogou/360/Xiuxiu), clears + locks registry |
| 7 | Large File Finder | "where's my space" / "large files" | Recursively scans drives, lists top 30 files by size |
| 8 | Defender Quick Scan | "virus scan" | Triggers Windows Defender quick scan, shows threat history |
| 9 | Driver Health Check | "driver check" | Scans all devices for error codes, translates 50+ codes to plain English |
| 10 | Network Diagnostic | "network check" / "wifi status" | WiFi signal, DNS latency, open ports, internet connectivity |

## Installation

```bash
# Clone into your Claude Code skills directory
git clone https://github.com/YOUR_USERNAME/pc-manager.git ~/.claude/skills/pc-manager

# Or copy manually
cp -r pc-manager ~/.claude/skills/
```

## Usage

Just talk to Claude Code naturally:

```
> scan my PC
> clean temp files
> who changed my default apps
> battery health
> are my drivers ok
```

## State Persistence

The skill reads `state.json` on activation to remember:
- System profile (device, OS, specs)
- Completed optimizations (won't repeat)
- User-preserved items (won't touch)
- Pending tasks

New conversations pick up where the last one left off.

## Structure

```
pc-manager/
├── SKILL.md              # Skill definition + instructions
├── README.md             # This file
├── state.json            # System state index (machine-readable)
├── LICENSE               # MIT
└── scripts/
    ├── health-check.ps1  # 7-dimension system scan
    ├── cleanup.ps1       # Safe temp file cleaning
    ├── optimize.ps1      # Startup/service/task optimizer
    ├── repair-wu.ps1     # Windows Update component repair
    ├── large-files.ps1   # Disk space analysis
    ├── defender-scan.ps1 # Windows Defender integration
    ├── driver-check.ps1  # Device driver diagnostics
    └── network-diag.ps1  # Network & WiFi diagnostic
```

## Requirements

- Windows 10/11
- PowerShell 5.1+
- Claude Code (or any AI agent with tool execution)

## Security

All scripts are plain PowerShell — no compiled binaries, no obfuscation.  
You can (and should) read every script before running.

## Why Not {360, SysCleanPro, DriverGenius, ...}?

| Traditional Tool | Problem | This Skill |
|-----------------|---------|-------------|
| 360 Safe Guard | Kernel hooks, hijacks file associations | No kernel access, transparent |
| SysClean Pro | Deletes system files (like UpdateOrchestrator.mof) | Only cleans safe temp locations |
| Driver Genius | Bloatware, adware installs | Uses built-in WMI, no install |

## License

MIT — use it, fork it, ship it.

## Inspired By

- [XDA: Claude Code replaced my bloated PC optimization tools](https://www.xda-developers.com/claude-code-replaced-bloated-pc-optimization-tools-with-custom-scripts-pc-happier/)
- Claude Code community at [awesome-claude-code](https://github.com/onmyway133/awesome-claude-code)
