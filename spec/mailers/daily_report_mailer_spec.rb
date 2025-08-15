require "rails_helper"

RSpec.describe DailyReportMailer, type: :mailer do
  describe "daily_purchases_report" do
    let(:administrator) { create(:administrator) }
    let(:date) { Date.yesterday }
    let(:mail) { DailyReportMailer.daily_purchases_report(date) }

    before do
      # Asegurar que hay al menos un administrador para enviar el email
      administrator
    end

    it "renders the headers" do
      expected_subject = "Reporte Diario de Compras - #{date.strftime('%d/%m/%Y')}"
      expect(mail.subject).to eq(expected_subject)
      expect(mail.to).to include(administrator.email)
      expect(mail.from).to eq([ "noreply@puntospoint.com" ])
    end

    it "renders the body" do
      # Para emails multipart, acceder al contenido de texto plano
      text_part = mail.text_part.body.decoded
      expect(text_part).to match("REPORTE DIARIO DE COMPRAS")
      expect(text_part).to match(date.strftime('%d/%m/%Y'))

      # Verificar que también tenga contenido HTML
      html_part = mail.html_part.body.decoded
      expect(html_part).to match("Reporte Diario de Compras")
    end
  end
end
