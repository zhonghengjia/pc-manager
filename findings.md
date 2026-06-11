# 研究发现与发现记录

> 更新: 2026-06-11

## 系统诊断发现

### Windows Update
- **根因**：UpdateOrchestrator.mof 被 SysCleanPro 物理删除
- **连锁影响**：USO服务无法创建定时任务 → WU完全瘫痪
- **修复路径**：DISM /RestoreHealth 需要WU下载 → 鸡生蛋问题 → 只能就地升级

### 360安全卫士
- ZhuDongFangYu.sys 内核驱动锁定360进程
- taskkill /F + 管理员权限 均无法终止
- 压制Windows Defender，注册4个AV产品冲突
- 文件关联劫持能力已被清除（注册表锁定）

### 未知进程调查
- `tray` (PID 22748, 75连接) → 确认为 **爱数AnyShare同步盘** (G盘服务)
- 路径：`C:\Program Files (x86)\AISHU\SyncDisk\tray.exe`
- 结论：安全，必须保留

### 磁盘
- Disk0: SSD 1863GB (健康)
- Disk1: SSD 477GB (健康)
- G盘为爱数AnyShare网络共享盘

### 进程优化效果
- 优化前: 462个进程
- 优化后: 431个进程（↓31个）

## 已知工具冲突
| 清理工具 | 风险 | 状态 |
|----------|------|------|
| SysCleanPro | 删除系统文件(WU组件) | 已禁用 |
| 360深度清理 | 可能误删系统组件 | 保留但监控 |
| 迅雷下载 | Chrome扩展劫持 | 已拆除 |
| 搜狗快图 | 文件关联劫持 | 已封锁 |
