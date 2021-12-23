---Weather cloud. After creating, set a texture and then add it to the ac.weatherClouds list which would add it to the scene.
---@class ac.SkyCloudBase
---@field position vec3 "Cloud position."
---@field size vec2 "Cloud size, X for width and Y for height."
---@field color rgb "Cloud color (final shading color is material.baseColor * cloud.color * lightColor (either from cloud.customLightColor if cloud.useCustomLightColor is set, or scene light color))."
---@field opacity number "Cloud opacity, from 0 to 1."
---@field cutoff number "Cloud cutoff, from 0 to 1. All areas more transparent than this would be discarded, and opacity of the rest rescaled for smooth transition. Good for getting clouds in and out of scene without awkward fading."
---@field flipHorizontal boolean "Flip cloud horizontally, helps to increase visual variety, especially with clouds v1."
---@field flipVertical boolean "Flip cloud vertically for some reason."
---@field noTilt boolean "Set to true to stop cloud from tilting as it tries to face camera, and instead keep it strictly vectrical. Works only without cloud.horizontal and without cloud.customOrientation."
---@field horizontal boolean "Set to true to orient cloud horizontally. Good either for clouds directly above camera, or some thin clouds way up and way in the distance. Works only without cloud.customOrientation. If shading seems off with clouds v2, check cloud.flipHorizontalShading parameter."
---@field horizontalHeading number "Angle in degrees to control horizontal heading of a cloud in horizontal mode."
---@field customOrientation boolean "Set to true to use cloud.up and cloud.side vectors instead of calculating them automatically."
---@field up vec3 "Orient cloud by manually setting a vector facing up, works only with customOrientation."
---@field side vec3 "Orient cloud by manually setting a vector facing sideways, works only with customOrientation."
---@field shadowOpacity number "Opacity of shadow cast from a cloud."
---@field occludeGodrays boolean "Set to true if cloud has to occlude YEBIS godrays effect. Note: it would require to render cloud twice if it’s close to sun."
---@field useCustomLightColor boolean "Set to true to use `cloud.customLightColor` instead of main scene light color."
---@field useCustomLightDirection boolean "Set to true to use `cloud.customLightDirection` instead of main scene light direction."
---@field version integer "Version of a cloud, 1 for v1, 2 for v2."
---@field passedFrustumTest boolean "True if cloud was visible in main camera in the last frame. Might be a good idea to limit processing for clouds that are behing the camera or something like that."
---@field extraDownlit rgb "Additional cloud downlit color which will be added to downlit value set by cloud material. Good for lighting clouds above some bright area from below at night, for example."
---@field customLightColor rgb "Custom light color used instead of main scene one. Only used if `cloud.useCustomLightColor` is set to true."
---@field customLightDirection vec3 "Custom light direction used instead of main scene one. Only used if `cloud.useCustomLightDirection` is set to true."
---@field orderBy number "Clouds will be ordered by this value, ones with highest value will be rendered first. You can store distance to a cloud here, but, better yet, consider updating distance oinly if `cloud.passedFrustumTest` is false or cloud was just created. This way, clouds wouldn’t visually change rendering order in front of spectator’s eyes. Not the best solution, of course, but something to experiment with, I think."
---@field fogMultiplier number "Additional fog multiplier to value set by cloud material."
---@field material ac.SkyCloudMaterial "Cloud material. Not set by default, so cloud would be invisible and you’d need to create and set a texture first. With this arrangement, it’s easier to change some common properties without iterating all of the clouds, so consider sharing materials between clouds. It’s not a strict rule though, additional materials wouldn’t induce any marginal costs (apart from script having to iterate through all the clouds)"
---@field extras table "Extra table to store your stuff in. Just a regular Lua table."
---@virtual-class ac.SkyCloudBase

---Sets cloud texture. Note: unless you’ve used `ac.setAsyncTextureLoading(true)`, texture will be loaded syncronously, possibly causing a small freeze.
---@param filename string
function ac.SkyCloudBase:setTexture(filename) end

