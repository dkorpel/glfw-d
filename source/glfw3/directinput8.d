/// Partial translation of dinput.h
///
/// Assumes direct input version 8, so old versions of interfaces are not included
/// Also assumes `UNICODE`, so only the variants that end in W (using wchar) instead of A (using ascii char).
module glfw3.directinput8;

version(Windows):
extern(Windows): nothrow: __gshared:

import core.sys.windows.windows;
import core.sys.windows.objbase;

enum DIRECTINPUT_VERSION =	0x0800;

// @nogc IUnknown interface
// Compiler doesn't care where it's from as long as it's named IUnknown
private interface IUnknown {
extern(Windows) nothrow @system:
	HRESULT QueryInterface(IID* riid, void** pvObject);
	ULONG AddRef();
	ULONG Release();
}

struct _DIDATAFORMAT {
    DWORD dwSize;
    DWORD dwObjSize;
    DWORD dwFlags;
    DWORD dwDataSize;
    DWORD dwNumObjs;
    LPDIOBJECTDATAFORMAT rgodf;
}alias _DIDATAFORMAT DIDATAFORMAT;alias _DIDATAFORMAT* LPDIDATAFORMAT;
alias const(DIDATAFORMAT)* LPCDIDATAFORMAT;

struct DIDEVICEOBJECTINSTANCEW {
    DWORD dwSize;
    GUID guidType;
    DWORD dwOfs;
    DWORD dwType;
    DWORD dwFlags;
    WCHAR[MAX_PATH] tszName;
    DWORD dwFFMaxForce;
    DWORD dwFFForceResolution;
    WORD wCollectionNumber;
    WORD wDesignatorIndex;
    WORD wUsagePage;
    WORD wUsage;
    DWORD dwDimension;
    WORD wExponent;
    WORD wReserved;
}
alias DIDEVICEOBJECTINSTANCEW* LPDIDEVICEOBJECTINSTANCEW;
alias const(DIDEVICEOBJECTINSTANCEW)* LPCDIDEVICEOBJECTINSTANCEW;

enum DIDOI_FFACTUATOR =	0x00000001;
enum DIDOI_FFEFFECTTRIGGER =	0x00000002;
enum DIDOI_POLLED =		0x00008000;
enum DIDOI_ASPECTPOSITION =	0x00000100;
enum DIDOI_ASPECTVELOCITY =	0x00000200;
enum DIDOI_ASPECTACCEL =	0x00000300;
enum DIDOI_ASPECTFORCE =	0x00000400;
enum DIDOI_ASPECTMASK =	0x00000F00;
enum DIDOI_GUIDISUSAGE =	0x00010000;

struct DIPROPHEADER {
    DWORD dwSize;
    DWORD dwHeaderSize;
    DWORD dwObj;
    DWORD dwHow;
}
alias DIPROPHEADER* LPDIPROPHEADER;
alias const(DIPROPHEADER)* LPCDIPROPHEADER;

enum DIPH_DEVICE =	0;
enum DIPH_BYOFFSET =	1;
enum DIPH_BYID =	2;
enum DIPH_BYUSAGE =	3;

struct DIPROPDWORD {
	DIPROPHEADER diph;
	DWORD dwData;
}
alias DIPROPDWORD* LPDIPROPDWORD;
alias const(DIPROPDWORD)* LPCDIPROPDWORD;

struct DIPROPRANGE {
	DIPROPHEADER diph;
	LONG lMin;
	LONG lMax;
}
alias DIPROPRANGE* LPDIPROPRANGE;
alias const(DIPROPRANGE)* LPCDIPROPRANGE;

enum DIPROPRANGE_NOMIN = cast(LONG) 0x80000000;
enum DIPROPRANGE_NOMAX = cast(LONG) 0x7FFFFFFF;

struct DIPROPCAL {
	DIPROPHEADER diph;
	LONG lMin;
	LONG lCenter;
	LONG lMax;
}
alias DIPROPCAL* LPDIPROPCAL;
alias const(DIPROPCAL)* LPCDIPROPCAL;

struct DIPROPCALPOV {
	DIPROPHEADER diph;
	LONG[5] lMin;
	LONG[5] lMax;
}
alias DIPROPCALPOV* LPDIPROPCALPOV;
alias const(DIPROPCALPOV)* LPCDIPROPCALPOV;

struct DIPROPGUIDANDPATH {
	DIPROPHEADER diph;
	GUID guidClass;
	WCHAR[MAX_PATH] wszPath;
}
alias DIPROPGUIDANDPATH* LPDIPROPGUIDANDPATH;
alias const(DIPROPGUIDANDPATH)* LPCDIPROPGUIDANDPATH;

struct DIPROPSTRING {
        DIPROPHEADER diph;
        WCHAR[MAX_PATH] wsz;
}
alias DIPROPSTRING* LPDIPROPSTRING;
alias const(DIPROPSTRING)* LPCDIPROPSTRING;

struct DIPROPPOINTER {
	DIPROPHEADER diph;
	UINT_PTR uData;
}
alias DIPROPPOINTER* LPDIPROPPOINTER;
alias const(DIPROPPOINTER)* LPCDIPROPPOINTER;

auto MAKEDIPROP(int prop) {return cast(REFGUID) prop;}

enum DIPROP_BUFFERSIZE =	MAKEDIPROP(1);
enum DIPROP_AXISMODE =		MAKEDIPROP(2);

enum DIPROPAXISMODE_ABS =	0;
enum DIPROPAXISMODE_REL =	1;

enum DIPROP_GRANULARITY =	MAKEDIPROP(3);
enum DIPROP_RANGE =		MAKEDIPROP(4);
enum DIPROP_DEADZONE =		MAKEDIPROP(5);
enum DIPROP_SATURATION =	MAKEDIPROP(6);
enum DIPROP_FFGAIN =		MAKEDIPROP(7);
enum DIPROP_FFLOAD =		MAKEDIPROP(8);
enum DIPROP_AUTOCENTER =	MAKEDIPROP(9);

enum DIPROPAUTOCENTER_OFF =	0;
enum DIPROPAUTOCENTER_ON =	1;

enum DIPROP_CALIBRATIONMODE =	MAKEDIPROP(10);

enum DIPROPCALIBRATIONMODE_COOKED =	0;
enum DIPROPCALIBRATIONMODE_RAW =	1;

enum DIPROP_CALIBRATION =	MAKEDIPROP(11);
enum DIPROP_GUIDANDPATH =	MAKEDIPROP(12);
enum DIPROP_INSTANCENAME =	MAKEDIPROP(13);
enum DIPROP_PRODUCTNAME =	MAKEDIPROP(14);

enum DIPROP_JOYSTICKID =	MAKEDIPROP(15);
enum DIPROP_GETPORTDISPLAYNAME =	MAKEDIPROP(16);

enum DIPROP_PHYSICALRANGE =	MAKEDIPROP(18);
enum DIPROP_LOGICALRANGE =	MAKEDIPROP(19);

enum DIPROP_KEYNAME =		MAKEDIPROP(20);
enum DIPROP_CPOINTS =		MAKEDIPROP(21);
enum DIPROP_APPDATA =		MAKEDIPROP(22);
enum DIPROP_SCANCODE =		MAKEDIPROP(23);
enum DIPROP_VIDPID =		MAKEDIPROP(24);
enum DIPROP_USERNAME =		MAKEDIPROP(25);
enum DIPROP_TYPENAME =		MAKEDIPROP(26);

enum MAXCPOINTSNUM =		8;

struct _CPOINT {
    LONG lP;
    DWORD dwLog;
}alias _CPOINT CPOINT;alias _CPOINT* PCPOINT;

