Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

# DreamWear — Là où les Dreamers rencontrent les Makers 🌟🛠️

## Le concept

DreamWear est une marketplace créative qui connecte des personnes ayant des idées uniques d'objets décoratifs avec des artisans talentueux capables de les réaliser.

## Comment ça marche ?

- **Les Dreamers** créent un projet, décrivent leur idée et génèrent un visuel grâce à notre assistant IA (DALL-E 3). Une fois prêt, ils publient leur projet.
- **Les Makers** parcourent les projets publiés, matchent avec ceux qui correspondent à leurs compétences et échangent directement avec le Dreamer via le chat intégré.

## Stack technique

- Ruby on Rails 8
- PostgreSQL
- Devise (authentification)
- Pundit (autorisation)
- OpenAI API (GPT-4o + DALL-E 3)
- Active Storage + Cloudinary
- Hotwire (Turbo + Stimulus)
- Bootstrap



- generer un maker_projects controller
- dans lequel il y aura l'action create
- créer une instance de maker_project (équivalent à une candidature du maker sur un project), qui aura un status "approved"
