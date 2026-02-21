# FITS Preview Plugin - Quick Start

快速开始使用 FITS 预览插件。

## 快速安装

### 1. 安装依赖

```bash
# macOS
brew install cfitsio
brew install --cask saods9  # 可选，用于打开文件

# Linux (Ubuntu/Debian)
sudo apt-get install cfitsio-bin saods9
```

### 2. 安装插件

```bash
# 复制到 yazi 插件目录
cp -r fits-preview.yazi ~/.config/yazi/plugins/fits-preview.yazi
```

### 3. 配置 yazi

在 `~/.config/yazi/yazi.toml` 中添加：

```toml
[[plugin.prepend_previewers]]
name = "*.fits"
run = "fits-preview"

[[plugin.prepend_previewers]]
name = "*.fit"
run = "fits-preview"
```

### 4. 重启 yazi 并使用

```bash
yazi
```

浏览到任何 `.fits` 文件即可看到预览！

## 验证安装

```bash
# 检查 fitsheader 是否可用
which fitsheader
fitsheader --version

# 测试预览功能
# 在 yazi 中打开一个 FITS 文件，右侧应该显示 header 信息
```

## 常用操作

- **预览 FITS header**: 选中文件，右侧自动显示
- **滚动查看**: `Ctrl+j/k` 上下滚动，`Ctrl+u/d` 翻页
- **在 DS9 中打开**: 按 `Enter` 键

## 示例 FITS 文件

如果你没有 FITS 文件，可以从以下来源下载测试：

- [Hubble Space Telescope Archive](https://hst.esac.esa.int/ehst-sl-server/servlet/data-action)
- [Chandra X-ray Observatory](https://cda.harvard.edu/chaser/)
- [SDSS SkyServer](https://skyserver.sdss.org/)

## 需要帮助？

查看完整文档: [README.md](README.md)

提交问题: [GitHub Issues](https://github.com/cxwx/fits-preview.yazi/issues)
