/// Needed C declarations taken out of /usr/include/linux/input.h
module glfw3.linuxinput;

version(linux):

import core.sys.posix.sys.ioctl;

struct input_absinfo {
	int value;
	int minimum;
	int maximum;
	int fuzz;
	int flat;
	int resolution;
}

struct input_id {
	ushort bustype;
	ushort vendor;
	ushort product;
	ushort version_;
}

struct input_event {
	import core.sys.posix.sys.time: timeval;
	timeval time;
	ushort type;
	ushort code;
	int value;
}

auto EVIOCGBIT(T)(int ev) {
	return _IOC!T(_IOC_READ, 'E', 0x20 + (ev));
}

auto EVIOCGABS(T)(T abs) {return _IOR!input_absinfo('E', 0x40 + (abs));}
auto EVIOCSABS(T)(T abs) {return _IOW!input_absinfo('E', 0xc0 + (abs));}

enum EVIOCGID = _IOR!input_id('E', 0x02);
auto EVIOCGNAME(T)() {return _IOC!T(_IOC_READ, 'E', 0x06);}

enum EVIOCSFF = _IOW!ff_effect('E', 0x80);
enum EVIOCRMFF = _IOW!int('E', 0x81);
enum EVIOCGEFFECTS = _IOR!int('E', 0x84);
enum EVIOCGRAB = _IOW!int('E', 0x90);
enum EVIOCREVOKE = _IOW!int('E', 0x91);

// force feedback
enum FF_STATUS_STOPPED =	0x00;
enum FF_STATUS_PLAYING =	0x01;
enum FF_STATUS_MAX =		0x01;

struct ff_replay {
	ushort length;
	ushort delay;
}

struct ff_trigger {
	ushort button;
	ushort interval;
}

struct ff_envelope {
	ushort attack_length;
	ushort attack_level;
	ushort fade_length;
	ushort fade_level;
}

struct ff_constant_effect {
	short level;
	ff_envelope envelope;
}

struct ff_ramp_effect {
	short start_level;
	short end_level;
	ff_envelope envelope;
}

struct ff_condition_effect {
	ushort right_saturation;
	ushort left_saturation;

	short right_coeff;
	short left_coeff;

	ushort deadband;
	short center;
}

struct ff_periodic_effect {
	ushort waveform;
	ushort period;
	short magnitude;
	short offset;
	ushort phase;

	ff_envelope envelope;

	uint custom_len;
	short* custom_data;
}

struct ff_rumble_effect {
	ushort strong_magnitude;
	ushort weak_magnitude;
}

struct ff_effect {
	ushort type;
	short id;
	ushort direction;
	ff_trigger trigger;
	ff_replay replay;

	struct _U {
		union {
			ff_constant_effect constant;
			ff_ramp_effect ramp;
			ff_periodic_effect periodic;
			ff_condition_effect[2] condition;
			ff_rumble_effect rumble;
		}
	}
	_U u;
}

enum FF_RUMBLE =	0x50;
enum FF_PERIODIC =	0x51;
enum FF_CONSTANT =	0x52;
enum FF_SPRING =	0x53;
enum FF_FRICTION =	0x54;
enum FF_DAMPER =	0x55;
enum FF_INERTIA =	0x56;
enum FF_RAMP =		0x57;

enum FF_EFFECT_MIN =	FF_RUMBLE;
enum FF_EFFECT_MAX =	FF_RAMP;

enum FF_SQUARE =	0x58;
enum FF_TRIANGLE =	0x59;
enum FF_SINE =		0x5a;
enum FF_SAW_UP =	0x5b;
enum FF_SAW_DOWN =	0x5c;
enum FF_CUSTOM =	0x5d;

enum FF_WAVEFORM_MIN =	FF_SQUARE;
enum FF_WAVEFORM_MAX =	FF_CUSTOM;

enum FF_GAIN =		0x60;
enum FF_AUTOCENTER =	0x61;

enum FF_MAX_EFFECTS =	FF_GAIN;

enum FF_MAX =		0x7f;
enum FF_CNT =		(FF_MAX+1);

//
// input-event-codes.h
//

enum INPUT_PROP_POINTER = 0x00;
enum INPUT_PROP_DIRECT = 0x01;
enum INPUT_PROP_BUTTONPAD = 0x02;
enum INPUT_PROP_SEMI_MT = 0x03;
enum INPUT_PROP_TOPBUTTONPAD = 0x04;
enum INPUT_PROP_POINTING_STICK = 0x05;
enum INPUT_PROP_ACCELEROMETER = 0x06;

enum INPUT_PROP_MAX = 0x1f;
enum INPUT_PROP_CNT = (INPUT_PROP_MAX + 1);