struct DIPROPCPOINTS {
    DIPROPHEADER diph;
    DWORD dwCPointsNum;
    CPOINT[MAXCPOINTSNUM] cp;
}
alias const(DIPROPCPOINTS)* LPCDIPROPCPOINTS;

/* Device FF flags */
enum DISFFC_RESET =            0x00000001;
enum DISFFC_STOPALL =          0x00000002;
enum DISFFC_PAUSE =            0x00000004;
enum DISFFC_CONTINUE =         0x00000008;
enum DISFFC_SETACTUATORSON =   0x00000010;
enum DISFFC_SETACTUATORSOFF =  0x00000020;

enum DIGFFS_EMPTY =            0x00000001;
enum DIGFFS_STOPPED =          0x00000002;
enum DIGFFS_PAUSED =           0x00000004;
enum DIGFFS_ACTUATORSON =      0x00000010;
enum DIGFFS_ACTUATORSOFF =     0x00000020;
enum DIGFFS_POWERON =          0x00000040;
enum DIGFFS_POWEROFF =         0x00000080;
enum DIGFFS_SAFETYSWITCHON =   0x00000100;
enum DIGFFS_SAFETYSWITCHOFF =  0x00000200;
enum DIGFFS_USERFFSWITCHON =   0x00000400;
enum DIGFFS_USERFFSWITCHOFF =  0x00000800;
enum DIGFFS_DEVICELOST =       0x80000000;

/* Effect flags */
enum DIEFT_ALL =		0x00000000;

enum DIEFT_CONSTANTFORCE =	0x00000001;
enum DIEFT_RAMPFORCE =		0x00000002;
enum DIEFT_PERIODIC =		0x00000003;
enum DIEFT_CONDITION =		0x00000004;
enum DIEFT_CUSTOMFORCE =	0x00000005;
enum DIEFT_HARDWARE =		0x000000FF;
enum DIEFT_FFATTACK =		0x00000200;
enum DIEFT_FFFADE =		0x00000400;
enum DIEFT_SATURATION =	0x00000800;
enum DIEFT_POSNEGCOEFFICIENTS = 0x00001000;
enum DIEFT_POSNEGSATURATION =	0x00002000;
enum DIEFT_DEADBAND =		0x00004000;
enum DIEFT_STARTDELAY =	0x00008000;
alias DIEFT_GETTYPE = LOBYTE; //auto DIEFT_GETTYPE(T)(T n) {return LOBYTE(n);}

enum DIEFF_OBJECTIDS =         0x00000001;
enum DIEFF_OBJECTOFFSETS =     0x00000002;
enum DIEFF_CARTESIAN =         0x00000010;
enum DIEFF_POLAR =             0x00000020;
enum DIEFF_SPHERICAL =         0x00000040;

enum DIEP_DURATION =           0x00000001;
enum DIEP_SAMPLEPERIOD =       0x00000002;
enum DIEP_GAIN =               0x00000004;
enum DIEP_TRIGGERBUTTON =      0x00000008;
enum DIEP_TRIGGERREPEATINTERVAL = 0x00000010;
enum DIEP_AXES =               0x00000020;
enum DIEP_DIRECTION =          0x00000040;
enum DIEP_ENVELOPE =           0x00000080;
enum DIEP_TYPESPECIFICPARAMS = 0x00000100;
enum DIEP_STARTDELAY =         0x00000200;
enum DIEP_ALLPARAMS_DX5 =      0x000001FF;
enum DIEP_ALLPARAMS =          0x000003FF;
enum DIEP_START =              0x20000000;
enum DIEP_NORESTART =          0x40000000;
enum DIEP_NODOWNLOAD =         0x80000000;
enum DIEB_NOTRIGGER =          0xFFFFFFFF;

enum DIES_SOLO =               0x00000001;
enum DIES_NODOWNLOAD =         0x80000000;

enum DIEGES_PLAYING =          0x00000001;
enum DIEGES_EMULATED =         0x00000002;

enum DI_DEGREES =		100;
enum DI_FFNOMINALMAX =		10000;
enum DI_SECONDS =		1000000;

struct DICONSTANTFORCE {
	LONG lMagnitude;
}
alias DICONSTANTFORCE* LPDICONSTANTFORCE;
alias const(DICONSTANTFORCE)* LPCDICONSTANTFORCE;

struct DIRAMPFORCE {
	LONG lStart;
	LONG lEnd;
}
alias DIRAMPFORCE* LPDIRAMPFORCE;
alias const(DIRAMPFORCE)* LPCDIRAMPFORCE;

struct DIPERIODIC {
	DWORD dwMagnitude;
	LONG lOffset;
	DWORD dwPhase;
	DWORD dwPeriod;
}
alias DIPERIODIC* LPDIPERIODIC;
alias const(DIPERIODIC)* LPCDIPERIODIC;

struct DICONDITION {
	LONG lOffset;
	LONG lPositiveCoefficient;
	LONG lNegativeCoefficient;
	DWORD dwPositiveSaturation;
	DWORD dwNegativeSaturation;
	LONG lDeadBand;
}
alias DICONDITION* LPDICONDITION;
alias const(DICONDITION)* LPCDICONDITION;

struct DICUSTOMFORCE {
	DWORD cChannels;
	DWORD dwSamplePeriod;
	DWORD cSamples;
	LPLONG rglForceData;
}
alias DICUSTOMFORCE* LPDICUSTOMFORCE;
alias const(DICUSTOMFORCE)* LPCDICUSTOMFORCE;

struct DIENVELOPE {
	DWORD dwSize;
	DWORD dwAttackLevel;
	DWORD dwAttackTime;
	DWORD dwFadeLevel;
	DWORD dwFadeTime;
}
alias DIENVELOPE* LPDIENVELOPE;
alias const(DIENVELOPE)* LPCDIENVELOPE;

struct DIEFFECT_DX5 {
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwDuration;
	DWORD dwSamplePeriod;
	DWORD dwGain;
	DWORD dwTriggerButton;
	DWORD dwTriggerRepeatInterval;
	DWORD cAxes;
	LPDWORD rgdwAxes;
	LPLONG rglDirection;
	LPDIENVELOPE lpEnvelope;
	DWORD cbTypeSpecificParams;
	LPVOID lpvTypeSpecificParams;
}
alias DIEFFECT_DX5* LPDIEFFECT_DX5;
alias const(DIEFFECT_DX5)* LPCDIEFFECT_DX5;

struct DIEFFECT {
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwDuration;
	DWORD dwSamplePeriod;
	DWORD dwGain;
	DWORD dwTriggerButton;
	DWORD dwTriggerRepeatInterval;
	DWORD cAxes;
	LPDWORD rgdwAxes;
	LPLONG rglDirection;
	LPDIENVELOPE lpEnvelope;
	DWORD cbTypeSpecificParams;
	LPVOID lpvTypeSpecificParams;
	DWORD dwStartDelay;
}
alias DIEFFECT* LPDIEFFECT;
alias const(DIEFFECT)* LPCDIEFFECT;
alias DIEFFECT DIEFFECT_DX6;
alias LPDIEFFECT LPDIEFFECT_DX6;

struct DIEFFECTINFOA {
	DWORD dwSize;
	GUID guid;
	DWORD dwEffType;
	DWORD dwStaticParams;
	DWORD dwDynamicParams;
	CHAR[MAX_PATH] tszName;
}
alias DIEFFECTINFOA* LPDIEFFECTINFOA;
alias const(DIEFFECTINFOA)* LPCDIEFFECTINFOA;

