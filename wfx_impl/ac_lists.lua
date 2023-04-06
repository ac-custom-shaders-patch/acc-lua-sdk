ac.weatherClouds = __util.boundArray(ffi.typeof('cloud*'), ffi.C.lj_set_clouds__impl)
ac.weatherCloudsCovers = __util.boundArray(ffi.typeof('cloudscover*'), ffi.C.lj_set_cloudscovers__impl)
ac.skyExtraGradients = __util.boundArray(ffi.typeof('extragradient*'), ffi.C.lj_set_gradients__impl)
ac.weatherColorCorrections = __util.boundArray(ffi.typeof('void*'), ffi.C.lj_set_corrections__impl)

ac.addWeatherCloud = function(cloud) return ac.weatherClouds:pushWhereFits(cloud) end
ac.addWeatherCloudCover = function(cloud) return ac.weatherCloudsCovers:pushWhereFits(cloud) end
ac.addSkyExtraGradient = function(gradient) return ac.skyExtraGradients:pushWhereFits(gradient) end
ac.addWeatherColorCorrection = function(cc) return ac.weatherColorCorrections:pushWhereFits(cc) end
ac.removeWeatherCloud = function(cloud) return ac.weatherClouds:erase(cloud) end
ac.removeWeatherCloudCover = function(cloud) return ac.weatherCloudsCovers:erase(cloud) end
ac.removeSkyExtraGradient = function(gradient) return ac.skyExtraGradients:erase(gradient) end
ac.removeWeatherColorCorrection = function(cc) return ac.weatherColorCorrections:erase(cc) end
