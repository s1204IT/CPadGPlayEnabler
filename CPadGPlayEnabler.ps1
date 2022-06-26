Clear-Host


# ADB�p�X�̐ݒ�^�T�[�o�J�n
Set-Item env:Path "$env:Path;$(Convert-Path .\assets\DebugBridge\);"
adb start-server
Clear-Host


# �[������
If ($(adb shell getprop ro.product.model) -Like "TAB-A03-B[S,R,R2]") {
    Write-Output "��`�������W�p�b�h�Q������o����܂���"
    Set-Variable -Name CT2 -Value 1
} ElseIf ($(adb shell getprop ro.product.model) -Like "TAB-A03-BR3") {
    Write-Output "��`�������W�p�b�h�R������o����܂���"
    Set-Variable -Name CT3 -Value 1
} ElseIf ($(adb shell getprop ro.product.model) -Like "TAB-A05-B[D,A1]") {
    Write-Output "��`�������W�p�b�hNeo/Next������o����܂���"
} Else {
    Write-Output "�`�������W�p�b�h�����o����܂���ł���"
    Read-Host "������x��蒼���ĉ������(Enter)"
    adb kill-server
    Clear-Host
    exit 1
} Read-Host "���s���܂����H(Enter)"
Clear-Host


# Google�T�[�r�X�̃C���X�g�[��

# Google�A�J�E���g�}�l�[�W���[
If ($CT2 -Eq 1) {
    Write-Output "�Google�A�J�E���g�}�l�[�W���[����C���X�g�[����..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=97485
    adb install .\assets\GoogleLoginService_22.apk | Out-Null
    Write-Output "�Google�A�J�E���g�}�l�[�W���[��Ɍ�����t�^��..."
    adb shell pm grant com.google.android.gsf.login android.permission.DUMP
    adb shell pm grant com.google.android.gsf.login android.permission.READ_LOGS
}

# Google�T�[�r�X�t���[�����[�N | microG Services Framework Proxy
If ($CT2 -Eq 1){
    Write-Output "�Google�T�[�r�X�t���[�����[�N����C���X�g�[����..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=83724
    adb install .\assets\GoogleServicesFramework_19.apk | Out-Null
    Write-Output "�Google�T�[�r�X�t���[�����[�N��Ɍ�����t�^��..."
    adb shell pm grant com.google.android.gsf android.permission.DUMP
    adb shell pm grant com.google.android.gsf android.permission.READ_LOGS
    adb shell pm grant com.google.android.gsf android.permission.WRITE_SECURE_SETTINGS
    adb shell pm grant com.google.android.gsf android.permission.INTERACT_ACROSS_USERS
} Else {
    Write-Output "�microG Services Framework Proxy����C���X�g�[����..."
    # https://github.com/microg/android_packages_apps_GsfProxy/releases/download/v0.1.0/GsfProxy.apk
    adb install .\assets\microG\GsfProxy.apk | Out-Null
}

# Google Play�J���҃T�[�r�X | microG Services Core
If ($CT2 -Eq 1) {
    Write-Output "�Google Play�J���҃T�[�r�X����C���X�g�[����..."
    # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=3181340
    adb install .\assets\GmsCore_214858006.apk | Out-Null
    Write-Output "�Google Play�J���҃T�[�r�X��Ɍ�����t�^��..."
    adb shell pm grant com.google.android.gms android.permission.INTERACT_ACROSS_USERS
    adb shell pm grant com.google.android.gms android.permission.PACKAGE_USAGE_STATS
    adb shell pm grant com.google.android.gms android.permission.GET_APP_OPS_STATS
    adb shell pm grant com.google.android.gms android.permission.READ_LOGS
    adb shell dpm set-active-admin --user 0 com.google.android.gms/.mdm.receivers.MdmDeviceAdminReceiver | Out-Null
} Else {
    Write-Output "�microG Services Core����C���X�g�[����..."
    # https://github.com/microg/GmsCore/releases/download/v0.2.24.214816/com.google.android.gms-214816048.apk
    adb install .\assets\microG\com.google.android.gms-214816048.apk | Out-Null
    Write-Output "�microG Services Core��Ɍ�����t�^��..."
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

# Google Play�X�g�A | FakeStore
If ($CT3 -Ne 1) {
    Write-Output "�Google Play�X�g�A����C���X�g�[����..."
    If ($CT2 -Eq 1) {
        # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=2860119&forcebaseapk
        adb install .\assets\Phonesky_82791710.apk | Out-Null
    } Else {
        # https://www.apkmirror.com/wp-content/themes/APKMirror/download.php?id=1360568
        adb install .\assets\Phonesky_82092000.apk | Out-Null
        adb shell am force-stop com.android.vending
    }
    Write-Output "�Google Play�X�g�A��Ɍ�����t�^��..."
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
    Write-Output "�FakeStore����C���X�g�[����..."
    # https://github.com/microg/FakeStore/releases/download/v0.1.0/FakeStore-v0.1.0.apk
    adb install .\assets\microG\FakeStore-v0.1.0.apk | Out-Null
} Clear-Host


# Rebooting Tablet
adb reboot


# End Script
Write-Output "�������������܂���"
Read-Host "Enter�������ďI�����ĉ�����"
adb kill-server
Clear-Host
exit 0