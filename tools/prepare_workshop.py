"""Prepare or check this mod's native PZ Workshop upload directory; never contacts Steam."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import struct

ROOT = Path(__file__).resolve().parents[1]
NAME = "SuQingGunWeightCharms"
MOD_FOLDER = "PetGunWeightKits_4221_Local"
SOURCE = ROOT / "mods" / MOD_FOLDER
PUBLISHING = ROOT / "publishing"
MOD_ID = "Codex_PetGunWeightKits_4221"


def require(ok, message):
    if not ok:
        raise ValueError(message)


def files(root):
    result = {}
    for path in sorted(root.rglob("*")):
        require(not path.is_symlink(), "Linked content is unsupported")
        if path.is_file():
            result[path.relative_to(root).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result


def validate(destination):
    mod = destination / "Contents" / "mods" / MOD_FOLDER
    require(files(mod) == files(SOURCE), "Staged mod differs from repository source")
    require((mod / "common").is_dir(), "Missing Build 42 common directory")
    info = dict(line.split("=", 1) for line in (mod / "42/mod.info").read_text("utf-8-sig").splitlines() if "=" in line)
    require(info.get("id") == MOD_ID and info.get("require") == "ModernFirearmsSystem", "Unexpected mod or dependency")
    raw = (destination / "preview.png").read_bytes()
    require(raw[:8] == b"\x89PNG\r\n\x1a\n" and raw[12:16] == b"IHDR", "Preview must be PNG")
    width, height = struct.unpack(">II", raw[16:24])
    require(width == height and width in (256, 512) and len(raw) <= 1024000, "Invalid native Workshop preview")
    for path in mod.rglob("*"):
        require(path.suffix.lower() not in {".exe", ".dll", ".bat", ".ps1", ".zip", ".so", ".sh"}, "Unexpected executable or archive in mod")
        if path.suffix.lower() == ".json":
            json.loads(path.read_bytes())
    settings = (destination / "workshop.txt").read_text("utf-8-sig")
    require("真实性与平衡性" in settings and "谨慎添加" in settings and "屯屯鼠" in settings, "Missing prominent balance warning")
    metadata = json.loads((PUBLISHING / "workshop.json").read_text("utf-8"))
    if metadata.get("publishedfileid"):
        ids = [line.removeprefix("id=") for line in settings.splitlines() if line.startswith("id=")]
        require(ids == [str(metadata["publishedfileid"])], "Staged Workshop ID differs from published item; do not create a duplicate")
    return {"result": "PASS", "folder": str(destination), "mod_id": MOD_ID, "version": info["modversion"],
            "mod_files": len(files(mod)), "preview_size": [width, height], "preview_bytes": len(raw),
            "runtime_tested": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path.home() / "Zomboid" / "Workshop" / NAME)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    destination = args.output.expanduser().resolve()
    if not args.check:
        require(destination.parent.name == "Workshop" and destination.name == NAME, "Output must end in Workshop/" + NAME)
        require(not destination.exists(), "Upload directory exists: preserve its assigned ID and update deliberately, or use --check")
        metadata = json.loads((PUBLISHING / "workshop.json").read_text("utf-8"))
        description = (PUBLISHING / "description.bbcode.txt").read_text("utf-8").strip()
        lines = ["version=1"]
        if metadata.get("publishedfileid"):
            require(str(metadata["publishedfileid"]).isdigit() and int(metadata["publishedfileid"]) > 0, "Invalid published ID")
            lines.append("id=" + str(metadata["publishedfileid"]))
        lines.append("title=" + metadata["title"])
        lines += ["description=" + line for line in description.splitlines()]
        lines += ["tags=" + ";".join(metadata["tags"]), "visibility=" + metadata["visibility"], ""]
        destination.mkdir(parents=True)
        shutil.copytree(SOURCE, destination / "Contents" / "mods" / MOD_FOLDER)
        shutil.copy2(PUBLISHING / "preview.png", destination / "preview.png")
        shutil.copy2(PUBLISHING / "changenote.txt", destination / "changenote.txt")
        (destination / "workshop.txt").write_text("\n".join(lines), encoding="utf-8", newline="\n")
    print(json.dumps(validate(destination), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
