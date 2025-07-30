/// C declarations for the X11 windowing system
module glfw3.x11_header;

version(linux):

/*
I started out using https://github.com/nomad-software/x11/, but I had some problems with it:
- many headers GLFW needs were missing
- missing @nogc / nothrow annotations
- I prefer to not have a dub dependency
So I fixed the existing files, added the missing files, concatenated the files, stripped comments,
and let Dustmite reduce it a bit (going from 20K lines to 5K), resulting in this single file.
Still a bit of a mess, but good enough for compiling GLFW in its current state.
*/
import core.stdc.config: c_ulong, c_long;
import core.stdc.stddef: wchar_t;
import core.stdc.stdio: fopen;
import core.stdc.stdlib: free, malloc, calloc, realloc;

extern(C):
nothrow:

const uint X_PROTOCOL = 11;
const uint X_PROTOCOL_REVISION = 0;
alias XID = c_ulong;
alias Mask = XID;
alias Atom = XID;
alias VisualID = XID;
alias Time = XID;
alias Window = XID;
alias Drawable = XID;
alias Font = XID;
alias Pixmap = XID;
alias Cursor = XID;
alias Colormap = XID;
alias GContext = XID;
alias KeySym = XID;
alias KeyCode = ubyte;
const XID None = 0;
const XID ParentRelative = 1;
const XID CopyFromParent = 0;
const Window PointerWindow = 0;
const Window InputFocus = 1;
const Window PointerRoot = 1;
const Atom AnyPropertyType = 0;
const KeyCode AnyKey = 0;
enum c_long AnyButton = 0;
const XID AllTemporary = 0;
const Time CurrentTime = 0;
const KeySym NoSymbol = 0;

enum {
    NoEventMask = 0,
    KeyPressMask = 1 << 0,
    KeyReleaseMask = 1 << 1,
    ButtonPressMask = 1 << 2,
    ButtonReleaseMask = 1 << 3,
    EnterWindowMask = 1 << 4,
    LeaveWindowMask = 1 << 5,
    PointerMotionMask = 1 << 6,
    PointerMotionHintMask = 1 << 7,
    Button1MotionMask = 1 << 8,
    Button2MotionMask = 1 << 9,
    Button3MotionMask = 1 << 10,
    Button4MotionMask = 1 << 11,
    Button5MotionMask = 1 << 12,
    ButtonMotionMask = 1 << 13,
    KeymapStateMask = 1 << 14,
    ExposureMask = 1 << 15,
    VisibilityChangeMask = 1 << 16,
    StructureNotifyMask = 1 << 17,
    ResizeRedirectMask = 1 << 18,
    SubstructureNotifyMask = 1 << 19,
    SubstructureRedirectMask = 1 << 20,
    FocusChangeMask = 1 << 21,
    PropertyChangeMask = 1 << 22,
    ColormapChangeMask = 1 << 23,
    OwnerGrabButtonMask = 1 << 24
}
enum {
    KeyPress = 2,
    KeyRelease = 3,
    ButtonPress = 4,
    ButtonRelease = 5,
    MotionNotify = 6,
    EnterNotify = 7,
    LeaveNotify = 8,
    FocusIn = 9,
    FocusOut = 10,
    KeymapNotify = 11,
    Expose = 12,
    GraphicsExpose = 13,
    NoExpose = 14,
    VisibilityNotify = 15,
    CreateNotify = 16,
    DestroyNotify = 17,
    UnmapNotify = 18,
    MapNotify = 19,
    MapRequest = 20,
    ReparentNotify = 21,
    ConfigureNotify = 22,
    ConfigureRequest = 23,
    GravityNotify = 24,
    ResizeRequest = 25,
    CirculateNotify = 26,
    CirculateRequest = 27,
    PropertyNotify = 28,
    SelectionClear = 29,
    SelectionRequest = 30,
    SelectionNotify = 31,
    ColormapNotify = 32,
    ClientMessage = 33,
    MappingNotify = 34,
    GenericEvent = 35,
    LASTEvent = 36
}
enum {
    ShiftMask = 1 << 0,
    LockMask = 1 << 1,
    ControlMask = 1 << 2,
    Mod1Mask = 1 << 3,
    Mod2Mask = 1 << 4,
    Mod3Mask = 1 << 5,
    Mod4Mask = 1 << 6,
    Mod5Mask = 1 << 7
}
enum {
    ShiftMapIndex = 0,
    LockMapIndex = 1,
    ControlMapIndex = 2,
    Mod1MapIndex = 3,
    Mod2MapIndex = 4,
    Mod3MapIndex = 5,
    Mod4MapIndex = 6,
    Mod5MapIndex = 7
}
enum {
    Button1Mask = 1 << 8,
    Button2Mask = 1 << 9,
    Button3Mask = 1 << 10,
    Button4Mask = 1 << 11,
    Button5Mask = 1 << 12,
    AnyModifier = 1 << 15
}
enum {
    ShiftMap = 1 << 0,
    LockMap = 1 << 1,
    ControlMap = 1 << 2,
    Mod1Map = 1 << 3,
    Mod2Map = 1 << 4,
    Mod3Map = 1 << 5,
    Mod4Map = 1 << 6,
    Mod5Map = 1 << 7,
}
enum {
    Button1 = 1,
    Button2 = 2,
    Button3 = 3,
    Button4 = 4,
    Button5 = 5
}
enum {
    NotifyNormal = 0,
    NotifyGrab = 1,
    NotifyUngrab = 2,
    NotifyWhileGrabbed = 3
}
enum int NotifyHint = 1;
enum {
    NotifyAncestor = 0,
    NotifyVirtual = 1,
    NotifyInferior = 2,
    NotifyNonlinear = 3,
    NotifyNonlinearVirtual = 4,
    NotifyPointer = 5,
    NotifyPointerRoot = 6,
    NotifyDetailNone = 7
}
enum {
    VisibilityUnobscured = 0,
    VisibilityPartiallyObscured = 1,
    VisibilityFullyObscured = 2
}
enum {
    PlaceOnTop = 0,
    PlaceOnBottom = 1
}
enum {
    FamilyInternet = 0,
    FamilyDECnet = 1,
    FamilyChaos = 2,
    FamilyServerInterpreted = 5,
    FamilyInternet6 = 6
}
enum {
    PropertyNewValue = 0,
    PropertyDelete = 1
}
enum {
    ColormapUninstalled = 0,
    ColormapInstalled = 1
}
enum {
    GrabModeSync = 0,
    GrabModeAsync = 1
}
enum {
    GrabSuccess = 0,
    AlreadyGrabbed = 1,
    GrabInvalidTime = 2,
    GrabNotViewable = 3,
    GrabFrozen = 4
}
enum {
    AsyncPointer = 0,
    SyncPointer = 1,
    ReplayPointer = 2,
    AsyncKeyboard = 3,
    SyncKeyboard = 4,
    ReplayKeyboard = 5,
    AsyncBoth = 6,
    SyncBoth = 7
}
enum {
    RevertToNone = None,
    RevertToPointerRoot = PointerRoot,
    RevertToParent = 2
}
enum XErrorCode : int {
    Success = 0,
    BadRequest = 1,
    BadValue = 2,
    BadWindow = 3,
    BadPixmap = 4,
    BadAtom = 5,
    BadCursor = 6,
    BadFont = 7,
    BadMatch = 8,
    BadDrawable = 9,
    BadAccess = 10,
    BadAlloc = 11,
    BadColor = 12,
    BadGC = 13,
    BadIDChoice = 14,
    BadName = 15,
    BadLength = 16,
    BadImplementation = 17,
    FirstExtensionError = 128,
    LastExtensionError = 255
}

enum {
    InputOutput = 1,
    InputOnly = 2
}
enum {
    CWBackPixmap = 1 << 0,
    CWBackPixel = 1 << 1,
    CWBorderPixmap = 1 << 2,
    CWBorderPixel = 1 << 3,
    CWBitGravity = 1 << 4,
    CWWinGravity = 1 << 5,
    CWBackingStore = 1 << 6,
    CWBackingPlanes = 1 << 7,
    CWBackingPixel = 1 << 8,
    CWOverrideRedirect = 1 << 9,
    CWSaveUnder = 1 << 10,
    CWEventMask = 1 << 11,
    CWDontPropagate = 1 << 12,
    CWColormap = 1 << 13,
    CWCursor = 1 << 14
}
enum {
    CWX = 1 << 0,
    CWY = 1 << 1,
    CWWidth = 1 << 2,
    CWHeight = 1 << 3,
    CWBorderWidth = 1 << 4,
    CWSibling = 1 << 5,
    CWStackMode = 1 << 6
}
enum {
    ForgetGravity = 0,
    NorthWestGravity = 1,
    NorthGravity = 2,
    NorthEastGravity = 3,
    WestGravity = 4,
    CenterGravity = 5,
    EastGravity = 6,
    SouthWestGravity = 7,
    SouthGravity = 8,
    SouthEastGravity = 9,
    StaticGravity = 10
}
const uint UnmapGravity = 0;
enum {
    NotUseful = 0,
    WhenMapped = 1,
    Always = 2
}
enum {
    IsUnmapped = 0,
    IsUnviewable = 1,
    IsViewable = 2
}
enum {
    SetModeInsert = 0,
    SetModeDelete = 1
}
enum CloseDownMode : int {
    DestroyAll = 0,
    RetainPermanent = 1,
    RetainTemporary = 2
}
enum {
    Above = 0,
    Below = 1,
    TopIf = 2,
    BottomIf = 3,
    Opposite = 4
}
enum {
    RaiseLowest = 0,
    LowerHighest = 1
}
enum {
    PropModeReplace = 0,
    PropModePrepend = 1,
    PropModeAppend = 2
}
enum {
    ArcChord = 0,
    ArcPieSlice = 1
}
enum {
    GCFunction = 1 << 0,
    GCPlaneMask = 1 << 1,
    GCForeground = 1 << 2,
    GCBackground = 1 << 3,
    GCLineWidth = 1 << 4,
    GCLineStyle = 1 << 5,
    GCCapStyle = 1 << 6,
    GCJoinStyle = 1 << 7,
    GCFillStyle = 1 << 8,
    GCFillRule = 1 << 9,
    GCTile = 1 << 10,
    GCStipple = 1 << 11,
    GCTileStipXOrigin = 1 << 12,
    GCTileStipYOrigin = 1 << 13,
    GCFont = 1 << 14,
    GCSubwindowMode = 1 << 15,
    GCGraphicsExposures = 1 << 16,
    GCClipXOrigin = 1 << 17,
    GCClipYOrigin = 1 << 18,
    GCClipMask = 1 << 19,
    GCDashOffset = 1 << 20,
    GCDashList = 1 << 21,
    GCArcMode = 1 << 22,
}
const uint GCLastBit = 22;
enum {
    FontLeftToRight = 0,
    FontRightToLeft = 1,
    FontChange = 255
}
enum {
    XYBitmap = 0,
    XYPixmap = 1,
    ZPixmap = 2
}
enum {
    AllocNone = 0,
    AllocAll = 1
}
enum {
    DoRed = 1 << 0,
    DoGreen = 1 << 1,
    DoBlue = 1 << 2
}
enum {
    CursorShape = 0,
    TileShape = 1,
    StippleShape = 2
}
enum {
    AutoRepeatModeOff = 0,
    AutoRepeatModeOn = 1,
    AutoRepeatModeDefault = 2
}
enum {
    LedModeOff = 0,
    LedModeOn = 1
}
enum {
    KBKeyClickPercent = 1 << 0,
    KBBellPercent = 1 << 1,
    KBBellPitch = 1 << 2,
    KBBellDuration = 1 << 3,
    KBLed = 1 << 4,
    KBLedMode = 1 << 5,
    KBKey = 1 << 6,
    KBAutoRepeatMode = 1 << 7
}
enum {
    MappingSuccess = 0,
    MappingBusy = 1,
    MappingFailed = 2
}
enum {
    MappingModifier = 0,
    MappingKeyboard = 1,
    MappingPointer = 2
}
enum {
    DontPreferBlanking = 0,
    PreferBlanking = 1,
    DefaultBlanking = 2
}
enum {
    DisableScreenSaver = 0,
    DisableScreenInterval = 0
}
enum {
    DontAllowExposures = 0,
    AllowExposures = 1,
    DefaultExposures = 2
}
enum {
    ScreenSaverReset = 0,
    ScreenSaverActive = 1
}
enum {
    HostInsert = 0,
    HostDelete = 1
}
enum {
    EnableAccess = 1,
    DisableAccess = 0
}
enum {
    StaticGray = 0,
    GrayScale = 1,
    StaticColor = 2,
    PseudoColor = 3,
    TrueColor = 4,
    DirectColor = 5
}
enum {
    LSBFirst = 0,
    MSBFirst = 1
}
struct _XkbAnyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    uint device;
}
alias _XkbAnyEvent XkbAnyEvent;
struct _XkbNewKeyboardNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    int old_device;
    int min_key_code;
    int max_key_code;
    int old_min_key_code;
    int old_max_key_code;
    uint changed;
    char req_major = 0;
    char req_minor = 0;
}
alias _XkbNewKeyboardNotify XkbNewKeyboardNotifyEvent;
struct _XkbMapNotifyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed;
    uint flags;
    int first_type;
    int num_types;
    KeyCode min_key_code;
    KeyCode max_key_code;
    KeyCode first_key_sym;
    KeyCode first_key_act;
    KeyCode first_key_behavior;
    KeyCode first_key_explicit;
    KeyCode first_modmap_key;
    KeyCode first_vmodmap_key;
    int num_key_syms;
    int num_key_acts;
    int num_key_behaviors;
    int num_key_explicit;
    int num_modmap_keys;
    int num_vmodmap_keys;
    uint vmods;
}
alias _XkbMapNotifyEvent XkbMapNotifyEvent;
struct _XkbStateNotifyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed;
    int group;
    int base_group;
    int latched_group;
    int locked_group;
    uint mods;
    uint base_mods;
    uint latched_mods;
    uint locked_mods;
    int compat_state;
    ubyte grab_mods;
    ubyte compat_grab_mods;
    ubyte lookup_mods;
    ubyte compat_lookup_mods;
    int ptr_buttons;
    KeyCode keycode;
    char event_type = 0;
    char req_major = 0;
    char req_minor = 0;
}
alias _XkbStateNotifyEvent XkbStateNotifyEvent;
struct _XkbControlsNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed_ctrls;
    uint enabled_ctrls;
    uint enabled_ctrl_changes;
    int num_groups;
    KeyCode keycode;
    char event_type = 0;
    char req_major = 0;
    char req_minor = 0;
}
alias _XkbControlsNotify XkbControlsNotifyEvent;
struct _XkbIndicatorNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed;
    uint state;
}
alias _XkbIndicatorNotify XkbIndicatorNotifyEvent;
struct _XkbNamesNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed;
    int first_type;
    int num_types;
    int first_lvl;
    int num_lvls;
    int num_aliases;
    int num_radio_groups;
    uint changed_vmods;
    uint changed_groups;
    uint changed_indicators;
    int first_key;
    int num_keys;
}
alias _XkbNamesNotify XkbNamesNotifyEvent;
struct _XkbCompatMapNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint changed_groups;
    int first_si;
    int num_si;
    int num_total_si;
}
alias _XkbCompatMapNotify XkbCompatMapNotifyEvent;
struct _XkbBellNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    int percent;
    int pitch;
    int duration;
    int bell_class;
    int bell_id;
    Atom name;
    Window window;
    Bool event_only;
}
alias _XkbBellNotify XkbBellNotifyEvent;
struct _XkbActionMessage {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    KeyCode keycode;
    Bool press;
    Bool key_event_follows;
    int group;
    uint mods;
    char[XkbActionMessageLength + 1] message = '\0';
}
alias _XkbActionMessage XkbActionMessageEvent;
struct _XkbAccessXNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    int detail;
    int keycode;
    int sk_delay;
    int debounce_delay;
}
alias _XkbAccessXNotify XkbAccessXNotifyEvent;
struct _XkbExtensionDeviceNotify {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Time time;
    int xkb_type;
    int device;
    uint reason;
    uint supported;
    uint unsupported;
    int first_btn;
    int num_btns;
    uint leds_defined;
    uint led_state;
    int led_class;
    int led_id;
}
alias _XkbExtensionDeviceNotify XkbExtensionDeviceNotifyEvent;
union _XkbEvent {
    int type;
    XkbAnyEvent any;
    XkbNewKeyboardNotifyEvent new_kbd;
    XkbMapNotifyEvent map;
    XkbStateNotifyEvent state;
    XkbControlsNotifyEvent ctrls;
    XkbIndicatorNotifyEvent indicators;
    XkbNamesNotifyEvent names;
    XkbCompatMapNotifyEvent compat;
    XkbBellNotifyEvent bell;
    XkbActionMessageEvent message;
    XkbAccessXNotifyEvent accessx;
    XkbExtensionDeviceNotifyEvent device;
    XEvent core;
}
alias _XkbEvent XkbEvent;
enum XkbLC_AllComposeControls = 0xc0000000;
enum XkbLC_AllControls = 0xc000001f;
Bool XkbIgnoreExtension(Bool);
Display* XkbOpenDisplay(char*, int*, int*, int*, int*, int*);
Bool XkbQueryExtension(Display*, int*, int*, int*, int*, int*);
Bool XkbUseExtension(Display*, int*, int*);
Bool XkbLibraryVersion(int*, int*);
uint XkbSetXlibControls(Display*, uint, uint);
uint XkbGetXlibControls(Display*);
uint XkbXlibControlsImplemented();
alias Atom function(Display*, const(char)*, Bool) XkbInternAtomFunc;
alias char* function(Display*, Atom) XkbGetAtomNameFunc;
void XkbSetAtomFuncs(XkbInternAtomFunc, XkbGetAtomNameFunc);
KeySym XkbKeycodeToKeysym(Display*, KeyCode, int, int);
uint XkbKeysymToModifiers(Display*, KeySym);
Bool XkbLookupKeySym(Display*, KeyCode, uint, uint*, KeySym*);
Bool XkbDeviceBellEvent(Display*, Window, int, int, int, int, Atom);
Bool XkbBell(Display*, Window, int, Atom);
Bool XkbForceBell(Display*, int);
Bool XkbBellEvent(Display*, Window, int, Atom);
Bool XkbSelectEvents(Display*, uint, uint, uint);
Bool XkbSelectEventDetails(Display*, uint, uint, c_ulong, c_ulong);
void XkbNoteMapChanges(XkbMapChangesPtr, XkbMapNotifyEvent*, uint);
void XkbNoteNameChanges(XkbNameChangesPtr, XkbNamesNotifyEvent*, uint);
Bool XkbSetServerInternalMods(Display*, uint, uint, uint, uint, uint);
Bool XkbSetIgnoreLockMods(Display*, uint, uint, uint, uint, uint);
Bool XkbVirtualModsToReal(XkbDescPtr, uint, uint*);
Bool XkbComputeEffectiveMap(XkbDescPtr, XkbKeyTypePtr, ubyte*);
Status XkbInitCanonicalKeyTypes(XkbDescPtr, uint, int);
XkbDescPtr XkbAllocKeyboard();
void XkbFreeKeyboard(XkbDescPtr, uint, Bool);
Status XkbAllocClientMap(XkbDescPtr, uint, uint);
Status XkbAllocServerMap(XkbDescPtr, uint, uint);
void XkbFreeClientMap(XkbDescPtr, uint, Bool);
void XkbFreeServerMap(XkbDescPtr, uint, Bool);
XkbKeyTypePtr XkbAddKeyType(XkbDescPtr, Atom, int, Bool, int);
Status XkbAllocIndicatorMaps(XkbDescPtr);
void XkbFreeIndicatorMaps(XkbDescPtr);
XkbDescPtr XkbGetMap(Display*, uint, uint);
Status XkbGetUpdatedMap(Display*, uint, XkbDescPtr);
Status XkbAllocCompatMap(XkbDescPtr, uint, uint);
void XkbFreeCompatMap(XkbDescPtr, uint, Bool);
Status XkbGetCompatMap(Display*, uint, XkbDescPtr);
Bool XkbSetCompatMap(Display*, uint, XkbDescPtr, Bool);
XkbSymInterpretPtr XkbAddSymInterpret(XkbDescPtr, XkbSymInterpretPtr, Bool, XkbChangesPtr);
Status XkbAllocNames(XkbDescPtr, uint, int, int);
Status XkbGetNames(Display*, uint, XkbDescPtr);
Bool XkbSetNames(Display*, uint, uint, uint, XkbDescPtr);
Bool XkbChangeNames(Display*, XkbDescPtr, XkbNameChangesPtr);
void XkbFreeNames(XkbDescPtr, uint, Bool);
Status XkbGetState(Display*, uint, XkbStatePtr);
Bool XkbSetMap(Display*, uint, XkbDescPtr);
Bool XkbChangeMap(Display*, XkbDescPtr, XkbMapChangesPtr);
Bool XkbSetDetectableAutoRepeat(Display*, Bool, Bool*);
Bool XkbGetDetectableAutoRepeat(Display*, Bool*);
Bool XkbSetDebuggingFlags(Display*, uint, uint, char*, uint, uint, uint*, uint*);
Bool XkbApplyVirtualModChanges(XkbDescPtr, uint, XkbChangesPtr);
Bool XkbUpdateActionVirtualMods(XkbDescPtr, XkbAction*, uint);
void XkbUpdateKeyTypeVirtualMods(XkbDescPtr, XkbKeyTypePtr, uint, XkbChangesPtr);
enum XA_PRIMARY = 1;
enum XA_SECONDARY = 2;
enum XA_ARC = 3;
enum XA_ATOM = 4;
enum XA_BITMAP = 5;
enum XA_CARDINAL = 6;
enum XA_COLORMAP = 7;
enum XA_CURSOR = 8;
enum XA_CUT_BUFFER0 = 9;
enum XA_CUT_BUFFER1 = 10;
enum XA_CUT_BUFFER2 = 11;
enum XA_CUT_BUFFER3 = 12;
enum XA_RGB_GREEN_MAP = 29;
enum XA_RGB_RED_MAP = 30;
enum XA_STRING = 31;
enum XA_VISUALID = 32;
enum XA_WINDOW = 33;
enum XA_WM_COMMAND = 34;
enum XA_WM_HINTS = 35;
enum XA_WM_CLIENT_MACHINE = 36;
alias int XcursorBool;
alias uint XcursorUInt;
alias XcursorUInt XcursorDim;
alias XcursorUInt XcursorPixel;
enum XcursorTrue = 1;
enum XcursorFalse = 0;
enum XCURSOR_MAGIC = 0x72756358;
enum XCURSOR_FILE_TOC_LEN = (3 * 4);
struct _XcursorFileToc {
    XcursorUInt type;
    XcursorUInt subtype;
    XcursorUInt position;
}
alias _XcursorFileToc XcursorFileToc;
struct _XcursorFileHeader {
    XcursorUInt magic;
    XcursorUInt header;
    XcursorUInt version_;
    XcursorUInt ntoc;
    XcursorFileToc* tocs;
}
alias _XcursorFileHeader XcursorFileHeader;
enum XCURSOR_CHUNK_HEADER_LEN = (4 * 4);
struct _XcursorChunkHeader {
    XcursorUInt header;
    XcursorUInt type;
    XcursorUInt subtype;
    XcursorUInt version_;
}
alias _XcursorChunkHeader XcursorChunkHeader;
enum XCURSOR_COMMENT_TYPE = 0xfffe0001;
enum XCURSOR_COMMENT_VERSION = 1;
enum XCURSOR_COMMENT_HEADER_LEN = (XCURSOR_CHUNK_HEADER_LEN + (1 * 4));
enum XCURSOR_COMMENT_COPYRIGHT = 1;
enum XCURSOR_COMMENT_LICENSE = 2;
enum XCURSOR_COMMENT_OTHER = 3;
enum XCURSOR_COMMENT_MAX_LEN = 0x100000;
struct _XcursorComment {
    XcursorUInt version_;
    XcursorUInt comment_type;
    char* comment;
}
alias _XcursorComment XcursorComment;
enum XCURSOR_IMAGE_TYPE = 0xfffd0002;
enum XCURSOR_IMAGE_VERSION = 1;
enum XCURSOR_IMAGE_HEADER_LEN = (XCURSOR_CHUNK_HEADER_LEN + (5 * 4));
enum XCURSOR_IMAGE_MAX_SIZE = 0x7fff
 ;
