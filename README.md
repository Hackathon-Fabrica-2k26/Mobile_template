# Marsupi - Aplicativo Mobile (Flutter)

Aplicativo mobile oficial do **Marsupi**, copiloto pedagógico inclusivo desenvolvido para o **Hackathon Fábrica de Software 2026 (IFC Araquari)** no desafio *"Do Zero à Autonomia: 24H com IA"*.

O **Marsupi** apoia educadores na rotina escolar, simplificando a identificação rápida de turmas, o acompanhamento do desenvolvimento de cada estudante, o envio e análise de produções pedagógicas e o suporte personalizado a necessidades educacionais específicas (AEE).

---

## 📱 Fluxo Principal da Aplicação

O aplicativo segue estritamente a experiência desenhada no Figma e integrada à API REST:

1. **Acesso Seguro (Matrícula + OTP):**
   - Autenticação em duas etapas via matrícula do professor e senha institucional.
   - Validação imediata com código OTP de 4 dígitos enviado por e-mail, garantindo conformidade com a LGPD.
2. **Minhas Turmas:**
   - Painel inicial com busca rápida de turmas (`Buscar turma`), contagem de estudantes e turno (`Manhã`, `Tarde`, `Integral`).
3. **Cadastro de Turma com Foto da Chamada (OCR de Nomes):**
   - **Etapa 1:** Dados da turma (`Nome`, `Ano letivo`, `Turno`) e captura/envio da foto da lista de presença.
   - **Etapa 2:** Conferência inteligente dos nomes reconhecidos pelo OCR, permitindo editar nomes destacados em dúvida e adicionar novos antes de confirmar.
4. **Detalhes da Turma e Estudantes:**
   - Visualização com banner pedagógico da turma.
   - Estado vazio (*"Nenhum aluno cadastrado"*) convidando ao envio da foto da chamada ou listagem compacta com iniciais de cada aluno.
   - Seção integrada de atividades da turma no mesmo fluxo rolável.
5. **Detalhes do Estudante e Perfil de Apoio:**
   - Ficha do aluno com matrícula, idade/nascimento, status ativo e observações de acompanhamento.
   - Histórico de atividades entregues e opção de exportação de relatórios consolidados.
6. **Envio de Atividades e Trabalhos:**
   - Envio de produções pedagógicas (fotos ou arquivos PDF/JPG/PNG), com dados de turma, título e anotações para análise pedagógica automatizada.

---

## 🏛️ Arquitetura e Modelagem de Dados (`lib/models/`)

A modelagem de dados foi totalmente alinhada ao contrato atual do backend Django REST, eliminando campos legados (como referências a Pais/DISC):

- **`Turma`** ([turma_model.dart](lib/models/turma_model.dart)): id, nome, turno (`manha`, `tarde`, `integral`), total de estudantes e escola vinculada.
- **`Aluno`** ([aluno_model.dart](lib/models/aluno_model.dart)): identificador, nome, vínculo obrigatório com `turmaId`, matrícula, status, acompanhamento e `PerfilApoio`.
- **`PerfilApoio`** ([perfil_apoio_model.dart](lib/models/perfil_apoio_model.dart)): resumo de desenvolvimento, métricas de radar pedagógico, pontos fortes, necessidades de apoio e dicas de autonomia.
- **`Atividade`** ([atividade_model.dart](lib/models/atividade_model.dart)): título da proposta pedagógica, tipo, turma, data de aplicação e total de relatórios.
- **`Trabalho`** ([trabalho_model.dart](lib/models/trabalho_model.dart)): envio de arquivos de produções dos estudantes (por foto ou upload), status de OCR e flag de conferência.
- **`Relatorio`** ([relatorio_model.dart](lib/models/relatorio_model.dart)): parecer e análise gerada pela IA vinculada ao estudante e à atividade.

---

## ⚙️ Conectividade e Execução

O cliente de rede ([api_service.dart](lib/services/api_service.dart)) opera em modo híbrido:
- Conecta-se aos endpoints REST autenticados via JWT (`/api/auth/login/`, `/api/auth/otp/verify/`, `/api/turmas/`, `/api/alunos/`, `/api/atividades/`).
- Consome **exclusivamente dados do backend** (sem mocks nem fallback offline): se o servidor estiver inacessível, as telas exibem a mensagem de erro e a opção "Tentar novamente".

### Configurando a URL da API em Tempo de Compilação

Para apontar o aplicativo para o backend desejado (servidor local, emulador ou produção), utilize a flag `--dart-define=API_URL=...`:

```bash
# Rodar apontando para o backend local na máquina host
flutter run --dart-define=API_URL=http://127.0.0.1:8000

# Rodar no Emulador Android (o emulador acessa o host via 10.0.2.2)
flutter run --dart-define=API_URL=http://10.0.2.2:8000

# Rodar em dispositivo físico na mesma rede local
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

Se `--dart-define=API_URL` for omitido, o aplicativo usa a **API de produção** (`https://api.delta.fabricadesoftware.ifc.edu.br`). Para desenvolver contra o backend local, passe o `--dart-define` como acima.

---

## 🛠️ Comandos de Verificação e Testes

```bash
# Obter dependências
flutter pub get

# Análise estática (linter e tipagem estrita)
flutter analyze

# Execução da suíte de testes unitários e de widgets
flutter test
```