enum EV_SYN = 0x00;
enum EV_KEY = 0x01;
enum EV_REL = 0x02;
enum EV_ABS = 0x03;
enum EV_MSC = 0x04;
enum EV_SW = 0x05;
enum EV_LED = 0x11;
enum EV_SND = 0x12;
enum EV_REP = 0x14;
enum EV_FF = 0x15;
enum EV_PWR = 0x16;
enum EV_FF_STATUS = 0x17;
enum EV_MAX = 0x1f;
enum EV_CNT = (EV_MAX+1);

enum SYN_REPORT = 0;
enum SYN_CONFIG = 1;
enum SYN_MT_REPORT = 2;
enum SYN_DROPPED = 3;
enum SYN_MAX = 0xf;
enum SYN_CNT = (SYN_MAX+1);

enum KEY_RESERVED = 0;
enum KEY_ESC = 1;
enum KEY_1 = 2;
enum KEY_2 = 3;
enum KEY_3 = 4;
enum KEY_4 = 5;
enum KEY_5 = 6;
enum KEY_6 = 7;
enum KEY_7 = 8;
enum KEY_8 = 9;
enum KEY_9 = 10;
enum KEY_0 = 11;
enum KEY_MINUS = 12;
enum KEY_EQUAL = 13;
enum KEY_BACKSPACE = 14;
enum KEY_TAB = 15;
enum KEY_Q = 16;
enum KEY_W = 17;
enum KEY_E = 18;
enum KEY_R = 19;
enum KEY_T = 20;
enum KEY_Y = 21;
enum KEY_U = 22;
enum KEY_I = 23;
enum KEY_O = 24;
enum KEY_P = 25;
enum KEY_LEFTBRACE = 26;
enum KEY_RIGHTBRACE = 27;
enum KEY_ENTER = 28;
enum KEY_LEFTCTRL = 29;
enum KEY_A = 30;
enum KEY_S = 31;
enum KEY_D = 32;
enum KEY_F = 33;
enum KEY_G = 34;
enum KEY_H = 35;
enum KEY_J = 36;
enum KEY_K = 37;
enum KEY_L = 38;
enum KEY_SEMICOLON = 39;
enum KEY_APOSTROPHE = 40;
enum KEY_GRAVE = 41;
enum KEY_LEFTSHIFT = 42;
enum KEY_BACKSLASH = 43;
enum KEY_Z = 44;
enum KEY_X = 45;
enum KEY_C = 46;
enum KEY_V = 47;
enum KEY_B = 48;
enum KEY_N = 49;
enum KEY_M = 50;
enum KEY_COMMA = 51;
enum KEY_DOT = 52;
enum KEY_SLASH = 53;
enum KEY_RIGHTSHIFT = 54;
enum KEY_KPASTERISK = 55;
enum KEY_LEFTALT = 56;
enum KEY_SPACE = 57;
enum KEY_CAPSLOCK = 58;
enum KEY_F1 = 59;
enum KEY_F2 = 60;
enum KEY_F3 = 61;
enum KEY_F4 = 62;
enum KEY_F5 = 63;
enum KEY_F6 = 64;
enum KEY_F7 = 65;
enum KEY_F8 = 66;
enum KEY_F9 = 67;
enum KEY_F10 = 68;
enum KEY_NUMLOCK = 69;
enum KEY_SCROLLLOCK = 70;
enum KEY_KP7 = 71;
enum KEY_KP8 = 72;
enum KEY_KP9 = 73;
enum KEY_KPMINUS = 74;
enum KEY_KP4 = 75;
enum KEY_KP5 = 76;
enum KEY_KP6 = 77;
enum KEY_KPPLUS = 78;
enum KEY_KP1 = 79;
enum KEY_KP2 = 80;
enum KEY_KP3 = 81;
enum KEY_KP0 = 82;
enum KEY_KPDOT = 83;

enum KEY_ZENKAKUHANKAKU = 85;
enum KEY_102ND = 86;
enum KEY_F11 = 87;
enum KEY_F12 = 88;
enum KEY_RO = 89;
enum KEY_KATAKANA = 90;
enum KEY_HIRAGANA = 91;
enum KEY_HENKAN = 92;
enum KEY_KATAKANAHIRAGANA = 93;
enum KEY_MUHENKAN = 94;
enum KEY_KPJPCOMMA = 95;
enum KEY_KPENTER = 96;
enum KEY_RIGHTCTRL = 97;
enum KEY_KPSLASH = 98;
enum KEY_SYSRQ = 99;
enum KEY_RIGHTALT = 100;
enum KEY_LINEFEED = 101;
enum KEY_HOME = 102;
enum KEY_UP = 103;
enum KEY_PAGEUP = 104;
enum KEY_LEFT = 105;
enum KEY_RIGHT = 106;
enum KEY_END = 107;
enum KEY_DOWN = 108;
enum KEY_PAGEDOWN = 109;
enum KEY_INSERT = 110;
enum KEY_DELETE = 111;
enum KEY_MACRO = 112;
enum KEY_MUTE = 113;
enum KEY_VOLUMEDOWN = 114;
enum KEY_VOLUMEUP = 115;
enum KEY_POWER = 116;
enum KEY_KPEQUAL = 117;
enum KEY_KPPLUSMINUS = 118;
enum KEY_PAUSE = 119;
enum KEY_SCALE = 120;