struct DIEFFECTINFOW {
	DWORD dwSize;
	GUID guid;
	DWORD dwEffType;
	DWORD dwStaticParams;
	DWORD dwDynamicParams;
	WCHAR[MAX_PATH] tszName;
}
alias DIEFFECTINFOW* LPDIEFFECTINFOW;
alias const(DIEFFECTINFOW)* LPCDIEFFECTINFOW;

struct DIEFFESCAPE {
	DWORD dwSize;
	DWORD dwCommand;
	LPVOID lpvInBuffer;
	DWORD cbInBuffer;
	LPVOID lpvOutBuffer;
	DWORD cbOutBuffer;
}
alias DIEFFESCAPE* LPDIEFFESCAPE;

struct DIJOYSTATE {
	LONG lX;
	LONG lY;
	LONG lZ;
	LONG lRx;
	LONG lRy;
	LONG lRz;
	LONG[2] rglSlider;
	DWORD[4] rgdwPOV;
	BYTE[32] rgbButtons;
}
alias DIJOYSTATE* LPDIJOYSTATE;

struct DIJOYSTATE2 {
	LONG lX;
	LONG lY;
	LONG lZ;
	LONG lRx;
	LONG lRy;
	LONG lRz;
	LONG[2] rglSlider;
	DWORD[4] rgdwPOV;
	BYTE[128] rgbButtons;
	LONG lVX;		/* 'v' as in velocity */
	LONG lVY;
	LONG lVZ;
	LONG lVRx;
	LONG lVRy;
	LONG lVRz;
	LONG[2] rglVSlider;
	LONG lAX;		/* 'a' as in acceleration */
	LONG lAY;
	LONG lAZ;
	LONG lARx;
	LONG lARy;
	LONG lARz;
	LONG[2] rglASlider;
	LONG lFX;		/* 'f' as in force */
	LONG lFY;
	LONG lFZ;
	LONG lFRx;		/* 'fr' as in rotational force aka torque */
	LONG lFRy;
	LONG lFRz;
	LONG[2] rglFSlider;
}
alias DIJOYSTATE2* LPDIJOYSTATE2;

enum DIJOFS_X =		DIJOYSTATE.lX.offsetof;
enum DIJOFS_Y =		DIJOYSTATE.lY.offsetof;
enum DIJOFS_Z =		DIJOYSTATE.lZ.offsetof;
enum DIJOFS_RX =	DIJOYSTATE.lRx.offsetof;
enum DIJOFS_RY =	DIJOYSTATE.lRy.offsetof;
enum DIJOFS_RZ =	DIJOYSTATE.lRz.offsetof;
pragma(inline, true) extern(D) int DIJOFS_SLIDER(int n) {return cast(int) (DIJOYSTATE.rglSlider.offsetof + n * LONG.sizeof);}
pragma(inline, true) extern(D) int DIJOFS_POV(int n)    {return cast(int) (DIJOYSTATE.rgdwPOV.offsetof + n * DWORD.sizeof);}
pragma(inline, true) extern(D) int DIJOFS_BUTTON(int n) {return cast(int) (DIJOYSTATE.rgbButtons.offsetof + n);}
enum DIJOFS_BUTTON0 =		DIJOFS_BUTTON(0);
enum DIJOFS_BUTTON1 =		DIJOFS_BUTTON(1);
enum DIJOFS_BUTTON2 =		DIJOFS_BUTTON(2);
enum DIJOFS_BUTTON3 =		DIJOFS_BUTTON(3);
enum DIJOFS_BUTTON4 =		DIJOFS_BUTTON(4);
enum DIJOFS_BUTTON5 =		DIJOFS_BUTTON(5);
enum DIJOFS_BUTTON6 =		DIJOFS_BUTTON(6);
enum DIJOFS_BUTTON7 =		DIJOFS_BUTTON(7);
enum DIJOFS_BUTTON8 =		DIJOFS_BUTTON(8);
enum DIJOFS_BUTTON9 =		DIJOFS_BUTTON(9);
enum DIJOFS_BUTTON10 =		DIJOFS_BUTTON(10);
enum DIJOFS_BUTTON11 =		DIJOFS_BUTTON(11);
enum DIJOFS_BUTTON12 =		DIJOFS_BUTTON(12);
enum DIJOFS_BUTTON13 =		DIJOFS_BUTTON(13);
enum DIJOFS_BUTTON14 =		DIJOFS_BUTTON(14);
enum DIJOFS_BUTTON15 =		DIJOFS_BUTTON(15);
enum DIJOFS_BUTTON16 =		DIJOFS_BUTTON(16);
enum DIJOFS_BUTTON17 =		DIJOFS_BUTTON(17);
enum DIJOFS_BUTTON18 =		DIJOFS_BUTTON(18);
enum DIJOFS_BUTTON19 =		DIJOFS_BUTTON(19);
enum DIJOFS_BUTTON20 =		DIJOFS_BUTTON(20);
enum DIJOFS_BUTTON21 =		DIJOFS_BUTTON(21);
enum DIJOFS_BUTTON22 =		DIJOFS_BUTTON(22);
enum DIJOFS_BUTTON23 =		DIJOFS_BUTTON(23);
enum DIJOFS_BUTTON24 =		DIJOFS_BUTTON(24);
enum DIJOFS_BUTTON25 =		DIJOFS_BUTTON(25);
enum DIJOFS_BUTTON26 =		DIJOFS_BUTTON(26);
enum DIJOFS_BUTTON27 =		DIJOFS_BUTTON(27);
enum DIJOFS_BUTTON28 =		DIJOFS_BUTTON(28);
enum DIJOFS_BUTTON29 =		DIJOFS_BUTTON(29);
enum DIJOFS_BUTTON30 =		DIJOFS_BUTTON(30);
enum DIJOFS_BUTTON31 =		DIJOFS_BUTTON(31);

