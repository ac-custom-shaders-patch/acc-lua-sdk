__source 'lua/api_physics_unrestricted.cpp'
__namespace 'physics'

---Physics namespace. Note: most functions here are accessible only if track has expicitly allowed it with its
---extended CSP physics.
---
---To allow scriptable physics, add to surfaces.ini:
---```ini
---[_SCRIPTING_PHYSICS]
---ALLOW_TRACK_SCRIPTS=1    ; choose ones that you need
---ALLOW_DISPLAY_SCRIPTS=1
---ALLOW_NEW_MODE_SCRIPTS=1
---ALLOW_TOOLS=1
---```
---
---And to activate extended physics, use:
---```ini
---[SURFACE_0]
---WAV_PITCH=extended-0
---```
physics = {}