enum KEY_KPCOMMA = 121;
enum KEY_HANGEUL = 122;
enum KEY_HANGUEL = KEY_HANGEUL;
enum KEY_HANJA = 123;
enum KEY_YEN = 124;
enum KEY_LEFTMETA = 125;
enum KEY_RIGHTMETA = 126;
enum KEY_COMPOSE = 127;

enum KEY_STOP = 128;
enum KEY_AGAIN = 129;
enum KEY_PROPS = 130;
enum KEY_UNDO = 131;
enum KEY_FRONT = 132;
enum KEY_COPY = 133;
enum KEY_OPEN = 134;
enum KEY_PASTE = 135;
enum KEY_FIND = 136;
enum KEY_CUT = 137;
enum KEY_HELP = 138;
enum KEY_MENU = 139;
enum KEY_CALC = 140;
enum KEY_SETUP = 141;
enum KEY_SLEEP = 142;
enum KEY_WAKEUP = 143;
enum KEY_FILE = 144;
enum KEY_SENDFILE = 145;
enum KEY_DELETEFILE = 146;
enum KEY_XFER = 147;
enum KEY_PROG1 = 148;
enum KEY_PROG2 = 149;
enum KEY_WWW = 150;
enum KEY_MSDOS = 151;
enum KEY_COFFEE = 152;
enum KEY_SCREENLOCK = KEY_COFFEE;
enum KEY_ROTATE_DISPLAY = 153;
enum KEY_DIRECTION = KEY_ROTATE_DISPLAY;
enum KEY_CYCLEWINDOWS = 154;
enum KEY_MAIL = 155;
enum KEY_BOOKMARKS = 156;
enum KEY_COMPUTER = 157;
enum KEY_BACK = 158;
enum KEY_FORWARD = 159;
enum KEY_CLOSECD = 160;
enum KEY_EJECTCD = 161;
enum KEY_EJECTCLOSECD = 162;
enum KEY_NEXTSONG = 163;
enum KEY_PLAYPAUSE = 164;
enum KEY_PREVIOUSSONG = 165;
enum KEY_STOPCD = 166;
enum KEY_RECORD = 167;
enum KEY_REWIND = 168;
enum KEY_PHONE = 169;
enum KEY_ISO = 170;
enum KEY_CONFIG = 171;
enum KEY_HOMEPAGE = 172;
enum KEY_REFRESH = 173;
enum KEY_EXIT = 174;
enum KEY_MOVE = 175;
enum KEY_EDIT = 176;
enum KEY_SCROLLUP = 177;
enum KEY_SCROLLDOWN = 178;
enum KEY_KPLEFTPAREN = 179;
enum KEY_KPRIGHTPAREN = 180;
enum KEY_NEW = 181;
enum KEY_REDO = 182;

enum KEY_F13 = 183;
enum KEY_F14 = 184;
enum KEY_F15 = 185;
enum KEY_F16 = 186;
enum KEY_F17 = 187;
enum KEY_F18 = 188;
enum KEY_F19 = 189;
enum KEY_F20 = 190;
enum KEY_F21 = 191;
enum KEY_F22 = 192;
enum KEY_F23 = 193;
enum KEY_F24 = 194;

enum KEY_PLAYCD = 200;
enum KEY_PAUSECD = 201;
enum KEY_PROG3 = 202;
enum KEY_PROG4 = 203;
enum KEY_DASHBOARD = 204;
enum KEY_SUSPEND = 205;
enum KEY_CLOSE = 206;
enum KEY_PLAY = 207;
enum KEY_FASTFORWARD = 208;
enum KEY_BASSBOOST = 209;
enum KEY_PRINT = 210;
enum KEY_HP = 211;
enum KEY_CAMERA = 212;
enum KEY_SOUND = 213;
enum KEY_QUESTION = 214;
enum KEY_EMAIL = 215;
enum KEY_CHAT = 216;
enum KEY_SEARCH = 217;
enum KEY_CONNECT = 218;
enum KEY_FINANCE = 219;
enum KEY_SPORT = 220;
enum KEY_SHOP = 221;
enum KEY_ALTERASE = 222;
enum KEY_CANCEL = 223;
enum KEY_BRIGHTNESSDOWN = 224;
enum KEY_BRIGHTNESSUP = 225;
enum KEY_MEDIA = 226;