enum DIK_ESCAPE =          0x01;
enum DIK_1 =               0x02;
enum DIK_2 =               0x03;
enum DIK_3 =               0x04;
enum DIK_4 =               0x05;
enum DIK_5 =               0x06;
enum DIK_6 =               0x07;
enum DIK_7 =               0x08;
enum DIK_8 =               0x09;
enum DIK_9 =               0x0A;
enum DIK_0 =               0x0B;
enum DIK_MINUS =           0x0C    /* - on main keyboard */;
enum DIK_EQUALS =          0x0D;
enum DIK_BACK =            0x0E    /* backspace */;
enum DIK_TAB =             0x0F;
enum DIK_Q =               0x10;
enum DIK_W =               0x11;
enum DIK_E =               0x12;
enum DIK_R =               0x13;
enum DIK_T =               0x14;
enum DIK_Y =               0x15;
enum DIK_U =               0x16;
enum DIK_I =               0x17;
enum DIK_O =               0x18;
enum DIK_P =               0x19;
enum DIK_LBRACKET =        0x1A;
enum DIK_RBRACKET =        0x1B;
enum DIK_RETURN =          0x1C    /* Enter on main keyboard */;
enum DIK_LCONTROL =        0x1D;
enum DIK_A =               0x1E;
enum DIK_S =               0x1F;
enum DIK_D =               0x20;
enum DIK_F =               0x21;
enum DIK_G =               0x22;
enum DIK_H =               0x23;
enum DIK_J =               0x24;
enum DIK_K =               0x25;
enum DIK_L =               0x26;
enum DIK_SEMICOLON =       0x27;
enum DIK_APOSTROPHE =      0x28;
enum DIK_GRAVE =           0x29    /* accent grave */;
enum DIK_LSHIFT =          0x2A;
enum DIK_BACKSLASH =       0x2B;
enum DIK_Z =               0x2C;
enum DIK_X =               0x2D;
enum DIK_C =               0x2E;
enum DIK_V =               0x2F;
enum DIK_B =               0x30;
enum DIK_N =               0x31;
enum DIK_M =               0x32;
enum DIK_COMMA =           0x33;
enum DIK_PERIOD =          0x34    /* . on main keyboard */;
enum DIK_SLASH =           0x35    /* / on main keyboard */;
enum DIK_RSHIFT =          0x36;
enum DIK_MULTIPLY =        0x37    /* * on numeric keypad */;
enum DIK_LMENU =           0x38    /* left Alt */;
enum DIK_SPACE =           0x39;
enum DIK_CAPITAL =         0x3A;
enum DIK_F1 =              0x3B;
enum DIK_F2 =              0x3C;
enum DIK_F3 =              0x3D;
enum DIK_F4 =              0x3E;
enum DIK_F5 =              0x3F;
enum DIK_F6 =              0x40;
enum DIK_F7 =              0x41;
enum DIK_F8 =              0x42;
enum DIK_F9 =              0x43;
enum DIK_F10 =             0x44;
enum DIK_NUMLOCK =         0x45;
enum DIK_SCROLL =          0x46    /* Scroll Lock */;
enum DIK_NUMPAD7 =         0x47;
enum DIK_NUMPAD8 =         0x48;
enum DIK_NUMPAD9 =         0x49;
enum DIK_SUBTRACT =        0x4A    /* - on numeric keypad */;
enum DIK_NUMPAD4 =         0x4B;
enum DIK_NUMPAD5 =         0x4C;
enum DIK_NUMPAD6 =         0x4D;
enum DIK_ADD =             0x4E    /* + on numeric keypad */;
enum DIK_NUMPAD1 =         0x4F;
enum DIK_NUMPAD2 =         0x50;
enum DIK_NUMPAD3 =         0x51;
enum DIK_NUMPAD0 =         0x52;
enum DIK_DECIMAL =         0x53    /* . on numeric keypad */;
enum DIK_OEM_102 =         0x56    /* < > | on UK/Germany keyboards */;
enum DIK_F11 =             0x57;
enum DIK_F12 =             0x58;
enum DIK_F13 =             0x64    /*                     (NEC PC98) */;
enum DIK_F14 =             0x65    /*                     (NEC PC98) */;
enum DIK_F15 =             0x66    /*                     (NEC PC98) */;
enum DIK_KANA =            0x70    /* (Japanese keyboard)            */;
enum DIK_ABNT_C1 =         0x73    /* / ? on Portugese (Brazilian) keyboards */;
enum DIK_CONVERT =         0x79    /* (Japanese keyboard)            */;
enum DIK_NOCONVERT =       0x7B    /* (Japanese keyboard)            */;
enum DIK_YEN =             0x7D    /* (Japanese keyboard)            */;
enum DIK_ABNT_C2 =         0x7E    /* Numpad . on Portugese (Brazilian) keyboards */;
enum DIK_NUMPADEQUALS =    0x8D    /* = on numeric keypad (NEC PC98) */;
enum DIK_CIRCUMFLEX =      0x90    /* (Japanese keyboard)            */;
enum DIK_AT =              0x91    /*                     (NEC PC98) */;
enum DIK_COLON =           0x92    /*                     (NEC PC98) */;
enum DIK_UNDERLINE =       0x93    /*                     (NEC PC98) */;
enum DIK_KANJI =           0x94    /* (Japanese keyboard)            */;
enum DIK_STOP =            0x95    /*                     (NEC PC98) */;
enum DIK_AX =              0x96    /*                     (Japan AX) */;
enum DIK_UNLABELED =       0x97    /*                        (J3100) */;
enum DIK_NEXTTRACK =       0x99    /* Next Track */;
enum DIK_NUMPADENTER =     0x9C    /* Enter on numeric keypad */;
enum DIK_RCONTROL =        0x9D;
enum DIK_MUTE =	    0xA0    /* Mute */;
enum DIK_CALCULATOR =      0xA1    /* Calculator */;
enum DIK_PLAYPAUSE =       0xA2    /* Play / Pause */;
enum DIK_MEDIASTOP =       0xA4    /* Media Stop */;
enum DIK_VOLUMEDOWN =      0xAE    /* Volume - */;
enum DIK_VOLUMEUP =        0xB0    /* Volume + */;
enum DIK_WEBHOME =         0xB2    /* Web home */;
enum DIK_NUMPADCOMMA =     0xB3    /* , on numeric keypad (NEC PC98) */;
enum DIK_DIVIDE =          0xB5    /* / on numeric keypad */;
enum DIK_SYSRQ =           0xB7;
enum DIK_RMENU =           0xB8    /* right Alt */;
enum DIK_PAUSE =           0xC5    /* Pause */;
enum DIK_HOME =            0xC7    /* Home on arrow keypad */;
enum DIK_UP =              0xC8    /* UpArrow on arrow keypad */;
enum DIK_PRIOR =           0xC9    /* PgUp on arrow keypad */;
enum DIK_LEFT =            0xCB    /* LeftArrow on arrow keypad */;
enum DIK_RIGHT =           0xCD    /* RightArrow on arrow keypad */;
enum DIK_END =             0xCF    /* End on arrow keypad */;
enum DIK_DOWN =            0xD0    /* DownArrow on arrow keypad */;
enum DIK_NEXT =            0xD1    /* PgDn on arrow keypad */;
enum DIK_INSERT =          0xD2    /* Insert on arrow keypad */;
enum DIK_DELETE =          0xD3    /* Delete on arrow keypad */;
enum DIK_LWIN =            0xDB    /* Left Windows key */;
enum DIK_RWIN =            0xDC    /* Right Windows key */;
enum DIK_APPS =            0xDD    /* AppMenu key */;
enum DIK_POWER =           0xDE;
enum DIK_SLEEP =           0xDF;
enum DIK_WAKE =            0xE3    /* System Wake */;
enum DIK_WEBSEARCH =       0xE5    /* Web Search */;
enum DIK_WEBFAVORITES =    0xE6    /* Web Favorites */;
enum DIK_WEBREFRESH =      0xE7    /* Web Refresh */;
enum DIK_WEBSTOP =         0xE8    /* Web Stop */;
enum DIK_WEBFORWARD =      0xE9    /* Web Forward */;
enum DIK_WEBBACK =         0xEA    /* Web Back */;
enum DIK_MYCOMPUTER =      0xEB    /* My Computer */;
enum DIK_MAIL =            0xEC    /* Mail */;
enum DIK_MEDIASELECT =     0xED    /* Media Select */;

enum DIK_BACKSPACE =       DIK_BACK            /* backspace */;
enum DIK_NUMPADSTAR =      DIK_MULTIPLY        /* * on numeric keypad */;
enum DIK_LALT =            DIK_LMENU           /* left Alt */;
enum DIK_CAPSLOCK =        DIK_CAPITAL         /* CapsLock */;
enum DIK_NUMPADMINUS =     DIK_SUBTRACT        /* - on numeric keypad */;
enum DIK_NUMPADPLUS =      DIK_ADD             /* + on numeric keypad */;
enum DIK_NUMPADPERIOD =    DIK_DECIMAL         /* . on numeric keypad */;
enum DIK_NUMPADSLASH =     DIK_DIVIDE          /* / on numeric keypad */;
enum DIK_RALT =            DIK_RMENU           /* right Alt */;
enum DIK_UPARROW =         DIK_UP              /* UpArrow on arrow keypad */;
enum DIK_PGUP =            DIK_PRIOR           /* PgUp on arrow keypad */;
enum DIK_LEFTARROW =       DIK_LEFT            /* LeftArrow on arrow keypad */;
enum DIK_RIGHTARROW =      DIK_RIGHT           /* RightArrow on arrow keypad */;
enum DIK_DOWNARROW =       DIK_DOWN            /* DownArrow on arrow keypad */;
enum DIK_PGDN =            DIK_NEXT            /* PgDn on arrow keypad */;

