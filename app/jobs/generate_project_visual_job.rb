class GenerateProjectVisualJob < ApplicationJob
  queue_as :default

  def perform(chat)
    conversation = chat.llm_messages.map { |m| "#{m.role}: #{m.content}" }.join("\n")
    prompt = RubyLLM.chat.ask("Résume cette conversation en un prompt DALL-E de 100 mots maximum pour générer une image de l'objet décrit : #{conversation}")
    image = RubyLLM.paint(prompt.content)
    chat.project.image.attach(
      io: StringIO.new(Base64.decode64(image.data)),
      filename: "generated_#{chat.project.id}.png",
      content_type: "image/png"
    )
  end
end
