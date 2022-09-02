/// Vulkan test application adapted from GLFW's test suite
///
/// https://github.com/glfw/glfw/blob/33cd8b865d9289cfbcf3d95e6e68e4050b94fcd3/tests/triangle-vulkan.c
module app;

nothrow: @nogc:

import glfw3.api;
import erupted;
import erupted.vulkan_lib_loader;
import core.stdc.stdio;

/*
 * Draw a textured triangle with depth testing.  This is written against Intel
 * ICD.  It does not do state transition nor object memory binding like it
 * should.  It also does no error checking.
 */
/*
 * Copyright (c) 2015-2016 The Khronos Group Inc.
 * Copyright (c) 2015-2016 Valve Corporation
 * Copyright (c) 2015-2016 LunarG, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Chia-I Wu <olvaffe@gmail.com>
 * Author: Cody Northrop <cody@lunarg.com>
 * Author: Courtney Goeltzenleuchter <courtney@LunarG.com>
 * Author: Ian Elliott <ian@LunarG.com>
 * Author: Jon Ashburn <jon@lunarg.com>
 * Author: Piers Daniell <pdaniell@nvidia.com>
 * Author: Gwan-gyeong Mun <elongbug@gmail.com>
 * Porter: Camilla Löwy <elmindreda@glfw.org>
 */

import core.stdc.stdio;
import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.assert_;
//import core.stdc.signal; is missing SIGTRAP
import core.sys.posix.signal;

version (Windows) {
	import core.sys.windows.windows;
}

enum DEMO_TEXTURE_COUNT = 1;
enum VERTEX_BUFFER_BIND_ID = 0;
enum APP_SHORT_NAME = "tri";
enum APP_LONG_NAME = "The Vulkan Triangle Demo Program";

enum string ARRAY_SIZE(string a) = ` (sizeof(a) / sizeof(a[0]))`;

auto ERR_EXIT(const(char)* err_msg, const(char)* err_class) {
	printf(err_msg);
	fflush(stdout);
	return exit(1);
}

immutable ubyte[] fragShaderCode = [
	0x03, 0x02, 0x23, 0x07, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x08, 0x00,
	0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x02, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x47, 0x4c, 0x53, 0x4c, 0x2e, 0x73, 0x74, 0x64, 0x2e, 0x34, 0x35, 0x30,
	0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x07, 0x00, 0x04, 0x00, 0x00, 0x00,
	0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00,
	0x09, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x10, 0x00, 0x03, 0x00,
	0x04, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x03, 0x00, 0x03, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x90, 0x01, 0x00, 0x00, 0x04, 0x00, 0x09, 0x00,
	0x47, 0x4c, 0x5f, 0x41, 0x52, 0x42, 0x5f, 0x73, 0x65, 0x70, 0x61, 0x72,
	0x61, 0x74, 0x65, 0x5f, 0x73, 0x68, 0x61, 0x64, 0x65, 0x72, 0x5f, 0x6f,
	0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x00, 0x00, 0x04, 0x00, 0x09, 0x00,
	0x47, 0x4c, 0x5f, 0x41, 0x52, 0x42, 0x5f, 0x73, 0x68, 0x61, 0x64, 0x69,
	0x6e, 0x67, 0x5f, 0x6c, 0x61, 0x6e, 0x67, 0x75, 0x61, 0x67, 0x65, 0x5f,
	0x34, 0x32, 0x30, 0x70, 0x61, 0x63, 0x6b, 0x00, 0x05, 0x00, 0x04, 0x00,
	0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00,
	0x05, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x00, 0x75, 0x46, 0x72, 0x61,
	0x67, 0x43, 0x6f, 0x6c, 0x6f, 0x72, 0x00, 0x00, 0x05, 0x00, 0x03, 0x00,
	0x0d, 0x00, 0x00, 0x00, 0x74, 0x65, 0x78, 0x00, 0x05, 0x00, 0x05, 0x00,
	0x11, 0x00, 0x00, 0x00, 0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, 0x72, 0x64,
	0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x09, 0x00, 0x00, 0x00,
	0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00,
	0x0d, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x47, 0x00, 0x04, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x21, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x02, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x21, 0x00, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x16, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00,
	0x20, 0x00, 0x00, 0x00, 0x17, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00,
	0x06, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00,
	0x08, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00,
	0x3b, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00,
	0x03, 0x00, 0x00, 0x00, 0x19, 0x00, 0x09, 0x00, 0x0a, 0x00, 0x00, 0x00,
	0x06, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x1b, 0x00, 0x03, 0x00, 0x0b, 0x00, 0x00, 0x00,
	0x0a, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x0c, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00,
	0x0c, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x17, 0x00, 0x04, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x10, 0x00, 0x00, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00,
	0x10, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x36, 0x00, 0x05, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x02, 0x00,
	0x05, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00,
	0x0e, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00,
	0x0f, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x57, 0x00, 0x05, 0x00, 0x07, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00,
	0x0e, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00,
	0x09, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x01, 0x00,
	0x38, 0x00, 0x01, 0x00
];

immutable ubyte[] vertShaderCode = [
	0x03, 0x02, 0x23, 0x07, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x08, 0x00,
	0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x02, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x47, 0x4c, 0x53, 0x4c, 0x2e, 0x73, 0x74, 0x64, 0x2e, 0x34, 0x35, 0x30,
	0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e, 0x00, 0x00, 0x00, 0x00,
	0x09, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00,
	0x17, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x1d, 0x00, 0x00, 0x00,
	0x03, 0x00, 0x03, 0x00, 0x02, 0x00, 0x00, 0x00, 0x90, 0x01, 0x00, 0x00,
	0x04, 0x00, 0x09, 0x00, 0x47, 0x4c, 0x5f, 0x41, 0x52, 0x42, 0x5f, 0x73,
	0x65, 0x70, 0x61, 0x72, 0x61, 0x74, 0x65, 0x5f, 0x73, 0x68, 0x61, 0x64,
	0x65, 0x72, 0x5f, 0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x00, 0x00,
	0x04, 0x00, 0x09, 0x00, 0x47, 0x4c, 0x5f, 0x41, 0x52, 0x42, 0x5f, 0x73,
	0x68, 0x61, 0x64, 0x69, 0x6e, 0x67, 0x5f, 0x6c, 0x61, 0x6e, 0x67, 0x75,
	0x61, 0x67, 0x65, 0x5f, 0x34, 0x32, 0x30, 0x70, 0x61, 0x63, 0x6b, 0x00,
	0x05, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00, 0x00, 0x6d, 0x61, 0x69, 0x6e,
	0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x05, 0x00, 0x09, 0x00, 0x00, 0x00,
	0x74, 0x65, 0x78, 0x63, 0x6f, 0x6f, 0x72, 0x64, 0x00, 0x00, 0x00, 0x00,
	0x05, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x61, 0x74, 0x74, 0x72,
	0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x06, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x67, 0x6c, 0x5f, 0x50, 0x65, 0x72, 0x56, 0x65, 0x72, 0x74, 0x65, 0x78,
	0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x06, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x73, 0x69, 0x74,
	0x69, 0x6f, 0x6e, 0x00, 0x06, 0x00, 0x07, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x50, 0x6f, 0x69, 0x6e, 0x74,
	0x53, 0x69, 0x7a, 0x65, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x07, 0x00,
	0x11, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x43,
	0x6c, 0x69, 0x70, 0x44, 0x69, 0x73, 0x74, 0x61, 0x6e, 0x63, 0x65, 0x00,
	0x05, 0x00, 0x03, 0x00, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x05, 0x00, 0x03, 0x00, 0x17, 0x00, 0x00, 0x00, 0x70, 0x6f, 0x73, 0x00,
	0x05, 0x00, 0x05, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x56,
	0x65, 0x72, 0x74, 0x65, 0x78, 0x49, 0x44, 0x00, 0x05, 0x00, 0x06, 0x00,
	0x1d, 0x00, 0x00, 0x00, 0x67, 0x6c, 0x5f, 0x49, 0x6e, 0x73, 0x74, 0x61,
	0x6e, 0x63, 0x65, 0x49, 0x44, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00,
	0x09, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x47, 0x00, 0x04, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x1e, 0x00, 0x00, 0x00,
	0x01, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x48, 0x00, 0x05, 0x00, 0x11, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x0b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x48, 0x00, 0x05, 0x00,
	0x11, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00,
	0x03, 0x00, 0x00, 0x00, 0x47, 0x00, 0x03, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00, 0x17, 0x00, 0x00, 0x00,
	0x1e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47, 0x00, 0x04, 0x00,
	0x1c, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
	0x47, 0x00, 0x04, 0x00, 0x1d, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00,
	0x06, 0x00, 0x00, 0x00, 0x13, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00,
	0x21, 0x00, 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
	0x16, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
	0x17, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00,
	0x02, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00,
	0x03, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00,
	0x08, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
	0x20, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x07, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x0a, 0x00, 0x00, 0x00,
	0x0b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x17, 0x00, 0x04, 0x00,
	0x0d, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
	0x15, 0x00, 0x04, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x04, 0x00, 0x0e, 0x00, 0x00, 0x00,
	0x0f, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x04, 0x00,
	0x10, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00,
	0x1e, 0x00, 0x05, 0x00, 0x11, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00,
	0x06, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00,
	0x12, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x00,
	0x3b, 0x00, 0x04, 0x00, 0x12, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00,
	0x03, 0x00, 0x00, 0x00, 0x15, 0x00, 0x04, 0x00, 0x14, 0x00, 0x00, 0x00,
	0x20, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x2b, 0x00, 0x04, 0x00,
	0x14, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x20, 0x00, 0x04, 0x00, 0x16, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x0d, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x16, 0x00, 0x00, 0x00,
	0x17, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x20, 0x00, 0x04, 0x00,
	0x19, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00,
	0x20, 0x00, 0x04, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x14, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00, 0x1b, 0x00, 0x00, 0x00,
	0x1c, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x3b, 0x00, 0x04, 0x00,
	0x1b, 0x00, 0x00, 0x00, 0x1d, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
	0x36, 0x00, 0x05, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xf8, 0x00, 0x02, 0x00,
	0x05, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00, 0x07, 0x00, 0x00, 0x00,
	0x0c, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00,
	0x09, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x3d, 0x00, 0x04, 0x00,
	0x0d, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00, 0x00,
	0x41, 0x00, 0x05, 0x00, 0x19, 0x00, 0x00, 0x00, 0x1a, 0x00, 0x00, 0x00,
	0x13, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x03, 0x00,
	0x1a, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0xfd, 0x00, 0x01, 0x00,
	0x38, 0x00, 0x01, 0x00
];