struct _XcursorImage {
    XcursorUInt version_;
    XcursorDim size;
    XcursorDim width;
    XcursorDim height;
    XcursorDim xhot;
    XcursorDim yhot;
    XcursorUInt delay;
    XcursorPixel* pixels;
}
alias _XcursorImage XcursorImage;
struct _XcursorImages {
    int nimage;
    XcursorImage** images;
    char* name;
}
enum int XlibSpecificationRelease = 6;
enum int X_HAVE_UTF8_STRING = 1;
alias char* XPointer;
alias int Status;
alias int Bool;
enum {
    False,
    True
}
alias int QueueMode;
enum {
    QueuedAlready,
    QueuedAfterReading,
    QueuedAfterFlush
}
int ConnectionNumber(Display* dpy) {
    return dpy.fd;
}
Window RootWindow(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).root;
}
int DefaultScreen(Display* dpy) {
    return dpy.default_screen;
}
Window DefaultRootWindow(Display* dpy) {
    return ScreenOfDisplay(dpy, DefaultScreen(dpy)).root;
}
Visual* DefaultVisual(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).root_visual;
}
GC DefaultGC(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).default_gc;
}
c_ulong BlackPixel(Display* dpy, int scr) {
    return cast(c_ulong) ScreenOfDisplay(dpy, scr).black_pixel;
}
c_ulong WhitePixel(Display* dpy, int scr) {
    return cast(c_ulong) ScreenOfDisplay(dpy, scr).white_pixel;
}
c_ulong AllPlanes() {
    return 0xFFFFFFFF;
}
int QLength(Display* dpy) {
    return dpy.qlen;
}
int DisplayWidth(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).width;
}
int DisplayHeight(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).height;
}
int DisplayWidthMM(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).mwidth;
}
int DisplayHeightMM(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).mheight;
}
int DisplayPlanes(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).root_depth;
}
int DisplayCells(Display* dpy, int scr) {
    return DefaultVisual(dpy, scr).map_entries;
}
int ScreenCount(Display* dpy) {
    return dpy.nscreens;
}
int ProtocolVersion(Display* dpy) {
    return dpy.proto_major_version;
}
int ProtocolRevision(Display* dpy) {
    return dpy.proto_minor_version;
}
int VendorRelease(Display* dpy) {
    return dpy.release;
}
char* DisplayString(Display* dpy) {
    return dpy.display_name;
}
int DefaultDepth(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).root_depth;
}
Colormap DefaultColormap(Display* dpy, int scr) {
    return ScreenOfDisplay(dpy, scr).cmap;
}
int BitmapUnit(Display* dpy) {
    return dpy.bitmap_unit;
}
int BitmapBitOrder(Display* dpy) {
    return dpy.bitmap_bit_order;
}
int BitmapPad(Display* dpy) {
    return dpy.bitmap_pad;
}
uint NextRequest(Display* dpy) {
    return cast(uint) dpy.request + 1;
}
uint LastKnownRequestProcessed(Display* dpy) {
    return cast(uint) dpy.last_request_read;
}
Screen* ScreenOfDisplay(Display* dpy, int scr) {
    return &dpy.screens[scr];
}
Screen* DefaultScreenOfDisplay(Display* dpy) {
    return ScreenOfDisplay(dpy, DefaultScreen(dpy));
}
Display* DisplayOfScreen(Screen* s) {
    return s.display;
}
int DoesBackingStore(Screen* s) {
    return s.backing_store;
}
c_long EventMaskOfScreen(Screen* s) {
    return s.root_input_mask;
}
struct XExtData {
    int number;
    XExtData* next;
    extern(C) nothrow int function(XExtData* extension) free_private;
    XPointer private_data;
}
struct XExtCodes {
    int extension;
    int major_opcode;
    int first_event;
    int first_error;
}
struct XPixmapFormatValues {
    int depth;
    int bits_per_pixel;
    int scanline_pad;
}
struct XGCValues {
    int function_;
    c_ulong plane_mask;
    c_ulong foreground;
    c_ulong background;
    int line_width;
    int line_style;
    int cap_style;
    int join_style;
    int fill_style;
    int fill_rule;
    int arc_mode;
    Pixmap tile;
    Pixmap stipple;
    int ts_x_origin;
    int ts_y_origin;
    Font font;
    int subwindow_mode;
    Bool graphics_exposures;
    int clip_x_origin;
    int clip_y_origin;
    Pixmap clip_mask;
    int dash_offset;
    char dashes = 0;
}
alias _XGC* GC;
struct Visual {
    XExtData* ext_data;
    VisualID visualid;
    int c_class;
    c_ulong red_mask, green_mask, blue_mask;
    int bits_per_rgb;
    int map_entries;
}
struct Depth {
    int depth;
    int nvisuals;
    Visual* visuals;
}
alias Display XDisplay;
struct Screen {
    XExtData* ext_data;
    XDisplay* display;
    Window root;
    int width, height;
    int mwidth, mheight;
    int ndepths;
    Depth* depths;
    int root_depth;
    Visual* root_visual;
    GC default_gc;
    Colormap cmap;
    c_ulong white_pixel;
    c_ulong black_pixel;
    int max_maps, min_maps;
    int backing_store;
    Bool save_unders;
    c_long root_input_mask;
}
struct ScreenFormat {
    XExtData* ext_data;
    int depth;
    int bits_per_pixel;
    int scanline_pad;
}
struct XSetWindowAttributes {
    Pixmap background_pixmap;
    c_ulong background_pixel;
    Pixmap border_pixmap;
    c_ulong border_pixel;
    int bit_gravity;
    int win_gravity;
    int backing_store;
    c_ulong backing_planes;
    c_ulong backing_pixel;
    Bool save_under;
    c_long event_mask;
    c_long do_not_propagate_mask;
    Bool override_redirect;
    Colormap colormap;
    Cursor cursor;
}
struct XWindowAttributes {
    int x, y;
    int width, height;
    int border_width;
    int depth;
    Visual* visual;
    Window root;
    int c_class;
    int bit_gravity;
    int win_gravity;
    int backing_store;
    c_ulong backing_planes;
    c_ulong backing_pixel;
    Bool save_under;
    Colormap colormap;
    Bool map_installed;
    int map_state;
    c_long all_event_masks;
    c_long your_event_mask;
    c_long do_not_propagate_mask;
    Bool override_redirect;
    Screen* screen;
}
struct XHostAddress {
    int family;
    int length;
    char* address;
}
struct XServerInterpretedAddress {
    int typelength;
    int valuelength;
    char* type;
    char* value;
}
struct XImage {
    int width, height;
    int xoffset;
    int format;
    char* data;
    int char_order;
    int bitmap_unit;
    int bitmap_bit_order;
    int bitmap_pad;
    int depth;
    int chars_per_line;
    int bits_per_pixel;
    c_ulong red_mask;
    c_ulong green_mask;
    c_ulong blue_mask;
    XPointer obdata;
    struct F {
    extern(C) nothrow:
    @nogc:
        XImage* function(XDisplay*, Visual*, uint, int, int, char*, uint, uint, int, int) create_image;
        int function(XImage*) destroy_image;
        c_ulong function(XImage*, int, int) get_pixel;
        int function(XImage*, int, int, c_ulong) put_pixel;
        XImage function(XImage*, int, int, uint, uint) sub_image;
        int function(XImage*, c_long) add_pixel;
    }
    F f;
}
struct XWindowChanges {
    int x, y;
    int width, height;
    int border_width;
    Window sibling;
    int stack_mode;
}
struct XColor {
    c_ulong pixel;
    ushort red, green, blue;
    char flags;
    char pad;
}
struct XSegment {
    short x1, y1, x2, y2;
}
struct XPoint {
    short x, y;
}
struct XRectangle {
    short x, y;
    ushort width, height;
}
struct XArc {
    short x, y;
    ushort width, height;
    short angle1, angle2;
}
struct XKeyboardControl {
    int key_click_percent;
    int bell_percent;
    int bell_pitch;
    int bell_duration;
    int led;
    int led_mode;
    int key;
    int auto_repeat_mode;
}
struct XKeyboardState {
    int key_click_percent;
    int bell_percent;
    uint bell_pitch, bell_duration;
    c_ulong led_mask;
    int global_auto_repeat;
    char[32] auto_repeats = '\0';
}
struct XTimeCoord {
    Time time;
    short x, y;
}
struct XModifierKeymap {
    int max_keypermod;
    KeyCode* modifiermap;
}
struct _XPrivate;
struct _XrmHashBucketRec;
alias _XDisplay Display;
alias _XDisplay* _XPrivDisplay;
struct XKeyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    int x, y;
    int x_root, y_root;
    uint state;
    uint keycode;
    Bool same_screen;
}
alias XKeyEvent XKeyPressedEvent;
alias XKeyEvent XKeyReleasedEvent;
struct XButtonEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    int x, y;
    int x_root, y_root;
    uint state;
    uint button;
    Bool same_screen;
}
alias XButtonEvent XButtonPressedEvent;
alias XButtonEvent XButtonReleasedEvent;
struct XMotionEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    int x, y;
    int x_root, y_root;
    uint state;
    char is_hint = 0;
    Bool same_screen;
}
alias XMotionEvent XPointerMovedEvent;
struct XCrossingEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Window root;
    Window subwindow;
    Time time;
    int x, y;
    int x_root, y_root;
    int mode;
    int detail;
    Bool same_screen;
    Bool focus;
    uint state;
}
alias XCrossingEvent XEnterWindowEvent;
alias XCrossingEvent XLeaveWindowEvent;
struct XFocusChangeEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    int mode;
    int detail;
}
alias XFocusChangeEvent XFocusInEvent;
alias XFocusChangeEvent XFocusOutEvent;
struct XKeymapEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    char[32] key_vector = '\0';
}
struct XExposeEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    int x, y;
    int width, height;
    int count;
}
struct XGraphicsExposeEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Drawable drawable;
    int x, y;
    int width, height;
    int count;
    int major_code;
    int minor_code;
}
struct XNoExposeEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Drawable drawable;
    int major_code;
    int minor_code;
}
struct XVisibilityEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    int state;
}
struct XCreateWindowEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window parent;
    Window window;
    int x, y;
    int width, height;
    int border_width;
    Bool override_redirect;
}
struct XDestroyWindowEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
}
struct XUnmapEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    Bool from_configure;
}
struct XMapEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    Bool override_redirect;
}
struct XMapRequestEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window parent;
    Window window;
}
struct XReparentEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    Window parent;
    int x, y;
    Bool override_redirect;
}
struct XConfigureEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    int x, y;
    int width, height;
    int border_width;
    Window above;
    Bool override_redirect;
}
struct XGravityEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    int x, y;
}
struct XResizeRequestEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    int width, height;
}
struct XConfigureRequestEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window parent;
    Window window;
    int x, y;
    int width, height;
    int border_width;
    Window above;
    int detail;
    c_ulong value_mask;
}
struct XCirculateEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window event;
    Window window;
    int place;
}
struct XCirculateRequestEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window parent;
    Window window;
    int place;
}
struct XPropertyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Atom atom;
    Time time;
    int state;
}
struct XSelectionClearEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Atom selection;
    Time time;
}
struct XSelectionRequestEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window owner;
    Window requestor;
    Atom selection;
    Atom target;
    Atom property;
    Time time;
}
struct XSelectionEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window requestor;
    Atom selection;
    Atom target;
    Atom property;
    Time time;
}
struct XColormapEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Colormap colormap;
    Bool c_new;
    int state;
}
struct XClientMessageEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    Atom message_type;
    int format;
    union _data {
        char[20] b = '\0';
        short[10] s;
        c_long[5] l;
    }
    _data data;
}
struct XMappingEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
    int request;
    int first_keycode;
    int count;
}
struct XErrorEvent {
    int type;
    Display* display;
    XID resourceid;
    c_ulong serial;
    ubyte error_code;
    ubyte request_code;
    ubyte minor_code;
}
struct XAnyEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    Window window;
}
struct XGenericEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    int extension;
    int evtype;
}
struct XGenericEventCookie {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    int extension;
    int evtype;
    uint cookie;
    void* data;
}
union XEvent {
    int type;
    XAnyEvent xany;
    XKeyEvent xkey;
    XButtonEvent xbutton;
    XMotionEvent xmotion;
    XCrossingEvent xcrossing;
    XFocusChangeEvent xfocus;
    XExposeEvent xexpose;
    XGraphicsExposeEvent xgraphicsexpose;
    XNoExposeEvent xnoexpose;
    XVisibilityEvent xvisibility;
    XCreateWindowEvent xcreatewindow;
    XDestroyWindowEvent xdestroywindow;
    XUnmapEvent xunmap;
    XMapEvent xmap;
    XMapRequestEvent xmaprequest;
    XReparentEvent xreparent;
    XConfigureEvent xconfigure;
    XGravityEvent xgravity;
    XResizeRequestEvent xresizerequest;
    XConfigureRequestEvent xconfigurerequest;
    XCirculateEvent xcirculate;
    XCirculateRequestEvent xcirculaterequest;
    XPropertyEvent xproperty;
    XSelectionClearEvent xselectionclear;
    XSelectionRequestEvent xselectionrequest;
    XSelectionEvent xselection;
    XColormapEvent xcolormap;
    XClientMessageEvent xclient;
    XMappingEvent xmapping;
    XErrorEvent xerror;
    XKeymapEvent xkeymap;
    XGenericEvent xgeneric;
    XGenericEventCookie xcookie;
    c_long[24] pad;
}
int XAllocID(Display* dpy) {
    return cast(int) dpy.resource_alloc(dpy);
}
struct XCharStruct {
    short lbearing;
    short rbearing;
    short width;
    short ascent;
    short descent;
    ushort attributes;
}
struct XFontProp {
    Atom name;
    c_ulong card32;
}
struct XFontStruct {
    XExtData* ext_data;
    Font fid;
    uint direction;
    uint min_char_or_char2;
    uint max_char_or_char2;
    uint min_char1;
    uint max_char1;
    Bool all_chars_exist;
    uint default_char;
    int n_properties;
    XFontProp* properties;
    XCharStruct min_bounds;
    XCharStruct max_bounds;
    XCharStruct* per_char;
    int ascent;
    int descent;
}
struct XTextItem {
    char* chars;
    int nchars;
    int delta;
    Font font;
}
struct XChar2b {
    ubyte char1;
    ubyte char2;
}
struct XTextItem16 {
    XChar2b* chars;
    int nchars;
    int delta;
    Font font;
}
union XEDataObject {
    Display* display;
    GC gc;
    Visual* visual;
    Screen* screen;
    ScreenFormat* pixmap_format;
    XFontStruct* font;
}
struct XFontSetExtents {
    XRectangle max_ink_extent;
    XRectangle max_logical_extent;
}
struct _XOM {}
struct _XOC {}
alias _XOM* XOM;
alias _XOC* XOC;
alias _XOC* XFontSet;
struct XmbTextItem {
    char* chars;
    int nchars;
    int delta;
    XFontSet font_set;
}
struct XwcTextItem {
    wchar* chars;
    int nchars;
    int delta;
    XFontSet font_set;
}
const char* XNRequiredCharSet = "requiredCharSet";
const char* XNQueryOrientation = "queryOrientation";
const char* XNBaseFontName = "baseFontName";
const char* XNOMAutomatic = "omAutomatic";
const char* XNMissingCharSet = "missingCharSet";
const char* XNDefaultString = "defaultString";
const char* XNOrientation = "orientation";
const char* XNDirectionalDependentDrawing = "directionalDependentDrawing";
const char* XNContextualDrawing = "contextualDrawing";
const char* XNFontInfo = "fontInfo";
struct XOMCharSetList {
    int charset_count;
    char** charset_list;
}
alias int XOrientation;
enum {
    XOMOrientation_LTR_TTB,
    XOMOrientation_RTL_TTB,
    XOMOrientation_TTB_LTR,
    XOMOrientation_TTB_RTL,
    XOMOrientation_Context
}
struct XOMOrientation {
    int num_orientation;
    XOrientation* orientation;
}
struct XOMFontInfo {
    int num_font;
    XFontStruct** font_struct_list;
    char** font_name_list;
}
struct _XIM {}
struct _XIC {}
alias _XIM* XIM;
alias _XIC* XIC;
alias void function(XIM, XPointer, XPointer) XIMProc;
alias Bool function(XIC, XPointer, XPointer) XICProc;
alias void function(Display*, XPointer, XPointer) XIDProc;
struct XIMStyles {
    ushort count_styles;
    XIMStyle* supported_styles;
}
alias c_ulong XIMStyle;
enum {
    XIMPreeditArea = 0x0001L,
    XIMPreeditCallbacks = 0x0002L,
    XIMPreeditPosition = 0x0004L,
    XIMPreeditNothing = 0x0008L,
    XIMPreeditNone = 0x0010L,
    XIMStatusArea = 0x0100L,
    XIMStatusCallbacks = 0x0200L,
    XIMStatusNothing = 0x0400L,
    XIMStatusNone = 0x0800L
}
const char* XNVaNestedList = "XNVaNestedList";
const char* XNQueryInputStyle = "queryInputStyle";
const char* XNClientWindow = "clientWindow";
const char* XNInputStyle = "inputStyle";
const char* XNFocusWindow = "focusWindow";
const char* XNResourceName = "resourceName";
const char* XNResourceClass = "resourceClass";
const char* XNGeometryCallback = "geometryCallback";
const char* XNDestroyCallback = "destroyCallback";
const char* XNFilterEvents = "filterEvents";
const char* XNPreeditStartCallback = "preeditStartCallback";
const char* XNPreeditDoneCallback = "preeditDoneCallback";
const char* XNStringConversion = "stringConversion";
const char* XNResetState = "resetState";
const char* XNHotKey = "hotKey";
const char* XNHotKeyState = "hotKeyState";
const char* XNPreeditState = "preeditState";
const char* XNSeparatorofNestedList = "separatorofNestedList";
enum int XBufferOverflow = -1;
enum int XLookupNone = 1;
enum int XLookupChars = 2;
enum int XLookupKeySym = 3;
enum int XLookupBoth = 4;
alias XVaNestedList = void*;
XImage* XGetImage(Display*, Drawable, int, int, uint, uint, c_ulong, int);
XImage* XGetSubImage(Display*, Drawable, int, int, uint, uint, c_ulong, int, XImage*, int, int);
Display* XOpenDisplay(char*);
void XrmInitialize();
int function(Display*) XSetAfterFunction(Display*, int function(Display*));
Atom XInternAtom(Display*, const char*, Bool);
Status XInternAtoms(Display*, char**, int, Bool, Atom*);
Colormap XCopyColormapAndFree(Display*, Colormap);
Colormap XCreateColormap(Display*, Window, Visual*, int);
Cursor XCreatePixmapCursor(Display*, Pixmap, Pixmap, XColor*, XColor*, uint, uint);
Cursor XCreateGlyphCursor(Display*, Font, Font, uint, uint, XColor*, XColor*);
Cursor XCreateFontCursor(Display*, uint);
Window XGetSelectionOwner(Display*, Atom);
Window XCreateWindow(Display*, Window, int, int, uint, uint, uint, int, uint, Visual*, c_ulong, XSetWindowAttributes*);
Colormap* XListInstalledColormaps(Display*, Window, int*);
char** XListFonts(Display*, char*, int, int*);
XHostAddress* XListHosts(Display*, int*, Bool*);
KeySym XKeycodeToKeysym(Display*, KeyCode, int);
KeySym XLookupKeysym(XKeyEvent*, int);
KeySym* XGetKeyboardMapping(Display*, KeyCode, int, int*);
KeySym XStringToKeysym(char*);
c_long XMaxRequestSize(Display*);
c_long XExtendedMaxRequestSize(Display*);
char* XResourceManagerString(Display*);
char* XScreenResourceString(Screen*);
c_ulong XDisplayMotionBufferSize(Display*);
VisualID XVisualIDFromVisual(Visual*);
Status XInitThreads();
int XScreenNumberOfScreen(Screen*);
alias int function(Display*, XErrorEvent*) XErrorHandler;
XErrorHandler XSetErrorHandler(XErrorHandler);
alias int function(Display*) XIOErrorHandler;
Status XGetWMProtocols(Display*, Window, Atom**, int*);
Status XSetWMProtocols(Display*, Window, Atom*, int);
Status XIconifyWindow(Display*, Window, int);
Status XWithdrawWindow(Display*, Window, int);
int XChangeKeyboardControl(Display*, c_ulong, XKeyboardControl*);
int XChangeKeyboardMapping(Display*, int, int, KeySym*, int);
int XChangePointerControl(Display*, Bool, Bool, int, int, int);
int XChangeProperty(Display*, Window, Atom, Atom, int, int, ubyte*, int);
int XChangeSaveSet(Display*, Window, int);
int XChangeWindowAttributes(Display*, Window, uint, XSetWindowAttributes*);
Bool XCheckIfEvent(Display*, XEvent*, Bool function(Display*, XEvent*, XPointer), XPointer);
Bool XCheckMaskEvent(Display*, c_long, XEvent*);
Bool XCheckTypedEvent(Display*, int, XEvent*);
Bool XCheckTypedWindowEvent(Display*, Window, int, XEvent*);
Bool XCheckWindowEvent(Display*, Window, c_long, XEvent*);
int XCirculateSubwindows(Display*, Window, int);
int XCloseDisplay(Display*);
int XConfigureWindow(Display*, Window, c_ulong, XWindowChanges*);
int XConnectionNumber(Display*);
int XConvertSelection(Display*, Atom, Atom, Atom, Window, Time);
int XDefaultDepthOfScreen(Screen*);
int XDefaultScreen(Display*);
int XDefineCursor(Display*, Window, Cursor);
int XDeleteProperty(Display*, Window, Atom);
int XDestroyWindow(Display*, Window);
int XDestroySubwindows(Display*, Window);
int XDoesBackingStore(Screen*);
Bool XDoesSaveUnders(Screen*);
int XEventsQueued(Display*, int);
Status XFetchName(Display*, Window, char**);
int XFillArc(Display*, Drawable, GC, int, int, uint, uint, int, int);
int XFillArcs(Display*, Drawable, GC, XArc*, int);
int XFillPolygon(Display*, Drawable, GC, XPoint*, int, int, int);
int XFillRectangle(Display*, Drawable, GC, int, int, uint, uint);
int XFillRectangles(Display*, Drawable, GC, XRectangle*, int);
int XFlush(Display*);
int XForceScreenSaver(Display*, int);
int XFree(void*);
int XFreeColormap(Display*, Colormap);
int XFreeColors(Display*, Colormap, c_ulong*, int, c_ulong);
int XFreeCursor(Display*, Cursor);
int XFreeExtensionList(char**);
int XFreeFont(Display*, XFontStruct*);
int XFreeFontInfo(char**, XFontStruct*, int);
int XFreePixmap(Display*, Pixmap);
int XGeometry(Display*, int, char*, char*, uint, uint, uint, int, int, int*, int*, int*, int*);
int XGetErrorDatabaseText(Display*, char*, char*, char*, char*, int);
int XGetErrorText(Display*, int, char*, int);
int XGetInputFocus(Display*, Window*, int*);
int XGetKeyboardControl(Display*, XKeyboardState*);
int XGetPointerControl(Display*, int*, int*, int*);
int XGetPointerMapping(Display*, ubyte*, int);
int XGetScreenSaver(Display*, int*, int*, int*, int*);
Status XGetTransientForHint(Display*, Window, Window*);
int XGetWindowProperty(Display*, Window, Atom, c_long, c_long, Bool, Atom, Atom*, int*, c_ulong*, c_ulong*, ubyte**);
Status XGetWindowAttributes(Display*, Window, XWindowAttributes*);
int XGrabButton(Display*, uint, uint, Window, Bool, uint, int, int, Window, Cursor);
int XGrabKey(Display*, int, uint, Window, Bool, int, int);
int XGrabKeyboard(Display*, Window, Bool, int, int, Time);
int XGrabPointer(Display*, Window, Bool, uint, int, int, Window, Cursor, Time);
Status XLookupColor(Display*, Colormap, char*, XColor*, XColor*);
int XLowerWindow(Display*, Window);
int XMapRaised(Display*, Window);
int XMapSubwindows(Display*, Window);
int XMapWindow(Display*, Window);
int XMaskEvent(Display*, c_long, XEvent*);
int XMaxCmapsOfScreen(Screen*);
int XMinCmapsOfScreen(Screen*);
int XMoveResizeWindow(Display*, Window, int, int, uint, uint);
int XMoveWindow(Display*, Window, int, int);
int XNextEvent(Display*, XEvent*);
int XNoOp(Display*);
Status XParseColor(Display*, Colormap, char*, XColor*);
int XParseGeometry(char*, int*, int*, uint*, uint*);
int XPeekEvent(Display*, XEvent*);
int XPeekIfEvent(Display*, XEvent*, Bool function(Display*, XEvent*, XPointer), XPointer);
int XPending(Display*);
int XPlanesOfScreen(Screen*);
int XProtocolRevision(Display*);
int XProtocolVersion(Display*);
int XPutBackEvent(Display*, XEvent*);
int XPutImage(Display*, Drawable, GC, XImage*, int, int, int, int, uint, uint);
int XQLength(Display*);
Status XQueryBestCursor(Display*, Drawable, uint, uint, uint*, uint*);
int XQueryColors(Display*, Colormap, XColor*, int);
Bool XQueryExtension(Display*, const(char)*, int*, int*, int*);
int XQueryKeymap(Display*, char[32]);
Bool XQueryPointer(Display*, Window, Window*, Window*, int*, int*, int*, int*, uint*);
int XQueryTextExtents(Display*, XID, char*, int, int*, int*, int*, XCharStruct*);
int XQueryTextExtents16(Display*, XID, XChar2b*, int, int*, int*, int*, XCharStruct*);
Status XQueryTree(Display*, Window, Window*, Window*, Window**, uint*);
int XRaiseWindow(Display*, Window);
int XReparentWindow(Display*, Window, Window, int, int);
int XResetScreenSaver(Display*);
int XResizeWindow(Display*, Window, uint, uint);
int XRestackWindows(Display*, Window*, int);
int XRotateBuffers(Display*, int);
int XRotateWindowProperties(Display*, Window, Atom*, int, int);
int XScreenCount(Display*);
int XSelectInput(Display*, Window, c_long);
Status XSendEvent(Display*, Window, Bool, c_long, XEvent*);
int XSetAccessControl(Display*, int);
int XSetArcMode(Display*, GC, int);
int XSetBackground(Display*, GC, c_ulong);
int XSetGraphicsExposures(Display*, GC, Bool);
int XSetIconName(Display*, Window, char*);
int XSetInputFocus(Display*, Window, int, Time);
int XSetLineAttributes(Display*, GC, uint, int, int, int);
int XSetModifierMapping(Display*, XModifierKeymap*);
int XSetPlaneMask(Display*, GC, c_ulong);
int XSetPointerMapping(Display*, ubyte*, int);
int XSetScreenSaver(Display*, int, int, int, int);
int XSetSelectionOwner(Display*, Atom, Window, Time);
int XSetState(Display*, GC, c_ulong, c_ulong, int, c_ulong);
int XSetStipple(Display*, GC, Pixmap);
int XSetSubwindowMode(Display*, GC, int);
int XStoreName(Display*, Window, char*);
int XStoreNamedColor(Display*, Colormap, char*, c_ulong, int);
int XSync(Display*, Bool);
int XTextExtents(XFontStruct*, char*, int, int*, int*, int*, XCharStruct*);
int XTextExtents16(XFontStruct*, XChar2b*, int, int*, int*, int*, XCharStruct*);
int XTextWidth(XFontStruct*, char*, int);
int XTextWidth16(XFontStruct*, XChar2b*, int);
Bool XTranslateCoordinates(Display*, Window, Window, int, int, int*, int*, Window*);
int XUndefineCursor(Display*, Window);
int XUngrabButton(Display*, uint, uint, Window);
int XUngrabKey(Display*, int, uint, Window);
int XUngrabKeyboard(Display*, Time);
int XUngrabPointer(Display*, Time);
int XUngrabServer(Display*);
int XUninstallColormap(Display*, Colormap);
int XUnloadFont(Display*, Font);
int XUnmapSubwindows(Display*, Window);
int XUnmapWindow(Display*, Window);
int XVendorRelease(Display*);
int XWarpPointer(Display*, Window, Window, int, int, uint, uint, int, int);
Bool XSupportsLocale();
char* XSetLocaleModifiers(const char*);
XOM XOpenOM(Display*, _XrmHashBucketRec*, char*, char*);
Status XCloseOM(XOM);XIM XOpenIM(Display*, _XrmHashBucketRec*, char*, char*);
Status XCloseIM(XIM);char* XGetIMValues(XIM, ...);
char* XSetIMValues(XIM, ...);
Display* XDisplayOfIM(XIM);
char* XLocaleOfIM(XIM);
XIC XCreateIC(XIM,...);
void XDestroyIC(XIC);
void XSetICFocus(XIC);
void XUnsetICFocus(XIC);
wchar* XwcResetIC(XIC);
char* XmbResetIC(XIC);
char* Xutf8ResetIC(XIC);
char* XSetICValues(XIC, ...);
char* XGetICValues(XIC, ...);
XIM XIMOfIC(XIC);Bool XFilterEvent(XEvent*, Window);
int XmbLookupString(XIC, XKeyPressedEvent*, char*, int, KeySym*, Status*);int XwcLookupString(XIC, XKeyPressedEvent*, wchar_t*, int, KeySym*, Status*);int Xutf8LookupString(XIC, XKeyPressedEvent*, char*, int, KeySym*, Status*);XVaNestedList XVaCreateNestedList(int, ...);
Bool XRegisterIMInstantiateCallback(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer);
Bool XUnregisterIMInstantiateCallback(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer);
alias void function(Display*, XPointer, int, Bool, XPointer*) XConnectionWatchProc;
void XSetAuthorization(char*, int, char*, int);
int _Xmbtowc(wchar*, char*, int);
int _Xwctomb(char*, wchar);
Bool XGetEventData(Display*, XGenericEventCookie*);
void XFreeEventData(Display*, XGenericEventCookie*);
enum bool XTHREADS = true;
enum bool XUSE_MTSAFE_API = true;
enum XEventQueueOwner {
    XlibOwnsEventQueue = 0,
    XCBOwnsEventQueue
}
const uint XCONN_CHECK_FREQ = 256;
struct _XGC {
    XExtData* ext_data;
    GContext gid;
    Bool rects;
    Bool dashes;
    c_ulong dirty;
    XGCValues values;
}
struct _XLockInfo {}
struct _XDisplayAtoms {}
struct _XContextDB {}
struct _XIMFilter {}
struct _XkbInfoRec {}
struct _XtransConnInfo {}
struct _X11XCBPrivate {}
//~ struct _XLockPtrs{} -- define in version XTHREAD
struct _XKeytrans {}
struct _XDisplay {
    XExtData* ext_data;
    _XFreeFuncs* free_funcs;
    int fd;
    int conn_checker;
    int proto_major_version;
    int proto_minor_version;
    char* c_vendor;
    XID resource_base;
    XID resource_mask;
    XID resource_id;
    int resource_shift;
    extern(C) nothrow XID function(_XDisplay*) resource_alloc;
    int byte_order;
    int bitmap_unit;
    int bitmap_pad;
    int bitmap_bit_order;
    int nformats;
    ScreenFormat* pixmap_format;
    int vnumber;
    int release;
    _XSQEvent* head, tail;
    int qlen;
    c_ulong last_request_read;
    c_ulong request;
    char* last_req;
    char* buffer;
    char* bufptr;
    char* bufmax;
    uint max_request_size;
    _XrmHashBucketRec* db;
    extern(C) nothrow int function(_XDisplay*) synchandler;
    char* display_name;
    int default_screen;
    int nscreens;
    Screen* screens;
    c_ulong motion_buffer;
    c_ulong flags;
    int min_keycode;
    int max_keycode;
    KeySym* keysyms;
    XModifierKeymap* modifiermap;
    int keysyms_per_keycode;
    char* xdefaults;
    char* scratch_buffer;
    c_ulong scratch_length;
    int ext_number;
    _XExten* ext_procs;
    extern(C) nothrow Bool function(
            Display*, XEvent*, xEvent*)[128] event_vec;
    extern(C) nothrow Status function(
            Display*, XEvent*, xEvent*)[128] wire_vec;
    KeySym lock_meaning;
    _XLockInfo* lock;
    _XInternalAsync* async_handlers;
    c_ulong bigreq_size;
    _XLockPtrs* lock_fns;
    extern(C) nothrow void function(
            Display*, XID*, int) idlist_alloc;
    _XKeytrans* key_bindings;
    Font cursor_font;
    _XDisplayAtoms* atoms;
    uint mode_switch;
    uint num_lock;
    _XContextDB* context_db;
    extern(C) nothrow Bool function(
            Display*, XErrorEvent*, xError*)* error_vec;
    struct cms {
        XPointer defaultCCCs;
        XPointer clientCmaps;
        XPointer perVisualIntensityMaps;
    }
    _XIMFilter* im_filters;
    _XSQEvent* qfree;
    c_ulong next_event_serial_num;
    _XExten* flushes;
    _XConnectionInfo* im_fd_info;
    int im_fd_length;
    _XConnWatchInfo* conn_watchers;
    int watcher_count;
    XPointer filedes;
    extern(C) nothrow int function(
            Display*) savedsynchandler;
    XID resource_max;
    int xcmisc_opcode;
    _XkbInfoRec* xkb_info;
    _XtransConnInfo* trans_conn;
    _X11XCBPrivate* xcb;
    uint next_cookie;
    extern(C) nothrow Bool function(Display*, XGenericEventCookie*, xEvent*)[128] generic_event_vec;
    extern(C) nothrow Bool function(Display*, XGenericEventCookie*, XGenericEventCookie*)[128] generic_event_copy_vec;
    void* cookiejar;
}
void XAllocIDs(Display* dpy, XID* ids, int n) {
    dpy.idlist_alloc(dpy, ids, n);
}
enum bool DataRoutineIsProcedure = false;
struct _XSQEvent {
    _XSQEvent* next;
    XEvent event;
    c_ulong qserial_num;
}
alias _XSQEvent _XQEvent;
extern LockInfoPtr _Xglobal_lock; // warn put here for skip build error
struct _XLockPtrs {}
struct _LockInfoRec {}
alias _LockInfoRec* LockInfoPtr;