enum DIDFT_ALL =		0x00000000;
enum DIDFT_RELAXIS =		0x00000001;
enum DIDFT_ABSAXIS =		0x00000002;
enum DIDFT_AXIS =		0x00000003;
enum DIDFT_PSHBUTTON =		0x00000004;
enum DIDFT_TGLBUTTON =		0x00000008;
enum DIDFT_BUTTON =		0x0000000C;
enum DIDFT_POV =		0x00000010;
enum DIDFT_COLLECTION =	0x00000040;
enum DIDFT_NODATA =		0x00000080;
enum DIDFT_ANYINSTANCE =	0x00FFFF00;
enum DIDFT_INSTANCEMASK =	DIDFT_ANYINSTANCE;

enum DIERR_INSUFFICIENTPRIVS =         0x80040200L;
enum DIERR_DEVICEFULL =                0x80040201L;
enum DIERR_MOREDATA =                  0x80040202L;
enum DIERR_NOTDOWNLOADED =             0x80040203L;
enum DIERR_HASEFFECTS =                0x80040204L;
enum DIERR_NOTEXCLUSIVEACQUIRED =      0x80040205L;
enum DIERR_INCOMPLETEEFFECT =          0x80040206L;
enum DIERR_NOTBUFFERED =               0x80040207L;
enum DIERR_EFFECTPLAYING =             0x80040208L;
enum DIERR_UNPLUGGED =                 0x80040209L;
enum DIERR_REPORTFULL =                0x8004020AL;
enum DIERR_MAPFILEFAIL =               0x8004020BL;

enum DIENUM_STOP =                     0;
enum DIENUM_CONTINUE =                 1;

enum DIEDFL_ALLDEVICES =               0x00000000;
enum DIEDFL_ATTACHEDONLY =             0x00000001;
enum DIEDFL_FORCEFEEDBACK =            0x00000100;
enum DIEDFL_INCLUDEALIASES =           0x00010000;
enum DIEDFL_INCLUDEPHANTOMS =          0x00020000;
enum DIEDFL_INCLUDEHIDDEN =		0x00040000;

enum DIDEVTYPE_DEVICE =                1;
enum DIDEVTYPE_MOUSE =                 2;
enum DIDEVTYPE_KEYBOARD =              3;
enum DIDEVTYPE_JOYSTICK =              4;
enum DIDEVTYPE_HID =                   0x00010000;

enum DI8DEVCLASS_ALL =             0;
enum DI8DEVCLASS_DEVICE =          1;
enum DI8DEVCLASS_POINTER =         2;
enum DI8DEVCLASS_KEYBOARD =        3;
enum DI8DEVCLASS_GAMECTRL =        4;

enum DI8DEVTYPE_DEVICE =           0x11;
enum DI8DEVTYPE_MOUSE =            0x12;
enum DI8DEVTYPE_KEYBOARD =         0x13;
enum DI8DEVTYPE_JOYSTICK =         0x14;
enum DI8DEVTYPE_GAMEPAD =          0x15;
enum DI8DEVTYPE_DRIVING =          0x16;
enum DI8DEVTYPE_FLIGHT =           0x17;
enum DI8DEVTYPE_1STPERSON =        0x18;
enum DI8DEVTYPE_DEVICECTRL =       0x19;
enum DI8DEVTYPE_SCREENPOINTER =    0x1A;
enum DI8DEVTYPE_REMOTE =           0x1B;
enum DI8DEVTYPE_SUPPLEMENTAL =     0x1C;

enum DIDEVTYPEMOUSE_UNKNOWN =          1;
enum DIDEVTYPEMOUSE_TRADITIONAL =      2;
enum DIDEVTYPEMOUSE_FINGERSTICK =      3;
enum DIDEVTYPEMOUSE_TOUCHPAD =         4;
enum DIDEVTYPEMOUSE_TRACKBALL =        5;

enum DIDEVTYPEKEYBOARD_UNKNOWN =       0;
enum DIDEVTYPEKEYBOARD_PCXT =          1;
enum DIDEVTYPEKEYBOARD_OLIVETTI =      2;
enum DIDEVTYPEKEYBOARD_PCAT =          3;
enum DIDEVTYPEKEYBOARD_PCENH =         4;
enum DIDEVTYPEKEYBOARD_NOKIA1050 =     5;
enum DIDEVTYPEKEYBOARD_NOKIA9140 =     6;
enum DIDEVTYPEKEYBOARD_NEC98 =         7;
enum DIDEVTYPEKEYBOARD_NEC98LAPTOP =   8;
enum DIDEVTYPEKEYBOARD_NEC98106 =      9;
enum DIDEVTYPEKEYBOARD_JAPAN106 =     10;
enum DIDEVTYPEKEYBOARD_JAPANAX =      11;
enum DIDEVTYPEKEYBOARD_J3100 =        12;

enum DIDEVTYPEJOYSTICK_UNKNOWN =       1;
enum DIDEVTYPEJOYSTICK_TRADITIONAL =   2;
enum DIDEVTYPEJOYSTICK_FLIGHTSTICK =   3;
enum DIDEVTYPEJOYSTICK_GAMEPAD =       4;
enum DIDEVTYPEJOYSTICK_RUDDER =        5;
enum DIDEVTYPEJOYSTICK_WHEEL =         6;
enum DIDEVTYPEJOYSTICK_HEADTRACKER =   7;

enum DI8DEVTYPEMOUSE_UNKNOWN =                     1;
enum DI8DEVTYPEMOUSE_TRADITIONAL =                 2;
enum DI8DEVTYPEMOUSE_FINGERSTICK =                 3;
enum DI8DEVTYPEMOUSE_TOUCHPAD =                    4;
enum DI8DEVTYPEMOUSE_TRACKBALL =                   5;
enum DI8DEVTYPEMOUSE_ABSOLUTE =                    6;

enum DI8DEVTYPEKEYBOARD_UNKNOWN =                  0;
enum DI8DEVTYPEKEYBOARD_PCXT =                     1;
enum DI8DEVTYPEKEYBOARD_OLIVETTI =                 2;
enum DI8DEVTYPEKEYBOARD_PCAT =                     3;
enum DI8DEVTYPEKEYBOARD_PCENH =                    4;
enum DI8DEVTYPEKEYBOARD_NOKIA1050 =                5;
enum DI8DEVTYPEKEYBOARD_NOKIA9140 =                6;
enum DI8DEVTYPEKEYBOARD_NEC98 =                    7;
enum DI8DEVTYPEKEYBOARD_NEC98LAPTOP =              8;
enum DI8DEVTYPEKEYBOARD_NEC98106 =                 9;
enum DI8DEVTYPEKEYBOARD_JAPAN106 =                10;
enum DI8DEVTYPEKEYBOARD_JAPANAX =                 11;
enum DI8DEVTYPEKEYBOARD_J3100 =                   12;

enum DI8DEVTYPE_LIMITEDGAMESUBTYPE =               1;

enum DI8DEVTYPEJOYSTICK_LIMITED =                  DI8DEVTYPE_LIMITEDGAMESUBTYPE;
enum DI8DEVTYPEJOYSTICK_STANDARD =                 2;