struct texture_object {
	VkSampler sampler;

	VkImage image;
	VkImageLayout imageLayout;

	VkDeviceMemory mem;
	VkImageView view;
	int tex_width, tex_height;
}

private int validation_error = 0;

extern(System) VkBool32 BreakCallback(
	VkFlags msgFlags, VkDebugReportObjectTypeEXT objType, ulong srcObject, size_t location, int msgCode,
	const(char)* pLayerPrefix, const(char)* pMsg, void* pUserData
) {
	version (Windows) {
		DebugBreak();
	} else {
		raise(SIGTRAP);
	}
	return false;
}

struct SwapchainBuffers {
	VkImage image;
	VkCommandBuffer cmd;
	VkImageView view;
}

struct Demo {
	GLFWwindow* window;
	VkSurfaceKHR surface;
	bool use_staging_buffer;

	VkInstance inst;
	VkPhysicalDevice gpu;
	VkDevice device;
	VkQueue queue;
	VkPhysicalDeviceProperties gpu_props;
	VkPhysicalDeviceFeatures gpu_features;
	VkQueueFamilyProperties* queue_props;
	uint graphics_queue_node_index;

	uint enabled_extension_count;
	uint enabled_layer_count;
	const(char)*[64] extension_names;
	const(char)*[64] enabled_layers;

	int width;int height;
	VkFormat format;
	VkColorSpaceKHR color_space;

	uint swapchainImageCount;
	VkSwapchainKHR swapchain;
	SwapchainBuffers* buffers;

	VkCommandPool cmd_pool;

	struct _Depth {
		VkFormat format;

		VkImage image;
		VkDeviceMemory mem;
		VkImageView view;
	}_Depth depth;

	texture_object[DEMO_TEXTURE_COUNT] textures;

	struct _Vertices {
		VkBuffer buf;
		VkDeviceMemory mem;

		VkPipelineVertexInputStateCreateInfo vi;
		VkVertexInputBindingDescription[1] vi_bindings;
		VkVertexInputAttributeDescription[2] vi_attrs;
	}_Vertices vertices;

	VkCommandBuffer setup_cmd; // Command Buffer for initialization commands
	VkCommandBuffer draw_cmd;  // Command Buffer for drawing commands
	VkPipelineLayout pipeline_layout;
	VkDescriptorSetLayout desc_layout;
	VkPipelineCache pipelineCache;
	VkRenderPass render_pass;
	VkPipeline pipeline;

	VkShaderModule vert_shader_module;
	VkShaderModule frag_shader_module;

	VkDescriptorPool desc_pool;
	VkDescriptorSet desc_set;

	VkFramebuffer* framebuffers;

	VkPhysicalDeviceMemoryProperties memory_properties;

	int curFrame;
	int frameCount;
	bool validate;
	bool use_break;
	VkDebugReportCallbackEXT msg_callback;

	float depthStencil;
	float depthIncrement;

	uint current_buffer;
	uint queue_count;
}

extern(System) VkBool32 dbgFunc(
	VkFlags msgFlags, VkDebugReportObjectTypeEXT objType, ulong srcObject, size_t location, int msgCode,
	const(char)* pLayerPrefix, const(char)* pMsg, void* pUserData
) {
	char* message = cast(char*)malloc(strlen(pMsg) + 100);

	assert(message);

	validation_error = 1;

	if (msgFlags & VK_DEBUG_REPORT_ERROR_BIT_EXT) {
		sprintf(message, "ERROR: [%s] Code %d : %s", pLayerPrefix, msgCode,
			pMsg);
	} else if (msgFlags & VK_DEBUG_REPORT_WARNING_BIT_EXT) {
		sprintf(message, "WARNING: [%s] Code %d : %s", pLayerPrefix, msgCode,
			pMsg);
	} else {
		return false;
	}

	printf("%s\n", message);
	fflush(stdout);
	free(message);

	/*
	* false indicates that layer should not bail-out of an
	* API call that had validation failures. This may mean that the
	* app dies inside the driver due to invalid parameter(s).
	* That's what would happen without validation layers, so we'll
	* keep that behavior here.
	*/
	return false;
}

// Forward declaration:
private void demo_resize(Demo* demo);

private bool memory_type_from_properties(Demo* demo, uint typeBits, VkFlags requirements_mask, uint* typeIndex) {
	uint i;
	// Search memtypes to find first index with those properties
	for (i = 0; i < VK_MAX_MEMORY_TYPES; i++) {
		if ((typeBits & 1) == 1) {
			// Type is available, does it match user properties?
			if ((demo.memory_properties.memoryTypes[i].propertyFlags &
				 requirements_mask) == requirements_mask) {
				*typeIndex = i;
				return true;
			}
		}
		typeBits >>= 1;
	}
	// No memory types matched, return failure
	return false;
}

private void demo_flush_init_cmd(Demo* demo) {
	VkResult err;

	if (demo.setup_cmd == VK_NULL_HANDLE)
		return;

	err = vkEndCommandBuffer(demo.setup_cmd);
	assert(!err);

	const(VkCommandBuffer)[1] cmd_bufs = [demo.setup_cmd];
	//VkFence_handle[1] _handleArray = [VK_NULL_HANDLE];
	//ubyte[8] _handleArrayBytes = 0;
	//VkFence nullFence = cast(VkFence_handle) (_handleArrayBytes.ptr);
	VkSubmitInfo submit_info = {sType: VK_STRUCTURE_TYPE_SUBMIT_INFO,
								pNext: null,
								waitSemaphoreCount: 0,
								pWaitSemaphores: null,
								pWaitDstStageMask: null,
								commandBufferCount: cmd_bufs.length,
								pCommandBuffers: cmd_bufs.ptr,
								signalSemaphoreCount: 0,
								pSignalSemaphores: null};

	err = vkQueueSubmit(demo.queue, 1, &submit_info, VK_NULL_ND_HANDLE);
	assert(!err);

	err = vkQueueWaitIdle(demo.queue);
	assert(!err);

	vkFreeCommandBuffers(demo.device, demo.cmd_pool, cmd_bufs.length, cmd_bufs.ptr);
	demo.setup_cmd = VK_NULL_HANDLE;
}

private void demo_set_image_layout(
	Demo* demo, VkImage image, VkImageAspectFlags aspectMask, VkImageLayout old_image_layout,
	VkImageLayout new_image_layout, VkAccessFlagBits srcAccessMask
) {
	VkResult err;

	if (demo.setup_cmd == VK_NULL_HANDLE) {
		const(VkCommandBufferAllocateInfo) cmd = {
			sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
			pNext: null,
			commandPool: demo.cmd_pool,
			level: VK_COMMAND_BUFFER_LEVEL_PRIMARY,
			commandBufferCount: 1,
		};

		err = vkAllocateCommandBuffers(demo.device, &cmd, &demo.setup_cmd);
		assert(!err);

		VkCommandBufferBeginInfo cmd_buf_info = {
			sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
			pNext: null,
			flags: 0,
			pInheritanceInfo: null,
		};
		err = vkBeginCommandBuffer(demo.setup_cmd, &cmd_buf_info);
		assert(!err);
	}

	VkImageMemoryBarrier image_memory_barrier = {
		sType: VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
		pNext: null,
		srcAccessMask: srcAccessMask,
		dstAccessMask: 0,
		oldLayout: old_image_layout,
		newLayout: new_image_layout,
		image: image,
		subresourceRange: {aspectMask, 0, 1, 0, 1}
	};

	if (new_image_layout == VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL) {
		/* Make sure anything that was copying from this image has completed */
		image_memory_barrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
	}

	if (new_image_layout == VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL) {
		image_memory_barrier.dstAccessMask =
			VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
	}

	if (new_image_layout == VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL) {
		image_memory_barrier.dstAccessMask =
			VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
	}

	if (new_image_layout == VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL) {
		/* Make sure any Copy or CPU writes to image are flushed */
		image_memory_barrier.dstAccessMask =
			VK_ACCESS_SHADER_READ_BIT | VK_ACCESS_INPUT_ATTACHMENT_READ_BIT;
	}

	VkImageMemoryBarrier* pmemory_barrier = &image_memory_barrier;

	VkPipelineStageFlags src_stages = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
	VkPipelineStageFlags dest_stages = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;

	vkCmdPipelineBarrier(demo.setup_cmd, src_stages, dest_stages, 0, 0, null,
						 0, null, 1, pmemory_barrier);
}

private void demo_draw_build_cmd(Demo* demo) {
	const(VkCommandBufferBeginInfo) cmd_buf_info = {
		sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
		pNext: null,
		flags: 0,
		pInheritanceInfo: null,
	};
	VkClearColorValue colorValue;
	colorValue.float32 = [0.2f, 0.2f, 0.2f, 0.2f];
	VkClearValue clearValueColor;
	clearValueColor.color = colorValue;
	const(VkClearValue)[2] clear_values = [
		clearValueColor,
		{depthStencil: {demo.depthStencil, 0}},
	];
	const(VkRenderPassBeginInfo) rp_begin = {
		sType: VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
		pNext: null,
		renderPass: demo.render_pass,
		framebuffer: demo.framebuffers[demo.current_buffer],
		renderArea: {offset: {x: 0, y: 0}, extent: {width: demo.width, height: demo.height}},
		clearValueCount: 2,
		pClearValues: clear_values.ptr,
	};
	VkResult err;

	err = vkBeginCommandBuffer(demo.draw_cmd, &cmd_buf_info);
	assert(!err);

	// We can use LAYOUT_UNDEFINED as a wildcard here because we don't care what
	// happens to the previous contents of the image
	VkImageMemoryBarrier image_memory_barrier = {
		sType: VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
		pNext: null,
		srcAccessMask: 0,
		dstAccessMask: VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
		oldLayout: VK_IMAGE_LAYOUT_UNDEFINED,
		newLayout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
		srcQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED,
		dstQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED,
		image: demo.buffers[demo.current_buffer].image,
		subresourceRange: {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1}
	};

	vkCmdPipelineBarrier(demo.draw_cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
						 VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, 0, 0, null, 0,
						 null, 1, &image_memory_barrier);
	vkCmdBeginRenderPass(demo.draw_cmd, &rp_begin, VK_SUBPASS_CONTENTS_INLINE);
	vkCmdBindPipeline(demo.draw_cmd, VK_PIPELINE_BIND_POINT_GRAPHICS,
					  demo.pipeline);
	vkCmdBindDescriptorSets(demo.draw_cmd, VK_PIPELINE_BIND_POINT_GRAPHICS,
							demo.pipeline_layout, 0, 1, &demo.desc_set, 0,
							null);

	VkViewport viewport;
	memset(&viewport, 0, viewport.sizeof);
	viewport.height = cast(float)demo.height;
	viewport.width = cast(float)demo.width;
	viewport.minDepth = cast(float)0.0f;
	viewport.maxDepth = cast(float)1.0f;
	vkCmdSetViewport(demo.draw_cmd, 0, 1, &viewport);

	VkRect2D scissor;
	memset(&scissor, 0, scissor.sizeof);
	scissor.extent.width = demo.width;
	scissor.extent.height = demo.height;
	scissor.offset.x = 0;
	scissor.offset.y = 0;
	vkCmdSetScissor(demo.draw_cmd, 0, 1, &scissor);

	VkDeviceSize[1] offsets = [0];
	vkCmdBindVertexBuffers(demo.draw_cmd, VERTEX_BUFFER_BIND_ID, 1,
						   &demo.vertices.buf, offsets.ptr);

	vkCmdDraw(demo.draw_cmd, 3, 1, 0, 0);
	vkCmdEndRenderPass(demo.draw_cmd);

	VkImageMemoryBarrier prePresentBarrier = {
		sType: VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
		pNext: null,
		srcAccessMask: VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
		dstAccessMask: VK_ACCESS_MEMORY_READ_BIT,
		oldLayout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
		newLayout: VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
		srcQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED,
		dstQueueFamilyIndex: VK_QUEUE_FAMILY_IGNORED,
		subresourceRange: {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1}
	};

	prePresentBarrier.image = demo.buffers[demo.current_buffer].image;
	VkImageMemoryBarrier* pmemory_barrier = &prePresentBarrier;
	vkCmdPipelineBarrier(demo.draw_cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT,
						 VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, 0, 0, null, 0,
						 null, 1, pmemory_barrier);

	err = vkEndCommandBuffer(demo.draw_cmd);
	assert(!err);
}

