---Sets a callback which will be called when AC tries to apply YEBIS post-processing. At this point final LDR
---render target is already bound, input textures can be accessed as `dynamic::pp::hdr` and `dynamic::pp::depth`.
---Could be a good place to add extra effects to HDR buffer or even replace YEBIS with a custom call. Or you can
---just alter values in `params`: this is the structure that will be passed to YEBIS as post-processing settings.
---@param callback fun(params: ac.PostProcessingParameters, exposure: number, mainPass: boolean, updateExposure: boolean, rtSize: vec2): nil|boolean|ui.ExtraCanvas @Callback function. Return `true` to stop YEBIS. Return an extra canvas and it’ll be used as an HDR input to YEBIS instead (make sure it’s in HDR format and with the same resolution). Make sure to check `mainPass` parameter: if it’s `false`, you’re rendering an extra canvas with YEBIS post-processing mode, so maybe tune down features and apply the most basic stuff (and don’t use YEBIS antialiasing in your canvases here). If you’re doing autoexposure, don’t change things if `updateExposure` is set to `false` (this usually means you got a second eye in VR, don’t change brightness for it).
---@return ac.Disposable
function ac.onPostProcessing(callback)
  return __util.lazy('lib_postprocessing')(callback)
end