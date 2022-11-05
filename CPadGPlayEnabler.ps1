Clear-Host
$Host.UI.RawUI.WindowTitle = "CPadGPlayEnabler"

# ADBサーバ開始
$ErrorActionPreference = "SilentlyContinue"
adb start-server | Out-Null
# ADBサーバの開始に失敗した場合に最新版を導入
If ($? -Eq $false) {
    # ダウンロード済みかどうかを検証
    If ($(Test-Path .\assets\platform-tools) -Ne "True") {
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri https://dl.google.com/android/repository/platform-tools-latest-windows.zip -OutFile .\assets\platform-tools.zip -UseBasicParsing
        Expand-Archive -Path .\assets\platform-tools.zip -Force
        Move-Item -Path .\platform-tools\platform-tools\ .\assets\ -Force
        Remove-Item -Path .\assets\platform-tools.zip -Recurse
        Remove-Item -Path .\platform-tools -Recurse
    }
    # Path に追加
    Set-Item Env:Path "$(Convert-Path .\assets\platform-tools\);$Env:Path;" -Force
    adb start-server
}
Clear-Host

# 端末識別
$Model = "$(adb shell getprop ro.product.model)"

If ($Model -Like "TAB-A03-B[S,R,R2]") {
    Write-Output "｢チャレンジパッド２｣が検出されました"
    $CT2 = 1
} ElseIf ($Model -Like "TAB-A03-BR3") {
    Write-Output "｢チャレンジパッド３｣が検出されました"
} ElseIf ($Model -Like "TAB-A05-B[D,A1]") {
    Write-Output "｢チャレンジパッドNeo/Next｣が検出されました"
} Else {
    Write-Output "チャレンジパッドが検出されませんでした"
    adb kill-server
    Read-Host "もう一度やり直して下さい｡(Enter)"
    Clear-Host
    exit 1
}
Read-Host "続行しますか？(Enter)"
Clear-Host

# Googleサービスのインストール

# Googleアカウントマネージャー
If ($CT2 -Eq 1) {
    Write-Output "｢Googleアカウントマネージャー｣をインストール中..."
    adb install .\assets\GoogleLoginService_22.apk | Out-Null
    Write-Output "｢Googleアカウントマネージャー｣に権限を付与中..."
    adb shell pm grant com.google.android.gsf.login android.permission.DUMP
    adb shell pm grant com.google.android.gsf.login android.permission.READ_LOGS
}

# Googleサービスフレームワーク | microG Services Framework Proxy
If ($CT2 -Eq 1){
    Write-Output "｢Googleサービスフレームワーク｣をインストール中..."
    adb install .\assets\GoogleServicesFramework_19.apk | Out-Null
    Write-Output "｢Googleサービスフレームワーク｣に権限を付与中..."
    adb shell pm grant com.google.android.gsf android.permission.DUMP
    adb shell pm grant com.google.android.gsf android.permission.READ_LOGS
    adb shell pm grant com.google.android.gsf android.permission.WRITE_SECURE_SETTINGS
    adb shell pm grant com.google.android.gsf android.permission.INTERACT_ACROSS_USERS
} Else {
    Write-Output "｢microG Services Framework Proxy｣をインストール中..."
    adb install .\assets\microG\GsfProxy.apk | Out-Null
}

# Google Play開発者サービス | microG Services Core
If ($CT2 -Eq 1) {
    Write-Output "｢Google Play開発者サービス｣をインストール中..."
    adb install .\assets\GmsCore_214858006.apk | Out-Null
    Write-Output "｢Google Play開発者サービス｣に権限を付与中..."
    adb shell pm grant com.google.android.gms android.permission.INTERACT_ACROSS_USERS
    adb shell pm grant com.google.android.gms android.permission.PACKAGE_USAGE_STATS
    adb shell pm grant com.google.android.gms android.permission.GET_APP_OPS_STATS
    adb shell pm grant com.google.android.gms android.permission.READ_LOGS
    adb shell dpm set-active-admin --user 0 com.google.android.gms/.mdm.receivers.MdmDeviceAdminReceiver | Out-Null
} Else {
    Write-Output "｢microG Services Core｣をインストール中..."
    adb install .\assets\microG\com.google.android.gms-214816048.apk | Out-Null
    Write-Output "｢microG Services Core｣に権限を付与中..."
    adb shell pm grant com.google.android.gms android.permission.ACCESS_COARSE_LOCATION
    adb shell pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION
    adb shell pm grant com.google.android.gms android.permission.READ_PHONE_STATE
    adb shell pm grant com.google.android.gms android.permission.GET_ACCOUNTS
    adb shell pm grant com.google.android.gms android.permission.WRITE_EXTERNAL_STORAGE
    adb shell pm grant com.google.android.gms android.permission.READ_EXTERNAL_STORAGE
    adb shell pm grant com.google.android.gms android.permission.RECEIVE_SMS
    adb shell pm grant com.google.android.gms android.permission.SYSTEM_ALERT_WINDOW
    adb shell dumpsys deviceidle whitelist +"com.google.android.gms" | Out-Null
}

# Google Playストア | FakeStore
Write-Output "｢Google Playストア｣をインストール中..."
If ($CT2 -Eq 1) {
    adb install .\assets\Phonesky_82791710.apk | Out-Null
    Write-Output "｢Google Playストア｣に権限を付与中..."
    adb shell pm grant com.android.vending android.permission.PACKAGE_USAGE_STATS
    adb shell pm grant com.android.vending android.permission.BATTERY_STATS
    adb shell pm grant com.android.vending android.permission.DUMP
    adb shell pm grant com.android.vending android.permission.GET_APP_OPS_STATS
    adb shell pm grant com.android.vending android.permission.INTERACT_ACROSS_USERS
    adb shell pm grant com.android.vending android.permission.WRITE_SECURE_SETTINGS
} Else {
    Write-Output "｢FakeStore｣をインストール中..."
    adb install .\assets\microG\FakeStore-v0.1.0.apk | Out-Null
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