enum KEY_SWITCHVIDEOMODE = 227;
enum KEY_KBDILLUMTOGGLE = 228;
enum KEY_KBDILLUMDOWN = 229;
enum KEY_KBDILLUMUP = 230;

enum KEY_SEND = 231;
enum KEY_REPLY = 232;
enum KEY_FORWARDMAIL = 233;
enum KEY_SAVE = 234;
enum KEY_DOCUMENTS = 235;

enum KEY_BATTERY = 236;

enum KEY_BLUETOOTH = 237;
enum KEY_WLAN = 238;
enum KEY_UWB = 239;

enum KEY_UNKNOWN = 240;

enum KEY_VIDEO_NEXT = 241;
enum KEY_VIDEO_PREV = 242;
enum KEY_BRIGHTNESS_CYCLE = 243;
enum KEY_BRIGHTNESS_AUTO = 244;
enum KEY_BRIGHTNESS_ZERO = KEY_BRIGHTNESS_AUTO;
enum KEY_DISPLAY_OFF = 245;

enum KEY_WWAN = 246;
enum KEY_WIMAX = KEY_WWAN;
enum KEY_RFKILL = 247;

enum KEY_MICMUTE = 248;

enum BTN_MISC = 0x100;
enum BTN_0 = 0x100;
enum BTN_1 = 0x101;
enum BTN_2 = 0x102;
enum BTN_3 = 0x103;
enum BTN_4 = 0x104;
enum BTN_5 = 0x105;
enum BTN_6 = 0x106;
enum BTN_7 = 0x107;
enum BTN_8 = 0x108;
enum BTN_9 = 0x109;

enum BTN_MOUSE = 0x110;
enum BTN_LEFT = 0x110;
enum BTN_RIGHT = 0x111;
enum BTN_MIDDLE = 0x112;
enum BTN_SIDE = 0x113;
enum BTN_EXTRA = 0x114;
enum BTN_FORWARD = 0x115;
enum BTN_BACK = 0x116;
enum BTN_TASK = 0x117;

enum BTN_JOYSTICK = 0x120;
enum BTN_TRIGGER = 0x120;
enum BTN_THUMB = 0x121;
enum BTN_THUMB2 = 0x122;
enum BTN_TOP = 0x123;
enum BTN_TOP2 = 0x124;
enum BTN_PINKIE = 0x125;
enum BTN_BASE = 0x126;
enum BTN_BASE2 = 0x127;
enum BTN_BASE3 = 0x128;
enum BTN_BASE4 = 0x129;
enum BTN_BASE5 = 0x12a;
enum BTN_BASE6 = 0x12b;
enum BTN_DEAD = 0x12f;

enum BTN_GAMEPAD = 0x130;
enum BTN_SOUTH = 0x130;
enum BTN_A = BTN_SOUTH;
enum BTN_EAST = 0x131;
enum BTN_B = BTN_EAST;
enum BTN_C = 0x132;
enum BTN_NORTH = 0x133;
enum BTN_X = BTN_NORTH;
enum BTN_WEST = 0x134;
enum BTN_Y = BTN_WEST;
enum BTN_Z = 0x135;
enum BTN_TL = 0x136;
enum BTN_TR = 0x137;
enum BTN_TL2 = 0x138;
enum BTN_TR2 = 0x139;
enum BTN_SELECT = 0x13a;
enum BTN_START = 0x13b;
enum BTN_MODE = 0x13c;
enum BTN_THUMBL = 0x13d;
enum BTN_THUMBR = 0x13e;

enum BTN_DIGI = 0x140;
enum BTN_TOOL_PEN = 0x140;
enum BTN_TOOL_RUBBER = 0x141;
enum BTN_TOOL_BRUSH = 0x142;
enum BTN_TOOL_PENCIL = 0x143;
enum BTN_TOOL_AIRBRUSH = 0x144;
enum BTN_TOOL_FINGER = 0x145;
enum BTN_TOOL_MOUSE = 0x146;
enum BTN_TOOL_LENS = 0x147;
enum BTN_TOOL_QUINTTAP = 0x148;
enum BTN_TOUCH = 0x14a;
enum BTN_STYLUS = 0x14b;
enum BTN_STYLUS2 = 0x14c;
enum BTN_TOOL_DOUBLETAP = 0x14d;
enum BTN_TOOL_TRIPLETAP = 0x14e;
enum BTN_TOOL_QUADTAP = 0x14f;