---Checks state of texture loading if you’re using asynchronous loading. Might be a good idea to use it to make sure cloud is ready before starting to fade it into the scene.
---@return ac.TextureState
function ac.SkyCloudBase:getTextureState() end

---First version of a cloud. Very basic, just uses its texture. Optionally can have a small noise texture for a bit of movement on edges, but that’s it. Great stuff, but sadly cloud textures start to get recognizable fairly quickly.
---@class ac.SkyCloud : ac.SkyCloudBase
---@field useNoise boolean "Use additional noise texture or not."
---@field noiseOffset vec2 "UV offset for additional noise texture, if set."
---@constructor fun(): ac.SkyCloud

---Sets cloud noise texture. Note: unless you’ve used `ac.setAsyncTextureLoading(true)`, texture will be loaded syncronously, possibly causing a small freeze.
---@param filename string
function ac.SkyCloud:setNoiseTexture(filename) end

---Checks state of noise texture loading if you’re using asynchronous loading. Might be a good idea to use it to make sure cloud is ready before starting to fade it into the scene.
---@return ac.TextureState
function ac.SkyCloud:getNoiseTextureState() end

---Second version of a cloud. Unlike first version, this one relies on [a special procedural 3D cloud texture](https://www.shadertoy.com/view/3dVXDc) generated during loading (`ac.generateCloudMap(parameters)` can be used to specify its parameters). That texture is repeating itself in all three directions, so cloud can move through it altering UVW coordinates to create an illusion of it changing shape as it moves. For main shape, cloud uses a low-resolution mask texture with red and green channels working as normal (sideways and up/down), blue channel working as sharpness mask and alpha channel is for transparency. Because this one does not have to be in high resolution, atlas could be used combining all textures into one. Use fields `cloud.texStart` and `cloud.texSize` to specify UV region of that masking texture.
---@class ac.SkyCloudV2 : ac.SkyCloudBase
---@field procMap vec2 "X is alpha of procedural 3D cloud texture where resulting cloud will be transparent, 1 is where resulting cloud will be fully opaque. In reality final result is also affected by cutoff, mask alpha and sharpness set by mask blue channel and adjusted `cloud.procSharpnessMult`. Default value: `vec2(0.65, 0.75)`."
---@field procScale vec2 "UV scale for procedural 3D cloud texture. Default value: `vec2(1, 1)`."
---@field noiseOffset vec2 "UV offset for procedural 3D cloud texture."
---@field procNormalScale vec2 "X value is a multiplier for normal read from procedural 3D cloud texture, Y value is a multiplier for normal read from red and green channels of cloud mask texture. Default value: `vec2(0.5, 0.5)`."
---@field procShapeShifting number "W coordinate for UVW when sampling that procedural 3D cloud texture. Slowly increasing it can look like cloud slowly changing shape while being stationary. That 3D cloud texture repeats on all axis, so you can loop go from 0.99 to 1.01 with no jumps."
---@field procSharpnessMult number "Blue channel of v2 cloud mask texture stores sharpness map. This value is a multiplier to said mask. Default value: 1."
---@field texStart vec2 "UV coordinates of a start of texture region with cloud mask."
---@field texSize vec2 "Size of a texture region with cloud mask, in UV coordinates."
---@field normalYExponent number "Exponent for Y part of cloud normals. Increase it to shift shape in such a way that cloud would like looked at below rather than from a side. Default value: 1."
---@field topFogBoost number "Use this value to increase fog for upper part of a cloud. Default value: 0. Values below 0 would decrease fog in upper part of a cloud."
---@field flipHorizontalShading boolean "Inverts normals for horizontal clouds."
---@field extraFidelity number "Optional extra fidelity adds another layer of cloud details, this parameter allows to control the strength of the effect. Set below zero to instead make cloud blurrier and less defined. Default value: 0 (for backwards compatibility)."
---@field receiveShadowsOpacityMult number "Multiplier for opacity of shadows from other clouds. Main value is set by the material."
---@constructor fun(): ac.SkyCloudV2
