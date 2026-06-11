# 电脑系统持续优化 — 任务计划

> 创建: 2026-06-11 | 最后更新: 2026-06-11
> 设备: Lenovo 82RF | i7-12700H | 40GB | Win11 22000

## 阶段总览

| 阶段 | 状态 | 内容 |
|------|------|------|
| 1 | ✅ 完成 | 文件关联防护（搜狗/360/XIUXIU） |
| 2 | ✅ 完成 | 开机自启清理 |
| 3 | ✅ 完成 | 垃圾定时任务清理 |
| 4 | ✅ 完成 | 多余服务禁用 |
| 5 | ✅ 完成 | 系统设置优化（电源/遥测） |
| 6 | ✅ 完成 | 临时文件清理 |
| 7 | ✅ 完成 | 安全诊断（磁盘/网络/驱动） |
| 8 | ✅ 完成 | PC管家Skill构建与发布 |
| 9 | 🟡 待处理 | Windows Update修复 |
| 10 | 🟡 待处理 | SMB端口139/445关闭 |
| 11 | 🟡 待处理 | F/G盘空间清理 |

---

## 阶段1-8：已完成

### 文件关联
- sgaipic.exe → .BLOCKED，目录锁定
- 360AlbumViewer/XIUXIU 图片劫持清除
- 360seURL .html/.htm 清除
- 迅雷Chrome扩展强制移除
- 注册表HKCR锁定防恢复

### 启动项
已移除：BaiduYunDetect、Kimi、EdgeAutoLaunch、360Safetray
保留：SecurityHealth、RtkAudUService、kwallpaper

### 定时任务（16项已删）
喜马拉雅x2、有道词典x2、夸克更新、360Zip更新x2、OneDrivex2、HP打印x2、NVIDIA CrashReportx4、Readertray、UpdateSkillIndex

### 服务（6项已禁）
SysCleanProService、LDPlayerSvr、HPPrintScanDoctorService、XTU3SERVICE、GAService、LZService

### 设置优化
- 合盖不睡眠(AC)、息屏永不(AC)、休眠永不(AC)
- 遥测 Full→Basic、DiagTrack已禁用
- 临时文件清理350MB

### Skill发布
- GitHub: https://github.com/zhonghengjia/pc-manager
- 10项能力，8个脚本，MIT开源
- SSH推送已配

---

## 阶段9：Windows Update修复 🟡
**问题**：UpdateOrchestrator.mof 被SysCleanPro删除，定时任务0个
**修复**：需Win11 22000就地升级（保留文件和应用）
**难度**：需下载ISO（4-5GB），1-2小时执行

## 阶段10：SMB端口关闭 🟡
**问题**：Port 139/445 开放，勒索病毒入口
**操作**：关闭SMBv1，禁用Server服务或防火墙规则

## 阶段11：空间清理 🟡
**F盘**：88%（59GB空闲）| **G盘**：90%（86GB空闲）
**操作**：large-files.ps1 扫描大文件

---

## 保留清单（不可触碰）
- 元纸壁纸(kwallpaper) — 用户喜欢
- AnyShare(G盘同步) — 医院共享数据
- 360安全卫士 — 内核保护保留
- 深信服VDI — 医院远程桌面