enum BTN_WHEEL = 0x150;
enum BTN_GEAR_DOWN = 0x150;
enum BTN_GEAR_UP = 0x151;

enum KEY_OK = 0x160;
enum KEY_SELECT = 0x161;
enum KEY_GOTO = 0x162;
enum KEY_CLEAR = 0x163;
enum KEY_POWER2 = 0x164;
enum KEY_OPTION = 0x165;
enum KEY_INFO = 0x166;
enum KEY_TIME = 0x167;
enum KEY_VENDOR = 0x168;
enum KEY_ARCHIVE = 0x169;
enum KEY_PROGRAM = 0x16a;
enum KEY_CHANNEL = 0x16b;
enum KEY_FAVORITES = 0x16c;
enum KEY_EPG = 0x16d;
enum KEY_PVR = 0x16e;
enum KEY_MHP = 0x16f;
enum KEY_LANGUAGE = 0x170;
enum KEY_TITLE = 0x171;
enum KEY_SUBTITLE = 0x172;
enum KEY_ANGLE = 0x173;
enum KEY_ZOOM = 0x174;
enum KEY_MODE = 0x175;
enum KEY_KEYBOARD = 0x176;
enum KEY_SCREEN = 0x177;
enum KEY_PC = 0x178;
enum KEY_TV = 0x179;
enum KEY_TV2 = 0x17a;
enum KEY_VCR = 0x17b;
enum KEY_VCR2 = 0x17c;
enum KEY_SAT = 0x17d;
enum KEY_SAT2 = 0x17e;
enum KEY_CD = 0x17f;
enum KEY_TAPE = 0x180;
enum KEY_RADIO = 0x181;
enum KEY_TUNER = 0x182;
enum KEY_PLAYER = 0x183;
enum KEY_TEXT = 0x184;
enum KEY_DVD = 0x185;
enum KEY_AUX = 0x186;
enum KEY_MP3 = 0x187;
enum KEY_AUDIO = 0x188;
enum KEY_VIDEO = 0x189;
enum KEY_DIRECTORY = 0x18a;
enum KEY_LIST = 0x18b;
enum KEY_MEMO = 0x18c;
enum KEY_CALENDAR = 0x18d;
enum KEY_RED = 0x18e;
enum KEY_GREEN = 0x18f;
enum KEY_YELLOW = 0x190;
enum KEY_BLUE = 0x191;
enum KEY_CHANNELUP = 0x192;
enum KEY_CHANNELDOWN = 0x193;
enum KEY_FIRST = 0x194;
enum KEY_LAST = 0x195;
enum KEY_AB = 0x196;
enum KEY_NEXT = 0x197;
enum KEY_RESTART = 0x198;
enum KEY_SLOW = 0x199;
enum KEY_SHUFFLE = 0x19a;
enum KEY_BREAK = 0x19b;
enum KEY_PREVIOUS = 0x19c;
enum KEY_DIGITS = 0x19d;
enum KEY_TEEN = 0x19e;
enum KEY_TWEN = 0x19f;
enum KEY_VIDEOPHONE = 0x1a0;
enum KEY_GAMES = 0x1a1;
enum KEY_ZOOMIN = 0x1a2;
enum KEY_ZOOMOUT = 0x1a3;
enum KEY_ZOOMRESET = 0x1a4;
enum KEY_WORDPROCESSOR = 0x1a5;
enum KEY_EDITOR = 0x1a6;
enum KEY_SPREADSHEET = 0x1a7;
enum KEY_GRAPHICSEDITOR = 0x1a8;
enum KEY_PRESENTATION = 0x1a9;
enum KEY_DATABASE = 0x1aa;
enum KEY_NEWS = 0x1ab;
enum KEY_VOICEMAIL = 0x1ac;
enum KEY_ADDRESSBOOK = 0x1ad;
enum KEY_MESSENGER = 0x1ae;
enum KEY_DISPLAYTOGGLE = 0x1af;
enum KEY_BRIGHTNESS_TOGGLE = KEY_DISPLAYTOGGLE;
enum KEY_SPELLCHECK = 0x1b0;
enum KEY_LOGOFF = 0x1b1;

enum KEY_DOLLAR = 0x1b2;
enum KEY_EURO = 0x1b3;

enum KEY_FRAMEBACK = 0x1b4;
enum KEY_FRAMEFORWARD = 0x1b5;
enum KEY_CONTEXT_MENU = 0x1b6;
enum KEY_MEDIA_REPEAT = 0x1b7;
enum KEY_10CHANNELSUP = 0x1b8;
enum KEY_10CHANNELSDOWN = 0x1b9;
enum KEY_IMAGES = 0x1ba;

