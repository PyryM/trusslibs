/*
 * Copyright 2011-2022 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#ifndef IMGUI_H_HEADER_GUARD
#define IMGUI_H_HEADER_GUARD

#include <bgfx/bgfx.h>
#include <bgfx/c99/bgfx.h>
#include <dear-imgui/imgui.h>
#include <iconfontheaders/icons_kenney.h>
#include <iconfontheaders/icons_font_awesome.h>

#define IMGUI_MBUT_LEFT   0x01
#define IMGUI_MBUT_RIGHT  0x02
#define IMGUI_MBUT_MIDDLE 0x04

inline uint32_t imguiRGBA(uint8_t _r, uint8_t _g, uint8_t _b, uint8_t _a = 255)
{
	return 0
		| (uint32_t(_r) <<  0)
		| (uint32_t(_g) <<  8)
		| (uint32_t(_b) << 16)
		| (uint32_t(_a) << 24)
		;
}

namespace bx { struct AllocatorI; }

void imguiCreate(float _fontSize = 18.0f, bx::AllocatorI* _allocator = NULL);
void imguiDestroy();

void imguiBeginFrame(int32_t _mx, int32_t _my, uint8_t _button, int32_t _scroll, uint16_t _width, uint16_t _height, int _inputChar = -1, bgfx::ViewId _view = 255);
void imguiEndFrame();

namespace entry { class AppI; }
void showExampleDialog(entry::AppI* _app, const char* _errorText = NULL);

namespace ImGui
{
#define IMGUI_FLAGS_NONE        UINT8_C(0x00)
#define IMGUI_FLAGS_ALPHA_BLEND UINT8_C(0x01)

	///
	inline ImTextureID toId(bgfx::TextureHandle _handle, uint8_t _flags, uint8_t _mip)
	{
		union { struct { bgfx::TextureHandle handle; uint8_t flags; uint8_t mip; } s; ImTextureID id; } tex;
		tex.s.handle = _handle;
		tex.s.flags  = _flags;
		tex.s.mip    = _mip;
		return tex.id;
	}

	// Helper function for passing bgfx::TextureHandle to ImGui::Image.
	inline void Image(bgfx::TextureHandle _handle
		, uint8_t _flags
		, uint8_t _mip
		, const ImVec2& _size
		, const ImVec2& _uv0       = ImVec2(0.0f, 0.0f)
		, const ImVec2& _uv1       = ImVec2(1.0f, 1.0f)
		, const ImVec4& _tintCol   = ImVec4(1.0f, 1.0f, 1.0f, 1.0f)
		, const ImVec4& _borderCol = ImVec4(0.0f, 0.0f, 0.0f, 0.0f)
		)
	{
		Image(toId(_handle, _flags, _mip), _size, _uv0, _uv1, _tintCol, _borderCol);
	}

	// Helper function for passing bgfx::TextureHandle to ImGui::Image.
	inline void Image(bgfx::TextureHandle _handle
		, const ImVec2& _size
		, const ImVec2& _uv0       = ImVec2(0.0f, 0.0f)
		, const ImVec2& _uv1       = ImVec2(1.0f, 1.0f)
		, const ImVec4& _tintCol   = ImVec4(1.0f, 1.0f, 1.0f, 1.0f)
		, const ImVec4& _borderCol = ImVec4(0.0f, 0.0f, 0.0f, 0.0f)
		)
	{
		Image(_handle, IMGUI_FLAGS_ALPHA_BLEND, 0, _size, _uv0, _uv1, _tintCol, _borderCol);
	}

	// Helper function for passing bgfx::TextureHandle to ImGui::ImageButton.
	inline bool ImageButton(bgfx::TextureHandle _handle
		, uint8_t _flags
		, uint8_t _mip
		, const ImVec2& _size
		, const ImVec2& _uv0     = ImVec2(0.0f, 0.0f)
		, const ImVec2& _uv1     = ImVec2(1.0f, 1.0f)
		, const ImVec4& _bgCol   = ImVec4(0.0f, 0.0f, 0.0f, 0.0f)
		, const ImVec4& _tintCol = ImVec4(1.0f, 1.0f, 1.0f, 1.0f)
		)
	{
		return ImageButton("image", toId(_handle, _flags, _mip), _size, _uv0, _uv1, _bgCol, _tintCol);
	}

	// Helper function for passing bgfx::TextureHandle to ImGui::ImageButton.
	inline bool ImageButton(bgfx::TextureHandle _handle
		, const ImVec2& _size
		, const ImVec2& _uv0     = ImVec2(0.0f, 0.0f)
		, const ImVec2& _uv1     = ImVec2(1.0f, 1.0f)
		, const ImVec4& _bgCol   = ImVec4(0.0f, 0.0f, 0.0f, 0.0f)
		, const ImVec4& _tintCol = ImVec4(1.0f, 1.0f, 1.0f, 1.0f)
		)
	{
		return ImageButton(_handle, IMGUI_FLAGS_ALPHA_BLEND, 0, _size, _uv0, _uv1, _bgCol, _tintCol);
	}

	///
	inline void NextLine()
	{
		SetCursorPosY(GetCursorPosY() + GetTextLineHeightWithSpacing() );
	}

	///
	inline bool MouseOverArea()
	{
		return false
			|| ImGui::IsAnyItemActive()
			|| ImGui::IsAnyItemHovered()
			|| ImGui::IsWindowHovered(ImGuiHoveredFlags_AnyWindow)
//			|| ImGuizmo::IsOver()
			;
	}

	///
	void PushEnabled(bool _enabled);

	///
	void PopEnabled();

} // namespace ImGui

// PATCHED vvvvvv
#if defined _WIN32 || defined __CYGWIN__
    #ifdef CIMGUI_NO_EXPORT
        #define API
    #else
        #define API __declspec(dllexport)
    #endif
#else
    #ifdef __GNUC__
        #define API  __attribute__((__visibility__("default")))
    #else
        #define API
    #endif
#endif

#if defined __cplusplus
    #define EXTERN extern "C"
#else
    #include <stdarg.h>
    #include <stdbool.h>
    #define EXTERN extern
#endif

#define CIMGUI_API EXTERN API

struct bgfx_imgui_font_info {
	uint8_t* data;
	uint32_t datasize;
	float fontsizemod;
	char* fontname;
};

// C API functions
struct bgfx_util_imagedata {
	uint8_t* data;
	void* _container;
	uint32_t datasize;
	uint32_t width;
	uint32_t height;
};

CIMGUI_API void igBGFXCreate(float _fontSize);
CIMGUI_API void igBGFXCreateWithFonts(float _fontSize, bgfx_imgui_font_info* _fonts, uint32_t _fontcount);
CIMGUI_API void igBGFXDestroy();

CIMGUI_API void igBGFXBeginFrame(uint16_t _width, uint16_t _height, uint16_t _viewId);
CIMGUI_API void igBGFXEndFrame();

// Note that in practice `ImTextureID` is a void*
CIMGUI_API ImTextureID igBGFXTexToId(bgfx_texture_handle_t _handle, uint8_t _flags, uint8_t _mip);
CIMGUI_API void igBGFXPushFont(uint32_t _fontid);

CIMGUI_API bool igBGFXUtilDecodeImage(uint8_t* data, uint32_t datasize, bgfx_util_imagedata* dest);
CIMGUI_API void igBGFXUtilReleaseImage(bgfx_util_imagedata* imgdata);
// PATCHED ^^^^^^

#endif // IMGUI_H_HEADER_GUARD
