BindingsActive() {
    Title := WinGetTitle("A")
    if (Title ~= "^(QQ|微信)$") {
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
    if (FocusedHwnd != 0) {
        FocusedClassNN := ControlGetClassNN(FocusedHwnd)
    }
    MsgBox 'Window with focus = {Title: ' Title '}'
    MsgBox 'Control with focus = {Hwnd: ' FocusedHwnd '}'
    MsgBox 'Control with focus = {ClassNN: ' FocusedClassNN '}'
}