enum KEY_DEL_EOL = 0x1c0;
enum KEY_DEL_EOS = 0x1c1;
enum KEY_INS_LINE = 0x1c2;
enum KEY_DEL_LINE = 0x1c3;

enum KEY_FN = 0x1d0;
enum KEY_FN_ESC = 0x1d1;
enum KEY_FN_F1 = 0x1d2;
enum KEY_FN_F2 = 0x1d3;
enum KEY_FN_F3 = 0x1d4;
enum KEY_FN_F4 = 0x1d5;
enum KEY_FN_F5 = 0x1d6;
enum KEY_FN_F6 = 0x1d7;
enum KEY_FN_F7 = 0x1d8;
enum KEY_FN_F8 = 0x1d9;
enum KEY_FN_F9 = 0x1da;
enum KEY_FN_F10 = 0x1db;
enum KEY_FN_F11 = 0x1dc;
enum KEY_FN_F12 = 0x1dd;
enum KEY_FN_1 = 0x1de;
enum KEY_FN_2 = 0x1df;
enum KEY_FN_D = 0x1e0;
enum KEY_FN_E = 0x1e1;
enum KEY_FN_F = 0x1e2;
enum KEY_FN_S = 0x1e3;
enum KEY_FN_B = 0x1e4;

enum KEY_BRL_DOT1 = 0x1f1;
enum KEY_BRL_DOT2 = 0x1f2;
enum KEY_BRL_DOT3 = 0x1f3;
enum KEY_BRL_DOT4 = 0x1f4;
enum KEY_BRL_DOT5 = 0x1f5;
enum KEY_BRL_DOT6 = 0x1f6;
enum KEY_BRL_DOT7 = 0x1f7;
enum KEY_BRL_DOT8 = 0x1f8;
enum KEY_BRL_DOT9 = 0x1f9;
enum KEY_BRL_DOT10 = 0x1fa;

enum KEY_NUMERIC_0 = 0x200;
enum KEY_NUMERIC_1 = 0x201;
enum KEY_NUMERIC_2 = 0x202;
enum KEY_NUMERIC_3 = 0x203;
enum KEY_NUMERIC_4 = 0x204;
enum KEY_NUMERIC_5 = 0x205;
enum KEY_NUMERIC_6 = 0x206;
enum KEY_NUMERIC_7 = 0x207;
enum KEY_NUMERIC_8 = 0x208;
enum KEY_NUMERIC_9 = 0x209;
enum KEY_NUMERIC_STAR = 0x20a;
enum KEY_NUMERIC_POUND = 0x20b;
enum KEY_NUMERIC_A = 0x20c;
enum KEY_NUMERIC_B = 0x20d;
enum KEY_NUMERIC_C = 0x20e;
enum KEY_NUMERIC_D = 0x20f;

enum KEY_CAMERA_FOCUS = 0x210;
enum KEY_WPS_BUTTON = 0x211;

enum KEY_TOUCHPAD_TOGGLE = 0x212;
enum KEY_TOUCHPAD_ON = 0x213;
enum KEY_TOUCHPAD_OFF = 0x214;

enum KEY_CAMERA_ZOOMIN = 0x215;
enum KEY_CAMERA_ZOOMOUT = 0x216;
enum KEY_CAMERA_UP = 0x217;
enum KEY_CAMERA_DOWN = 0x218;
enum KEY_CAMERA_LEFT = 0x219;
enum KEY_CAMERA_RIGHT = 0x21a;

enum KEY_ATTENDANT_ON = 0x21b;
enum KEY_ATTENDANT_OFF = 0x21c;
enum KEY_ATTENDANT_TOGGLE = 0x21d;
enum KEY_LIGHTS_TOGGLE = 0x21e;

enum BTN_DPAD_UP = 0x220;
enum BTN_DPAD_DOWN = 0x221;
enum BTN_DPAD_LEFT = 0x222;
enum BTN_DPAD_RIGHT = 0x223;

enum KEY_ALS_TOGGLE = 0x230;

enum KEY_BUTTONCONFIG = 0x240;
enum KEY_TASKMANAGER = 0x241;
enum KEY_JOURNAL = 0x242;
enum KEY_CONTROLPANEL = 0x243;
enum KEY_APPSELECT = 0x244;
enum KEY_SCREENSAVER = 0x245;
enum KEY_VOICECOMMAND = 0x246;

enum KEY_BRIGHTNESS_MIN = 0x250;
enum KEY_BRIGHTNESS_MAX = 0x251;

