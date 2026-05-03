# App de Tarefas - Flutter

> Trabalho mobile thiago – Desenvolvimento de Dispositivos Móveis

Aplicativo de gerenciamento de tarefas desenvolvido em Flutter com CRUD completo, persistência SQLite e gerenciamento de estado com Provider.

---

## Funcionalidades

- ✅ **CRUD Completo**: criar, listar, editar e excluir tarefas
- ✅ **Persistência com SQLite** via `sqflite`
- ✅ **Gerenciamento de estado** com `Provider`
- ✅ **Rotas nomeadas** com tela de boas-vindas
- ✅ **Filtros por TabBar**: Todas, Importantes, Concluídas, Pendentes, Atrasadas
- ✅ **DatePicker** para seleção de data prevista
- ✅ **Widgets próprios**: `TaskCard`, `CustomButton`, `CategoryBadge`
- ✅ **Swipe para excluir** na lista de tarefas

---

## Atributos da Tarefa

| Campo           | Tipo    | Descrição                                      |
|----------------|---------|------------------------------------------------|
| `id`           | int     | Gerado automaticamente pelo banco              |
| `title`        | String  | Título da tarefa                               |
| `description`  | String  | Descrição detalhada (só na tela de detalhes)   |
| `scheduledDate`| String  | Data prevista (armazenada como texto ISO)       |
| `important`    | bool    | Se a tarefa é importante                       |
| `completed`    | bool    | Se a tarefa foi realizada                      |
| `category`     | String  | **Atributo extra**: Geral, Trabalho, Pessoal, Estudos, Saúde, Finanças |

---

## Estrutura de Arquivos

```
lib/
├── main.dart                    # Entry point + rotas nomeadas + Provider
├── models/
│   └── task_model.dart          # Modelo com fromMap() e toMap()
├── database/
│   └── database_helper.dart     # Singleton de acesso ao SQLite
├── providers/
│   └── task_provider.dart       # ChangeNotifier com lógica de estado
├── screens/
│   ├── welcome_screen.dart      # Tela inicial com próxima tarefa
│   ├── task_list_screen.dart    # Lista com TabBar de filtros
│   ├── task_detail_screen.dart  # Detalhes + marcar como realizada
│   └── task_form_screen.dart    # Formulário criar/editar
└── widgets/
    ├── task_card.dart           # Card personalizado com Dismissible
    ├── custom_button.dart       # Botão estilizado reutilizável
    └── category_badge.dart      # Badge colorido de categoria
```

---

## Como Executar

```bash
# Instalar dependências
flutter pub get

# Executar no emulador ou dispositivo
flutter run
```

---

## Dependências

```yaml
dependencies:
  sqflite: ^2.3.2     # Banco de dados SQLite
  path: ^1.9.0         # Manipulação de caminhos de arquivo
  provider: ^6.1.2     # Gerenciamento de estado
  intl: ^0.19.0        # Formatação de datas
```

---

## Requisitos Atendidos

1. ✅ Atributo extra: **categoria** da tarefa (Geral, Trabalho, Pessoal, Estudos, Saúde, Finanças)
2. ✅ `id` e `description` exibidos somente na tela de detalhes; realização feita nessa tela
3. ✅ `showDatePicker` utilizado na tela de inserção e edição
4. ✅ Tela de edição permite editar campos mas **não marcar como realizada**
5. ✅ Persistência SQLite com `DatabaseHelper`, `fromMap()`, `toMap()`, id auto-gerado, data como Text
6. ✅ Provider gerencia a lista de tarefas e filtros
7. ✅ Rotas nomeadas (`/welcome`, `/tasks`, `/task-detail`, `/task-form`); tela de boas-vindas com próxima tarefa
8. ✅ TabBar com filtros: Todas, Importantes, Concluídas, Pendentes, Atrasadas
9. ✅ Widgets próprios: `TaskCard`, `CustomButton`, `CategoryBadge`
10. ✅ Arquivos organizados em pastas: `models/`, `database/`, `providers/`, `screens/`, `widgets/`
