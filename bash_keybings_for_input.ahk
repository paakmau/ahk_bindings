#Requires AutoHotkey v2.0
global IUIAutomationActivateScreenReader := 0
#Include Lib\UIA.ahk

BindingsActive() {
    Title := WinGetTitle("A")
    if (Title ~= "^(QQ|微信)$") {
        return true
    }

    if EdgeEditBindingsActive() {
        return true
    }

    FocusedHwnd := ControlGetFocus("A")
    if (FocusedHwnd != 0) {
        FocusedClassNN := ControlGetClassNN(FocusedHwnd)
        if (FocusedClassNN ~= "^(Input|Windows\.UI\.Core).*") {
            return true
        }
        return false
    }

   return CaretGetPos()
}

EdgeEditBindingsActive() {
    static edgeExe := "ahk_exe msedge.exe"

    if !WinActive(edgeExe) {
        return false
    }

    if !UIA.WindowIsChromium("A") {
        return false
    }

    caretVisible := CaretGetPos()

    try {
        UIA.ActivateChromiumAccessibility("A")
        focusedEl := UIA.GetFocusedElement()

        Loop 12 {
            switch focusedEl.Type {
                case UIA.Type.Edit:
                    return true
                case UIA.Type.ListItem:
                    return true
                case UIA.Type.Document:
                    if caretVisible {
                        return true
                    }
            }

            focusedEl := focusedEl.Parent
            if !IsObject(focusedEl) {
                break
            }
        }
    } catch Error {
        return false
    }

    return false
}

#HotIf (BindingsActive())
    ^f::Right
    !f::^Right
    ^b::Left
    !b::^Left
    ^n::Down
    ^p::Up
    ^a::Home
    ^e::End
    ^d::Delete
    !d::Send "^+{Right}^x"
    ^h::Backspace
    ^w::Send "^+{Left}^x"
    ^k::Send "+{End}^x"
    ^u::Send "+{Home}^x"
    ^y::^v
#HotIf

^+!a::{
    Title := WinGetTitle("A")
    FocusedHwnd := ControlGetFocus("A")
    FocusedClassNN := ""
    UiInfo := "UIA focus = <unavailable>`nUIA parent = <unavailable>"
    if (FocusedHwnd != 0) {
        FocusedClassNN := ControlGetClassNN(FocusedHwnd)
    }
    try {
        if UIA.WindowIsChromium("A") {
            UIA.ActivateChromiumAccessibility("A")
        }
        FocusedEl := UIA.GetFocusedElement()
        ParentEl := 0
        try ParentEl := FocusedEl.Parent
        UiInfo := "UIA focus = " FocusedEl.Dump()
            . "`nUIA parent = "
            . (IsObject(ParentEl) ? ParentEl.Dump() : "<none>")
    } catch Error as Err {
        UiInfo := "UIA focus = <error>`nUIA parent = <error>`nReason = " Err.Message
    }

    MsgBox "Window title = " Title
        . "`nControl hwnd = " FocusedHwnd
        . "`nControl classNN = " FocusedClassNN
        . "`n" UiInfo
}