enum DI8DEVTYPEGAMEPAD_LIMITED =                   DI8DEVTYPE_LIMITEDGAMESUBTYPE;
enum DI8DEVTYPEGAMEPAD_STANDARD =                  2;
enum DI8DEVTYPEGAMEPAD_TILT =                      3;

enum DI8DEVTYPEDRIVING_LIMITED =                   DI8DEVTYPE_LIMITEDGAMESUBTYPE;
enum DI8DEVTYPEDRIVING_COMBINEDPEDALS =            2;
enum DI8DEVTYPEDRIVING_DUALPEDALS =                3;
enum DI8DEVTYPEDRIVING_THREEPEDALS =               4;
enum DI8DEVTYPEDRIVING_HANDHELD =                  5;

enum DI8DEVTYPEFLIGHT_LIMITED =                    DI8DEVTYPE_LIMITEDGAMESUBTYPE;
enum DI8DEVTYPEFLIGHT_STICK =                      2;
enum DI8DEVTYPEFLIGHT_YOKE =                       3;
enum DI8DEVTYPEFLIGHT_RC =                         4;

enum DI8DEVTYPE1STPERSON_LIMITED =                 DI8DEVTYPE_LIMITEDGAMESUBTYPE;
enum DI8DEVTYPE1STPERSON_UNKNOWN =                 2;
enum DI8DEVTYPE1STPERSON_SIXDOF =                  3;
enum DI8DEVTYPE1STPERSON_SHOOTER =                 4;

enum DI8DEVTYPESCREENPTR_UNKNOWN =                 2;
enum DI8DEVTYPESCREENPTR_LIGHTGUN =                3;
enum DI8DEVTYPESCREENPTR_LIGHTPEN =                4;
enum DI8DEVTYPESCREENPTR_TOUCH =                   5;

enum DI8DEVTYPEREMOTE_UNKNOWN =                    2;

enum DI8DEVTYPEDEVICECTRL_UNKNOWN =                2;
enum DI8DEVTYPEDEVICECTRL_COMMSSELECTION =         3;
enum DI8DEVTYPEDEVICECTRL_COMMSSELECTION_HARDWIRED = 4;

enum DI8DEVTYPESUPPLEMENTAL_UNKNOWN =              2;
enum DI8DEVTYPESUPPLEMENTAL_2NDHANDCONTROLLER =    3;
enum DI8DEVTYPESUPPLEMENTAL_HEADTRACKER =          4;
enum DI8DEVTYPESUPPLEMENTAL_HANDTRACKER =          5;
enum DI8DEVTYPESUPPLEMENTAL_SHIFTSTICKGATE =       6;
enum DI8DEVTYPESUPPLEMENTAL_SHIFTER =              7;
enum DI8DEVTYPESUPPLEMENTAL_THROTTLE =             8;
enum DI8DEVTYPESUPPLEMENTAL_SPLITTHROTTLE =        9;
enum DI8DEVTYPESUPPLEMENTAL_COMBINEDPEDALS =      10;
enum DI8DEVTYPESUPPLEMENTAL_DUALPEDALS =          11;
enum DI8DEVTYPESUPPLEMENTAL_THREEPEDALS =         12;
enum DI8DEVTYPESUPPLEMENTAL_RUDDERPEDALS =        13;

struct DIDEVICEINSTANCEW {
    DWORD dwSize;
    GUID guidInstance;
    GUID guidProduct;
    DWORD dwDevType;
    WCHAR[MAX_PATH] tszInstanceName;
    WCHAR[MAX_PATH] tszProductName;
    GUID guidFFDriver;
    WORD wUsagePage;
    WORD wUsage;
}
alias DIDEVICEINSTANCEW* LPDIDEVICEINSTANCEW;
alias const(DIDEVICEINSTANCEW)* LPCDIDEVICEINSTANCEW;

alias DIDEVICEINSTANCE = DIDEVICEINSTANCEW;

enum DI_OK =                           S_OK;
enum DI_NOTATTACHED =                  S_FALSE;
enum DI_BUFFEROVERFLOW =               S_FALSE;
enum DI_PROPNOEFFECT =                 S_FALSE;
enum DI_NOEFFECT =                     S_FALSE;
enum DI_POLLEDDEVICE =                 HRESULT(0x0002);
enum DI_DOWNLOADSKIPPED =              HRESULT(0x0003);
enum DI_EFFECTRESTARTED =              HRESULT(0x0004);
enum DI_TRUNCATED =                    HRESULT(0x0008);
enum DI_SETTINGSNOTSAVED =             HRESULT(0x000B);
enum DI_TRUNCATEDANDRESTARTED =        HRESULT(0x000C);
enum DI_WRITEPROTECT =                 HRESULT(0x0013);

enum DIERR_OLDDIRECTINPUTVERSION =     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_OLD_WIN_VERSION);
enum DIERR_BETADIRECTINPUTVERSION =    MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_RMODE_APP);
enum DIERR_BADDRIVERVER =              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_BAD_DRIVER_LEVEL);
enum DIERR_DEVICENOTREG =              REGDB_E_CLASSNOTREG;
enum DIERR_NOTFOUND =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_FILE_NOT_FOUND);
enum DIERR_OBJECTNOTFOUND =            MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_FILE_NOT_FOUND);
enum DIERR_INVALIDPARAM =              E_INVALIDARG;
enum DIERR_NOINTERFACE =               E_NOINTERFACE;
enum DIERR_GENERIC =                   E_FAIL;
enum DIERR_OUTOFMEMORY =               E_OUTOFMEMORY;
enum DIERR_UNSUPPORTED =               E_NOTIMPL;
enum DIERR_NOTINITIALIZED =            MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_NOT_READY);
enum DIERR_ALREADYINITIALIZED =        MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_ALREADY_INITIALIZED);
enum DIERR_NOAGGREGATION =             CLASS_E_NOAGGREGATION;
enum DIERR_OTHERAPPHASPRIO =           E_ACCESSDENIED;
enum DIERR_INPUTLOST =                 MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_READ_FAULT);
enum DIERR_ACQUIRED =                  MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_BUSY);
enum DIERR_NOTACQUIRED =               MAKE_HRESULT(SEVERITY_ERROR, FACILITY_WIN32, ERROR_INVALID_ACCESS);
enum DIERR_READONLY =                  E_ACCESSDENIED;
enum DIERR_HANDLEEXISTS =              E_ACCESSDENIED;
enum E_PENDING =                       0x8000000AL;

enum string DIDFT_MAKEINSTANCE(string n) = `	((WORD)(n) << 8)`;
auto DIDFT_GETTYPE(T)(T a) {return LOBYTE(cast(ushort) a);}
enum string DIDFT_GETINSTANCE(string n) = `	LOWORD((n) >> 8)`;
enum DIDFT_FFACTUATOR =	0x01000000;
enum DIDFT_FFEFFECTTRIGGER =	0x02000000;
enum DIDFT_OUTPUT =		0x10000000;
enum DIDFT_VENDORDEFINED =	0x04000000;
enum DIDFT_ALIAS =		0x08000000;
enum DIDFT_OPTIONAL =		0x80000000;
enum string DIDFT_ENUMCOLLECTION(string n) = `	((WORD)(n) << 8)`;
enum DIDFT_NOCOLLECTION =	0x00FFFF00;

enum DIDF_ABSAXIS =		0x00000001;
enum DIDF_RELAXIS =		0x00000002;
enum DIGDD_PEEK =		0x00000001;