private void demo_draw(Demo* demo) {
	VkResult err;
	VkSemaphore imageAcquiredSemaphore;VkSemaphore drawCompleteSemaphore;
	VkSemaphoreCreateInfo semaphoreCreateInfo = {
		sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
		pNext: null,
		flags: 0,
	};

	err = vkCreateSemaphore(demo.device, &semaphoreCreateInfo,
							null, &imageAcquiredSemaphore);
	assert(!err);

	err = vkCreateSemaphore(demo.device, &semaphoreCreateInfo,
							null, &drawCompleteSemaphore);
	assert(!err);

	// Get the index of the next available swapchain image:
	err = vkAcquireNextImageKHR(demo.device, demo.swapchain, ulong.max,
								imageAcquiredSemaphore,
								cast(VkFence)0, // TODO: Show use of fence
								&demo.current_buffer);
	if (err == VK_ERROR_OUT_OF_DATE_KHR) {
		// demo->swapchain is out of date (e.g. the window was resized) and
		// must be recreated:
		demo_resize(demo);
		demo_draw(demo);
		vkDestroySemaphore(demo.device, imageAcquiredSemaphore, null);
		vkDestroySemaphore(demo.device, drawCompleteSemaphore, null);
		return;
	} else if (err == VK_SUBOPTIMAL_KHR) {
		// demo->swapchain is not as optimal as it could be, but the platform's
		// presentation engine will still present the image correctly.
	} else {
		assert(!err);
	}

	demo_flush_init_cmd(demo);

	// Wait for the present complete semaphore to be signaled to ensure
	// that the image won't be rendered to until the presentation
	// engine has fully released ownership to the application, and it is
	// okay to render to the image.

	demo_draw_build_cmd(demo);
	VkFence nullFence = VK_NULL_ND_HANDLE;
	VkPipelineStageFlags pipe_stage_flags = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
	VkSubmitInfo submit_info = {sType: VK_STRUCTURE_TYPE_SUBMIT_INFO,
								pNext: null,
								waitSemaphoreCount: 1,
								pWaitSemaphores: &imageAcquiredSemaphore,
								pWaitDstStageMask: &pipe_stage_flags,
								commandBufferCount: 1,
								pCommandBuffers: &demo.draw_cmd,
								signalSemaphoreCount: 1,
								pSignalSemaphores: &drawCompleteSemaphore};

	err = vkQueueSubmit(demo.queue, 1, &submit_info, nullFence);
	assert(!err);

	VkPresentInfoKHR present = {
		sType: VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
		pNext: null,
		waitSemaphoreCount: 1,
		pWaitSemaphores: &drawCompleteSemaphore,
		swapchainCount: 1,
		pSwapchains: &demo.swapchain,
		pImageIndices: &demo.current_buffer,
	};

	err = vkQueuePresentKHR(demo.queue, &present);
	if (err == VK_ERROR_OUT_OF_DATE_KHR) {
		// demo->swapchain is out of date (e.g. the window was resized) and
		// must be recreated:
		demo_resize(demo);
	} else if (err == VK_SUBOPTIMAL_KHR) {
		// demo->swapchain is not as optimal as it could be, but the platform's
		// presentation engine will still present the image correctly.
	} else {
		assert(!err);
	}

	err = vkQueueWaitIdle(demo.queue);
	assert(err == VK_SUCCESS);

	vkDestroySemaphore(demo.device, imageAcquiredSemaphore, null);
	vkDestroySemaphore(demo.device, drawCompleteSemaphore, null);
}

private void demo_prepare_buffers(Demo* demo) {
	VkResult err;
	VkSwapchainKHR oldSwapchain = demo.swapchain;

	// Check the surface capabilities and formats
	VkSurfaceCapabilitiesKHR surfCapabilities;
	err = vkGetPhysicalDeviceSurfaceCapabilitiesKHR(
		demo.gpu, demo.surface, &surfCapabilities);
	assert(!err);

	uint presentModeCount;
	err = vkGetPhysicalDeviceSurfacePresentModesKHR(
		demo.gpu, demo.surface, &presentModeCount, null);
	assert(!err);
	VkPresentModeKHR* presentModes = cast(VkPresentModeKHR*)malloc(presentModeCount * VkPresentModeKHR.sizeof);
	assert(presentModes);
	err = vkGetPhysicalDeviceSurfacePresentModesKHR(
		demo.gpu, demo.surface, &presentModeCount, presentModes);
	assert(!err);

	VkExtent2D swapchainExtent;
	// width and height are either both 0xFFFFFFFF, or both not 0xFFFFFFFF.
	if (surfCapabilities.currentExtent.width == 0xFFFFFFFF) {
		// If the surface size is undefined, the size is set to the size
		// of the images requested, which must fit within the minimum and
		// maximum values.
		swapchainExtent.width = demo.width;
		swapchainExtent.height = demo.height;

		if (swapchainExtent.width < surfCapabilities.minImageExtent.width) {
			swapchainExtent.width = surfCapabilities.minImageExtent.width;
		} else if (swapchainExtent.width > surfCapabilities.maxImageExtent.width) {
			swapchainExtent.width = surfCapabilities.maxImageExtent.width;
		}

		if (swapchainExtent.height < surfCapabilities.minImageExtent.height) {
			swapchainExtent.height = surfCapabilities.minImageExtent.height;
		} else if (swapchainExtent.height > surfCapabilities.maxImageExtent.height) {
			swapchainExtent.height = surfCapabilities.maxImageExtent.height;
		}
	} else {
		// If the surface size is defined, the swap chain size must match
		swapchainExtent = surfCapabilities.currentExtent;
		demo.width = surfCapabilities.currentExtent.width;
		demo.height = surfCapabilities.currentExtent.height;
	}

	VkPresentModeKHR swapchainPresentMode = VK_PRESENT_MODE_FIFO_KHR;

	// Determine the number of VkImage's to use in the swap chain.
	// Application desires to only acquire 1 image at a time (which is
	// "surfCapabilities.minImageCount").
	uint desiredNumOfSwapchainImages = surfCapabilities.minImageCount;
	// If maxImageCount is 0, we can ask for as many images as we want;
	// otherwise we're limited to maxImageCount
	if ((surfCapabilities.maxImageCount > 0) &&
		(desiredNumOfSwapchainImages > surfCapabilities.maxImageCount)) {
		// Application must settle for fewer images than desired:
		desiredNumOfSwapchainImages = surfCapabilities.maxImageCount;
	}

	VkSurfaceTransformFlagsKHR preTransform;
	if (surfCapabilities.supportedTransforms &
		VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR) {
		preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
	} else {
		preTransform = surfCapabilities.currentTransform;
	}

	const(VkSwapchainCreateInfoKHR) swapchain = {
		sType: VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
		pNext: null,
		surface: demo.surface,
		minImageCount: desiredNumOfSwapchainImages,
		imageFormat: demo.format,
		imageColorSpace: demo.color_space,
		imageExtent: {width: swapchainExtent.width, height: swapchainExtent.height},
		imageUsage: VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
		preTransform: cast(VkSurfaceTransformFlagBitsKHR) preTransform,
		compositeAlpha: VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
		imageArrayLayers: 1,
		imageSharingMode: VK_SHARING_MODE_EXCLUSIVE,
		queueFamilyIndexCount: 0,
		pQueueFamilyIndices: null,
		presentMode: swapchainPresentMode,
		oldSwapchain: oldSwapchain,
		clipped: true,
	};
	uint i;

	err = vkCreateSwapchainKHR(demo.device, &swapchain, null, &demo.swapchain);
	assert(!err);

	// If we just re-created an existing swapchain, we should destroy the old
	// swapchain at this point.
	// Note: destroying the swapchain also cleans up all its associated
	// presentable images once the platform is done with them.
	if (oldSwapchain != VK_NULL_ND_HANDLE) {
		vkDestroySwapchainKHR(demo.device, oldSwapchain, null);
	}

	err = vkGetSwapchainImagesKHR(demo.device, demo.swapchain,
										&demo.swapchainImageCount, null);
	assert(!err);

	VkImage* swapchainImages = cast(VkImage*)malloc(demo.swapchainImageCount * VkImage.sizeof);
	assert(swapchainImages);
	err = vkGetSwapchainImagesKHR(demo.device, demo.swapchain,
								  &demo.swapchainImageCount,
								  swapchainImages);
	assert(!err);

	demo.buffers = cast(SwapchainBuffers*) malloc(SwapchainBuffers.sizeof * demo.swapchainImageCount);
	assert(demo.buffers);

	for (i = 0; i < demo.swapchainImageCount; i++) {
		VkImageViewCreateInfo color_attachment_view = {
			sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
			pNext: null,
			format: demo.format,
			components:
				{
				 r: VK_COMPONENT_SWIZZLE_R,
				 g: VK_COMPONENT_SWIZZLE_G,
				 b: VK_COMPONENT_SWIZZLE_B,
				 a: VK_COMPONENT_SWIZZLE_A,
				},
			subresourceRange: {
				aspectMask: VK_IMAGE_ASPECT_COLOR_BIT,
				baseMipLevel: 0,
				levelCount: 1,
				baseArrayLayer: 0,
				layerCount: 1
			},
			viewType: VK_IMAGE_VIEW_TYPE_2D,
			flags: 0,
		};

		demo.buffers[i].image = swapchainImages[i];

		color_attachment_view.image = demo.buffers[i].image;

		err = vkCreateImageView(demo.device, &color_attachment_view, null,
								&demo.buffers[i].view);
		assert(!err);
	}

	demo.current_buffer = 0;

	if (null != presentModes) {
		free(presentModes);
	}
}

