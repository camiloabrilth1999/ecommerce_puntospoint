require "rails_helper"

RSpec.describe FirstPurchaseNotificationMailer, type: :mailer do
  describe "first_purchase_notification" do
    let(:administrator) { create(:administrator) }
    let(:category) { create(:category) }
    let(:product) { create(:product, administrator: administrator, categories: [ category ]) }
    let(:client) { create(:client) }
    let(:purchase) { create(:purchase, product: product, client: client) }
    let(:mail) { FirstPurchaseNotificationMailer.first_purchase_notification(purchase.id) }

    it "renders the headers" do
      expect(mail.subject).to eq("Primera compra del producto: #{product.name}")
      expect(mail.to).to eq([ administrator.email ])
      expect(mail.from).to eq([ "noreply@puntospoint.com" ])
    end

    it "renders the body" do
      # Para emails multipart, acceder al contenido de texto plano
      text_part = mail.text_part.body.decoded
      expect(text_part).to match(product.name)
      expect(text_part).to match(client.name)
      expect(text_part).to match("PRIMERA COMPRA REALIZADA")

      # Verificar que también tenga contenido HTML
      html_part = mail.html_part.body.decoded
      expect(html_part).to match(product.name)
    end
  end
end
