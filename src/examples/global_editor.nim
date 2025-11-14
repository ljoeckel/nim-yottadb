import os, unicode
import std/strutils
import std/strformat
import yottadb
import ydbutils


# MAIN ----
var
    currentFocus: int
    currentSelected: string
    lastSelected: string
    eventCount: int
    globalsCount: int

type 
    TextItem* = object 
        text*: string 
        bg*: uint32
        fg*: uint32
        style*: uint16

    DPCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) {.nimcall.}
    DataProvider = object of RootObj
        lines: seq[string]
        callback: DPCallback

    Frame* = ref object of RootObj
        name*: string = ""
        focus*: bool
        x*: int
        y*: int
        curX*: int
        curY*: int
        page*: int
        more*: bool
        width*: int
        height*: int
        lines*: seq[string]
        frame*: int = 1
        bg*: uint32
        fg*: uint32
        ch*: string
        style*: uint16
        provider*: DataProvider
        #provider*: DPCallback

method offset(f: var Frame, x: int, y: int): (int, int) =
    result = (f.x + x + f.frame, f.y + y + f.frame)

method handleEvent(f: var Frame) =
    if not f.focus: return
    if texalotEvent of MouseEvent:
        removeArea(0, 0, 80, 1)
        var mouseEvent = MouseEvent(texalotEvent)
        case mouseEvent.key:
        of EVENT_MOUSE_MOVE:
            #drawText("- Mouse moving - x:" & $mouseEvent.x & " y:" & $mouseEvent.y, 0, 0, FG_COLOR_WHITE, BG_COLOR_DEFAULT)
            discard
        of EVENT_MOUSE_LEFT:
            #drawText("- Mouse clicked - x:" & $mouseEvent.x & " y:" & $mouseEvent.y, 0, 0, FG_COLOR_WHITE, BG_COLOR_DEFAULT)
            let mousey = mouseEvent.y - 2
            if mousey >= 0 and mousey < f.lines.len: currentSelected = f.lines[mousey]
            f.curY = mousey
        of EVENT_MOUSE_WHEEL_UP:
            dec f.curY
            if f.curY < 0 and f.page > 0:
                dec f.page
                if f.page < 0: f.page = 0
                f.curY = f.height - 2
            elif f.curY < 0: f.curY = 0
        of EVENT_MOUSE_WHEEL_DOWN:
            inc f.curY
            if f.curY >= f.height - 1 and f.more:
                f.curY = 0
                inc f.page
            if f.curY >= f.lines.len:
                f.curY = f.lines.len - 1
        else:
            discard 

    elif texalotEvent of KeyEvent:
        var keyEvent = KeyEvent(texalotEvent)
        case keyEvent.key:
        of EVENT_KEY_PGUP:
            dec f.page
            if f.page < 0: f.page = 0
        of EVENT_KEY_PGDN:
            inc f.page
        of EVENT_KEY_ARROW_DOWN:
            inc f.curY
            if f.curY >= f.height - 1 and f.more:
                f.curY = 0
                inc f.page
            if f.curY >= f.lines.len:
                f.curY = f.lines.len - 1
        of EVENT_KEY_ARROW_UP:
            dec f.curY
            if f.curY < 0 and f.page > 0:
                dec f.page
                if f.page < 0: f.page = 0
                f.curY = f.height - 2
            elif f.curY < 0: f.curY = 0
        of EVENT_KEY_ENTER:
            currentSelected = f.lines[f.curY]
        else: 
            discard

# Draw text in window
method draw(self: var Frame, txt: string, x: int, y: int, bg: uint32 = 0, fg: uint32 = 0, style: uint16 = 0) =
    let (xx,yy) = self.offset(x, y)
    var sbg, sfg: uint32
    var sst: uint16
    if bg == 0: sbg = self.bg
    if fg == 0: sfg = self.fg
    if style == 0: sst = self.style
    if y == self.curY and self.focus:
        sbg = BG_COLOR_RED
        sfg = FG_COLOR_WHITE
    drawText(txt, xx, yy, sfg, sbg, sst)

# https://en.wikipedia.org/wiki/Box-drawing_characters
method drawFrame*(self: var Frame) =
    let x1 = self.x
    let x2 = self.x + self.width
    let y1 = self.y
    let y2 = self.y + self.height
    drawRectangle(x1, y1, x2, y2, self.bg, self.fg, self.ch, self.style) 
    let width = x2 - x1 - 2
    let height = y2 - y1
    drawRectangle(x1+1, y1+1, x2-1, y2-1, self.bg, self.fg, self.ch, self.style)
    # draw frame around
    let fg = if self.focus: FG_COLOR_RED_BRIGHT else: self.fg
    let bg = self.bg
    if self.frame > 0:
        if self.name.len > 0:
            drawText("\u2554 " & self.name & " " & repeat("\u2550", width - self.name.len - 2) & "\u2557", x1, y1, fg, bg, self.style)
        else:
            drawText("\u2554" & repeat("\u2550", width) & "\u2557", x1, y1, fg, bg, self.style)            
        drawText("\u255a" & repeat("\u2550", width) & "\u255d", x1, y1 + height, fg, bg, self.style)
        #drawText("\u250F" & repeat("\u2501", width) & "\u2513", x1, y1, fg, bg, self.style)
        #drawText("\u2517" & repeat("\u2501", width) & "\u251b", x1, y1 + height, fg, bg, self.style)
    for y in y1 + 1..y1 + height - self.frame:
        if self.frame > 0:
            drawText("\u2551", x1, y, fg, bg, self.style)
            drawText("\u2551", x2-1, y, fg, bg, self.style)
    
    # Do we have a DataProvider, ask and paint
    (self.lines, self.more) = self.provider.callback(self.provider, self.page, self.height-1)
    if self.lines.len == 0 and self.page > 0: dec self.page
    for line, txt in self.lines:
        let lineLength = (min(txt.len, self.width-2)) - 1
        self.draw(txt[0..lineLength], 0, line)

    # Draw arrows
    if self.page > 0:
        self.draw("\u2191", self.width-4, height-1)
    if self.more: 
        self.draw("\u2193", self.width-3, height-1)

    self.handleEvent()

