# 🛠️ Guia: Recuperação de Partição ext4 e Checagem de Badblock

> Guia prático para recuperar partições ext4 corrompidas (especialmente após redimensionamento incorreto) e verificar a saúde física de discos via SMART.

---

## 📋 Índice

- [Diagnóstico rápido](#-diagnóstico-rápido)
- [Cenário 1 — Filesystem maior que a partição](#-cenário-1--filesystem-maior-que-a-partição)
- [Cenário 2 — Superblock corrompido](#-cenário-2--superblock-corrompido)
- [Cenário 3 — Erros comuns de filesystem](#-cenário-3--erros-comuns-de-filesystem)
- [Checagem de Badblock e Saúde do Disco](#-checagem-de-badblock-e-saúde-do-disco)
- [Adicionar partição ao fstab](#-adicionar-partição-ao-fstab)
- [Ordem correta para redimensionar](#-ordem-correta-para-redimensionar)

---

## 🔍 Diagnóstico rápido

### Listar todos os discos e partições

```bash
lsblk -f
```

### Ver erros do kernel relacionados ao disco

```bash
sudo dmesg | grep -iE "sda|sdb|nvme|I/O error|buffer error" | tail -30
```

### Verificar estado do filesystem

```bash
sudo dumpe2fs -h /dev/sdXN | grep -E "state|error|block count|mount count"
```

> Substitua `/dev/sdXN` pelo device correto (ex: `/dev/sdb9`).

---

## 🚨 Cenário 1 — Filesystem maior que a partição

**Sintoma:** Após redimensionar, o `e2fsck` ou `mount` falham com:

```
O tamanho de filesystem (segundo o superblock) é XXXXXX blocks
O tamanho físico do device é de YYYYYY blocks
Ou o superblock ou a tabela de partição aparentam estar corrompidos!
```

**Causa:** A partição foi encolhida sem antes redimensionar o filesystem ext4.

### Passo 1 — Descobrir o tamanho físico real da partição

```bash
sudo e2fsck -f /dev/sdXN 2>&1 | grep "tamanho físico"
# Anote o número de blocks reportado (ex: 157467392)
```

Ou via `blockdev`:

```bash
sudo blockdev --getsz /dev/sdXN   # retorna em setores de 512 bytes
# divida por 8 para obter blocos de 4K
```

### Passo 2 — Patch direto no superblock (campo `blocks_count`)

O campo `s_blocks_count_lo` fica no **byte 1028** da partição.

**Verificar o valor atual:**

```bash
sudo dd if=/dev/sdXN bs=1 skip=1028 count=4 2>/dev/null | xxd
```

**Converter o novo tamanho para little-endian hex (Python):**

```python
import struct
n = 157467392  # substitua pelo seu valor
print(struct.pack('<I', n).hex())
# ex: 00c36209 → bytes: \x00\xC3\x62\x09
```

**Aplicar o patch:**

```bash
printf '\xBB\xBB\xBB\xBB' | sudo dd of=/dev/sdXN bs=1 seek=1028 count=4 conv=notrunc
# substitua \xBB\xBB\xBB\xBB pelos bytes do seu valor
```

**Verificar que foi aplicado:**

```bash
sudo dd if=/dev/sdXN bs=1 skip=1028 count=4 2>/dev/null | xxd
```

### Passo 3 — Corrigir o checksum do superblock

Após alterar `blocks_count`, o checksum CRC32C do superblock fica inválido. Use o script abaixo:

```python
#!/usr/bin/env python3
"""Corrige checksum CRC32C do superblock ext4 após patch de blocks_count."""
import struct, sys

DEVICE = '/dev/sdXN'   # <- altere para seu device
SB_OFF = 1024
BLOCKS_COUNT_OFF = 4
CHECKSUM_OFF = 0x3FC   # byte 1020

_T = []
for _i in range(256):
    _c = _i
    for _ in range(8):
        _c = (_c >> 1) ^ 0x82F63B78 if _c & 1 else _c >> 1
    _T.append(_c)

def crc32c_raw(data):
    """CRC32C sem XOR final — valor que o ext4 armazena."""
    crc = 0xFFFFFFFF
    for b in data:
        crc = (crc >> 8) ^ _T[(crc ^ b) & 0xFF]
    return crc

def crc32c_std(data):
    return crc32c_raw(data) ^ 0xFFFFFFFF

def read_sb(offset):
    with open(DEVICE, 'rb') as f:
        f.seek(offset); return bytearray(f.read(1024))

def compute(sb, fn):
    tmp = bytearray(sb)
    struct.pack_into('<I', tmp, CHECKSUM_OFF, 0)
    return fn(bytes(tmp[:CHECKSUM_OFF]))

# Identifica o algoritmo correto via backup superblock (block group 1)
bsb = read_sb(32768 * 4096 + 1024)
b_stored = struct.unpack_from('<I', bsb, CHECKSUM_OFF)[0]
fn = crc32c_raw if compute(bsb, crc32c_raw) == b_stored else crc32c_std
print(f"Algoritmo: {'sem XOR' if fn == crc32c_raw else 'com XOR'}")

# Corrige o superblock primário
psb = read_sb(SB_OFF)
if struct.unpack_from('<H', psb, 0x38)[0] != 0xEF53:
    print("ERRO: magic inválido!"); sys.exit(1)
new_csum = compute(psb, fn)
struct.pack_into('<I', psb, CHECKSUM_OFF, new_csum)
with open(DEVICE, 'r+b') as f:
    f.seek(SB_OFF); f.write(bytes(psb))
print(f"Novo checksum: 0x{new_csum:08X}")
print("Proximo: sudo e2fsck -fy /dev/sdXN")
```

```bash
sudo python3 fix_superblock.py
```

### Passo 4 — Reparar e montar

```bash
sudo e2fsck -fy /dev/sdXN
sudo mkdir -p /ponto-de-montagem
sudo mount /ponto-de-montagem
```

---

## 🔧 Cenário 2 — Superblock corrompido

Quando o superblock primário está corrompido mas os backups estão íntegros.

### Usar superblock de backup

```bash
# Localizar superblocks de backup disponíveis
sudo mke2fs -n /dev/sdXN

# Usar o backup (ex: bloco 32768)
sudo e2fsck -b 32768 /dev/sdXN
```

### Forçar escrita de superblock a partir do backup

```bash
sudo e2fsck -b 32768 -B 4096 /dev/sdXN
```

---

## 🔧 Cenário 3 — Erros comuns de filesystem

### Filesystem marcado como "dirty" / não desmontado corretamente

```bash
sudo e2fsck -f /dev/sdXN
```

### Reparar automaticamente sem interação

```bash
sudo e2fsck -fy /dev/sdXN
```

### Filesystem cheio impedindo montagem

```bash
# Montar read-only para resgatar dados
sudo mount -o ro /dev/sdXN /mnt/rescue

# Ver o que está ocupando espaço
du -sh /mnt/rescue/* | sort -rh | head -20
```

---

## 💾 Checagem de Badblock e Saúde do Disco

### Verificação rápida de todos os discos (SMART Health)

```bash
for disk in /dev/sda /dev/sdb /dev/nvme0n1; do
    echo "=== $disk ==="
    sudo smartctl -H $disk
done
```

Resultado esperado: `SMART overall-health self-assessment test result: PASSED`

### Relatório SMART completo por disco

```bash
sudo smartctl -a /dev/sda       # HD SATA 1
sudo smartctl -a /dev/sdb       # HD SATA 2
sudo smartctl -a /dev/nvme0n1   # SSD NVMe
```

### Atributos SMART críticos

| Atributo | Valor saudável | Significado |
|---|---|---|
| `Reallocated_Sector_Ct` | **0** | Setores defeituosos realocados |
| `Current_Pending_Sector` | **0** | Setores instáveis aguardando teste |
| `Offline_Uncorrectable` | **0** | Setores não corrigíveis — sinal grave |
| `Reallocated_Event_Count` | **0** | Número de eventos de realocação |
| `Spin_Retry_Count` (HDs) | **0** | Falhas ao girar o prato |

> ⚠️ Se qualquer um desses for **> 0**, faça backup imediato e considere substituir o disco.

### Extrair apenas os atributos críticos

```bash
sudo smartctl -a /dev/sdb | grep -E "Reallocated|Pending|Uncorrectable|Spin_Retry"
```

### Teste de superfície curto (~2 minutos)

```bash
sudo smartctl -t short /dev/sdb
# Aguarde e veja o resultado:
sudo smartctl -a /dev/sdb | grep -A 10 "SMART Self-test log"
```

### Teste de superfície longo (varre setor por setor — horas)

```bash
# Iniciar em background
sudo smartctl -t long /dev/sdb

# Acompanhar progresso
watch -n 60 'sudo smartctl -a /dev/sdb | grep -E "progress|remaining"'
```

### Badblock via `badblocks` (alternativa ao SMART)

```bash
# Somente leitura (não destrutivo) — pode demorar muito em discos grandes
sudo badblocks -sv /dev/sdb > ~/badblocks_sdb.txt 2>&1

# Ver resultado
cat ~/badblocks_sdb.txt
```

> ⚠️ Nunca rode `badblocks -w` (modo escrita) em um disco com dados — ele **apaga tudo**.

---

## 📝 Adicionar partição ao fstab

### Por UUID (recomendado — não muda se a ordem dos discos mudar)

```bash
# Descobrir o UUID
sudo blkid /dev/sdXN

# Adicionar ao fstab
echo 'UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /ponto  ext4  defaults  0  2' \
  | sudo tee -a /etc/fstab

# Recarregar e testar
sudo systemctl daemon-reload
sudo mount -a
```

### Verificar fstab sem reiniciar

```bash
sudo mount -a && echo "fstab OK" || echo "ERRO no fstab!"
```

---

## ✅ Ordem correta para redimensionar partição ext4

### Ao **ENCOLHER** a partição

```bash
# 1. Primeiro: encolher o filesystem
sudo resize2fs /dev/sdXN <novo_tamanho_em_blocos>

# 2. Depois: encolher a partição (GParted, parted, fdisk)
sudo parted /dev/sdX resizepart N <novo_fim>
```

### Ao **AUMENTAR** a partição

```bash
# 1. Primeiro: aumentar a partição (GParted, parted, fdisk)
sudo parted /dev/sdX resizepart N <novo_fim>

# 2. Depois: expandir o filesystem (sem tamanho = usa todo o espaço disponível)
sudo resize2fs /dev/sdXN
```

> 💡 O GParted geralmente faz ambos os passos automaticamente, mas em alguns casos pode pular o resize2fs. Sempre verifique após o redimensionamento.

---

## 🔗 Referências

- [ext4 Disk Layout — kernel.org](https://www.kernel.org/doc/html/latest/filesystems/ext4/index.html)
- [e2fsck manual](https://man7.org/linux/man-pages/man8/e2fsck.8.html)
- [smartmontools](https://www.smartmontools.org/)
- [badblocks manual](https://man7.org/linux/man-pages/man8/badblocks.8.html)
