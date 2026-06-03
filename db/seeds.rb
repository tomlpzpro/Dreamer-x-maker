# Dreamer — données de démo
# Lancer avec : bin/rails db:seed (ou db:reset pour repartir de zéro)

puts "Nettoyage de la base..."
LlmMessage.destroy_all
LlmChat.destroy_all
MatchMessage.destroy_all
MatchChat.destroy_all
MakerProject.destroy_all
Project.destroy_all
User.destroy_all

PASSWORD = "password"

# ----------------------------------------------------------------------------
# DREAMERS (ceux qui rêvent d'un objet sur mesure)
# ----------------------------------------------------------------------------
puts "Création des dreamers..."

dreamers = [
  {
    email: "camille.durand@example.com",
    username: "Camille Durand",
    adresse: "12 rue de Bretagne, 75003 Paris",
    phone_number: "0612345678",
    profile_picture_url: "https://i.pravatar.cc/150?img=5"
  },
  {
    email: "thomas.leroy@example.com",
    username: "Thomas Leroy",
    adresse: "8 quai des Chartrons, 33000 Bordeaux",
    phone_number: "0623456789",
    profile_picture_url: "https://i.pravatar.cc/150?img=12"
  },
  {
    email: "lea.martin@example.com",
    username: "Léa Martin",
    adresse: "45 cours Lafayette, 69003 Lyon",
    phone_number: "0634567890",
    profile_picture_url: "https://i.pravatar.cc/150?img=20"
  }
].map do |attrs|
  User.create!(attrs.merge(password: PASSWORD, role: "dreamer", skills: nil))
end

# ----------------------------------------------------------------------------
# MAKERS (les artisans)
# ----------------------------------------------------------------------------
puts "Création des makers..."

makers = [
  {
    email: "atelier.bois@example.com",
    username: "Atelier du Bois",
    adresse: "3 rue des Artisans, 35000 Rennes",
    phone_number: "0645678901",
    skills: "Menuiserie, ébénisterie, chêne massif",
    profile_picture_url: "https://i.pravatar.cc/150?img=33"
  },
  {
    email: "ceramique.claire@example.com",
    username: "Claire Céramique",
    adresse: "27 avenue Jean Jaurès, 31000 Toulouse",
    phone_number: "0656789012",
    skills: "Céramique, grès émaillé, tournage",
    profile_picture_url: "https://i.pravatar.cc/150?img=45"
  },
  {
    email: "ferronnerie.dupont@example.com",
    username: "Ferronnerie Dupont",
    adresse: "14 rue du Faubourg, 67000 Strasbourg",
    phone_number: "0667890123",
    skills: "Ferronnerie d'art, laiton, métal",
    profile_picture_url: "https://i.pravatar.cc/150?img=51"
  }
].map do |attrs|
  User.create!(attrs.merge(password: PASSWORD, role: "maker"))
end

# ----------------------------------------------------------------------------
# PROJECTS (les rêves postés par les dreamers)
# ----------------------------------------------------------------------------
puts "Création des projets..."

projects = [
  {
    title: "Table basse en chêne sur mesure",
    description: "Je cherche une table basse en chêne massif, 110x60cm, " \
                 "finition huilée, avec un piètement métallique noir.",
    budget: 800,
    deadline: "2026-09-15",
    dreamer: dreamers[0]
  },
  {
    title: "Service à thé en grès",
    description: "Un service à thé pour 4 personnes en grès émaillé, " \
                 "tons terracotta, théière + 4 tasses + plateau.",
    budget: 250,
    deadline: "2026-08-01",
    dreamer: dreamers[1]
  },
  {
    title: "Luminaire suspendu en laiton",
    description: "Suspension en laiton brossé pour une salle à manger, " \
                 "style Art déco, diamètre ~50cm.",
    budget: 600,
    deadline: "2026-10-30",
    dreamer: dreamers[2]
  },
  {
    title: "Étagère murale modulable",
    description: "Étagère murale en bois et métal, modulable, " \
                 "3 niveaux, pour un salon de 20m².",
    budget: 400,
    deadline: "2026-09-01",
    dreamer: dreamers[0]
  }
].map do |attrs|
  dreamer = attrs.delete(:dreamer)
  Project.create!(attrs.merge(dreamer_id: dreamer.id))