void Xfree(void* ptr) {
    free(ptr);
}
struct _XInternalAsync {
    _XInternalAsync* next;
    extern(C) nothrow Bool function(Display*, xReply*, char*, int, XPointer) handler;
    XPointer data;
}
alias _XInternalAsync _XAsyncHandler;
struct _XAsyncEState {
    c_ulong min_sequence_number;
    c_ulong max_sequence_number;
    ubyte error_code;
    ubyte major_opcode;
    ushort minor_opcode;
    ubyte last_error_received;
    int error_count;
}
alias _XAsyncEState _XAsyncErrorState;
void _XDeqAsyncHandler(Display* dpy, _XAsyncHandler* handler);
void DeqAsyncHandler(Display* dpy, _XAsyncHandler* handler) {
    if (dpy.async_handlers == handler)
        dpy.async_handlers = handler.next;
    else
        _XDeqAsyncHandler(dpy, handler);
}
alias void function(Display*) FreeFuncType;
alias int function(XModifierKeymap*) FreeModmapType;
struct _XFreeFuncs {
    FreeFuncType atoms;
    FreeModmapType modifiermap;
    FreeFuncType key_bindings;
    FreeFuncType context_db;
    FreeFuncType defaultCCCs;
    FreeFuncType clientCmaps;
    FreeFuncType intensityMaps;
    FreeFuncType im_filters;
    FreeFuncType xkb;
}
alias _XFreeFuncs _XFreeFuncRec;
alias int function(Display*, GC, XExtCodes*) CreateGCType;
alias int function(Display*, GC, XExtCodes*) CopyGCType;
alias int function(Display*, GC, XExtCodes*) FlushGCType;
alias int function(Display*, GC, XExtCodes*) FreeGCType;
alias int function(Display*, XFontStruct*, XExtCodes*) CreateFontType;
alias int function(Display*, XFontStruct*, XExtCodes*) FreeFontType;
alias int function(Display*, XExtCodes*) CloseDisplayType;
alias int function(Display*, xError*, XExtCodes*, int*) ErrorType;
alias char* function(Display*, int, XExtCodes*, char*, int) ErrorStringType;
alias void function(Display*, XErrorEvent*, void*) PrintErrorType;
alias void function(Display*, XExtCodes*, const char*, c_long) BeforeFlushType;
struct _XExten {
    _XExten* next;
    XExtCodes codes;
    CreateGCType create_GC;
    CopyGCType copy_GC;
    FlushGCType flush_GC;
    FreeGCType free_GC;
    CreateFontType create_Font;
    FreeFontType free_Font;
    CloseDisplayType close_display;
    ErrorType error;
    ErrorStringType error_string;
    char* name;
    PrintErrorType error_values;
    BeforeFlushType before_flush;
    _XExten* next_flush;
}
alias _XExten _XExtension;
alias void function(Display*, int, XPointer) _XInternalConnectionProc;
Status _XRegisterInternalConnection(Display*, int, _XInternalConnectionProc, XPointer);
void _XUnregisterInternalConnection(Display*, int);
void _XProcessInternalConnection(Display*, _XConnectionInfo*);
struct _XConnectionInfo {
    int fd;
    _XInternalConnectionProc read_callback;
    XPointer call_data;
    XPointer* watch_data;
    _XConnectionInfo* next;
}
struct _XConnWatchInfo {
    XConnectionWatchProc fn;
    XPointer client_data;
    _XConnWatchInfo* next;
}
version(X86_64) {
    enum bool LONG64 = true;
    enum bool MUSTCOPY = true;
} else {
    enum bool LONG64 = false;
    enum bool MUSTCOPY = false;
}
size_t _SIZEOF(T)() {
    return T.sizeof;
}
alias _SIZEOF SIZEOF;
version(X86_64) {
    alias long INT64;
    alias uint INT32;
    alias uint INT16;
} else {
    static if (LONG64) {
        alias c_long INT64;
        alias int INT32;
    } else
        alias c_long INT32;
    alias short INT16;
}
alias byte INT8;
static if (LONG64) {
    alias c_ulong CARD64;
    alias uint CARD32;
} else
    alias c_ulong CARD32;