enum string DISEQUENCE_COMPARE(string dwSq1,string cmp,string dwSq2) = ` ((int)((dwSq1) - (dwSq2)) cmp 0)`;

struct DIDEVCAPS_DX3 {
    DWORD dwSize;
    DWORD dwFlags;
    DWORD dwDevType;
    DWORD dwAxes;
    DWORD dwButtons;
    DWORD dwPOVs;
}
alias DIDEVCAPS_DX3* LPDIDEVCAPS_DX3;

struct DIDEVCAPS {
    DWORD dwSize;
    DWORD dwFlags;
    DWORD dwDevType;
    DWORD dwAxes;
    DWORD dwButtons;
    DWORD dwPOVs;
    DWORD dwFFSamplePeriod;
    DWORD dwFFMinTimeResolution;
    DWORD dwFirmwareRevision;
    DWORD dwHardwareRevision;
    DWORD dwFFDriverVersion;
}
alias DIDEVCAPS* LPDIDEVCAPS;

alias BOOL function(LPCDIDEVICEINSTANCEW, LPDIRECTINPUTDEVICE8W, DWORD, DWORD, LPVOID) LPDIENUMDEVICESBYSEMANTICSCBW;
alias LPDIENUMDEVICESBYSEMANTICSCB = LPDIENUMDEVICESBYSEMANTICSCBW;
alias LPDICONFIGUREDEVICESCALLBACK = extern(Windows) BOOL function(LPUNKNOWN, LPVOID);
alias LPDIENUMDEVICEOBJECTSCALLBACKW = extern(Windows) BOOL function(LPCDIDEVICEOBJECTINSTANCEW, LPVOID);
alias LPDIENUMDEVICEOBJECTSCALLBACK = LPDIENUMDEVICEOBJECTSCALLBACKW;
alias LPDIENUMEFFECTSCALLBACKW = extern(Windows) BOOL function(LPCDIEFFECTINFOW, LPVOID);
alias LPDIENUMDEVICESCALLBACKW = extern(Windows) BOOL function(LPCDIDEVICEINSTANCEW, LPVOID);

alias LPDIENUMCREATEDEFFECTOBJECTSCALLBACK = BOOL function(LPDIRECTINPUTEFFECT, LPVOID);

struct DIFILEEFFECT {
DWORD dwSize;
GUID GuidEffect;
LPCDIEFFECT lpDiEffect;
CHAR[MAX_PATH] szFriendlyName;
}
alias DIFILEEFFECT* LPDIFILEEFFECT;

alias const(DIFILEEFFECT)* LPCDIFILEEFFECT;
alias BOOL function(LPCDIFILEEFFECT, LPVOID) LPDIENUMEFFECTSINFILECALLBACK;

struct DIDEVICEOBJECTDATA {
    DWORD dwOfs;
    DWORD dwData;
    DWORD dwTimeStamp;
    DWORD dwSequence;
    UINT_PTR uAppData;
}
alias DIDEVICEOBJECTDATA* LPDIDEVICEOBJECTDATA;
alias const(DIDEVICEOBJECTDATA)* LPCDIDEVICEOBJECTDATA;

struct _DIOBJECTDATAFORMAT {
    const(GUID)* pguid;
    DWORD dwOfs;
    DWORD dwType;
    DWORD dwFlags;
}
alias _DIOBJECTDATAFORMAT DIOBJECTDATAFORMAT;
alias _DIOBJECTDATAFORMAT* LPDIOBJECTDATAFORMAT;
alias const(DIOBJECTDATAFORMAT)* LPCDIOBJECTDATAFORMAT;

// D interfaces are pointers (so LP prefix)
alias LPDIRECTINPUTW = IDirectInputW;
alias LPDIRECTINPUT8W = IDirectInput8W;
alias LPDIRECTINPUTDEVICEW = IDirectInputDeviceW;
alias LPDIRECTINPUTDEVICE8W = IDirectInputDevice8W;
alias LPDIRECTINPUTEFFECT = IDirectInputEffect;

interface IDirectInputW : IUnknown {
extern(Windows) nothrow @system:
    HRESULT CreateDevice(REFGUID, LPDIRECTINPUTDEVICEW*, LPUNKNOWN);
    HRESULT EnumDevices(DWORD, LPDIENUMDEVICESCALLBACKW, LPVOID, DWORD);
    HRESULT GetDeviceStatus(REFGUID);
    HRESULT RunControlPanel(HWND, DWORD);
    HRESULT Initialize(HINSTANCE, DWORD);
}

interface IDirectInputDeviceW : IUnknown {
extern(Windows) nothrow @system:
    HRESULT GetCapabilities(LPDIDEVCAPS);
    HRESULT EnumObjects(LPDIENUMDEVICEOBJECTSCALLBACKW, LPVOID, DWORD);
    HRESULT GetProperty(REFGUID, LPDIPROPHEADER);
    HRESULT SetProperty(REFGUID, LPCDIPROPHEADER);
    HRESULT Acquire();
    HRESULT Unacquire();
    HRESULT GetDeviceState(DWORD, LPVOID);
    HRESULT GetDeviceData(DWORD, LPDIDEVICEOBJECTDATA, LPDWORD, DWORD);
    HRESULT SetDataFormat(LPCDIDATAFORMAT);
    HRESULT SetEventNotification(HANDLE);
    HRESULT SetCooperativeLevel(HWND, DWORD);
    HRESULT GetObjectInfo(LPDIDEVICEOBJECTINSTANCEW, DWORD, DWORD);
    HRESULT GetDeviceInfo(LPDIDEVICEINSTANCEW);
    HRESULT RunControlPanel(HWND, DWORD);
    HRESULT Initialize(HINSTANCE, DWORD, REFGUID);
}

interface IDirectInputEffect : IUnknown {
extern(Windows) nothrow @system:
    HRESULT Initialize(HINSTANCE, DWORD, REFGUID);
    HRESULT GetEffectGuid(LPGUID);
    HRESULT GetParameters(LPDIEFFECT, DWORD);
    HRESULT SetParameters(LPCDIEFFECT, DWORD);
    HRESULT Start(DWORD, DWORD);
    HRESULT Stop();
    HRESULT GetEffectStatus(LPDWORD);
    HRESULT Download();
    HRESULT Unload();
    HRESULT Escape(LPDIEFFESCAPE);
}

struct _DIDEVICEIMAGEINFOW {
	WCHAR[MAX_PATH] tszImagePath;
	DWORD dwFlags;
	DWORD dwViewID;
	RECT rcOverlay;
	DWORD dwObjID;
	DWORD dwcValidPts;
	POINT[5] rgptCalloutLine;
	RECT rcCalloutRect;
	DWORD dwTextAlign;
}alias _DIDEVICEIMAGEINFOW DIDEVICEIMAGEINFOW;alias _DIDEVICEIMAGEINFOW* LPDIDEVICEIMAGEINFOW;
alias const(DIDEVICEIMAGEINFOW)* LPCDIDEVICEIMAGEINFOW;

struct _DIDEVICEIMAGEINFOHEADERW {
	DWORD dwSize;
	DWORD dwSizeImageInfo;
	DWORD dwcViews;
	DWORD dwcButtons;
	DWORD dwcAxes;
	DWORD dwcPOVs;
	DWORD dwBufferSize;
	DWORD dwBufferUsed;
	LPDIDEVICEIMAGEINFOW lprgImageInfoArray;
}alias _DIDEVICEIMAGEINFOHEADERW DIDEVICEIMAGEINFOHEADERW;alias _DIDEVICEIMAGEINFOHEADERW* LPDIDEVICEIMAGEINFOHEADERW;
alias const(DIDEVICEIMAGEINFOHEADERW)* LPCDIDEVICEIMAGEINFOHEADERW;

