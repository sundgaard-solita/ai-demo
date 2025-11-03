#!/usr/bin/env python3
"""
Tiny local reasoning agent that talks to itself.
Requires a local model server (e.g. Ollama running `ollama serve`).
"""

import requests, json

MODEL_URL = "http://localhost:11434/api/chat"  # default Ollama endpoint
MODEL_NAME = "phi3:mini"


def think(prompt: str, history=None):
    messages = (history or []) + [{"role": "user", "content": prompt}]
    resp = requests.post(
        MODEL_URL, json={"model": MODEL_NAME, "messages": messages, "stream": False}
    )
    data = resp.json()
    return data["message"]["content"].strip()


def self_reason(task: str, max_steps=3):
    log = []
    thought = f"Goal: {task}"
    for step in range(max_steps):
        reply = think(thought, log)
        print(f"\n🧠 Step {step+1}: {reply}")
        log.append({"role": "assistant", "content": reply})
        if "done" in reply.lower():  # crude stop signal
            break
        thought = f"Reflect and improve on: {reply}"
    return log[-1]["content"]


if __name__ == "__main__":
    task = input("What should I do? ")
    result = self_reason(task)
    print("\n✅ Final result:", result)
