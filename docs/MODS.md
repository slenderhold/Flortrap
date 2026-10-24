# Writing mods for Flortrap

A mod is a small package that changes how Roblox looks or behaves. It can do two things:

1. **Set FastFlags** (the same flags as in Settings > Flags).
2. **Replace or add files** inside the Roblox folder (cursors, textures, sounds, fonts).

Mods never run code. Flortrap only copies the listed files and writes the listed flags.

## Quick start (5 minutes)

1. Open the **Mods** tab and press **Open mods folder** (`C:\FRoblox\Mods`).
2. Create a folder, for example `C:\FRoblox\Mods\my-mod`. The folder name is the mod id.
3. Put a file called `mod.json` in it:

```json
{
  "id": "my-mod",
  "name": "My Mod",
  "description": "Turns shadows off.",
  "version": "1.0.0",
  "author": "You",
  "flags": {
    "FIntRenderShadowIntensity": 0
  }
}
```

4. Press **Refresh** in the Mods tab. The mod shows up in the list. Switch it on.
5. Start Roblox from Flortrap. Mods are applied on every launch.

## Folder layout

```
my-mod/
  mod.json        required
  banner.png      optional, shown on the card (about 720x240)
  files/          optional, anything you want to copy into Roblox
    ArrowCursor.png
```

To share a mod, zip the **contents** of the folder (`mod.json` must be at the top of the zip, not inside a subfolder).

## mod.json

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Lower case letters, digits, `-` and `_`, 2 to 41 characters. Must equal the folder name. |
| `name` | yes | Shown on the card. |
| `description` | yes | One or two sentences. |
| `version` | yes | For example `1.2.0`. A higher version in the catalog shows an **Update** button. |
| `author` | no | Shown next to the version. |
| `flags` | no | Object of FastFlag name to value. Values can be `true`/`false`, numbers or text. |
| `files` | no | List of `{ "from": "...", "to": "..." }`. |

### files

```json
"files": [
  { "from": "files/ArrowCursor.png", "to": "content/textures/Cursors/KeyboardMouse/ArrowCursor.png" }
]
```

* `from` is a path inside the mod folder.
* `to` is a path inside the Roblox version folder. It must start with `content/`, `PlatformContent/` or `ExtraContent/`.
* If the target file already exists, Flortrap saves a backup first and puts the original back when the mod is switched off or removed.
* Allowed file types: png, jpg, jpeg, ogg, mp3, wav, ttf, otf, cur, ani, ico, json, txt, ktx, dds, mesh, rbxm, xml.
  Programs and scripts (exe, dll, bat, ps1 and so on) are never copied.
* Limits: 500 files and 100 MB per mod.

Handy targets:

| What | Path |
|---|---|
| Mouse arrow | `content/textures/Cursors/KeyboardMouse/ArrowCursor.png` |
| Far mouse arrow | `content/textures/Cursors/KeyboardMouse/ArrowFarCursor.png` |
| Death sound | `content/sounds/ouch.ogg` |

Roblox changes its files from time to time. If a path does not exist in your version, the file is simply added and has no effect.

### flags

Roblox only accepts flags from its own allow-list and silently ignores the rest. A flag that does nothing is not an error. Flags from a mod are written first, so flags you add yourself in Settings > Flags win over them.

## Switching on and off

* The switch on a card turns the mod on or off. Changes are applied on the next launch of Roblox from Flortrap.
* **Remove** deletes the mod folder and restores the files it replaced.
* Downloading a mod switches it on automatically.

## Publishing in the catalog

The Mods tab also reads `mods/catalog.json` from the GitHub repository (`slenderhold/Flortrap`, branch `main`). Add an entry with a link to your zip:

```json
{
  "mods": [
    {
      "id": "my-mod",
      "name": "My Mod",
      "description": "Turns shadows off.",
      "version": "1.0.0",
      "author": "You",
      "package": "https://github.com/you/my-mod/releases/download/v1.0.0/my-mod.zip",
      "banner": "https://raw.githubusercontent.com/you/my-mod/main/banner.png"
    }
  ]
}
```

`package` must be an `https://` link to the zip. The `id` inside the zip's `mod.json` must match the catalog id, otherwise the install is refused.

## Building the bundled mods

The mods that ship inside Flortrap live in `mods-src/`. After changing one, run `python tools/build_mods.py` and rebuild the app.