private void demo_prepare_depth(Demo* demo) {
	const(VkFormat) depth_format = VK_FORMAT_D16_UNORM;
	const(VkImageCreateInfo) image = {
		sType: VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
		pNext: null,
		imageType: VK_IMAGE_TYPE_2D,
		format: depth_format,
		extent: {demo.width, demo.height, 1},
		mipLevels: 1,
		arrayLayers: 1,
		samples: VK_SAMPLE_COUNT_1_BIT,
		tiling: VK_IMAGE_TILING_OPTIMAL,
		usage: VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
		flags: 0,
	};
	VkMemoryAllocateInfo mem_alloc = {
		sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		pNext: null,
		allocationSize: 0,
		memoryTypeIndex: 0,
	};
	VkImageViewCreateInfo view = {
		sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
		pNext: null,
		image: VK_NULL_ND_HANDLE,
		format: depth_format,
		subresourceRange: {
			aspectMask: VK_IMAGE_ASPECT_DEPTH_BIT,
			baseMipLevel: 0,
			levelCount: 1,
			baseArrayLayer: 0,
			layerCount: 1
		},
		flags: 0,
		viewType: VK_IMAGE_VIEW_TYPE_2D,
	};

	VkMemoryRequirements mem_reqs;
	VkResult err;
	bool pass;

	demo.depth.format = depth_format;

	/* create image */
	err = vkCreateImage(demo.device, &image, null, &demo.depth.image);
	assert(!err);

	/* get memory requirements for this object */
	vkGetImageMemoryRequirements(demo.device, demo.depth.image, &mem_reqs);

	/* select memory size and type */
	mem_alloc.allocationSize = mem_reqs.size;
	pass = memory_type_from_properties(demo, mem_reqs.memoryTypeBits,
									   0, /* No requirements */
									   &mem_alloc.memoryTypeIndex);
	assert(pass);

	/* allocate memory */
	err = vkAllocateMemory(demo.device, &mem_alloc, null, &demo.depth.mem);
	assert(!err);

	/* bind memory */
	err =
		vkBindImageMemory(demo.device, demo.depth.image, demo.depth.mem, 0);
	assert(!err);

	demo_set_image_layout(demo, demo.depth.image, VK_IMAGE_ASPECT_DEPTH_BIT,
						  VK_IMAGE_LAYOUT_UNDEFINED,
						  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
						 cast(VkAccessFlagBits) 0);

	/* create image view */
	view.image = demo.depth.image;
	err = vkCreateImageView(demo.device, &view, null, &demo.depth.view);
	assert(!err);
}

private void demo_prepare_texture_image(
	Demo* demo, const(uint)* tex_colors, texture_object* tex_obj,
	VkImageTiling tiling, VkImageUsageFlags usage, VkFlags required_props
) {
	const(VkFormat) tex_format = VK_FORMAT_B8G8R8A8_UNORM;
	const(int) tex_width = 2;
	const(int) tex_height = 2;
	VkResult err;
	bool pass;

	tex_obj.tex_width = tex_width;
	tex_obj.tex_height = tex_height;

	const(VkImageCreateInfo) image_create_info = {
		sType: VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
		pNext: null,
		imageType: VK_IMAGE_TYPE_2D,
		format: tex_format,
		extent: {tex_width, tex_height, 1},
		mipLevels: 1,
		arrayLayers: 1,
		samples: VK_SAMPLE_COUNT_1_BIT,
		tiling: tiling,
		usage: usage,
		flags: 0,
		initialLayout: VK_IMAGE_LAYOUT_PREINITIALIZED
	};
	VkMemoryAllocateInfo mem_alloc = {
		sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		pNext: null,
		allocationSize: 0,
		memoryTypeIndex: 0,
    };

	VkMemoryRequirements mem_reqs;

	err = vkCreateImage(demo.device, &image_create_info, null, &tex_obj.image);
	assert(!err);

	vkGetImageMemoryRequirements(demo.device, tex_obj.image, &mem_reqs);

	mem_alloc.allocationSize = mem_reqs.size;
	pass = memory_type_from_properties(demo, mem_reqs.memoryTypeBits,
									required_props, &mem_alloc.memoryTypeIndex);
	assert(pass);

	/* allocate memory */
	err = vkAllocateMemory(demo.device, &mem_alloc, null, &tex_obj.mem);
	assert(!err);

	/* bind memory */
	err = vkBindImageMemory(demo.device, tex_obj.image, tex_obj.mem, 0);
	assert(!err);

	if (required_props & VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT) {
		const(VkImageSubresource) subres = {
			aspectMask: VK_IMAGE_ASPECT_COLOR_BIT,
			mipLevel: 0,
			arrayLayer: 0,
        };
		VkSubresourceLayout layout;
		void* data;
		int x;int y;

		vkGetImageSubresourceLayout(demo.device, tex_obj.image, &subres,
									&layout);

		err = vkMapMemory(demo.device, tex_obj.mem, 0,
						  mem_alloc.allocationSize, 0, &data);
		assert(!err);

		for (y = 0; y < tex_height; y++) {
			uint* row = cast(uint*)(cast(char*)data + layout.rowPitch * y);
			for (x = 0; x < tex_width; x++)
				row[x] = tex_colors[(x & 1) ^ (y & 1)];
		}

		vkUnmapMemory(demo.device, tex_obj.mem);
	}

	tex_obj.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
	demo_set_image_layout(demo, tex_obj.image, VK_IMAGE_ASPECT_COLOR_BIT,
						  VK_IMAGE_LAYOUT_PREINITIALIZED, tex_obj.imageLayout,
						  VK_ACCESS_HOST_WRITE_BIT);
	/* setting the image layout does not reference the actual memory so no need
	 * to add a mem ref */
}

private void demo_destroy_texture_image(Demo* demo, texture_object* tex_obj) {
	/* clean up staging resources */
	vkDestroyImage(demo.device, tex_obj.image, null);
	vkFreeMemory(demo.device, tex_obj.mem, null);
}

