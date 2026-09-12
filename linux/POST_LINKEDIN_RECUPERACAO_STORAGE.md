# 📱 Post LinkedIn: Como uma simulação de fsck salvou 400 GB de dados (Visão de DBA)

---

🚨 **"O disco de dados não monta no boot": O que um susto com storage ensina sobre administração de bancos de missão crítica?**

Muita gente associa o trabalho do DBA apenas a SQL, planos de execução e tuning de instâncias. Mas a verdade é incontornável: **o banco de dados pisa no chão do Sistema Operacional e do Storage.** Se a infraestrutura falhar por baixo, não existe query que resolva.

Hoje enfrentei um incidente clássico em laboratório: após um particionamento indevido, uma partição ext4 de **620 GB** contendo quase **400 GB de backups e projetos** parou de montar. O boot travou no systemd com `[FAILED]`.

🔍 **O Diagnóstico:**
A partição física havia sido encolhida para **157 milhões de blocos**, mas o filesystem ainda esperava os **163 milhões originais**. Resultado: geometria inconsistente, superblocks dessincronizados e recusa total de montagem.

A tentação de muitos numa hora dessas é rodar comandos de força bruta (`fsck -fy`) para "tentar fazer montar logo". 

💡 **A Decisão que Salvou os Dados (A Mentalidade de DBA):**
Antes de qualquer alteração destrutiva, rodamos a verificação em **modo simulação somente-leitura (`e2fsck -fn`)**. 

O relatório na tela foi um soco no estômago: se tivéssemos forçado a partição menor com `-y`, o utilitário iria expurgar dezenas de gigabytes de diretórios vitais (`/Backup`, `/Projetos` e bases de teste) que haviam ficado na faixa cortada pelo redimensionamento.

🔧 **A Solução Técnica e Cirúrgica:**
1. **Inspeção de metadados:** Identificamos que o filesystem continha 40.960.000 inodes distribuídos em 5.000 grupos que não cabiam fisicamente no corte feito.
2. **Reversão de geometria:** Em vez de podar dados legítimos, recalculamos os setores GPT no `parted` e devolvemos a partição para o seu limite original de 163M blocos.
3. **Restauração de metadados:** Copiamos o superblock íntegro a partir dos blocos de backup do Grupo 1 (bloco 32768) diretamente para o bloco primário.
4. **Reparo consistente:** O `e2fsck` passou com sucesso por todas as 5 fases, reconstruindo os diretórios impactados.

Resultado: **Partição montada com sucesso e 100% dos 397 GB preservados intactos.**

🎯 **Principais lições para quem cuida de bancos de dados:**
1. **Nunca subestime o `-n` (no-write):** Antes de autorizar correções automáticas em storage ou filesystems, sempre simule o impacto.
2. **DBA precisa entender de Kernel e Storage:** LUNs, ASM, filesystems, offsets e tabelas de partição não são "assunto só do time de infra". Em incidentes graves, esse conhecimento economiza horas de downtime e evita perda de dados irreversível.
3. **Dados vêm primeiro:** Sistemas operacionais a gente reinstala em minutos; dados de negócio sem backup não voltam.

Documentei todos os passos técnicos, comandos de troubleshooting e scripts de validação no meu repositório:
👉 https://github.com/davlima/oracle-dba-scripts/blob/main/linux/RECUPERACAO_PARTICAO_EXT4.md

Já passou por uma situação onde um comando no terminal quase levou gigabytes de dados embora? Como foi a recuperação?

---
#OracleDBA #Linux #Storage #Sysadmin #DevOps #Database #DataRecovery #Infrastructure #ext4 #Troubleshooting