struct _DIACTIONW {
	UINT_PTR uAppData;
	DWORD dwSemantic;
	DWORD dwFlags;
	union {
        LPCWSTR lptszActionName;
		UINT uResIdString;
	}
	GUID guidInstance;
	DWORD dwObjID;
	DWORD dwHow;
}
alias DIACTIONW = _DIACTIONW; alias LPDIACTIONW = _DIACTIONW;
alias const(DIACTIONW)* LPCDIACTIONW;

struct _DIACTIONFORMATW {
	DWORD dwSize;
	DWORD dwActionSize;
	DWORD dwDataSize;
	DWORD dwNumActions;
	LPDIACTIONW rgoAction;
	GUID guidActionMap;
	DWORD dwGenre;
	DWORD dwBufferSize;
	LONG lAxisMin;
	LONG lAxisMax;
	HINSTANCE hInstString;
	FILETIME ftTimeStamp;
	DWORD dwCRC;
	WCHAR[MAX_PATH] tszActionMap;
}alias _DIACTIONFORMATW DIACTIONFORMATW;alias _DIACTIONFORMATW* LPDIACTIONFORMATW;
alias const(DIACTIONFORMATW)* LPCDIACTIONFORMATW;

alias IDirectInputDevice8 = IDirectInputDevice8W;
interface IDirectInputDevice8W : IUnknown {
extern(Windows) nothrow @system:
	/*** IDirectInputDeviceW methods ***/
	HRESULT GetCapabilities(LPDIDEVCAPS lpDIDevCaps);
	HRESULT EnumObjects(LPDIENUMDEVICEOBJECTSCALLBACKW lpCallback, LPVOID pvRef, DWORD dwFlags);
	HRESULT GetProperty(REFGUID rguidProp, LPDIPROPHEADER pdiph);
	HRESULT SetProperty(REFGUID rguidProp, LPCDIPROPHEADER pdiph);
	HRESULT Acquire();
	HRESULT Unacquire();
	HRESULT GetDeviceState(DWORD cbData, LPVOID lpvData);
	HRESULT GetDeviceData(DWORD cbObjectData, LPDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD dwFlags);
	HRESULT SetDataFormat(LPCDIDATAFORMAT lpdf);
	HRESULT SetEventNotification(HANDLE hEvent);
	HRESULT SetCooperativeLevel(HWND hwnd, DWORD dwFlags);
	HRESULT GetObjectInfo(LPDIDEVICEOBJECTINSTANCEW pdidoi, DWORD dwObj, DWORD dwHow);
	HRESULT GetDeviceInfo(LPDIDEVICEINSTANCEW pdidi);
	HRESULT RunControlPanel(HWND hwndOwner, DWORD dwFlags);
	HRESULT Initialize(HINSTANCE hinst, DWORD dwVersion, REFGUID rguid);
	/*** IDirectInputDevice2W methods ***/
	HRESULT CreateEffect(REFGUID rguid, LPCDIEFFECT lpeff, LPDIRECTINPUTEFFECT *ppdeff, LPUNKNOWN punkOuter);
	HRESULT EnumEffects(LPDIENUMEFFECTSCALLBACKW lpCallback, LPVOID pvRef, DWORD dwEffType);
	HRESULT GetEffectInfo(LPDIEFFECTINFOW pdei, REFGUID rguid);
	HRESULT GetForceFeedbackState(LPDWORD pdwOut);
	HRESULT SendForceFeedbackCommand(DWORD dwFlags);
	HRESULT EnumCreatedEffectObjects(LPDIENUMCREATEDEFFECTOBJECTSCALLBACK lpCallback, LPVOID pvRef, DWORD fl);
	HRESULT Escape(LPDIEFFESCAPE pesc);
	HRESULT Poll();
	HRESULT SendDeviceData(DWORD cbObjectData, LPCDIDEVICEOBJECTDATA rgdod, LPDWORD pdwInOut, DWORD fl);
	/*** IDirectInputDevice7W methods ***/
	HRESULT EnumEffectsInFile(LPCWSTR lpszFileName,LPDIENUMEFFECTSINFILECALLBACK pec,LPVOID pvRef,DWORD dwFlags);
	HRESULT WriteEffectToFile(LPCWSTR lpszFileName,DWORD dwEntries,LPDIFILEEFFECT rgDiFileEft,DWORD dwFlags);
	/*** IDirectInputDevice8W methods ***/
	HRESULT BuildActionMap(LPDIACTIONFORMATW lpdiaf, LPCWSTR lpszUserName, DWORD dwFlags);
	HRESULT SetActionMap(LPDIACTIONFORMATW lpdiaf, LPCWSTR lpszUserName, DWORD dwFlags);
	HRESULT GetImageInfo(LPDIDEVICEIMAGEINFOHEADERW lpdiDevImageInfoHeader);
}

alias DWORD D3DCOLOR;

struct _DICOLORSET {
	DWORD dwSize;
	D3DCOLOR cTextFore;
	D3DCOLOR cTextHighlight;
	D3DCOLOR cCalloutLine;
	D3DCOLOR cCalloutHighlight;
	D3DCOLOR cBorder;
	D3DCOLOR cControlFill;
	D3DCOLOR cHighlightFill;
	D3DCOLOR cAreaFill;
}
alias _DICOLORSET DICOLORSET;
alias _DICOLORSET* LPDICOLORSET;
alias const(DICOLORSET)* LPCDICOLORSET;

struct _DICONFIGUREDEVICESPARAMSW {
	DWORD dwSize;
	DWORD dwcUsers;
	LPWSTR lptszUserNames;
	DWORD dwcFormats;
	LPDIACTIONFORMATW lprgFormats;
	HWND hwnd;
	DICOLORSET dics;
	LPUNKNOWN lpUnkDDSTarget;
}
alias _DICONFIGUREDEVICESPARAMSW DICONFIGUREDEVICESPARAMSW;
alias _DICONFIGUREDEVICESPARAMSW* LPDICONFIGUREDEVICESPARAMSW;
alias const(DICONFIGUREDEVICESPARAMSW)* LPCDICONFIGUREDEVICESPARAMSW;

alias IDirectInput8 = IDirectInput8W;
interface IDirectInput8W : IUnknown {
extern(Windows) nothrow @system:
	/*** IDirectInput8W methods ***/
	HRESULT CreateDevice(REFGUID rguid, LPDIRECTINPUTDEVICE8W* lplpDirectInputDevice, LPUNKNOWN pUnkOuter);
	HRESULT EnumDevices(DWORD dwDevType, LPDIENUMDEVICESCALLBACKW lpCallback, LPVOID pvRef, DWORD dwFlags);
	HRESULT GetDeviceStatus(REFGUID rguidInstance);
	HRESULT RunControlPanel(HWND hwndOwner, DWORD dwFlags);
	HRESULT Initialize(HINSTANCE hinst, DWORD dwVersion);
	HRESULT FindDevice(REFGUID rguid, LPCWSTR pszName, LPGUID pguidInstance);
	HRESULT EnumDevicesBySemantics(LPCWSTR ptszUserName, LPDIACTIONFORMATW lpdiActionFormat, LPDIENUMDEVICESBYSEMANTICSCBW lpCallback, LPVOID pvRef, DWORD dwFlags);
	HRESULT ConfigureDevices(LPDICONFIGUREDEVICESCALLBACK, LPDICONFIGUREDEVICESPARAMSW lpdiCDParams, DWORD dwFlags, LPVOID pvRefData);
}
