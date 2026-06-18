# mobile_arquitetura_01 — Catálogo de Produtos (Flutter)

Aplicativo Flutter de catálogo de produtos com autenticação, sessão
persistente, listagem e detalhes de produtos, controle de favoritos e cache
em camadas. Consome a API pública [DummyJSON](https://dummyjson.com).

## Como executar

```bash
flutter pub get
flutter run
```

Há duas formas de entrar:

- **Conta de demonstração (DummyJSON):** usuário `emilys` / senha `emilyspass`.
- **Criar conta:** botão "Criar conta" na tela de login. O cadastro é salvo
  localmente e funciona **mesmo offline** (não depende do servidor).

## API utilizada

Todas as requisições usam a API pública **DummyJSON**:

| Recurso | Endpoint |
|---|---|
| Login | `POST https://dummyjson.com/auth/login` |
| Perfil do usuário | `GET https://dummyjson.com/auth/me` |
| Lista de produtos | `GET https://dummyjson.com/products` |
| Cadastrar produto | `POST https://dummyjson.com/products/add` |
| Editar produto | `PUT https://dummyjson.com/products/{id}` |
| Excluir produto | `DELETE https://dummyjson.com/products/{id}` |

> Os detalhes do produto não exigem nova requisição: o objeto `Product`
> selecionado na lista é enviado diretamente para a tela de detalhes via
> construtor, evitando latência desnecessária.

## Arquitetura

O projeto segue uma separação em camadas inspirada no padrão **MVVM**:

```
lib/
├── domain/
│   └── models/            # Modelo de domínio (Product)
├── data/
│   ├── datasources/       # Acesso HTTP à API (ProductApi)
│   ├── cache/             # Cache em memória e local (SharedPreferences)
│   └── repositories/      # Orquestração API + cache (Repository)
├── presentation/
│   ├── viewmodels/        # Estado da UI (ChangeNotifier)
│   ├── pages/             # Telas de produtos, detalhes e favoritos
│   └── widgets/           # Componentes reutilizáveis (skeleton, botões)
├── models/                # Modelo de usuário (User)
├── services/              # Autenticação e cadastro (AuthService, AccountStore)
├── session/               # Sessão do usuário (SessionManager)
├── utils/                 # Helper HTTP
├── screens/               # Splash, Login, Cadastro e Perfil
└── main.dart              # Injeção de dependências e rotas
```

Cada responsabilidade fica isolada: **modelo** (`Product`, `User`),
**serviço** (`AuthService`), **sessão** (`SessionManager`) e **tela**
(`pages`/`screens`) são independentes entre si.

## Gerenciamento de estado — por que Provider

Foi adotado o **Provider** (`ChangeNotifier` + `Consumer`) por ser a solução
oficial recomendada pela equipe do Flutter e por equilibrar simplicidade e
reatividade:

- **Atualização automática da interface:** ao marcar/remover um favorito, o
  `FavoritesViewModel` chama `notifyListeners()` e todos os widgets que o
  observam (lista, tela de detalhes, contador no app bar e tela de favoritos)
  se reconstroem sozinhos — sem `setState` manual espalhado pela árvore.
- **Reconstrução granular:** o `Consumer`/`context.watch` reconstrói apenas o
  widget que depende do estado (ex.: o botão de coração), não a tela inteira.
- **Injeção de dependências:** o `MultiProvider` no `main.dart` fornece os
  ViewModels já configurados com seus repositórios e o `SharedPreferences`.

Onde o estado é puramente local de um único widget (ex.: índice da galeria de
imagens na tela de detalhes), foi mantido `setState`, por ser mais simples e
não justificar um ViewModel.

## Funcionalidades

### Autenticação e sessão
- **Cadastro (criar conta):** tela de registro com validação; a conta é
  persistida localmente (`AccountStore`) e o usuário entra já logado.
- **Login** com **validação** de usuário e senha:
  - contas criadas no app são autenticadas localmente (funcionam offline);
  - demais usuários via `POST /auth/login` (DummyJSON).
- **Tratamento de erro** (credenciais inválidas / sem conexão) exibido na tela.
- **Sessão resiliente e persistente:** a sessão é salva em `SharedPreferences`.
  Ao reabrir o app, a `SplashScreen` mantém o usuário logado sem depender do
  servidor. Mesmo que a chamada de perfil (`/auth/me`) caia, o app continua
  logado e usa os dados salvos da sessão (`ProfileScreen`).
- **Bloqueio de acesso sem login:** sem sessão válida, o usuário é redirecionado
  para a tela de login.
- Nome do usuário autenticado exibido no app bar e **botão de logout** (com
  confirmação) que limpa a sessão.

### Produtos
- Lista de produtos (`GET /products`) com **título, preço e imagem**.
- Tela de detalhes com **nome, preço, descrição, imagens e demais dados**.
- Tratamento de **carregamento** (skeleton animado) e de **erro** com botão de
  "Tentar novamente".
- Cache em camadas (memória → local → rede) para reduzir latência percebida.

### CRUD de produtos
- **Cadastrar** (`POST /products/add`), **editar** (`PUT /products/{id}`) e
  **excluir** (`DELETE /products/{id}`) produtos, com validação de formulário,
  tratamento de erro e confirmação antes de excluir.
- **Fluxo híbrido:** como o DummyJSON simula a escrita (não persiste de fato),
  o repositório envia a requisição à API e reflete a alteração na persistência
  local (memória + `SharedPreferences`), garantindo que a lista permaneça
  consistente. A interface é atualizada automaticamente via Provider.

### Favoritos
- Marcar/remover produto como favorito pelo coração na lista ou nos detalhes.
- Tela dedicada de favoritos com contador no app bar.
- Favoritos persistidos em `SharedPreferences` (sobrevivem ao fechamento do
  app) e interface atualizada automaticamente via Provider.

## Navegação

- **Rotas nomeadas** (`/`, `/login`, `/register`, `/products`, `/favorites`,
  `/profile`) registradas no `MaterialApp`.
- `Navigator.push` (`MaterialPageRoute`) para abrir os detalhes do produto.
- `Navigator.pop` para retornar/fechar diálogos (ex.: confirmação de logout).
