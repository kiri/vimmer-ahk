#Requires AutoHotkey v2.0

/**
 * IMEの状態を設定する (v2修正版)
 */
IME_SET(SetSts, WinTitle := "A") {
    try {
        ; ControlGetHwndの第1引数に空文字を指定、またはWinGetIDを使用
        hwnd := WinGetID(WinTitle)
    } catch {
        return
    }

    if WinActive(WinTitle) {
        stGTI := Buffer(cbSize := 4 + 4 + (A_PtrSize * 6) + 16, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI) {
            ; 8 + PtrSize の位置は hwndFocus (フォーカスのあるコントロール)
            if (focusHwnd := NumGet(stGTI, 8 + A_PtrSize, "Ptr")) {
                hwnd := focusHwnd
            }
        }
    }

    ; 送信
    return DllCall("SendMessage", 
        "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr"), 
        "UInt", 0x0283, ; WM_IME_CONTROL
        "Ptr", 0x006,  ; IMC_SETOPENSTATUS
        "Ptr", SetSts, 
        "Ptr")
}

; ホットキー
~Esc::IME_SET(0)
~^[::IME_SET(0)