static if (!WORD64 && !LONG64)
    alias ulong CARD64;
alias ushort CARD16;
alias byte CARD8;
alias CARD32 BITS32;
alias CARD16 BITS16;
alias CARD8 BYTE;
alias CARD8 BOOL;
static if (WORD64) {
    template cvtINT8toInt(INT8 val) {
        enum int cvtINT8toInt = cast(int)(val & 0x00000080) ? (val | 0xffffffffffffff00) : val;
    }
    template cvtINT16toInt(INT16 val) {
        enum int cvtINT16toInt = cast(int)(val & 0x00008000) ? (val | 0xffffffffffff0000) : val;
    }
    template cvtINT32toInt(INT32 val) {
        enum int cvtINT32toInt = cast(int)(val & 0x80000000) ? (val | 0xffffffff00000000) : val;
    }
    template cvtINT8toShort(INT8 val) {
        enum short cvtINT8toShort = cast(short) cvtINT8toInt(val);
    }
    template cvtINT16toShort(INT16 val) {
        enum short cvtINT16toShort = cast(short) cvtINT16toInt(val);
    }
    template cvtINT32toShort(INT32 val) {
        enum short cvtINT32toShort = cast(short) cvtINT32toInt(val);
    }
    template cvtINT8toLong(INT8 val) {
        enum c_long cvtINT8toLong = cast(c_long) cvtINT8toInt(val);
    }
    template cvtINT16toLong(INT16 val) {
        enum c_long cvtINT16toLong = cast(c_long) cvtINT16toInt(val);
    }
    template cvtINT32toLong(INT32 val) {
        enum c_long cvtINT32toLong = cast(c_long) cvtINT32toInt(val);
    }
} else {
    template cvtINT8toInt(INT8 val) {
        enum int cvtINT8toInt = cast(int) val;
    }
    template cvtINT16toInt(INT16 val) {
        enum int cvtINT16toInt = cast(int) val;
    }
    template cvtINT32toInt(INT32 val) {
        enum int cvtINT32toInt = cast(int) val;
    }
    template cvtINT8toShort(INT8 val) {
        enum short cvtINT8toShort = cast(short) val;
    }
    template cvtINT16toShort(INT16 val) {
        enum short cvtINT16toShort = cast(short) val;
    }
    template cvtINT32toShort(INT32 val) {
        enum short cvtINT32toShort = cast(short) val;
    }
    template cvtINT8toLong(INT8 val) {
        enum c_long cvtINT8toLong = cast(c_long) val;
    }
    template cvtINT16toLong(INT16 val) {
        enum c_long cvtINT16toLong = cast(c_long) val;
    }
    template cvtINT32toLong(INT32 val) {
        enum c_long cvtINT32toLong = cast(c_long) val;
    }
}
enum int xFalse = 0;
alias CARD16 KeyButMask;
struct xConnClientPrefix {
    CARD8 byteOrder;
    BYTE pad;
    CARD16 majorVersion;
    CARD16 minorVersion;
    CARD16 nbytesAuthProto6;
    CARD16 nbytesAuthString;
    CARD16 pad2;
}
struct xConnSetupPrefix {
    CARD8 success;
    BYTE lengthReason;
    CARD16 majorVersion, minorVersion;
    CARD16 length;
}
struct xWindowRoot {
    Window windowId;
    Colormap defaultColormap;
    CARD32 whitePixel, blackPixel;
    CARD32 currentInputMask;
    CARD16 pixWidth, pixHeight;
    CARD16 mmWidth, mmHeight;
    CARD16 minInstalledMaps, maxInstalledMaps;
    VisualID rootVisualID;
    CARD8 backingStore;
    BOOL saveUnders;
    CARD8 rootDepth;
    CARD8 nDepths;
}
struct xTimecoord {
    CARD32 time;
    INT16 x, y;
}
struct xHostEntry {
    CARD8 family;
    BYTE pad;
    CARD16 length;
}
struct xCharInfo {
    INT16 leftSideBearing, rightSideBearing, characterWidth, ascent, descent;
    CARD16 attributes;
}
alias CARD8 KEYCODE;
struct xGenericReply {
    BYTE type;
    BYTE data1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 data00;
    CARD32 data01;
    CARD32 data02;
    CARD32 data03;
    CARD32 data04;
    CARD32 data05;
}
struct xGetWindowAttributesReply {
    BYTE type;
    CARD8 backingStore;
    CARD16 sequenceNumber;
    CARD32 length;
    VisualID visualID;
    CARD16 c_class;
    CARD8 bitGravity;
    CARD8 winGravity;
    CARD32 backingBitPlanes;
    CARD32 backingPixel;
    BOOL saveUnder;
    BOOL mapInstalled;
    CARD8 mapState;
    BOOL c_override;
    Colormap colormap;
    CARD32 allEventMasks;
    CARD32 yourEventMask;
    CARD16 doNotPropagateMask;
    CARD16 pad;
}
struct xGetGeometryReply {
    BYTE type;
    CARD8 depth;
    CARD16 sequenceNumber;
    CARD32 length;
    Window root;
    INT16 x, y;
    CARD16 width, height;
    CARD16 borderWidth;
    CARD16 pad1;
    CARD32 pad2;
    CARD32 pad3;
}
struct xQueryTreeReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    Window root, parent;
    CARD16 nChildren;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
