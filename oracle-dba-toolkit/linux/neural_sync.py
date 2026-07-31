#!/usr/bin/env python3
"""
Neural Sync: Conecta Skills do Antigravity/Hermes e Repositórios Git ao Obsidian Vault
"""
import os
import shutil
import re
from pathlib import Path

OBSIDIAN_VAULT = Path("/home/pop/Documents/Obsidian Vault")
BRAIN_SKILLS_DIR = OBSIDIAN_VAULT / "01 - Brain / Skills"
GIT_REPOS_DIR = OBSIDIAN_VAULT / "02 - Repositories"

ANTIGRAVITY_SKILLS = Path("/home/pop/.gemini/config/plugins")
LOCAL_GIT_REPO = Path("/home/pop/oracle-dba-scripts")

def setup_directories():
    BRAIN_SKILLS_DIR.mkdir(parents=True, exist_ok=True)
    GIT_REPOS_DIR.mkdir(parents=True, exist_ok=True)

def sync_skills():
    print("🧠 Sincronizando Skills do Antigravity/Hermes para o Obsidian...")
    if not ANTIGRAVITY_SKILLS.exists():
        return
    
    for skill_path in ANTIGRAVITY_SKILLS.rglob("SKILL.md"):
        skill_name = skill_path.parent.name
        target_note = BRAIN_SKILLS_DIR / f"{skill_name}.md"
        
        content = skill_path.read_text(encoding="utf-8")
        
        # Adicionar conexões neuronais automáticas
        neural_header = f"""---
type: skill
agent: antigravity
name: {skill_name}
tags: [brain/skill, agent/antigravity]
---

# 🧠 Skill: [[{skill_name}]]

> **Conexões Neurais**: [[Antigravity Agent]], [[Obsidian Vault]], [[oracle-dba-toolkit]]

---

"""
        if not content.startswith("---"):
            full_content = neural_header + content
        else:
            full_content = neural_header + "\n" + content

        target_note.write_text(full_content, encoding="utf-8")
        print(f"  ✓ Neurônio criado/atualizado: {skill_name}.md")

def sync_git_docs():
    print("🔗 Sincronizando documentação do Git para o Obsidian...")
    toolkit_docs = LOCAL_GIT_REPO / "oracle-dba-toolkit" / "docs"
    target_dir = GIT_REPOS_DIR / "oracle-dba-toolkit" / "docs"
    target_dir.mkdir(parents=True, exist_ok=True)

    if toolkit_docs.exists():
        for doc_file in toolkit_docs.glob("*.md"):
            dest_file = target_dir / doc_file.name
            shutil.copy2(doc_file, dest_file)
            print(f"  ✓ Doc conectada: [[{doc_file.stem}]]")

if __name__ == "__main__":
    setup_directories()
    sync_skills()
    sync_git_docs()
    print("\n✨ Sincronização Neuronal Concluída! Abra o Graph View no Obsidian.")