proc walk(path: string): seq[string] =
    for kind, path in walkDir(path):
        case kind:
        of pcFile, pcLinkToFile:
            result.add(path)
        of pcDir, pcLinkToDir:
            result.add(walk(path))

proc onExit() {.noconv.} =
    deinitTextalot()
    quit(0)

func getProviderData(page: int, pagesize: int, data: seq[string]): (seq[string], bool) =
    var lower = page*pagesize
    if lower >= data.len: return
    var upper = lower + pagesize
    if upper > data.len: upper = data.len
    elif data.len < upper: upper = data.len
    let more = upper < data.len
    return (data[lower..<upper], more)

# ----------- main -------

setControlCHook(onExit)
initTextalot()

const dirProviderCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) =
    provider.lines = walk(".")
    getProviderData(page, pagesize, provider.lines)

const fileProviderCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) =
    if currentSelected.len > 0 and currentSelected != lastSelected:
        if fileExists(currentSelected):
            provider.lines = split(readFile(currentSelected), "\n")
            lastSelected = currentSelected
    return getProviderData(page, pagesize, provider.lines)

const stringProviderCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) =
    return getProviderData(page, pagesize, @["Hello", "World", "aaaaa", "bbbbbb", "ccccccc", "dddddddd", "eeeeeee", "ffffff", "Hello2", "World2", "2aaaaa", "2bbbbbb", "2ccccccc", "2dddddddd", "2eeeeeee", "2ffffff"])

const globalsProviderCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) =
    drawText(fmt"event:{eventCount} globalsCount:{globalsCount}", 0, 0)
    if provider.lines.len == 0:
        inc globalsCount
        provider.lines = getGlobals()
    return getProviderData(page, pagesize, provider.lines)

const globalProviderCallback = proc(provider: var DataProvider, page: int, pagesize: int): (seq[string], bool) =
    var items: seq[string]
    if currentSelected.len > 0 and currentSelected != lastSelected:
        for (k, v) in queryItr @currentSelected.kv:
            items.add(k & "=" & v)
    return getProviderData(page, pagesize, items)

var dirProvider = DataProvider(callback: dirProviderCallback)
var fileProvider = DataProvider(callback: fileProviderCallback)
var stringProvider = DataProvider(callback: stringProviderCallback)
var globalsProvider = DataProvider(callback: globalsProviderCallback)
var globalProvider = DataProvider(callback: globalProviderCallback)

let width = getTerminalWidth()
let height = getTerminalHeight()

var f1 = Frame(name:"Globals", x:0, y:1, height:10, width:30, bg:BG_COLOR_BLUE, fg:FG_COLOR_WHITE, provider: globalsProvider)
var f2 = Frame(name:"", x:30, y:1, height:10, width:width-30, bg:BG_COLOR_WHITE_BRIGHT, provider: globalProvider)
var f3 = Frame(name:"f3", x:0, y:12, height:5, width:width, bg:BG_COLOR_WHITE_BRIGHT, provider: stringProvider)

var windows: seq[Frame]
windows.add(f1)
windows.add(f2)
windows.add(f3)
f1.focus = true

proc paintWindows() =
    for win in windows.mitems():
        if not win.focus: win.drawFrame()
    for win in windows.mitems():
        if win.focus: win.drawFrame()

while true:
    inc eventCount
    paintWindows()
    updateTextalot()

    # Handle screen resize
    if texalotEvent of ResizeEvent:
        let width = getTerminalWidth()
        let height = getTerminalHeight()
        windows[1].width = width - 30
        windows[2].width = width

    # Handle Focus
    if texalotEvent of KeyEvent:
        var keyEvent = KeyEvent(texalotEvent)
        case keyEvent.key
        of EVENT_KEY_ESC:
            onExit()
        of EVENT_KEY_TAB:
            windows[currentFocus].focus = false
            inc currentFocus
            if currentFocus >= windows.len:
                windows[^1].focus = false
                currentFocus = 0
            windows[currentFocus].focus = true
        of EVENT_KEY_ENTER:
            f2.curX = 0
            f2.curY = 0
            f2.page = 0
            #removeArea(f2.x, f2.y, f2.x + f2.width, f2.y + f2.height)
        else:
            discard

    os.sleep(20) 
