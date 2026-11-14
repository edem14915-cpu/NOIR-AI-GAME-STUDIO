import os
import re
import json
import argparse
from pathlib import Path

import httpx
from dotenv import load_dotenv

HOME = Path.home()
load_dotenv(HOME / "NOIR_AI" / ".env", override=True)

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL = "gemini-3.5-flash"

API_URL = (
    f"https://generativelanguage.googleapis.com/v1beta/"
    f"models/{MODEL}:generateContent"
)

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "output"


def safe_name(name):
    name = re.sub(r"[^a-zA-Z0-9_-]", "_", name)
    return name.strip("_")[:50] or "NOIR_Game"


def ask_gemini(description):
    if not API_KEY:
        raise RuntimeError("GEMINI_API_KEY не найден в ~/NOIR_AI/.env")

    system = """
Ты — профессиональный разработчик игр на Godot 4.4.
Создавай полноценные небольшие игровые проекты.
Используй GDScript 2.0.
Для Android предпочитай мобильный рендерер и сенсорное управление.
Не используй платные ассеты и внешние зависимости.

Верни ТОЛЬКО JSON следующего формата:
{
  "project_name": "название",
  "files": [
    {
      "path": "project.godot",
      "content": "содержимое файла"
    }
  ]
}

Обязательно создай project.godot, главную сцену .tscn
и все необходимые скрипты .gd.
Пути должны быть относительными от корня проекта.
Не используй Markdown и блоки кода.
Не создавай бинарные файлы.
"""

    payload = {
        "system_instruction": {
            "parts": [{"text": system}]
        },
        "contents": [{
            "role": "user",
            "parts": [{"text": description}]
        }],
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 8192,
            "responseMimeType": "application/json"
        }
    }

    with httpx.Client(timeout=180) as client:
        response = client.post(
            API_URL,
            headers={"x-goog-api-key": API_KEY},
            json=payload
        )

    if response.status_code != 200:
        raise RuntimeError(
            f"Gemini HTTP {response.status_code}: "
            f"{response.text[:1500]}"
        )

    data = response.json()
    text = data["candidates"][0]["content"]["parts"][0]["text"]
    return json.loads(text)


def create_project(data):
    project_name = safe_name(data.get("project_name", "NOIR_Game"))
    project_dir = OUTPUT / project_name
    project_dir.mkdir(parents=True, exist_ok=True)

    files = data.get("files", [])

    if not files or len(files) > 30:
        raise ValueError("Некорректное количество файлов")

    total_size = 0

    for item in files:
        relative = Path(item["path"])

        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError("Недопустимый путь файла")

        content = item["content"]

        if not isinstance(content, str):
            raise ValueError("Содержимое файла должно быть текстом")

        total_size += len(content.encode("utf-8"))

        if total_size > 2_000_000:
            raise ValueError("Проект превышает лимит 2 МБ")

        target = project_dir / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    if not (project_dir / "project.godot").exists():
        raise ValueError("Gemini не создал project.godot")

    return project_dir


def main():
    parser = argparse.ArgumentParser(
        description="NOIR AI Godot Game Generator"
    )
    parser.add_argument(
        "prompt",
        help="Описание игры"
    )
    args = parser.parse_args()

    print("[NOIR] Проектируем игру...")
    data = ask_gemini(args.prompt)

    print("[NOIR] Создаём файлы Godot...")
    project = create_project(data)

    print(f"[NOIR] Проект создан: {project}")
    print("[NOIR] Проверь проект в Godot перед экспортом APK.")


if __name__ == "__main__":
    main()
