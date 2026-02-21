# 🐍 Snakesss — Game Design Document

## Le Jeu

Snakesss est un jeu de **trivia + déduction sociale** pour **4 à 8 joueurs**, joué en local sur un seul iPhone (pass & play). L'app remplace le modérateur humain du jeu de plateau original.

**Pitch :** Un quiz multijoueur où des traîtres connaissent déjà la bonne réponse et tentent de manipuler le groupe vers la mauvaise.

---

## Règles

### Rôles

Trois rôles distribués aléatoirement à chaque manche :

- **🧑 Humain** — Doit deviner la bonne réponse. Ne la connaît pas.
- **🐍 Serpent** — Connaît la bonne réponse. Doit manipuler les autres pour qu'ils se trompent. Ne vote pas A/B/C (vote "Snake" obligatoirement).
- **🦡 Mangouste de Vérité** — Comme un Humain, mais son identité est **publique**. Tout le monde sait qu'il est digne de confiance. Ne connaît pas la réponse pour autant.

### Distribution des rôles

| Joueurs | Humains | Serpents | Mangouste |
|---------|---------|----------|-----------|
| 4       | 1       | 2        | 1         |
| 5       | 2       | 2        | 1         |
| 6       | 2       | 3        | 1         |
| 7       | 3       | 3        | 1         |
| 8       | 3       | 4        | 1         |

Toujours exactement 1 Mangouste. Les Serpents sont à peu près aussi nombreux que les non-Serpents.

### Déroulement d'une manche

La partie dure **6 manches**. Chaque manche :

1. **Distribution des rôles** — L'app attribue les rôles au hasard. Chaque joueur passe le téléphone et voit son rôle en privé. La Mangouste est annoncée publiquement.

2. **Question** — L'app affiche une question de culture générale avec **3 réponses (A, B, C)**. Le téléphone est posé au centre, visible par tous. Les questions sont volontairement obscures pour que personne ne soit sûr.

3. **Révélation aux Serpents** — Tous ferment les yeux. Les Serpents ouvrent les yeux et voient la bonne réponse affichée à l'écran. Ils voient aussi qui sont les autres Serpents. Puis tout le monde rouvre les yeux.

4. **Discussion (2 min)** — Timer de 2 minutes. Les joueurs débattent à voix haute. Les Serpents bluffent pour orienter le groupe vers une mauvaise réponse. La Mangouste donne son avis (elle est de confiance, mais peut se tromper).

5. **Vote** — Chaque joueur vote secrètement via pass & play. Humains/Mangouste choisissent A, B ou C. Les Serpents votent obligatoirement "🐍".

6. **Résultats** — L'app révèle la bonne réponse, les votes de chacun, et les rôles de chacun.

### Scoring

- **Humain / Mangouste avec la bonne réponse** → gagne **1 point par joueur ayant répondu correctement** (y compris soi-même).
- **Humain / Mangouste avec la mauvaise réponse** → 0 point.
- **Serpent** → gagne **1 point par non-serpent ayant répondu incorrectement**.

### Fin de partie

Après 6 manches, le joueur avec le plus de points gagne. Égalité = victoire partagée.

### Questions

- Format : question + 3 choix (A/B/C) + réponse + fun fact optionnel.
- 120 questions minimum (20 parties sans répétition).
- Questions obscures et surprenantes, mauvaises réponses plausibles.

---

## Stack Technique

- **iOS 17+**, iPhone
- **Xcode**, **Swift**, **SwiftUI** (100%)
- **Architecture MVVM**
- **100% offline** — pas de backend, pas d'API, pas d'auth
- Questions stockées dans un **JSON embarqué** dans le bundle
- Persistance locale optionnelle via **SwiftData** (historique)
