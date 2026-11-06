#!/usr/bin/env python3
"""Build a deterministic, self-contained Roblox place with Python's stdlib.

Run: python3 scripts/build_place.py
For an immediately visible Edit scene, pass --scene artifacts/scene.json.
The scene snapshot is captured from the actual Studio world, not regenerated.
Without a snapshot the kitchen is constructed on Play instead.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
BOOTSTRAP = """-- Generated bootstrap: construct the kitchen before character spawning.
do
    local bootstrapPlayers = game:GetService("Players")
    local previousAutoLoads = bootstrapPlayers.CharacterAutoLoads
    bootstrapPlayers.CharacterAutoLoads = false
    local built, buildError = pcall(function()
        if not workspace:FindFirstChild("PizzaChiefWorld") then
            require(game:GetService("ServerStorage"):WaitForChild("BuildWorld"))
        end
    end)
    bootstrapPlayers.CharacterAutoLoads = previousAutoLoads
    if not built then
        error("Pizza Chief world build failed: " .. tostring(buildError))
    end
    if previousAutoLoads then
        for _, bootstrapPlayer in bootstrapPlayers:GetPlayers() do
            if not bootstrapPlayer.Character then
                task.spawn(function()
                    if bootstrapPlayer.Parent == bootstrapPlayers then
                        bootstrapPlayer:LoadCharacterAsync()
                    end
                end)
            end
        end
    end
