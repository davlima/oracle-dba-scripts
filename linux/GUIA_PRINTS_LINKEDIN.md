# 📸 Guia de Prints para o Post do LinkedIn

Para não sobrecarregar sua postagem com dezenas de telas, o ideal é usar **2 a 3 imagens selecionadas** (ou montar uma imagem comparativa tipo "Antes vs Depois" / carrossel de 2 a 3 slides).

Abaixo estão os trechos exatos do seu terminal que contam a história com impacto:

---

### 📷 Imagem 1: O "Problema / Frio na Barriga" (O Erro)
**Objetivo:** Mostrar o momento em que a ferramenta tradicional falha e assusta quem está operando.

**O que capturar:**
```bash
pop@pop-os:~$ sudo e2fsck -f /dev/sdb9
e2fsck 1.47.0 (5-Feb-2023)
O tamanho de filesystem (segundo o superblock) é 163821568 blocks
O tamanho físico do device é de 157467392 blocks
Ou o superblock ou a tabela de partição aparentam estar corrompidos!
Abortar<y>?
```
> 💡 **Dica de edição:** Coloque um retângulo ou destaque vermelho nas duas linhas dos números de blocos (`163821568` vs `157467392`). É isso que chama a atenção técnica no feed.

---

### 📷 Imagem 2: A "Intervenção Cirúrgica" (O Diagnóstico de Baixo Nível)
**Objetivo:** Demonstrar domínio técnico avançado — mexer diretamente nos bytes do disco e no superblock.

**O que capturar:**
```bash
pop@pop-os:~$ sudo dd if=/dev/sdb9 bs=1 skip=1028 count=4 2>/dev/null | xxd
00000000: 00b8 c309                                ....

pop@pop-os:~$ printf '\x00\xC3\x62\x09' | sudo dd of=/dev/sdb9 bs=1 seek=1028 count=4 conv=notrunc
4+0 records in
4+0 records out
4 bytes copied, 0.000597772 s, 6.7 kB/s

pop@pop-os:~$ sudo dd if=/dev/sdb9 bs=1 skip=1028 count=4 2>/dev/null | xxd
00000000: 00c3 6209                                ..b.
```
> 💡 **Dica de edição:** Mostra a transição de `00b8 c309` para `00c3 6209` (o ajuste do little-endian). Isso mostra na prática que não foi um "clique de botão", foi engenharia reversa de filesystem.

---

### 📷 Imagem 3: O "Sucesso / Validação" (A Solução)
**Objetivo:** Provar que funcionou, o filesystem foi validado e montado com sucesso.

**O que capturar:**
A validação do checksum calculada contra o backup superblock + o `df -h /dados` montado:
```bash
Magic        : 0xEF53
blocks_count : 157467392
✅ Superblock atualizado com sucesso!

pop@pop-os:~$ df -h /dados
Sist. Arq.      Tam. Usado Disp. Uso% Montado em
/dev/sdb9       590G  ...   ...    ... /dados
```
> 💡 **Dica de edição:** Um destaque verde no `✅` e no `/dados` montado no `df -h`.

---

### 🎨 Formatos recomendados no LinkedIn:
1. **Formato Carrossel (PDF de 3 slides):** Cada print em um slide com um título curto em cima (Ex: Slide 1: *"O Erro"*, Slide 2: *"A Cirurgia nos Metadados"*, Slide 3: *"A Recuperação"*). Carrossel tem o maior alcance orgânico no LinkedIn atualmente.
2. **Imagem Única Dividida (Collage):** Lado esquerdo o print do Erro (com destaque vermelho), lado direito a solução (com destaque verde).