struct xInternAtomReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    Atom atom;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xGetAtomNameReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nameLength;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xGetPropertyReply {
    BYTE type;
    CARD8 format;
    CARD16 sequenceNumber;
    CARD32 length;
    Atom propertyType;
    CARD32 bytesAfter;
    CARD32 nItems;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
}
struct xListPropertiesReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nProperties;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xGetSelectionOwnerReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    Window owner;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xGrabPointerReply {
    BYTE type;
    BYTE status;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
alias xGrabPointerReply xGrabKeyboardReply;
struct xQueryPointerReply {
    BYTE type;
    BOOL sameScreen;
    CARD16 sequenceNumber;
    CARD32 length;
    Window root, child;
    INT16 rootX, rootY, winX, winY;
    CARD16 mask;
    CARD16 pad1;
    CARD32 pad;
}
struct xGetMotionEventsReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 nEvents;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xTranslateCoordsReply {
    BYTE type;
    BOOL sameScreen;
    CARD16 sequenceNumber;
    CARD32 length;
    Window child;
    INT16 dstX, dstY;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
struct xGetInputFocusReply {
    BYTE type;
    CARD8 revertTo;
    CARD16 sequenceNumber;
    CARD32 length;
    Window focus;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
struct xQueryTextExtentsReply {
    BYTE type;
    CARD8 drawDirection;
    CARD16 sequenceNumber;
    CARD32 length;
    INT16 fontAscent, fontDescent;
    INT16 overallAscent, overallDescent;
    INT32 overallWidth, overallLeft, overallRight;
    CARD32 pad;
}
struct xListFontsReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nFonts;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
version(X86_64) {
    struct xListFontsWithInfoReply {
        BYTE type;
        CARD8 nameLength;
        CARD16 sequenceNumber;
        CARD32 length;
        xCharInfo minBounds;
        xCharInfo maxBounds;
        CARD16 minCharOrByte2, maxCharOrByte2;
        CARD16 defaultChar;
        CARD16 nFontProps;
        CARD8 drawDirection;
        CARD8 minByte1, maxByte1;
        BOOL allCharsExist;
        INT16 fontAscent, fontDescent;
        CARD32 nReplies;
    }
} else {
    struct xListFontsWithInfoReply {
        BYTE type;
        CARD8 nameLength;
        CARD16 sequenceNumber;
        CARD32 length;
        xCharInfo minBounds;
        CARD32 walign1;
        xCharInfo maxBounds;
        CARD32 align2;
        CARD16 minCharOrByte2, maxCharOrByte2;
        CARD16 defaultChar;
        CARD16 nFontProps;
        CARD8 drawDirection;
        CARD8 minByte1, maxByte1;
        BOOL allCharsExist;
        INT16 fontAscent, fontDescent;
        CARD32 nReplies;
    }
}
struct xGetFontPathReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nPaths;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xGetImageReply {
    BYTE type;
    CARD8 depth;
    CARD16 sequenceNumber;
    CARD32 length;
    VisualID visual;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xListInstalledColormapsReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nColormaps;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xAllocColorReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 red, green, blue;
    CARD16 pad2;
    CARD32 pixel;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
struct xAllocNamedColorReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pixel;
    CARD16 exactRed, exactGreen, exactBlue;
    CARD16 screenRed, screenGreen, screenBlue;
    CARD32 pad2;
    CARD32 pad3;
}
struct xAllocColorCellsReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nPixels, nMasks;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xAllocColorPlanesReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nPixels;
    CARD16 pad2;
    CARD32 redMask, greenMask, blueMask;
    CARD32 pad3;
    CARD32 pad4;
}
struct xQueryColorsReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nColors;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xLookupColorReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 exactRed, exactGreen, exactBlue;
    CARD16 screenRed, screenGreen, screenBlue;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
struct xQueryBestSizeReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 width, height;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xQueryExtensionReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    BOOL present;
    CARD8 major_opcode;
    CARD8 first_event;
    CARD8 first_error;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xListExtensionsReply {
    BYTE type;
    CARD8 nExtensions;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xSetMappingReply {
    BYTE type;
    CARD8 success;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
alias xSetMappingReply xSetPointerMappingReply;
alias xSetMappingReply xSetModifierMappingReply;
struct xGetPointerMappingReply {
    BYTE type;
    CARD8 nElts;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xGetKeyboardMappingReply {
    BYTE type;
    CARD8 keySymsPerKeyCode;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xGetModifierMappingReply {
    BYTE type;
    CARD8 numKeyPerModifier;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xGetKeyboardControlReply {
    BYTE type;
    BOOL globalAutoRepeat;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD32 ledMask;
    CARD8 keyClickPercent, bellPercent;
    CARD16 bellPitch, bellDuration;
    CARD16 pad;
    BYTE[32] map;
}
struct xGetPointerControlReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 accelNumerator, accelDenominator;
    CARD16 threshold;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xGetScreenSaverReply {
    BYTE type;
    BYTE pad1;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 timeout, interval;
    BOOL preferBlanking;
    BOOL allowExposures;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
}
struct xListHostsReply {
    BYTE type;
    BOOL enabled;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 nHosts;
    CARD16 pad1;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xError {
    BYTE type;
    BYTE errorCode;
    CARD16 sequenceNumber;
    CARD32 resourceID;
    CARD16 minorCode;
    CARD8 majorCode;
    BYTE pad1;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct _xEvent {
    union u {
        struct u {
            BYTE type;
            BYTE detail;
            CARD16 sequenceNumber;
        }
        struct keyButtonPointer {
            CARD32 pad00;
            Time time;
            Window root, event, child;
            INT16 rootX, rootY, eventX, eventY;
            KeyButMask state;
            BOOL sameScreen;
            BYTE pad1;
        }
        struct enterLeave {
            CARD32 pad00;
            Time time;
            Window root, event, child;
            INT16 rootX, rootY, eventX, eventY;
            KeyButMask state;
            BYTE mode;
            BYTE flags;
            enum int ELFlagFocus = 1 << 0;
            enum int ELFlagSameScreen = 1 << 1;
        }
        struct focus {
            CARD32 pad00;
            Window window;
            BYTE mode;
            BYTE pad1, pad2, pad3;
        }
        struct expose {
            CARD32 pad00;
            Window window;
            CARD16 x, y, width, height;
            CARD16 count;
            CARD16 pad2;
        }
        struct graphicsExposure {
            CARD32 pad00;
            Drawable drawable;
            CARD16 x, y, width, height;
            CARD16 minorEvent;
            CARD16 count;
            BYTE majorEvent;
            BYTE pad1, pad2, pad3;
        }
        struct noExposure {
            CARD32 pad00;
            Drawable drawable;
            CARD16 minorEvent;
            BYTE majorEvent;
            BYTE bpad;
        }
        struct visibility {
            CARD32 pad00;
            Window window;
            CARD8 state;
            BYTE pad1, pad2, pad3;
        }
        struct createNotify {
            CARD32 pad00;
            Window parent, window;
            INT16 x, y;
            CARD16 width, height, borderWidth;
            BOOL c_override;
            BYTE bpad;
        }
        struct destroyNotify {
            CARD32 pad00;
            Window event, window;
        }
        struct unmapNotify {
            CARD32 pad00;
            Window event, window;
            BOOL fromConfigure;
            BYTE pad1, pad2, pad3;
        }
        struct mapNotify {
            CARD32 pad00;
            Window event, window;
            BOOL c_override;
            BYTE pad1, pad2, pad3;
        }
        struct mapRequest {
            CARD32 pad00;
            Window parent, window;
        }
        struct reparent {
            CARD32 pad00;
            Window event, window, parent;
            INT16 x, y;
            BOOL c_override;
            BYTE pad1, pad2, pad3;
        }
        struct configureNotify {
            CARD32 pad00;
            Window event, window, aboveSibling;
            INT16 x, y;
            CARD16 width, height, borderWidth;
            BOOL c_override;
            BYTE bpad;
        }
        struct configureRequest {
            CARD32 pad00;
            Window parent, window, sibling;
            INT16 x, y;
            CARD16 width, height, borderWidth;
            CARD16 valueMask;
            CARD32 pad1;
        }
        struct gravity {
            CARD32 pad00;
            Window event, window;
            INT16 x, y;
            CARD32 pad1, pad2, pad3, pad4;
        }
        struct resizeRequest {
            CARD32 pad00;
            Window window;
            CARD16 width, height;
        }
        struct circulate {
            CARD32 pad00;
            Window event, window, parent;
            BYTE place;
            BYTE pad1, pad2, pad3;
        }
        struct property {
            CARD32 pad00;
            Window window;
            Atom atom;
            Time time;
            BYTE state;
            BYTE pad1;
            CARD16 pad2;
        }
        struct selectionClear {
            CARD32 pad00;
            Time time;
            Window window;
            Atom atom;
        }
        struct selectionRequest {
            CARD32 pad00;
            Time time;
            Window owner, requestor;
            Atom selection, target, property;
        }
        struct selectionNotify {
            CARD32 pad00;
            Time time;
            Window requestor;
            Atom selection, target, property;
        }
        struct colormap {
            CARD32 pad00;
            Window window;
            Colormap colormap;
            BOOL c_new;
            BYTE state;
            BYTE pad1, pad2;
        }
        struct mappingNotify {
            CARD32 pad00;
            CARD8 request;
            KeyCode firstKeyCode;
            CARD8 count;
            BYTE pad1;
        }
        struct clientMessage {
            CARD32 pad00;
            Window window;
            union u {
                struct l {
                    Atom type;
                    INT32 longs0;
                    INT32 longs1;
                    INT32 longs2;
                    INT32 longs3;
                    INT32 longs4;
                }
                struct s {
                    Atom type;
                    INT16 shorts0;
                    INT16 shorts1;
                    INT16 shorts2;
                    INT16 shorts3;
                    INT16 shorts4;
                    INT16 shorts5;
                    INT16 shorts6;
                    INT16 shorts7;
                    INT16 shorts8;
                    INT16 shorts9;
                }
                struct b {
                    Atom type;
                    INT8[20] bytes;
                }
            }
        }
    }
}
alias _xEvent xEvent;
struct xGenericEvent {
    BYTE type;
    CARD8 extension;
    CARD16 sequenceNumber;
    CARD32 length;
    CARD16 evtype;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
struct xKeymapEvent {
    BYTE type;
    BYTE[31] map;
}
const size_t XEventSize = xEvent.sizeof;
union xReply {
    xGenericReply generic;
    xGetGeometryReply geom;
    xQueryTreeReply tree;
    xInternAtomReply atom;
    xGetAtomNameReply atomName;
    xGetPropertyReply propertyReply;
    xListPropertiesReply listProperties;
    xGetSelectionOwnerReply selection;
    xGrabPointerReply grabPointer;
    xGrabKeyboardReply grabKeyboard;
    xQueryPointerReply pointer;
    xGetMotionEventsReply motionEvents;
    xTranslateCoordsReply coords;
    xGetInputFocusReply inputFocus;
    xQueryTextExtentsReply textExtents;
    xListFontsReply fonts;
    xGetFontPathReply fontPath;
    xGetImageReply image;
    xListInstalledColormapsReply colormaps;
    xAllocColorReply allocColor;
    xAllocNamedColorReply allocNamedColor;
    xAllocColorCellsReply colorCells;
    xAllocColorPlanesReply colorPlanes;
    xQueryColorsReply colors;
    xLookupColorReply lookupColor;
    xQueryBestSizeReply bestSize;
    xQueryExtensionReply extension;
    xListExtensionsReply extensions;
    xSetModifierMappingReply setModifierMapping;
    xGetModifierMappingReply getModifierMapping;
    xSetPointerMappingReply setPointerMapping;
    xGetKeyboardMappingReply getKeyboardMapping;
    xGetPointerMappingReply getPointerMapping;
    xGetPointerControlReply pointerControl;
    xGetScreenSaverReply screenSaver;
    xListHostsReply hosts;
    xError error;
    xEvent event;
}
struct _xReq {
    CARD8 reqType;
    CARD8 data;
    CARD16 length;
}
alias _xReq xReq;
struct xResourceReq {
    CARD8 reqType;
    BYTE pad;
    CARD16 length;
    CARD32 id;
}
struct Box {
    short x1, x2, y1, y2;
}
alias Box BOX;
alias Box BoxRec;
// private extern(D) int MAX(int a, int b) {return (a < b) ? b : a;}
// private extern(D) int MIN(int a, int b) {return (a > b) ? b : a;}
struct _XRegion {
    c_long size;
    c_long numRects;
    BOX* rects;
    BOX extents;
}
alias _XRegion REGION;
alias int XrmQuark;
alias int* XrmQuarkList;
const XrmQuark NULLQUARK = 0;
alias char* XrmString;
const XrmString NULLSTRING = null;
XrmQuark XrmStringToQuark(const char*);
XrmQuark XrmPermStringToQuark(const char*);
XrmString XrmQuarkToString(XrmQuark);
XrmQuark XrmUniqueQuark();
bool XrmStringsEqual(XrmString a1, XrmString a2) {
    return *a1 == *a2;
}
alias int XrmBinding;
enum {
    XrmBindTightly,
    XrmBindLoosely
}
alias XrmBinding* XrmBindingList;
void XrmStringToQuarkList(const char*, XrmQuarkList);
void XrmStringToBindingQuarkList(const char*, XrmBindingList, XrmQuarkList);
alias XrmQuark XrmName;
alias XrmQuarkList XrmNameList;
XrmString XrmNameToString(XrmName name) {
    return XrmQuarkToString(cast(XrmQuark) name);
}
XrmName XrmStringToName(XrmString string) {
    return cast(XrmName) XrmStringToQuark(string);
}
void XrmStringToNameList(XrmString str, XrmNameList name) {
    XrmStringToQuarkList(str, name);
}
alias XrmQuark XrmClass;
alias XrmQuarkList XrmClassList;
XrmString XrmClassToString(XrmClass c_class) {
    return XrmQuarkToString(cast(XrmQuark) c_class);
}
XrmClass XrmStringToClass(XrmString c_class) {
    return cast(XrmClass) XrmStringToQuark(c_class);
}
void XrmStringToClassList(XrmString str, XrmClassList c_class) {
    XrmStringToQuarkList(str, c_class);
}
alias XrmQuark XrmRepresentation;
XrmRepresentation XrmStringToRepresentation(XrmString string) {
    return cast(XrmRepresentation) XrmStringToQuark(string);
}
XrmString XrmRepresentationToString(XrmRepresentation type) {
    return XrmQuarkToString(type);
}
struct XrmValue {
    uint size;
    XPointer addr;
}
alias XrmValue* XrmValuePtr;
alias _XrmHashBucketRec* XrmHashBucket;
alias XrmHashBucket* XrmHashTable;
alias XrmHashTable[] XrmSearchList;
alias _XrmHashBucketRec* XrmDatabase;
void XrmDestroyDatabase(XrmDatabase);
void XrmQPutResource(XrmDatabase*, XrmBindingList, XrmQuarkList, XrmRepresentation, XrmValue*);
Bool XrmQGetResource(XrmDatabase, XrmNameList, XrmClassList, XrmRepresentation*, XrmValue*);Bool XrmGetResource(XrmDatabase, const char*, const char*, char**, XrmValue*);Bool XrmQGetSearchList(XrmDatabase, XrmNameList, XrmClassList, XrmSearchList, int);Bool XrmQGetSearchResource(XrmSearchList, XrmName, XrmClass, XrmRepresentation*, XrmValue*);XrmDatabase XrmGetStringDatabase(const char*);
void XrmPutFileDatabase(XrmDatabase, const char*);
void XrmMergeDatabases(XrmDatabase, XrmDatabase*);
void XrmCombineDatabase(XrmDatabase, XrmDatabase*, Bool);
alias int XrmOptionKind;
enum {
    XrmoptionNoArg,
    XrmoptionIsArg,
    XrmoptionStickyArg,
    XrmoptionSepArg,
    XrmoptionResArg,
    XrmoptionSkipArg,
    XrmoptionSkipLine,
    XrmoptionSkipNArgs
}
struct XrmOptionDescRec {
    char* option;
    char* specifier;
    XrmOptionKind argKind;
    XPointer value;
}
alias XrmOptionDescRec* XrmOptionDescList;
void XrmParseCommand(XrmDatabase*, XrmOptionDescList, int, const char*, int*, char**);
enum bool WORD64 = false;
enum int NoValue = 0x0000;
enum int AllValues = 0x000F;
enum int XNegative = 0x0010;
enum int YNegative = 0x0020;
struct XSizeHints {
    c_long flags;
    int x, y;
    int width, height;
    int min_width, min_height;
    int max_width, max_height;
    int width_inc, height_inc;
    struct aspect {
        int x;
        int y;
    }
    aspect min_aspect, max_aspect;
    int base_width, base_height;
    int win_gravity;
}
enum {
    USPosition = 1L << 0,
    USSize = 1L << 1,
    PPosition = 1L << 2,
    PSize = 1L << 3,
    PMinSize = 1L << 4,
    PMaxSize = 1L << 5,
    PResizeInc = 1L << 6,
    PAspect = 1L << 7,
    PBaseSize = 1L << 8,
    PWinGravity = 1L << 9
}
c_long PAllHints = (PPosition | PSize | PMinSize | PMaxSize | PResizeInc | PAspect);
struct XWMHints {
    c_long flags;
    Bool input;
    int initial_state;
    Pixmap icon_pixmap;
    Window icon_window;
    int icon_x, icon_y;
    Pixmap icon_mask;
    XID window_group;
}
enum {
    InputHint = (1L << 0),
    StateHint = (1L << 1),
    IconPixmapHint = (1L << 2),
    IconWindowHint = (1L << 3),
    IconPositionHint = (1L << 4),
    IconMaskHint = (1L << 5),
    WindowGroupHint = (1L << 6),
    AllHints = (InputHint | StateHint | IconPixmapHint | IconWindowHint
            | IconPositionHint | IconMaskHint | WindowGroupHint),
    XUrgencyHint = (1L << 8)
}
enum {
    WithdrawnState = 0,
    NormalState = 1,
    IconicState = 3
}
enum {
    DontCareState = 0,
    ZoomState = 2,
    InactiveState = 4
}
struct XTextProperty {
    ubyte* value;
    Atom encoding;
    int format;
    c_ulong nitems;
}
enum int XNoMemory = -1;
struct XIconSize {
    int min_width, min_height;
    int max_width, max_height;
    int width_inc, height_inc;
}
struct XClassHint {
    char* res_name;
    char* res_class;
}
struct XComposeStatus {
    XPointer compose_ptr;
    int chars_matched;
}
template IsKeypadKey(KeySym keysym) {
    const bool IsKeypadKey = ((keysym >= XK_KP_Space) && (keysym <= XK_KP_Equal));
}
template IsPrivateKeypadKey(KeySym keysym) {
    const bool IsPrivateKeypadKey = ((keysym >= 0x11000000) && (keysym <= 0x1100FFFF));
}
static if (XK_XKB_KEYS) {
    template IsModifierKey(KeySym keysym) {
        const bool IsModifierKey = (((keysym >= XK_Shift_L) && (keysym <= XK_Hyper_R))
                || ((keysym >= XK_ISO_Lock) && (keysym <= XK_ISO_Last_Group_Lock))
                || (keysym == XK_Mode_switch) || (keysym == XK_Num_Lock));
    }
} else {
    template IsModifierKey(keysym) {
        const bool IsModifierKey = (((keysym >= XK_Shift_L) && (keysym <= XK_Hyper_R))
                || (keysym == XK_Mode_switch) || (keysym == XK_Num_Lock));
    }
}
alias _XRegion* Region;
enum {
    RectangleOut = 0,
    RectangleIn = 1,
    RectanglePart = 2
}
struct XVisualInfo {
    Visual* visual;
    VisualID visualid;
    int screen;
    int depth;
    int c_class;
    c_ulong red_mask;
    c_ulong green_mask;
    c_ulong blue_mask;
    int colormap_size;
    int bits_per_rgb;
}
enum {
    VisualNoMask = 0x0,
    VisualIDMask = 0x1,
    VisualScreenMask = 0x2,
    VisualDepthMask = 0x4,
    VisualClassMask = 0x8,
    VisualRedMaskMask = 0x10,
    VisualGreenMaskMask = 0x20,
    VisualBlueMaskMask = 0x40,
    VisualColormapSizeMask = 0x80,
    VisualBitsPerRGBMask = 0x100,
    VisualAllMask = 0x1FF
}
struct XStandardColormap {
    Colormap colormap;
    c_ulong red_max;
    c_ulong red_mult;
    c_ulong green_max;
    c_ulong green_mult;
    c_ulong blue_max;
    c_ulong blue_mult;
    c_ulong base_pixel;
    VisualID visualid;
    XID killid;
}
const XID ReleaseByFreeingColormap = 1L;
enum {
    BitmapSuccess = 0,
    BitmapOpenFailed = 1,
    BitmapFileInvalid = 2,
    BitmapNoMemory = 3
}
enum {
    XCSUCCESS = 0,
    XCNOMEM = 1,
    XCNOENT = 2,
}
alias int XContext;
extern(D) auto XUniqueContext() {
    return cast(XContext) XrmUniqueQuark();
}
XContext XStringToContext(char* statement) {
    return XrmStringToQuark(statement);
}
XClassHint* XAllocClassHint();
XIconSize* XAllocIconSize();
XSizeHints* XAllocSizeHints();
XStandardColormap* XAllocStandardColormap();
XWMHints* XAllocWMHints();
int XClipBox(Region, XRectangle*);
Region XCreateRegion();
char* XDefaultString();
int XDeleteContext(Display*, XID, XContext);
int XDestroyRegion(Region);
int XEmptyRegion(Region);
int XEqualRegion(Region, Region);
int XFindContext(Display*, XID, XContext, XPointer*);
Status XGetClassHint(Display*, Window, XClassHint*);
Status XGetIconSizes(Display*, Window, XIconSize**, int*);
Status XGetNormalHints(Display*, Window, XSizeHints*);
XVisualInfo* XGetVisualInfo(Display*, long, XVisualInfo*, int*);
Status XGetWMClientMachine(Display*, Window, XTextProperty*);
XWMHints* XGetWMHints(Display*, Window);
Status XGetWMIconName(Display*, Window, XTextProperty*);
Status XGetWMName(Display*, Window, XTextProperty*);
Status XGetWMNormalHints(Display*, Window, XSizeHints*, long*);
Status XGetWMSizeHints(Display*, Window, XSizeHints*, long*, Atom);
Status XGetZoomHints(Display*, Window, XSizeHints*);
int XIntersectRegion(Region, Region, Region);
void XConvertCase(KeySym, KeySym*, KeySym*);
int XLookupString(XKeyEvent*, char*, int, KeySym*, XComposeStatus*);
Status XMatchVisualInfo(Display*, int, int, int, XVisualInfo*);
int XSaveContext(Display*, XID, XContext, char*);
int XSetClassHint(Display*, Window, XClassHint*);
int XSetIconSizes(Display*, Window, XIconSize*, int);
int XSetNormalHints(Display*, Window, XSizeHints*);
void XSetWMClientMachine(Display*, Window, XTextProperty*);
int XSetWMHints(Display*, Window, XWMHints*);
void XSetWMIconName(Display*, Window, XTextProperty*);
void XSetWMName(Display*, Window, XTextProperty*);
void XSetWMNormalHints(Display*, Window, XSizeHints*);
void XSetWMProperties(Display*, Window, XTextProperty*, XTextProperty*, char**, int, XSizeHints*, XWMHints*, XClassHint*);
void XmbSetWMProperties(Display*, Window, const(char)*, const(char)*, const(char)**, int, XSizeHints*, XWMHints*, XClassHint*);
void Xutf8SetWMProperties(Display*, Window, char*, char*, char**, int, XSizeHints*, XWMHints*, XClassHint*);
enum XC_cross_reverse = 32;
enum XC_crosshair = 34;
enum XC_diamond_cross = 36;
enum XC_dot = 38;
enum XC_gumby = 56;
enum XC_hand1 = 58;
enum XC_hand2 = 60;
enum XC_heart = 62;
enum XC_icon = 64;
enum XC_iron_cross = 66;
enum XC_left_ptr = 68;
enum XC_left_side = 70;
enum XC_sailboat = 104;
enum XC_sb_down_arrow = 106;
enum XC_sb_h_double_arrow = 108;
enum XC_sb_left_arrow = 110;
enum XC_sb_right_arrow = 112;
enum XC_sb_up_arrow = 114;
enum XC_sb_v_double_arrow = 116;
enum XC_shuttle = 118;
enum XC_xterm = 152;
enum bool XK_MISCELLANY = true;
enum bool XK_XKB_KEYS = true;
enum bool XK_3270 = false;
enum bool XK_LATIN1 = true;
enum bool XK_LATIN2 = true;
enum bool XK_LATIN3 = true;
enum bool XK_LATIN4 = true;
enum bool XK_SINHALA = true;
enum int XK_VoidSymbol = 0xffffff;
static if (XK_MISCELLANY) {
    enum int XK_BackSpace = 0xff08;
    enum int XK_Tab = 0xff09;
    enum int XK_Linefeed = 0xff0a;
    enum int XK_Clear = 0xff0b;
    enum int XK_Return = 0xff0d;
    enum int XK_Pause = 0xff13;
    enum int XK_Scroll_Lock = 0xff14;
    enum int XK_Sys_Req = 0xff15;
    enum int XK_Escape = 0xff1b;
    enum int XK_Delete = 0xffff;
    enum int XK_Multi_key = 0xff20;
    enum int XK_Codeinput = 0xff37;
    enum int XK_SingleCandidate = 0xff3c;
    enum int XK_MultipleCandidate = 0xff3d;
    enum int XK_PreviousCandidate = 0xff3e;
    enum int XK_Kanji = 0xff21;
    enum int XK_Muhenkan = 0xff22;
    enum int XK_Henkan_Mode = 0xff23;
    enum int XK_Henkan = 0xff23;
    enum int XK_Romaji = 0xff24;
    enum int XK_Hiragana = 0xff25;
    enum int XK_Katakana = 0xff26;
    enum int XK_Hiragana_Katakana = 0xff27;
    enum int XK_Zenkaku = 0xff28;
    enum int XK_Hankaku = 0xff29;
    enum int XK_Zenkaku_Hankaku = 0xff2a;
    enum int XK_Touroku = 0xff2b;
    enum int XK_Massyo = 0xff2c;
    enum int XK_Kana_Lock = 0xff2d;
    enum int XK_Kana_Shift = 0xff2e;
    enum int XK_Eisu_Shift = 0xff2f;
    enum int XK_Eisu_toggle = 0xff30;
    enum int XK_Kanji_Bangou = 0xff37;
    enum int XK_Zen_Koho = 0xff3d;
    enum int XK_Mae_Koho = 0xff3e;
    enum int XK_Home = 0xff50;
    enum int XK_Left = 0xff51;
    enum int XK_Up = 0xff52;
    enum int XK_Right = 0xff53;
    enum int XK_Down = 0xff54;
    enum int XK_Prior = 0xff55;
    enum int XK_Page_Up = 0xff55;
    enum int XK_Next = 0xff56;
    enum int XK_Page_Down = 0xff56;
    enum int XK_End = 0xff57;
    enum int XK_Begin = 0xff58;
    enum int XK_Select = 0xff60;
    enum int XK_Print = 0xff61;
    enum int XK_Execute = 0xff62;
    enum int XK_Insert = 0xff63;
    enum int XK_Undo = 0xff65;
    enum int XK_Redo = 0xff66;
    enum int XK_Menu = 0xff67;
    enum int XK_Find = 0xff68;
    enum int XK_Cancel = 0xff69;
    enum int XK_Help = 0xff6a;
    enum int XK_break = 0xff6b;
    enum int XK_Mode_switch = 0xff7e;
    enum int XK_script_switch = 0xff7e;
    enum int XK_Num_Lock = 0xff7f;
    enum int XK_KP_Space = 0xff80;
    enum int XK_KP_Tab = 0xff89;
    enum int XK_KP_Enter = 0xff8d;
    enum int XK_KP_F1 = 0xff91;
    enum int XK_KP_F2 = 0xff92;
    enum int XK_KP_F3 = 0xff93;
    enum int XK_KP_F4 = 0xff94;
    enum int XK_KP_Home = 0xff95;
    enum int XK_KP_Left = 0xff96;
    enum int XK_KP_Up = 0xff97;
    enum int XK_KP_Right = 0xff98;
    enum int XK_KP_Down = 0xff99;
    enum int XK_KP_Prior = 0xff9a;
    enum int XK_KP_Page_Up = 0xff9a;
    enum int XK_KP_Next = 0xff9b;
    enum int XK_KP_Page_Down = 0xff9b;
    enum int XK_KP_End = 0xff9c;
    enum int XK_KP_Begin = 0xff9d;
    enum int XK_KP_Insert = 0xff9e;
    enum int XK_KP_Delete = 0xff9f;
    enum int XK_KP_Equal = 0xffbd;
    enum int XK_KP_Multiply = 0xffaa;
    enum int XK_KP_Add = 0xffab;
    enum int XK_KP_Separator = 0xffac;
    enum int XK_KP_Subtract = 0xffad;
    enum int XK_KP_Decimal = 0xffae;
    enum int XK_KP_Divide = 0xffaf;
    enum int XK_KP_0 = 0xffb0;
    enum int XK_KP_1 = 0xffb1;
    enum int XK_KP_2 = 0xffb2;
    enum int XK_KP_3 = 0xffb3;
    enum int XK_KP_4 = 0xffb4;
    enum int XK_KP_5 = 0xffb5;
    enum int XK_KP_6 = 0xffb6;
    enum int XK_KP_7 = 0xffb7;
    enum int XK_KP_8 = 0xffb8;
    enum int XK_KP_9 = 0xffb9;
    enum int XK_F1 = 0xffbe;
    enum int XK_F2 = 0xffbf;
    enum int XK_F3 = 0xffc0;
    enum int XK_F4 = 0xffc1;
    enum int XK_F5 = 0xffc2;
    enum int XK_F6 = 0xffc3;
    enum int XK_F7 = 0xffc4;
    enum int XK_F8 = 0xffc5;
    enum int XK_F9 = 0xffc6;
    enum int XK_F10 = 0xffc7;
    enum int XK_F11 = 0xffc8;
    enum int XK_L1 = 0xffc8;
    enum int XK_F12 = 0xffc9;
    enum int XK_L2 = 0xffc9;
    enum int XK_F13 = 0xffca;
    enum int XK_L3 = 0xffca;
    enum int XK_F14 = 0xffcb;
    enum int XK_L4 = 0xffcb;
    enum int XK_F15 = 0xffcc;
    enum int XK_L5 = 0xffcc;
    enum int XK_F16 = 0xffcd;
    enum int XK_L6 = 0xffcd;
    enum int XK_F17 = 0xffce;
    enum int XK_L7 = 0xffce;
    enum int XK_F18 = 0xffcf;
    enum int XK_L8 = 0xffcf;
    enum int XK_F19 = 0xffd0;
    enum int XK_L9 = 0xffd0;
    enum int XK_F20 = 0xffd1;
    enum int XK_L10 = 0xffd1;
    enum int XK_F21 = 0xffd2;
    enum int XK_R1 = 0xffd2;
    enum int XK_F22 = 0xffd3;
    enum int XK_R2 = 0xffd3;
    enum int XK_F23 = 0xffd4;
    enum int XK_R3 = 0xffd4;
    enum int XK_F24 = 0xffd5;
    enum int XK_R4 = 0xffd5;
    enum int XK_F25 = 0xffd6;
    enum int XK_R5 = 0xffd6;
    enum int XK_F26 = 0xffd7;
    enum int XK_R6 = 0xffd7;
    enum int XK_F27 = 0xffd8;
    enum int XK_R7 = 0xffd8;
    enum int XK_F28 = 0xffd9;
    enum int XK_R8 = 0xffd9;
    enum int XK_F29 = 0xffda;
    enum int XK_R9 = 0xffda;
    enum int XK_F30 = 0xffdb;
    enum int XK_R10 = 0xffdb;
    enum int XK_F31 = 0xffdc;
    enum int XK_R11 = 0xffdc;
    enum int XK_F32 = 0xffdd;
    enum int XK_R12 = 0xffdd;
    enum int XK_F33 = 0xffde;
    enum int XK_R13 = 0xffde;
    enum int XK_F34 = 0xffdf;
    enum int XK_R14 = 0xffdf;
    enum int XK_F35 = 0xffe0;
    enum int XK_R15 = 0xffe0;
    enum int XK_Shift_L = 0xffe1;
    enum int XK_Shift_R = 0xffe2;
    enum int XK_Control_L = 0xffe3;
    enum int XK_Control_R = 0xffe4;
    enum int XK_Caps_Lock = 0xffe5;
    enum int XK_Shift_Lock = 0xffe6;
    enum int XK_Meta_L = 0xffe7;
    enum int XK_Meta_R = 0xffe8;
    enum int XK_Alt_L = 0xffe9;
    enum int XK_Alt_R = 0xffea;
    enum int XK_Super_L = 0xffeb;
    enum int XK_Super_R = 0xffec;
    enum int XK_Hyper_L = 0xffed;
    enum int XK_Hyper_R = 0xffee;
}
static if (XK_XKB_KEYS) {
    enum int XK_ISO_Lock = 0xfe01;
    enum int XK_ISO_Level2_Latch = 0xfe02;
    enum int XK_ISO_Level3_Shift = 0xfe03; // used
    enum int XK_ISO_Level3_Latch = 0xfe04;
    enum int XK_ISO_Level3_Lock = 0xfe05;
    enum int XK_ISO_Level5_Shift = 0xfe11;
    enum int XK_ISO_Level5_Latch = 0xfe12;
    enum int XK_ISO_Level5_Lock = 0xfe13;
    enum int XK_ISO_Group_Shift = 0xff7e;
    enum int XK_ISO_Group_Latch = 0xfe06;
    enum int XK_ISO_Group_Lock = 0xfe07;
    enum int XK_ISO_Next_Group = 0xfe08;
    enum int XK_ISO_Next_Group_Lock = 0xfe09;
    enum int XK_ISO_Prev_Group = 0xfe0a;
    enum int XK_ISO_Prev_Group_Lock = 0xfe0b;
    enum int XK_ISO_First_Group = 0xfe0c;
    enum int XK_ISO_First_Group_Lock = 0xfe0d;
    enum int XK_ISO_Last_Group = 0xfe0e;
    enum int XK_ISO_Last_Group_Lock = 0xfe0f;
    enum int XK_ISO_Left_Tab = 0xfe20;
    enum int XK_ISO_Move_Line_Up = 0xfe21;
    enum int XK_ISO_Move_Line_Down = 0xfe22;
    enum int XK_ISO_Partial_Line_Up = 0xfe23;
    enum int XK_ISO_Partial_Line_Down = 0xfe24;
    enum int XK_ISO_Partial_Space_Left = 0xfe25;
    enum int XK_ISO_Partial_Space_Right = 0xfe26;
    enum int XK_ISO_Set_Margin_Left = 0xfe27;
    enum int XK_ISO_Set_Margin_Right = 0xfe28;
    enum int XK_ISO_Release_Margin_Left = 0xfe29;
    enum int XK_ISO_Release_Margin_Right = 0xfe2a;
    enum int XK_ISO_Release_Both_Margins = 0xfe2b;
    enum int XK_ISO_Fast_Cursor_Left = 0xfe2c;
    enum int XK_ISO_Fast_Cursor_Right = 0xfe2d;
    enum int XK_ISO_Fast_Cursor_Up = 0xfe2e;
    enum int XK_ISO_Fast_Cursor_Down = 0xfe2f;
    enum int XK_ISO_Continuous_Underline = 0xfe30;
    enum int XK_ISO_Discontinuous_Underline = 0xfe31;
    enum int XK_ISO_Emphasize = 0xfe32;
    enum int XK_ISO_Center_Object = 0xfe33;
    enum int XK_ISO_Enter = 0xfe34;
    enum int XK_dead_grave = 0xfe50;
    enum int XK_dead_acute = 0xfe51;
    enum int XK_dead_circumflex = 0xfe52;
    enum int XK_dead_tilde = 0xfe53;
    enum int XK_dead_perispomeni = 0xfe53;
    enum int XK_dead_macron = 0xfe54;
    enum int XK_dead_breve = 0xfe55;
    enum int XK_dead_abovedot = 0xfe56;
    enum int XK_dead_diaeresis = 0xfe57;
    enum int XK_dead_abovering = 0xfe58;
    enum int XK_dead_doubleacute = 0xfe59;
    enum int XK_dead_caron = 0xfe5a;
    enum int XK_dead_cedilla = 0xfe5b;
    enum int XK_dead_ogonek = 0xfe5c;
    enum int XK_dead_iota = 0xfe5d;
    enum int XK_dead_voiced_sound = 0xfe5e;
    enum int XK_dead_semivoiced_sound = 0xfe5f;
    enum int XK_dead_belowdot = 0xfe60;
    enum int XK_dead_hook = 0xfe61;
    enum int XK_dead_horn = 0xfe62;
    enum int XK_dead_stroke = 0xfe63;
    enum int XK_dead_abovecomma = 0xfe64;
    enum int XK_dead_psili = 0xfe64;
    enum int XK_dead_abovereversedcomma = 0xfe65;
    enum int XK_dead_dasia = 0xfe65;
    enum int XK_dead_doublegrave = 0xfe66;
    enum int XK_dead_belowring = 0xfe67;
    enum int XK_dead_belowmacron = 0xfe68;
    enum int XK_dead_belowcircumflex = 0xfe69;
    enum int XK_dead_belowtilde = 0xfe6a;
    enum int XK_dead_belowbreve = 0xfe6b;
    enum int XK_dead_belowdiaeresis = 0xfe6c;
    enum int XK_dead_invertedbreve = 0xfe6d;
    enum int XK_dead_belowcomma = 0xfe6e;
    enum int XK_dead_currency = 0xfe6f;
    enum int XK_dead_a = 0xfe80;
    enum int XK_dead_A = 0xfe81;
    enum int XK_dead_e = 0xfe82;
    enum int XK_dead_E = 0xfe83;
    enum int XK_dead_i = 0xfe84;
    enum int XK_dead_I = 0xfe85;
    enum int XK_dead_o = 0xfe86;
    enum int XK_dead_O = 0xfe87;
    enum int XK_dead_u = 0xfe88;
    enum int XK_dead_U = 0xfe89;
    enum int XK_dead_small_schwa = 0xfe8a;
    enum int XK_dead_capital_schwa = 0xfe8b;
    enum int XK_First_Virtual_Screen = 0xfed0;
    enum int XK_Prev_Virtual_Screen = 0xfed1;
    enum int XK_Next_Virtual_Screen = 0xfed2;
    enum int XK_Last_Virtual_Screen = 0xfed4;
    enum int XK_Terminate_Server = 0xfed5;
    enum int XK_AccessX_Enable = 0xfe70;
    enum int XK_AccessX_Feedback_Enable = 0xfe71;
    enum int XK_RepeatKeys_Enable = 0xfe72;
    enum int XK_SlowKeys_Enable = 0xfe73;
    enum int XK_BounceKeys_Enable = 0xfe74;
    enum int XK_StickyKeys_Enable = 0xfe75;
    enum int XK_MouseKeys_Enable = 0xfe76;
    enum int XK_MouseKeys_Accel_Enable = 0xfe77;
    enum int XK_Overlay1_Enable = 0xfe78;
    enum int XK_Overlay2_Enable = 0xfe79;
    enum int XK_AudibleBell_Enable = 0xfe7a;
    enum int XK_Pointer_Left = 0xfee0;
    enum int XK_Pointer_Right = 0xfee1;
    enum int XK_Pointer_Up = 0xfee2;
    enum int XK_Pointer_Down = 0xfee3;
    enum int XK_Pointer_UpLeft = 0xfee4;
    enum int XK_Pointer_UpRight = 0xfee5;
    enum int XK_Pointer_DownLeft = 0xfee6;
    enum int XK_Pointer_DownRight = 0xfee7;
    enum int XK_Pointer_Button_Dflt = 0xfee8;
    enum int XK_Pointer_Button1 = 0xfee9;
    enum int XK_Pointer_Button2 = 0xfeea;
    enum int XK_Pointer_Button3 = 0xfeeb;
    enum int XK_Pointer_Button4 = 0xfeec;
    enum int XK_Pointer_Button5 = 0xfeed;
    enum int XK_Pointer_DblClick_Dflt = 0xfeee;
    enum int XK_Pointer_DblClick1 = 0xfeef;
    enum int XK_Pointer_DblClick2 = 0xfef0;
    enum int XK_Pointer_DblClick3 = 0xfef1;
    enum int XK_Pointer_DblClick4 = 0xfef2;
    enum int XK_Pointer_DblClick5 = 0xfef3;
    enum int XK_Pointer_Drag_Dflt = 0xfef4;
    enum int XK_Pointer_Drag1 = 0xfef5;
    enum int XK_Pointer_Drag2 = 0xfef6;
    enum int XK_Pointer_Drag3 = 0xfef7;
    enum int XK_Pointer_Drag4 = 0xfef8;
    enum int XK_Pointer_Drag5 = 0xfefd;
    enum int XK_Pointer_EnableKeys = 0xfef9;
    enum int XK_Pointer_Accelerate = 0xfefa;
    enum int XK_Pointer_DfltBtnNext = 0xfefb;
    enum int XK_Pointer_DfltBtnPrev = 0xfefc;
}
static if (XK_LATIN1) {
    enum int XK_space = 0x0020;
    enum int XK_exclam = 0x0021;
    enum int XK_quotedbl = 0x0022;
    enum int XK_numbersign = 0x0023;
    enum int XK_dollar = 0x0024;
    enum int XK_percent = 0x0025;
    enum int XK_ampersand = 0x0026;
    enum int XK_apostrophe = 0x0027;
    enum int XK_quoteright = 0x0027;
    enum int XK_parenleft = 0x0028;
    enum int XK_parenright = 0x0029;
    enum int XK_asterisk = 0x002a;
    enum int XK_plus = 0x002b;
    enum int XK_comma = 0x002c;
    enum int XK_minus = 0x002d;
    enum int XK_period = 0x002e;
    enum int XK_slash = 0x002f;
    enum int XK_0 = 0x0030;
    enum int XK_1 = 0x0031;
    enum int XK_2 = 0x0032;
    enum int XK_3 = 0x0033;
    enum int XK_4 = 0x0034;
    enum int XK_5 = 0x0035;
    enum int XK_6 = 0x0036;
    enum int XK_7 = 0x0037;
    enum int XK_8 = 0x0038;
    enum int XK_9 = 0x0039;
    enum int XK_colon = 0x003a;
    enum int XK_semicolon = 0x003b;
    enum int XK_less = 0x003c;
    enum int XK_equal = 0x003d;
    enum int XK_greater = 0x003e;
    enum int XK_question = 0x003f;
    enum int XK_at = 0x0040;
    enum int XK_A = 0x0041;
    enum int XK_B = 0x0042;
    enum int XK_C = 0x0043;
    enum int XK_D = 0x0044;
    enum int XK_E = 0x0045;
    enum int XK_F = 0x0046;
    enum int XK_G = 0x0047;
    enum int XK_H = 0x0048;
    enum int XK_I = 0x0049;
    enum int XK_J = 0x004a;
    enum int XK_K = 0x004b;
    enum int XK_L = 0x004c;
    enum int XK_M = 0x004d;
    enum int XK_N = 0x004e;
    enum int XK_O = 0x004f;
    enum int XK_P = 0x0050;
    enum int XK_Q = 0x0051;
    enum int XK_R = 0x0052;
    enum int XK_S = 0x0053;
    enum int XK_T = 0x0054;
    enum int XK_U = 0x0055;
    enum int XK_V = 0x0056;
    enum int XK_W = 0x0057;
    enum int XK_X = 0x0058;
    enum int XK_Y = 0x0059;
    enum int XK_Z = 0x005a;
    enum int XK_bracketleft = 0x005b;
    enum int XK_backslash = 0x005c;
    enum int XK_bracketright = 0x005d;
    enum int XK_asciicircum = 0x005e;
    enum int XK_underscore = 0x005f;
    enum int XK_grave = 0x0060;
    enum int XK_quoteleft = 0x0060;
    enum int XK_a = 0x0061;
    enum int XK_b = 0x0062;
    enum int XK_c = 0x0063;
    enum int XK_d = 0x0064;
    enum int XK_e = 0x0065;
    enum int XK_f = 0x0066;
    enum int XK_g = 0x0067;
    enum int XK_h = 0x0068;
    enum int XK_i = 0x0069;
    enum int XK_j = 0x006a;
    enum int XK_k = 0x006b;
    enum int XK_l = 0x006c;
    enum int XK_m = 0x006d;
    enum int XK_n = 0x006e;
    enum int XK_o = 0x006f;
    enum int XK_p = 0x0070;
    enum int XK_q = 0x0071;
    enum int XK_r = 0x0072;
    enum int XK_s = 0x0073;
    enum int XK_t = 0x0074;
    enum int XK_u = 0x0075;
    enum int XK_v = 0x0076;
    enum int XK_w = 0x0077;
    enum int XK_x = 0x0078;
    enum int XK_y = 0x0079;
    enum int XK_z = 0x007a;
    enum int XK_braceleft = 0x007b;
    enum int XK_bar = 0x007c;
    enum int XK_braceright = 0x007d;
    enum int XK_asciitilde = 0x007e;
    enum int XK_nobreakspace = 0x00a0;
    enum int XK_exclamdown = 0x00a1;
    enum int XK_cent = 0x00a2;
    enum int XK_sterling = 0x00a3;
    enum int XK_currency = 0x00a4;
    enum int XK_yen = 0x00a5;
    enum int XK_brokenbar = 0x00a6;
    enum int XK_section = 0x00a7;
    enum int XK_diaeresis = 0x00a8;
    enum int XK_copyright = 0x00a9;
    enum int XK_ordfeminine = 0x00aa;
    enum int XK_guillemotleft = 0x00ab;
    enum int XK_notsign = 0x00ac;
    enum int XK_hyphen = 0x00ad;
    enum int XK_registered = 0x00ae;
    enum int XK_macron = 0x00af;
    enum int XK_degree = 0x00b0;
    enum int XK_plusminus = 0x00b1;
    enum int XK_twosuperior = 0x00b2;
    enum int XK_threesuperior = 0x00b3;
    enum int XK_acute = 0x00b4;
    enum int XK_mu = 0x00b5;
    enum int XK_paragraph = 0x00b6;
    enum int XK_periodcentered = 0x00b7;
    enum int XK_cedilla = 0x00b8;
    enum int XK_onesuperior = 0x00b9;
    enum int XK_masculine = 0x00ba;
    enum int XK_guillemotright = 0x00bb;
    enum int XK_onequarter = 0x00bc;
    enum int XK_onehalf = 0x00bd;
    enum int XK_threequarters = 0x00be;
    enum int XK_questiondown = 0x00bf;
    enum int XK_Agrave = 0x00c0;
    enum int XK_Aacute = 0x00c1;
    enum int XK_Acircumflex = 0x00c2;
    enum int XK_Atilde = 0x00c3;
    enum int XK_Adiaeresis = 0x00c4;
    enum int XK_Aring = 0x00c5;
    enum int XK_AE = 0x00c6;
    enum int XK_Ccedilla = 0x00c7;
    enum int XK_Egrave = 0x00c8;
    enum int XK_Eacute = 0x00c9;
    enum int XK_Ecircumflex = 0x00ca;
    enum int XK_Ediaeresis = 0x00cb;
    enum int XK_Igrave = 0x00cc;
    enum int XK_Iacute = 0x00cd;
    enum int XK_Icircumflex = 0x00ce;
    enum int XK_Idiaeresis = 0x00cf;
    enum int XK_ETH = 0x00d0;
    enum int XK_Eth = 0x00d0;
    enum int XK_Ntilde = 0x00d1;
    enum int XK_Ograve = 0x00d2;
    enum int XK_Oacute = 0x00d3;
    enum int XK_Ocircumflex = 0x00d4;
    enum int XK_Otilde = 0x00d5;
    enum int XK_Odiaeresis = 0x00d6;
    enum int XK_multiply = 0x00d7;
    enum int XK_Oslash = 0x00d8;
    enum int XK_Ooblique = 0x00d8;
    enum int XK_Ugrave = 0x00d9;
    enum int XK_Uacute = 0x00da;
    enum int XK_Ucircumflex = 0x00db;
    enum int XK_Udiaeresis = 0x00dc;
    enum int XK_Yacute = 0x00dd;
    enum int XK_THORN = 0x00de;
    enum int XK_Thorn = 0x00de;
    enum int XK_ssharp = 0x00df;
    enum int XK_agrave = 0x00e0;
    enum int XK_aacute = 0x00e1;
    enum int XK_acircumflex = 0x00e2;
    enum int XK_atilde = 0x00e3;
    enum int XK_adiaeresis = 0x00e4;
    enum int XK_aring = 0x00e5;
    enum int XK_ae = 0x00e6;
    enum int XK_ccedilla = 0x00e7;
    enum int XK_egrave = 0x00e8;
    enum int XK_eacute = 0x00e9;
    enum int XK_ecircumflex = 0x00ea;
    enum int XK_ediaeresis = 0x00eb;
    enum int XK_igrave = 0x00ec;
    enum int XK_iacute = 0x00ed;
    enum int XK_icircumflex = 0x00ee;
    enum int XK_idiaeresis = 0x00ef;
    enum int XK_eth = 0x00f0;
    enum int XK_ntilde = 0x00f1;
    enum int XK_ograve = 0x00f2;
    enum int XK_oacute = 0x00f3;
    enum int XK_ocircumflex = 0x00f4;
    enum int XK_otilde = 0x00f5;
    enum int XK_odiaeresis = 0x00f6;
    enum int XK_division = 0x00f7;
    enum int XK_oslash = 0x00f8;
    enum int XK_ooblique = 0x00f8;
    enum int XK_ugrave = 0x00f9;
    enum int XK_uacute = 0x00fa;
    enum int XK_ucircumflex = 0x00fb;
    enum int XK_udiaeresis = 0x00fc;
    enum int XK_yacute = 0x00fd;
    enum int XK_thorn = 0x00fe;
    enum int XK_ydiaeresis = 0x00ff;
}
template XIClearMask(string ptr, int event) {
    const ubyte XIClearMask = cast(ubyte)(ptr[(event) >> 3] &= ~(1 << ((event) & 7)));
}
auto XIMaskIsSet(T, U)(T ptr, U event) {
    return cast(ubyte)((cast(ubyte*) ptr)[(event) >> 3] & (1 << ((event) & 7)));
}
auto XIMaskIsSet(T)(T event) {
    return (((event) >> 3) + 1);
}
auto XIMaskLen(T)(T event) {
    return (((event) >> 3) + 1);
}
enum {
    XIAllDevices = 0,
    XIAllMasterDevices = 1
}
enum {
    XI_DeviceChanged = 1,
    XI_KeyPress = 2,
    XI_KeyRelease = 3,
    XI_ButtonPress = 4,
    XI_ButtonRelease = 5,
    XI_Motion = 6,
    XI_Enter = 7,
    XI_Leave = 8,
    XI_FocusIn = 9,
    XI_FocusOut = 10,
    XI_HierarchyChanged = 11,
    XI_PropertyEvent = 12,
    XI_RawKeyPress = 13,
    XI_RawKeyRelease = 14,
    XI_RawButtonPress = 15,
    XI_RawButtonRelease = 16,
    XI_RawMotion = 17,
    XI_LASTEVENT = XI_RawMotion
}
enum {
    XI_DeviceChangedMask = (1 << XI_DeviceChanged),
    XI_KeyPressMask = (1 << XI_KeyPress),
    XI_KeyReleaseMask = (1 << XI_KeyRelease),
    XI_ButtonPressMask = (1 << XI_ButtonPress),
    XI_ButtonReleaseMask = (1 << XI_ButtonRelease),
    XI_MotionMask = (1 << XI_Motion),
    XI_EnterMask = (1 << XI_Enter),
    XI_LeaveMask = (1 << XI_Leave),
    XI_FocusInMask = (1 << XI_FocusIn),
    XI_FocusOutMask = (1 << XI_FocusOut),
    XI_HierarchyChangedMask = (1 << XI_HierarchyChanged),
    XI_PropertyEventMask = (1 << XI_PropertyEvent),
    XI_RawKeyPressMask = (
            1 << XI_RawKeyPress),
    XI_RawKeyReleaseMask = (1 << XI_RawKeyRelease),
    XI_RawButtonPressMask = (1 << XI_RawButtonPress),
    XI_RawButtonReleaseMask = (
            1 << XI_RawButtonRelease),
    XI_RawMotionMask = (1 << XI_RawMotion)
}
enum _deviceKeyPress = 0;
struct XDeviceCoreState {
    XID control;
    int length;
    int status;
    int iscore;
}
struct XDeviceEnableControl {
    XID control;
    int length;
    int enable;
}
alias XDeviceEnableState = XDeviceEnableControl;
struct XAnyClassInfo {
    XID class_;
    int length;
}
alias XAnyClassPtr = XAnyClassInfo*;
struct XDeviceInfo {
    XID id;
    Atom type;
    char* name;
    int num_classes;
    int use;
    XAnyClassPtr inputclassinfo;
}
alias XDeviceInfoPtr = XDeviceInfo*;
struct XKeyInfo {
    XID class_;
    int length;
    ushort min_keycode;
    ushort max_keycode;
    ushort num_keys;
}
alias XKeyInfoPtr = XKeyInfo*;
struct XButtonInfo {
    XID class_;
    int length;
    short num_buttons;
}
alias XButtonInfoPtr = XButtonInfo*;
alias XAxisInfoPtr = XAxisInfo*;
struct XAxisInfo {
    int resolution;
    int min_value;
    int max_value;
}
alias XValuatorInfoPtr = XValuatorInfo*;
struct XValuatorInfo {
    XID class_;
    int length;
    ubyte num_axes;
    ubyte mode;
    ulong motion_buffer;
    XAxisInfoPtr axes;
}
struct XInputClassInfo {
    ubyte input_class;
    ubyte event_type_base;
}
struct XIAddMasterInfo {
    int type;
    char* name;
    Bool send_core;
    Bool enable;
}
struct XIRemoveMasterInfo {
    int type;
    int deviceid;
    int return_mode;
    int return_pointer;
    int return_keyboard;
}
struct XIAttachSlaveInfo {
    int type;
    int deviceid;
    int new_master;
}
struct XIDetachSlaveInfo {
    int type;
    int deviceid;
}
union XIAnyHierarchyChangeInfo {
    int type;
    XIAddMasterInfo add;
    XIRemoveMasterInfo remove;
    XIAttachSlaveInfo attach;
    XIDetachSlaveInfo detach;
}
struct XIModifierState {
    int base;
    int latched;
    int locked;
    int effective;
}
alias XIModifierState XIGroupState;
struct XIButtonState {
    int mask_len;
    ubyte* mask;
}
struct XIValuatorState {
    int mask_len;
    ubyte mask;
    double* values;
}
struct XIEventMask {
    int deviceid;
    int mask_len;
    ubyte* mask;
}
struct XIAnyClassInfo {
    int type;
    int sourceid;
}
struct XIButtonClassInfo {
    int type;
    int sourceid;
    int num_buttons;
    Atom* labels;
    XIButtonState state;
}
struct XIDeviceEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    int extension;
    int evtype;
    Time time;
    int deviceid;
    int sourceid;
    int detail;
    Window root;
    Window event;
    Window child;
    double root_x = 0.0;
    double root_y = 0.0;
    double event_x = 0.0;
    double event_y = 0.0;
    int flags;
    XIButtonState buttons;
    XIValuatorState valuators;
    XIModifierState mods;
    XIGroupState group;
}
struct XIRawEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    int extension;
    int evtype;
    Time time;
    int deviceid;
    int sourceid;
    int detail;
    int flags;
    XIValuatorState valuators;
    double* raw_values;
}
struct XIEnterEvent {
    int type;
    c_ulong serial;
    Bool send_event;
    Display* display;
    int extension;
    int evtype;
    Time time;
    int deviceid;
    int sourceid;
    int detail;
    Window root;
    Window event;
    Window child;
    double root_x = 0;
    double root_y = 0;
    double event_x = 0;
    double event_y = 0;
    int mode;
    Bool focus;
    Bool same_screen;
    XIButtonState buttons;
    XIModifierState mods;
    XIGroupState group;
}
alias XIEnterEvent XILeaveEvent;
enum X_kbSetDeviceInfo = 25;
enum X_kbSetDebuggingFlags = 101;
enum XkbEventCode = 0;
enum XkbNumberEvents = (XkbEventCode + 1);
enum XkbNewKeyboardNotify = 0;
enum XkbMapNotify = 1;
enum XkbStateNotify = 2;
enum XkbControlsNotify = 3;
enum XkbModifierLockMask = (1L << 3);
enum XkbGroupStateMask = (1L << 4);
enum XkbGroupBaseMask = (1L << 5);
enum XkbGroupLatchMask = (1L << 6);
enum XkbLookupModsMask = (1L << 11);
enum XkbCompatLookupModsMask = (1L << 12);
enum XkbPointerButtonMask = (1L << 13);
enum XkbAllStateComponentsMask = (0x3fff);
enum XkbUseCoreKbd = 0x0100;
enum XkbUseCorePtr = 0x0200;
enum XkbDfltXIClass = 0x0300;
enum XkbDfltXIId = 0x0400;
enum XkbAllVirtualModsMask = 0xffff;
enum XkbNumKbdGroups = 4;
enum XkbMaxKbdGroup = (XkbNumKbdGroups - 1);
enum XkbMaxMouseKeysBtn = 4;
enum XkbKB_Overlay1 = 0x03;
enum XkbKB_Overlay2 = 0x04;
enum XkbKB_RGAllowNone = 0x80;
enum XkbMinLegalKeyCode = 8;
enum XkbMaxLegalKeyCode = 255;
enum XkbMaxKeyCount = (XkbMaxLegalKeyCode - XkbMinLegalKeyCode + 1);
enum XkbPerKeyBitArraySize = ((XkbMaxLegalKeyCode + 1) / 8);
enum XkbNumModifiers = 8;
enum XkbNumVirtualMods = 16;
enum XkbNumIndicators = 32;
enum XkbAllIndicatorsMask = (0xffffffff);
enum XkbRGMaxMembers = 12;
enum XkbActionMessageLength = 6;
enum XkbKeyNameLength = 4;
enum XkbMaxRedirectCount = 8;
enum XkbKTLevelNamesMask = (1 << 7);
enum XkbIndicatorNamesMask = (1 << 8);
enum XkbKeyNamesMask = (1 << 9);
enum XkbKeyAliasesMask = (1 << 10);
struct _xkbAnyEvent {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 pad1;
    CARD16 pad2;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
    CARD32 pad6;
    CARD32 pad7;
}
alias _xkbAnyEvent xkbAnyEvent;
enum sz_xkbAnyEvent = 32;
struct _xkbNewKeyboardNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 oldDeviceID;
    KeyCode minKeyCode;
    KeyCode maxKeyCode;
    KeyCode oldMinKeyCode;
    KeyCode oldMaxKeyCode;
    CARD8 requestMajor;
    CARD8 requestMinor;
    CARD16 changed;
    CARD8 detail;
    CARD8 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
}
alias _xkbNewKeyboardNotify xkbNewKeyboardNotify;
enum sz_xkbNewKeyboardNotify = 32;
struct _xkbMapNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 ptrBtnActions;
    CARD16 changed;
    KeyCode minKeyCode;
    KeyCode maxKeyCode;
    CARD8 firstType;
    CARD8 nTypes;
    KeyCode firstKeySym;
    CARD8 nKeySyms;
    KeyCode firstKeyAct;
    CARD8 nKeyActs;
    KeyCode firstKeyBehavior;
    CARD8 nKeyBehaviors;
    KeyCode firstKeyExplicit;
    CARD8 nKeyExplicit;
    KeyCode firstModMapKey;
    CARD8 nModMapKeys;
    KeyCode firstVModMapKey;
    CARD8 nVModMapKeys;
    CARD16 virtualMods;
    CARD16 pad1;
}
alias _xkbMapNotify xkbMapNotify;
enum sz_xkbMapNotify = 32;
struct _xkbStateNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 mods;
    CARD8 baseMods;
    CARD8 latchedMods;
    CARD8 lockedMods;
    CARD8 group;
    INT16 baseGroup;
    INT16 latchedGroup;
    CARD8 lockedGroup;
    CARD8 compatState;
    CARD8 grabMods;
    CARD8 compatGrabMods;
    CARD8 lookupMods;
    CARD8 compatLookupMods;
    CARD16 ptrBtnState;
    CARD16 changed;
    KeyCode keycode;
    CARD8 eventType;
    CARD8 requestMajor;
    CARD8 requestMinor;
}
alias _xkbStateNotify xkbStateNotify;
enum sz_xkbStateNotify = 32;
struct _xkbControlsNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 numGroups;
    CARD16 pad1;
    CARD32 changedControls;
    CARD32 enabledControls;
    CARD32 enabledControlChanges;
    KeyCode keycode;
    CARD8 eventType;
    CARD8 requestMajor;
    CARD8 requestMinor;
    CARD32 pad2;
}
alias _xkbControlsNotify xkbControlsNotify;
enum sz_xkbControlsNotify = 32;
struct _xkbIndicatorNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 pad1;
    CARD16 pad2;
    CARD32 state;
    CARD32 changed;
    CARD32 pad3;
    CARD32 pad4;
    CARD32 pad5;
}
alias _xkbIndicatorNotify xkbIndicatorNotify;
enum sz_xkbIndicatorNotify = 32;
struct _xkbNamesNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 pad1;
    CARD16 changed;
    CARD8 firstType;
    CARD8 nTypes;
    CARD8 firstLevelName;
    CARD8 nLevelNames;
    CARD8 pad2;
    CARD8 nRadioGroups;
    CARD8 nAliases;
    CARD8 changedGroupNames;
    CARD16 changedVirtualMods;
    CARD8 firstKey;
    CARD8 nKeys;
    CARD32 changedIndicators;
    CARD32 pad3;
}
alias _xkbNamesNotify xkbNamesNotify;
enum sz_xkbNamesNotify = 32;
struct _xkbCompatMapNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 changedGroups;
    CARD16 firstSI;
    CARD16 nSI;
    CARD16 nTotalSI;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
}
alias _xkbCompatMapNotify xkbCompatMapNotify;
enum sz_xkbCompatMapNotify = 32;
struct _xkbBellNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 bellClass;
    CARD8 bellID;
    CARD8 percent;
    CARD16 pitch;
    CARD16 duration;
    Atom name;
    Window window;
    BOOL eventOnly;
    CARD8 pad1;
    CARD16 pad2;
    CARD32 pad3;
}
alias _xkbBellNotify xkbBellNotify;
enum sz_xkbBellNotify = 32;
struct _xkbActionMessage {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    KeyCode keycode;
    BOOL press;
    BOOL keyEventFollows;
    CARD8 mods;
    CARD8 group;
    CARD8[8] message;
    CARD16 pad1;
    CARD32 pad2;
    CARD32 pad3;
}
alias _xkbActionMessage xkbActionMessage;
enum sz_xkbActionMessage = 32;
struct _xkbAccessXNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    KeyCode keycode;
    CARD16 detail;
    CARD16 slowKeysDelay;
    CARD16 debounceDelay;
    CARD32 pad1;
    CARD32 pad2;
    CARD32 pad3;
    CARD32 pad4;
}
alias _xkbAccessXNotify xkbAccessXNotify;
enum sz_xkbAccessXNotify = 32;
struct _xkbExtensionDeviceNotify {
    BYTE type;
    BYTE xkbType;
    CARD16 sequenceNumber;
    Time time;
    CARD8 deviceID;
    CARD8 pad1;
    CARD16 reason;
    CARD16 ledClass;
    CARD16 ledID;
    CARD32 ledsDefined;
    CARD32 ledState;
    CARD8 firstBtn;
    CARD8 nBtns;
    CARD16 supported;
    CARD16 unsupported;
    CARD16 pad3;
}
alias _xkbExtensionDeviceNotify xkbExtensionDeviceNotify;
enum sz_xkbExtensionDeviceNotify = 32;
struct _xkbEvent {
    union _U {
        xkbAnyEvent any;
        xkbNewKeyboardNotify new_kbd;
        xkbMapNotify map;
        xkbStateNotify state;
        xkbControlsNotify ctrls;
        xkbIndicatorNotify indicators;
        xkbNamesNotify names;
        xkbCompatMapNotify compat;
        xkbBellNotify bell;
        xkbActionMessage message;
        xkbAccessXNotify accessx;
        xkbExtensionDeviceNotify device;
    }
    _U u;
}
alias _xkbEvent xkbEvent;
enum sz_xkbEvent = 32;
/// Translated from C to D
struct _XkbStateRec {
    ubyte group;
    ubyte locked_group;
    ushort base_group;
    ushort latched_group;
    ubyte mods;
    ubyte base_mods;
    ubyte latched_mods;
    ubyte locked_mods;
    ubyte compat_state;
    ubyte grab_mods;
    ubyte compat_grab_mods;
    ubyte lookup_mods;
    ubyte compat_lookup_mods;
    ushort ptr_buttons;
}
alias _XkbStateRec XkbStateRec;
alias _XkbStateRec* XkbStatePtr;
struct _XkbMods {
    ubyte mask;
    ubyte real_mods;
    ushort vmods;
}
alias _XkbMods XkbModsRec;
alias _XkbMods* XkbModsPtr;
struct _XkbKTMapEntry {
    Bool active;
    ubyte level;
    XkbModsRec mods;
}
alias _XkbKTMapEntry XkbKTMapEntryRec;
alias _XkbKTMapEntry* XkbKTMapEntryPtr;
struct _XkbKeyType {
    XkbModsRec mods;
    ubyte num_levels;
    ubyte map_count;
    XkbKTMapEntryPtr map;
    XkbModsPtr preserve;
    Atom name;
    Atom* level_names;
}
alias _XkbKeyType XkbKeyTypeRec;
alias _XkbKeyType* XkbKeyTypePtr;
struct _XkbBehavior {
    ubyte type;
    ubyte data;
}
alias _XkbBehavior XkbBehavior;
enum XkbAnyActionDataSize = 7;
struct _XkbAnyAction {
    ubyte type;
    ubyte[XkbAnyActionDataSize] data;
}
alias _XkbAnyAction XkbAnyAction;
struct _XkbModAction {
    ubyte type;
    ubyte flags;
    ubyte mask;
    ubyte real_mods;
    ubyte vmods1;
    ubyte vmods2;
}
alias _XkbModAction XkbModAction;
struct _XkbGroupAction {
    ubyte type;
    ubyte flags;
    char group_XXX;
}
alias _XkbGroupAction XkbGroupAction;
struct _XkbISOAction {
    ubyte type;
    ubyte flags;
    ubyte mask;
    ubyte real_mods;
    char group_XXX;
    ubyte affect;
    ubyte vmods1;
    ubyte vmods2;
}
alias _XkbISOAction XkbISOAction;
struct _XkbPtrAction {
    ubyte type;
    ubyte flags;
    ubyte high_XXX;
    ubyte low_XXX;
    ubyte high_YYY;
    ubyte low_YYY;
}
alias _XkbPtrAction XkbPtrAction;
struct _XkbPtrBtnAction {
    ubyte type;
    ubyte flags;
    ubyte count;
    ubyte button;
}
alias _XkbPtrBtnAction XkbPtrBtnAction;
struct _XkbPtrDfltAction {
    ubyte type;
    ubyte flags;
    ubyte affect;
    char valueXXX;
}
alias _XkbPtrDfltAction XkbPtrDfltAction;
struct _XkbSwitchScreenAction {
    ubyte type;
    ubyte flags;
    char screenXXX;
}
alias _XkbSwitchScreenAction XkbSwitchScreenAction;
struct _XkbCtrlsAction {
    ubyte type;
    ubyte flags;
    ubyte ctrls3;
    ubyte ctrls2;
    ubyte ctrls1;
    ubyte ctrls0;
}
alias _XkbCtrlsAction XkbCtrlsAction;
struct _XkbMessageAction {
    ubyte type;
    ubyte flags;
    ubyte[6] message;
}
alias _XkbMessageAction XkbMessageAction;
struct _XkbRedirectKeyAction {
    ubyte type;
    ubyte new_key;
    ubyte mods_mask;
    ubyte mods;
    ubyte vmods_mask0;
    ubyte vmods_mask1;
    ubyte vmods0;
    ubyte vmods1;
}
alias _XkbRedirectKeyAction XkbRedirectKeyAction;
struct _XkbDeviceBtnAction {
    ubyte type;
    ubyte flags;
    ubyte count;
    ubyte button;
    ubyte device;
}
alias _XkbDeviceBtnAction XkbDeviceBtnAction;
struct _XkbDeviceValuatorAction {
    ubyte type;
    ubyte device;
    ubyte v1_what;
    ubyte v1_ndx;
    ubyte v1_value;
    ubyte v2_what;
    ubyte v2_ndx;
    ubyte v2_value;
}
alias _XkbDeviceValuatorAction XkbDeviceValuatorAction;
union _XkbAction {
    XkbAnyAction any;
    XkbModAction mods;
    XkbGroupAction group;
    XkbISOAction iso;
    XkbPtrAction ptr;
    XkbPtrBtnAction btn;
    XkbPtrDfltAction dflt;
    XkbSwitchScreenAction screen;
    XkbCtrlsAction ctrls;
    XkbMessageAction msg;
    XkbRedirectKeyAction redirect;
    XkbDeviceBtnAction devbtn;
    XkbDeviceValuatorAction devval;
    ubyte type;
}
alias _XkbAction XkbAction;
struct _XkbControls {
    ubyte mk_dflt_btn;
    ubyte num_groups;
    ubyte groups_wrap;
    XkbModsRec internal;
    XkbModsRec ignore_lock;
    uint enabled_ctrls;
    ushort repeat_delay;
    ushort repeat_interval;
    ushort slow_keys_delay;
    ushort debounce_delay;
    ushort mk_delay;
    ushort mk_interval;
    ushort mk_time_to_max;
    ushort mk_max_speed;
    short mk_curve;
    ushort ax_options;
    ushort ax_timeout;
    ushort axt_opts_mask;
    ushort axt_opts_values;
    uint axt_ctrls_mask;
    uint axt_ctrls_values;
    ubyte[XkbPerKeyBitArraySize] per_key_repeat;
}
alias _XkbControls XkbControlsRec;
alias _XkbControls* XkbControlsPtr;
struct _XkbServerMapRec {
    ushort num_acts;
    ushort size_acts;
    XkbAction* acts;
    XkbBehavior* behaviors;
    ushort* key_acts;
    ubyte* explicit;
    ubyte[XkbNumVirtualMods] vmods;
    ushort* vmodmap;
}
alias _XkbServerMapRec XkbServerMapRec;
alias _XkbServerMapRec* XkbServerMapPtr;
struct _XkbSymMapRec {
    ubyte[XkbNumKbdGroups] kt_index;
    ubyte group_info;
    ubyte width;
    ushort offset;
}
alias _XkbSymMapRec XkbSymMapRec;
alias _XkbSymMapRec* XkbSymMapPtr;
struct _XkbClientMapRec {
    ubyte size_types;
    ubyte num_types;
    XkbKeyTypePtr types;
    ushort size_syms;
    ushort num_syms;
    KeySym* syms;
    XkbSymMapPtr key_sym_map;
    ubyte* modmap;
}
alias _XkbClientMapRec XkbClientMapRec;
alias _XkbClientMapRec* XkbClientMapPtr;
struct _XkbSymInterpretRec {
    KeySym sym;
    ubyte flags;
    ubyte match;
    ubyte mods;
    ubyte virtual_mod;
    XkbAnyAction act;
}
alias _XkbSymInterpretRec XkbSymInterpretRec;
alias _XkbSymInterpretRec* XkbSymInterpretPtr;
struct _XkbCompatMapRec {
    XkbSymInterpretPtr sym_interpret;
    XkbModsRec[XkbNumKbdGroups] groups;
    ushort num_si;
    ushort size_si;
}
alias _XkbCompatMapRec XkbCompatMapRec;
alias _XkbCompatMapRec* XkbCompatMapPtr;
struct _XkbIndicatorMapRec {
    ubyte flags;
    ubyte which_groups;
    ubyte groups;
    ubyte which_mods;
    XkbModsRec mods;
    uint ctrls;
}
alias _XkbIndicatorMapRec XkbIndicatorMapRec;
alias _XkbIndicatorMapRec* XkbIndicatorMapPtr;
struct _XkbIndicatorRec {
    c_ulong phys_indicators;
    XkbIndicatorMapRec[XkbNumIndicators] maps;
}
alias _XkbIndicatorRec XkbIndicatorRec;
alias _XkbIndicatorRec* XkbIndicatorPtr;
struct _XkbKeyNameRec {
    char[XkbKeyNameLength] name;
}
alias _XkbKeyNameRec XkbKeyNameRec;
alias _XkbKeyNameRec* XkbKeyNamePtr;
struct _XkbKeyAliasRec {
    char[XkbKeyNameLength] real_;
    char[XkbKeyNameLength] alias_;
}
alias _XkbKeyAliasRec XkbKeyAliasRec;
alias _XkbKeyAliasRec* XkbKeyAliasPtr;
struct _XkbNamesRec {
    Atom keycodes;
    Atom geometry;
    Atom symbols;
    Atom types;
    Atom compat;
    Atom[XkbNumVirtualMods] vmods;
    Atom[XkbNumIndicators] indicators;
    Atom[XkbNumKbdGroups] groups;
    XkbKeyNamePtr keys;
    XkbKeyAliasPtr key_aliases;
    Atom* radio_groups;
    Atom phys_symbols;
    ubyte num_keys;
    ubyte num_key_aliases;
    ushort num_rg;
}
alias _XkbNamesRec XkbNamesRec;
alias _XkbNamesRec* XkbNamesPtr;
struct _XkbGeometry;
alias _XkbGeometry* XkbGeometryPtr;
struct _XkbDesc {
    struct _XDisplay;
    _XDisplay* dpy;
    ushort flags;
    ushort device_spec;
    KeyCode min_key_code;
    KeyCode max_key_code;
    XkbControlsPtr ctrls;
    XkbServerMapPtr server;
    XkbClientMapPtr map;
    XkbIndicatorPtr indicators;
    XkbNamesPtr names;
    XkbCompatMapPtr compat;
    XkbGeometryPtr geom;
}
alias _XkbDesc XkbDescRec;
alias _XkbDesc* XkbDescPtr;
struct _XkbMapChanges {
    ushort changed;
    KeyCode min_key_code;
    KeyCode max_key_code;
    ubyte first_type;
    ubyte num_types;
    KeyCode first_key_sym;
    ubyte num_key_syms;
    KeyCode first_key_act;
    ubyte num_key_acts;
    KeyCode first_key_behavior;
    ubyte num_key_behaviors;
    KeyCode first_key_explicit;
    ubyte num_key_explicit;
    KeyCode first_modmap_key;
    ubyte num_modmap_keys;
    KeyCode first_vmodmap_key;
    ubyte num_vmodmap_keys;
    ubyte pad;
    ushort vmods;
}
alias _XkbMapChanges XkbMapChangesRec;
alias _XkbMapChanges* XkbMapChangesPtr;
struct _XkbControlsChanges {
    uint changed_ctrls;
    uint enabled_ctrls_changes;
    Bool num_groups_changed;
}
alias _XkbControlsChanges XkbControlsChangesRec;
alias _XkbControlsChanges* XkbControlsChangesPtr;
struct _XkbIndicatorChanges {
    uint state_changes;
    uint map_changes;
}
alias _XkbIndicatorChanges XkbIndicatorChangesRec;
alias _XkbIndicatorChanges* XkbIndicatorChangesPtr;
struct _XkbNameChanges {
    uint changed;
    ubyte first_type;
    ubyte num_types;
    ubyte first_lvl;
    ubyte num_lvls;
    ubyte num_aliases;
    ubyte num_rg;
    ubyte first_key;
    ubyte num_keys;
    ushort changed_vmods;
    c_ulong changed_indicators;
    ubyte changed_groups;
}
alias _XkbNameChanges XkbNameChangesRec;
alias _XkbNameChanges* XkbNameChangesPtr;
struct _XkbCompatChanges {
    ubyte changed_groups;
    ushort first_si;
    ushort num_si;
}
alias _XkbCompatChanges XkbCompatChangesRec;
alias _XkbCompatChanges* XkbCompatChangesPtr;
struct _XkbChanges {
    ushort device_spec;
    ushort state_changes;
    XkbMapChangesRec map;
    XkbControlsChangesRec ctrls;
    XkbIndicatorChangesRec indicators;
    XkbNameChangesRec names;
    XkbCompatChangesRec compat;
}
alias _XkbChanges XkbChangesRec;
alias _XkbChanges* XkbChangesPtr;
struct XineramaScreenInfo {
    int screen_number;
    short x_org;
    short y_org;
    short width;
    short height;
}
Bool XineramaQueryExtension(Display* dpy, int* event_base, int* error_base);
Status XineramaQueryVersion(Display* dpy, int* major_versionp, int* minor_versionp);
Bool XineramaIsActive(Display* dpy);
XineramaScreenInfo* XineramaQueryScreens(Display* dpy, int* number);
alias XID RROutput;
alias XID RRCrtc;
alias XID RRMode;
alias ulong XRRModeFlags;
struct _XRRModeInfo {
    RRMode id;
    uint width;
    uint height;
    ulong dotClock;
    uint hSyncStart;
    uint hSyncEnd;
    uint hTotal;
    uint hSkew;
    uint vSyncStart;
    uint vSyncEnd;
    uint vTotal;
    char* name;
    uint nameLength;
    XRRModeFlags modeFlags;
}
alias _XRRModeInfo XRRModeInfo;
struct _XRRScreenResources {
    Time timestamp;
    Time configTimestamp;
    int ncrtc;
    RRCrtc* crtcs;
    int noutput;
    RROutput* outputs;
    int nmode;
    XRRModeInfo* modes;
}
alias _XRRScreenResources XRRScreenResources;
XRRScreenResources* XRRGetScreenResources(Display* dpy, Window window);
void XRRFreeScreenResources(XRRScreenResources* resources);
struct _XRROutputInfo {
    Time timestamp;
    RRCrtc crtc;
    char* name;
    int nameLen;
    ulong mm_width;
    ulong mm_height;
    Connection connection;
    SubpixelOrder subpixel_order;
    int ncrtc;
    RRCrtc* crtcs;
    int nclone;
    RROutput* clones;
    int nmode;
    int npreferred;
    RRMode* modes;
}
alias _XRROutputInfo XRROutputInfo;
XRROutputInfo* XRRGetOutputInfo(Display* dpy, XRRScreenResources* resources, RROutput output);
void XRRFreeOutputInfo(XRROutputInfo* outputInfo);
Atom* XRRListOutputProperties(Display* dpy, RROutput output, int* nprop);
struct _XRRCrtcInfo {
    Time timestamp;
    int x, y;
    uint width, height;
    RRMode mode;
    Rotation rotation;
    int noutput;
    RROutput* outputs;
    Rotation rotations;
    int npossible;
    RROutput* possible;
}
alias _XRRCrtcInfo XRRCrtcInfo;
XRRCrtcInfo* XRRGetCrtcInfo(Display* dpy, XRRScreenResources* resources, RRCrtc crtc);
void XRRFreeCrtcInfo(XRRCrtcInfo* crtcInfo);
Status XRRSetCrtcConfig(Display* dpy, XRRScreenResources* resources, RRCrtc crtc,
        Time timestamp, int x, int y, RRMode mode, Rotation rotation,
        RROutput* outputs, int noutputs);