enum KEY_KBDINPUTASSIST_PREV = 0x260;
enum KEY_KBDINPUTASSIST_NEXT = 0x261;
enum KEY_KBDINPUTASSIST_PREVGROUP = 0x262;
enum KEY_KBDINPUTASSIST_NEXTGROUP = 0x263;
enum KEY_KBDINPUTASSIST_ACCEPT = 0x264;
enum KEY_KBDINPUTASSIST_CANCEL = 0x265;

enum KEY_RIGHT_UP = 0x266;
enum KEY_RIGHT_DOWN = 0x267;
enum KEY_LEFT_UP = 0x268;
enum KEY_LEFT_DOWN = 0x269;

enum KEY_ROOT_MENU = 0x26a;

enum KEY_MEDIA_TOP_MENU = 0x26b;
enum KEY_NUMERIC_11 = 0x26c;
enum KEY_NUMERIC_12 = 0x26d;

enum KEY_AUDIO_DESC = 0x26e;
enum KEY_3D_MODE = 0x26f;
enum KEY_NEXT_FAVORITE = 0x270;
enum KEY_STOP_RECORD = 0x271;
enum KEY_PAUSE_RECORD = 0x272;
enum KEY_VOD = 0x273;
enum KEY_UNMUTE = 0x274;
enum KEY_FASTREVERSE = 0x275;
enum KEY_SLOWREVERSE = 0x276;

enum KEY_DATA = 0x277;

enum BTN_TRIGGER_HAPPY = 0x2c0;
enum BTN_TRIGGER_HAPPY1 = 0x2c0;
enum BTN_TRIGGER_HAPPY2 = 0x2c1;
enum BTN_TRIGGER_HAPPY3 = 0x2c2;
enum BTN_TRIGGER_HAPPY4 = 0x2c3;
enum BTN_TRIGGER_HAPPY5 = 0x2c4;
enum BTN_TRIGGER_HAPPY6 = 0x2c5;
enum BTN_TRIGGER_HAPPY7 = 0x2c6;
enum BTN_TRIGGER_HAPPY8 = 0x2c7;
enum BTN_TRIGGER_HAPPY9 = 0x2c8;
enum BTN_TRIGGER_HAPPY10 = 0x2c9;
enum BTN_TRIGGER_HAPPY11 = 0x2ca;
enum BTN_TRIGGER_HAPPY12 = 0x2cb;
enum BTN_TRIGGER_HAPPY13 = 0x2cc;
enum BTN_TRIGGER_HAPPY14 = 0x2cd;
enum BTN_TRIGGER_HAPPY15 = 0x2ce;
enum BTN_TRIGGER_HAPPY16 = 0x2cf;
enum BTN_TRIGGER_HAPPY17 = 0x2d0;
enum BTN_TRIGGER_HAPPY18 = 0x2d1;
enum BTN_TRIGGER_HAPPY19 = 0x2d2;
enum BTN_TRIGGER_HAPPY20 = 0x2d3;
enum BTN_TRIGGER_HAPPY21 = 0x2d4;
enum BTN_TRIGGER_HAPPY22 = 0x2d5;
enum BTN_TRIGGER_HAPPY23 = 0x2d6;
enum BTN_TRIGGER_HAPPY24 = 0x2d7;
enum BTN_TRIGGER_HAPPY25 = 0x2d8;
enum BTN_TRIGGER_HAPPY26 = 0x2d9;
enum BTN_TRIGGER_HAPPY27 = 0x2da;
enum BTN_TRIGGER_HAPPY28 = 0x2db;
enum BTN_TRIGGER_HAPPY29 = 0x2dc;
enum BTN_TRIGGER_HAPPY30 = 0x2dd;
enum BTN_TRIGGER_HAPPY31 = 0x2de;
enum BTN_TRIGGER_HAPPY32 = 0x2df;
enum BTN_TRIGGER_HAPPY33 = 0x2e0;
enum BTN_TRIGGER_HAPPY34 = 0x2e1;
enum BTN_TRIGGER_HAPPY35 = 0x2e2;
enum BTN_TRIGGER_HAPPY36 = 0x2e3;
enum BTN_TRIGGER_HAPPY37 = 0x2e4;
enum BTN_TRIGGER_HAPPY38 = 0x2e5;
enum BTN_TRIGGER_HAPPY39 = 0x2e6;
enum BTN_TRIGGER_HAPPY40 = 0x2e7;


enum KEY_MIN_INTERESTING = KEY_MUTE;
enum KEY_MAX = 0x2ff;
enum KEY_CNT = (KEY_MAX+1);

