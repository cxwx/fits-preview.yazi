# FITS File Preview Plugin for Yazi

这是一个用于 Yazi 文件管理器的 FITS 文件预览插件，使用 `fitsheader` 命令来预览 Flexible Image Transport System (FITS) 天文数据文件。

## 功能特性

- 🔍 __预览 FITS 文件__ - 自动显示 FITS 文件的 header 信息
- 📜 __优化滚动__ - 智能缓存和分页，提供流畅的大文件滚动体验
- 🚀 __快速打开__ - 直接在 FITS 查看器（ds9 等）中打开文件
- 💾 __智能缓存__ - 自动缓存文件内容，避免重复执行命令
- 🎨 __自动清理__ - 自动清理 ANSI 颜色代码，确保预览清晰可读

## 安装

### 方法 1: 使用 Yazi 包管理器（推荐）

```
# 从 git 仓库安装
ya pkg add cxwx/fits-preview
```

### 方法 2: 手动安装

```
# 将插件复制到你的 yazi 配置目录
cp -r fits-preview.yazi ~/.config/yazi/plugins/fits-preview.yazi
```

## 配置

在你的 `~/.config/yazi/yazi.toml` 文件中添加以下配置：

```toml
[[plugin.prepend_previewers]]
url = "*.fits"
run = "fits-preview"

[[plugin.prepend_previewers]]
url = "*.fit"
run = "fits-preview"
```

## 依赖

本插件需要以下工具：

- CFITSIO - FITS 文件操作库
- `fitsheader` - 用于显示 FITS header 信息（预览功能）
- FITS 查看器（可选，用于 entry 功能）：
  - `ds9` - SAOImage DS9 天文图像查看器（推荐）
  - `fv` - FITS 文件查看器
  - `saotng` - SAOImage TG查看器

### 安装依赖

__macOS (使用 Homebrew):__

```bash
# 安装 CFITSIO（包含 fitsheader）
brew install cfitsio

# 安装 DS9 查看器（可选）
brew install --cask saods9
```

__Linux:__

```bash
# Ubuntu/Debian
sudo apt-get install cfitsio-bin saods9

# Fedora/RHEL
sudo dnf install cfitsio ds9

# Arch Linux
sudo pacman -S cfitsio saods9
```

__验证安装:__

```bash
# 检查 fitsheader
which fitsheader
fitsheader --version

# 检查 ds9
which ds9
ds9 -version
```

## 使用方法

### 1. 预览 FITS 文件 (Peek)

在 Yazi 中浏览到 `.fits` 文件时，右侧预览面板会自动显示 FITS 文件的 header 信息。

插件会调用 `fitsheader` 命令显示：
- SIMPLE 格式标志
- BITPIX 像素位数
- NAXIS 维度信息
- 观测时间、望远镜、仪器等元数据
- 其他 FITS 关键字

示例输出：

```
SIMPLE  =                    T / file does conform to FITS standard
BITPIX  =                   16 / number of bits per data pixel
NAXIS   =                    2 / number of data axes
NAXIS1  =                 1024 / length of data axis 1
NAXIS2  =                 1024 / length of data axis 2
DATE    = '2024-02-15'         / creation date
TELESCOP= 'My Telescope'       / telescope name
INSTRUME= 'My Camera'          / instrument name
EXPTIME =                 120.0 / exposure time [s]
FILTER  = 'R'                  / filter name
OBJNAME = 'M31'                / object name
```

### 2. 滚动浏览 (Seek)

对于大型 FITS header，可以使用 Yazi 的标准滚动键浏览预览内容：

- `Ctrl+j` / `Ctrl+k`: 上下滚动
- `Ctrl+u` / `Ctrl+d`: 页面滚动
- 鼠标滚轮: 滚动浏览

### 3. 在 FITS 查看器中打开 (Entry)

按 `Enter` 键直接在 FITS 查看器中打开文件，进行交互式查看和分析。

插件会自动检测以下查看器（按优先级）：
1. `ds9` - SAOImage DS9（最推荐）
2. `fv` - FITS 文件查看器
3. `saotng` - SAOImage TG

## 故障排除

如果预览不工作：

### 1. 确认 CFITSIO 工具已安装

```bash
# 检查 fitsheader
which fitsheader

# 如果没有，在 macOS 上安装
brew install cfitsio

# 在 Linux 上安装
sudo apt-get install cfitsio-bin
```

### 2. 测试命令是否正常工作

```bash
# 测试预览命令
fitsheader your_file.fits

# 测试查看器命令
ds9 your_file.fits
```

### 3. 检查 Yazi 日志

```bash
# 启用调试模式
YAZI_LOG=debug yazi

# 查看日志
grep "fits" ~/.local/state/yazi/yazi.log
```

### 4. 常见问题

__Q: 预览显示 "fitsheader command not found"__

A: 请确保已安装 CFITSIO，并且 `fitsheader` 在 PATH 中

__Q: 按 Enter 打开文件时出错__

A: 请安装 DS9 或其他 FITS 查看器

```bash
# macOS
brew install --cask saods9

# Linux
sudo apt-get install saods9
```

__Q: FITS header 显示乱码__

A: 插件会自动清理 ANSI 颜色代码。如果仍有问题，请检查 `fitsheader` 的输出格式

## 开发

### 项目结构

```
fits-preview.yazi/
├── main.lua           # 主插件代码
└── README.md          # 本文档
```

### 插件接口

插件实现了 Yazi 的三个标准预览器接口：

- `peek(job)` - 预览文件内容
- `seek(job)` - 处理滚动事件
- `entry(job)` - 处理打开文件事件

## 版本

当前版本: __0.1.0__

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 作者

cxwx using glm-5

## 相关链接

- [FITS 格式规范](https://fits.gsfc.nasa.gov/fits_documentation.html)
- [CFITSIO 官网](https://heasarc.gsfc.nasa.gov/fitsio/)
- [SAOImage DS9](http://ds9.si.edu/site/Home.html)
- [Yazi 文件管理器](https://github.com/sxyazi/yazi)
