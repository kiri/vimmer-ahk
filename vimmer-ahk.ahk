#Requires AutoHotkey v2.0

/**
 * IMEの状態を設定する (v2対応版)
 * @param SetSts - 0: OFF, 1: ON
 * @param WinTitle - 対象ウィンドウ (デフォルトはアクティブウィンドウ)
 */
IME_SET(SetSts, WinTitle := "A") {
    try {
        hwnd := ControlGetHwnd(, WinTitle)
    } catch {
        return ; ウィンドウが見つからない場合は終了
    }

    if WinActive(WinTitle) {
        ; GUIThreadInfo 構造体の準備 (Size: 48 or 72 bytes)
        stGTI := Buffer(cbSize := 4 + 4 + (A_PtrSize * 6) + 16, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        
        if DllCall("GetGUIThreadInfo", "UInt", 0, "Ptr", stGTI) {
            ; 8 + PtrSize の位置にある hwndFocus を取得
            if (focusHwnd := NumGet(stGTI, 8 + A_PtrSize, "Ptr")) {
                hwnd := focusHwnd
            }
        }
    }

    ; IMEデフォルトウィンドウに対してメッセージを送信
    return DllCall("SendMessage", 
        "Ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr"), 
        "UInt", 0x0283, ; WM_IME_CONTROL
        "Ptr", 0x006,  ; IMC_SETOPENSTATUS
        "Ptr", SetSts, 
        "Ptr")
}

; ホットキーの割り当て
~Esc::IME_SET(0)
~^[::IME_SET(0)
