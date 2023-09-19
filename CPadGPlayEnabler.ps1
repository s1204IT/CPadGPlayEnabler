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
    adb install -r .\assets\$AppPackage.apk | Out-Null
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
        $CT2 = 1
    }
    "TAB-A03-BR3" {
        ExistCPad "３"
        Start-Process "https://github.com/s1204IT/CPadGApps/tree/CT3"
        Write-Output "`r`nCPadGAppsが利用出来ます`r`n"
    }
    "TAB-A05-BD" { ExistCPad "Neo" }
    "TAB-A05-BA1" { ExistCPad "Next" }
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


# Googleサービスのインストール

if ($CT2 -eq 1) {
    
    # Googleアカウントマネージャー
    InstApp "Googleアカウントマネージャー" GoogleLoginService_22
    GrantApp "Googleアカウントマネージャー" com.google.android.gsf.login DUMP,READ_LOGS

    # Googleサービスフレームワーク
    InstApp "Googleサービスフレームワーク" GoogleServicesFramework_19
    GrantApp "Googleサービスフレームワーク" com.google.android.gsf DUMP,READ_LOGS,WRITE_SECURE_SETTINGS,INTERACT_ACROSS_USERS

    # Google Play開発者サービス
    InstApp "Google Play開発者サービス" GmsCore_225014006
    GrantApp "Google Play開発者サービス" com.google.android.gms INTERACT_ACROSS_USERS,PACKAGE_USAGE_STATS,GET_APP_OPS_STATS,READ_LOGS
    adb shell dpm set-active-admin --user 0 com.google.android.gms/.mdm.receivers.MdmDeviceAdminReceiver | Out-Null

    # Google Playストア
    InstApp "Google Playストア" Phonesky_82791710
    GrantApp "Google Playストア" com.android.vending PACKAGE_USAGE_STATS,BATTERY_STATS,DUMP,GET_APP_OPS_STATS,INTERACT_ACROSS_USERS,WRITE_SECURE_SETTINGS

} else {

    # microG Services Framework Proxy
    InstApp "microG Services Framework Proxy" microG\GsfProxy

    # microG Services Core
    InstApp "microG Services Core" microG\com.google.android.gms-231657056
    GrantApp "microG Services Core" com.google.android.gms ACCESS_COARSE_LOCATION,ACCESS_FINE_LOCATION,READ_PHONE_STATE,GET_ACCOUNTS,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE,RECEIVE_SMS,SYSTEM_ALERT_WINDOW,BODY_SENSORS
    adb shell dumpsys deviceidle whitelist +"com.google.android.gms" | Out-Null

    # FakeStore
    InstApp "FakeStore" microG\com.android.vending-30

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
