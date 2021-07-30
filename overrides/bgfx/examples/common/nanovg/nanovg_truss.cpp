#include <bx/bx.h>
#include <bx/allocator.h>
#include <bx/uint32_t.h>
#include <bgfx/bgfx.h>
#include "nanovg.h"

NVGcontext* nvgCreateC(unsigned int _edgeaa, uint16_t _viewId) {
	return nvgCreate(_edgeaa, _viewId, NULL);
}

void nvgDeleteC(NVGcontext* _ctx)
{
	nvgDeleteInternal(_ctx);
}

void nvgSetViewIdC(NVGcontext* _ctx, uint16_t _viewId)
{
	nvgSetViewId(_ctx, _viewId);
}

uint16_t nvgGetViewIdC(struct NVGcontext* _ctx)
{
	return nvgGetViewId(_ctx);
}