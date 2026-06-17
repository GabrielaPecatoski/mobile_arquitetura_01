# mobile_arquitetura_01 — Catálogo de Produtos (Flutter)

Aplicativo Flutter de catálogo de produtos com autenticação, sessão
persistente, listagem e detalhes de produtos, controle de favoritos e cache
em camadas. Consome a API pública [DummyJSON](https://dummyjson.com).

## Como executar

```bash
flutter pub get
flutter run
```

Login de teste (DummyJSON):

- **Usuário:** `emilys`
- **Senha:** `emilyspass`

## API utilizada

Todas as requisições usam a API pública **DummyJSON**:

| Recurso | Endpoint |
|---|---|
| Login | `POST https://dummyjson.com/auth/login` |
| Perfil do usuário | `GET https://dummyjson.com/auth/me` |
| Lista de produtos | `GET https://dummyjson.com/products` |

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
├── services/              # Serviço de autenticação (AuthService)
├── session/               # Sessão do usuário (SessionManager)
├── utils/                 # Helper HTTP
├── screens/               # Splash, Login e Perfil
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
- Tela de login com **validação** de usuário e senha.
- `POST /auth/login` com **tratamento de erro** (credenciais inválidas / falha
  de rede) exibido na própria tela.
- Sessão persistida em `SharedPreferences`: ao reabrir o app, a `SplashScreen`
  verifica a sessão e **bloqueia o acesso** às telas internas sem login,
  redirecionando para o login quando não há usuário autenticado.
- Nome do usuário autenticado exibido no app bar e **botão de logout** (com
  confirmação) que limpa a sessão.

### Produtos
- Lista de produtos (`GET /products`) com **título, preço e imagem**.
- Tela de detalhes com **nome, preço, descrição, imagens e demais dados**.
- Tratamento de **carregamento** (skeleton animado) e de **erro** com botão de
  "Tentar novamente".
- Cache em camadas (memória → local → rede) para reduzir latência percebida.

### Favoritos
- Marcar/remover produto como favorito pelo coração na lista ou nos detalhes.
- Tela dedicada de favoritos com contador no app bar.
- Favoritos persistidos em `SharedPreferences` (sobrevivem ao fechamento do
  app) e interface atualizada automaticamente via Provider.

## Navegação

- **Rotas nomeadas** (`/`, `/login`, `/products`, `/favorites`, `/profile`)
  registradas no `MaterialApp`.
- `Navigator.push` (`MaterialPageRoute`) para abrir os detalhes do produto.
- `Navigator.pop` para retornar/fechar diálogos (ex.: confirmação de logout).
