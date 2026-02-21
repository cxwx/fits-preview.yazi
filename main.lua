-- FITS 文件预览插件
-- 用于在 Yazi 中预览 Flexible Image Transport System (FITS) 天文数据文件
--
-- 实现标准的 Yazi 预览器接口
local M = {}

-- 缓存文件内容，避免重复执行 fitsheader
-- cache[file] = { lines = {...}, total = total_lines }
local cache = {}

-- 检查 fitsheader 是否可用
local function check_fitsheader()
	local handle = io.popen("which fitsheader 2>/dev/null && echo 'found' || echo 'not_found'")
	local result = handle:read("*a")
	handle:close()
	return result:match("found") ~= nil
end

-- 清理输出中的 ANSI 颜色代码
local function strip_ansi_codes(str)
	return str:gsub("\x1b%[%d;]*m", "")
end

-- 预览 FITS 文件内容
function M:peek(job)
	-- 检查依赖
	if not check_fitsheader() then
		ya.preview_widget(
			job,
			ui.Text.parse(
				"Error: fitsheader command not found.\nPlease install CFITSIO or fitsheader.\n\nmacOS: brew install cfitsio\nLinux: apt-get install cfitsio-bin"
			):area(job.area)
		)
		return
	end

	-- 修复：将 Url 对象转换为字符串
	local file = tostring(job.file.url)

	-- 尝试从缓存读取
	local cached = cache[file]
	if not cached then
		-- 使用 Yazi 的 Command API 执行 fitsheader 命令
		-- fitsheader 可以显示 FITS 文件的 header 信息
		local output, err = Command("fitsheader"):arg({ file }):output()
		if err then
			ya.err("FITS preview plugin: failed to execute fitsheader - " .. tostring(err))
			ya.preview_widget(
				job,
				ui.Text.parse("Failed to preview FITS file\n" .. tostring(err)):area(job.area):wrap(ui.Wrap.YES)
			)
			return
		end

		-- 清理 ANSI 颜色代码以提高可读性
		local content = strip_ansi_codes(output.stdout)

		-- 预先分割成行并缓存
		local lines = {}
		for line in content:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end

		-- 缓存分割后的行数组
		cached = { lines = lines, total = #lines }
		cache[file] = cached
	end

	-- 处理分页和滚动
	local lines = {}
	local limit = job.area.h
	local start_line = job.skip + 1
	local end_line = math.min(job.skip + limit, cached.total)

	-- 如果滚动超出范围，发送 peek 事件调整位置
	if job.skip > 0 and end_line >= cached.total then
		ya.emit("peek", {
			math.max(0, cached.total - limit),
			only_if = job.file.url,
			upper_bound = true,
		})
		return
	end

	-- 直接从缓存中提取需要的行
	for i = start_line, end_line do
		table.insert(lines, cached.lines[i])
	end

	-- 显示分页后的内容
	ya.preview_widget(job, ui.Text.parse(table.concat(lines, "\n")):area(job.area):wrap(ui.Wrap.NO))
end

-- 处理预览滚动
function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

-- 打开 FITS 文件（使用 fitsview 或 ds9）
function M:entry(job)
	-- 尝试检测可用的 FITS 查看器
	local viewers = { "ds9", "fv", "saotng" }
	local chosen_viewer = nil

	for _, viewer in ipairs(viewers) do
		local handle = io.popen("which " .. viewer .. " 2>/dev/null && echo 'found' || echo 'not_found'")
		local result = handle:read("*a")
		handle:close()
		if result:match("found") ~= nil then
			chosen_viewer = viewer
			break
		end
	end

	if not chosen_viewer then
		ya.notify({
			title = "FITS Preview",
			content = "No FITS viewer found.\nPlease install ds9: brew install saods9",
			level = "error",
			timeout = 5.0,
		})
		return
	end

	-- 隐藏 Yazi 界面
	local _ = ui.hide and ui.hide() or ya.hide()

	-- 使用找到的查看器打开文件
	local file = tostring(job.file.url)
	local child, err = Command(chosen_viewer):arg({ file }):stdin(Command.INHERIT):stdout(Command.INHERIT):stderr(Command.PIPED):spawn()

	if not child then
		ya.notify({
			title = "FITS Preview",
			content = "Failed to open FITS file: " .. tostring(err),
			level = "error",
			timeout = 5.0,
		})
		return
	end

	-- 等待查看器退出
	local output, err_code = child:wait_with_output()
	if err_code ~= nil then
		ya.notify({
			title = "FITS Viewer Error",
			content = "Exit code: " .. err_code,
			level = "error",
			timeout = 5.0,
		})
	end
end

-- 插件初始化
function M:setup(state, opts)
	-- 检查依赖
	if not check_fitsheader() then
		ya.err("FITS preview plugin: fitsheader command not found. Please install CFITSIO.")
		return false
	end

	-- 检查用户配置
	opts = opts or {}

	-- 成功初始化
	ya.info("FITS preview plugin loaded successfully")
	return true
end

-- 插件元数据
M.metadata = {
	name = "fits-preview",
	description = "Preview FITS files using fitsheader command",
	version = "0.1.0",
	author = "chenxu",
	dependencies = { "fitsheader" },
}

return M
