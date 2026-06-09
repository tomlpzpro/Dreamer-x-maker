# db/seeds.rb
# Seed Dreamer x Maker
# Ordre de destruction inverse des dépendances FK

puts "Nettoyage de la base..."
LlmMessage.destroy_all
LlmChat.destroy_all
MatchMessage.destroy_all
MatchChat.destroy_all
MakerProject.destroy_all
Project.destroy_all
User.destroy_all

PASSWORD = "password123"

# ---------------------------------------------------------------------------
# USERS
# role: "dreamer" (porteur de projet) ou "maker" (artisan)
# ---------------------------------------------------------------------------
puts "Création des utilisateurs..."

dreamers_data = [
  { username: "claire_n",   email: "claire@example.com",   adresse: "Neuilly-sur-Seine", phone_number: "0601020304" },
  { username: "thomas_b",   email: "thomas@example.com",   adresse: "Paris 11e",         phone_number: "0602030405" },
  { username: "sophie_m",   email: "sophie@example.com",   adresse: "Lyon 6e",           phone_number: "0603040506" },
  { username: "antoine_r",  email: "antoine@example.com",  adresse: "Bordeaux",          phone_number: "0604050607" }
]

makers_data = [
  { username: "atelier_chene",  email: "chene@example.com",   adresse: "Saint-Ouen",  phone_number: "0611121314", skills: "Menuiserie, ébénisterie, bois massif" },
  { username: "ceramique_lou",  email: "lou@example.com",     adresse: "Vallauris",   phone_number: "0612131415", skills: "Céramique, grès, émaillage" },
  { username: "metal_forge",    email: "forge@example.com",   adresse: "Montreuil",   phone_number: "0613141516", skills: "Ferronnerie, métal, soudure" },
  { username: "textile_inde",   email: "textile@example.com", adresse: "Roubaix",     phone_number: "0614151617", skills: "Tissage, couture, tapisserie" },
  { username: "bijoux_sarah",   email: "sarah@example.com",   adresse: "Paris 3e",    phone_number: "0615161718", skills: "Bijouterie, fonte, sertissage" }
]

dreamers = dreamers_data.map do |d|
  User.create!(
    username: d[:username],
    email: d[:email],
    password: PASSWORD,
    password_confirmation: PASSWORD,
    adresse: d[:adresse],
    phone_number: d[:phone_number],
    role: "dreamer",
    profile_picture_url: "https://i.pravatar.cc/150?u=#{d[:email]}"
  )
end

makers = makers_data.map do |m|
  User.create!(
    username: m[:username],
    email: m[:email],
    password: PASSWORD,
    password_confirmation: PASSWORD,
    adresse: m[:adresse],
    phone_number: m[:phone_number],
    role: "maker",
    skills: m[:skills],
    profile_picture_url: "https://i.pravatar.cc/150?u=#{m[:email]}"
  )
end

puts "#{dreamers.count} dreamers et #{makers.count} makers créés."

# ---------------------------------------------------------------------------
# PROJECTS (créés par des dreamers)
# ---------------------------------------------------------------------------
puts "Création des projets..."

projects_data = [
  { title: "Table basse en chêne sur mesure", category: "Mobilier",   budget: 1200, deadline: "2026-09-15",
    description: "Table basse rectangulaire en chêne massif, finition huilée, pieds métal noir. Dimensions 120x60x40 cm." },
  { title: "Service de table en grès émaillé", category: "Céramique", budget: 600, deadline: "2026-08-30",
    description: "Service complet pour 6 personnes en grès, tons terre et bleu profond, fait main." },
  { title: "Luminaire suspendu en laiton", category: "Métal",         budget: 850, deadline: "2026-10-01",
    description: "Suspension design en laiton brossé pour salle à manger, structure géométrique." },
  { title: "Tête de lit en tissu capitonné", category: "Textile",     budget: 950, deadline: "2026-09-20",
    description: "Tête de lit 160 cm capitonnée en velours côtelé vert sauge, finition soignée." },
  { title: "Bague de fiançailles personnalisée", category: "Bijoux",  budget: 2200, deadline: "2026-07-25",
    description: "Bague or jaune 18 carats avec saphir central, design épuré et intemporel." },
  { title: "Étagère murale modulable",          category: "Mobilier", budget: 700, deadline: "2026-11-10",
    description: "Système d'étagères modulables en bois clair et métal, fixation murale invisible." }
]

