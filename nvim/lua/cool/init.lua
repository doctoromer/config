local download_dir = require("cool.utils").download_dir

if vim.env.DOWNLOAD_MODE then
    require("cool.download").download(download_dir)
else
    require("cool.options")
    require("cool.lazy_init").setup(false, download_dir)
end
