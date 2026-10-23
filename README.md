# Marsupi - Aplicativo Mobile (Flutter)

Aplicativo mobile do **Marsupi**, copiloto pedagógico inclusivo desenvolvido para o **Hackathon Fábrica de Software 2026 (IFC Araquari)** dentro do desafio *"Do Zero à Autonomia: 24H com IA"*.

O aplicativo permite que professores de Educação Infantil e Anos Iniciais registrem observações pedagógicas de rotina no celular, protejam os dados de seus alunos (LGPD) e gerem Planos de Intervenção e Atividades Adaptadas com apoio da IA generativa.

---

## 🚀 Tecnologias e Recursos

- **Flutter 3+** & **Dart 3+**
- **Material 3** habilitado (`useMaterial3: true`) com suporte a Dark Mode automático
- **Tipografia:** Google Fonts (`Inter`)
- **Comunicação HTTP:** Pacote `http` com tratamento de erros amigável (sem vazamento de erros técnicos para o professor)
- **Modelagem de Domínio:** Entidades `Aluno`, `Relatorio`, `Atividade` e compatibilidade com o backend Django
- **Permissões de Rede:** `android.permission.INTERNET` e `usesCleartextTraffic="true"` já configurados para desenvolvimento local

---

## 📁 Estrutura de Diretórios

```text
mobile/
├── android/app/src/main/AndroidManifest.xml  # Permissões de rede local (HTTP) e label Marsupi
├── lib/
│   ├── models/
│   │   ├── aluno_model.dart                  # Modelo Aluno (vínculo com Turma, Metadados e Pais)
│   │   ├── relatorio_model.dart              # Radar de competências e análise pedagógica da IA
│   │   ├── atividade_model.dart              # Atividades adaptadas e dinâmicas inclusivas
│   │   └── item_model.dart                   # Modelo Item (compatibilidade legado)
│   ├── services/
│   │   └── api_service.dart                  # Cliente HTTP e tratamento humanizado de erros
│   ├── screens/
│   │   ├── home_screen.dart                  # Listagem, pull-to-refresh e estados de tela
│   │   └── create_screen.dart                # Formulário com validação e teclado responsivo
│   └── main.dart                             # Entrypoint com identidade visual Marsupi (Teal)
├── test/
│   └── widget_test.dart                      # Teste de fumaça inicial
└── pubspec.yaml                              # Dependências do projeto
```

---

## ⚙️ Conectividade com a API Django

O serviço de API (`ApiService`) seleciona automaticamente o endpoint base conforme o ambiente:

| Ambiente | URL Base Padrão | Observação |
|---|---|---|
| **Android Emulator** | `http://10.0.2.2:8000/api` | Redireciona para o `localhost` da máquina host |
| **iOS Simulator** | `http://localhost:8000/api` | Roda nativamente no host |
| **Web / Desktop** | `http://localhost:8000/api` | Navegador ou app desktop |
| **Celular Físico** | `http://<SEU_IP_LOCAL>:8000/api` | IP do computador na mesma rede Wi-Fi |

> 💡 **Ajuste em Desenvolvimento:** No modo debug, pressionar longamente o título **"Marsupi"** na barra superior permite alterar o endereço da API em tempo de execução sem recompilar o app.

---

## 🛠️ Como Executar

```bash
# Obter dependências
flutter pub get

# Verificar conformidade e testes
flutter analyze
flutter test

# Rodar no Linux Desktop (teste instantâneo)
flutter run -d linux

# Rodar no Android
flutter run
```
