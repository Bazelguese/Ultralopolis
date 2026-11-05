# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.26)
## Tradizioni e ascensioni: le vie diventano alberi

**Data:** 5 novembre 2026
**Stato:** bozza da approvare. Il GDD non è ancora stato modificato.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.25

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Da definire** = manca una regola; **Spunto** = idea per il futuro, da non implementare.

**Portata.** Le vie stanno nella Parte II del GDD (§10.4): questa bozza le amplia senza toccare il nucleo. Non serve una risorsa nuova, perché i passi si sbloccano con le **imprese**. Gli effetti dei passi e delle ascensioni usano il linguaggio del nucleo (P5). Fa eccezione qualche ascensione che cambierebbe una regola: è segnata come tale in §6 e resta fuori dal primo prototipo.

Riferimento verificato (Stellaris Wiki, pagine *Traditions* e *Ascension perks*): in Stellaris ogni albero ha un'adozione, 5 tradizioni e un completamento, e si compra con l'Unità. Completando un albero si apre uno spazio per un'ascensione; le ascensioni sono permanenti e a livelli.

---

## 1. Decisioni prese con Davide

| # | Decisione | Stato |
|---|---|---|
| 1 | Le tradizioni **non sono un sistema a parte**: ogni **via** diventa un albero di tradizioni | Confermato |
| 2 | I passi dell'albero si sbloccano con le **imprese** della nazione, cioè facendo cose, non pagando una risorsa | Confermato |
| 3 | Un'**ascensione** si ottiene **completando un albero** | Confermato |
| 4 | Si progetta subito, insieme alle tecnologie | Confermato |

---

## 2. Che cosa diventa una via

| Parte dell'albero | Che cosa è | Stato |
|---|---|---|
| **Adozione** | Scegliere la via entrando nell'era, come oggi. Dà ciò che la via dà già: tratto permanente, bonus immediato, offerte più frequenti, esclusivi e tecnologie esclusive (§10.4) | Proposta (nessun cambiamento alle vie di oggi) |
| **Passi** | **4 tradizioni** per via (Stellaris ne ha 5), ognuna con la sua impresa e il suo effetto | Proposta; numero placeholder |
| **Completamento** | Quando tutti i passi sono fatti, la nazione sceglie un'**ascensione** (§5) | Confermato (decisione 3) |

| Regola | Stato |
|---|---|
| I passi si possono completare **in qualsiasi ordine**: tutte le imprese della via sono attive insieme, e l'ordine nasce da come gioca la nazione | Proposta |
| Un passo si completa **da solo** appena l'impresa riesce, e il suo effetto vale subito e **per sempre** | Proposta |
| L'albero di una via **resta aperto anche nelle ere successive**: una via scelta nell'era 2 si può completare nell'era 3 | Proposta |
| Le vie restano al massimo una per era, dalla seconda (§10.4): nel prototipo, con 3 ere, sono **2 alberi per run** | Confermato (regola esistente) |

---

## 3. Le imprese

Un'impresa è un obiettivo che si legge in una riga e che il gioco può controllare da solo, per esempio "Vinci 3 scontri" o "Abbi 4 carte Fante sulla plancia". Accanto a ogni impresa si vede quanto manca (P4).

### 3.1 Due generi di impresa

| Genere | Come si controlla | Esempio | Stato |
|---|---|---|---|
| **Traguardo** | Conta le cose fatte **dopo l'adozione della via**: quello che era già fatto prima non vale | "Vinci 3 scontri" | Proposta |
| **Stato** | Guarda com'è la nazione in quel momento; basta esserci arrivati una volta | "Abbi 4 carte Fante sulla plancia" | Proposta |

### 3.2 Imprese possibili nel primo prototipo

Sono tutte cose che il gioco conosce già, quindi non servono regole nuove.

| Impresa | Genere | Stato |
|---|---|---|
| Vincere N scontri: fantasmi, incontri o entrambi; un pareggio conta come vittoria (§3.4) | Traguardo | Proposta |
| Completare N tecnologie di una sfera (§10.5) | Traguardo | Proposta |
| Prendere N proposte da un consigliere, o da una categoria | Traguardo | Proposta |
| Scegliere N Eventi di una sfera (§4.2.5) | Traguardo | Proposta |
| Avere sulla plancia N carte con un tipo | Stato | Proposta |
| Avere N carte con un tipo al livello 2 o 3 | Stato | Proposta |
| Raccogliere in una sola produzione almeno N di una risorsa | Stato | Proposta |
| Chiudere un anno con il Malcontento a N o meno (§5.5) | Stato | Proposta |

| Regola | Stato |
|---|---|
| I passi di un albero vanno dal più facile al più difficile: il primo si fa in un anno, l'ultimo chiede di puntare sulla via | Proposta |
| Le imprese sono scritte nei dati della via, non nel codice: si cambiano senza toccare uno script | Proposta |
| Imprese che guardano dentro la battaglia, come "vinci uno scontro senza scendere sotto metà Resistenza" | Spunto (servono statistiche della battaglia che oggi non si registrano) |