end

# ----------------------------------------------------------------------------
# MAKER_PROJECTS (candidatures des makers sur les projets)
# ----------------------------------------------------------------------------
puts "Création des candidatures..."

maker_projects = []

# Projet 0 (table chêne) : l'Atelier du Bois est accepté
maker_projects << MakerProject.create!(
  project_id: projects[0].id, maker_id: makers[0].id, status: "accepted"
)
# Projet 0 : la Ferronnerie a aussi postulé mais refusée
MakerProject.create!(
  project_id: projects[0].id, maker_id: makers[2].id, status: "rejected"
)
# Projet 1 (service à thé) : Claire Céramique en attente
maker_projects << MakerProject.create!(
  project_id: projects[1].id, maker_id: makers[1].id, status: "pending"
)
# Projet 2 (luminaire laiton) : Ferronnerie acceptée
maker_projects << MakerProject.create!(
  project_id: projects[2].id, maker_id: makers[2].id, status: "accepted"
)
# Projet 3 (étagère) : Atelier du Bois en attente
MakerProject.create!(
  project_id: projects[3].id, maker_id: makers[0].id, status: "pending"
)

# ----------------------------------------------------------------------------
# MATCH_CHATS + MATCH_MESSAGES (discussion dreamer <-> maker sur un match)
# ----------------------------------------------------------------------------
puts "Création des chats de match..."

# Chat sur le projet table chêne (dreamer Camille <-> Atelier du Bois)
chat1 = MatchChat.create!(maker_project_id: maker_projects[0].id)
[
  { user: dreamers[0], content: "Bonjour ! Vous pensez pouvoir livrer avant mi-septembre ?" },
  { user: makers[0],   content: "Bonjour Camille, oui sans problème. Vous avez une essence précise en tête ?" },
  { user: dreamers[0], content: "Du chêne français si possible, finition huilée mate." },
  { user: makers[0],   content: "Parfait, je vous prépare un devis détaillé aujourd'hui." }
].each do |msg|
  MatchMessage.create!(match_chat_id: chat1.id, user_id: msg[:user].id, content: msg[:content])
end

# Chat sur le projet luminaire (dreamer Léa <-> Ferronnerie)
chat2 = MatchChat.create!(maker_project_id: maker_projects[2].id)
[
  { user: dreamers[2], content: "Le laiton peut-il être patiné plutôt que brossé ?" },
  { user: makers[2],   content: "Tout à fait, je peux vous proposer plusieurs finitions de patine." }
].each do |msg|
  MatchMessage.create!(match_chat_id: chat2.id, user_id: msg[:user].id, content: msg[:content])
end

# ----------------------------------------------------------------------------
# LLM_CHATS + LLM_MESSAGES (assistant IA attaché à un projet)
# ----------------------------------------------------------------------------
puts "Création des chats LLM..."

llm_conversations = {
  projects[0] => [
    { role: "user",      content: "Aide-moi à décrire ma table basse en chêne." },
    { role: "assistant", content: "Bien sûr ! Quelles dimensions et quelle finition souhaitez-vous ?" },
    { role: "user",      content: "110x60, finition huilée, pieds métal noir." },
    { role: "assistant", content: "Voici une description claire à publier pour les artisans..." }
  ],
  projects[2] => [
    { role: "user",      content: "Quel budget réaliste pour une suspension laiton Art déco ?" },
    { role: "assistant", content: "Pour du laiton travaillé sur mesure, comptez entre 500 et 800€." }
  ]
}

llm_conversations.each do |project, messages|
  chat = LlmChat.create!(project_id: project.id)
  messages.each do |msg|
    LlmMessage.create!(llm_chat_id: chat.id, role: msg[:role], content: msg[:content])
  end
end

# ----------------------------------------------------------------------------
puts "----------------------------------------"
puts "Seed terminé :"
puts "#{User.count} users (#{User.where(role: 'dreamer').count} dreamers, #{User.where(role: 'maker').count} makers)"
puts "#{Project.count} projets"
puts "#{MakerProject.count} candidatures"
puts "#{MatchChat.count} match chats / #{MatchMessage.count} messages"
puts "#{LlmChat.count} llm chats / #{LlmMessage.count} messages"
puts "----------------------------------------"
