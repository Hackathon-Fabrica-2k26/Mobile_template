# Mobile Template (Flutter)

Template boilerplate inicial para desenvolvimento mobile com **Flutter (Dart)** no hackathon. Focado em agilidade, com zero atrito de configuração, design moderno com **Material 3**, cliente HTTP pronto e CRUD genérico de exemplo integrado à API Django REST Framework.

---

## 🚀 Tecnologias e Recursos

- **Flutter 3+** & **Dart 3+**
- **Material 3** habilitado (`useMaterial3: true`) com suporte a Dark Mode automático
- **Tipografia:** Google Fonts (`Inter`)
- **Comunicação HTTP:** Pacote `http` com chaveamento dinâmico de URL base
- **Gerenciamento de Estado Direto:** `StatefulWidget` com `setState` e `FutureBuilder` (rápido e sem boilerplate)
- **Permissões de Rede:** `android.permission.INTERNET` e `usesCleartextTraffic="true"` já configurados para desenvolvimento local

---

## 📁 Estrutura de Diretórios

```text
mobile/
├── android/app/src/main/AndroidManifest.xml  # Permissões de rede local (HTTP)
├── lib/
│   ├── models/
│   │   └── item_model.dart                   # Modelo Item (compatível com DRF)
│   ├── services/
│   │   └── api_service.dart                  # Cliente HTTP, chaveamento de URL e CRUD
│   ├── screens/
│   │   ├── home_screen.dart                  # Listagem, FutureBuilder, pull-to-refresh e deleção
│   │   └── create_screen.dart                # Formulário com validação e teclado responsivo
│   └── main.dart                             # Entrypoint, tema Material 3 e Google Fonts
├── test/
│   └── widget_test.dart                      # Teste de fumaça inicial
└── pubspec.yaml                              # Dependências do projeto
```

---

## ⚙️ Conectividade e Endpoints da API

O serviço de API (`ApiService`) seleciona automaticamente a URL adequada conforme a plataforma:

| Ambiente | URL Base Padrão | Observação |
|---|---|---|
| **Android Emulator** | `http://10.0.2.2:8000/api` | Redireciona para o `localhost` da máquina host |
| **iOS Simulator** | `http://localhost:8000/api` | Roda nativamente no host |
| **Web / Desktop** | `http://localhost:8000/api` | Navegador ou app desktop |
| **Celular Físico** | `http://<SEU_IP_LOCAL>:8000/api` | Configure o IP do seu computador na rede Wi-Fi |

> 💡 **Dica durante o Hackathon:** No canto superior direito da tela inicial do app, há um ícone de engrenagem ⚙️ que permite alterar a URL da API em tempo de execução sem precisar recompilar o aplicativo!

### Endpoints Consumidos (Padrão Backend DRF)

- `GET /api/items/`: Listagem de itens (suporta formato paginado DRF `results: [...]` ou lista direta)
- `POST /api/items/`: Criação de novo item (`title`, `description`, `done`)
- `PATCH /api/items/<id>/`: Atualização parcial de item (usado no toggle de concluído)
- `DELETE /api/items/<id>/`: Exclusão de item

---

## 🛠️ Como Executar

### 1. Obter dependências
```bash
flutter pub get
```

### 2. Verificar código e testes
```bash
flutter analyze
flutter test
```

### 3. Rodar o aplicativo

- **No emulador Android conectado:**
  ```bash
  flutter run
  ```

- **No navegador Chrome (para testes rápidos de UI):**
  ```bash
  flutter run -d chrome
  ```

- **Listar dispositivos disponíveis:**
  ```bash
  flutter devices
  ```

---

## 🔗 Integração com o Backend Django

Ao rodar o backend local (`Backend_template`), certifique-se de que:
1. O backend está escutando em `0.0.0.0:8000` ou `localhost:8000`.
2. Se testar no celular físico, garanta que computador e celular estejam no mesmo Wi-Fi.
3. No `.env` do backend, `CORS_ALLOW_ALL_ORIGINS = True` e `AUTH_DISABLED=True` (em modo debug) facilitam o consumo imediato sem necessidade de login prévio.
