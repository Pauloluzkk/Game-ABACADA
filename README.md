# Game-ABACADA 🤖

Um jogo educacional interativo desenvolvido em Godot 4.x, projetado especificamente para auxiliar no processo de alfabetização de alunos de APAEs e centros educacionais, utilizando a poderosa metodologia **ABACADA**.

## 📖 Contribuições Pedagógicas (Método ABACADA)

O método ABACADA tem como premissa a facilitação da leitura através de famílias silábicas regulares e associação fonética direta. Este jogo digitaliza e potencializa esse processo, focado no público da educação especial:

- **Associação Multissensorial (Áudio e Visual):** A criança escuta o fonema exato da sílaba ao tocá-la, amarrando o estímulo auditivo à representação escrita.
- **Feedback Corretivo Imediato:** O sistema de tentativa e erro é ativo. Sílabas erradas piscam em vermelho e rejeitam o encaixe (com som de erro), orientando o aluno suavemente sem causar frustração estática.
- **Recompensa Lúdica Constante:** A montagem gradativa do "Robô" serve como métrica visual de progresso, mantendo o aluno engajado até a conclusão da tarefa.
- **Conteúdo Flexível e Personalizado:** Como o jogo se alimenta de uma API externa, os educadores podem adaptar as palavras e imagens de acordo com o nível e a realidade do aluno, promovendo uma educação verdadeiramente inclusiva.

## ⚙️ Funcionalidades Técnicas

- **Engine:** Godot Engine 4.x (GDScript).
- **Consumo de API:** Faz requisições HTTP para carregar JSON, texturas (PNG) e áudios (OGG) dinamicamente de um banco de dados local (Docker).
- **Mecânicas:**
  - Drag & Drop (Arrastar e Soltar) com verificação geométrica inteligente.
  - Geração de "distrações" silábicas com base em outras palavras da base de dados.
  - UI Global com AutoLoad para persistência de som e envio de relatórios de desempenho (`Global.erros`, `TempoDeJogo`).

## 🚀 Como Rodar o Projeto

1. Certifique-se de que a API local de palavras e imagens (Docker) esteja rodando na porta `8080`.
2. Importe o projeto no **Godot 4**.
3. Pressione `F5` para iniciar o jogo (o carregamento começará a partir da `Intro.tscn`).
