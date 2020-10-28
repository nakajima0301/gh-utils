# nested team

1. add
1. del

## add

### 入力

- Environment variables
    - Organization
    - Token
- User input
    - Parent team : 単一
    - Child team : 複数対応

### 処理の流れ

1. 入力のバリデーション
1. Parent teamのIDを取得し変数に格納
1. parent_team_idの値を取得した変数の値に設定

## del

### 入力

- Environment variables
    - Organization
    - Token
- User input
    - Child team : 複数対応

### 処理の流れ

1. 入力のバリデーション
1. parent_team_idの値をnullに設定

### memo

- 親は複数の子チームを持てる
- 子は単一のチームのみを親として持てる

削除のタスクに関してはそもそも子は親を1チームしか指定できないので誰が親なのかを考慮する必要がない