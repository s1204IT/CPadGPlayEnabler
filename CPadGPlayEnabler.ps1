Clear-Host


# ADBパスの設定／サーバ開始
Set-Item env:Path "$env:Path;$(Convert-Path .\assets\DebugBridge\);"
adb start-server
Clear-Host


# 端末識別
If ($(adb shell getprop ro.product.model) -Like "TAB-A03-B[S,R,R2]") {
    Write-Output "｢チャレンジパッド２｣が検出されました"
    Set-Variable -Name CT2 -Value 1
} ElseIf ($(adb shell getprop ro.product.model) -Like "TAB-A03-BR3") {
    Write-Output "｢チャレンジパッド３｣が検出されました"
    Set-Variable -Name CT3 -Value 1
} ElseIf ($(adb shell getprop ro.product.model) -Like "TAB-A05-B[D,A1]") {
    Write-Output "｢チャレンジパッドNeo/Next｣が検出されました"
} Else {
    Write-Output "チャレンジパッドが検出されませんでした"
    Read-Host "もう一度やり直して下さい｡(Enter)"
    adb kill-server
    Clear-Host
    exit 1
} Read-Host "続行しますか？(Enter)"
Clear-Host


# Googleサービスのインストール

# Googleアカウントマネージャー
If ($CT2 -Eq 1) {
    Write-Output "｢Googleアカウントマネージャー｣をインストール中..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=97485
    adb install .\assets\GoogleLoginService_22.apk | Out-Null
    Write-Output "｢Googleアカウントマネージャー｣に権限を付与中..."
    adb shell pm grant com.google.android.gsf.login android.permission.DUMP
    adb shell pm grant com.google.android.gsf.login android.permission.READ_LOGS
}

# Googleサービスフレームワーク | microG Services Framework Proxy
If ($CT2 -Eq 1){
    Write-Output "｢Googleサービスフレームワーク｣をインストール中..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=83724
    adb install .\assets\GoogleServicesFramework_19.apk | Out-Null
    Write-Output "｢Googleサービスフレームワーク｣に権限を付与中..."
    adb shell pm grant com.google.android.gsf android.permission.DUMP
    adb shell pm grant com.google.android.gsf android.permission.READ_LOGS
    adb shell pm grant com.google.android.gsf android.permission.WRITE_SECURE_SETTINGS
    adb shell pm grant com.google.android.gsf android.permission.INTERACT_ACROSS_USERS
} Else {
    Write-Output "｢microG Services Framework Proxy｣をインストール中..."
    # https://github.com/microg/android_packages_apps_GsfProxy/releases/download/v0.1.0/GsfProxy.apk
    adb install .\assets\microG\GsfProxy.apk | Out-Null
}

# Google Play開発者サービス | microG Services Core
If ($CT2 -Eq 1) {
    Write-Output "｢Google Play開発者サービス｣をインストール中..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=3181340
    adb install .\assets\GmsCore_214858006.apk | Out-Null
    Write-Output "｢Google Play開発者サービス｣に権限を付与中..."
    adb shell pm grant com.google.android.gms android.permission.INTERACT_ACROSS_USERS
    adb shell pm grant com.google.android.gms android.permission.PACKAGE_USAGE_STATS
    adb shell pm grant com.google.android.gms android.permission.GET_APP_OPS_STATS
    adb shell pm grant com.google.android.gms android.permission.READ_LOGS
    adb shell dpm set-active-admin --user 0 com.google.android.gms/.mdm.receivers.MdmDeviceAdminReceiver | Out-Null
} Else {
    Write-Output "｢microG Services Core｣をインストール中..."
    # https://github.com/microg/GmsCore/releases/download/v0.2.24.214816/com.google.android.gms-214816048.apk
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
If ($CT3 -Ne 1) {
    Write-Output "｢Google Playストア｣をインストール中..."
    If ($CT2 -Eq 1) {
        # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=2860119&forcebaseapk
        adb install .\assets\Phonesky_82791710.apk | Out-Null
    } Else {
        # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=1360568
        adb install .\assets\Phonesky_82092000.apk | Out-Null
        adb shell am force-stop com.android.vending
    }
    Write-Output "｢Google Playストア｣に権限を付与中..."
    adb shell pm grant com.android.vending android.permission.PACKAGE_USAGE_STATS
    adb shell pm grant com.android.vending android.permission.BATTERY_STATS
    adb shell pm grant com.android.vending android.permission.DUMP
    adb shell pm grant com.android.vending android.permission.GET_APP_OPS_STATS
    adb shell pm grant com.android.vending android.permission.INTERACT_ACROSS_USERS
    adb shell pm grant com.android.vending android.permission.WRITE_SECURE_SETTINGS
    If ($CT2 -Ne 1) {
        adb shell pm grant com.android.vending android.permission.SEND_SMS
        adb shell pm grant com.android.vending android.permission.RECEIVE_SMS
        adb shell pm grant com.android.vending android.permission.READ_SMS
        adb shell pm grant com.android.vending android.permission.WRITE_EXTERNAL_STORAGE
        adb shell pm grant com.android.vending android.permission.READ_EXTERNAL_STORAGE
        adb shell pm grant com.android.vending android.permission.READ_PHONE_STATE
        adb shell pm grant com.android.vending android.permission.ACCESS_COARSE_LOCATION
        adb shell pm grant com.android.vending android.permission.READ_CONTACTS
        adb shell am start -n com.android.vending/com.google.android.finsky.activities.SettingsActivity | Out-Null
        Start-Sleep 1
        adb shell am force-stop com.android.vending
    }
} Else {
    Write-Output "｢FakeStore｣をインストール中..."
    # https://github.com/microg/FakeStore/releases/download/v0.1.0/FakeStore-v0.1.0.apk
    adb install .\assets\microG\FakeStore-v0.1.0.apk | Out-Null
} Clear-Host


# Rebooting Tablet
adb reboot


# End Script
Write-Output "処理が完了しました"
Read-Host "Enterを押して終了して下さい"
adb kill-server
Clear-Host
exit 0