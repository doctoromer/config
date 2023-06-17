if vim.env.DOWNLOAD_MODE then
    require("cool.download").download()
else
    require("cool.options")
    require("cool.lazy_init").setup()
end
