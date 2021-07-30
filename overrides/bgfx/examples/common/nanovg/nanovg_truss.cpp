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
	struct NVGparams* params = nvgInternalParams(_ctx);
	struct GLNVGcontext* gl = (struct GLNVGcontext*)params->userPtr;
	gl->m_viewId = _viewId;
}

uint16_t nvgGetViewIdC(struct NVGcontext* _ctx)
{
	struct NVGparams* params = nvgInternalParams(_ctx);
	struct GLNVGcontext* gl = (struct GLNVGcontext*)params->userPtr;
	return gl->m_viewId;
}