enum REL_X = 0x00;
enum REL_Y = 0x01;
enum REL_Z = 0x02;
enum REL_RX = 0x03;
enum REL_RY = 0x04;
enum REL_RZ = 0x05;
enum REL_HWHEEL = 0x06;
enum REL_DIAL = 0x07;
enum REL_WHEEL = 0x08;
enum REL_MISC = 0x09;
enum REL_MAX = 0x0f;
enum REL_CNT = (REL_MAX+1);
enum ABS_X = 0x00;
enum ABS_Y = 0x01;
enum ABS_Z = 0x02;
enum ABS_RX = 0x03;
enum ABS_RY = 0x04;
enum ABS_RZ = 0x05;
enum ABS_THROTTLE = 0x06;
enum ABS_RUDDER = 0x07;
enum ABS_WHEEL = 0x08;
enum ABS_GAS = 0x09;
enum ABS_BRAKE = 0x0a;
enum ABS_HAT0X = 0x10;
enum ABS_HAT0Y = 0x11;
enum ABS_HAT1X = 0x12;
enum ABS_HAT1Y = 0x13;
enum ABS_HAT2X = 0x14;
enum ABS_HAT2Y = 0x15;
enum ABS_HAT3X = 0x16;
enum ABS_HAT3Y = 0x17;
enum ABS_PRESSURE = 0x18;
enum ABS_DISTANCE = 0x19;
enum ABS_TILT_X = 0x1a;
enum ABS_TILT_Y = 0x1b;
enum ABS_TOOL_WIDTH = 0x1c;

enum ABS_VOLUME = 0x20;

enum ABS_MISC = 0x28;

enum ABS_RESERVED = 0x2e;

enum ABS_MT_SLOT = 0x2f;
enum ABS_MT_TOUCH_MAJOR = 0x30;
enum ABS_MT_TOUCH_MINOR = 0x31;
enum ABS_MT_WIDTH_MAJOR = 0x32;
enum ABS_MT_WIDTH_MINOR = 0x33;
enum ABS_MT_ORIENTATION = 0x34;
enum ABS_MT_POSITION_X = 0x35;
enum ABS_MT_POSITION_Y = 0x36;
enum ABS_MT_TOOL_TYPE = 0x37;
enum ABS_MT_BLOB_ID = 0x38;
enum ABS_MT_TRACKING_ID = 0x39;
enum ABS_MT_PRESSURE = 0x3a;
enum ABS_MT_DISTANCE = 0x3b;
enum ABS_MT_TOOL_X = 0x3c;
enum ABS_MT_TOOL_Y = 0x3d;

enum ABS_MAX = 0x3f;
enum ABS_CNT = (ABS_MAX+1);

enum SW_LID = 0x00;
enum SW_TABLET_MODE = 0x01;
enum SW_HEADPHONE_INSERT = 0x02;
enum SW_RFKILL_ALL = 0x03;
enum SW_RADIO = SW_RFKILL_ALL;
enum SW_MICROPHONE_INSERT = 0x04;
enum SW_DOCK = 0x05;
enum SW_LINEOUT_INSERT = 0x06;
enum SW_JACK_PHYSICAL_INSERT = 0x07;
enum SW_VIDEOOUT_INSERT = 0x08;
enum SW_CAMERA_LENS_COVER = 0x09;
enum SW_KEYPAD_SLIDE = 0x0a;
enum SW_FRONT_PROXIMITY = 0x0b;
enum SW_ROTATE_LOCK = 0x0c;
enum SW_LINEIN_INSERT = 0x0d;
enum SW_MUTE_DEVICE = 0x0e;
enum SW_PEN_INSERTED = 0x0f;
enum SW_MAX = 0x0f;
enum SW_CNT = (SW_MAX+1);

enum MSC_SERIAL = 0x00;
enum MSC_PULSELED = 0x01;
enum MSC_GESTURE = 0x02;
enum MSC_RAW = 0x03;
enum MSC_SCAN = 0x04;
enum MSC_TIMESTAMP = 0x05;
enum MSC_MAX = 0x07;
enum MSC_CNT = (MSC_MAX+1);

enum LED_NUML = 0x00;
enum LED_CAPSL = 0x01;
enum LED_SCROLLL = 0x02;
enum LED_COMPOSE = 0x03;
enum LED_KANA = 0x04;
enum LED_SLEEP = 0x05;
enum LED_SUSPEND = 0x06;
enum LED_MUTE = 0x07;
enum LED_MISC = 0x08;
enum LED_MAIL = 0x09;
enum LED_CHARGING = 0x0a;
enum LED_MAX = 0x0f;
enum LED_CNT = (LED_MAX+1);

enum REP_DELAY = 0x00;
enum REP_PERIOD = 0x01;
enum REP_MAX = 0x01;
enum REP_CNT = (REP_MAX+1);

enum SND_CLICK = 0x00;
enum SND_BELL = 0x01;
enum SND_TONE = 0x02;
enum SND_MAX = 0x07;
enum SND_CNT = (SND_MAX+1);
