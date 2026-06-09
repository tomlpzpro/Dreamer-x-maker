class GenerateVisualJob < ApplicationJob
  queue_as :default

  def perform(llm_chat)
    conversation = llm_chat.llm_messages.map { |m| "#{m.role}: #{m.content}" }.join("\n")
    prompt = RubyLLM.chat.ask("Résume cette conversation en un prompt DALL-E de 100 mots maximum pour générer une image de l'objet décrit : #{conversation}")
    image = RubyLLM.paint(prompt.content)
    llm_chat.project.image.attach(
      io: StringIO.new(Base64.decode64(image.data)),
      filename: "generated_#{llm_chat.project.id}.png",
      content_type: "image/png"
    )

    Turbo::StreamsChannel.broadcast_update_to(
      llm_chat.project, target: "generate-project-image", partial: "projects/project_image", locals: { project: llm_chat.project }
    )

    
  end
end