private void demo_prepare_textures(Demo* demo) {
	const(VkFormat) tex_format = VK_FORMAT_B8G8R8A8_UNORM;
	VkFormatProperties props;
	const(uint)[2][DEMO_TEXTURE_COUNT] tex_colors = [
		[0xffff0000, 0xff00ff00],
	];
	uint i;
	VkResult err;

	vkGetPhysicalDeviceFormatProperties(demo.gpu, tex_format, &props);

	for (i = 0; i < DEMO_TEXTURE_COUNT; i++) {
		if ((props.linearTilingFeatures &
			 VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) &&
			!demo.use_staging_buffer) {
			/* Device can texture using linear textures */
			demo_prepare_texture_image(
				demo, tex_colors[i].ptr, &demo.textures[i], VK_IMAGE_TILING_LINEAR,
				VK_IMAGE_USAGE_SAMPLED_BIT,
				VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
					VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
		} else if (props.optimalTilingFeatures &
				   VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT) {
			/* Must use staging buffer to copy linear texture to optimized */
			texture_object staging_texture;

			memset(&staging_texture, 0, staging_texture.sizeof);
			demo_prepare_texture_image(
				demo, tex_colors[i].ptr, &staging_texture, VK_IMAGE_TILING_LINEAR,
				VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
				VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
					VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);

			demo_prepare_texture_image(
				demo, tex_colors[i].ptr, &demo.textures[i],
				VK_IMAGE_TILING_OPTIMAL,
				(VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_SAMPLED_BIT),
				VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);

			demo_set_image_layout(demo, staging_texture.image,
								  VK_IMAGE_ASPECT_COLOR_BIT,
								  staging_texture.imageLayout,
								  VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
								  cast(VkAccessFlagBits) 0);

			demo_set_image_layout(demo, demo.textures[i].image,
								  VK_IMAGE_ASPECT_COLOR_BIT,
								  demo.textures[i].imageLayout,
								  VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
								  cast(VkAccessFlagBits) 0);

			VkImageCopy copy_region = {
				srcSubresource: {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
				srcOffset: {0, 0, 0},
				dstSubresource: {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
				dstOffset: {0, 0, 0},
				extent: {staging_texture.tex_width, staging_texture.tex_height, 1},
			};
			vkCmdCopyImage(
				demo.setup_cmd, staging_texture.image,
				VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, demo.textures[i].image,
				VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &copy_region);

			demo_set_image_layout(demo, demo.textures[i].image,
								  VK_IMAGE_ASPECT_COLOR_BIT,
								  VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
								  demo.textures[i].imageLayout,
								  cast(VkAccessFlagBits) 0);

			demo_flush_init_cmd(demo);

			demo_destroy_texture_image(demo, &staging_texture);
		} else {
			/* Can't support VK_FORMAT_B8G8R8A8_UNORM !? */
			assert(!"No support for B8G8R8A8_UNORM as texture image format");
		}

		const(VkSamplerCreateInfo) sampler = {
			sType: VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
			pNext: null,
			magFilter: VK_FILTER_NEAREST,
			minFilter: VK_FILTER_NEAREST,
			mipmapMode: VK_SAMPLER_MIPMAP_MODE_NEAREST,
			addressModeU: VK_SAMPLER_ADDRESS_MODE_REPEAT,
			addressModeV: VK_SAMPLER_ADDRESS_MODE_REPEAT,
			addressModeW: VK_SAMPLER_ADDRESS_MODE_REPEAT,
			mipLodBias: 0.0f,
			anisotropyEnable: VK_FALSE,
			maxAnisotropy: 1,
			compareOp: VK_COMPARE_OP_NEVER,
			minLod: 0.0f,
			maxLod: 0.0f,
			borderColor: VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE,
			unnormalizedCoordinates: VK_FALSE,
        };
		VkImageViewCreateInfo view = {
			sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
			pNext: null,
			image: VK_NULL_ND_HANDLE,
			viewType: VK_IMAGE_VIEW_TYPE_2D,
			format: tex_format,
			components:
            {
				 VK_COMPONENT_SWIZZLE_R, VK_COMPONENT_SWIZZLE_G,
				 VK_COMPONENT_SWIZZLE_B, VK_COMPONENT_SWIZZLE_A,
            },
			subresourceRange: {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1},
			flags: 0,
        };

		/* create sampler */
		err = vkCreateSampler(demo.device, &sampler, null,
							  &demo.textures[i].sampler);
		assert(!err);

		/* create image view */
		view.image = demo.textures[i].image;
		err = vkCreateImageView(demo.device, &view, null,
								&demo.textures[i].view);
		assert(!err);
	}
}

private void demo_prepare_vertices(Demo* demo) {
	// clang-format off
	const(float)[5][3] vb = [
		/*      position             texcoord */
		[ -1.0f, -1.0f,  0.25f,     0.0f, 0.0f ],
		[  1.0f, -1.0f,  0.25f,     1.0f, 0.0f ],
		[  0.0f,  1.0f,  1.0f,      0.5f, 1.0f ],
	];
	// clang-format on
	const(VkBufferCreateInfo) buf_info = {
		sType: VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
		pNext: null,
		size: vb.sizeof,
		usage: VK_BUFFER_USAGE_VERTEX_BUFFER_BIT,
		flags: 0,
    };
	VkMemoryAllocateInfo mem_alloc = {
		sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
		pNext: null,
		allocationSize: 0,
		memoryTypeIndex: 0,
    };
	VkMemoryRequirements mem_reqs;
	VkResult err;
	bool pass; // U_ASSERT_ONLY
	void* data;

	memset(&demo.vertices, 0, typeof(demo.vertices).sizeof);

	err = vkCreateBuffer(demo.device, &buf_info, null, &demo.vertices.buf);
	assert(!err);

	vkGetBufferMemoryRequirements(demo.device, demo.vertices.buf, &mem_reqs);
	assert(!err);

	mem_alloc.allocationSize = mem_reqs.size;
	pass = memory_type_from_properties(demo, mem_reqs.memoryTypeBits,
									   VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT |
										   VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
									   &mem_alloc.memoryTypeIndex);
	assert(pass);

	err = vkAllocateMemory(demo.device, &mem_alloc, null, &demo.vertices.mem);
	assert(!err);

	err = vkMapMemory(demo.device, demo.vertices.mem, 0,
					  mem_alloc.allocationSize, 0, &data);
	assert(!err);

	memcpy(data, vb.ptr, vb.sizeof);

	vkUnmapMemory(demo.device, demo.vertices.mem);

	err = vkBindBufferMemory(demo.device, demo.vertices.buf,
							 demo.vertices.mem, 0);
	assert(!err);

	demo.vertices.vi.sType =
		VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
	demo.vertices.vi.pNext = null;
	demo.vertices.vi.vertexBindingDescriptionCount = 1;
	demo.vertices.vi.pVertexBindingDescriptions = demo.vertices.vi_bindings.ptr;
	demo.vertices.vi.vertexAttributeDescriptionCount = 2;
	demo.vertices.vi.pVertexAttributeDescriptions = demo.vertices.vi_attrs.ptr;

	demo.vertices.vi_bindings[0].binding = VERTEX_BUFFER_BIND_ID;
	demo.vertices.vi_bindings[0].stride = typeof(vb[0]).sizeof;
	demo.vertices.vi_bindings[0].inputRate = VK_VERTEX_INPUT_RATE_VERTEX;

	demo.vertices.vi_attrs[0].binding = VERTEX_BUFFER_BIND_ID;
	demo.vertices.vi_attrs[0].location = 0;
	demo.vertices.vi_attrs[0].format = VK_FORMAT_R32G32B32_SFLOAT;
	demo.vertices.vi_attrs[0].offset = 0;

	demo.vertices.vi_attrs[1].binding = VERTEX_BUFFER_BIND_ID;
	demo.vertices.vi_attrs[1].location = 1;
	demo.vertices.vi_attrs[1].format = VK_FORMAT_R32G32_SFLOAT;
	demo.vertices.vi_attrs[1].offset = float.sizeof * 3;
}
private void demo_prepare_descriptor_layout(Demo* demo) {
	const(VkDescriptorSetLayoutBinding) layout_binding = {
		binding: 0,
		descriptorType: VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
		descriptorCount: DEMO_TEXTURE_COUNT,
		stageFlags: VK_SHADER_STAGE_FRAGMENT_BIT,
		pImmutableSamplers: null,
    };
	const(VkDescriptorSetLayoutCreateInfo) descriptor_layout = {
		sType: VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
		pNext: null,
		bindingCount: 1,
		pBindings: &layout_binding,
    };
	VkResult err;

	err = vkCreateDescriptorSetLayout(demo.device, &descriptor_layout, null,
									  &demo.desc_layout);
	assert(!err);

	const(VkPipelineLayoutCreateInfo) pPipelineLayoutCreateInfo = {
		sType: VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
		pNext: null,
		setLayoutCount: 1,
		pSetLayouts: &demo.desc_layout,
    };

	err = vkCreatePipelineLayout(demo.device, &pPipelineLayoutCreateInfo, null,
								 &demo.pipeline_layout);
	assert(!err);
}

private void demo_prepare_render_pass(Demo* demo) {
	const(VkAttachmentDescription)[2] attachments = [
            {
				 format: demo.format,
				 samples: VK_SAMPLE_COUNT_1_BIT,
				 loadOp: VK_ATTACHMENT_LOAD_OP_CLEAR,
				 storeOp: VK_ATTACHMENT_STORE_OP_STORE,
				 stencilLoadOp: VK_ATTACHMENT_LOAD_OP_DONT_CARE,
				 stencilStoreOp: VK_ATTACHMENT_STORE_OP_DONT_CARE,
				 initialLayout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
				 finalLayout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
            },
            {
				format:  demo.depth.format,
				samples:  VK_SAMPLE_COUNT_1_BIT,
				loadOp:  VK_ATTACHMENT_LOAD_OP_CLEAR,
				storeOp:  VK_ATTACHMENT_STORE_OP_DONT_CARE,
				stencilLoadOp:  VK_ATTACHMENT_LOAD_OP_DONT_CARE,
				stencilStoreOp:  VK_ATTACHMENT_STORE_OP_DONT_CARE,
				initialLayout:  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
				finalLayout:  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
            },
	];
	const(VkAttachmentReference) color_reference = {
		attachment: 0,
		layout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
    };
	const(VkAttachmentReference) depth_reference = {
		attachment: 1,
		layout: VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    };
	const(VkSubpassDescription) subpass = {
		pipelineBindPoint: VK_PIPELINE_BIND_POINT_GRAPHICS,
		flags: 0,
		inputAttachmentCount: 0,
		pInputAttachments: null,
		colorAttachmentCount: 1,
		pColorAttachments: &color_reference,
		pResolveAttachments: null,
		pDepthStencilAttachment: &depth_reference,
		preserveAttachmentCount: 0,
		pPreserveAttachments: null,
    };
	const(VkRenderPassCreateInfo) rp_info = {
		sType: VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
		pNext: null,
		attachmentCount: 2,
		pAttachments: attachments.ptr,
		subpassCount: 1,
		pSubpasses: &subpass,
		dependencyCount: 0,
		pDependencies: null,
    };
	VkResult err;

	err = vkCreateRenderPass(demo.device, &rp_info, null, &demo.render_pass);
	assert(!err);
}

private VkShaderModule demo_prepare_shader_module(Demo* demo, const(ubyte)[] code) {
	VkShaderModuleCreateInfo moduleCreateInfo;
	VkShaderModule module_;
	VkResult err;

	moduleCreateInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
	moduleCreateInfo.pNext = null;

	moduleCreateInfo.codeSize = code.length;
	moduleCreateInfo.pCode = cast(const(uint)*) code.ptr;
	moduleCreateInfo.flags = 0;
	err = vkCreateShaderModule(demo.device, &moduleCreateInfo, null, &module_);
	assert(!err);

	return module_;
}

private VkShaderModule demo_prepare_vs(Demo* demo) {
	demo.vert_shader_module = demo_prepare_shader_module(demo, vertShaderCode[]);
	return demo.vert_shader_module;
}

private VkShaderModule demo_prepare_fs(Demo* demo) {
	demo.frag_shader_module = demo_prepare_shader_module(demo, fragShaderCode[]);
	return demo.frag_shader_module;
}

private void demo_prepare_pipeline(Demo* demo) {
	VkGraphicsPipelineCreateInfo pipeline;
	VkPipelineCacheCreateInfo pipelineCache;

	VkPipelineVertexInputStateCreateInfo vi;
	VkPipelineInputAssemblyStateCreateInfo ia;
	VkPipelineRasterizationStateCreateInfo rs;
	VkPipelineColorBlendStateCreateInfo cb;
	VkPipelineDepthStencilStateCreateInfo ds;
	VkPipelineViewportStateCreateInfo vp;
	VkPipelineMultisampleStateCreateInfo ms;
	VkDynamicState[VK_DYNAMIC_STATE_RANGE_SIZE] dynamicStateEnables;
	VkPipelineDynamicStateCreateInfo dynamicState;

	VkResult err;

	memset(dynamicStateEnables.ptr, 0, dynamicStateEnables.sizeof);
	memset(&dynamicState, 0, dynamicState.sizeof);
	dynamicState.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
	dynamicState.pDynamicStates = dynamicStateEnables.ptr;

	memset(&pipeline, 0, pipeline.sizeof);
	pipeline.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
	pipeline.layout = demo.pipeline_layout;

	vi = demo.vertices.vi;

	memset(&ia, 0, ia.sizeof);
	ia.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
	ia.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;

	memset(&rs, 0, rs.sizeof);
	rs.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
	rs.polygonMode = VK_POLYGON_MODE_FILL;
	rs.cullMode = VK_CULL_MODE_BACK_BIT;
	rs.frontFace = VK_FRONT_FACE_CLOCKWISE;
	rs.depthClampEnable = VK_FALSE;
	rs.rasterizerDiscardEnable = VK_FALSE;
	rs.depthBiasEnable = VK_FALSE;
	rs.lineWidth = 1.0f;

	memset(&cb, 0, cb.sizeof);
	cb.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
	VkPipelineColorBlendAttachmentState[1] att_state;
	memset(att_state.ptr, 0, att_state.sizeof);
	att_state[0].colorWriteMask = 0xf;
	att_state[0].blendEnable = VK_FALSE;
	cb.attachmentCount = 1;
	cb.pAttachments = att_state.ptr;

	memset(&vp, 0, vp.sizeof);
	vp.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
	vp.viewportCount = 1;
	dynamicStateEnables[dynamicState.dynamicStateCount++] =
		VK_DYNAMIC_STATE_VIEWPORT;
	vp.scissorCount = 1;
	dynamicStateEnables[dynamicState.dynamicStateCount++] =
		VK_DYNAMIC_STATE_SCISSOR;

	memset(&ds, 0, ds.sizeof);
	ds.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
	ds.depthTestEnable = VK_TRUE;
	ds.depthWriteEnable = VK_TRUE;
	ds.depthCompareOp = VK_COMPARE_OP_LESS_OR_EQUAL;
	ds.depthBoundsTestEnable = VK_FALSE;
	ds.back.failOp = VK_STENCIL_OP_KEEP;
	ds.back.passOp = VK_STENCIL_OP_KEEP;
	ds.back.compareOp = VK_COMPARE_OP_ALWAYS;
	ds.stencilTestEnable = VK_FALSE;
	ds.front = ds.back;

	memset(&ms, 0, ms.sizeof);
	ms.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
	ms.pSampleMask = null;
	ms.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;

	// Two stages: vs and fs
	pipeline.stageCount = 2;
	VkPipelineShaderStageCreateInfo[2] shaderStages;
	memset(&shaderStages, 0, 2 * VkPipelineShaderStageCreateInfo.sizeof);

	shaderStages[0].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
	shaderStages[0].stage = VK_SHADER_STAGE_VERTEX_BIT;
	shaderStages[0].module_ = demo_prepare_vs(demo);
	shaderStages[0].pName = "main";

	shaderStages[1].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
	shaderStages[1].stage = VK_SHADER_STAGE_FRAGMENT_BIT;
	shaderStages[1].module_ = demo_prepare_fs(demo);
	shaderStages[1].pName = "main";

	pipeline.pVertexInputState = &vi;
	pipeline.pInputAssemblyState = &ia;
	pipeline.pRasterizationState = &rs;
	pipeline.pColorBlendState = &cb;
	pipeline.pMultisampleState = &ms;
	pipeline.pViewportState = &vp;
	pipeline.pDepthStencilState = &ds;
	pipeline.pStages = shaderStages.ptr;
	pipeline.renderPass = demo.render_pass;
	pipeline.pDynamicState = &dynamicState;

	memset(&pipelineCache, 0, pipelineCache.sizeof);
	pipelineCache.sType = VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO;

	err = vkCreatePipelineCache(demo.device, &pipelineCache, null,
								&demo.pipelineCache);
	assert(!err);
	err = vkCreateGraphicsPipelines(demo.device, demo.pipelineCache, 1,
									&pipeline, null, &demo.pipeline);
	assert(!err);

	vkDestroyPipelineCache(demo.device, demo.pipelineCache, null);

	vkDestroyShaderModule(demo.device, demo.frag_shader_module, null);
	vkDestroyShaderModule(demo.device, demo.vert_shader_module, null);
}

private void demo_prepare_descriptor_pool(Demo* demo) {
	const(VkDescriptorPoolSize) type_count = {
		type: VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
		descriptorCount: DEMO_TEXTURE_COUNT,
    };
	const(VkDescriptorPoolCreateInfo) descriptor_pool = {
		sType: VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
		pNext: null,
		maxSets: 1,
		poolSizeCount: 1,
		pPoolSizes: &type_count,
    };
	VkResult err;

	err = vkCreateDescriptorPool(demo.device, &descriptor_pool, null,
								 &demo.desc_pool);
	assert(!err);
}

private void demo_prepare_descriptor_set(Demo* demo) {
	VkDescriptorImageInfo[DEMO_TEXTURE_COUNT] tex_descs;
	VkWriteDescriptorSet write;
	VkResult err;
	uint i;

	VkDescriptorSetAllocateInfo alloc_info = {
		sType: VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
		pNext: null,
		descriptorPool: demo.desc_pool,
		descriptorSetCount: 1,
		pSetLayouts: &demo.desc_layout};
	err = vkAllocateDescriptorSets(demo.device, &alloc_info, &demo.desc_set);
	assert(!err);

	memset(&tex_descs, 0, tex_descs.sizeof);
	for (i = 0; i < DEMO_TEXTURE_COUNT; i++) {
		tex_descs[i].sampler = demo.textures[i].sampler;
		tex_descs[i].imageView = demo.textures[i].view;
		tex_descs[i].imageLayout = VK_IMAGE_LAYOUT_GENERAL;
	}

	memset(&write, 0, write.sizeof);
	write.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
	write.dstSet = demo.desc_set;
	write.descriptorCount = DEMO_TEXTURE_COUNT;
	write.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
	write.pImageInfo = tex_descs.ptr;

	vkUpdateDescriptorSets(demo.device, 1, &write, 0, null);
}

private void demo_prepare_framebuffers(Demo* demo) {
	VkImageView[2] attachments;
	attachments[1] = demo.depth.view;

	const(VkFramebufferCreateInfo) fb_info = {
		sType: VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
		pNext: null,
		renderPass: demo.render_pass,
		attachmentCount: 2,
		pAttachments: attachments.ptr,
		width: demo.width,
		height: demo.height,
		layers: 1,
    };
	VkResult err;
	uint i;

	demo.framebuffers = cast(VkFramebuffer*)malloc(demo.swapchainImageCount *
												 VkFramebuffer.sizeof);
	assert(demo.framebuffers);

	for (i = 0; i < demo.swapchainImageCount; i++) {
		attachments[0] = demo.buffers[i].view;
		err = vkCreateFramebuffer(demo.device, &fb_info, null,
								  &demo.framebuffers[i]);
		assert(!err);
	}
}

private void demo_prepare(Demo* demo) {
	VkResult err;

	const(VkCommandPoolCreateInfo) cmd_pool_info = {
		sType: VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
		pNext: null,
		queueFamilyIndex: demo.graphics_queue_node_index,
		flags: VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
    };
	err = vkCreateCommandPool(demo.device, &cmd_pool_info, null,
							  &demo.cmd_pool);
	assert(!err);

	const(VkCommandBufferAllocateInfo) cmd = {
		sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
		pNext: null,
		commandPool: demo.cmd_pool,
		level: VK_COMMAND_BUFFER_LEVEL_PRIMARY,
		commandBufferCount: 1,
    };
	err = vkAllocateCommandBuffers(demo.device, &cmd, &demo.draw_cmd);
	assert(!err);

	demo_prepare_buffers(demo);
	demo_prepare_depth(demo);
	demo_prepare_textures(demo);
	demo_prepare_vertices(demo);
	demo_prepare_descriptor_layout(demo);
	demo_prepare_render_pass(demo);
	demo_prepare_pipeline(demo);

	demo_prepare_descriptor_pool(demo);
	demo_prepare_descriptor_set(demo);

	demo_prepare_framebuffers(demo);
}

private extern(C) void demo_error_callback(int error, const(char)* description) {
	printf("GLFW error: %s\n", description);
	fflush(stdout);
}

private extern(C) void demo_key_callback(GLFWwindow* window, int key, int scancode, int action, int mods) {
	if (key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE)
		glfwSetWindowShouldClose(window, GLFW_TRUE);
}

private extern(C) void demo_refresh_callback(GLFWwindow* window) {
	Demo* demo = cast(Demo*) glfwGetWindowUserPointer(window);
	demo_draw(demo);
}

private extern(C) void demo_resize_callback(GLFWwindow* window, int width, int height) {
	Demo* demo = cast(Demo*) glfwGetWindowUserPointer(window);
	demo.width = width;
	demo.height = height;
	demo_resize(demo);
}

private void demo_run(Demo* demo) {
	while (!glfwWindowShouldClose(demo.window)) {
		glfwPollEvents();

		demo_draw(demo);

		if (demo.depthStencil > 0.99f)
			demo.depthIncrement = -0.001f;
		if (demo.depthStencil < 0.8f)
			demo.depthIncrement = 0.001f;

		demo.depthStencil += demo.depthIncrement;

		// Wait for work to finish before updating MVP.
		vkDeviceWaitIdle(demo.device);
		demo.curFrame++;
		if (demo.frameCount != int.max && demo.curFrame == demo.frameCount)
			glfwSetWindowShouldClose(demo.window, GLFW_TRUE);
	}
}

private void demo_create_window(Demo* demo) {
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);

	demo.window = glfwCreateWindow(demo.width,
									demo.height,
									APP_LONG_NAME,
									null,
									null);
	if (!demo.window) {
		// It didn't work, so try to give a useful error:
		printf("Cannot create a window in which to draw!\n");
		fflush(stdout);
		exit(1);
	}

	glfwSetWindowUserPointer(demo.window, demo);
	glfwSetWindowRefreshCallback(demo.window, &demo_refresh_callback);
	glfwSetFramebufferSizeCallback(demo.window, &demo_resize_callback);
	glfwSetKeyCallback(demo.window, &demo_key_callback);
}

/*
 * Return 1 (true) if all layer names specified in check_names
 * can be found in given layer properties.
 */
static VkBool32 demo_check_layers(
	uint check_count, const(char)** check_names, uint layer_count, VkLayerProperties* layers
) {
	uint i;uint j;
	for (i = 0; i < check_count; i++) {
		VkBool32 found = 0;
		for (j = 0; j < layer_count; j++) {
			if (!strcmp(check_names[i], layers[j].layerName.ptr)) {
				found = 1;
				break;
			}
		}
		if (!found) {
			fprintf(stderr, "Cannot find layer: %s\n", check_names[i]);
			return 0;
		}
	}
	return 1;
}

private void demo_init_vk(Demo* demo) {
	VkResult err;
	uint i = 0;
	uint required_extension_count = 0;
	uint instance_extension_count = 0;
	uint instance_layer_count = 0;
	uint validation_layer_count = 0;
	const(char)** required_extensions = null;
	const(char)** instance_validation_layers = null;
	demo.enabled_extension_count = 0;
	demo.enabled_layer_count = 0;

	const(char)*[1] instance_validation_layers_alt1 = [
		"VK_LAYER_LUNARG_standard_validation"
	];

	const(char)*[7] instance_validation_layers_alt2 = [
		"VK_LAYER_GOOGLE_threading",       "VK_LAYER_LUNARG_parameter_validation",
		"VK_LAYER_LUNARG_object_tracker",  "VK_LAYER_LUNARG_image",
		"VK_LAYER_LUNARG_core_validation", "VK_LAYER_LUNARG_swapchain",
		"VK_LAYER_GOOGLE_unique_objects"
	];

	/* Look for validation layers */
	VkBool32 validation_found = 0;
	if (demo.validate) {

		err = vkEnumerateInstanceLayerProperties(&instance_layer_count, null);
		assert(!err);

		instance_validation_layers = cast(const(char)**) instance_validation_layers_alt1;
		if (instance_layer_count > 0) {
			VkLayerProperties* instance_layers = cast(VkLayerProperties*)
				malloc(VkLayerProperties.sizeof * instance_layer_count);
			err = vkEnumerateInstanceLayerProperties(&instance_layer_count, instance_layers);
			assert(!err);

			validation_found = demo_check_layers(
					instance_validation_layers_alt1.length,
					instance_validation_layers, instance_layer_count,
					instance_layers);
			if (validation_found) {
				demo.enabled_layer_count = instance_validation_layers_alt1.length;
				demo.enabled_layers[0] = "VK_LAYER_LUNARG_standard_validation";
				validation_layer_count = 1;
			} else {
				// use alternative set of validation layers
				instance_validation_layers =
					cast(const(char)**) instance_validation_layers_alt2;
				demo.enabled_layer_count = instance_validation_layers_alt2.length;
				validation_found = demo_check_layers(
					instance_validation_layers_alt2.length,
					instance_validation_layers, instance_layer_count,
					instance_layers);
				validation_layer_count =
					instance_validation_layers_alt2.length;
				for (i = 0; i < validation_layer_count; i++) {
					demo.enabled_layers[i] = instance_validation_layers[i];
				}
			}
			free(instance_layers);
		}

		if (!validation_found) {
			ERR_EXIT("vkEnumerateInstanceLayerProperties failed to find "
					~ "required validation layer.\n\n"
					~ "Please look at the Getting Started guide for additional "
					~ "information.\n",
					"vkCreateInstance Failure");
		}
	}

	/* Look for instance extensions */
	required_extensions = glfwGetRequiredInstanceExtensions(&required_extension_count);
	if (!required_extensions) {
		ERR_EXIT("glfwGetRequiredInstanceExtensions failed to find the "
				 ~ "platform surface extensions.\n\nDo you have a compatible "
				 ~ "Vulkan installable client driver (ICD) installed?\nPlease "
				 ~ "look at the Getting Started guide for additional "
				 ~ "information.\n",
				 "vkCreateInstance Failure");
	}

	for (i = 0; i < required_extension_count; i++) {
		demo.extension_names[demo.enabled_extension_count++] = required_extensions[i];
		assert(demo.enabled_extension_count < 64);
	}

	err = vkEnumerateInstanceExtensionProperties(null, &instance_extension_count, null);
	assert(!err);

	if (instance_extension_count > 0) {
		VkExtensionProperties* instance_extensions = cast(VkExtensionProperties*)
			malloc(VkExtensionProperties.sizeof * instance_extension_count);
		err = vkEnumerateInstanceExtensionProperties(
			null, &instance_extension_count, instance_extensions);
		assert(!err);
		for (i = 0; i < instance_extension_count; i++) {
			if (!strcmp(VK_EXT_DEBUG_REPORT_EXTENSION_NAME,
						instance_extensions[i].extensionName.ptr)) {
				if (demo.validate) {
					demo.extension_names[demo.enabled_extension_count++] =
						VK_EXT_DEBUG_REPORT_EXTENSION_NAME;
				}
			}
			assert(demo.enabled_extension_count < 64);
		}

		free(instance_extensions);
	}


	const(VkApplicationInfo) app = {
		sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
		pNext: null,
		pApplicationName: APP_SHORT_NAME,
		applicationVersion: 0,
		pEngineName: APP_SHORT_NAME,
		engineVersion: 0,
		apiVersion: VK_API_VERSION_1_0,
    };
	VkInstanceCreateInfo inst_info = {
		sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
		pNext: null,
		pApplicationInfo: &app,
		enabledLayerCount: demo.enabled_layer_count,
		ppEnabledLayerNames: cast(const(char*)*)instance_validation_layers,
		enabledExtensionCount: demo.enabled_extension_count,
		ppEnabledExtensionNames: cast(const(char*)*)demo.extension_names,
    };

	uint gpu_count;

	err = vkCreateInstance(&inst_info, null, &demo.inst);
	if (err == VK_ERROR_INCOMPATIBLE_DRIVER) {
		ERR_EXIT("Cannot find a compatible Vulkan installable client driver "
				 ~ "(ICD).\n\nPlease look at the Getting Started guide for "
				 ~ "additional information.\n",
				 "vkCreateInstance Failure");
	} else if (err == VK_ERROR_EXTENSION_NOT_PRESENT) {
		ERR_EXIT("Cannot find a specified extension library"
				 ~ ".\nMake sure your layers path is set appropriately\n",
				 "vkCreateInstance Failure");
	} else if (err) {
		ERR_EXIT("vkCreateInstance failed.\n\nDo you have a compatible Vulkan "
				 ~ "installable client driver (ICD) installed?\nPlease look at "
				 ~ "the Getting Started guide for additional information.\n",
				 "vkCreateInstance Failure");
	}

	//gladLoadVulkanUserPtr(null, &glad_vulkan_callback, demo.inst);
	loadInstanceLevelFunctions(demo.inst);

	/* Make initial call to query gpu_count, then second call for gpu info*/
	err = vkEnumeratePhysicalDevices(demo.inst, &gpu_count, null);
	assert(!err && gpu_count > 0);

	if (gpu_count > 0) {
		VkPhysicalDevice* physical_devices =
			cast(VkPhysicalDevice*) malloc(VkPhysicalDevice.sizeof * gpu_count);
		err = vkEnumeratePhysicalDevices(demo.inst, &gpu_count, physical_devices);
		assert(!err);
		/* For tri demo we just grab the first physical device */
		demo.gpu = physical_devices[0];
		free(physical_devices);
	} else {
		ERR_EXIT("vkEnumeratePhysicalDevices reported zero accessible devices."
				 ~ "\n\nDo you have a compatible Vulkan installable client"
				 ~ " driver (ICD) installed?\nPlease look at the Getting Started"
				 ~ " guide for additional information.\n",
				 "vkEnumeratePhysicalDevices Failure");
	}

	//gladLoadVulkanUserPtr(demo.gpu, &glad_vulkan_callback, demo.inst);

	/* Look for device extensions */
	uint device_extension_count = 0;
	VkBool32 swapchainExtFound = 0;
	demo.enabled_extension_count = 0;

	err = vkEnumerateDeviceExtensionProperties(demo.gpu, null, &device_extension_count, null);
	assert(!err);

	if (device_extension_count > 0) {
		VkExtensionProperties* device_extensions = cast(VkExtensionProperties*)
			malloc(VkExtensionProperties.sizeof * device_extension_count);
		err = vkEnumerateDeviceExtensionProperties(
			demo.gpu, null, &device_extension_count, device_extensions);
		assert(!err);

		for (i = 0; i < device_extension_count; i++) {
			if (!strcmp(VK_KHR_SWAPCHAIN_EXTENSION_NAME, device_extensions[i].extensionName.ptr)) {
				swapchainExtFound = 1;
				demo.extension_names[demo.enabled_extension_count++] =
					VK_KHR_SWAPCHAIN_EXTENSION_NAME;
			}
			assert(demo.enabled_extension_count < 64);
		}

		free(device_extensions);
	}

	if (!swapchainExtFound) {
		ERR_EXIT("vkEnumerateDeviceExtensionProperties failed to find "
				 ~ "the " ~ VK_KHR_SWAPCHAIN_EXTENSION_NAME
				 ~ " extension.\n\nDo you have a compatible "
				 ~ "Vulkan installable client driver (ICD) installed?\nPlease "
				 ~ "look at the Getting Started guide for additional "
				 ~ "information.\n",
				 "vkCreateInstance Failure");
	}

	if (demo.validate) {
		VkDebugReportCallbackCreateInfoEXT dbgCreateInfo;
		dbgCreateInfo.sType = VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT;
		dbgCreateInfo.flags =
			VK_DEBUG_REPORT_ERROR_BIT_EXT | VK_DEBUG_REPORT_WARNING_BIT_EXT;
		dbgCreateInfo.pfnCallback = demo.use_break ? &BreakCallback : &dbgFunc;
		dbgCreateInfo.pUserData = demo;
		dbgCreateInfo.pNext = null;
		err = vkCreateDebugReportCallbackEXT(demo.inst, &dbgCreateInfo, null,
											 &demo.msg_callback);
		switch (err) {
			case VK_SUCCESS:
				break;
			case VK_ERROR_OUT_OF_HOST_MEMORY:
				return ERR_EXIT("CreateDebugReportCallback: out of host memory\n",
						"CreateDebugReportCallback Failure");
			default:
				return ERR_EXIT("CreateDebugReportCallback: unknown failure\n",
						"CreateDebugReportCallback Failure");
		}
	}

	vkGetPhysicalDeviceProperties(demo.gpu, &demo.gpu_props);

	// Query with NULL data to get count
	vkGetPhysicalDeviceQueueFamilyProperties(demo.gpu, &demo.queue_count,
											 null);

	demo.queue_props = cast(VkQueueFamilyProperties*)malloc(
		demo.queue_count * VkQueueFamilyProperties.sizeof);
	vkGetPhysicalDeviceQueueFamilyProperties(demo.gpu, &demo.queue_count,
											 demo.queue_props);
	assert(demo.queue_count >= 1);

	vkGetPhysicalDeviceFeatures(demo.gpu, &demo.gpu_features);

	// Graphics queue and MemMgr queue can be separate.
	// TODO: Add support for separate queues, including synchronization,
	//       and appropriate tracking for QueueSubmit
}

private void demo_init_device(Demo* demo) {
	VkResult err;

	float[1] queue_priorities = [0.0];
	const(VkDeviceQueueCreateInfo) queue = {
		sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
		pNext: null,
		queueFamilyIndex: demo.graphics_queue_node_index,
		queueCount: 1,
		pQueuePriorities: queue_priorities.ptr};


	VkPhysicalDeviceFeatures features;
	memset(&features, 0, features.sizeof);
	if (demo.gpu_features.shaderClipDistance) {
		features.shaderClipDistance = VK_TRUE;
	}

	VkDeviceCreateInfo device = {
		sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
		pNext: null,
		queueCreateInfoCount: 1,
		pQueueCreateInfos: &queue,
		enabledLayerCount: 0,
		ppEnabledLayerNames: null,
		enabledExtensionCount: demo.enabled_extension_count,
		ppEnabledExtensionNames: cast(const(char*)*)demo.extension_names,
		pEnabledFeatures: &features,
    };

	err = vkCreateDevice(demo.gpu, &device, null, &demo.device);
	assert(!err);
}

private void demo_init_vk_swapchain(Demo* demo) {
	VkResult err;
	uint i;

	// Create a WSI surface for the window:
	glfwCreateWindowSurface(demo.inst, demo.window, null, cast(ulong*) &demo.surface); // todo: ugly cast

	// Iterate over each queue to learn whether it supports presenting:
	VkBool32* supportsPresent = cast(VkBool32*)malloc(demo.queue_count * VkBool32.sizeof);
	for (i = 0; i < demo.queue_count; i++) {
		vkGetPhysicalDeviceSurfaceSupportKHR(demo.gpu, i, demo.surface, &supportsPresent[i]);
	}

	// Search for a graphics and a present queue in the array of queue
	// families, try to find one that supports both
	uint graphicsQueueNodeIndex = uint.max;
	uint presentQueueNodeIndex = uint.max;
	for (i = 0; i < demo.queue_count; i++) {
		if ((demo.queue_props[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) != 0) {
			if (graphicsQueueNodeIndex == uint.max) {
				graphicsQueueNodeIndex = i;
			}

			if (supportsPresent[i] == VK_TRUE) {
				graphicsQueueNodeIndex = i;
				presentQueueNodeIndex = i;
				break;
			}
		}
	}
	if (presentQueueNodeIndex == uint.max) {
		// If didn't find a queue that supports both graphics and present, then
		// find a separate present queue.
		for (i = 0; i < demo.queue_count; ++i) {
			if (supportsPresent[i] == VK_TRUE) {
				presentQueueNodeIndex = i;
				break;
			}
		}
	}
	free(supportsPresent);

	// Generate error if could not find both a graphics and a present queue
	if (graphicsQueueNodeIndex == uint.max ||
		presentQueueNodeIndex == uint.max) {
		ERR_EXIT("Could not find a graphics and a present queue\n",
				 "Swapchain Initialization Failure");
	}

	// TODO: Add support for separate queues, including presentation,
	//       synchronization, and appropriate tracking for QueueSubmit.
	// NOTE: While it is possible for an application to use a separate graphics
	//       and a present queues, this demo program assumes it is only using
	//       one:
	if (graphicsQueueNodeIndex != presentQueueNodeIndex) {
		ERR_EXIT("Could not find a common graphics and a present queue\n",
				 "Swapchain Initialization Failure");
	}
	demo.graphics_queue_node_index = graphicsQueueNodeIndex;

	demo_init_device(demo);
	loadDeviceLevelFunctions(demo.device);
	vkGetDeviceQueue(demo.device, demo.graphics_queue_node_index, 0, &demo.queue);

	// Get the list of VkFormat's that are supported:
	uint formatCount;
	err = vkGetPhysicalDeviceSurfaceFormatsKHR(demo.gpu, demo.surface,
											   &formatCount, null);
	assert(!err);
	VkSurfaceFormatKHR* surfFormats = cast(VkSurfaceFormatKHR*)malloc(formatCount * VkSurfaceFormatKHR.sizeof);
	err = vkGetPhysicalDeviceSurfaceFormatsKHR(demo.gpu, demo.surface,
											   &formatCount, surfFormats);
	assert(!err);
	// If the format list includes just one entry of VK_FORMAT_UNDEFINED,
	// the surface has no preferred format.  Otherwise, at least one
	// supported format will be returned.
	if (formatCount == 1 && surfFormats[0].format == VK_FORMAT_UNDEFINED) {
		demo.format = VK_FORMAT_B8G8R8A8_UNORM;
	} else {
		assert(formatCount >= 1);
		demo.format = surfFormats[0].format;
	}
	demo.color_space = surfFormats[0].colorSpace;

	demo.curFrame = 0;

	// Get Memory information and properties
	vkGetPhysicalDeviceMemoryProperties(demo.gpu, &demo.memory_properties);
}

private void demo_init_connection(Demo* demo) {
	glfwSetErrorCallback(&demo_error_callback);

	if (!glfwInit()) {
		printf("Cannot initialize GLFW.\nExiting ...\n");
		fflush(stdout);
		exit(1);
	}

	if (!glfwVulkanSupported()) {
		printf("GLFW failed to find the Vulkan loader.\nExiting ...\n");
		fflush(stdout);
		exit(1);
	}

	//gladLoadVulkanUserPtr(null, &glad_vulkan_callback, null);
}

private void demo_init(Demo* demo, const(int) argc, const(char)** argv) {
	int i;
	memset(demo, 0, typeof(*demo).sizeof);
	demo.frameCount = int.max;

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "--use_staging") == 0) {
			demo.use_staging_buffer = true;
			continue;
		}
		if (strcmp(argv[i], "--break") == 0) {
			demo.use_break = true;
			continue;
		}
		if (strcmp(argv[i], "--validate") == 0) {
			demo.validate = true;
			continue;
		}
		if (strcmp(argv[i], "--c") == 0 && demo.frameCount == int.max &&
			i < argc - 1 && sscanf(argv[i + 1], "%d", &demo.frameCount) == 1 &&
			demo.frameCount >= 0) {
			i++;
			continue;
		}

		fprintf(stderr, "Usage:\n  %s [--use_staging] [--validate] [--break] "
						~ "[--c <framecount>]\n",
				APP_SHORT_NAME.ptr);
		fflush(stderr);
		exit(1);
	}

	demo_init_connection(demo);
	demo_init_vk(demo);

	demo.width = 300;
	demo.height = 300;
	demo.depthStencil = 1.0;
	demo.depthIncrement = -0.01f;
}