int XRRGetCrtcGammaSize(Display* dpy, RRCrtc crtc);
struct _XRRCrtcGamma {
    int size;
    ushort* red;
    ushort* green;
    ushort* blue;
}
alias _XRRCrtcGamma XRRCrtcGamma;
RROutput XRRGetOutputPrimary(Display* dpy, Window window);
struct XRenderDirectFormat {
    short red;
    short redMask;
    short green;
    short greenMask;
    short blue;
    short blueMask;
    short alpha;
    short alphaMask;
}
struct XRenderPictFormat {
    PictFormat id;
    int type;
    int depth;
    XRenderDirectFormat direct;
    Colormap colormap;
}
enum PictFormatID = (1 << 0);
alias ushort Rotation;
alias ushort SizeID;
alias ushort SubpixelOrder;
alias ushort Connection;
alias ushort XRandrRotation;
enum RRScreenChangeNotifyMask = (1L << 0);
enum RRCrtcChangeNotifyMask = (1L << 1);
enum RROutputChangeNotifyMask = (1L << 2);
enum RROutputPropertyNotifyMask = (1L << 3);
enum RRNotify = 1;
enum RRNotify_CrtcChange = 0;
enum RRNotify_OutputChange = 1;
enum RRNotify_OutputProperty = 2;
enum RR_Rotate_90 = 2;
enum RR_Rotate_180 = 4;
enum RR_Rotate_270 = 8;
enum RR_Reflect_X = 16;
enum RR_VSyncNegative = 0x00000008;
enum RR_Interlace = 0x00000010;
enum RR_DoubleScan = 0x00000020;
enum RR_CSync = 0x00000040;
enum RR_PixelMultiplex = 0x00000800;
enum RR_DoubleClock = 0x00001000;
enum RR_ClockDivideBy2 = 0x00002000;
enum RR_Connected = 0;
alias XID PictFormat;
enum RENDER_NAME = "RENDER";
enum RENDER_MAJOR = 0;
enum RENDER_MINOR = 11;
