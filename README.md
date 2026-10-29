# HLAE UI

A Windows desktop app built with Qt Quick and C++ for using HLAE with Counter-Strike 2. The goal is a full UI for HLAE FX in CS2, so demo and recording work can be done without typing every command by hand.

The app is still in early development. Some pages and controls are unfinished.

## What works now

- Launch CS2 through HLAE with custom game arguments.
- Save the HLAE and CS2 executable paths and launch arguments in Settings.
- Create, list, load, and delete demo projects. Loading a project sends `playdemo` to the game.
- Read the map name from a demo and show its map icon in the project list.
- List, add, and remove normal, depth, and black/white HUD streams.
- Read and edit stream settings, including recording inclusion, capture timing, output presets, depth settings, and HUD background color.
- Send commands to the running game's console.

Projects are stored in `Documents/HLAE Projects`, with a `project.json` file in each project folder. Demo files stay in their original location. Stream types are saved with the project; the full stream setup is not saved and restored yet.

The Overview and cmd Timeline pages are placeholders. The Kill button is not connected yet. The Console page sends commands and shows their send status; it does not show a live console log.

## Plans

The main goal is to cover the full HLAE FX workflow for CS2. Planned work includes:

- More controls for HLAE features and recording settings.
- A command timeline for running commands at chosen points in a demo.
- A useful project overview.
- Saving and restoring project settings and stream setups.
- Finishing the launcher and making installation paths fully configurable.

## Build

Qt Creator is recommended.

You need:

- Windows.
- Qt 6.10 or newer with Qt Quick. The included CMake presets use Qt 6.11.1.
- A matching C++ compiler, such as the MinGW kit from the Qt installer.
- CMake and Ninja, which can also be installed through the Qt installer.

### Qt Creator

1. Clone or download this repository.
2. Open `CMakeLists.txt` in Qt Creator.
3. Select a desktop Qt kit, such as Qt 6.11.1 MinGW 64-bit.
4. Configure the project and choose Debug or Release.
5. Build and run the `appqt_hlae` target.

### Command line

The included presets expect Qt at `C:/Qt/6.11.1/mingw_64`, MinGW at `C:/Qt/Tools/mingw1310_64`, and Ninja at `C:/Qt/Tools/Ninja`. Adjust `CMakePresets.json` if your installation uses different paths. The presets require CMake 3.25 or newer.

From the repository folder:

```powershell
cmake --preset qt-mingw-debug
cmake --build --preset qt-mingw-debug
```

Use `qt-mingw-release` in both commands for a release build. When running outside Qt Creator, the Qt and MinGW `bin` folders need to be on `PATH`, or the required runtime DLLs need to be deployed beside the executable.

## Running with CS2

HLAE, CS2, and Steam must be installed separately.

1. Open Settings and check the paths to `HLAE.exe` and `cs2.exe`.
2. Check the game launch arguments. The launcher requires `-insecure`.
3. Launch the game, then create or select a project using a CS2 demo file.
4. Load the project before using the Streams page. The game must be running and its console connection available for stream controls and console commands to work.

The launcher currently uses `C:/Program Files (x86)/HLAE/x64/AfxHookSource2.dll` and `C:/Program Files (x86)/Steam` as fixed paths in `qml/pages/LauncherPage.qml`. If HLAE or Steam is installed elsewhere, update those paths before building. Changing the executable paths in Settings does not change these two paths.