private void demo_cleanup(Demo* demo) {
	uint i;

	for (i = 0; i < demo.swapchainImageCount; i++) {
		vkDestroyFramebuffer(demo.device, demo.framebuffers[i], null);
	}
	free(demo.framebuffers);
	vkDestroyDescriptorPool(demo.device, demo.desc_pool, null);

	if (demo.setup_cmd) {
		vkFreeCommandBuffers(demo.device, demo.cmd_pool, 1, &demo.setup_cmd);
	}
	vkFreeCommandBuffers(demo.device, demo.cmd_pool, 1, &demo.draw_cmd);
	vkDestroyCommandPool(demo.device, demo.cmd_pool, null);

	vkDestroyPipeline(demo.device, demo.pipeline, null);
	vkDestroyRenderPass(demo.device, demo.render_pass, null);
	vkDestroyPipelineLayout(demo.device, demo.pipeline_layout, null);
	vkDestroyDescriptorSetLayout(demo.device, demo.desc_layout, null);

	vkDestroyBuffer(demo.device, demo.vertices.buf, null);
	vkFreeMemory(demo.device, demo.vertices.mem, null);

	for (i = 0; i < DEMO_TEXTURE_COUNT; i++) {
		vkDestroyImageView(demo.device, demo.textures[i].view, null);
		vkDestroyImage(demo.device, demo.textures[i].image, null);
		vkFreeMemory(demo.device, demo.textures[i].mem, null);
		vkDestroySampler(demo.device, demo.textures[i].sampler, null);
	}

	for (i = 0; i < demo.swapchainImageCount; i++) {
		vkDestroyImageView(demo.device, demo.buffers[i].view, null);
	}

	vkDestroyImageView(demo.device, demo.depth.view, null);
	vkDestroyImage(demo.device, demo.depth.image, null);
	vkFreeMemory(demo.device, demo.depth.mem, null);

	vkDestroySwapchainKHR(demo.device, demo.swapchain, null);
	free(demo.buffers);

	vkDestroyDevice(demo.device, null);
	if (demo.validate) {
		vkDestroyDebugReportCallbackEXT(demo.inst, demo.msg_callback, null);
	}
	vkDestroySurfaceKHR(demo.inst, demo.surface, null);
	vkDestroyInstance(demo.inst, null);

	free(demo.queue_props);

	glfwDestroyWindow(demo.window);
	glfwTerminate();
}

