# 📱 Post LinkedIn: Como uma simulação de fsck salvou 400 GB de dados (Visão de DBA)

---

🚨 **"O disco de dados não monta e o fsck aborta": O que um susto com storage ensina sobre administração de bancos de missão crítica?**

Muita gente associa o trabalho do DBA apenas a queries SQL, planos de execução e parâmetros de banco. Mas a verdade é uma só: **o banco de dados pisa no chão do Sistema Operacional e do Storage.** Se o filesystem ou a LUN corrompem por baixo, não existe query que resolva.

Hoje passei por um incidente real em laboratório: após um redimensionamento incorreto, uma partição ext4 de **620 GB** contendo quase **400 GB de backups, bases e projetos de estudo** simplesmente parou de montar.

🔍 **O Diagnóstico (Imagem 1):**
A partição física foi encolhida na tabela GPT para **157 milhões de blocos**, mas o filesystem ext4 ainda esperava os **163 milhões originais**. O `e2fsck`, `resize2fs` e `debugfs` recusavam qualquer operação acusando inconsistência crítica de geometria.

A primeira tentação de muitos numa crise é tentar forçar o sistema a aceitar o tamanho menor com comandos de reparo automático (`fsck -fy`). 

🔬 **A Engenharia Reversa (Imagem 2):**
Varremos os metadados do ext4 diretamente nos blocos do disco e localizamos as cópias de segurança do superblock no Grupo 1 (bloco 32768). O layout original estava intacto: eram 40.960.000 inodes distribuídos em 5.000 grupos que simplesmente não cabiam fisicamente no corte feito.

💡 **O Ponto de Virada: A Prudência do DBA (Imagem 3):**
Antes de qualquer alteração destrutiva, rodamos o teste em **modo simulação somente-leitura (`e2fsck -fn`)**.
O relatório na tela foi um banho de água fria: se tivéssemos forçado o reparo na partição cortada, o fsck iria expurgar dezenas de gigabytes de diretórios vitais (`/Backup`, `/DBAOCM`, `/Projetos`) que haviam ficado na faixa do espaço reduzido.

🔧 **A Solução Cirúrgica:**
1. Em vez de amputar os dados, recalculamos os limites na tabela GPT via `parted` e devolvemos a partição para o seu tamanho original de 163M blocos.
2. Restauramos o superblock íntegro do backup do Grupo 1 no bloco primário.
3. Executamos o `e2fsck`, que passou com sucesso por todas as 5 fases reparando apenas entradas de diretórios afetadas.

🏆 **O Resultado (Imagem 4):**
Partição `/dev/sdb9` montada em `/dados`, **100% dos 397 GB preservados intactos** com todas as pastas e bancos íntegros.

---
🎯 **3 Lições essenciais para quem cuida de bancos de dados:**
1. **Nunca subestime o modo `-n` (simulação):** Em momentos de crise, sempre simule o impacto antes de aprovar gravações destrutivas.
2. **DBA precisa dominar Linux e Storage:** Entender sobre LUNs, ASM, partições, superblocks e inodes separa o operador básico do especialista que salva o ambiente de um desastre.
3. **Dados vêm primeiro:** Sistemas operacionais a gente reinstala em 15 minutos; dados de negócio sem backup não voltam.

Documentei todos os passos técnicos, comandos e scripts no meu repositório:
👉 https://github.com/davlima/oracle-dba-scripts/blob/main/linux/RECUPERACAO_PARTICAO_EXT4.md

Já passou por uma situação de frio na barriga onde um comando quase levou gigabytes de dados embora? Como foi a recuperação?

---
#OracleDBA #Linux #Storage #Sysadmin #DevOps #Database #DataRecovery #Infrastructure #ext4 #Troubleshooting
