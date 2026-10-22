# CONTEXTO DO PROJETO - HACKATHON 24H (STARTER TEMPLATE)

## 1. Visão Geral e Objetivo
Este repositório é um **template boilerplate unificado** para um hackathon presencial de 24 horas. 
Como o tema do evento só será revelado na abertura, a arquitetura deve ser modular, desacoplada, limpa e pronta para receber qualquer modelo de dados de negócio em minutos, com zero atrito de configuração inicial.

A stack é composta por:
- **Backend:** Django 5 + Django REST Framework (DRF)
- **Frontend Web:** Vue 3 + Vite + TypeScript + Vuetify 3
- **Frontend Mobile:** Flutter (Dart) com Material 3

O objetivo do template é ter um CRUD genérico de exemplo (`Item`/`Task`) funcionando ponta a ponta nas três camadas (Backend <-> Web <-> Mobile), com autenticação mock/básica, CORS liberado e scripts de seed prontos.

---

## 2. Especificações da Stack e Requisitos Técnicos

### Backend: Django & Django REST Framework
- **Python:** 3.11+
- **Pacotes obrigatórios:**
  - `django`
  - `djangorestframework`
  - `django-cors-headers`
  - `python-dotenv`
- **Configurações essenciais (`settings.py`):**
  - `CORS_ALLOW_ALL_ORIGINS = True` (obrigatório para conexões locais sem fricção durante o evento).
  - `ALLOWED_HOSTS = ['*']`
  - `INSTALLED_APPS`: Adicionar `'rest_framework'`, `'corsheaders'`, e o app core `'api'`.
  - `MIDDLEWARE`: Posicionar `'corsheaders.middleware.CorsMiddleware'` o mais alto possível (antes de `CommonMiddleware`).
- **Arquitetura mínima:**
  - Modelo genérico de exemplo em `api/models.py`:
    - `id` (AutoField / UUID)
    - `title` (CharField, max_length=200)
    - `description` (TextField, blank=True)
    - `status` (CharField choices: `pending`, `in_progress`, `completed`, default `pending`)
    - `created_at` (DateTimeField auto_now_add=True)
  - `api/serializers.py`: `ModelSerializer` completo para o modelo.
  - `api/views.py`: `ModelViewSet` padrão com paginação simples ou desativada para protótipo.
  - `api/urls.py`: `DefaultRouter` registrando o endpoint `/api/items/`.
  - Comando ou fixture de seed: `python manage.py seed_data` populando pelo menos 5 a 10 registros realistas para demonstração imediata.

---

### Frontend Web: Vue 3 + Vuetify + TypeScript
- **Bundler:** Vite
- **Linguagem:** TypeScript
- **UI Framework:** Vuetify 3 (com suporte a Material Design Icons `@mdi/font`)
- **Roteamento & Estado:** `vue-router` e `pinia` (ou `axios` direto em services)
- **Cliente HTTP:** `axios` configurado em `src/services/api.ts` com `baseURL` baseada em variável de ambiente `VITE_API_URL` (fallback para `http://localhost:8000/api`).
- **Telas mínimas prontas:**
  1. `AppLayout`: Navbar superior com título do projeto, drawer lateral limpo e botão para alternar tema (light/dark).
  2. `DashboardView` (Home): 
     - Cards de métricas rápidas (ex: Total, Pendentes, Concluídos).
     - `v-data-table` listando os itens vindos da API Django.
     - Botão flutuante ou superior para abrir `v-dialog` de cadastro/edição.
  3. `ItemDialog`: Formulário reativo com validação básica no Vuetify (Título obrigatório, Descrição, Seletor de Status).

---

### Frontend Mobile: Flutter (Dart)
- **UI System:** Material 3 ativado (`useMaterial3: true`).
- **Tipografia:** `google_fonts` (Inter ou Roboto).
- **Gerenciamento de Estado:** Abordagem direta (`StatefulWidget` com `setState` ou `ChangeNotifier` básico), sem arquiteturas pesadas como BLoC ou Clean Code estrito.
- **Cliente HTTP:** Pacote `http`.
- **Configuração de Conectividade:**
  - `ApiService` com chaveamento de URL:
    - Android Emulator: `http://10.0.2.2:8000/api`
    - Celular físico / Desktop: `http://<SEU_IP_LOCAL>:8000/api`
  - Permissão de rede configurada no `android/app/src/main/AndroidManifest.xml`:
    `<uses-permission android:name="android.permission.INTERNET"/>`
- **Telas mínimas prontas:**
  1. `HomeScreen`:
     - `AppBar` com ação de refresh (`IconButton`).
     - `FutureBuilder` consumindo a lista da API Django com estados claros de Loading (`CircularProgressIndicator`), Vazio e Erro.
     - `ListView.builder` exibindo `Card` com `ListTile`.
     - `FloatingActionButton` que abre tela ou bottom-sheet para criar novo item.
  2. `CreateItemScreen`:
     - Formulário simples com `TextFormField` dentro de um `SingleChildScrollView` (evita overflow de teclado).

---

## 3. Estrutura de Diretórios Unificada Sugerida

```text
hackathon-starter/
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── core/
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   └── api/
│       ├── management/commands/seed_data.py
│       ├── migrations/
│       ├── models.py
│       ├── serializers.py
│       ├── urls.py
│       └── views.py
├── frontend-web/
│   ├── package.json
│   ├── vite.config.ts
│   ├── src/
│   │   ├── assets/
│   │   ├── components/
│   │   │   └── ItemDialog.vue
│   │   ├── plugins/
│   │   │   └── vuetify.ts
│   │   ├── services/
│   │   │   └── api.ts
│   │   ├── views/
│   │   │   └── DashboardView.vue
│   │   ├── App.vue
│   │   └── main.ts
│   └── index.html
├── frontend-mobile/
│   ├── pubspec.yaml
│   └── lib/
│       ├── models/
│       │   └── item_model.dart
│       ├── services/
│       │   └── api_service.dart
│       ├── screens/
│       │   ├── home_screen.dart
│       │   └── create_screen.dart
│       └── main.dart
├── .gitignore
├── docker-compose.yml (opcional para rodar back + db com 1 comando)
└── README.md