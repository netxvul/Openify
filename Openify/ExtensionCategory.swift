struct ExtensionCategory: Identifiable {
    let id: String
    let title: String
    let extensions: [String]
}

enum ExtensionDataSource {
    static let categories: [ExtensionCategory] = [
        ExtensionCategory(
            id: "code",
            title: "代码",
            extensions: [
                "h", "hpp", "c", "cc", "cpp", "m", "mm", "swift", "go", "rs", "java", "kt",
                "py", "rb", "php", "cs", "sh", "bash", "zsh", "ps1", "sql", "html", "vue",
                "tsx", "ts", "jsx", "js", "css", "scss", "sass", "less",
            ]
        ),
        ExtensionCategory(
            id: "document",
            title: "文档",
            extensions: [
                "txt", "rtf", "md", "markdown", "doc", "docx", "odt", "pages", "pdf",
                "ppt", "pptx", "key", "odp", "xls", "xlsx", "numbers", "ods", "csv",
                "wps", "epub",
            ]
        ),
        ExtensionCategory(
            id: "image",
            title: "图片",
            extensions: [
                "png", "svg", "jpeg", "jpg", "gif", "webp", "bmp", "tiff", "tif", "heic",
                "heif", "avif", "ico", "icns", "psd", "raw", "cr2", "nef", "arw",
            ]
        ),
        ExtensionCategory(
            id: "audio",
            title: "音频",
            extensions: [
                "mp3", "m4a", "aac", "wav", "flac", "ogg", "oga", "opus", "aiff", "aif",
                "wma", "mid", "midi",
            ]
        ),
        ExtensionCategory(
            id: "video",
            title: "视频",
            extensions: [
                "mp4", "m4v", "mov", "mkv", "avi", "wmv", "flv", "webm", "mpeg", "mpg",
                "ts", "m2ts", "3gp",
            ]
        ),
        ExtensionCategory(
            id: "archive",
            title: "压缩包",
            extensions: [
                "zip", "rar", "7z", "tar", "gz", "tgz", "bz2", "tbz", "xz", "txz", "zst",
                "tar.gz", "tar.bz2", "tar.xz",
            ]
        ),
        ExtensionCategory(
            id: "data",
            title: "数据配置",
            extensions: [
                "json", "jsonc", "yaml", "yml", "toml", "xml", "plist", "ini", "conf",
                "cfg", "env", "properties", "log",
            ]
        ),
        ExtensionCategory(
            id: "design",
            title: "设计工程",
            extensions: [
                "fig", "sketch", "xd", "ai", "eps", "indd",
            ]
        ),
        ExtensionCategory(
            id: "font",
            title: "字体",
            extensions: [
                "ttf", "otf", "woff", "woff2",
            ]
        ),
        ExtensionCategory(
            id: "package",
            title: "安装镜像",
            extensions: [
                "dmg", "pkg", "mpkg", "iso",
            ]
        ),
    ]
}