end
-- End generated bootstrap. Original GameServer source follows unchanged.
"""


def prop(properties: ET.Element, kind: str, name: str, value: str) -> None:
    ET.SubElement(properties, kind, {"name": name}).text = value


def item(parent: ET.Element, class_name: str, name: str, ref: str) -> ET.Element:
    element = ET.SubElement(parent, "Item", {"class": class_name, "referent": ref})
    properties = ET.SubElement(element, "Properties")
    prop(properties, "string", "Name", name)
    return element


def properties(element: ET.Element) -> ET.Element:
    result = element.find("Properties")
    assert result is not None
    return result


def script(parent: ET.Element, class_name: str, name: str, ref: str, source: str) -> None:
    element = item(parent, class_name, name, ref)
    prop(properties(element), "ProtectedString", "Source", source)
    if class_name != "ModuleScript":
        prop(properties(element), "bool", "Disabled", "false")


def scene_property(parent: ET.Element, class_name: str, name: str, data: dict) -> None:
    """Encode Studio property values using Roblox XML's serialization names.

    Part aliases: github.com/rojo-rbx/rbx-dom/blob/master/patches/parts.yml
    Value format: github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md
    """
    kind, value = data["type"], data["value"]
    is_part = class_name in {"Part", "SpawnLocation"}
    if is_part and name == "Color":
        channels = [max(0, min(255, round(c * 255))) for c in value]
        packed = (255 << 24) | (channels[0] << 16) | (channels[1] << 8) | channels[2]
        prop(parent, "Color3uint8", "Color3uint8", str(packed))
        return
    if is_part and name == "Size":
        name = "size"
    if class_name == "Part" and name == "Shape":
        name = "shape"
    if kind == "boolean":
        prop(parent, "bool", name, "true" if value else "false")
    elif kind == "number":
        scalar = "int" if name in {"BorderSizePixel", "ZIndex", "Duration"} else "float"
        prop(parent, scalar, name, str(int(value) if scalar == "int" else value))
    elif kind in {"string", "token"}:
        prop(parent, kind, name, str(value))
    elif kind == "BrickColor":
        prop(parent, "int", name, str(value))
    else:
        tags = {
            "Vector3": ("Vector3", ("X", "Y", "Z")),
            "Vector2": ("Vector2", ("X", "Y")),
            "Color3": ("Color3", ("R", "G", "B")),
            "CFrame": ("CoordinateFrame", ("X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22")),
            "UDim": ("UDim", ("S", "O")),
            "UDim2": ("UDim2", ("XS", "XO", "YS", "YO")),
        }
        assert kind in tags, f"Unsupported snapshot type: {kind}"
        tag, components = tags[kind]
        element = ET.SubElement(parent, tag, {"name": name})
        assert len(components) == len(value)
        for component, number in zip(components, value):
            ET.SubElement(element, component).text = str(number)


def scene_item(parent: ET.Element, entry: dict, counter: list[int], ref: str | None = None) -> ET.Element:
    counter[0] += 1
    element = item(parent, entry["class"], entry["name"], ref or f"RBX_Scene_{counter[0]}")
    # HttpService encodes an empty Luau table as [], including Model properties.
    for name, value in sorted((entry["properties"] or {}).items()):
        scene_property(properties(element), entry["class"], name, value)
    for child in entry["children"]:
        scene_item(element, child, counter)
    return element


def build(output: Path, scene_path: Path | None = None) -> None:
    sources = {
        "Recipes": (ROOT / "src/shared/Recipes.luau").read_bytes(),
        "GameRules": (ROOT / "src/shared/GameRules.luau").read_bytes(),
        "ProfileStore": (ROOT / "src/server/ProfileStore.luau").read_bytes(),
        "GameServer": (ROOT / "src/server/GameServer.server.luau").read_bytes(),
        "PizzaClient": (ROOT / "src/client/PizzaClient.client.luau").read_bytes(),
        "BuildWorld": (ROOT / "src/studio/BuildWorld.luau").read_bytes(),
    }
    text = {name: content.decode("utf-8") for name, content in sources.items()}
    root = ET.Element("roblox", {"version": "4"})
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    # The kitchen owns the full-screen UI; do not insert the deprecated chat
    # framework, which races CoreGui startup in multi-client Studio sessions.
    chat = item(root, "Chat", "Chat", "RBX_Chat")
    prop(properties(chat), "bool", "LoadDefaultChat", "false")
    workspace = item(root, "Workspace", "Workspace", "RBX_Workspace")
    scene_count = [0]
    if scene_path:
        scene = json.loads(scene_path.read_text(encoding="utf-8"))
        assert scene["version"] == 1
        scene_item(workspace, scene["world"], scene_count)
        scene_item(workspace, scene["camera"], scene_count, "RBX_EditCamera")
        prop(properties(workspace), "Ref", "CurrentCamera", "RBX_EditCamera")
        scene_item(root, scene["lighting"], scene_count, "RBX_Lighting")
    else:
        item(root, "Lighting", "Lighting", "RBX_Lighting")
    item(root, "Players", "Players", "RBX_Players")
    replicated = item(root, "ReplicatedStorage", "ReplicatedStorage", "RBX_ReplicatedStorage")
    shared = item(replicated, "Folder", "PizzaChief", "RBX_PizzaChief")
    script(shared, "ModuleScript", "Recipes", "RBX_Recipes", text["Recipes"])
    script(shared, "ModuleScript", "GameRules", "RBX_GameRules", text["GameRules"])
    server = item(root, "ServerScriptService", "ServerScriptService", "RBX_ServerScriptService")
    script(server, "ModuleScript", "ProfileStore", "RBX_ProfileStore", text["ProfileStore"])
    script(server, "Script", "GameServer", "RBX_GameServer", BOOTSTRAP + text["GameServer"])
    storage = item(root, "ServerStorage", "ServerStorage", "RBX_ServerStorage")
    script(storage, "ModuleScript", "BuildWorld", "RBX_BuildWorld", text["BuildWorld"])
    starter = item(root, "StarterPlayer", "StarterPlayer", "RBX_StarterPlayer")
    player_scripts = item(starter, "StarterPlayerScripts", "StarterPlayerScripts", "RBX_StarterPlayerScripts")
    script(player_scripts, "LocalScript", "PizzaClient", "RBX_PizzaClient", text["PizzaClient"])
    gui = item(root, "StarterGui", "StarterGui", "RBX_StarterGui")
    # Verified against Enum.ScreenOrientation.LandscapeSensor.Value in Studio.
    prop(properties(gui), "token", "ScreenOrientation", "2")
    item(root, "SoundService", "SoundService", "RBX_SoundService")
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(root).write(output, encoding="utf-8", xml_declaration=True)

    # Parse the written file and prove every embedded source survived byte-exactly.
    parsed = ET.parse(output).getroot()
    verified = 0
    for element in parsed.iter("Item"):
        props = element.find("Properties")
        if props is None:
            continue
        source = props.find("ProtectedString[@name='Source']")
        if source is None:
            continue
        name_element = props.find("string[@name='Name']")
        assert name_element is not None and name_element.text in sources
        name = name_element.text
        embedded = source.text or ""
        if name == "GameServer":
            assert embedded.startswith(BOOTSTRAP), "Bootstrap differs after XML serialization"
            embedded = embedded[len(BOOTSTRAP):]
        assert embedded.encode("utf-8") == sources[name], f"Source mismatch: {name}"
        verified += 1
    assert verified == len(sources), "One or more source scripts are missing"
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    print(f"Built {output.relative_to(ROOT) if output.is_relative_to(ROOT) else output}")
    if scene_path:
        print(f"Embedded {scene_count[0]} captured scene instances from {scene_path}")
    print(f"Verified {verified} embedded source files byte-for-byte; SHA-256 {digest}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist/PizzaChief.rbxlx")
    parser.add_argument("--scene", type=Path, help="Live Studio JSON snapshot from scripts/export_scene.luau")
    args = parser.parse_args()
    target = args.output.resolve()
    if target == ROOT / "PizzaChief.rbxlx" and not args.scene:
        parser.error("A root place requires --scene so it opens with the captured visible world")
    build(target, args.scene.resolve() if args.scene else None)
