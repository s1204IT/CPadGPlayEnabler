Clear-Host
$Host.UI.RawUI.WindowTitle = "CPadGPlayEnabler"

# ADBサーバ開始
$ErrorActionPreference = "SilentlyContinue"
# ADBコマンドの実行に失敗した場合に最新版を導入
if ($(adb start-server | Out-Null) -eq $false) {
    # ダウンロード済みかどうかを検証
    if ($(Test-Path .\assets\platform-tools) -ne $true) {
        $ProgressPreference = "SilentlyContinue"
        Write-Output "ADBをダウンロード中..."
        Invoke-WebRequest -Uri https://dl.google.com/android/repository/platform-tools-latest-windows.zip -OutFile .\assets\platform-tools.zip -UseBasicParsing
        Expand-Archive -Path .\assets\platform-tools.zip -Force
        Move-Item -Path .\platform-tools\platform-tools\ .\assets\ -Force
        Remove-Item -Path .\assets\platform-tools.zip,.\platform-tools -Recurse -Force
    }
    # Path に追加
    Set-Item Env:Path "$(Convert-Path .\assets\platform-tools\);$Env:Path;" -Force
    adb start-server
}
Clear-Host


# 関数
function ExistCPad ($CPadType) {
    Write-Output "｢チャレンジパッド$CPadType｣が検出されました"
}

function InstApp ($AppName, $AppPackage) {
    Write-Output "｢$AppName｣をインストール中..."
    adb install -r ".\assets\$AppPackage.apk" | Out-Null
}

function GrantApp ($AppName, $AppPackage, $perms) {
    Write-Output "｢$AppName｣に権限を付与中..."
    foreach ($NowPerm in $perms) {
        adb shell pm grant $AppPackage android.permission.$NowPerm
    }
}

# 端末識別
switch ("$(adb shell getprop ro.product.model)") {
    ({"TAB-A03-B[S,R]" -or "TAB-A03-BR2"}) {
        ExistCPad "２"
        $PType = '2'
    }
    "TAB-A03-BR3" {
        ExistCPad "３"
        Start-Process "https://zenn.dev/s1204it/articles/16fce85441821f"
        Write-Output "`r`nCPadGAppsが利用出来ます`r`n"
        $PType = '3'
    }
    "TAB-A05-BD" {
        ExistCPad "Neo"
        $PType = 'X'
    }
    "TAB-A05-BA1" {
        ExistCPad "Next"
        $PType = 'Z'
    }
    default {
        Write-Output "チャレンジパッドが検出されませんでした"
        Read-Host "もう一度やり直して下さい｡(Enter)"
        adb kill-server
        Clear-Host
        exit 1
    }
}
Read-Host "続行しますか？(Enter)"
Clear-Host

# CTZ の場合のみ DchaState を 3 に修正する
if ($Ptype -eq "Z") {
    adb shell settings put system dcha_state 3
    InstApp "Bypass Revoke Permission" BypassRevokePermission
}

# Googleサービスのインストール

if ({$PType -eq "2" -or $PType -eq "Z"}) {

    # Googleサービスフレームワーク
    InstApp "Googleサービスフレームワーク" "CT$PType\GoogleServicesFramework"
    GrantApp "Googleサービスフレームワーク" com.google.android.gsf DUMP,READ_LOGS,WRITE_SECURE_SETTINGS,INTERACT_ACROSS_USERS

    # Google Play開発者サービス
    InstApp "Google Play開発者サービス" "CT$PType\GmsCore"
    GrantApp "Google Play開発者サービス" com.google.android.gms INTERACT_ACROSS_USERS,PACKAGE_USAGE_STATS,GET_APP_OPS_STATS,READ_LOGS
    adb shell dpm set-active-admin --user 0 com.google.android.gms/.mdm.receivers.MdmDeviceAdminReceiver | Out-Null

    # Google Playストア
    InstApp "Google Playストア" "CT$PType\Phonesky"
    GrantApp "Google Playストア" com.android.vending PACKAGE_USAGE_STATS,BATTERY_STATS,DUMP,GET_APP_OPS_STATS,INTERACT_ACROSS_USERS,WRITE_SECURE_SETTINGS

} else {

    # Services Framework Proxy
    InstApp "microG Services Framework Proxy" microG\ServicesFrameworkProxy

    # microG Services
    InstApp "microG Services" microG\microGServices
    GrantApp "microG Services" com.google.android.gms ACCESS_COARSE_LOCATION,ACCESS_FINE_LOCATION,READ_PHONE_STATE,GET_ACCOUNTS,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,RECEIVE_SMS,SYSTEM_ALERT_WINDOW,BODY_SENSORS
    adb shell dumpsys deviceidle whitelist +"com.google.android.gms" | Out-Null

    # microG Companion
    InstApp "microG Companion" microG\microGCompanion

}

# CT2 は GMS の権限を修正
if ($PType -eq "2") {
    InstApp "Enable GServices" EnableGServices
    adb shell am start -n com.saradabar.enablegservices/.MainActivity
    Start-Sleep 3
    adb shell pm uninstall com.saradabar.enablegservices | Out-Null
}

Clear-Host

# 端末を再起動
adb reboot

# スクリプトを終了
Write-Output "処理が完了しました"
Read-Host "Enterを押して終了して下さい"
adb kill-server
Clear-Host
exit 0