private void demo_resize(Demo* demo) {
	uint i;

	// In order to properly resize the window, we must re-create the swapchain
	// AND redo the command buffers, etc.
	//
	// First, perform part of the demo_cleanup() function:

	for (i = 0; i < demo.swapchainImageCount; i++) {
		vkDestroyFramebuffer(demo.device, demo.framebuffers[i], null);
	}
	free(demo.framebuffers);
	vkDestroyDescriptorPool(demo.device, demo.desc_pool, null);

	if (demo.setup_cmd) {
		vkFreeCommandBuffers(demo.device, demo.cmd_pool, 1, &demo.setup_cmd);
		demo.setup_cmd = VK_NULL_HANDLE;
	}
	vkFreeCommandBuffers(demo.device, demo.cmd_pool, 1, &demo.draw_cmd);
	vkDestroyCommandPool(demo.device, demo.cmd_pool, null);

	vkDestroyPipeline(demo.device, demo.pipeline, null);
	vkDestroyRenderPass(demo.device, demo.render_pass, null);
	vkDestroyPipelineLayout(demo.device, demo.pipeline_layout, null);
	vkDestroyDescriptorSetLayout(demo.device, demo.desc_layout, null);

	vkDestroyBuffer(demo.device, demo.vertices.buf, null);
	vkFreeMemory(demo.device, demo.vertices.mem, null);

	for (i = 0; i < DEMO_TEXTURE_COUNT; i++) {
		vkDestroyImageView(demo.device, demo.textures[i].view, null);
		vkDestroyImage(demo.device, demo.textures[i].image, null);
		vkFreeMemory(demo.device, demo.textures[i].mem, null);
		vkDestroySampler(demo.device, demo.textures[i].sampler, null);
	}

	for (i = 0; i < demo.swapchainImageCount; i++) {
		vkDestroyImageView(demo.device, demo.buffers[i].view, null);
	}

	vkDestroyImageView(demo.device, demo.depth.view, null);
	vkDestroyImage(demo.device, demo.depth.image, null);
	vkFreeMemory(demo.device, demo.depth.mem, null);

	free(demo.buffers);

	// Second, re-perform the demo_prepare() function, which will re-create the
	// swapchain:
	demo_prepare(demo);
}

extern(C) int main(const(int) argc, const(char)** argv) {
	Demo demo;

	loadGlobalLevelFunctions();

	demo_init(&demo, argc, argv);
	demo_create_window(&demo);
	demo_init_vk_swapchain(&demo);

	demo_prepare(&demo);
	demo_run(&demo);

	demo_cleanup(&demo);

	return validation_error;
}
