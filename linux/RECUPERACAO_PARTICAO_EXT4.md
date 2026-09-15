# 🛠️ Guia: Recuperação de Partição ext4 e Checagem de Badblock

> Guia prático para recuperar partições ext4 corrompidas (especialmente após redimensionamento incorreto) e verificar a saúde física de discos via SMART.

---

## 📋 Índice

- [Diagnóstico rápido](#-diagnóstico-rápido)[cite: 4]
- [Cenário 1 — Filesystem maior que a partição](#-cenário-1--filesystem-maior-que-a-partição)[cite: 4]
- [Cenário 2 — Superblock corrompido](#-cenário-2--superblock-corrompido)[cite: 4]
- [Cenário 3 — Erros comuns de filesystem](#-cenário-3--erros-comuns-de-filesystem)[cite: 4]
- [Checagem de Badblock e Saúde do Disco](#-checagem-de-badblock-e-saúde-do-disco)[cite: 4]
- [Adicionar partição ao fstab](#-adicionar-partição-ao-fstab)[cite: 4]
- [Ordem correta para redimensionar](#-ordem-correta-para-redimensionar)[cite: 4]

---

## 🔍 Diagnóstico rápido

### Listar todos os discos e partições

```bash
lsblk -f