---

## 4. Esempio completo: Via della Guerra

È un esempio placeholder per vedere la forma; il catalogo di tutte le vie arriva dopo l'approvazione.

| Passo | Impresa | Effetto |
|---|---|---|
| **Veterani** | Vinci 2 scontri | Le truppe Fante fanno 1 danno in più |
| **Arsenali** | Abbi 2 edifici Infrastruttura Bellica sulla plancia | +1 Ferro per fase da ogni edificio Infrastruttura Bellica |
| **Dottrina** | Prendi 4 proposte dal Generale | +1 spazio truppa |
| **Esercito di popolo** | Abbi 6 carte Fante sulla plancia, di cui 2 al livello 2 o più | +8 Resistenza in ogni scontro |

**Completamento:** si sceglie un'ascensione (§5).

---

## 5. Le ascensioni

| Regola | Stato |
|---|---|
| Completando un albero si sceglie **1 ascensione fra 3** pescate, con più probabilità per quelle coerenti con l'identità e le vie (stessa regola delle vie, §16.3) | Proposta |
| Le ascensioni sono **permanenti** e non si cambiano | Proposta (come in Stellaris) |
| Due **livelli**: quelle del livello 2 compaiono solo a chi ha già un'ascensione. Così la seconda è più forte della prima (P2a) | Proposta |
| Un'ascensione già presa non si ripresenta | Proposta |
| Alcune ascensioni possono essere esclusive di una via o di un elemento dell'identità (radice "richiede") | Proposta |

---

## 6. Primo catalogo di ascensioni (placeholder)

| Ascensione | Livello | Effetto | Linguaggio |
|---|---:|---|---|
| **Nazione in armi** | 1 | +1 spazio truppa e +1 spazio edificio | Esistente |
| **Consiglio ristretto** | 1 | In ogni round compare un consigliere in più | Esistente (effetti dei governi, v0.24) |
| **Botteghe maestre** | 1 | Potenzia costa 1 in meno (mai sotto 1) | Esistente (cultura artigiana, v0.24) |
| **Ordine e decoro** | 1 | Il Malcontento sale di 1 in meno per ogni causa | Da verificare nel codice dell'identità |
| **Eredità imperiale** | 2 | +20 Resistenza in ogni scontro | Esistente |
| **Età dell'oro** | 2 | +25% di tutte le risorse prodotte | Esistente |
| **Maestri d'armi** | 2 | Tutte le truppe fanno il 15% di danno in più | Esistente |
| **Illuminismo** | 2 | La mano delle tecnologie ha 4 carte | Piccolo effetto nuovo sulle offerte (bersaglio già previsto in §8.2) |
| **Seconda natura** | 2 | Una truppa può essere incantata due volte | **Cambia una regola** (§4.3): fuori dal primo prototipo |

---

## 7. Interfaccia (P4)

| Regola | Stato |
|---|---|
| Un pannello **Tradizioni**, accanto a Ricerca: per ogni via adottata, i suoi passi con l'impresa, l'avanzamento ("2/3 scontri vinti") e l'effetto | Proposta |
| Quando un passo si completa compare un messaggio, e la cronaca lo registra | Proposta |
| La scelta dell'ascensione si fa con le carte sul tavolo, come le vie | Proposta |

---

## 8. Fantasmi

| Regola | Stato |
|---|---|
| Un fantasma salvato registra i passi e le ascensioni fra i suoi modificatori; in battaglia valgono quelli su tutta la nazione, come per le tecnologie | Proposta tecnica |
| Fantasmi generati: tutti i passi delle vie delle ere passate e metà di quelli della via dell'era corrente, scelti a caso con il seme della run; un'ascensione per ogni albero completo | Convenzione provvisoria (§16.3) |

---

## 9. Domande per Davide

1. **Era 1 senza albero.** La prima via arriva nell'era 2, quindi nell'era 1 non c'è nessuna tradizione da costruire. Va bene così, oppure vuoi un albero dall'inizio? Per esempio la **cultura** potrebbe fare da primo albero, oppure si potrebbe scegliere una "via della fondazione" alla creazione della nazione.
2. **Quanti passi:** 4 per via (proposta) o 5 come in Stellaris? Con 5 è più difficile completare gli alberi nel prototipo, che ha solo 2 vie per run.
3. **Le imprese si vedono prima di scegliere la via?** Proposta: sì, sulla carta della via, così la scelta dice anche "che cosa dovrai fare".
4. **Ascensioni:** il catalogo di §6 ti piace come punto di partenza? E le ascensioni che cambiano una regola, come "Seconda natura", le vuoi più avanti?