projects = projects_data.each_with_index.map do |p, i|
  Project.create!(
    title: p[:title],
    category: p[:category],
    budget: p[:budget],
    deadline: p[:deadline],
    description: p[:description],
    dreamer_id: dreamers[i % dreamers.size].id
  )
end

puts "#{projects.count} projets créés."

# ---------------------------------------------------------------------------
# MAKER_PROJECTS (candidatures / matchs makers <-> projets)
# status: "pending", "accepted", "in_progress", "completed", "declined"
# ---------------------------------------------------------------------------
puts "Création des maker_projects..."

statuses = ["rejected", "accepted", "pending", "made", "delivered"]
maker_projects = []

projects.each_with_index do |project, idx|
  # 1 à 2 makers candidatent sur chaque projet
  candidate_makers = makers.sample(rand(1..2))
  candidate_makers.each do |maker|
    maker_projects << MakerProject.create!(
      maker_id: maker.id,
      project_id: project.id,
      status: statuses[idx % statuses.size],
      rating: rand(3..5)
    )
  end
end

puts "#{maker_projects.count} maker_projects créés."

# ---------------------------------------------------------------------------
# MATCH_CHATS + MATCH_MESSAGES (conversation dreamer <-> maker)
# ---------------------------------------------------------------------------
puts "Création des conversations de match..."

maker_projects.each do |mp|
  chat = MatchChat.create!(maker_project: mp)

  project = mp.project
  dreamer = User.find(project.dreamer_id)
  maker   = User.find(mp.maker_id)

  exchange = [
    { user: dreamer, content: "Bonjour, j'ai vu que vous étiez intéressé(e) par mon projet « #{project.title} ». Quelles seraient vos disponibilités ?" },
    { user: maker,   content: "Bonjour, oui le projet me plaît beaucoup. Je peux démarrer dès la semaine prochaine. Avez-vous des références visuelles ?" },
    { user: dreamer, content: "Parfait. Je vous envoie quelques images d'inspiration et les dimensions exactes." },
    { user: maker,   content: "Très bien, je vous prépare un premier devis détaillé d'ici demain." }
  ]

  exchange.each_with_index do |msg, i|
    MatchMessage.create!(
      match_chat: chat,
      user_id: msg[:user].id,
      content: msg[:content],
      read: i < 2 # les premiers messages sont lus, les derniers non
    )
  end
end

puts "#{MatchChat.count} conversations et #{MatchMessage.count} messages créés."

# ---------------------------------------------------------------------------
# LLM_CHATS + LLM_MESSAGES (assistant IA lié à un projet)
# role: "user" / "assistant"
# ---------------------------------------------------------------------------
puts "Création des chats IA..."

projects.first(3).each do |project|
  llm_chat = LlmChat.create!(project: project)

  conversation = [
    { role: "user",      content: "Peux-tu m'aider à affiner la description de mon projet « #{project.title} » ?" },
    { role: "assistant", content: "Bien sûr. Précisons d'abord les matériaux, les dimensions et le style recherché pour attirer les bons artisans." },
    { role: "user",      content: "Je vise un style épuré, matériaux nobles, budget autour de #{project.budget} €." },
    { role: "assistant", content: "Parfait. Je suggère de mettre en avant la finition et la durabilité dans le titre pour valoriser le sur-mesure." }
  ]

  conversation.each do |m|
    LlmMessage.create!(llm_chat: llm_chat, role: m[:role], content: m[:content])
  end
end

puts "#{LlmChat.count} chats IA et #{LlmMessage.count} messages IA créés."

puts ""
puts "Seed terminé."
puts "Comptes de test (mot de passe : #{PASSWORD})"
puts "  Dreamer : claire@example.com"
puts "  Maker   : chene@example.com"
