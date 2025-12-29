## Výchozí chování (AND)

```sql
MATCH 'golem praha'
```
 interpretuje se jako:

```
golem AND praha
```

* **oba výrazy se musí v záznamu vyskytovat**
* nezáleží na pořadí slov

---

## Logické operátory

### OR

```sql
MATCH 'golem OR praha'
```

 stačí výskyt jednoho z výrazů

---

### NOT

```sql
MATCH 'golem NOT praha'
```
 obsahuje `golem`, ale ne `praha`

---

## Přesná fráze

```sql
MATCH '"golem z prahy"'
```
 slova musí být **přesně za sebou**

---

## Prefix search (`*`)

```sql
MATCH 'gole* pra*'
```

* hledá slova začínající na daný prefix
* velmi vhodné pro search dialogy

 Typický UI pattern:

```
"gol pra" → "gol* AND pra*"
```

---

## Vyhledávání v konkrétních sloupcích

```sql
MATCH 'tags:golem text:praha'
```

* `golem` musí být v `tags`
* `praha` musí být v `text`

---

## Mezery vs. AND

Tyto dotazy jsou **ekvivalentní**:

```sql
MATCH 'golem praha'
MATCH 'golem AND praha'
```

mezera = **AND**

---

## Shrnutí

| Zápis     | Význam       |
| --------- | ------------ |
| `a b`     | `a AND b`    |
| `a OR b`  | logické OR   |
| `a NOT b` | negace       |
| `"a b"`   | přesná fráze |
| `a*`      | prefix       |

✔ výchozí chování je **AND**
✔ OR musí být explicitní
✔ ideální pro rychlé search UI

---

*(Použitelné jako interní dokumentace pro kfsNotes)*
